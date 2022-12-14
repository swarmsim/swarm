// based on:
// https://gitlab.com/erosson/swarm-elm/-/blob/master/packages/www/src/persist.js
// https://github.com/swarmsim/swarm/blob/6c6b73889d253e5382cbcf2bdd6270b171a4484e/app/scripts/services/session.coffee#L53
// https://github.com/swarmsim/swarm/blob/6c6b73889d253e5382cbcf2bdd6270b171a4484e/app/scripts/services/session.coffee#L110
import LZ from "lz-string";
import * as IO from "io-ts";
import * as E from "fp-ts/Either";
import * as A from "fp-ts/Apply";
import * as IOT from "io-ts-types";
import * as O from "fp-ts/Option";
import { pipe } from "fp-ts/lib/function";
import { iso, Newtype } from "newtype-ts";

export interface Base64
  extends Newtype<{ readonly Base64: unique symbol }, string> {}
const _Base64 = iso<Base64>();

export const Base64: IO.Type<string, Base64> = new IO.Type(
  "Base64",
  IO.string.is,
  (input, c) => {
    return pipe(
      IO.string.validate(input, c),
      // _Base64.unwrap
      E.map((o) => Buffer.from(o, "base64").toString("utf8")),
      // Buffer ignores invalid characters or bogus encoding, instead of
      // throwing an error, so detect errors by comparing to the original
      E.chain((o) =>
        Base64.encode(o) !== input
          ? IO.failure("Invalid base64 encoding", c)
          : IO.success(o)
      )
    );
  },
  (output: string): Base64 =>
    _Base64.wrap(Buffer.from(output, "utf8").toString("base64"))
);

export const LZString = IO.string.pipe(
  new IO.Type(
    "LZString",
    IO.string.is,
    (input: string, c) => {
      const ret = LZ.decompressFromBase64(input);
      // decompress returns "" on error. But "" is valid output too, since we
      // can compress ""! Special-case that one.
      return ret === null || (ret === "" && input !== "Q===")
        ? IO.failure("Invalid lz-string encoding", c)
        : IO.success(ret);
    },
    LZ.compressToBase64
  )
);

const encPrefix: Base64 = Base64.encode("Cheater :(\n\n");
const versionDelim = "|";

const SwarmBody = LZString.pipe(IOT.JsonFromString, "SwarmBody");

export const SwarmHeaders = IO.type({
  version: IOT.optionFromNullable(IO.string),
  body: IOT.Json,
});
export type SwarmHeaders = IO.TypeOf<typeof SwarmHeaders>;
export const FromSwarmHeaders = IO.string.pipe(
  new IO.Type(
    "SwarmHeaders",
    SwarmHeaders.is,
    (enc: string, c) => {
      // ignore whitespace
      enc = enc.replace(/\s+/g, "");
      // try to parse the version prefix. Some very old savestates might not have one.
      let encBody: string, version: IO.Validation<O.Option<string>>;
      if (enc.indexOf(versionDelim) >= 0) {
        const split = enc.split(versionDelim);
        version = pipe(split[0], (s) => Base64.validate(s, c), E.map(O.some));
        encBody = split[1];
      } else {
        encBody = enc;
        version = E.right(O.none);
      }
      if (!encBody.startsWith(_Base64.unwrap(encPrefix))) {
        return IO.failure("body prefix missing", c);
      }
      const body = SwarmBody.validate(
        encBody.slice(_Base64.unwrap(encPrefix).length),
        c
      );
      return A.sequenceS(E.Apply)({ version, body });
    },
    (dec: SwarmHeaders): string =>
      O.fold(
        () => [],
        (v: string) => [Base64.encode(v), versionDelim]
      )(dec.version)
        .concat([encPrefix, SwarmBody.encode(dec.body)])
        .join("")
  )
);

const DecimalString = IO.string;
const DateISO = IO.string;
const ElapsedMs = IO.number;
function typeAndPartial<T extends IO.Props, P extends IO.Props>(
  required: T,
  optional: P,
  name?: string
): IO.IntersectionC<[IO.TypeC<T>, IO.PartialC<P>]> {
  return IO.intersection([IO.type(required), IO.partial(optional)], name);
}
// https://gitlab.com/erosson/swarm-elm/-/blob/master/packages/www/src/Game.elm#L1154
export const Legacy = typeAndPartial(
  {
    date: typeAndPartial(
      {
        started: DateISO,
        reified: DateISO,
        restarted: DateISO,
        saved: DateISO,
        closed: DateISO,
      },
      {
        loaded: DateISO,
        // cooldowns. this is the ony one we ever used, isn't it?
        // set to `now` when buying a hatchery/expansion
        "addUnitTimed-crystal": DateISO,
      }
    ),
    unittypes: IO.record(IO.string, DecimalString),
    options: IO.partial({
      isCustomTheme: IO.boolean,
      theme: IO.string,
      showAdvancedUnitData: IO.boolean,
      notation: IO.union([
        IO.literal("standard-decimal"),
        IO.literal("scientific-e"),
        IO.literal("hybrid"),
        IO.literal("engineering"),
      ]),
      velocityUnit: IO.union([
        IO.literal("sec"),
        IO.literal("min"),
        IO.literal("hr"),
        IO.literal("day"),
        IO.literal("warp"),
      ]),
      durationFormat: IO.union([
        IO.literal("abbreviated"), // "exact"
        IO.literal("human"), // "approximate"
        IO.literal("full"), // no longer used
      ]),
      fpsAuto: IO.boolean,
      fps: IO.number,
    }),
    upgrades: IO.record(IO.string, DecimalString),
    statistics: IO.partial({
      byUnit: IO.record(
        IO.string,
        IO.type({
          clicks: IO.number,
          num: DecimalString,
          twinnum: DecimalString,
          elapsedFirst: ElapsedMs,
        })
      ),
      byUpgrade: IO.record(
        IO.string,
        IO.type({
          clicks: IO.number,
          num: DecimalString,
          elapsedFirst: ElapsedMs,
        })
      ),
      clicks: IO.number,
    }),
    achievements: IO.record(IO.string, ElapsedMs),
    watched: IO.record(IO.string, IO.union([IO.boolean, IO.number])),
    skippedMillis: IO.number,
    version: IO.type({ started: IO.string, saved: IO.string }),
  },
  {
    achievementsShown: IO.type({
      earned: IO.boolean,
      unearned: IO.boolean,
      masked: IO.boolean,
      order: IO.union([IO.literal("default"), IO.literal("percentComplete")]),
      reverse: IO.boolean,
    }),
    // I'm pretty sure this is only true or missing, never false - but not completely sure
    kongregate: IO.boolean,
    mtx: IO.partial({
      playfab: IO.type({ items: IO.record(IO.string, IO.literal(true)) }),
      kongregate: IO.record(IO.string, IO.literal(true)),
    }),
  }
);
export type Legacy = IO.TypeOf<typeof Legacy>;
