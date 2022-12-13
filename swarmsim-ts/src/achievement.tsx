import React from "react";
import * as U from "@swarmsim/tables/src/achievement/codec";
import rowdata from "@swarmsim/tables/src/achievement/data";
import _ from "lodash";
import { propsFromType, Rows } from "./viewutil";

export function View(): JSX.Element {
  return <Rows fields={propsFromType(U.Achievement)} rows={rowdata} />;
}
export function ViewRequires(): JSX.Element {
  return (
    <Rows
      fields={propsFromType(U.NRequire)}
      rows={U.normalizeRequire(rowdata)}
    />
  );
}
export function ViewVisible(): JSX.Element {
  return (
    <Rows
      fields={propsFromType(U.NVisible)}
      rows={U.normalizeVisible(rowdata)}
    />
  );
}
