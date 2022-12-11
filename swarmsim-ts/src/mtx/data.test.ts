import list from "./data";
import * as C from "./codec";
import originalData from "../spreadsheet/original-data.json";
import { orThrow } from "../util";

test("data matches original-data, when it exists", () => {
  const originalByName = orThrow(C.sheetByName(originalData.mtx));
  for (let d of list) {
    const td = C.FromSpreadsheet.encode(d);
    const od = originalByName[td.name];
    expect(td).toEqual(od);
  }
});
test.skip("data matches original-data, and all of it exists", () => {
  fail("todo");
});
