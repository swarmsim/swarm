import React from "react";
import ReactDOM from "react-dom/client";
import * as Router from "react-router-dom";
import * as Unittype from "./unittype/view";
import * as Upgrade from "./upgrade/view";
import Home from "./home";

const rootEl = document.getElementById("root");
if (!rootEl) throw new Error("no root element");
const root = ReactDOM.createRoot(rootEl);
const router = Router.createBrowserRouter([
  { path: "/", element: <Home />, errorElement: <div>oops</div> },
  { path: "/unittype", element: <Unittype.View /> },
  { path: "/unittype/effect", element: <Unittype.ViewEffect /> },
  { path: "/unittype/requires", element: <Unittype.ViewRequires /> },
  { path: "/unittype/cost", element: <Unittype.ViewCost /> },
  { path: "/unittype/prod", element: <Unittype.ViewProd /> },
  { path: "/upgrade", element: <Upgrade.View /> },
  { path: "/upgrade/effect", element: <Upgrade.ViewEffect /> },
  { path: "/upgrade/requires", element: <Upgrade.ViewRequires /> },
  { path: "/upgrade/cost", element: <Upgrade.ViewCost /> },
]);
root.render(
  <React.StrictMode>
    <Router.RouterProvider router={router} />
  </React.StrictMode>
);
