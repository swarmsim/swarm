import React from "react";
import * as U from "@swarmsim/tables/src/mtx/codec";
import rowdata from "@swarmsim/tables/src/mtx/data";
import _ from "lodash";
import { propsFromType, Rows } from "./viewutil";

export function View(): JSX.Element {
  return <Rows fields={propsFromType(U.Mtx)} rows={rowdata} />;
}
