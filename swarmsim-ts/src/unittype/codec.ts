import * as IO from "io-ts";
import * as S from "../spreadsheet/original";

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

export const Effect = IO.type({
  type: IO.string,
  unittype: IO.string,
  val: IO.number,
  stat: IO.string,
  val2: IO.number,
  unittype2: IO.string,
  val3: IO.number,
});
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
    column: IO.number,
    tab: IO.string,
  }),
  IO.partial({
    init: IO.number,
    ascendPreserve: IO.boolean,
    disabled: IO.boolean,
    unbuyable: IO.boolean,
    isBuyHidden: IO.boolean,
    showparent: IO.boolean,
    warnfirst: WarnFirst,
    tier: IO.number,
    cost: IO.array(Cost),
    prod: IO.array(Prod),
    requires: IO.array(Require),
    effect: Effect,
  }),
]);
export type Unittype = IO.TypeOf<typeof Unittype>;

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
function prefixKeys(prefix: string, o: any): any {
  return Object.fromEntries(
    Object.entries(o).map(([k, v]) => [`${prefix}${k}`, v])
  );
}
export const FromSpreadsheet = new IO.Type<Unittype, S.Unittype[]>(
  "Unittype.FromSpreadsheet",
  // TODO
  (value): value is Unittype => true,
  (input: unknown, c) => IO.failure(input, c, "not implemented"),
  (o: Unittype): S.Unittype[] => {
    const len = Math.max(
      o.requires?.length || 0,
      o.cost?.length ?? 0,
      o.prod?.length ?? 0
    );
    const entries: S.Unittype[] = Array.from(Array(len || 1).keys()).map(
      (i) => ({
        ...empty,
        ...prefixKeys("requires.", (o.requires || [])[i] ?? {}),
        ...prefixKeys("cost.", (o.cost || [])[i] ?? {}),
        ...prefixKeys("prod.", (o.prod || [])[i] ?? {}),
        name: o.name,
      })
    );
    entries[0] = {
      ...entries[0],
      ...o.l,
      tab: o.tab,
      column: o.column,
      init: S.number.encode(o.init ?? 0),
      ascendPreserve: S.boolean.encode(o.ascendPreserve ?? false),
      disabled: S.boolean.encode(o.disabled ?? false),
      unbuyable: S.boolean.encode(o.unbuyable ?? false),
      isBuyHidden: S.boolean.encode(o.isBuyHidden ?? false),
      showparent: S.boolean.encode(o.showparent ?? false),
      "warnfirst.text": o.warnfirst?.text ?? "",
      "warnfirst.unittype": o.warnfirst?.unittype ?? "",
      "warnfirst.val": S.number.encode(o.warnfirst?.val ?? 0),
      tier: o.tier ?? "",
      "effect.stat": o.effect?.stat ?? "",
      "effect.type": o.effect?.type ?? "",
      "effect.unittype": o.effect?.unittype ?? "",
      "effect.unittype2": o.effect?.unittype2 ?? "",
      "effect.val": o.effect?.val ?? "",
      "effect.val2": o.effect?.val2 ?? "",
      "effect.val3": o.effect?.val3 ?? "",
    };
    return entries;
  }
);
