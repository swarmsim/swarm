import * as C from "./codec";

const list: C.Upgrade[] = [
  {
    "name": "hatchery",
    "l": {
      "description": "-",
      "label": "hatchery",
      "lol": ""
    },
    "class": "upgrade",
    "unittype": "invisiblehatchery",
    "cost": [
      {
        "unittype": "meat",
        "val": 300,
        "factor": 10
      }
    ],
    "effect": [
      {
        "type": "addStat",
        "unittype": "invisiblehatchery",
        "stat": "base",
        "val": 1
      },
      {
        "type": "addUnitRand",
        "unittype": "premutagen",
        "val": 1.2544
      },
      {
        "type": "addUnitTimed",
        "unittype": "crystal",
        "val": 500,
        "unittype2": "energy",
        "val2": 1800
      }
    ]
  },
  {
    "name": "expansion",
    "l": {
      "description": "-",
      "label": "expansion",
      "lol": ""
    },
    "class": "upgrade",
    "unittype": "invisiblehatchery",
    "cost": [
      {
        "unittype": "territory",
        "val": 10,
        "factor": 2.45
      }
    ],
    "effect": [
      {
        "type": "multStat",
        "unittype": "invisiblehatchery",
        "stat": "prod",
        "val": 1.1
      },
      {
        "type": "addUnitRand",
        "unittype": "premutagen",
        "val": 1.12
      },
      {
        "type": "addUnitTimed",
        "unittype": "crystal",
        "val": 500,
        "unittype2": "energy",
        "val2": 1800
      }
    ]
  },
  {
    "name": "achievementbonus",
    "l": {
      "description": "-",
      "label": "accomplished ancestry",
      "lol": ""
    },
    "class": "upgrade",
    "unittype": "invisiblehatchery",
    "requires": [
      {
        "unittype": "meat",
        "val": 50000
      }
    ],
    "cost": [
      {
        "unittype": "meat",
        "val": 5000000,
        "factor": 10000
      },
      {
        "unittype": "territory",
        "val": 500,
        "factor": 10000
      }
    ],
    "effect": [
      {
        "type": "multStatPerAchievementPoint",
        "unittype": "larva",
        "stat": "prod",
        "val": 0.001
      }
    ],
    "maxlevel": 5
  },
  {
    "name": "cocooning",
    "l": {
      "description": "Allows your larvae to encase themselves within cocoons. Cocooned larvae cannot mutate into other units, and can still be cloned by Clone Larvae. You may cocoon and uncocoon your larvae whenever you wish.",
      "label": "cocooning",
      "lol": ""
    },
    "class": "upgrade",
    "unittype": "invisiblehatchery",
    "requires": [
      {
        "unittype": "nexus",
        "val": 4
      }
    ],
    "cost": [
      {
        "unittype": "meat",
        "val": 3.33333e+21,
        "factor": 0
      }
    ],
    "maxlevel": 1
  },
  {
    "name": "droneprod",
    "l": {
      "description": "Drones gather more meat.",
      "label": "faster drones",
      "lol": ""
    },
    "class": "upgrade",
    "unittype": "drone",
    "requires": [
      {
        "unittype": "drone",
        "val": 67
      }
    ],
    "cost": [
      {
        "unittype": "drone",
        "val": 66,
        "factor": 666
      }
    ],
    "effect": [
      {
        "type": "multStat",
        "unittype": "drone",
        "stat": "prod",
        "val": 2
      }
    ]
  },
  {
    "name": "queenprod",
    "l": {
      "description": "Queens produce more drones.",
      "label": "faster queens",
      "lol": ""
    },
    "class": "upgrade",
    "unittype": "queen",
    "requires": [
      {
        "unittype": "queen",
        "val": 67
      }
    ],
    "cost": [
      {
        "unittype": "queen",
        "val": 66,
        "factor": 666
      }
    ],
    "effect": [
      {
        "type": "multStat",
        "unittype": "queen",
        "stat": "prod",
        "val": 2
      }
    ]
  },
  {
    "name": "nestprod",
    "l": {
      "description": "Nests produce more queens.",
      "label": "faster nests",
      "lol": ""
    },
    "class": "upgrade",
    "unittype": "nest",
    "requires": [
      {
        "unittype": "nest",
        "val": 67
      }
    ],
    "cost": [
      {
        "unittype": "nest",
        "val": 66,
        "factor": 666
      }
    ],
    "effect": [
      {
        "type": "multStat",
        "unittype": "nest",
        "stat": "prod",
        "val": 2
      }
    ]
  },
  {
    "name": "greaterqueenprod",
    "l": {
      "description": "Greater queens produce more nests.",
      "label": "faster greater queens",
      "lol": ""
    },
    "class": "upgrade",
    "unittype": "greaterqueen",
    "requires": [
      {
        "unittype": "greaterqueen",
        "val": 67
      }
    ],
    "cost": [
      {
        "unittype": "greaterqueen",
        "val": 66,
        "factor": 666
      }
    ],
    "effect": [
      {
        "type": "multStat",
        "unittype": "greaterqueen",
        "stat": "prod",
        "val": 2
      }
    ]
  },
  {
    "name": "hiveprod",
    "l": {
      "description": "Hives produce more greater queens.",
      "label": "faster hives",
      "lol": ""
    },
    "class": "upgrade",
    "unittype": "hive",
    "requires": [
      {
        "unittype": "hive",
        "val": 67
      }
    ],
    "cost": [
      {
        "unittype": "hive",
        "val": 66,
        "factor": 666
      }
    ],
    "effect": [
      {
        "type": "multStat",
        "unittype": "hive",
        "stat": "prod",
        "val": 2
      }
    ]
  },
  {
    "name": "hivequeenprod",
    "l": {
      "description": "Hive queens produce more hives.",
      "label": "faster hive queens",
      "lol": ""
    },
    "class": "upgrade",
    "unittype": "hivequeen",
    "requires": [
      {
        "unittype": "hivequeen",
        "val": 67
      }
    ],
    "cost": [
      {
        "unittype": "hivequeen",
        "val": 66,
        "factor": 666
      }
    ],
    "effect": [
      {
        "type": "multStat",
        "unittype": "hivequeen",
        "stat": "prod",
        "val": 2
      }
    ]
  },
  {
    "name": "empressprod",
    "l": {
      "description": "Hive empresses produce more hive queens.",
      "label": "faster hive empresses",
      "lol": ""
    },
    "class": "upgrade",
    "unittype": "empress",
    "requires": [
      {
        "unittype": "empress",
        "val": 67
      }
    ],
    "cost": [
      {
        "unittype": "empress",
        "val": 66,
        "factor": 666
      }
    ],
    "effect": [
      {
        "type": "multStat",
        "unittype": "empress",
        "stat": "prod",
        "val": 2
      }
    ]
  },
  {
    "name": "prophetprod",
    "l": {
      "description": "Neuroprophets produce more hive empresses.",
      "label": "faster neuroprophets",
      "lol": ""
    },
    "class": "upgrade",
    "unittype": "prophet",
    "requires": [
      {
        "unittype": "prophet",
        "val": 67
      }
    ],
    "cost": [
      {
        "unittype": "prophet",
        "val": 66,
        "factor": 666
      }
    ],
    "effect": [
      {
        "type": "multStat",
        "unittype": "prophet",
        "stat": "prod",
        "val": 2
      }
    ]
  },
  {
    "name": "goddessprod",
    "l": {
      "description": "Hive neurons produce more neuroprophets.",
      "label": "faster hive neurons",
      "lol": ""
    },
    "class": "upgrade",
    "unittype": "goddess",
    "requires": [
      {
        "unittype": "goddess",
        "val": 67
      }
    ],
    "cost": [
      {
        "unittype": "goddess",
        "val": 66,
        "factor": 666
      }
    ],
    "effect": [
      {
        "type": "multStat",
        "unittype": "goddess",
        "stat": "prod",
        "val": 2
      }
    ]
  },
  {
    "name": "pantheonprod",
    "l": {
      "description": "Neural clusters produce more hive neurons.",
      "label": "faster neural clusters",
      "lol": ""
    },
    "class": "upgrade",
    "unittype": "pantheon",
    "requires": [
      {
        "unittype": "pantheon",
        "val": 67
      }
    ],
    "cost": [
      {
        "unittype": "pantheon",
        "val": 66,
        "factor": 666
      }
    ],
    "effect": [
      {
        "type": "multStat",
        "unittype": "pantheon",
        "stat": "prod",
        "val": 2
      }
    ]
  },
  {
    "name": "pantheon2prod",
    "l": {
      "description": "Hive networks produce more neural clusters.",
      "label": "faster hive networks",
      "lol": ""
    },
    "class": "upgrade",
    "unittype": "pantheon2",
    "requires": [
      {
        "unittype": "pantheon2",
        "val": 67
      }
    ],
    "cost": [
      {
        "unittype": "pantheon2",
        "val": 66,
        "factor": 666
      }
    ],
    "effect": [
      {
        "type": "multStat",
        "unittype": "pantheon2",
        "stat": "prod",
        "val": 2
      }
    ]
  },
  {
    "name": "pantheon3prod",
    "l": {
      "description": "Lesser hive minds produce more hive networks.",
      "label": "faster lesser hive minds",
      "lol": ""
    },
    "class": "upgrade",
    "unittype": "pantheon3",
    "requires": [
      {
        "unittype": "pantheon3",
        "val": 67
      }
    ],
    "cost": [
      {
        "unittype": "pantheon3",
        "val": 66,
        "factor": 666
      }
    ],
    "effect": [
      {
        "type": "multStat",
        "unittype": "pantheon3",
        "stat": "prod",
        "val": 2
      }
    ]
  },
  {
    "name": "pantheon4prod",
    "l": {
      "description": "Hive minds produce more lesser hive minds.",
      "label": "faster hive minds",
      "lol": ""
    },
    "class": "upgrade",
    "unittype": "pantheon4",
    "requires": [
      {
        "unittype": "pantheon4",
        "val": 67
      }
    ],
    "cost": [
      {
        "unittype": "pantheon4",
        "val": 66,
        "factor": 666
      }
    ],
    "effect": [
      {
        "type": "multStat",
        "unittype": "pantheon4",
        "stat": "prod",
        "val": 2
      }
    ]
  },
  {
    "name": "pantheon5prod",
    "l": {
      "description": "Arch-minds produce more hive minds.",
      "label": "faster arch-minds",
      "lol": ""
    },
    "class": "upgrade",
    "unittype": "pantheon5",
    "requires": [
      {
        "unittype": "pantheon5",
        "val": 67
      }
    ],
    "cost": [
      {
        "unittype": "pantheon5",
        "val": 66,
        "factor": 666
      }
    ],
    "effect": [
      {
        "type": "multStat",
        "unittype": "pantheon5",
        "stat": "prod",
        "val": 2
      }
    ]
  },
  {
    "name": "overmindprod",
    "l": {
      "description": "Overminds produce more arch-minds.",
      "label": "faster overminds",
      "lol": ""
    },
    "class": "upgrade",
    "unittype": "overmind",
    "requires": [
      {
        "unittype": "overmind",
        "val": 67
      }
    ],
    "cost": [
      {
        "unittype": "overmind",
        "val": 66,
        "factor": 666
      }
    ],
    "effect": [
      {
        "type": "multStat",
        "unittype": "overmind",
        "stat": "prod",
        "val": 2
      }
    ]
  },
  {
    "name": "overmind2prod",
    "l": {
      "description": "Overmind IIs produce more overminds.",
      "label": "faster overmind IIs",
      "lol": ""
    },
    "class": "upgrade",
    "unittype": "overmind2",
    "requires": [
      {
        "unittype": "overmind2",
        "val": 67
      }
    ],
    "cost": [
      {
        "unittype": "overmind2",
        "val": 66,
        "factor": 666
      }
    ],
    "effect": [
      {
        "type": "multStat",
        "unittype": "overmind2",
        "stat": "prod",
        "val": 2
      }
    ]
  },
  {
    "name": "overmind3prod",
    "l": {
      "description": "Overmind IIIs produce more overmind IIs.",
      "label": "faster overmind IIIs",
      "lol": ""
    },
    "class": "upgrade",
    "unittype": "overmind3",
    "requires": [
      {
        "unittype": "overmind3",
        "val": 67
      }
    ],
    "cost": [
      {
        "unittype": "overmind3",
        "val": 66,
        "factor": 666
      }
    ],
    "effect": [
      {
        "type": "multStat",
        "unittype": "overmind3",
        "stat": "prod",
        "val": 2
      }
    ]
  },
  {
    "name": "overmind4prod",
    "l": {
      "description": "Overmind IVs produce more overmind IIIs.",
      "label": "faster overmind IVs",
      "lol": ""
    },
    "class": "upgrade",
    "unittype": "overmind4",
    "requires": [
      {
        "unittype": "overmind4",
        "val": 67
      }
    ],
    "cost": [
      {
        "unittype": "overmind4",
        "val": 66,
        "factor": 666
      }
    ],
    "effect": [
      {
        "type": "multStat",
        "unittype": "overmind4",
        "stat": "prod",
        "val": 2
      }
    ]
  },
  {
    "name": "overmind5prod",
    "l": {
      "description": "Overmind Vs produce more overmind IVs.",
      "label": "faster overmind Vs",
      "lol": ""
    },
    "class": "upgrade",
    "unittype": "overmind5",
    "requires": [
      {
        "unittype": "overmind5",
        "val": 67
      }
    ],
    "cost": [
      {
        "unittype": "overmind5",
        "val": 66,
        "factor": 666
      }
    ],
    "effect": [
      {
        "type": "multStat",
        "unittype": "overmind5",
        "stat": "prod",
        "val": 2
      }
    ]
  },
  {
    "name": "overmind6prod",
    "l": {
      "description": "Overmind VIs produce more overmind Vs.",
      "label": "faster overmind VIs",
      "lol": ""
    },
    "class": "upgrade",
    "unittype": "overmind6",
    "requires": [
      {
        "unittype": "overmind6",
        "val": 67
      }
    ],
    "cost": [
      {
        "unittype": "overmind6",
        "val": 66,
        "factor": 666
      }
    ],
    "effect": [
      {
        "type": "multStat",
        "unittype": "overmind6",
        "stat": "prod",
        "val": 2
      }
    ]
  },
  {
    "name": "dronetwin",
    "l": {
      "description": "Multiple drones hatch from each larva. (This does not affect queen production.)",
      "label": "twin drones",
      "lol": ""
    },
    "class": "upgrade",
    "unittype": "drone",
    "requires": [
      {
        "unittype": "queen",
        "val": 1
      }
    ],
    "cost": [
      {
        "unittype": "queen",
        "val": 1,
        "factor": 10
      }
    ],
    "effect": [
      {
        "type": "multStat",
        "unittype": "drone",
        "stat": "twin",
        "val": 2
      }
    ]
  },
  {
    "name": "queentwin",
    "l": {
      "description": "Multiple queens hatch from each larva. (This does not affect nest production.)",
      "label": "twin queens",
      "lol": ""
    },
    "class": "upgrade",
    "unittype": "queen",
    "requires": [
      {
        "unittype": "nest",
        "val": 1
      }
    ],
    "cost": [
      {
        "unittype": "nest",
        "val": 1,
        "factor": 10
      }
    ],
    "effect": [
      {
        "type": "multStat",
        "unittype": "queen",
        "stat": "twin",
        "val": 2
      }
    ]
  },
  {
    "name": "nesttwin",
    "l": {
      "description": "Multiple nests are constructed from each larva. (This does not affect greater queen production.)",
      "label": "twin nests",
      "lol": ""
    },
    "class": "upgrade",
    "unittype": "nest",
    "requires": [
      {
        "unittype": "greaterqueen",
        "val": 1
      }
    ],
    "cost": [
      {
        "unittype": "greaterqueen",
        "val": 1,
        "factor": 10
      }
    ],
    "effect": [
      {
        "type": "multStat",
        "unittype": "nest",
        "stat": "twin",
        "val": 2
      }
    ]
  },
  {
    "name": "greaterqueentwin",
    "l": {
      "description": "Multiple greater queens hatch from each larva. (This does not affect hive production.)",
      "label": "twin greater queens",
      "lol": ""
    },
    "class": "upgrade",
    "unittype": "greaterqueen",
    "requires": [
      {
        "unittype": "hive",
        "val": 1
      }
    ],
    "cost": [
      {
        "unittype": "hive",
        "val": 1,
        "factor": 10
      }
    ],
    "effect": [
      {
        "type": "multStat",
        "unittype": "greaterqueen",
        "stat": "twin",
        "val": 2
      }
    ]
  },
  {
    "name": "hivetwin",
    "l": {
      "description": "Multiple hives are constructed from each larva. (This does not affect hive queen production.)",
      "label": "twin hives",
      "lol": ""
    },
    "class": "upgrade",
    "unittype": "hive",
    "requires": [
      {
        "unittype": "hivequeen",
        "val": 1
      }
    ],
    "cost": [
      {
        "unittype": "hivequeen",
        "val": 1,
        "factor": 10
      }
    ],
    "effect": [
      {
        "type": "multStat",
        "unittype": "hive",
        "stat": "twin",
        "val": 2
      }
    ]
  },
  {
    "name": "hivequeentwin",
    "l": {
      "description": "Multiple hive queens hatch from each larva. (This does not affect hive empress production.)",
      "label": "twin hive queens",
      "lol": ""
    },
    "class": "upgrade",
    "unittype": "hivequeen",
    "requires": [
      {
        "unittype": "empress",
        "val": 1
      }
    ],
    "cost": [
      {
        "unittype": "empress",
        "val": 1,
        "factor": 10
      }
    ],
    "effect": [
      {
        "type": "multStat",
        "unittype": "hivequeen",
        "stat": "twin",
        "val": 2
      }
    ]
  },
  {
    "name": "empresstwin",
    "l": {
      "description": "Multiple hive empresses hatch from each larva. (This does not affect neuroprophet production.)",
      "label": "twin hive empresses",
      "lol": ""
    },
    "class": "upgrade",
    "unittype": "empress",
    "requires": [
      {
        "unittype": "prophet",
        "val": 1
      }
    ],
    "cost": [
      {
        "unittype": "prophet",
        "val": 1,
        "factor": 10
      }
    ],
    "effect": [
      {
        "type": "multStat",
        "unittype": "empress",
        "stat": "twin",
        "val": 2
      }
    ]
  },
  {
    "name": "prophettwin",
    "l": {
      "description": "Multiple neuroprophets hatch from each larva. (This does not affect hive neuron production.)",
      "label": "twin neuroprophets",
      "lol": ""
    },
    "class": "upgrade",
    "unittype": "prophet",
    "requires": [
      {
        "unittype": "goddess",
        "val": 1
      }
    ],
    "cost": [
      {
        "unittype": "goddess",
        "val": 1,
        "factor": 10
      }
    ],
    "effect": [
      {
        "type": "multStat",
        "unittype": "prophet",
        "stat": "twin",
        "val": 2
      }
    ]
  },
  {
    "name": "goddesstwin",
    "l": {
      "description": "Multiple hive neurons are created from each larva. (This does not affect neural cluster production.)",
      "label": "twin hive neurons",
      "lol": ""
    },
    "class": "upgrade",
    "unittype": "goddess",
    "requires": [
      {
        "unittype": "pantheon",
        "val": 1
      }
    ],
    "cost": [
      {
        "unittype": "pantheon",
        "val": 1,
        "factor": 10
      }
    ],
    "effect": [
      {
        "type": "multStat",
        "unittype": "goddess",
        "stat": "twin",
        "val": 2
      }
    ]
  },
  {
    "name": "pantheontwin",
    "l": {
      "description": "Multiple neural clusters are created from each larva. (This does not affect hive network production.)",
      "label": "twin neural clusters",
      "lol": ""
    },
    "class": "upgrade",
    "unittype": "pantheon",
    "requires": [
      {
        "unittype": "pantheon2",
        "val": 1
      }
    ],
    "cost": [
      {
        "unittype": "pantheon2",
        "val": 1,
        "factor": 10
      }
    ],
    "effect": [
      {
        "type": "multStat",
        "unittype": "pantheon",
        "stat": "twin",
        "val": 2
      }
    ]
  },
  {
    "name": "pantheon2twin",
    "l": {
      "description": "Multiple hive networks are created from each larva. (This does not affect lesser hive mind production.)",
      "label": "twin hive networks",
      "lol": ""
    },
    "class": "upgrade",
    "unittype": "pantheon2",
    "requires": [
      {
        "unittype": "pantheon3",
        "val": 1
      }
    ],
    "cost": [
      {
        "unittype": "pantheon3",
        "val": 1,
        "factor": 10
      }
    ],
    "effect": [
      {
        "type": "multStat",
        "unittype": "pantheon2",
        "stat": "twin",
        "val": 2
      }
    ]
  },
  {
    "name": "pantheon3twin",
    "l": {
      "description": "Multiple lesser hive minds are created from each larva. (This does not affect hive mind production.)",
      "label": "twin lesser hive minds",
      "lol": ""
    },
    "class": "upgrade",
    "unittype": "pantheon3",
    "requires": [
      {
        "unittype": "pantheon4",
        "val": 1
      }
    ],
    "cost": [
      {
        "unittype": "pantheon4",
        "val": 1,
        "factor": 10
      }
    ],
    "effect": [
      {
        "type": "multStat",
        "unittype": "pantheon3",
        "stat": "twin",
        "val": 2
      }
    ]
  },
  {
    "name": "pantheon4twin",
    "l": {
      "description": "Multiple hive minds are created from each larva. (This does not affect arch-mind production.)",
      "label": "twin hive minds",
      "lol": ""
    },
    "class": "upgrade",
    "unittype": "pantheon4",
    "requires": [
      {
        "unittype": "pantheon5",
        "val": 1
      }
    ],
    "cost": [
      {
        "unittype": "pantheon5",
        "val": 1,
        "factor": 10
      }
    ],
    "effect": [
      {
        "type": "multStat",
        "unittype": "pantheon4",
        "stat": "twin",
        "val": 2
      }
    ]
  },
  {
    "name": "pantheon5twin",
    "l": {
      "description": "Multiple arch-minds are created from each larva. (This does not affect overmind production.)",
      "label": "twin arch-minds",
      "lol": ""
    },
    "class": "upgrade",
    "unittype": "pantheon5",
    "requires": [
      {
        "unittype": "overmind",
        "val": 1
      }
    ],
    "cost": [
      {
        "unittype": "overmind",
        "val": 1,
        "factor": 10
      }
    ],
    "effect": [
      {
        "type": "multStat",
        "unittype": "pantheon5",
        "stat": "twin",
        "val": 2
      }
    ]
  },
  {
    "name": "overmindtwin",
    "l": {
      "description": "Multiple overminds are created from each larva. (This does not affect overmind II production.)",
      "label": "twin overminds",
      "lol": ""
    },
    "class": "upgrade",
    "unittype": "overmind",
    "requires": [
      {
        "unittype": "overmind2",
        "val": 1
      }
    ],
    "cost": [
      {
        "unittype": "overmind2",
        "val": 1,
        "factor": 12
      }
    ],
    "effect": [
      {
        "type": "multStat",
        "unittype": "overmind",
        "stat": "twin",
        "val": 2
      }
    ]
  },
  {
    "name": "overmind2twin",
    "l": {
      "description": "Multiple overmind IIs are created from each larva. (This does not affect overmind III production.)",
      "label": "twin overmind IIs",
      "lol": ""
    },
    "class": "upgrade",
    "unittype": "overmind2",
    "requires": [
      {
        "unittype": "overmind3",
        "val": 1
      }
    ],
    "cost": [
      {
        "unittype": "overmind3",
        "val": 1,
        "factor": 14
      }
    ],
    "effect": [
      {
        "type": "multStat",
        "unittype": "overmind2",
        "stat": "twin",
        "val": 2
      }
    ]
  },
  {
    "name": "overmind3twin",
    "l": {
      "description": "Multiple overmind IIIs are created from each larva. (This does not affect overmind IV production.)",
      "label": "twin overmind IIIs",
      "lol": ""
    },
    "class": "upgrade",
    "unittype": "overmind3",
    "requires": [
      {
        "unittype": "overmind4",
        "val": 1
      }
    ],
    "cost": [
      {
        "unittype": "overmind4",
        "val": 1,
        "factor": 16
      }
    ],
    "effect": [
      {
        "type": "multStat",
        "unittype": "overmind3",
        "stat": "twin",
        "val": 2
      }
    ]
  },
  {
    "name": "overmind4twin",
    "l": {
      "description": "Multiple overmind IVs are created from each larva. (This does not affect overmind V production.)",
      "label": "twin overmind IVs",
      "lol": ""
    },
    "class": "upgrade",
    "unittype": "overmind4",
    "requires": [
      {
        "unittype": "overmind5",
        "val": 1
      }
    ],
    "cost": [
      {
        "unittype": "overmind5",
        "val": 1,
        "factor": 18
      }
    ],
    "effect": [
      {
        "type": "multStat",
        "unittype": "overmind4",
        "stat": "twin",
        "val": 2
      }
    ]
  },
  {
    "name": "overmind5twin",
    "l": {
      "description": "Multiple overmind Vs are created from each larva. (This does not affect overmind VI production.)",
      "label": "twin overmind Vs",
      "lol": ""
    },
    "class": "upgrade",
    "unittype": "overmind5",
    "requires": [
      {
        "unittype": "overmind6",
        "val": 1
      }
    ],
    "cost": [
      {
        "unittype": "overmind6",
        "val": 1,
        "factor": 20
      }
    ],
    "effect": [
      {
        "type": "multStat",
        "unittype": "overmind5",
        "stat": "twin",
        "val": 2
      }
    ]
  },
  {
    "name": "overmind6twin",
    "l": {
      "description": "Multiple overmind VIs are created from each larva.",
      "label": "twin overmind VIs",
      "lol": ""
    },
    "class": "upgrade",
    "unittype": "overmind6",
    "requires": [
      {
        "unittype": "invisiblehatchery",
        "val": 2
      }
    ]
  },
  {
    "name": "swarmlingtwin",
    "l": {
      "description": "Multiple swarmlings hatch from each larva.",
      "label": "twin swarmlings",
      "lol": ""
    },
    "class": "upgrade",
    "unittype": "swarmling",
    "cost": [
      {
        "unittype": "meat",
        "val": 100,
        "factor": 500
      },
      {
        "unittype": "larva",
        "val": 1,
        "factor": 50
      }
    ],
    "effect": [
      {
        "type": "multStat",
        "unittype": "swarmling",
        "stat": "twin",
        "val": 2
      }
    ]
  },
  {
    "name": "stingertwin",
    "l": {
      "description": "Multiple stingers hatch from each larva.",
      "label": "twin stingers",
      "lol": ""
    },
    "class": "upgrade",
    "unittype": "stinger",
    "cost": [
      {
        "unittype": "meat",
        "val": 100,
        "factor": 500
      },
      {
        "unittype": "larva",
        "val": 1,
        "factor": 50
      }
    ],
    "effect": [
      {
        "type": "multStat",
        "unittype": "stinger",
        "stat": "twin",
        "val": 2
      }
    ]
  },
  {
    "name": "spidertwin",
    "l": {
      "description": "Multiple arachnomorphs hatch from each larva.",
      "label": "twin arachnomorphs",
      "lol": ""
    },
    "class": "upgrade",
    "unittype": "spider",
    "cost": [
      {
        "unittype": "meat",
        "val": 100,
        "factor": 500
      },
      {
        "unittype": "larva",
        "val": 1,
        "factor": 50
      }
    ],
    "effect": [
      {
        "type": "multStat",
        "unittype": "spider",
        "stat": "twin",
        "val": 2
      }
    ]
  },
  {
    "name": "mosquitotwin",
    "l": {
      "description": "Multiple culicimorphs hatch from each larva.",
      "label": "twin culicimorphs",
      "lol": ""
    },
    "class": "upgrade",
    "unittype": "mosquito",
    "cost": [
      {
        "unittype": "meat",
        "val": 100,
        "factor": 500
      },
      {
        "unittype": "larva",
        "val": 1,
        "factor": 50
      }
    ],
    "effect": [
      {
        "type": "multStat",
        "unittype": "mosquito",
        "stat": "twin",
        "val": 2
      }
    ]
  },
  {
    "name": "locusttwin",
    "l": {
      "description": "Multiple locusts hatch from each larva.",
      "label": "twin locusts",
      "lol": ""
    },
    "class": "upgrade",
    "unittype": "locust",
    "cost": [
      {
        "unittype": "meat",
        "val": 100,
        "factor": 500
      },
      {
        "unittype": "larva",
        "val": 1,
        "factor": 50
      }
    ],
    "effect": [
      {
        "type": "multStat",
        "unittype": "locust",
        "stat": "twin",
        "val": 2
      }
    ]
  },
  {
    "name": "roachtwin",
    "l": {
      "description": "Multiple roaches hatch from each larva.",
      "label": "twin roaches",
      "lol": ""
    },
    "class": "upgrade",
    "unittype": "roach",
    "cost": [
      {
        "unittype": "meat",
        "val": 100,
        "factor": 500
      },
      {
        "unittype": "larva",
        "val": 1,
        "factor": 50
      }
    ],
    "effect": [
      {
        "type": "multStat",
        "unittype": "roach",
        "stat": "twin",
        "val": 2
      }
    ]
  },
  {
    "name": "giantspidertwin",
    "l": {
      "description": "Multiple giant arachnomorphs hatch from each larva.",
      "label": "twin giant arachnomorphs",
      "lol": ""
    },
    "class": "upgrade",
    "unittype": "giantspider",
    "cost": [
      {
        "unittype": "meat",
        "val": 100,
        "factor": 500
      },
      {
        "unittype": "larva",
        "val": 1,
        "factor": 50
      }
    ],
    "effect": [
      {
        "type": "multStat",
        "unittype": "giantspider",
        "stat": "twin",
        "val": 2
      }
    ]
  },
  {
    "name": "centipedetwin",
    "l": {
      "description": "Multiple chilopodomorphs hatch from each larva.",
      "label": "twin chilopodomorphs",
      "lol": ""
    },
    "class": "upgrade",
    "unittype": "centipede",
    "cost": [
      {
        "unittype": "meat",
        "val": 100,
        "factor": 500
      },
      {
        "unittype": "larva",
        "val": 1,
        "factor": 50
      }
    ],
    "effect": [
      {
        "type": "multStat",
        "unittype": "centipede",
        "stat": "twin",
        "val": 2
      }
    ]
  },
  {
    "name": "wasptwin",
    "l": {
      "description": "Multiple wasps hatch from each larva.",
      "label": "twin wasps",
      "lol": ""
    },
    "class": "upgrade",
    "unittype": "wasp",
    "cost": [
      {
        "unittype": "meat",
        "val": 100,
        "factor": 500
      },
      {
        "unittype": "larva",
        "val": 1,
        "factor": 50
      }
    ],
    "effect": [
      {
        "type": "multStat",
        "unittype": "wasp",
        "stat": "twin",
        "val": 2
      }
    ]
  },
  {
    "name": "devourertwin",
    "l": {
      "description": "Multiple devourers hatch from each larva.",
      "label": "twin devourers",
      "lol": ""
    },
    "class": "upgrade",
    "unittype": "devourer",
    "cost": [
      {
        "unittype": "meat",
        "val": 100,
        "factor": 500
      },
      {
        "unittype": "larva",
        "val": 1,
        "factor": 50
      }
    ],
    "effect": [
      {
        "type": "multStat",
        "unittype": "devourer",
        "stat": "twin",
        "val": 2
      }
    ]
  },
  {
    "name": "goontwin",
    "l": {
      "description": "Multiple goons hatch from each larva.",
      "label": "twin goons",
      "lol": ""
    },
    "class": "upgrade",
    "unittype": "goon",
    "cost": [
      {
        "unittype": "meat",
        "val": 100,
        "factor": 500
      },
      {
        "unittype": "larva",
        "val": 1,
        "factor": 50
      }
    ],
    "effect": [
      {
        "type": "multStat",
        "unittype": "goon",
        "stat": "twin",
        "val": 2
      }
    ]
  },
  {
    "name": "swarmlingempower",
    "l": {
      "description": "-",
      "label": "empower swarmlings",
      "lol": ""
    },
    "class": "upgrade",
    "unittype": "swarmling",
    "requires": [
      {
        "unittype": "meat",
        "val": 2.5538e+29
      }
    ],
    "cost": [
      {
        "unittype": "meat",
        "val": 1.14921e+32,
        "factor": 1.53228e+29
      }
    ],
    "effect": [
      {
        "type": "compoundUnit",
        "unittype": "swarmling",
        "val": 0
      },
      {
        "type": "multStat",
        "unittype": "swarmling",
        "stat": "prod",
        "val": 1532280000000000000
      },
      {
        "type": "multStat",
        "unittype": "swarmling",
        "stat": "cost.meat",
        "val": 1.53228e+29
      },
      {
        "type": "suffix",
        "unittype": "swarmling"
      }
    ]
  },
  {
    "name": "stingerempower",
    "l": {
      "description": "-",
      "label": "empower stingers",
      "lol": ""
    },
    "class": "upgrade",
    "unittype": "stinger",
    "requires": [
      {
        "unittype": "meat",
        "val": 1.14921e+32
      }
    ],
    "cost": [
      {
        "unittype": "meat",
        "val": 5.17144e+34,
        "factor": 1.53228e+29
      }
    ],
    "effect": [
      {
        "type": "compoundUnit",
        "unittype": "stinger",
        "val": 0
      },
      {
        "type": "multStat",
        "unittype": "stinger",
        "stat": "prod",
        "val": 1532280000000000000
      },
      {
        "type": "multStat",
        "unittype": "stinger",
        "stat": "cost.meat",
        "val": 1.53228e+29
      },
      {
        "type": "suffix",
        "unittype": "stinger"
      }
    ]
  },
  {
    "name": "spiderempower",
    "l": {
      "description": "-",
      "label": "empower arachnomorphs",
      "lol": ""
    },
    "class": "upgrade",
    "unittype": "spider",
    "requires": [
      {
        "unittype": "meat",
        "val": 5.17144e+34
      }
    ],
    "cost": [
      {
        "unittype": "meat",
        "val": 2.32715e+37,
        "factor": 1.53228e+29
      }
    ],
    "effect": [
      {
        "type": "compoundUnit",
        "unittype": "spider",
        "val": 0
      },
      {
        "type": "multStat",
        "unittype": "spider",
        "stat": "prod",
        "val": 1532280000000000000
      },
      {
        "type": "multStat",
        "unittype": "spider",
        "stat": "cost.meat",
        "val": 1.53228e+29
      },
      {
        "type": "suffix",
        "unittype": "spider"
      }
    ]
  },
  {
    "name": "mosquitoempower",
    "l": {
      "description": "-",
      "label": "empower culicimorphs",
      "lol": ""
    },
    "class": "upgrade",
    "unittype": "mosquito",
    "requires": [
      {
        "unittype": "meat",
        "val": 2.32715e+37
      }
    ],
    "cost": [
      {
        "unittype": "meat",
        "val": 1.04722e+40,
        "factor": 1.53228e+29
      }
    ],
    "effect": [
      {
        "type": "compoundUnit",
        "unittype": "mosquito",
        "val": 0
      },
      {
        "type": "multStat",
        "unittype": "mosquito",
        "stat": "prod",
        "val": 1532280000000000000
      },
      {
        "type": "multStat",
        "unittype": "mosquito",
        "stat": "cost.meat",
        "val": 1.53228e+29
      },
      {
        "type": "suffix",
        "unittype": "mosquito"
      }
    ]
  },
  {
    "name": "locustempower",
    "l": {
      "description": "-",
      "label": "empower locusts",
      "lol": ""
    },
    "class": "upgrade",
    "unittype": "locust",
    "requires": [
      {
        "unittype": "meat",
        "val": 1.04722e+40
      }
    ],
    "cost": [
      {
        "unittype": "meat",
        "val": 4.71247e+42,
        "factor": 1.53228e+29
      }
    ],
    "effect": [
      {
        "type": "compoundUnit",
        "unittype": "locust",
        "val": 0
      },
      {
        "type": "multStat",
        "unittype": "locust",
        "stat": "prod",
        "val": 1532280000000000000
      },
      {
        "type": "multStat",
        "unittype": "locust",
        "stat": "cost.meat",
        "val": 1.53228e+29
      },
      {
        "type": "suffix",
        "unittype": "locust"
      }
    ]
  },
  {
    "name": "roachempower",
    "l": {
      "description": "-",
      "label": "empower roaches",
      "lol": ""
    },
    "class": "upgrade",
    "unittype": "roach",
    "requires": [
      {
        "unittype": "meat",
        "val": 4.71247e+42
      }
    ],
    "cost": [
      {
        "unittype": "meat",
        "val": 2.12061e+45,
        "factor": 1.53228e+29
      }
    ],
    "effect": [
      {
        "type": "compoundUnit",
        "unittype": "roach",
        "val": 0
      },
      {
        "type": "multStat",
        "unittype": "roach",
        "stat": "prod",
        "val": 1532280000000000000
      },
      {
        "type": "multStat",
        "unittype": "roach",
        "stat": "cost.meat",
        "val": 1.53228e+29
      },
      {
        "type": "suffix",
        "unittype": "roach"
      }
    ]
  },
  {
    "name": "giantspiderempower",
    "l": {
      "description": "-",
      "label": "empower giant arachnomorphs",
      "lol": ""
    },
    "class": "upgrade",
    "unittype": "giantspider",
    "requires": [
      {
        "unittype": "meat",
        "val": 2.12061e+45
      }
    ],
    "cost": [
      {
        "unittype": "meat",
        "val": 9.54276e+47,
        "factor": 1.53228e+29
      }
    ],
    "effect": [
      {
        "type": "compoundUnit",
        "unittype": "giantspider",
        "val": 0
      },
      {
        "type": "multStat",
        "unittype": "giantspider",
        "stat": "prod",
        "val": 1532280000000000000
      },
      {
        "type": "multStat",
        "unittype": "giantspider",
        "stat": "cost.meat",
        "val": 1.53228e+29
      },
      {
        "type": "suffix",
        "unittype": "giantspider"
      }
    ]
  },
  {
    "name": "centipedeempower",
    "l": {
      "description": "-",
      "label": "empower chilopodomorphs",
      "lol": ""
    },
    "class": "upgrade",
    "unittype": "centipede",
    "requires": [
      {
        "unittype": "meat",
        "val": 9.54276e+47
      }
    ],
    "cost": [
      {
        "unittype": "meat",
        "val": 4.29424e+50,
        "factor": 1.53228e+29
      }
    ],
    "effect": [
      {
        "type": "compoundUnit",
        "unittype": "centipede",
        "val": 0
      },
      {
        "type": "multStat",
        "unittype": "centipede",
        "stat": "prod",
        "val": 1532280000000000000
      },
      {
        "type": "multStat",
        "unittype": "centipede",
        "stat": "cost.meat",
        "val": 1.53228e+29
      },
      {
        "type": "suffix",
        "unittype": "centipede"
      }
    ]
  },
  {
    "name": "waspempower",
    "l": {
      "description": "-",
      "label": "empower wasps",
      "lol": ""
    },
    "class": "upgrade",
    "unittype": "wasp",
    "requires": [
      {
        "unittype": "meat",
        "val": 4.29424e+50
      }
    ],
    "cost": [
      {
        "unittype": "meat",
        "val": 1.93241e+53,
        "factor": 1.53228e+29
      }
    ],
    "effect": [
      {
        "type": "compoundUnit",
        "unittype": "wasp",
        "val": 0
      },
      {
        "type": "multStat",
        "unittype": "wasp",
        "stat": "prod",
        "val": 1532280000000000000
      },
      {
        "type": "multStat",
        "unittype": "wasp",
        "stat": "cost.meat",
        "val": 1.53228e+29
      },
      {
        "type": "suffix",
        "unittype": "wasp"
      }
    ]
  },
  {
    "name": "devourerempower",
    "l": {
      "description": "-",
      "label": "empower devourers",
      "lol": "hey, that rhymes"
    },
    "class": "upgrade",
    "unittype": "devourer",
    "requires": [
      {
        "unittype": "meat",
        "val": 1.93241e+53
      }
    ],
    "cost": [
      {
        "unittype": "meat",
        "val": 8.69584e+55,
        "factor": 1.53228e+29
      }
    ],
    "effect": [
      {
        "type": "compoundUnit",
        "unittype": "devourer",
        "val": 0
      },
      {
        "type": "multStat",
        "unittype": "devourer",
        "stat": "prod",
        "val": 1532280000000000000
      },
      {
        "type": "multStat",
        "unittype": "devourer",
        "stat": "cost.meat",
        "val": 1.53228e+29
      },
      {
        "type": "suffix",
        "unittype": "devourer"
      }
    ]
  },
  {
    "name": "goonempower",
    "l": {
      "description": "-",
      "label": "empower goons",
      "lol": ""
    },
    "class": "upgrade",
    "unittype": "goon",
    "requires": [
      {
        "unittype": "meat",
        "val": 8.69584e+55
      }
    ],
    "cost": [
      {
        "unittype": "meat",
        "val": 3.91313e+58,
        "factor": 1.53228e+29
      }
    ],
    "effect": [
      {
        "type": "compoundUnit",
        "unittype": "goon",
        "val": 0
      },
      {
        "type": "multStat",
        "unittype": "goon",
        "stat": "prod",
        "val": 1532280000000000000
      },
      {
        "type": "multStat",
        "unittype": "goon",
        "stat": "cost.meat",
        "val": 1.53228e+29
      },
      {
        "type": "suffix",
        "unittype": "goon"
      }
    ]
  },
  {
    "name": "nexus1",
    "l": {
      "description": "Build your first nexus, which generates energy and allows you to cast basic spells.",
      "label": "construct nexus",
      "lol": ""
    },
    "class": "upgrade",
    "unittype": "meat",
    "requires": [
      {
        "unittype": "meat",
        "val": 333333333333
      }
    ],
    "cost": [
      {
        "unittype": "meat",
        "val": 3333333333333,
        "factor": 0
      }
    ],
    "effect": [
      {
        "type": "addUnit",
        "unittype": "nexus",
        "val": 1
      },
      {
        "type": "addUnit",
        "unittype": "energy",
        "val": 2000
      }
    ],
    "maxlevel": 1
  },
  {
    "name": "nexus2",
    "l": {
      "description": "Build your second nexus, which generates more energy and unlocks several more special abilities.",
      "label": "construct nexus",
      "lol": ""
    },
    "class": "upgrade",
    "unittype": "nexus",
    "requires": [
      {
        "unittype": "meat",
        "val": 0
      },
      {
        "unittype": "nexus",
        "val": 1
      }
    ],
    "cost": [
      {
        "unittype": "meat",
        "val": 3333330000000000,
        "factor": 0
      },
      {
        "unittype": "energy",
        "val": 625,
        "factor": 0
      }
    ],
    "effect": [
      {
        "type": "addUnit",
        "unittype": "nexus",
        "val": 1
      },
      {
        "type": "addUnit",
        "unittype": "energy",
        "val": 4000
      }
    ],
    "maxlevel": 1
  },
  {
    "name": "nexus3",
    "l": {
      "description": "Build your third nexus, generating even more energy and unlocking more advanced spells.",
      "label": "construct nexus",
      "lol": ""
    },
    "class": "upgrade",
    "unittype": "nexus",
    "requires": [
      {
        "unittype": "meat",
        "val": 0
      },
      {
        "unittype": "nexus",
        "val": 2
      }
    ],
    "cost": [
      {
        "unittype": "meat",
        "val": 3333330000000000000,
        "factor": 0
      },
      {
        "unittype": "energy",
        "val": 2500,
        "factor": 0
      },
      {
        "unittype": "larva",
        "val": 3333333,
        "factor": 0
      }
    ],
    "effect": [
      {
        "type": "addUnit",
        "unittype": "nexus",
        "val": 1
      },
      {
        "type": "addUnit",
        "unittype": "energy",
        "val": 6000
      }
    ],
    "maxlevel": 1
  },
  {
    "name": "nexus4",
    "l": {
      "description": "Build your fourth nexus, generating even more energy and unlocking some of the most advanced spells available to your swarm.",
      "label": "construct nexus",
      "lol": ""
    },
    "class": "upgrade",
    "unittype": "nexus",
    "requires": [
      {
        "unittype": "meat",
        "val": 0
      },
      {
        "unittype": "nexus",
        "val": 3
      }
    ],
    "cost": [
      {
        "unittype": "meat",
        "val": 3.33333e+21,
        "factor": 0
      },
      {
        "unittype": "energy",
        "val": 10000,
        "factor": 0
      },
      {
        "unittype": "larva",
        "val": 33333330,
        "factor": 0
      }
    ],
    "effect": [
      {
        "type": "addUnit",
        "unittype": "nexus",
        "val": 1
      },
      {
        "type": "addUnit",
        "unittype": "energy",
        "val": 8000
      }
    ],
    "maxlevel": 1
  },
  {
    "name": "nexus5",
    "l": {
      "description": "Build your fifth and final nexus. All spells and abilities are unlocked. Your spellcasters cannot channel energy from more than five nexus; this is the limit of their power.",
      "label": "construct nexus",
      "lol": ""
    },
    "class": "upgrade",
    "unittype": "nexus",
    "requires": [
      {
        "unittype": "meat",
        "val": 0
      },
      {
        "unittype": "nexus",
        "val": 4
      }
    ],
    "cost": [
      {
        "unittype": "meat",
        "val": 3.33333e+24,
        "factor": 0
      },
      {
        "unittype": "energy",
        "val": 36000,
        "factor": 0
      },
      {
        "unittype": "larva",
        "val": 3333333000,
        "factor": 0
      }
    ],
    "effect": [
      {
        "type": "addUnit",
        "unittype": "nexus",
        "val": 1
      },
      {
        "type": "addUnit",
        "unittype": "energy",
        "val": 10000
      }
    ],
    "maxlevel": 1
  },
  {
    "name": "larvarush",
    "l": {
      "description": "-",
      "label": "larva rush",
      "lol": ""
    },
    "class": "ability",
    "unittype": "energy",
    "requires": [
      {
        "unittype": "nexus",
        "val": 1
      }
    ],
    "cost": [
      {
        "unittype": "energy",
        "val": 1600,
        "factor": 1
      }
    ],
    "effect": [
      {
        "type": "addUnitByVelocity",
        "unittype": "larva",
        "val": 2400
      },
      {
        "type": "addUnit",
        "unittype": "larva",
        "val": 100000
      }
    ]
  },
  {
    "name": "swarmwarp",
    "l": {
      "description": "-",
      "label": "swarmwarp",
      "lol": ""
    },
    "class": "ability",
    "unittype": "energy",
    "requires": [
      {
        "unittype": "nexus",
        "val": 1
      }
    ],
    "cost": [
      {
        "unittype": "energy",
        "val": 2000,
        "factor": 1
      }
    ],
    "effect": [
      {
        "type": "skipTime",
        "unittype": "",
        "val": 900
      },
      {
        "type": "addUnitByVelocity",
        "unittype": "energy",
        "val": -900
      }
    ]
  },
  {
    "name": "meatrush",
    "l": {
      "description": "-",
      "label": "meat rush",
      "lol": ""
    },
    "class": "ability",
    "unittype": "energy",
    "requires": [
      {
        "unittype": "nexus",
        "val": 2
      }
    ],
    "cost": [
      {
        "unittype": "energy",
        "val": 1600,
        "factor": 1
      }
    ],
    "effect": [
      {
        "type": "addUnitByVelocity",
        "unittype": "meat",
        "val": 7200
      },
      {
        "type": "addUnit",
        "unittype": "meat",
        "val": 100000000000
      }
    ]
  },
  {
    "name": "territoryrush",
    "l": {
      "description": "-",
      "label": "territory rush",
      "lol": ""
    },
    "class": "ability",
    "unittype": "energy",
    "requires": [
      {
        "unittype": "nexus",
        "val": 3
      }
    ],
    "cost": [
      {
        "unittype": "energy",
        "val": 1600,
        "factor": 1
      }
    ],
    "effect": [
      {
        "type": "addUnitByVelocity",
        "unittype": "territory",
        "val": 7200
      },
      {
        "type": "addUnit",
        "unittype": "territory",
        "val": 1000000000
      }
    ]
  },
  {
    "name": "clonelarvae",
    "l": {
      "description": "-",
      "label": "clone larvae",
      "lol": ""
    },
    "class": "ability",
    "unittype": "energy",
    "requires": [
      {
        "unittype": "nexus",
        "val": 4
      }
    ],
    "cost": [
      {
        "unittype": "energy",
        "val": 12000,
        "factor": 1
      }
    ],
    "effect": [
      {
        "type": "compoundUnit",
        "unittype": "larva",
        "val": 2,
        "unittype2": "cocoon",
        "val2": 100000
      }
    ]
  },
  {
    "name": "mutatehidden",
    "l": {
      "description": "",
      "label": "hidden mutation cost tracker",
      "lol": ""
    },
    "class": "ability",
    "unittype": "ascension",
    "requires": [
      {
        "unittype": "invisiblehatchery",
        "val": 2
      }
    ],
    "cost": [
      {
        "unittype": "mutagen",
        "val": 1,
        "factor": 15625
      }
    ]
  },
  {
    "name": "mutatehatchery",
    "l": {
      "description": "",
      "label": "mutate hatcheries",
      "lol": ""
    },
    "class": "upgrade",
    "unittype": "mutagen",
    "requires": [
      {
        "unittype": "ascension",
        "val": 0
      }
    ],
    "cost": [
      {
        "unittype": "mutagen",
        "val": 1,
        "factor": 15625
      }
    ],
    "effect": [
      {
        "type": "addStat",
        "unittype": "mutagen",
        "stat": "upgradecost",
        "val": 1
      },
      {
        "type": "addUpgrade",
        "unittype": "",
        "upgradetype": "mutatehidden",
        "val": 1
      },
      {
        "type": "addUnit",
        "unittype": "mutanthatchery",
        "val": 1
      }
    ],
    "maxlevel": 1
  },
  {
    "name": "mutatebat",
    "l": {
      "description": "",
      "label": "mutate bats",
      "lol": ""
    },
    "class": "upgrade",
    "unittype": "mutagen",
    "requires": [
      {
        "unittype": "ascension",
        "val": 0
      }
    ],
    "cost": [
      {
        "unittype": "mutagen",
        "val": 1,
        "factor": 15625
      }
    ],
    "effect": [
      {
        "type": "addStat",
        "unittype": "mutagen",
        "stat": "upgradecost",
        "val": 1
      },
      {
        "type": "addUpgrade",
        "unittype": "",
        "upgradetype": "mutatehidden",
        "val": 1
      },
      {
        "type": "addUnit",
        "unittype": "mutantbat",
        "val": 1
      }
    ],
    "maxlevel": 1
  },
  {
    "name": "mutateclone",
    "l": {
      "description": "",
      "label": "mutate clones",
      "lol": ""
    },
    "class": "upgrade",
    "unittype": "mutagen",
    "requires": [
      {
        "unittype": "ascension",
        "val": 0
      }
    ],
    "cost": [
      {
        "unittype": "mutagen",
        "val": 1,
        "factor": 15625
      }
    ],
    "effect": [
      {
        "type": "addStat",
        "unittype": "mutagen",
        "stat": "upgradecost",
        "val": 1
      },
      {
        "type": "addUpgrade",
        "unittype": "",
        "upgradetype": "mutatehidden",
        "val": 1
      },
      {
        "type": "addUnit",
        "unittype": "mutantclone",
        "val": 1
      }
    ],
    "maxlevel": 1
  },
  {
    "name": "mutateswarmwarp",
    "l": {
      "description": "",
      "label": "mutate swarmwarps",
      "lol": ""
    },
    "class": "upgrade",
    "unittype": "mutagen",
    "requires": [
      {
        "unittype": "ascension",
        "val": 0
      }
    ],
    "cost": [
      {
        "unittype": "mutagen",
        "val": 1,
        "factor": 15625
      }
    ],
    "effect": [
      {
        "type": "addStat",
        "unittype": "mutagen",
        "stat": "upgradecost",
        "val": 1
      },
      {
        "type": "addUpgrade",
        "unittype": "",
        "upgradetype": "mutatehidden",
        "val": 1
      },
      {
        "type": "addUnit",
        "unittype": "mutantswarmwarp",
        "val": 1
      }
    ],
    "maxlevel": 1
  },
  {
    "name": "mutaterush",
    "l": {
      "description": "",
      "label": "mutate rushes",
      "lol": ""
    },
    "class": "upgrade",
    "unittype": "mutagen",
    "requires": [
      {
        "unittype": "ascension",
        "val": 0
      }
    ],
    "cost": [
      {
        "unittype": "mutagen",
        "val": 1,
        "factor": 15625
      }
    ],
    "effect": [
      {
        "type": "addStat",
        "unittype": "mutagen",
        "stat": "upgradecost",
        "val": 1
      },
      {
        "type": "addUpgrade",
        "unittype": "",
        "upgradetype": "mutatehidden",
        "val": 1
      },
      {
        "type": "addUnit",
        "unittype": "mutantrush",
        "val": 1
      }
    ],
    "maxlevel": 1
  },
  {
    "name": "mutateeach",
    "l": {
      "description": "",
      "label": "meta-mutation",
      "lol": ""
    },
    "class": "upgrade",
    "unittype": "mutagen",
    "requires": [
      {
        "unittype": "ascension",
        "val": 0
      }
    ],
    "cost": [
      {
        "unittype": "mutagen",
        "val": 1,
        "factor": 15625
      }
    ],
    "effect": [
      {
        "type": "addStat",
        "unittype": "mutagen",
        "stat": "upgradecost",
        "val": 1
      },
      {
        "type": "addUpgrade",
        "unittype": "",
        "upgradetype": "mutatehidden",
        "val": 1
      },
      {
        "type": "addUnit",
        "unittype": "mutanteach",
        "val": 1
      }
    ],
    "maxlevel": 1
  },
  {
    "name": "mutatefreq",
    "l": {
      "description": "",
      "label": "mutate frequency",
      "lol": ""
    },
    "class": "upgrade",
    "unittype": "mutagen",
    "requires": [
      {
        "unittype": "ascension",
        "val": 0
      }
    ],
    "cost": [
      {
        "unittype": "mutagen",
        "val": 1,
        "factor": 15625
      }
    ],
    "effect": [
      {
        "type": "addStat",
        "unittype": "mutagen",
        "stat": "upgradecost",
        "val": 1
      },
      {
        "type": "addUpgrade",
        "unittype": "",
        "upgradetype": "mutatehidden",
        "val": 1
      },
      {
        "type": "addUnit",
        "unittype": "mutantfreq",
        "val": 1
      }
    ],
    "maxlevel": 1
  },
  {
    "name": "mutatenexus",
    "l": {
      "description": "",
      "label": "mutate lepidoptera",
      "lol": ""
    },
    "class": "upgrade",
    "unittype": "mutagen",
    "requires": [
      {
        "unittype": "ascension",
        "val": 0
      }
    ],
    "cost": [
      {
        "unittype": "mutagen",
        "val": 1,
        "factor": 15625
      }
    ],
    "effect": [
      {
        "type": "addStat",
        "unittype": "mutagen",
        "stat": "upgradecost",
        "val": 1
      },
      {
        "type": "addUpgrade",
        "unittype": "",
        "upgradetype": "mutatehidden",
        "val": 1
      },
      {
        "type": "addUnit",
        "unittype": "mutantnexus",
        "val": 1
      }
    ],
    "maxlevel": 1
  },
  {
    "name": "mutatearmy",
    "l": {
      "description": "",
      "label": "mutate territory",
      "lol": ""
    },
    "class": "upgrade",
    "unittype": "mutagen",
    "requires": [
      {
        "unittype": "ascension",
        "val": 0
      }
    ],
    "cost": [
      {
        "unittype": "mutagen",
        "val": 1,
        "factor": 15625
      }
    ],
    "effect": [
      {
        "type": "addStat",
        "unittype": "mutagen",
        "stat": "upgradecost",
        "val": 1
      },
      {
        "type": "addUpgrade",
        "unittype": "",
        "upgradetype": "mutatehidden",
        "val": 1
      },
      {
        "type": "addUnit",
        "unittype": "mutantarmy",
        "val": 1
      }
    ],
    "maxlevel": 1
  },
  {
    "name": "mutatemeat",
    "l": {
      "description": "",
      "label": "mutate meat",
      "lol": ""
    },
    "class": "upgrade",
    "unittype": "mutagen",
    "requires": [
      {
        "unittype": "ascension",
        "val": 0
      }
    ],
    "cost": [
      {
        "unittype": "mutagen",
        "val": 1,
        "factor": 15625
      }
    ],
    "effect": [
      {
        "type": "addStat",
        "unittype": "mutagen",
        "stat": "upgradecost",
        "val": 1
      },
      {
        "type": "addUpgrade",
        "unittype": "",
        "upgradetype": "mutatehidden",
        "val": 1
      },
      {
        "type": "addUnit",
        "unittype": "mutantmeat",
        "val": 1
      }
    ],
    "maxlevel": 1
  },
  {
    "name": "clonearmy",
    "l": {
      "description": "-",
      "label": "house of mirrors",
      "lol": ""
    },
    "class": "ability",
    "unittype": "energy",
    "requires": [
      {
        "unittype": "nexus",
        "val": 5
      }
    ],
    "cost": [
      {
        "unittype": "energy",
        "val": 2500,
        "factor": 1
      }
    ],
    "effect": [
      {
        "type": "compoundUnit",
        "unittype": "swarmling",
        "val": 2
      },
      {
        "type": "compoundUnit",
        "unittype": "stinger",
        "val": 2
      },
      {
        "type": "compoundUnit",
        "unittype": "spider",
        "val": 2
      },
      {
        "type": "compoundUnit",
        "unittype": "mosquito",
        "val": 2
      },
      {
        "type": "compoundUnit",
        "unittype": "locust",
        "val": 2
      },
      {
        "type": "compoundUnit",
        "unittype": "roach",
        "val": 2
      },
      {
        "type": "compoundUnit",
        "unittype": "giantspider",
        "val": 2
      },
      {
        "type": "compoundUnit",
        "unittype": "centipede",
        "val": 2
      },
      {
        "type": "compoundUnit",
        "unittype": "wasp",
        "val": 2
      },
      {
        "type": "compoundUnit",
        "unittype": "devourer",
        "val": 2
      },
      {
        "type": "compoundUnit",
        "unittype": "goon",
        "val": 2
      }
    ]
  }
];
export default list;
