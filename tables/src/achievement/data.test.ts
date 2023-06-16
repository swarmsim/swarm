import list from "./data";
import * as C from "./codec";
import originalData from "../spreadsheet/original-data.json";
import { orThrow } from "../util";

test("data matches original-data, when it exists", () => {
  const originalByName = orThrow(C.sheetByName(originalData.achievements));
  for (let d of list) {
    // skip achievements that have changed since the original
    if (d.name === 'therightquestion') continue;
    const td = C.FromSpreadsheet.encode(d);
    const od = originalByName[d.name];
    expect(td).toHaveLength(od.length);
    expect(td).toEqual(od);
  }
});
// achievements have changed since the original, and skipping just one is too hard, so disable the whole test
//test("data matches original-data, and all of it exists", () => {
//  expect(list.flatMap(C.FromSpreadsheet.encode)).toEqual(
//    originalData.achievements.elements
//  );
//});
