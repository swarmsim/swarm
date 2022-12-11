import * as IO from "io-ts";
/**
 * The original spreadsheet schema. The old swarmsim code expects these fields
 */

export const string = IO.string;
const number_ = IO.union([IO.literal(""), IO.number]);
export const number = number_.pipe(
  new IO.Type("Spreadsheet.number", number_.is, number_.validate, (output) =>
    output === 0 ? "" : output
  )
);
const boolean_ = IO.union([IO.literal(""), IO.literal("TRUE")]);
export const boolean = new IO.Type<boolean, "" | "TRUE">(
  "Spreadsheet.boolean",
  (b): b is boolean => typeof b === "boolean",
  (input, c) => {
    switch (input) {
      case "TRUE":
        return IO.success(true);
      case "":
        return IO.success(true);
      default:
        return IO.failure(input, c, "unknown boolean value");
    }
  },
  (output) => (output ? "TRUE" : "")
);

export const Achievement = IO.type({
  name: string,
  label: string,
  description: string,
  longdesc: string,
  "requires.event": string,
  "requires.unittype": string,
  "requires.upgradetype": string,
  "requires.val": IO.union([IO.number, IO.string]),
  points: number,
  "visible.unittype": string,
  "visible.upgradetype": string,
  "visible.val": number,
});
export type Achievement = IO.TypeOf<typeof Achievement>;

export const Mtx = IO.type({
  name: string,
  label: string,
  description: string,
  price_kreds: number,
  price_usd_paypal: number,
  uses: number,
  "pack.unittype": string,
  bulkbonus: number,
  "pack.val": number,
  paypalSandboxUrl: string,
  paypalLegacyGithubUrl: string,
  paypalSwarmsimDotComUrl: string,
});
export type Mtx = IO.TypeOf<typeof Mtx>;

export const Unittype = IO.type({
  name: string,
  label: string,
  plural: string,
  verb: string,
  verbone: string,
  verbing: string,
  column: number_,
  tab: string,
  init: number_,
  ascendPreserve: string,
  description: string,
  lol: string,
  disabled: string,
  unbuyable: string,
  isBuyHidden: string,
  tier: number_,
  "cost.unittype": string,
  "cost.val": number,
  "prod.unittype": string,
  "prod.val": number,
  showparent: string,
  "warnfirst.unittype": string,
  "warnfirst.val": number_,
  "warnfirst.text": string,
  "requires.unittype": string,
  "requires.upgradetype": string,
  "requires.val": number_,
  "requires.op": string,
  "effect.type": string,
  "effect.unittype": string,
  "effect.val": number_,
  "effect.stat": string,
  "effect.val2": number_,
  "effect.unittype2": string,
  "effect.val3": number_,
});
export type Unittype = IO.TypeOf<typeof Unittype>;

export const Upgrade = IO.type({
  name: string,
  label: string,
  description: string,
  lol: string,
  maxlevel: number,
  class: string,
  unittype: string,
  "requires.unittype": string,
  "requires.val": number,
  "cost.unittype": string,
  "cost.val": number,
  "cost.factor": number,
  "effect.type": string,
  "effect.unittype": string,
  "effect.upgradetype": string,
  "effect.val": number,
  "effect.stat": string,
  "effect.val2": number,
  "effect.unittype2": string,
});
export type Upgrade = IO.TypeOf<typeof Upgrade>;

export function Sheet<T>(row: IO.Type<T>): IO.Type<Sheet<T>> {
  return IO.type({
    name: string,
    column_names: IO.array(string),
    elements: IO.array(row),
  });
}
export type Sheet<T> = {
  name: string;
  column_names: string[];
  elements: T[];
};

export const Schema = IO.type({
  achievements: Sheet(Achievement),
  mtx: Sheet(Mtx),
  unittypes: Sheet(Unittype),
  upgrades: Sheet(Upgrade),
});
export type Schema = IO.TypeOf<typeof Schema>;

export const sheet_names = ["achievements", "mtx", "unittypes", "upgrades"];
