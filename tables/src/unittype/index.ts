import * as _Codec from "./codec";
import _Data from "./data";

export const Codec = _Codec;
export const list = _Data;
export const byName = Object.fromEntries(list.map((u) => [u.name, u]));
export const byProtoId = Object.fromEntries(list.map((u) => [u.protoId, u]));
