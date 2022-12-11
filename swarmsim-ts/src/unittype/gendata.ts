import * as C from "./codec";
import * as S from "../spreadsheet/original";
import originalData from "../spreadsheet/original-data.json";
import { PathReporter } from "io-ts/lib/PathReporter";
import fs from "fs/promises";
import path from "path";

async function main() {
  const sheet = S.Sheet(S.Unittype).decode(originalData.unittypes);
  if (sheet._tag !== "Right") throw new Error();
  const byName = sheet.right.elements.reduce((accum, d) => {
    accum[d.name] = (accum[d.name] ?? []).concat([d]);
    return accum;
  }, {} as { [s: string]: S.Unittype[] });
  const data = Object.values(byName)
    .map(C.FromSpreadsheet.decode)
    .map((res) => {
      if (res._tag === "Right") {
        return res.right;
      }
      throw new Error(...PathReporter.report(res));
    });

  const gen = `\
import * as C from "./codec";

const list: C.Unittype[] = ${JSON.stringify(data, null, 2)};
export default list;
`;
  const filename = path.join(__dirname, "data.ts");
  await fs.writeFile(filename, gen);
}
main().catch((err) => {
  console.error(err);
  process.exit(1);
});
