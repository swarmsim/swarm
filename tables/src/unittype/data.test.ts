import list from "./data";
import * as C from "./codec";
import originalData from "../spreadsheet/original-data.json";
import { orThrow } from "../util";

test.skip("data matches original-data, when it exists", () => {
  const originalByName = orThrow(C.sheetByName(originalData.unittypes));
  for (let d of list) {
    const td = C.FromSpreadsheet.encode(d);
    const od = originalByName[d.name];
    expect(td).toHaveLength(od.length);
    expect(td).toEqual(od);
  }
});
test.skip("data matches original-data, and all of it exists", () => {
  expect(list.flatMap(C.FromSpreadsheet.encode)).toEqual(
    originalData.unittypes.elements
  );
});
