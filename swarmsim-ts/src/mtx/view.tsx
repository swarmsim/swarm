import React from "react";
import * as U from "./codec";
import rowdata from "./data";
import _ from "lodash";
import { propsFromType, Rows } from "../viewutil";

export function View(): JSX.Element {
  return <Rows fields={propsFromType(U.Mtx)} rows={rowdata} />;
}
