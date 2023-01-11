import LZ from "lz-string";
import * as IO from "io-ts";
import * as E from "fp-ts/Either";
import * as A from "fp-ts/Apply";
import * as IOT from "io-ts-types";
import * as O from "fp-ts/Option";
import { pipe } from "fp-ts/lib/function";
import { iso, Newtype } from "newtype-ts";
import * as P from "../generated/persist";
import { Timestamp } from "../generated/google/protobuf/timestamp";
import * as L from "./legacy";
import * as Unittype from "@swarmsim/tables/src/unittype";
import * as Upgrade from "@swarmsim/tables/src/upgrade";
import * as Achievement from "@swarmsim/tables/src/achievement";
import { omit } from "lodash";
import Decimal from "decimal.js";

export function fromLegacy(legacy: L.Legacy): P.Persist {
  return {
    started: fromDate(legacy.date.started),
    saved: fromDate(legacy.date.saved),
    closed: fromDate(legacy.date.closed),
    reified: fromDate(legacy.date.reified),
    restarted: fromDate(legacy.date.restarted),
    ...(legacy.date["addUnitTimed-crystal"]
      ? { crystalCooldownDoneAt: fromDate(legacy.date["addUnitTimed-crystal"]) }
      : {}),
    skippedMillis: legacy.skippedMillis,
    units: Object.fromEntries(
      Object.entries(legacy.unittypes).map(([name, value]) => [
        fromUnitName(name),
        fromDecimalString(value),
      ])
    ),
    upgrades: Object.fromEntries(
      Object.entries(legacy.upgrades).map(([name, value]) => [
        fromUpgradeName(name),
        fromDecimalString(value),
      ])
    ),
    achievements: Object.fromEntries(
      Object.entries(legacy.achievements).map(([name, value]) => [
        fromAchievementName(name),
        value,
      ])
    ),
    watched: Object.fromEntries(
      Object.entries(legacy.watched).map(([name, value]) => {
        // TODO is this how this works?
        if (typeof value === "boolean") {
          value = value ? 1 : 0;
        }
        return [fromUpgradeName(name), value];
      })
    ),
    statistics: {
      byUnit: Object.fromEntries(
        Object.entries(legacy.statistics.byUnit ?? {}).map(([name, stats]) => [
          fromUnitName(name),
          {
            ...stats,
            num: fromDecimalString(stats.num),
            twinnum: fromDecimalString(stats.twinnum),
          },
        ])
      ),
      byUpgrade: Object.fromEntries(
        Object.entries(legacy.statistics.byUpgrade ?? {}).map(
          ([name, stats]) => [
            fromUpgradeName(name),
            {
              ...stats,
              num: fromDecimalString(stats.num),
            },
          ]
        )
      ),
      ...(legacy.statistics.clicks == null
        ? {}
        : { clicks: legacy.statistics.clicks }),
    },
    options: { ...legacy.options },
    version: {
      started: legacy.version.started,
      saved: legacy.version.saved,
    },
    ...(legacy.achievementsShown
      ? { achievementsUI: { ...legacy.achievementsShown } }
      : {}),
  };
}

export function toLegacy(proto: P.Persist): L.Legacy {
  if (proto.started == null) throw new Error(".started");
  if (proto.saved == null) throw new Error(".saved");
  if (proto.reified == null) throw new Error(".reified");
  if (proto.closed == null) throw new Error(".closed");
  if (proto.restarted == null) throw new Error(".restarted");
  if (proto.version == null) throw new Error(".version");
  if (proto.statistics == null) throw new Error(".statistics");
  if (proto.statistics.byUnit == null) throw new Error(".statistics.byUnit");
  if (proto.statistics.byUpgrade == null)
    throw new Error(".statistics.byUpgrade");
  if (proto.options == null) throw new Error(".options");
  return {
    unittypes: Object.fromEntries(
      Object.entries(proto.units).map(([id, value]) => [
        toUnitName(id),
        toDecimalString(value),
      ])
    ),
    upgrades: Object.fromEntries(
      Object.entries(proto.upgrades).map(([id, value]) => [
        toUpgradeName(id),
        toDecimalString(value),
      ])
    ),
    achievements: Object.fromEntries(
      Object.entries(proto.achievements).map(([id, value]) => [
        toAchievementName(id),
        value,
      ])
    ),
    watched: Object.fromEntries(
      Object.entries(proto.watched).map(([id, value]) => [
        toUpgradeName(id),
        value,
      ])
    ),
    statistics: {
      byUnit: Object.fromEntries(
        Object.entries(proto.statistics.byUnit).map(([id, stats]) => [
          toUnitName(id),
          {
            ...stats,
            num: toDecimalString(required(stats.num, `stats[${id}].num`)),
            twinnum: toDecimalString(
              required(stats.twinnum, `stats[${id}].twinnum`)
            ),
          },
        ])
      ),
      byUpgrade: Object.fromEntries(
        Object.entries(proto.statistics.byUpgrade).map(([id, stats]) => [
          toUpgradeName(id),
          {
            ...stats,
            num: toDecimalString(required(stats.num, `stats[${id}].num`)),
          },
        ])
      ),
      clicks: proto.statistics.clicks,
    },
    version: { saved: proto.version.started, started: proto.version.saved },
    date: {
      started: toDate(proto.started),
      closed: toDate(proto.closed),
      reified: toDate(proto.reified),
      restarted: toDate(proto.restarted),
      saved: toDate(proto.saved),
      ...(proto.crystalCooldownDoneAt
        ? { "addUnitTimed-crystal": toDate(proto.crystalCooldownDoneAt) }
        : {}),
    },
    skippedMillis: proto.skippedMillis,
    options: {
      ...omit(proto.options, ["durationFormat", "notation", "velocityUnit"]),
      ...(proto.options.durationFormat
        ? // TODO decode these enums properly
          { durationFormat: proto.options.durationFormat as any }
        : {}),
      ...(proto.options.notation
        ? // TODO decode these enums properly
          { durationFormat: proto.options.notation as any }
        : {}),
      ...(proto.options.velocityUnit
        ? // TODO decode these enums properly
          { durationFormat: proto.options.velocityUnit as any }
        : {}),
    },
    ...(proto.achievementsUI
      ? {
          achievementsShown: {
            ...omit(proto.achievementsUI, ["order"]),
            // TODO decode these enums properly
            order: proto.achievementsUI.order as any,
          },
        }
      : {}),
  };
}

function toDate(ts: Timestamp): string {
  return Timestamp.toDate(ts).toISOString();
}
function fromDate(ts: string): Timestamp {
  return Timestamp.fromDate(new Date(ts));
}
function fromUnitName(name: string): number {
  const u = Unittype.byName[name];
  if (!u) throw new Error(`no such unittype-name: ${name}`);
  return u.protoId;
}
function toUnitName(id: number | string): string {
  const u = Unittype.byProtoId[id];
  if (!u) throw new Error(`no such unittype-protoId: ${id}`);
  return u.name;
}
function fromUpgradeName(name: string): number {
  const u = Upgrade.byName[name];
  if (!u) throw new Error(`no such upgrade-name: ${name}`);
  return u.protoId;
}
function toUpgradeName(id: number | string): string {
  const u = Upgrade.byProtoId[id];
  if (!u) throw new Error(`no such upgrade-protoId: ${id}`);
  return u.name;
}
function fromAchievementName(name: string): number {
  const u = Achievement.byName[name];
  if (!u) throw new Error(`no such achievement-name: ${name}`);
  return u.protoId;
}
function toAchievementName(id: number | string): string {
  const u = Achievement.byProtoId[id];
  if (!u) throw new Error(`no such achievement-protoId: ${id}`);
  return u.name;
}
function fromDecimalString(s: string): P.Decimal {
  const d = new Decimal(s);
  return {
    value:
      d.e < 30
        ? { oneofKind: "tiny", tiny: d.toNumber() }
        : d.e < 300
        ? { oneofKind: "small", small: d.toNumber() }
        : { oneofKind: "big", big: d.toString() },
  };
}
function toDecimalString(d: P.Decimal): string {
  switch (d.value.oneofKind) {
    case "tiny":
      return `${d.value.tiny}`;
    case "small":
      return `${d.value.small}`;
    case "big":
      return d.value.big;
    default:
      throw new Error("undefined decimal oneofKind");
  }
}

function required<T>(value: T | undefined, message: string): T {
  if (value === undefined) {
    throw new Error(message);
  }
  return value;
}
