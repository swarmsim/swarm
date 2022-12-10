import * as S from "./original";
// data copied from swarmsim-coffee/app/scripts/spreadsheetpreload/v0.2.js
import json from "./original-data.json";
import { PathReporter } from "io-ts/lib/PathReporter";

test("spreadsheet typings match real spreadsheet: achievements", () => {
  const res = S.Sheet(S.Achievement).decode(json.achievements);
  expect(PathReporter.report(res)[0]).toEqual("No errors!");
});
test("spreadsheet typings match real spreadsheet: mtx", () => {
  const res = S.Sheet(S.Mtx).decode(json.mtx);
  expect(PathReporter.report(res)[0]).toEqual("No errors!");
});
test("spreadsheet typings match real spreadsheet: unittypes", () => {
  const res = S.Sheet(S.Unittype).decode(json.unittypes);
  expect(PathReporter.report(res)[0]).toEqual("No errors!");
});
test("spreadsheet typings match real spreadsheet: upgrades", () => {
  const res = S.Sheet(S.Upgrade).decode(json.upgrades);
  expect(PathReporter.report(res)[0]).toEqual("No errors!");
});
test("spreadsheet typings match real spreadsheet: all", () => {
  const res = S.Schema.decode(json);
  expect(PathReporter.report(res)[0]).toEqual("No errors!");
});
