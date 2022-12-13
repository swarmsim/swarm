import * as E from "fp-ts/lib/Either";

export function prefixKeys(prefix: string, o: any): any {
  return Object.fromEntries(
    Object.entries(o).map(([k, v]) => [`${prefix}${k}`, v])
  );
}

export function replaceKey(oldkey: string, newkey: string, o: any): any {
  if (oldkey in o) {
    o = { ...o };
    o[newkey] = o[oldkey];
    delete o[oldkey];
  }
  return o;
}

export const orThrow: <Err, V>(r: E.Either<Err, V>) => V = E.fold(
  (err) => {
    throw Error(`${err}`);
  },
  (val) => val
);
