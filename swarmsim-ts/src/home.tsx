import React from "react";
import { Link } from "react-router-dom";

export default function Home(props: {
  children?: React.ReactNode;
}): JSX.Element {
  const hrefs = [
    "/unittype",
    "/unittype/effect",
    "/unittype/requires",
    "/unittype/cost",
    "/unittype/prod",
    "/upgrade",
    "/upgrade/effect",
    "/upgrade/requires",
    "/upgrade/cost",
    "/achievements",
    "/mtx",
  ];
  return (
    <div>
      <ul>
        {hrefs.map((href) => (
          <li key={href}>
            <Link to={href}>{href}</Link>
          </li>
        ))}
      </ul>
      {props.children || []}
    </div>
  );
}
