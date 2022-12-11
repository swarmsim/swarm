import React from "react";
import * as U from "./codec";
import rowdata from "./data";
import _ from "lodash";
import { propsFromType, Rows } from "../viewutil";

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
      fields={propsFromType(U.Visible)}
      rows={U.normalizeVisible(rowdata)}
    />
  );
}
