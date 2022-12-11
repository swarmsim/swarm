import * as Un from "./unittype/codec";
import * as Up from "./upgrade/codec";
import originalData from "./spreadsheet/original-data.json";
import fs from "fs/promises";
import path from "path";
import { orThrow } from "./util";

async function main() {
  await Promise.all([
    fs.writeFile(filename("unittype"), genUnittype()),
    fs.writeFile(filename("upgrade"), genUpgrade()),
  ]);
}
function filename(dir: string): string {
  return path.join(__dirname, dir, "data.ts");
}
function genUpgrade(): string {
  const data = orThrow(Up.sheetDecode(originalData.upgrades));
  return `\
import * as C from "./codec";

const list: C.Upgrade[] = ${JSON.stringify(data, null, 2)};
export default list;
`;
}
function genUnittype(): string {
  const data = orThrow(Un.sheetDecode(originalData.unittypes));
  return `\
import * as C from "./codec";

const list: C.Unittype[] = ${JSON.stringify(data, null, 2)};
export default list;
`;
}
main().catch((err) => {
  console.error(err);
  process.exit(1);
});
