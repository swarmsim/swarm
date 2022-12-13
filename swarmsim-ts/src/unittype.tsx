import React from "react";
import * as U from "@swarmsim/tables/src/unittype/codec";
import rowdata from "@swarmsim/tables/src/unittype/data";
import _ from "lodash";
import { propsFromType, Rows } from "./viewutil";

export function View(): JSX.Element {
  return <Rows fields={propsFromType(U.Unittype)} rows={rowdata} />;
}
export function ViewEffect(): JSX.Element {
  return (
    <Rows fields={propsFromType(U.NEffect)} rows={U.normalizeEffect(rowdata)} />
  );
}
export function ViewRequires(): JSX.Element {
  return (
    <Rows
      fields={propsFromType(U.NRequire)}
      rows={U.normalizeRequire(rowdata)}
    />
  );
}
export function ViewCost(): JSX.Element {
  return (
    <Rows fields={propsFromType(U.NCost)} rows={U.normalizeCost(rowdata)} />
  );
}
export function ViewProd(): JSX.Element {
  return (
    <Rows fields={propsFromType(U.NProd)} rows={U.normalizeProd(rowdata)} />
  );
}
