import * as C from "./codec";

const meat: C.Unittype = {
  name: "meat",
  init: 35,
  column: 0,
  tab: "meat",
  tier: 0,
  unbuyable: true,
  requires: [{ unittype: "meat", val: 0 }],
  l: {
    description: "Meat is delicious. All of your swarm's creatures eat meat.",
    label: "meat",
    lol: "Some kingdoms use meat to craft paste or cars. Meat, meat, it can't be beat~",
    plural: "meat",
    verb: "gather",
    verbing: "gathering",
    verbone: "gathers",
  },
};
const drone: C.Unittype = {
  name: "drone",
  column: 1,
  cost: [
    { unittype: "meat", val: 10 },
    { unittype: "larva", val: 1 },
  ],
  prod: [{ unittype: "meat", val: 1 }],
  requires: [{ unittype: "meat", val: 0 }],
  tab: "meat",
  tier: 1,
  l: {
    description:
      "Drones are the lowest class of worker in your swarm. They continuously gather meat to feed your swarm.",
    label: "drone",
    lol: "Not to be confused with probes or mules.",
    plural: "drones",
    verb: "hatch",
    verbing: "hatching",
    verbone: "hatches",
  },
};

const list: C.Unittype[] = [meat, drone];
export default list;
