import * as IO from "io-ts";
import * as S from "../spreadsheet/original";
import * as E from "fp-ts/lib/Either";
import { pipe } from "fp-ts/lib/function";

export const Mtx = S.Mtx;
export type Mtx = IO.TypeOf<typeof Mtx>;
export const FromSpreadsheet = S.Mtx;

export function sheetByName(
  sheet: S.Sheet<{ name: string }>
): E.Either<IO.Errors, { [s: string]: S.Mtx }> {
  return pipe(
    sheet,
    S.Sheet(S.Mtx).decode,
    E.map((s) => s.elements.map((d) => [d.name, d])),
    E.map(Object.fromEntries)
  );
}
