import * as C from "./codec";

const list: C.Achievement[] = [
  {
    "name": "tutorial",
    "protoId": 1,
    "l": {
      "description": "Finish the tutorial",
      "label": "tutorial complete",
      "longdesc": ""
    },
    "points": 50,
    "requires": [
      {
        "upgradetype": "expansion",
        "val": 5
      }
    ],
    "visible": [
      {
        "unittype": "meat",
        "val": 0
      }
    ]
  },
  {
    "name": "expansion1",
    "protoId": 2,
    "l": {
      "description": "Create your first expansion",
      "label": "two base play",
      "longdesc": ""
    },
    "points": 10,
    "requires": [
      {
        "upgradetype": "expansion",
        "val": 1
      }
    ],
    "visible": [
      {
        "unittype": "territory",
        "val": 1
      }
    ]
  },
  {
    "name": "expansion2",
    "protoId": 3,
    "l": {
      "description": "Have $REQUIRED expansions at once",
      "label": "vast expanse",
      "longdesc": ""
    },
    "points": 20,
    "requires": [
      {
        "upgradetype": "expansion",
        "val": 20
      }
    ],
    "visible": [
      {
        "upgradetype": "expansion",
        "val": 1
      }
    ]
  },
  {
    "name": "expansion3",
    "protoId": 4,
    "l": {
      "description": "Have $REQUIRED expansions at once",
      "label": "infestation",
      "longdesc": ""
    },
    "points": 30,
    "requires": [
      {
        "upgradetype": "expansion",
        "val": 50
      }
    ],
    "visible": [
      {
        "upgradetype": "expansion",
        "val": 5
      }
    ]
  },
  {
    "name": "expansion4",
    "protoId": 5,
    "l": {
      "description": "Have $REQUIRED expansions at once",
      "label": "creepy",
      "longdesc": ""
    },
    "points": 40,
    "requires": [
      {
        "upgradetype": "expansion",
        "val": 100
      }
    ],
    "visible": [
      {
        "upgradetype": "expansion",
        "val": 20
      }
    ]
  },
  {
    "name": "expansion5",
    "protoId": 6,
    "l": {
      "description": "Have $REQUIRED expansions at once",
      "label": "no vacancy",
      "longdesc": ""
    },
    "points": 50,
    "requires": [
      {
        "upgradetype": "expansion",
        "val": 200
      }
    ],
    "visible": [
      {
        "upgradetype": "expansion",
        "val": 50
      }
    ]
  },
  {
    "name": "expansion6",
    "protoId": 7,
    "l": {
      "description": "Have $REQUIRED expansions at once",
      "label": "diminishing returns",
      "longdesc": ""
    },
    "points": 60,
    "requires": [
      {
        "upgradetype": "expansion",
        "val": 500
      }
    ],
    "visible": [
      {
        "upgradetype": "expansion",
        "val": 100
      }
    ]
  },
  {
    "name": "expansion7",
    "protoId": 8,
    "l": {
      "description": "Have $REQUIRED expansions at once",
      "label": "we have become as a vapor",
      "longdesc": ""
    },
    "points": 70,
    "requires": [
      {
        "upgradetype": "expansion",
        "val": 1000
      }
    ],
    "visible": [
      {
        "upgradetype": "expansion",
        "val": 200
      }
    ]
  },
  {
    "name": "expansion8",
    "protoId": 9,
    "l": {
      "description": "Have $REQUIRED expansions at once",
      "label": "imperialus conceptus",
      "longdesc": ""
    },
    "points": 80,
    "requires": [
      {
        "upgradetype": "expansion",
        "val": 2000
      }
    ],
    "visible": [
      {
        "upgradetype": "expansion",
        "val": 500
      }
    ]
  },
  {
    "name": "expansion9",
    "protoId": 10,
    "l": {
      "description": "Have $REQUIRED expansions at once",
      "label": "manifest destiny",
      "longdesc": ""
    },
    "points": 90,
    "requires": [
      {
        "upgradetype": "expansion",
        "val": 5000
      }
    ],
    "visible": [
      {
        "upgradetype": "expansion",
        "val": 1000
      }
    ]
  },
  {
    "name": "drone1",
    "protoId": 11,
    "l": {
      "description": "Hatch your first drone",
      "label": "a good start",
      "longdesc": ""
    },
    "points": 10,
    "requires": [
      {
        "unittype": "drone",
        "val": 1
      }
    ],
    "visible": [
      {
        "unittype": "meat",
        "val": 0
      }
    ]
  },
  {
    "name": "drone2",
    "protoId": 12,
    "l": {
      "description": "Hatch $REQUIRED drones",
      "label": "supply limit exceeded",
      "longdesc": "Drones hatched by queens don't count."
    },
    "points": 20,
    "requires": [
      {
        "unittype": "drone",
        "val": 201
      }
    ],
    "visible": [
      {
        "unittype": "meat",
        "val": 0
      }
    ]
  },
  {
    "name": "drone3",
    "protoId": 13,
    "l": {
      "description": "Hatch $REQUIRED drones",
      "label": "\"exponential\" growth",
      "longdesc": "Drones hatched by queens don't count."
    },
    "points": 30,
    "requires": [
      {
        "unittype": "drone",
        "val": 10000
      }
    ],
    "visible": [
      {
        "unittype": "meat",
        "val": 0
      }
    ]
  },
  {
    "name": "queen1",
    "protoId": 14,
    "l": {
      "description": "Hatch your first queen",
      "label": "queen me",
      "longdesc": ""
    },
    "points": 10,
    "requires": [
      {
        "unittype": "queen",
        "val": 1
      }
    ],
    "visible": [
      {
        "unittype": "meat",
        "val": 0
      }
    ]
  },
  {
    "name": "queen2",
    "protoId": 15,
    "l": {
      "description": "Hatch $REQUIRED queens",
      "label": "is this the real life?",
      "longdesc": "Queens hatched by nests don't count."
    },
    "points": 20,
    "requires": [
      {
        "unittype": "queen",
        "val": 1000
      }
    ],
    "visible": [
      {
        "unittype": "meat",
        "val": 0
      }
    ]
  },
  {
    "name": "queen3",
    "protoId": 16,
    "l": {
      "description": "Hatch $REQUIRED queens",
      "label": "don't stop me now",
      "longdesc": "Queens hatched by nests don't count."
    },
    "points": 30,
    "requires": [
      {
        "unittype": "queen",
        "val": 1000000
      }
    ],
    "visible": [
      {
        "unittype": "meat",
        "val": 0
      }
    ]
  },
  {
    "name": "nest1",
    "protoId": 17,
    "l": {
      "description": "Build your first nest",
      "label": "I wanna be the very nest",
      "longdesc": ""
    },
    "points": 10,
    "requires": [
      {
        "unittype": "nest",
        "val": 1
      }
    ],
    "visible": [
      {
        "unittype": "queen",
        "val": 5
      }
    ]
  },
  {
    "name": "nest2",
    "protoId": 18,
    "l": {
      "description": "Build $REQUIRED nests",
      "label": "to hatch them is my real test",
      "longdesc": ""
    },
    "points": 20,
    "requires": [
      {
        "unittype": "nest",
        "val": 10000
      }
    ],
    "visible": [
      {
        "unittype": "nest",
        "val": 1
      }
    ]
  },
  {
    "name": "nest3",
    "protoId": 19,
    "l": {
      "description": "Build $REQUIRED nests",
      "label": "final nesting place",
      "longdesc": ""
    },
    "points": 30,
    "requires": [
      {
        "unittype": "nest",
        "val": 100000000
      }
    ],
    "visible": [
      {
        "unittype": "nest",
        "val": 1
      }
    ]
  },
  {
    "name": "greaterqueen1",
    "protoId": 20,
    "l": {
      "description": "Hatch your first greater queen",
      "label": "some are born great",
      "longdesc": ""
    },
    "points": 10,
    "requires": [
      {
        "unittype": "greaterqueen",
        "val": 1
      }
    ],
    "visible": [
      {
        "unittype": "nest",
        "val": 5
      }
    ]
  },
  {
    "name": "greaterqueen2",
    "protoId": 21,
    "l": {
      "description": "Hatch $REQUIRED greater queens",
      "label": "catherine",
      "longdesc": ""
    },
    "points": 20,
    "requires": [
      {
        "unittype": "greaterqueen",
        "val": 100000
      }
    ],
    "visible": [
      {
        "unittype": "greaterqueen",
        "val": 1
      }
    ]
  },
  {
    "name": "greaterqueen3",
    "protoId": 22,
    "l": {
      "description": "Hatch $REQUIRED greater queens",
      "label": "greater and greater",
      "longdesc": ""
    },
    "points": 30,
    "requires": [
      {
        "unittype": "greaterqueen",
        "val": 10000000000
      }
    ],
    "visible": [
      {
        "unittype": "greaterqueen",
        "val": 1
      }
    ]
  },
  {
    "name": "hive1",
    "protoId": 23,
    "l": {
      "description": "Build your first hive",
      "label": "we'll do it hive",
      "longdesc": ""
    },
    "points": 10,
    "requires": [
      {
        "unittype": "hive",
        "val": 1
      }
    ],
    "visible": [
      {
        "unittype": "greaterqueen",
        "val": 5
      }
    ]
  },
  {
    "name": "hive2",
    "protoId": 24,
    "l": {
      "description": "Build $REQUIRED hives",
      "label": "breaking out",
      "longdesc": ""
    },
    "points": 20,
    "requires": [
      {
        "unittype": "hive",
        "val": 1000000
      }
    ],
    "visible": [
      {
        "unittype": "hive",
        "val": 1
      }
    ]
  },
  {
    "name": "hive3",
    "protoId": 25,
    "l": {
      "description": "Build $REQUIRED hives",
      "label": "hive mind",
      "longdesc": ""
    },
    "points": 30,
    "requires": [
      {
        "unittype": "hive",
        "val": 1000000000000
      }
    ],
    "visible": [
      {
        "unittype": "hive",
        "val": 1
      }
    ]
  },
  {
    "name": "hivequeen1",
    "protoId": 26,
    "l": {
      "description": "Hatch your first hive queen",
      "label": "too many kinds of queens",
      "longdesc": ""
    },
    "points": 10,
    "requires": [
      {
        "unittype": "hivequeen",
        "val": 1
      }
    ],
    "visible": [
      {
        "unittype": "hive",
        "val": 5
      }
    ]
  },
  {
    "name": "hivequeen2",
    "protoId": 27,
    "l": {
      "description": "Hatch $REQUIRED hive queens",
      "label": "or just too many queens",
      "longdesc": ""
    },
    "points": 20,
    "requires": [
      {
        "unittype": "hivequeen",
        "val": 10000000
      }
    ],
    "visible": [
      {
        "unittype": "hivequeen",
        "val": 1
      }
    ]
  },
  {
    "name": "hivequeen3",
    "protoId": 28,
    "l": {
      "description": "Hatch $REQUIRED hive queens",
      "label": "no more queens, honest",
      "longdesc": ""
    },
    "points": 30,
    "requires": [
      {
        "unittype": "hivequeen",
        "val": 100000000000000
      }
    ],
    "visible": [
      {
        "unittype": "hivequeen",
        "val": 1
      }
    ]
  },
  {
    "name": "empress1",
    "protoId": 29,
    "l": {
      "description": "Grow your first hive empress",
      "label": "queen of queens",
      "longdesc": ""
    },
    "points": 10,
    "requires": [
      {
        "unittype": "empress",
        "val": 1
      }
    ],
    "visible": [
      {
        "unittype": "hivequeen",
        "val": 5
      }
    ]
  },
  {
    "name": "empress2",
    "protoId": 30,
    "l": {
      "description": "Grow $REQUIRED hive empresses",
      "label": "wu zetian",
      "longdesc": ""
    },
    "points": 20,
    "requires": [
      {
        "unittype": "empress",
        "val": 100000000
      }
    ],
    "visible": [
      {
        "unittype": "empress",
        "val": 1
      }
    ]
  },
  {
    "name": "empress3",
    "protoId": 31,
    "l": {
      "description": "Grow $REQUIRED hive empresses",
      "label": "matriarchy",
      "longdesc": ""
    },
    "points": 30,
    "requires": [
      {
        "unittype": "empress",
        "val": 10000000000000000
      }
    ],
    "visible": [
      {
        "unittype": "empress",
        "val": 1
      }
    ]
  },
  {
    "name": "prophet1",
    "protoId": 32,
    "l": {
      "description": "Grow your first neuroprophet",
      "label": "1. collect larvae",
      "longdesc": ""
    },
    "points": 10,
    "requires": [
      {
        "unittype": "prophet",
        "val": 1
      }
    ],
    "visible": [
      {
        "unittype": "empress",
        "val": 5
      }
    ]
  },
  {
    "name": "prophet2",
    "protoId": 33,
    "l": {
      "description": "Grow $REQUIRED neuroprophets",
      "label": "2. ?",
      "longdesc": ""
    },
    "points": 20,
    "requires": [
      {
        "unittype": "prophet",
        "val": 1000000000
      }
    ],
    "visible": [
      {
        "unittype": "prophet",
        "val": 1
      }
    ]
  },
  {
    "name": "prophet3",
    "protoId": 34,
    "l": {
      "description": "Grow $REQUIRED neuroprophets",
      "label": "3. prophet",
      "longdesc": ""
    },
    "points": 30,
    "requires": [
      {
        "unittype": "prophet",
        "val": 1000000000000000000
      }
    ],
    "visible": [
      {
        "unittype": "prophet",
        "val": 1
      }
    ]
  },
  {
    "name": "goddess1",
    "protoId": 35,
    "l": {
      "description": "Grow your first hive neuron",
      "label": "neurogenesis",
      "longdesc": ""
    },
    "points": 10,
    "requires": [
      {
        "unittype": "goddess",
        "val": 1
      }
    ],
    "visible": [
      {
        "unittype": "prophet",
        "val": 5
      }
    ]
  },
  {
    "name": "goddess2",
    "protoId": 36,
    "l": {
      "description": "Grow $REQUIRED hive neurons",
      "label": "new neurons",
      "longdesc": ""
    },
    "points": 20,
    "requires": [
      {
        "unittype": "goddess",
        "val": 10000000000
      }
    ],
    "visible": [
      {
        "unittype": "goddess",
        "val": 1
      }
    ]
  },
  {
    "name": "goddess3",
    "protoId": 37,
    "l": {
      "description": "Grow $REQUIRED hive neurons",
      "label": "neuronerd",
      "longdesc": ""
    },
    "points": 30,
    "requires": [
      {
        "unittype": "goddess",
        "val": 100000000000000000000
      }
    ],
    "visible": [
      {
        "unittype": "goddess",
        "val": 1
      }
    ]
  },
  {
    "name": "pantheon1",
    "protoId": 38,
    "l": {
      "description": "Grow your first neural cluster",
      "label": "nucleus",
      "longdesc": ""
    },
    "points": 10,
    "requires": [
      {
        "unittype": "pantheon",
        "val": 1
      }
    ],
    "visible": [
      {
        "unittype": "goddess",
        "val": 5
      }
    ]
  },
  {
    "name": "pantheon2",
    "protoId": 39,
    "l": {
      "description": "Grow $REQUIRED neural clusters",
      "label": "ganglion",
      "longdesc": ""
    },
    "points": 20,
    "requires": [
      {
        "unittype": "pantheon",
        "val": 100000000000
      }
    ],
    "visible": [
      {
        "unittype": "pantheon",
        "val": 1
      }
    ]
  },
  {
    "name": "pantheon3",
    "protoId": 40,
    "l": {
      "description": "Grow $REQUIRED neural clusters",
      "label": "cluster-something",
      "longdesc": ""
    },
    "points": 30,
    "requires": [
      {
        "unittype": "pantheon",
        "val": 1e+22
      }
    ],
    "visible": [
      {
        "unittype": "pantheon",
        "val": 1
      }
    ]
  },
  {
    "name": "pantheon21",
    "protoId": 41,
    "l": {
      "description": "Grow your first hive network",
      "label": "arpanet",
      "longdesc": ""
    },
    "points": 10,
    "requires": [
      {
        "unittype": "pantheon2",
        "val": 1
      }
    ],
    "visible": [
      {
        "unittype": "pantheon",
        "val": 5
      }
    ]
  },
  {
    "name": "pantheon22",
    "protoId": 42,
    "l": {
      "description": "Grow $REQUIRED hive networks",
      "label": "backpropagation",
      "longdesc": ""
    },
    "points": 20,
    "requires": [
      {
        "unittype": "pantheon2",
        "val": 1000000000000
      }
    ],
    "visible": [
      {
        "unittype": "pantheon2",
        "val": 1
      }
    ]
  },
  {
    "name": "pantheon23",
    "protoId": 43,
    "l": {
      "description": "Grow $REQUIRED hive networks",
      "label": "nydus",
      "longdesc": ""
    },
    "points": 30,
    "requires": [
      {
        "unittype": "pantheon2",
        "val": 1e+24
      }
    ],
    "visible": [
      {
        "unittype": "pantheon2",
        "val": 1
      }
    ]
  },
  {
    "name": "pantheon31",
    "protoId": 44,
    "l": {
      "description": "Grow your first lesser hive mind",
      "label": "do you mind?",
      "longdesc": ""
    },
    "points": 10,
    "requires": [
      {
        "unittype": "pantheon3",
        "val": 1
      }
    ],
    "visible": [
      {
        "unittype": "pantheon2",
        "val": 5
      }
    ]
  },
  {
    "name": "pantheon32",
    "protoId": 45,
    "l": {
      "description": "Grow $REQUIRED lesser hive minds",
      "label": "lesser is morer",
      "longdesc": ""
    },
    "points": 20,
    "requires": [
      {
        "unittype": "pantheon3",
        "val": 10000000000000
      }
    ],
    "visible": [
      {
        "unittype": "pantheon3",
        "val": 1
      }
    ]
  },
  {
    "name": "pantheon33",
    "protoId": 46,
    "l": {
      "description": "Grow $REQUIRED lesser hive minds",
      "label": "lord have mercy",
      "longdesc": ""
    },
    "points": 30,
    "requires": [
      {
        "unittype": "pantheon3",
        "val": 1e+26
      }
    ],
    "visible": [
      {
        "unittype": "pantheon3",
        "val": 1
      }
    ]
  },
  {
    "name": "pantheon41",
    "protoId": 47,
    "l": {
      "description": "Grow your first hive mind",
      "label": "one of us",
      "longdesc": ""
    },
    "points": 10,
    "requires": [
      {
        "unittype": "pantheon4",
        "val": 1
      }
    ],
    "visible": [
      {
        "unittype": "pantheon3",
        "val": 5
      }
    ]
  },
  {
    "name": "pantheon42",
    "protoId": 48,
    "l": {
      "description": "Grow $REQUIRED hive minds",
      "label": "groupthink",
      "longdesc": ""
    },
    "points": 20,
    "requires": [
      {
        "unittype": "pantheon4",
        "val": 100000000000000
      }
    ],
    "visible": [
      {
        "unittype": "pantheon4",
        "val": 1
      }
    ]
  },
  {
    "name": "pantheon43",
    "protoId": 49,
    "l": {
      "description": "Grow $REQUIRED hive minds",
      "label": "swarm intelligence",
      "longdesc": ""
    },
    "points": 30,
    "requires": [
      {
        "unittype": "pantheon4",
        "val": 1e+28
      }
    ],
    "visible": [
      {
        "unittype": "pantheon4",
        "val": 1
      }
    ]
  },
  {
    "name": "pantheon51",
    "protoId": 50,
    "l": {
      "description": "Grow your first arch-mind",
      "label": "ante meridiem",
      "longdesc": ""
    },
    "points": 10,
    "requires": [
      {
        "unittype": "pantheon5",
        "val": 1
      }
    ],
    "visible": [
      {
        "unittype": "pantheon4",
        "val": 5
      }
    ]
  },
  {
    "name": "pantheon52",
    "protoId": 51,
    "l": {
      "description": "Grow $REQUIRED arch-minds",
      "label": "archery",
      "longdesc": ""
    },
    "points": 20,
    "requires": [
      {
        "unittype": "pantheon5",
        "val": 1000000000000000
      }
    ],
    "visible": [
      {
        "unittype": "pantheon5",
        "val": 1
      }
    ]
  },
  {
    "name": "pantheon53",
    "protoId": 52,
    "l": {
      "description": "Grow $REQUIRED arch-minds",
      "label": "cerebration time",
      "longdesc": ""
    },
    "points": 30,
    "requires": [
      {
        "unittype": "pantheon5",
        "val": 1e+30
      }
    ],
    "visible": [
      {
        "unittype": "pantheon5",
        "val": 1
      }
    ]
  },
  {
    "name": "overmind1",
    "protoId": 53,
    "l": {
      "description": "Grow your first overmind",
      "label": "awaken, my child",
      "longdesc": ""
    },
    "points": 10,
    "requires": [
      {
        "unittype": "overmind",
        "val": 1
      }
    ],
    "visible": [
      {
        "unittype": "pantheon5",
        "val": 5
      }
    ]
  },
  {
    "name": "overmind2",
    "protoId": 54,
    "l": {
      "description": "Grow $REQUIRED overminds",
      "label": "how ya like my groove?",
      "longdesc": ""
    },
    "points": 20,
    "requires": [
      {
        "unittype": "overmind",
        "val": 10000000000000000
      }
    ],
    "visible": [
      {
        "unittype": "overmind",
        "val": 1
      }
    ]
  },
  {
    "name": "overmind3",
    "protoId": 55,
    "l": {
      "description": "Grow $REQUIRED overminds",
      "label": "well done!",
      "longdesc": ""
    },
    "points": 30,
    "requires": [
      {
        "unittype": "overmind",
        "val": 1e+32
      }
    ],
    "visible": [
      {
        "unittype": "overmind",
        "val": 1
      }
    ]
  },
  {
    "name": "overmind2_1",
    "protoId": 56,
    "l": {
      "description": "Grow your first overmind II",
      "label": "transcendent thought",
      "longdesc": ""
    },
    "points": 10,
    "requires": [
      {
        "unittype": "overmind2",
        "val": 1
      }
    ],
    "visible": [
      {
        "unittype": "overmind",
        "val": 5
      }
    ]
  },
  {
    "name": "overmind2_2",
    "protoId": 57,
    "l": {
      "description": "Grow $REQUIRED overmind IIs",
      "label": "transcendent thought",
      "longdesc": ""
    },
    "points": 20,
    "requires": [
      {
        "unittype": "overmind2",
        "val": 10000000000000000000
      }
    ],
    "visible": [
      {
        "unittype": "overmind2",
        "val": 1
      }
    ]
  },
  {
    "name": "overmind2_3",
    "protoId": 58,
    "l": {
      "description": "Grow $REQUIRED overmind IIs",
      "label": "transcendent thought",
      "longdesc": ""
    },
    "points": 30,
    "requires": [
      {
        "unittype": "overmind2",
        "val": 1e+38
      }
    ],
    "visible": [
      {
        "unittype": "overmind2",
        "val": 1
      }
    ]
  },
  {
    "name": "overmind3_1",
    "protoId": 59,
    "l": {
      "description": "Grow your first overmind III",
      "label": "transcendent thought",
      "longdesc": ""
    },
    "points": 10,
    "requires": [
      {
        "unittype": "overmind3",
        "val": 1
      }
    ],
    "visible": [
      {
        "unittype": "overmind2",
        "val": 5
      }
    ]
  },
  {
    "name": "overmind3_2",
    "protoId": 60,
    "l": {
      "description": "Grow $REQUIRED overmind IIIs",
      "label": "transcendent thought",
      "longdesc": ""
    },
    "points": 20,
    "requires": [
      {
        "unittype": "overmind3",
        "val": 1e+22
      }
    ],
    "visible": [
      {
        "unittype": "overmind3",
        "val": 1
      }
    ]
  },
  {
    "name": "overmind3_3",
    "protoId": 61,
    "l": {
      "description": "Grow $REQUIRED overmind IIIs",
      "label": "transcendent thought",
      "longdesc": ""
    },
    "points": 30,
    "requires": [
      {
        "unittype": "overmind3",
        "val": 1e+44
      }
    ],
    "visible": [
      {
        "unittype": "overmind3",
        "val": 1
      }
    ]
  },
  {
    "name": "overmind4_1",
    "protoId": 62,
    "l": {
      "description": "Grow your first overmind IV",
      "label": "transcendent thought",
      "longdesc": ""
    },
    "points": 10,
    "requires": [
      {
        "unittype": "overmind4",
        "val": 1
      }
    ],
    "visible": [
      {
        "unittype": "overmind3",
        "val": 5
      }
    ]
  },
  {
    "name": "overmind4_2",
    "protoId": 63,
    "l": {
      "description": "Grow $REQUIRED overmind IVs",
      "label": "transcendent thought",
      "longdesc": ""
    },
    "points": 20,
    "requires": [
      {
        "unittype": "overmind4",
        "val": 1e+25
      }
    ],
    "visible": [
      {
        "unittype": "overmind4",
        "val": 1
      }
    ]
  },
  {
    "name": "overmind4_3",
    "protoId": 64,
    "l": {
      "description": "Grow $REQUIRED overmind IVs",
      "label": "transcendent thought",
      "longdesc": ""
    },
    "points": 30,
    "requires": [
      {
        "unittype": "overmind4",
        "val": 1e+50
      }
    ],
    "visible": [
      {
        "unittype": "overmind4",
        "val": 1
      }
    ]
  },
  {
    "name": "overmind5_1",
    "protoId": 65,
    "l": {
      "description": "Grow your first overmind V",
      "label": "transcendent thought",
      "longdesc": ""
    },
    "points": 10,
    "requires": [
      {
        "unittype": "overmind5",
        "val": 1
      }
    ],
    "visible": [
      {
        "unittype": "overmind4",
        "val": 5
      }
    ]
  },
  {
    "name": "overmind5_2",
    "protoId": 66,
    "l": {
      "description": "Grow $REQUIRED overmind Vs",
      "label": "transcendent thought",
      "longdesc": ""
    },
    "points": 20,
    "requires": [
      {
        "unittype": "overmind5",
        "val": 1e+28
      }
    ],
    "visible": [
      {
        "unittype": "overmind5",
        "val": 1
      }
    ]
  },
  {
    "name": "overmind5_3",
    "protoId": 67,
    "l": {
      "description": "Grow $REQUIRED overmind Vs",
      "label": "transcendent thought",
      "longdesc": ""
    },
    "points": 30,
    "requires": [
      {
        "unittype": "overmind5",
        "val": 1e+56
      }
    ],
    "visible": [
      {
        "unittype": "overmind5",
        "val": 1
      }
    ]
  },
  {
    "name": "overmind6_1",
    "protoId": 68,
    "l": {
      "description": "Grow your first overmind VI",
      "label": "transcendent thought",
      "longdesc": ""
    },
    "points": 10,
    "requires": [
      {
        "unittype": "overmind6",
        "val": 1
      }
    ],
    "visible": [
      {
        "unittype": "overmind5",
        "val": 5
      }
    ]
  },
  {
    "name": "overmind6_2",
    "protoId": 69,
    "l": {
      "description": "Grow $REQUIRED overmind VIs",
      "label": "transcendent thought",
      "longdesc": ""
    },
    "points": 20,
    "requires": [
      {
        "unittype": "overmind6",
        "val": 1e+31
      }
    ],
    "visible": [
      {
        "unittype": "overmind6",
        "val": 1
      }
    ]
  },
  {
    "name": "overmind6_3",
    "protoId": 70,
    "l": {
      "description": "Grow $REQUIRED overmind VIs",
      "label": "transcendent thought",
      "longdesc": ""
    },
    "points": 30,
    "requires": [
      {
        "unittype": "overmind6",
        "val": 1e+62
      }
    ],
    "visible": [
      {
        "unittype": "overmind6",
        "val": 1
      }
    ]
  },
  {
    "name": "ascension1",
    "protoId": 71,
    "l": {
      "description": "Ascend once",
      "label": "betcha can't beat just one",
      "longdesc": ""
    },
    "points": 10,
    "requires": [
      {
        "unittype": "ascension",
        "val": 1
      }
    ],
    "visible": [
      {
        "upgradetype": "expansion",
        "val": 40
      }
    ]
  },
  {
    "name": "ascension11",
    "protoId": 72,
    "l": {
      "description": "Ascend $REQUIRED times",
      "label": "third time's the charm",
      "longdesc": ""
    },
    "points": 20,
    "requires": [
      {
        "unittype": "ascension",
        "val": 3
      }
    ],
    "visible": [
      {
        "unittype": "ascension",
        "val": 1
      }
    ]
  },
  {
    "name": "ascension2",
    "protoId": 73,
    "l": {
      "description": "Ascend $REQUIRED times",
      "label": "interplanetary infestation",
      "longdesc": ""
    },
    "points": 30,
    "requires": [
      {
        "unittype": "ascension",
        "val": 5
      }
    ],
    "visible": [
      {
        "unittype": "ascension",
        "val": 1
      }
    ]
  },
  {
    "name": "ascension21",
    "protoId": 74,
    "l": {
      "description": "Ascend $REQUIRED times",
      "label": "reseterrific",
      "longdesc": ""
    },
    "points": 40,
    "requires": [
      {
        "unittype": "ascension",
        "val": 10
      }
    ],
    "visible": [
      {
        "unittype": "ascension",
        "val": 1
      }
    ]
  },
  {
    "name": "ascension3",
    "protoId": 75,
    "l": {
      "description": "Ascend $REQUIRED times",
      "label": "prestigious",
      "longdesc": ""
    },
    "points": 50,
    "requires": [
      {
        "unittype": "ascension",
        "val": 20
      }
    ],
    "visible": [
      {
        "unittype": "ascension",
        "val": 1
      }
    ]
  },
  {
    "name": "mutation1",
    "protoId": 76,
    "l": {
      "description": "Unlock your first mutation",
      "label": "cowabunga!",
      "longdesc": ""
    },
    "points": 10,
    "requires": [
      {
        "upgradetype": "mutatehidden",
        "val": 1
      }
    ],
    "visible": [
      {
        "unittype": "ascension",
        "val": 1
      }
    ]
  },
  {
    "name": "mutation2",
    "protoId": 77,
    "l": {
      "description": "Unlock $REQUIRED mutations",
      "label": "intelligent design",
      "longdesc": ""
    },
    "points": 20,
    "requires": [
      {
        "upgradetype": "mutatehidden",
        "val": 3
      }
    ],
    "visible": [
      {
        "upgradetype": "mutatehidden",
        "val": 1
      }
    ]
  },
  {
    "name": "mutation3",
    "protoId": 78,
    "l": {
      "description": "Unlock $REQUIRED mutations",
      "label": "unnatural selection",
      "longdesc": ""
    },
    "points": 30,
    "requires": [
      {
        "upgradetype": "mutatehidden",
        "val": 6
      }
    ],
    "visible": [
      {
        "upgradetype": "mutatehidden",
        "val": 1
      }
    ]
  },
  {
    "name": "mutation4",
    "protoId": 79,
    "l": {
      "description": "Unlock $REQUIRED mutations",
      "label": "a bath, ur",
      "longdesc": ""
    },
    "points": 40,
    "requires": [
      {
        "upgradetype": "mutatehidden",
        "val": 10
      }
    ],
    "visible": [
      {
        "upgradetype": "mutatehidden",
        "val": 1
      }
    ]
  },
  {
    "name": "swarmling1",
    "protoId": 80,
    "l": {
      "description": "Hatch $REQUIRED swarmlings",
      "label": "rush",
      "longdesc": ""
    },
    "points": 10,
    "requires": [
      {
        "unittype": "swarmling",
        "val": 6
      }
    ],
    "visible": [
      {
        "unittype": "meat",
        "val": 0
      }
    ]
  },
  {
    "name": "swarmling2",
    "protoId": 81,
    "l": {
      "description": "Hatch $REQUIRED swarmlings",
      "label": "metabolic boost",
      "longdesc": ""
    },
    "points": 10,
    "requires": [
      {
        "unittype": "swarmling",
        "val": 1000000
      }
    ],
    "visible": [
      {
        "unittype": "meat",
        "val": 0
      }
    ]
  },
  {
    "name": "swarmling3",
    "protoId": 82,
    "l": {
      "description": "Hatch $REQUIRED swarmlings",
      "label": "adrenal glands",
      "longdesc": "Swarmlings hatched by nexus abilities don't count."
    },
    "points": 10,
    "requires": [
      {
        "unittype": "swarmling",
        "val": 1000000000000000
      }
    ],
    "visible": [
      {
        "unittype": "meat",
        "val": 0
      }
    ]
  },
  {
    "name": "stinger1",
    "protoId": 83,
    "l": {
      "description": "Hatch $REQUIRED stingers",
      "label": "beekeeper",
      "longdesc": ""
    },
    "points": 10,
    "requires": [
      {
        "unittype": "stinger",
        "val": 100
      }
    ],
    "visible": [
      {
        "unittype": "meat",
        "val": 0
      }
    ]
  },
  {
    "name": "stinger2",
    "protoId": 84,
    "l": {
      "description": "Hatch $REQUIRED stingers",
      "label": "to bee or not to bee",
      "longdesc": ""
    },
    "points": 10,
    "requires": [
      {
        "unittype": "stinger",
        "val": 1000000
      }
    ],
    "visible": [
      {
        "unittype": "meat",
        "val": 0
      }
    ]
  },
  {
    "name": "stinger3",
    "protoId": 85,
    "l": {
      "description": "Hatch $REQUIRED stingers",
      "label": "waxing poetic",
      "longdesc": "Stingers hatched by nexus abilities don't count."
    },
    "points": 10,
    "requires": [
      {
        "unittype": "stinger",
        "val": 1000000000000000
      }
    ],
    "visible": [
      {
        "unittype": "meat",
        "val": 0
      }
    ]
  },
  {
    "name": "spider1",
    "protoId": 86,
    "l": {
      "description": "Hatch $REQUIRED arachnomorphs",
      "label": "with great power",
      "longdesc": ""
    },
    "points": 10,
    "requires": [
      {
        "unittype": "spider",
        "val": 100
      }
    ],
    "visible": [
      {
        "unittype": "spider",
        "val": 1
      }
    ]
  },
  {
    "name": "spider2",
    "protoId": 87,
    "l": {
      "description": "Hatch $REQUIRED arachnomorphs",
      "label": "the amazing spider",
      "longdesc": ""
    },
    "points": 10,
    "requires": [
      {
        "unittype": "spider",
        "val": 1000000
      }
    ],
    "visible": [
      {
        "unittype": "spider",
        "val": 1
      }
    ]
  },
  {
    "name": "spider3",
    "protoId": 88,
    "l": {
      "description": "Hatch $REQUIRED arachnomorphs",
      "label": "how do i shot web",
      "longdesc": "Arachnomorphs hatched by nexus abilities don't count."
    },
    "points": 10,
    "requires": [
      {
        "unittype": "spider",
        "val": 1000000000000000
      }
    ],
    "visible": [
      {
        "unittype": "spider",
        "val": 100
      }
    ]
  },
  {
    "name": "mosquito1",
    "protoId": 89,
    "l": {
      "description": "Hatch $REQUIRED culicimorphs",
      "label": "sparkly",
      "longdesc": ""
    },
    "points": 10,
    "requires": [
      {
        "unittype": "mosquito",
        "val": 100
      }
    ],
    "visible": [
      {
        "unittype": "mosquito",
        "val": 1
      }
    ]
  },
  {
    "name": "mosquito2",
    "protoId": 90,
    "l": {
      "description": "Hatch $REQUIRED culicimorphs",
      "label": "west nile",
      "longdesc": ""
    },
    "points": 10,
    "requires": [
      {
        "unittype": "mosquito",
        "val": 1000000
      }
    ],
    "visible": [
      {
        "unittype": "mosquito",
        "val": 1
      }
    ]
  },
  {
    "name": "mosquito3",
    "protoId": 91,
    "l": {
      "description": "Hatch $REQUIRED culicimorphs",
      "label": "this achievement sucks",
      "longdesc": "Culicimorphs hatched by nexus abilities don't count."
    },
    "points": 10,
    "requires": [
      {
        "unittype": "mosquito",
        "val": 1000000000000000
      }
    ],
    "visible": [
      {
        "unittype": "mosquito",
        "val": 100
      }
    ]
  },
  {
    "name": "locust1",
    "protoId": 92,
    "l": {
      "description": "Hatch $REQUIRED locusts",
      "label": "shadow over egypt",
      "longdesc": ""
    },
    "points": 10,
    "requires": [
      {
        "unittype": "locust",
        "val": 100
      }
    ],
    "visible": [
      {
        "unittype": "locust",
        "val": 1
      }
    ]
  },
  {
    "name": "locust2",
    "protoId": 93,
    "l": {
      "description": "Hatch $REQUIRED locusts",
      "label": "stalemate",
      "longdesc": ""
    },
    "points": 10,
    "requires": [
      {
        "unittype": "locust",
        "val": 1000000
      }
    ],
    "visible": [
      {
        "unittype": "locust",
        "val": 1
      }
    ]
  },
  {
    "name": "locust3",
    "protoId": 94,
    "l": {
      "description": "Hatch $REQUIRED locusts",
      "label": "trypophobia",
      "longdesc": "Locusts hatched by nexus abilities don't count."
    },
    "points": 10,
    "requires": [
      {
        "unittype": "locust",
        "val": 1000000000000000
      }
    ],
    "visible": [
      {
        "unittype": "locust",
        "val": 100
      }
    ]
  },
  {
    "name": "roach1",
    "protoId": 95,
    "l": {
      "description": "Hatch $REQUIRED roaches",
      "label": "roach coach",
      "longdesc": ""
    },
    "points": 10,
    "requires": [
      {
        "unittype": "roach",
        "val": 100
      }
    ],
    "visible": [
      {
        "unittype": "roach",
        "val": 1
      }
    ]
  },
  {
    "name": "roach2",
    "protoId": 96,
    "l": {
      "description": "Hatch $REQUIRED roaches",
      "label": "roach clips",
      "longdesc": ""
    },
    "points": 10,
    "requires": [
      {
        "unittype": "roach",
        "val": 1000000
      }
    ],
    "visible": [
      {
        "unittype": "roach",
        "val": 1
      }
    ]
  },
  {
    "name": "roach3",
    "protoId": 97,
    "l": {
      "description": "Hatch $REQUIRED roaches",
      "label": "papa",
      "longdesc": "Roaches hatched by nexus abilities don't count."
    },
    "points": 10,
    "requires": [
      {
        "unittype": "roach",
        "val": 1000000000000000
      }
    ],
    "visible": [
      {
        "unittype": "roach",
        "val": 100
      }
    ]
  },
  {
    "name": "giantspider1",
    "protoId": 98,
    "l": {
      "description": "Hatch $REQUIRED giant arachnomorphs",
      "label": "with greater power",
      "longdesc": ""
    },
    "points": 10,
    "requires": [
      {
        "unittype": "giantspider",
        "val": 100
      }
    ],
    "visible": [
      {
        "unittype": "giantspider",
        "val": 1
      }
    ]
  },
  {
    "name": "giantspider2",
    "protoId": 99,
    "l": {
      "description": "Hatch $REQUIRED giant arachnomorphs",
      "label": "whatever a spider can",
      "longdesc": ""
    },
    "points": 10,
    "requires": [
      {
        "unittype": "giantspider",
        "val": 1000000
      }
    ],
    "visible": [
      {
        "unittype": "giantspider",
        "val": 1
      }
    ]
  },
  {
    "name": "giantspider3",
    "protoId": 100,
    "l": {
      "description": "Hatch $REQUIRED giant arachnomorphs",
      "label": "and I'm just sitting here",
      "longdesc": "Giant Arachnomorphs hatched by nexus abilities don't count."
    },
    "points": 10,
    "requires": [
      {
        "unittype": "giantspider",
        "val": 1000000000000000
      }
    ],
    "visible": [
      {
        "unittype": "giantspider",
        "val": 100
      }
    ]
  },
  {
    "name": "centipede1",
    "protoId": 101,
    "l": {
      "description": "Hatch $REQUIRED chilopodomorphs",
      "label": "centipede",
      "longdesc": ""
    },
    "points": 10,
    "requires": [
      {
        "unittype": "centipede",
        "val": 100
      }
    ],
    "visible": [
      {
        "unittype": "centipede",
        "val": 1
      }
    ]
  },
  {
    "name": "centipede2",
    "protoId": 102,
    "l": {
      "description": "Hatch $REQUIRED chilopodomorphs",
      "label": "millipede",
      "longdesc": ""
    },
    "points": 10,
    "requires": [
      {
        "unittype": "centipede",
        "val": 1000000
      }
    ],
    "visible": [
      {
        "unittype": "centipede",
        "val": 1
      }
    ]
  },
  {
    "name": "centipede3",
    "protoId": 103,
    "l": {
      "description": "Hatch $REQUIRED chilopodomorphs",
      "label": "missile command",
      "longdesc": "Chilopodomorphs hatched by nexus abilities don't count."
    },
    "points": 10,
    "requires": [
      {
        "unittype": "centipede",
        "val": 1000000000000000
      }
    ],
    "visible": [
      {
        "unittype": "centipede",
        "val": 100
      }
    ]
  },
  {
    "name": "wasp1",
    "protoId": 104,
    "l": {
      "description": "Hatch $REQUIRED wasps",
      "label": "aldrin",
      "longdesc": ""
    },
    "points": 10,
    "requires": [
      {
        "unittype": "wasp",
        "val": 100
      }
    ],
    "visible": [
      {
        "unittype": "wasp",
        "val": 1
      }
    ]
  },
  {
    "name": "wasp2",
    "protoId": 105,
    "l": {
      "description": "Hatch $REQUIRED wasps",
      "label": "lightyear",
      "longdesc": ""
    },
    "points": 10,
    "requires": [
      {
        "unittype": "wasp",
        "val": 1000000
      }
    ],
    "visible": [
      {
        "unittype": "wasp",
        "val": 1
      }
    ]
  },
  {
    "name": "wasp3",
    "protoId": 106,
    "l": {
      "description": "Hatch $REQUIRED wasps",
      "label": "kill",
      "longdesc": "Wasps hatched by nexus abilities don't count."
    },
    "points": 10,
    "requires": [
      {
        "unittype": "wasp",
        "val": 1000000000000000
      }
    ],
    "visible": [
      {
        "unittype": "wasp",
        "val": 100
      }
    ]
  },
  {
    "name": "devourer1",
    "protoId": 107,
    "l": {
      "description": "Hatch $REQUIRED devourers",
      "label": "these things fly, right?",
      "longdesc": ""
    },
    "points": 10,
    "requires": [
      {
        "unittype": "devourer",
        "val": 100
      }
    ],
    "visible": [
      {
        "unittype": "devourer",
        "val": 1
      }
    ]
  },
  {
    "name": "devourer2",
    "protoId": 108,
    "l": {
      "description": "Hatch $REQUIRED devourers",
      "label": "or do they burrow?",
      "longdesc": ""
    },
    "points": 10,
    "requires": [
      {
        "unittype": "devourer",
        "val": 1000000
      }
    ],
    "visible": [
      {
        "unittype": "devourer",
        "val": 1
      }
    ]
  },
  {
    "name": "devourer3",
    "protoId": 109,
    "l": {
      "description": "Hatch $REQUIRED devourers",
      "label": "sometimes they drain energy",
      "longdesc": "Devourers hatched by nexus abilities don't count."
    },
    "points": 10,
    "requires": [
      {
        "unittype": "devourer",
        "val": 1000000000000000
      }
    ],
    "visible": [
      {
        "unittype": "devourer",
        "val": 100
      }
    ]
  },
  {
    "name": "goon1",
    "protoId": 110,
    "l": {
      "description": "Hatch $REQUIRED goons",
      "label": "new year's",
      "longdesc": ""
    },
    "points": 10,
    "requires": [
      {
        "unittype": "goon",
        "val": 100
      }
    ],
    "visible": [
      {
        "unittype": "goon",
        "val": 1
      }
    ]
  },
  {
    "name": "goon2",
    "protoId": 111,
    "l": {
      "description": "Hatch $REQUIRED goons",
      "label": "adam and",
      "longdesc": ""
    },
    "points": 10,
    "requires": [
      {
        "unittype": "goon",
        "val": 1000000
      }
    ],
    "visible": [
      {
        "unittype": "goon",
        "val": 1
      }
    ]
  },
  {
    "name": "goon3",
    "protoId": 112,
    "l": {
      "description": "Hatch $REQUIRED goons",
      "label": "all hallows'",
      "longdesc": "Goons hatched by nexus abilities don't count."
    },
    "points": 10,
    "requires": [
      {
        "unittype": "goon",
        "val": 1000000000000000
      }
    ],
    "visible": [
      {
        "unittype": "goon",
        "val": 100
      }
    ]
  },
  {
    "name": "nexus1",
    "protoId": 113,
    "l": {
      "description": "Build $REQUIRED nexus",
      "label": "phenomenal cosmic power",
      "longdesc": ""
    },
    "points": 10,
    "requires": [
      {
        "upgradetype": "nexus1",
        "val": 1
      }
    ],
    "visible": [
      {
        "unittype": "meat",
        "val": 33333333333
      }
    ]
  },
  {
    "name": "nexus2",
    "protoId": 114,
    "l": {
      "description": "Build 5 nexus",
      "label": "power overwhelming",
      "longdesc": ""
    },
    "points": 10,
    "requires": [
      {
        "upgradetype": "nexus5",
        "val": 1
      }
    ],
    "visible": [
      {
        "unittype": "nexus",
        "val": 1
      }
    ]
  },
  {
    "name": "changelog",
    "protoId": 115,
    "l": {
      "description": "Find the Patch Notes",
      "label": "patchy knowledge",
      "longdesc": "Don't take any books, please."
    },
    "points": 10,
    "requires": [
      {
        "event": "changelog",
        "val": ""
      }
    ],
    "visible": [
      {
        "unittype": "meat",
        "val": 0
      }
    ]
  },
  {
    "name": "import",
    "protoId": 116,
    "l": {
      "description": "Import your saved game",
      "label": "portable swarm",
      "longdesc": ""
    },
    "points": 10,
    "requires": [
      {
        "event": "import",
        "val": "{\"success\":true}"
      }
    ],
    "visible": []
  },
  {
    "name": "clickme",
    "protoId": 117,
    "l": {
      "description": "Click this achievement's slot",
      "label": "since you asked nicely",
      "longdesc": ""
    },
    "points": 30,
    "requires": [
      {
        "event": "achieveclick",
        "val": "{\"name\":\"clickme\"}"
      }
    ],
    "visible": []
  },
  {
    "name": "konami",
    "protoId": 118,
    "l": {
      "description": "Enter the Konami Code",
      "label": "l33t h4x",
      "longdesc": ""
    },
    "points": 30,
    "requires": [
      {
        "event": "konami",
        "val": ""
      }
    ],
    "visible": []
  },
  {
    "name": "debug",
    "protoId": 119,
    "l": {
      "description": "Find the debug page",
      "label": "even de bugs have bugs",
      "longdesc": ""
    },
    "points": 30,
    "requires": [
      {
        "event": "debugPage",
        "val": ""
      }
    ],
    "visible": []
  },
  {
    "name": "publictest1",
    "protoId": 120,
    "l": {
      "description": "Help test Swarm Simulator v1.0.",
      "label": "public test v1.0",
      "longdesc": "Thank you for your help!"
    },
    "points": 0,
    "requires": [
      {
        "event": "achieve-publictest1",
        "val": ""
      }
    ],
    "visible": []
  },
  {
    "name": "therightquestion",
    "protoId": 121,
    "l": {
      "description": "Ask the right question",
      "label": "signs point to yes",
      "longdesc": "The secret's out - read it on /r/swarmsim"
    },
    "points": 0,
    "requires": [
      {
        "event": "therightquestion",
        "val": ""
      }
    ],
    "visible": [
      {
        "unittype": "ascension",
        "val": 20
      }
    ]
  }
];
export default list;
