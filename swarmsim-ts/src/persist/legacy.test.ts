import json from "./persist.test.json";
import LZ from "lz-string";
import * as P from "./legacy";
import * as E from "fp-ts/lib/Either";
import * as O from "fp-ts/Option";
import * as IO from "io-ts";
import { PathReporter } from "io-ts/lib/PathReporter";
import { pipe } from "fp-ts/lib/function";

test.each(json.simple)("persist base64: $dec", (data) => {
  const { dec } = data;
  const enc = data.b64;
  // as a sanity check, I know these work, even though they're deprecated
  expect(btoa(dec)).toEqual(enc);
  expect(atob(enc)).toEqual(dec);
  expect(() => atob(`!${enc}`)).toThrow();
  // test the actual codec
  expect(P.Base64.encode(dec)).toEqual(enc);
  expect(P.Base64.decode(enc)).toEqual(E.right(dec));
  expect(P.Base64.decode(P.Base64.encode(dec))).toEqual(E.right(dec));
  expect(P.Base64.decode(`a${enc}`)).toMatchObject(E.left(expect.anything()));
  expect(P.Base64.decode(`!${enc}`)).toMatchObject(E.left(expect.anything()));
  expect(enc.length % 4).toBe(0);
});
test.each(json.simple)("persist lz-string: $dec", (data) => {
  const { dec } = data;
  const enc = data.lz;
  // verify that decompress returns empty on error
  expect(LZ.decompressFromBase64(LZ.compressToBase64(dec))).toBe(dec);
  expect(LZ.decompressFromBase64(`a${LZ.compressToBase64(dec)}`)).toBe("");
  // test the actual codec
  expect(P.LZString.encode(dec)).toEqual(enc);
  expect(P.LZString.decode(enc)).toEqual(E.right(dec));
  expect(P.LZString.decode(P.LZString.encode(dec))).toEqual(E.right(dec));
  expect(P.LZString.decode(`a${enc}`)).toEqual(E.left(expect.anything()));
  expect(P.LZString.decode(`!${enc}`)).toEqual(E.left(expect.anything()));
});

// test.each(json.codec.filter((d) => d.name === "null"))(
// "persist codec: $name",
// (d) => {
test.each(json.format.concat(json.exports))(
  "persist swarmheaders: $name",
  (d) => {
    const body = JSON.parse(d.body);
    const version = O.some(d.version);
    const headers = { body, version };
    expect(P.FromSwarmHeaders.decode(d.export_)).toEqual(E.right(headers));
    expect(P.FromSwarmHeaders.encode(headers)).toBe(d.export_);
    expect(
      P.FromSwarmHeaders.decode(P.FromSwarmHeaders.encode(headers))
    ).toEqual(E.right(headers));
  }
);
// test.each([json.exports[0]])("persist legacy: $name", (d) => {
test.each(json.exports)("persist legacy: $name", (d) => {
  const body = JSON.parse(d.body);
  // validates input, but makes no changes
  // typechecks
  const dec: IO.Validation<P.Legacy> = P.Legacy.decode(body);
  expect(PathReporter.report(dec)).toEqual(["No errors!"]);
  expect(dec).toEqual(E.right(body));
  expect(pipe(body, P.Legacy.decode, E.map(P.Legacy.encode))).toEqual(
    E.right(body)
  );
});
