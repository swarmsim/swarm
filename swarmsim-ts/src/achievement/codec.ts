import * as IO from "io-ts";
import * as S from "../spreadsheet/original";
import * as E from "fp-ts/lib/Either";
import { prefixKeys } from "../util";
import { pipe } from "fp-ts/lib/function";
import * as A from "fp-ts/lib/Array";

export const Require = IO.union([
  IO.type({
    event: IO.string,
    val: IO.string,
  }),
  IO.type({
    unittype: IO.string,
    val: IO.number,
  }),
  IO.type({
    upgradetype: IO.string,
    val: IO.number,
  }),
]);
export type Require = IO.TypeOf<typeof Require>;

export const Visible = IO.union([
  IO.type({
    unittype: IO.string,
    val: IO.number,
  }),
  IO.type({
    upgradetype: IO.string,
    val: IO.number,
  }),
]);
export type Visible = IO.TypeOf<typeof Visible>;

export const Achievement = IO.type({
  name: IO.string,
  l: IO.type({
    label: IO.string,
    description: IO.string,
    longdesc: IO.string,
  }),
  points: IO.number,
  requires: IO.array(Require),
  visible: IO.array(Visible),
});
export type Achievement = IO.TypeOf<typeof Achievement>;

export const NRequire = IO.type({ name: IO.string, requires: Require });
export type NRequire = IO.TypeOf<typeof NRequire>;
export function normalizeRequire(us: Achievement[]): NRequire[] {
  return us.flatMap((u) =>
    (u.requires || []).map((requires) => ({ name: u.name, requires }))
  );
}

export const NVisible = IO.type({ name: IO.string, visible: Visible });
export type NVisible = IO.TypeOf<typeof NVisible>;
export function normalizeVisible(us: Achievement[]): NVisible[] {
  return us.flatMap((u) =>
    (u.visible || []).map((visible) => ({ name: u.name, visible }))
  );
}

const empty: S.Achievement = {
  name: "",
  description: "",
  label: "",
  longdesc: "",
  points: "",
  "requires.event": "",
  "requires.unittype": "",
  "requires.upgradetype": "",
  "requires.val": "",
  "visible.unittype": "",
  "visible.upgradetype": "",
  "visible.val": "",
};

function assertString(value: unknown): string {
  if (typeof value !== "string") {
    throw new Error("string");
  }
  return value;
}
function assertNumber<V>(value: unknown): number {
  if (typeof value !== "number") {
    throw new Error("number");
  }
  return value;
}
export const FromSpreadsheet = IO.array(S.Achievement).pipe(
  new IO.Type(
    "Achievement.FromSpreadsheet",
    (value): value is Achievement => true,
    (rows: S.Achievement[], c) => {
      const requires: Require[] = rows
        .map((r) =>
          r["requires.event"]
            ? [
                {
                  event: r["requires.event"],
                  val: assertString(r["requires.val"]),
                },
              ]
            : r["requires.unittype"]
            ? [
                {
                  unittype: r["requires.unittype"],
                  val: assertNumber(r["requires.val"] || 0),
                },
              ]
            : r["requires.upgradetype"]
            ? [
                {
                  upgradetype: r["requires.upgradetype"],
                  val: assertNumber(r["requires.val"] || 0),
                },
              ]
            : []
        )
        .flat();
      const visible: Visible[] = rows
        .map((r) =>
          r["visible.unittype"]
            ? [
                {
                  unittype: r["visible.unittype"],
                  val: r["visible.val"] || 0,
                },
              ]
            : r["visible.upgradetype"]
            ? [
                {
                  upgradetype: r["visible.upgradetype"],
                  val: r["visible.val"] || 0,
                },
              ]
            : []
        )
        .flat();
      const r = rows[0];
      const o: Achievement = {
        name: r.name,
        l: {
          description: r.description,
          label: r.label,
          longdesc: r.longdesc,
        },
        points: r.points || 0,
        requires,
        visible,
      };
      return IO.success(o);
    },
    (o: Achievement): S.Achievement[] => {
      const len = Math.max(o.requires?.length ?? 0, o.visible?.length ?? 0);
      const entries: S.Achievement[] = Array.from(Array(len || 1).keys()).map(
        (i) => ({
          ...empty,
          ...prefixKeys("requires.", (o.requires || [])[i] ?? {}),
          ...prefixKeys("visible.", (o.visible || [])[i] ?? {}),
          name: o.name,
        })
      );
      entries[0] = {
        ...entries[0],
        ...o.l,
        points: o.points,
      };
      return entries;
    }
  )
);

export function sheetByName(
  sheet: S.Sheet<{ name: string }>
): E.Either<IO.Errors, { [s: string]: S.Achievement[] }> {
  return pipe(
    sheet,
    S.Sheet(S.Achievement).decode,
    E.map((s) =>
      s.elements.reduce((accum, d) => {
        accum[d.name] = (accum[d.name] ?? []).concat([d]);
        return accum;
      }, {} as { [s: string]: S.Achievement[] })
    )
  );
}
function decodes(byName: {
  [s: string]: S.Achievement[];
}): E.Either<IO.Errors, Achievement[]> {
  return pipe(
    byName,
    Object.values,
    // (vs) => vs.map((v) => FromSpreadsheet.decode(v)),
    A.map(FromSpreadsheet.decode),
    // E.Either<x, Achievement>[] => E.Either<x, Achievement[]>
    A.sequence(E.Applicative)
  );
}

export function sheetDecode(
  sheet: S.Sheet<{ name: string }>
): E.Either<IO.Errors, Achievement[]> {
  return pipe(sheet, sheetByName, E.chain(decodes));
}
