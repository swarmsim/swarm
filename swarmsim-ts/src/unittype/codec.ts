import * as IO from "io-ts";
import * as S from "../spreadsheet/original";
import * as E from "fp-ts/lib/Either";
import { prefixKeys, replaceKey } from "../util";
import { pipe } from "fp-ts/lib/function";
import * as A from "fp-ts/lib/Array";
import { PathReporter } from "io-ts/lib/PathReporter";

export const Cost = IO.type({
  unittype: IO.string,
  val: IO.number,
});
export type Cost = IO.TypeOf<typeof Cost>;

export const Prod = IO.type({
  unittype: IO.string,
  val: IO.number,
});
export type Prod = IO.TypeOf<typeof Prod>;

export const WarnFirst = IO.type({
  unittype: IO.string,
  val: IO.number,
  text: IO.string,
});
export type WarnFirst = IO.TypeOf<typeof WarnFirst>;

export const Require = IO.intersection([
  IO.union([
    IO.type({
      unittype: IO.string,
      val: IO.number,
    }),
    IO.type({
      upgrade: IO.string,
      val: IO.number,
    }),
  ]),
  IO.partial({ op: IO.string }),
]);
export type Require = IO.TypeOf<typeof Require>;

export const Effect = IO.intersection([
  IO.type({
    type: IO.string,
    unittype: IO.string,
    val: IO.number,
    stat: IO.string,
  }),
  IO.partial({
    val2: IO.number,
    unittype2: IO.string,
    val3: IO.number,
  }),
]);
export type Effect = IO.TypeOf<typeof Effect>;

export const Unittype = IO.intersection([
  IO.type({
    name: IO.string,
    l: IO.type({
      label: IO.string,
      plural: IO.string,
      verb: IO.string,
      verbone: IO.string,
      verbing: IO.string,
      description: IO.string,
      lol: IO.string,
    }),
    tab: IO.string,
  }),
  IO.partial({
    column: IO.number,
    init: IO.number,
    ascendPreserve: IO.boolean,
    disabled: IO.boolean,
    unbuyable: IO.boolean,
    isBuyHidden: IO.boolean,
    showparent: IO.string,
    warnfirst: WarnFirst,
    tier: IO.number,
    cost: IO.array(Cost),
    prod: IO.array(Prod),
    requires: IO.array(Require),
    effect: IO.array(Effect),
  }),
]);
export type Unittype = IO.TypeOf<typeof Unittype>;

export const NEffect = IO.type({ name: IO.string, effect: Effect });
export type NEffect = IO.TypeOf<typeof NEffect>;
export function normalizeEffect(us: Unittype[]): NEffect[] {
  return us.flatMap((u) =>
    (u.effect || []).map((effect) => ({ name: u.name, effect }))
  );
}

export const NRequire = IO.type({ name: IO.string, requires: Require });
export type NRequire = IO.TypeOf<typeof NRequire>;
export function normalizeRequire(us: Unittype[]): NRequire[] {
  return us.flatMap((u) =>
    (u.requires || []).map((requires) => ({ name: u.name, requires }))
  );
}

export const NCost = IO.type({ name: IO.string, cost: Cost });
export type NCost = IO.TypeOf<typeof NCost>;
export function normalizeCost(us: Unittype[]): NCost[] {
  return us.flatMap((u) =>
    (u.cost || []).map((cost) => ({ name: u.name, cost }))
  );
}

export const NProd = IO.type({ name: IO.string, prod: Prod });
export type NProd = IO.TypeOf<typeof NProd>;
export function normalizeProd(us: Unittype[]): NProd[] {
  return us.flatMap((u) =>
    (u.prod || []).map((prod) => ({ name: u.name, prod }))
  );
}

const empty: S.Unittype = {
  name: "",
  description: "",
  lol: "",
  label: "",
  plural: "",
  verb: "",
  verbone: "",
  verbing: "",
  tab: "",
  column: "",
  init: "",
  ascendPreserve: "",
  disabled: "",
  unbuyable: "",
  isBuyHidden: "",
  showparent: "",
  "warnfirst.text": "",
  "warnfirst.unittype": "",
  "warnfirst.val": "",
  tier: "",
  "cost.unittype": "",
  "cost.val": "",
  "prod.unittype": "",
  "prod.val": "",
  "requires.op": "",
  "requires.unittype": "",
  "requires.upgradetype": "",
  "requires.val": "",
  "effect.stat": "",
  "effect.type": "",
  "effect.unittype": "",
  "effect.unittype2": "",
  "effect.val": "",
  "effect.val2": "",
  "effect.val3": "",
};
export const FromSpreadsheet = IO.array(S.Unittype).pipe(
  new IO.Type(
    "Unittype.FromSpreadsheet",
    // TODO
    (value): value is Unittype => true,
    (rows: S.Unittype[], c) => {
      const requires: Require[] = rows
        .map((r) => {
          if (!r["requires.unittype"] && !r["requires.upgradetype"]) {
            return [];
          }
          const o: Require = {
            val: r["requires.val"] || 0,
            ...(r["requires.unittype"]
              ? { unittype: r["requires.unittype"] }
              : { upgrade: r["requires.upgradetype"] }),
          };
          if (r["requires.op"]) o.op = r["requires.op"];
          return [o];
        })
        .flat();
      const effect: Effect[] = rows
        .map((r) => {
          if (!r["effect.type"]) {
            return [];
          }
          const o: Effect = {
            type: r["effect.type"],
            stat: r["effect.stat"],
            unittype: r["effect.unittype"],
            val: r["effect.val"] || 0,
          };
          if (r["effect.unittype2"]) o.unittype2 = r["effect.unittype2"];
          if (r["effect.val2"] !== "") o.val2 = r["effect.val2"] || 0;
          if (r["effect.val3"] !== "") o.val3 = r["effect.val3"] || 0;
          return [o];
        })
        .flat();
      const cost: Cost[] = rows
        .map((r) =>
          r["cost.unittype"]
            ? [{ unittype: r["cost.unittype"], val: r["cost.val"] || 0 }]
            : []
        )
        .flat();
      const prod: Prod[] = rows
        .map((r) =>
          r["prod.unittype"]
            ? [{ unittype: r["prod.unittype"], val: r["prod.val"] || 0 }]
            : []
        )
        .flat();
      const r = rows[0];
      const o: Unittype = {
        name: r.name,
        tab: r.tab,
        l: {
          description: r.description,
          label: r.label,
          plural: r.plural,
          lol: r.lol,
          verb: r.verb,
          verbing: r.verbing,
          verbone: r.verbone,
        },
      };
      if (requires.length) o.requires = requires;
      if (cost.length) o.cost = cost;
      if (prod.length) o.prod = prod;
      if (effect.length) o.effect = effect;
      if (r.column !== "") o.column = r.column;
      if (r.init) o.init = r.init;
      if (r.tier !== "") o.tier = r.tier;
      if (r.column !== "") o.column = r.column;
      if (r.showparent) o.showparent = r.showparent;
      if (r.disabled) o.disabled = true;
      if (r.unbuyable !== "") o.unbuyable = true;
      if (r.isBuyHidden !== "") o.isBuyHidden = true;
      if (r.ascendPreserve !== "") o.ascendPreserve = true;
      if (r["warnfirst.unittype"] !== "") {
        o.warnfirst = {
          text: r["warnfirst.text"],
          unittype: r["warnfirst.unittype"],
          val: r["warnfirst.val"] || 0,
        };
      }
      return IO.success(o);
    },
    (o: Unittype): S.Unittype[] => {
      const len = Math.max(
        o.requires?.length ?? 0,
        o.cost?.length ?? 0,
        o.prod?.length ?? 0,
        o.effect?.length ?? 0
      );
      const entries: S.Unittype[] = Array.from(Array(len || 1).keys()).map(
        (i) => ({
          ...empty,
          ...prefixKeys(
            "requires.",
            replaceKey("upgrade", "upgradetype", (o.requires || [])[i] ?? {})
          ),
          ...prefixKeys("cost.", (o.cost || [])[i] ?? {}),
          ...prefixKeys("prod.", (o.prod || [])[i] ?? {}),
          ...prefixKeys("effect.", (o.effect || [])[i] ?? {}),
          name: o.name,
        })
      );
      entries[0] = {
        ...entries[0],
        ...o.l,
        tab: o.tab,
        column: o.column ?? "",
        init: S.number.encode(o.init ?? 0),
        ascendPreserve: S.boolean.encode(o.ascendPreserve ?? false),
        disabled: S.boolean.encode(o.disabled ?? false),
        unbuyable: S.boolean.encode(o.unbuyable ?? false),
        isBuyHidden: S.boolean.encode(o.isBuyHidden ?? false),
        showparent: o.showparent ?? "",
        "warnfirst.text": o.warnfirst?.text ?? "",
        "warnfirst.unittype": o.warnfirst?.unittype ?? "",
        "warnfirst.val": S.number.encode(o.warnfirst?.val ?? 0),
        tier: o.tier ?? "",
      };
      return entries;
    }
  )
);

export function sheetByName(
  sheet: S.Sheet<{ name: string }>
): E.Either<IO.Errors, { [s: string]: S.Unittype[] }> {
  return pipe(
    sheet,
    S.Sheet(S.Unittype).decode,
    E.map((s) =>
      s.elements.reduce((accum, d) => {
        accum[d.name] = (accum[d.name] ?? []).concat([d]);
        return accum;
      }, {} as { [s: string]: S.Unittype[] })
    )
  );
}
function decodes(byName: {
  [s: string]: S.Unittype[];
}): E.Either<IO.Errors, Unittype[]> {
  return pipe(
    byName,
    Object.values,
    // (vs) => vs.map((v) => FromSpreadsheet.decode(v)),
    A.map(FromSpreadsheet.decode),
    // E.Either<x, Upgrade>[] => E.Either<x, Unittype[]>
    A.sequence(E.Applicative)
  );
}

export function sheetDecode(
  sheet: S.Sheet<{ name: string }>
): E.Either<IO.Errors, Unittype[]> {
  return pipe(sheet, sheetByName, E.chain(decodes));
}
