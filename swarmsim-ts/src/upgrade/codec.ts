import * as IO from "io-ts";
import * as S from "../spreadsheet/original";
import * as E from "fp-ts/lib/Either";
import { prefixKeys } from "../util";
import { pipe } from "fp-ts/lib/function";
import * as A from "fp-ts/lib/Array";

export const Cost = IO.type({
  unittype: IO.string,
  val: IO.number,
  factor: IO.number,
});
export type Cost = IO.TypeOf<typeof Cost>;

export const Require = IO.type({
  unittype: IO.string,
  val: IO.number,
});
export type Require = IO.TypeOf<typeof Require>;

export const Effect = IO.intersection([
  IO.type({
    type: IO.string,
    unittype: IO.string,
  }),
  IO.partial({
    stat: IO.string,
    val: IO.number,
    upgradetype: IO.string,
    val2: IO.number,
    unittype2: IO.string,
  }),
]);
export type Effect = IO.TypeOf<typeof Effect>;

export const Upgrade = IO.intersection([
  IO.type({
    name: IO.string,
    l: IO.type({
      label: IO.string,
      description: IO.string,
      lol: IO.string,
    }),
    class: IO.union([IO.literal("upgrade"), IO.literal("ability")]),
    unittype: IO.string,
  }),
  IO.partial({
    maxlevel: IO.number,
    cost: IO.array(Cost),
    requires: IO.array(Require),
    effect: IO.array(Effect),
  }),
]);
export type Upgrade = IO.TypeOf<typeof Upgrade>;

const empty: S.Upgrade = {
  name: "",
  description: "",
  lol: "",
  label: "",
  class: "",
  maxlevel: "",
  unittype: "",
  "cost.unittype": "",
  "cost.val": "",
  "cost.factor": "",
  "requires.unittype": "",
  "requires.val": "",
  "effect.stat": "",
  "effect.type": "",
  "effect.unittype": "",
  "effect.unittype2": "",
  "effect.upgradetype": "",
  "effect.val": "",
  "effect.val2": "",
};

export const FromSpreadsheet = IO.array(S.Upgrade).pipe(
  new IO.Type(
    "Upgrade.FromSpreadsheet",
    (value): value is Upgrade => true,
    (rows: S.Upgrade[], c) => {
      const requires: Require[] = rows
        .map((r) =>
          r["requires.unittype"]
            ? [
                {
                  unittype: r["requires.unittype"],
                  val: r["requires.val"] || 0,
                },
              ]
            : []
        )
        .flat();
      const effect: Effect[] = rows
        .map((r) => {
          if (!r["effect.type"]) {
            return [];
          }
          const o: Effect = {
            type: r["effect.type"],
            unittype: r["effect.unittype"],
          };
          if (r["effect.upgradetype"]) o.upgradetype = r["effect.upgradetype"];
          if (r["effect.stat"]) o.stat = r["effect.stat"];
          if (r["effect.val"] !== "") o.val = r["effect.val"] || 0;
          if (r["effect.unittype2"]) o.unittype2 = r["effect.unittype2"];
          if (r["effect.val2"] !== "") o.val2 = r["effect.val2"] || 0;
          return [o];
        })
        .flat();
      const cost: Cost[] = rows
        .map((r) =>
          r["cost.unittype"]
            ? [
                {
                  unittype: r["cost.unittype"],
                  val: r["cost.val"] || 0,
                  factor: r["cost.factor"] || 0,
                },
              ]
            : []
        )
        .flat();
      const r = rows[0];
      if (r.class !== "ability" && r.class !== "upgrade")
        throw new Error("r.class");
      const o: Upgrade = {
        name: r.name,
        l: {
          description: r.description,
          label: r.label,
          lol: r.lol,
        },
        class: r.class,
        unittype: r.unittype,
      };
      if (requires.length) o.requires = requires;
      if (cost.length) o.cost = cost;
      if (effect.length) o.effect = effect;
      if (r.maxlevel !== "") o.maxlevel = r.maxlevel;
      return IO.success(o);
    },
    (o: Upgrade): S.Upgrade[] => {
      const len = Math.max(
        o.requires?.length ?? 0,
        o.cost?.length ?? 0,
        o.effect?.length ?? 0
      );
      const entries: S.Upgrade[] = Array.from(Array(len || 1).keys()).map(
        (i) => ({
          ...empty,
          ...prefixKeys("requires.", (o.requires || [])[i] ?? {}),
          ...prefixKeys("cost.", (o.cost || [])[i] ?? {}),
          ...prefixKeys("effect.", (o.effect || [])[i] ?? {}),
          name: o.name,
        })
      );
      entries[0] = {
        ...entries[0],
        ...o.l,
        class: o.class,
        maxlevel: o.maxlevel ?? "",
        unittype: o.unittype,
      };
      return entries;
    }
  )
);

export function sheetByName(
  sheet: S.Sheet<{ name: string }>
): E.Either<IO.Errors, { [s: string]: S.Upgrade[] }> {
  return pipe(
    sheet,
    S.Sheet(S.Upgrade).decode,
    E.map((s) =>
      s.elements.reduce((accum, d) => {
        accum[d.name] = (accum[d.name] ?? []).concat([d]);
        return accum;
      }, {} as { [s: string]: S.Upgrade[] })
    )
  );
}
function decodes(byName: {
  [s: string]: S.Upgrade[];
}): E.Either<IO.Errors, Upgrade[]> {
  return pipe(
    byName,
    Object.values,
    // (vs) => vs.map((v) => FromSpreadsheet.decode(v)),
    A.map(FromSpreadsheet.decode),
    // E.Either<x, Upgrade>[] => E.Either<x, Upgrade[]>
    A.sequence(E.Applicative)
  );
}

export function sheetDecode(
  sheet: S.Sheet<{ name: string }>
): E.Either<IO.Errors, Upgrade[]> {
  return pipe(sheet, sheetByName, E.chain(decodes));
}
