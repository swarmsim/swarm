import * as Un from "./unittype/codec";
import * as Up from "./upgrade/codec";
import * as A from "./achievement/codec";
import * as Mtx from "./mtx/codec";
import originalData from "./spreadsheet/original-data.json";
import fs from "fs/promises";
import path from "path";
import { orThrow } from "./util";

async function main() {
  await Promise.all([
    fs.writeFile(filename("unittype"), genUnittype()),
    fs.writeFile(filename("upgrade"), genUpgrade()),
    fs.writeFile(filename("achievement"), genAchievement()),
    fs.writeFile(filename("mtx"), genMtx()),
  ]);
}
function filename(dir: string): string {
  return path.join(__dirname, dir, "data.ts");
}
function genMtx(): string {
  const data = originalData.mtx.elements;
  return `\
import * as C from "./codec";

const list: C.Mtx[] = ${JSON.stringify(data, null, 2)};
export default list;
`;
}
main().catch((err) => {
  console.error(err);
  process.exit(1);
});

function genAchievement(): string {
  const data = orThrow(A.sheetDecode(originalData.achievements));
  return `\
import * as C from "./codec";

const list: C.Achievement[] = ${JSON.stringify(data, null, 2)};
export default list;
`;
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
