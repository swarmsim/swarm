import json from "./persist.test.json";
import { pipe } from "fp-ts/lib/function";
import * as P2 from "../generated/persist";
import * as Proto from "./proto";
import fs from "fs/promises";
import LZ from "lz-string";

test("persist proto: basic", () => {
  function smallD(small: number): P2.Decimal {
    return { value: { oneofKind: "small", small } };
  }
  function bigD(big: string): P2.Decimal {
    return { value: { oneofKind: "big", big } };
  }
  function tinyD(tiny: number): P2.Decimal {
    return { value: { oneofKind: "tiny", tiny } };
  }
  const body: P2.Persist = {
    units: { 1: smallD(123) },
    upgrades: { 2: bigD("456") },
    achievements: { 3: 789 },
    watched: { 2: 1 },
    skippedMillis: 0,
    statistics: {
      byUnit: {
        1: {
          clicks: 3,
          elapsedFirst: 123456,
          num: tinyD(123),
          twinnum: tinyD(456),
        },
      },
      byUpgrade: {
        1: { clicks: 3, elapsedFirst: 123456, num: tinyD(123) },
      },
    },
    version: { started: "1.1.14", saved: "1.1.14" },
  };
  expect(
    pipe(
      body,
      (v) => P2.Persist.toJson(v),
      (v) => P2.Persist.fromJson(v)
    )
  ).toEqual(body);
});

// TODO: decimal precision comparison issues
test.skip.each(json.exports)("persist proto: $name", (d) => {
  const body = JSON.parse(d.body);

  // write files for ad-hoc size comparisons.
  // protos don't help this as much as I thought...!
  // fs.writeFile(
  // `${__dirname}/${d.name}.bin`,
  // LZ.compressToBase64(P2.Persist.toBinary(Proto.fromLegacy(body)).toString())
  // );
  // fs.writeFile(
  // `${__dirname}/${d.name}.raw`,
  // P2.Persist.toBinary(Proto.fromLegacy(body)).toString()
  // );
  // fs.writeFile(`${__dirname}/${d.name}.old`, d.export_);

  // console.log(P2.Persist.fields);
  expect(
    pipe(
      body,
      Proto.fromLegacy,
      (v) => P2.Persist.toJson(v),
      (v) => P2.Persist.fromJson(v),
      Proto.toLegacy
    )
  ).toEqual(body);
  expect(
    pipe(
      body,
      Proto.fromLegacy,
      (v) => P2.Persist.toJsonString(v),
      (v) => P2.Persist.fromJsonString(v),
      Proto.toLegacy
    )
  ).toEqual(body);
  expect(
    pipe(
      body,
      Proto.fromLegacy,
      (v) => P2.Persist.toBinary(v),
      (v) => P2.Persist.fromBinary(v),
      Proto.toLegacy
    )
  ).toEqual(body);
});
// TODO: decimal precision comparison issues
test.each(json.exports)("proto snapshot: $name", (d) => {
  const body = JSON.parse(d.body);
  expect(
    pipe(
      body,
      Proto.fromLegacy,
      (v) => P2.Persist.toBinary(v),
      (b) => [b.byteLength, btoa(b.toString())]
    )
  ).toMatchSnapshot(`binary protobuf: ${d.name}`);
});
