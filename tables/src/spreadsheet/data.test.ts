import toSpreadsheet from "./data";
import originalData from "../spreadsheet/original-data.json";

test.skip("data matches original-data, when it exists", () => {
  const gen = toSpreadsheet();
  expect(gen).toEqual(originalData);
});
