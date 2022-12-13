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
    "/achievement",
    "/achievement/requires",
    "/achievement/visible",
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
      <EmbedResize />
      <a href="/#/test" target="_parent">
        test parent link
      </a>
    </div>
  );
}

const qsOnLoad = new URLSearchParams(window.document.location.search);
function getParentIframe(): HTMLElement | null {
  if (window.self === window.parent) return null;
  const embed = qsOnLoad.get("embed");
  return embed ? window.parent.document.getElementById(embed) : null;
}

function EmbedResize() {
  React.useEffect(() => {
    const iframe = getParentIframe();
    if (iframe) {
      // TODO not sure why the extra is necessary
      const width = window.document.body.scrollWidth + 20;
      const height = window.document.body.scrollHeight + 50;

      console.log("embed-resize", { width, height, iframe });
      iframe.style.minWidth = `${width}px`;
      iframe.style.minHeight = `${height}px`;
    }
  });
  return <></>;
}
