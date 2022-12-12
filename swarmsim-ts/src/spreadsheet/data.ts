import * as Un from "../unittype/codec";
import unittypes from "../unittype/data";
import * as Up from "../upgrade/codec";
import upgrades from "../upgrade/data";
import * as A from "../achievement/codec";
import achievements from "../achievement/data";
import * as M from "../mtx/codec";
import mtx from "../mtx/data";
import * as O from "./original";

export default function toSpreadsheet(sheets?: {
  unittypes?: Un.Unittype[];
  upgrades?: Up.Upgrade[];
  achievements?: A.Achievement[];
  mtx?: M.Mtx[];
}): O.Schema {
  return O.Schema.encode({
    unittypes: Un.sheet(sheets?.unittypes ?? unittypes),
    upgrades: Up.sheet(sheets?.upgrades ?? upgrades),
    achievements: A.sheet(sheets?.achievements ?? achievements),
    mtx: M.sheet(sheets?.mtx ?? mtx),
  });
}
