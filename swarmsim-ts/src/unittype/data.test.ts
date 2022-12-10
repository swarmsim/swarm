import list from "./data";
import * as C from "./codec";
import * as S from "../spreadsheet/original";
import originalData from "../spreadsheet/original-data.json";

const originalUnittypes = S.Sheet(S.Unittype).decode(originalData.unittypes);
if (originalUnittypes._tag !== "Right") throw new Error();
const originalByName = originalUnittypes.right.elements.reduce((accum, d) => {
  accum[d.name] = (accum[d.name] ?? []).concat([d]);
  return accum;
}, {} as { [s: string]: S.Unittype[] });
test("data matches original-data, when it exists", () => {
  for (let d of list) {
    const td = C.FromSpreadsheet.encode(d);
    const od = originalByName[d.name];
    expect(td).toHaveLength(od.length);
    expect(td).toEqual(od);
  }
});
test.skip("data matches original-data, and all of it exists", () => {
  fail("todo");
});
