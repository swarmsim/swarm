import React from "react";
import _ from "lodash";
import * as IO from "io-ts";
import Home from "./home";

export class Field {
  constructor(public keys: (string | number)[], public prop: any) {}

  get name(): string {
    return this.keys.join(".");
  }

  value(row: any): any {
    return _.get(row, this.keys);
  }
  has(row: any): any {
    return _.has(row, this.keys);
  }

  render(row: any): JSX.Element {
    const value = this.value(row);
    if (!this.has(row)) return <small style={{ color: "grey" }}>missing</small>;
    if (value === "")
      return <small style={{ color: "grey" }}>empty string</small>;
    if (value === null) return <small style={{ color: "grey" }}>null</small>;
    if (value === undefined)
      return <small style={{ color: "grey" }}>undefined</small>;
    switch (this.prop["_tag"]) {
      case "StringType":
        return <span title={JSON.stringify(value)}>{value}</span>;
      case "NumberType":
        return <span title={JSON.stringify(value)}>{value}</span>;
      case "BooleanType":
        return <span title={JSON.stringify(value)}><input type="checkbox" readOnly={true} checked={value} /></span>;
    }
    return <div>{JSON.stringify(value)}</div>;
  }
}

export function propsFromType(t: any): Field[] {
  const fields = propsFromType_([])(t);
  // dedupe
  const seen = new Set<string>();
  return fields.filter((f) => {
    const ret = !seen.has(f.name);
    seen.add(f.name);
    return ret;
  });
}
function propsFromType_<A, O, I>(keys: string[] = []) {
  return (t: any): Field[] => {
    if ("_tag" in t) {
      switch (t._tag) {
        case "IntersectionType":
          return (t as IO.IntersectionType<any>).types
            .map(propsFromType_(keys))
            .flat();
        case "UnionType":
          return (t as IO.UnionType<any>).types
            .map(propsFromType_(keys))
            .flat();
        case "InterfaceType":
          return Object.entries((t as IO.InterfaceType<any>).props)
            .map(([k, v]) => propsFromType_(keys.concat(k))(v))
            .flat();
        case "PartialType":
          return Object.entries((t as IO.PartialType<any>).props)
            .map(([k, v]) => propsFromType_(keys.concat(k))(v))
            .flat();
      }
    }
    return [new Field(keys, t)];
  };
}

export function Rows(props: { fields: Field[]; rows: any[] }): JSX.Element {
  return (
    <Home>
      <table border={1}>
        <thead>
          <tr>
            {props.fields.map((f) => (
              <th style={{ position: "sticky", top: 0 }} key={f.name}>
                {f.name}
              </th>
            ))}
          </tr>
        </thead>
        <tbody>
          {props.rows.map((row, i) => (
            <Row key={i} fields={props.fields} row={row} />
          ))}
        </tbody>
      </table>
    </Home>
  );
}
function Row({ row, fields }: { fields: Field[]; row: any }): JSX.Element {
  return (
    <tr>
      {fields.map((f) => (
        <td key={f.name}>{f.render(row)}</td>
      ))}
    </tr>
  );
}
