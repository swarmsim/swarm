import * as C from "./codec";

const list: C.Unittype[] = [
  {
    "name": "invisiblehatchery",
    "tab": "",
    "l": {
      "description": "Main source of larvae. Everyone starts with one, and no one can buy more. No one knows they have it, because it's invisible.",
      "label": "invisible hatchery",
      "plural": "invisible hatcherytachi",
      "lol": "Stop digging around in the source code, you dirty cheater.",
      "verb": "",
      "verbing": "",
      "verbone": ""
    },
    "prod": [
      {
        "unittype": "larva",
        "val": 1
      }
    ],
    "column": 0,
    "init": 1,
    "disabled": true,
    "unbuyable": true
  },
  {
    "name": "meat",
    "tab": "meat",
    "l": {
      "description": "Meat is delicious. All of your swarm's creatures eat meat.",
      "label": "meat",
      "plural": "meat",
      "lol": "Some kingdoms use meat to craft paste or cars. Meat, meat, it can't be beat~",
      "verb": "gather",
      "verbing": "gathering",
      "verbone": "gathers"
    },
    "requires": [
      {
        "val": 0,
        "unittype": "meat"
      }
    ],
    "column": 0,
    "init": 35,
    "tier": 0,
    "unbuyable": true
  },
  {
    "name": "larva",
    "tab": "larva",
    "l": {
      "description": "The children of your swarm. These young creatures morph into other adult units.",
      "label": "larva",
      "plural": "larvae",
      "lol": "Why not \"larvas\", English?",
      "verb": "uncocoon",
      "verbing": "uncocooning",
      "verbone": "uncocoons"
    },
    "requires": [
      {
        "val": 0,
        "unittype": "meat"
      }
    ],
    "cost": [
      {
        "unittype": "cocoon",
        "val": 1
      }
    ],
    "column": 0,
    "init": 10,
    "showparent": "invisiblehatchery"
  },
  {
    "name": "cocoon",
    "tab": "larva",
    "l": {
      "description": "-",
      "label": "cocoon",
      "plural": "cocoons",
      "lol": "Enemy COCOON used HARDEN!",
      "verb": "cocoon",
      "verbing": "cocooning",
      "verbone": "cocoons"
    },
    "requires": [
      {
        "val": 1,
        "upgrade": "cocooning"
      }
    ],
    "cost": [
      {
        "unittype": "larva",
        "val": 1
      }
    ],
    "column": 0
  },
  {
    "name": "territory",
    "tab": "territory",
    "l": {
      "description": "-",
      "label": "territory",
      "plural": "territory",
      "lol": "",
      "verb": "capture",
      "verbing": "capturing",
      "verbone": "captures"
    },
    "requires": [
      {
        "val": 5,
        "unittype": "queen"
      }
    ],
    "column": 0,
    "unbuyable": true
  },
  {
    "name": "energy",
    "tab": "energy",
    "l": {
      "description": "-",
      "label": "energy",
      "plural": "energy",
      "lol": "",
      "verb": "convert",
      "verbing": "converting",
      "verbone": "converts"
    },
    "requires": [
      {
        "val": 1,
        "unittype": "nexus"
      }
    ],
    "cost": [
      {
        "unittype": "crystal",
        "val": 1
      }
    ],
    "column": 0,
    "isBuyHidden": true
  },
  {
    "name": "respecEnergy",
    "tab": "energy",
    "l": {
      "description": "spent-energy consumed for respecs. affects ascension cost.",
      "label": "respecEnergy",
      "plural": "",
      "lol": "",
      "verb": "",
      "verbing": "",
      "verbone": ""
    },
    "cost": [
      {
        "unittype": "energy",
        "val": -1
      }
    ],
    "disabled": true,
    "unbuyable": true
  },
  {
    "name": "mtxEnergy",
    "tab": "energy",
    "l": {
      "description": "energy bought with microtransactions also permanently increases max energy. Don't wanna worry about hitting the cap.",
      "label": "energy and max energy",
      "plural": "energy and max energy",
      "lol": "",
      "verb": "",
      "verbing": "",
      "verbone": ""
    },
    "effect": [
      {
        "type": "addStat",
        "stat": "capFlat",
        "unittype": "energy",
        "val": 1
      }
    ],
    "disabled": true,
    "unbuyable": true,
    "ascendPreserve": true
  },
  {
    "name": "nexus",
    "tab": "energy",
    "l": {
      "description": "-",
      "label": "nexus",
      "plural": "nexus",
      "lol": "There was a lot more to magic, as Hairy quickly found out, than waving your antennae and saying a few funny words.",
      "verb": "",
      "verbing": "",
      "verbone": ""
    },
    "requires": [
      {
        "val": 1,
        "unittype": "nexus"
      }
    ],
    "prod": [
      {
        "unittype": "energy",
        "val": 0.1
      }
    ],
    "effect": [
      {
        "type": "addStat",
        "stat": "capBase",
        "unittype": "energy",
        "val": 10000
      }
    ],
    "unbuyable": true
  },
  {
    "name": "crystal",
    "tab": "energy",
    "l": {
      "description": "-",
      "label": "crystal",
      "plural": "crystals",
      "lol": "",
      "verb": "",
      "verbing": "",
      "verbone": ""
    },
    "requires": [
      {
        "val": 0,
        "unittype": "meat"
      }
    ],
    "unbuyable": true,
    "ascendPreserve": true
  },
  {
    "name": "mutagen",
    "tab": "mutagen",
    "l": {
      "description": "-",
      "label": "mutagen",
      "plural": "mutagen",
      "lol": "",
      "verb": "",
      "verbing": "",
      "verbone": ""
    },
    "requires": [
      {
        "val": 1,
        "unittype": "mutagen",
        "op": "OR"
      },
      {
        "val": 1,
        "unittype": "premutagen",
        "op": "OR"
      },
      {
        "val": 1,
        "unittype": "ascension",
        "op": "OR"
      },
      {
        "val": 2,
        "unittype": "invisiblehatchery",
        "op": "always false, hack to make OR work"
      }
    ],
    "prod": [
      {
        "unittype": "larva",
        "val": 0.1
      }
    ],
    "unbuyable": true,
    "ascendPreserve": true
  },
  {
    "name": "premutagen",
    "tab": "mutagen",
    "l": {
      "description": "-",
      "label": "mutagen (inactive)",
      "plural": "mutagen (inactive)",
      "lol": "Near comatose, no exercise / Don't tag my toe, I'm still alive",
      "verb": "",
      "verbing": "",
      "verbone": ""
    },
    "requires": [
      {
        "val": 1,
        "unittype": "mutagen",
        "op": "OR"
      },
      {
        "val": 1,
        "unittype": "premutagen",
        "op": "OR"
      },
      {
        "val": 1,
        "unittype": "ascension",
        "op": "OR"
      },
      {
        "val": 2,
        "unittype": "invisiblehatchery",
        "op": "always false, hack to make OR work"
      }
    ],
    "unbuyable": true,
    "ascendPreserve": true
  },
  {
    "name": "ascension",
    "tab": "mutagen",
    "l": {
      "description": "total ascensions",
      "label": "ascension",
      "plural": "ascensions",
      "lol": "",
      "verb": "",
      "verbing": "",
      "verbone": ""
    },
    "disabled": true,
    "unbuyable": true,
    "ascendPreserve": true
  },
  {
    "name": "freeRespec",
    "tab": "mutagen",
    "l": {
      "description": "",
      "label": "",
      "plural": "",
      "lol": "",
      "verb": "",
      "verbing": "",
      "verbone": ""
    },
    "init": 4,
    "disabled": true,
    "unbuyable": true,
    "ascendPreserve": true
  },
  {
    "name": "drone",
    "tab": "meat",
    "l": {
      "description": "Drones are the lowest class of worker in your swarm. They continuously gather meat to feed your swarm.",
      "label": "drone",
      "plural": "drones",
      "lol": "Not to be confused with probes or mules.",
      "verb": "hatch",
      "verbing": "hatching",
      "verbone": "hatches"
    },
    "requires": [
      {
        "val": 0,
        "unittype": "meat"
      }
    ],
    "cost": [
      {
        "unittype": "meat",
        "val": 10
      },
      {
        "unittype": "larva",
        "val": 1
      }
    ],
    "prod": [
      {
        "unittype": "meat",
        "val": 1
      }
    ],
    "column": 1,
    "tier": 1
  },
  {
    "name": "queen",
    "tab": "meat",
    "l": {
      "description": "Queens rule over your swarm's workers.",
      "label": "queen",
      "plural": "queens",
      "lol": "I want to ride my bicycle / I want to ride my bike / I want to ride my bicycle / I want to ride it where I like",
      "verb": "hatch",
      "verbing": "hatching",
      "verbone": "hatches"
    },
    "requires": [
      {
        "val": 1,
        "unittype": "ascension",
        "op": "OR"
      },
      {
        "val": 10,
        "unittype": "drone"
      }
    ],
    "cost": [
      {
        "unittype": "meat",
        "val": 810
      },
      {
        "unittype": "drone",
        "val": 100
      },
      {
        "unittype": "larva",
        "val": 1
      }
    ],
    "prod": [
      {
        "unittype": "drone",
        "val": 2
      }
    ],
    "column": 1,
    "tier": 2
  },
  {
    "name": "nest",
    "tab": "meat",
    "l": {
      "description": "Nests provide space and support for your swarm's queens.",
      "label": "nest",
      "plural": "nests",
      "lol": "They also have fancy temperature controls.",
      "verb": "build",
      "verbing": "building",
      "verbone": "builds"
    },
    "requires": [
      {
        "val": 1,
        "unittype": "ascension",
        "op": "OR"
      },
      {
        "val": 5,
        "unittype": "queen"
      },
      {
        "val": 1,
        "unittype": "territory"
      }
    ],
    "cost": [
      {
        "unittype": "meat",
        "val": 72900
      },
      {
        "unittype": "queen",
        "val": 1000
      },
      {
        "unittype": "larva",
        "val": 1
      }
    ],
    "prod": [
      {
        "unittype": "queen",
        "val": 3
      }
    ],
    "column": 1,
    "tier": 3,
    "warnfirst": {
      "text": "Your first nest will take a long time to regenerate the queens sacrificed to build it. Consider hatching more queens first.",
      "unittype": "queen",
      "val": 2000
    }
  },
  {
    "name": "greaterqueen",
    "tab": "meat",
    "l": {
      "description": "Greater queens rule over the lesser queens of very large swarms.",
      "label": "greater queen",
      "plural": "greater queens",
      "lol": "Can't think of a name? Pick another creature and slap \"greater\" in front of it!",
      "verb": "hatch",
      "verbing": "hatching",
      "verbone": "hatches"
    },
    "requires": [
      {
        "val": 1,
        "unittype": "nest"
      }
    ],
    "cost": [
      {
        "unittype": "meat",
        "val": 6561000
      },
      {
        "unittype": "nest",
        "val": 10000
      },
      {
        "unittype": "larva",
        "val": 1
      }
    ],
    "prod": [
      {
        "unittype": "nest",
        "val": 4
      }
    ],
    "column": 1,
    "tier": 4,
    "warnfirst": {
      "text": "Your first few greater queens will take a long time to regenerate the nests sacrificed to build them. Consider building more nests first.",
      "unittype": "nest",
      "val": 40000
    }
  },
  {
    "name": "hive",
    "tab": "meat",
    "l": {
      "description": "Hives are huge structures crafted from meat and the bodies of thousands of queens. They allow your swarm to grow even faster.",
      "label": "hive",
      "plural": "hives",
      "lol": "Serve the hive. Feel the groove. I control the way you move.",
      "verb": "build",
      "verbing": "building",
      "verbone": "builds"
    },
    "requires": [
      {
        "val": 1,
        "unittype": "greaterqueen"
      }
    ],
    "cost": [
      {
        "unittype": "meat",
        "val": 590490000
      },
      {
        "unittype": "greaterqueen",
        "val": 100000
      },
      {
        "unittype": "larva",
        "val": 1
      }
    ],
    "prod": [
      {
        "unittype": "greaterqueen",
        "val": 5
      }
    ],
    "column": 1,
    "tier": 5,
    "warnfirst": {
      "text": "Your first few hives will take a long time to regenerate the greater queens sacrificed to build them. Consider hatching more greater queens first.",
      "unittype": "greaterqueen",
      "val": 800000
    }
  },
  {
    "name": "hivequeen",
    "tab": "meat",
    "l": {
      "description": "Hive queens oversee the production of hives in the largest swarms.",
      "label": "hive queen",
      "plural": "hive queens",
      "lol": "Managers managing managers managing managers.",
      "verb": "hatch",
      "verbing": "hatching",
      "verbone": "hatches"
    },
    "requires": [
      {
        "val": 1,
        "unittype": "hive"
      }
    ],
    "cost": [
      {
        "unittype": "meat",
        "val": 53144100000
      },
      {
        "unittype": "hive",
        "val": 1000000
      },
      {
        "unittype": "larva",
        "val": 1
      }
    ],
    "prod": [
      {
        "unittype": "hive",
        "val": 6
      }
    ],
    "column": 1,
    "tier": 6,
    "warnfirst": {
      "text": "Your first few hive queens will take a long time to regenerate the hives sacrificed to build them. Consider building more hives first.",
      "unittype": "hive",
      "val": 4000000
    }
  },
  {
    "name": "empress",
    "tab": "meat",
    "l": {
      "description": "The mightiest creature to rule over your swarm so far.",
      "label": "hive empress",
      "plural": "hive empresses",
      "lol": "On her thorax and on her forewing she has this name written: queen of queens and lady of ladies.",
      "verb": "grow",
      "verbing": "growing",
      "verbone": "grows"
    },
    "requires": [
      {
        "val": 1,
        "unittype": "hivequeen"
      }
    ],
    "cost": [
      {
        "unittype": "meat",
        "val": 4782969000000
      },
      {
        "unittype": "hivequeen",
        "val": 10000000
      },
      {
        "unittype": "larva",
        "val": 1
      }
    ],
    "prod": [
      {
        "unittype": "hivequeen",
        "val": 7
      }
    ],
    "column": 1,
    "tier": 7
  },
  {
    "name": "prophet",
    "tab": "meat",
    "l": {
      "description": "Your prophets foresee the guidance of a higher power, a greater being - yet, the heavens have fallen silent.",
      "label": "neuroprophet",
      "plural": "neuroprophets",
      "lol": "Heavens and goddesses and pantheons never really made much sense for a swarm, did they?",
      "verb": "grow",
      "verbing": "growing",
      "verbone": "grows"
    },
    "requires": [
      {
        "val": 1,
        "unittype": "empress"
      }
    ],
    "cost": [
      {
        "unittype": "meat",
        "val": 430467210000000
      },
      {
        "unittype": "empress",
        "val": 100000000
      },
      {
        "unittype": "larva",
        "val": 1
      }
    ],
    "prod": [
      {
        "unittype": "empress",
        "val": 8
      }
    ],
    "column": 1,
    "tier": 8
  },
  {
    "name": "goddess",
    "tab": "meat",
    "l": {
      "description": "Neurons are the building blocks of a greater hive intelligence.",
      "label": "hive neuron",
      "plural": "hive neurons",
      "lol": "Thanks, Neuronerd. Miss you.",
      "verb": "grow",
      "verbing": "growing",
      "verbone": "grows"
    },
    "requires": [
      {
        "val": 1,
        "unittype": "prophet"
      }
    ],
    "cost": [
      {
        "unittype": "meat",
        "val": 38742000000000000
      },
      {
        "unittype": "prophet",
        "val": 1000000000
      },
      {
        "unittype": "larva",
        "val": 1
      }
    ],
    "prod": [
      {
        "unittype": "prophet",
        "val": 9
      }
    ],
    "column": 1,
    "tier": 9
  },
  {
    "name": "pantheon",
    "tab": "meat",
    "l": {
      "description": "Groups of neurons begin to exert mild psychic powers, influencing the minds of lesser creatures in your swarm.",
      "label": "neural cluster",
      "plural": "neural clusters",
      "lol": "Their trick for avoiding cluster headaches is to avoid having a head.",
      "verb": "grow",
      "verbing": "growing",
      "verbone": "grows"
    },
    "requires": [
      {
        "val": 1,
        "unittype": "goddess"
      }
    ],
    "cost": [
      {
        "unittype": "meat",
        "val": 3486780000000000000
      },
      {
        "unittype": "goddess",
        "val": 10000000000
      },
      {
        "unittype": "larva",
        "val": 1
      }
    ],
    "prod": [
      {
        "unittype": "goddess",
        "val": 10
      }
    ],
    "column": 1,
    "tier": 10
  },
  {
    "name": "pantheon2",
    "tab": "meat",
    "l": {
      "description": "Networking your hive's neurons allows them to coordinate their actions, much as a single entity would.",
      "label": "hive network",
      "plural": "hive networks",
      "lol": "Networks also allow them to play games and watch videos of ...uh, cats.",
      "verb": "grow",
      "verbing": "growing",
      "verbone": "grows"
    },
    "requires": [
      {
        "val": 1,
        "unittype": "pantheon"
      }
    ],
    "cost": [
      {
        "unittype": "meat",
        "val": 313811000000000000000
      },
      {
        "unittype": "pantheon",
        "val": 1000000000000
      },
      {
        "unittype": "larva",
        "val": 1
      }
    ],
    "prod": [
      {
        "unittype": "pantheon",
        "val": 11
      }
    ],
    "column": 1,
    "tier": 11
  },
  {
    "name": "pantheon3",
    "tab": "meat",
    "l": {
      "description": "Your neural networks have finally formed a single greater intelligence, primitive though it may be. The psychic powers of lesser hive minds are great enough to directly control several hundred lesser members of your swarm.",
      "label": "lesser hive mind",
      "plural": "lesser hive minds",
      "lol": "Hey, \"lesser\" works just as well as \"greater\" for naming things!",
      "verb": "grow",
      "verbing": "growing",
      "verbone": "grows"
    },
    "requires": [
      {
        "val": 1,
        "unittype": "pantheon2"
      }
    ],
    "cost": [
      {
        "unittype": "meat",
        "val": 2.8243e+22
      },
      {
        "unittype": "pantheon2",
        "val": 100000000000000
      },
      {
        "unittype": "larva",
        "val": 1
      }
    ],
    "prod": [
      {
        "unittype": "pantheon2",
        "val": 12
      }
    ],
    "column": 1,
    "tier": 12
  },
  {
    "name": "pantheon4",
    "tab": "meat",
    "l": {
      "description": "Mature hive minds control thousands of lesser members of your swarm, and their capacity for intelligent planning is dramatically improved.",
      "label": "hive mind",
      "plural": "hive minds",
      "lol": "Do hive minds have hives on their minds? Sounds painful.",
      "verb": "grow",
      "verbing": "growing",
      "verbone": "grows"
    },
    "requires": [
      {
        "val": 1,
        "unittype": "pantheon3"
      }
    ],
    "cost": [
      {
        "unittype": "meat",
        "val": 2.54187e+24
      },
      {
        "unittype": "pantheon3",
        "val": 10000000000000000
      },
      {
        "unittype": "larva",
        "val": 1
      }
    ],
    "prod": [
      {
        "unittype": "pantheon3",
        "val": 13
      }
    ],
    "column": 1,
    "tier": 13
  },
  {
    "name": "pantheon5",
    "tab": "meat",
    "l": {
      "description": "Multiple hive minds merge their collective consciousness into a single greater being.",
      "label": "arch-mind",
      "plural": "arch-minds",
      "lol": "By your powers combined...",
      "verb": "grow",
      "verbing": "growing",
      "verbone": "grows"
    },
    "requires": [
      {
        "val": 1,
        "unittype": "pantheon4"
      }
    ],
    "cost": [
      {
        "unittype": "meat",
        "val": 2.28768e+26
      },
      {
        "unittype": "pantheon4",
        "val": 10000000000000000000
      },
      {
        "unittype": "larva",
        "val": 1
      }
    ],
    "prod": [
      {
        "unittype": "pantheon4",
        "val": 14
      }
    ],
    "column": 1,
    "tier": 14
  },
  {
    "name": "overmind",
    "tab": "meat",
    "l": {
      "description": "The Overmind psychically controls the actions of every member of your swarm, including all of the lesser hive minds. Building more physical manifestations of the Overmind merely increases its influence; all belong to the same being, the same greater intelligence. Your swarm now exists to serve the will of its Overmind.",
      "label": "overmind",
      "plural": "overminds",
      "lol": "SO much cooler than that infested human, even if she did win.",
      "verb": "grow",
      "verbing": "growing",
      "verbone": "grows"
    },
    "requires": [
      {
        "val": 1,
        "unittype": "pantheon5"
      }
    ],
    "cost": [
      {
        "unittype": "meat",
        "val": 2.05891e+28
      },
      {
        "unittype": "pantheon5",
        "val": 1e+23
      },
      {
        "unittype": "larva",
        "val": 1
      }
    ],
    "prod": [
      {
        "unittype": "pantheon5",
        "val": 15
      }
    ],
    "column": 1,
    "tier": 15
  },
  {
    "name": "overmind2",
    "tab": "meat",
    "l": {
      "description": "Eternity lies ahead of us, and behind. Have you drunk your fill?",
      "label": "overmind II",
      "plural": "overmind IIs",
      "lol": "And here's where I ran out of ideas.",
      "verb": "grow",
      "verbing": "growing",
      "verbone": "grows"
    },
    "requires": [
      {
        "val": 1,
        "unittype": "overmind"
      }
    ],
    "cost": [
      {
        "unittype": "meat",
        "val": 1.85302e+30
      },
      {
        "unittype": "overmind",
        "val": 1e+28
      },
      {
        "unittype": "larva",
        "val": 1
      }
    ],
    "prod": [
      {
        "unittype": "overmind",
        "val": 16
      }
    ],
    "column": 1,
    "tier": 16
  },
  {
    "name": "overmind3",
    "tab": "meat",
    "l": {
      "description": "Eternity lies ahead of us, and behind. Have you drunk your fill?",
      "label": "overmind III",
      "plural": "overmind IIIs",
      "lol": "And here's where I ran out of ideas.",
      "verb": "grow",
      "verbing": "growing",
      "verbone": "grows"
    },
    "requires": [
      {
        "val": 1,
        "unittype": "overmind2"
      }
    ],
    "cost": [
      {
        "unittype": "meat",
        "val": 1.66772e+32
      },
      {
        "unittype": "overmind2",
        "val": 1e+34
      },
      {
        "unittype": "larva",
        "val": 1
      }
    ],
    "prod": [
      {
        "unittype": "overmind2",
        "val": 17
      }
    ],
    "column": 1,
    "tier": 17
  },
  {
    "name": "overmind4",
    "tab": "meat",
    "l": {
      "description": "Eternity lies ahead of us, and behind. Have you drunk your fill?",
      "label": "overmind IV",
      "plural": "overmind IVs",
      "lol": "And here's where I ran out of ideas.",
      "verb": "grow",
      "verbing": "growing",
      "verbone": "grows"
    },
    "requires": [
      {
        "val": 1,
        "unittype": "overmind3"
      }
    ],
    "cost": [
      {
        "unittype": "meat",
        "val": 1.50095e+34
      },
      {
        "unittype": "overmind3",
        "val": 1e+41
      },
      {
        "unittype": "larva",
        "val": 1
      }
    ],
    "prod": [
      {
        "unittype": "overmind3",
        "val": 18
      }
    ],
    "column": 1,
    "tier": 18
  },
  {
    "name": "overmind5",
    "tab": "meat",
    "l": {
      "description": "Eternity lies ahead of us, and behind. Have you drunk your fill?",
      "label": "overmind V",
      "plural": "overmind Vs",
      "lol": "And here's where I ran out of ideas.",
      "verb": "grow",
      "verbing": "growing",
      "verbone": "grows"
    },
    "requires": [
      {
        "val": 1,
        "unittype": "overmind4"
      }
    ],
    "cost": [
      {
        "unittype": "meat",
        "val": 1.35085e+36
      },
      {
        "unittype": "overmind4",
        "val": 1e+49
      },
      {
        "unittype": "larva",
        "val": 1
      }
    ],
    "prod": [
      {
        "unittype": "overmind4",
        "val": 19
      }
    ],
    "column": 1,
    "tier": 19
  },
  {
    "name": "overmind6",
    "tab": "meat",
    "l": {
      "description": "Eternity lies ahead of us, and behind. Have you drunk your fill?",
      "label": "overmind VI",
      "plural": "overmind VIs",
      "lol": "And here's where I ran out of ideas.",
      "verb": "grow",
      "verbing": "growing",
      "verbone": "grows"
    },
    "requires": [
      {
        "val": 1,
        "unittype": "overmind5"
      }
    ],
    "cost": [
      {
        "unittype": "meat",
        "val": 1.21577e+38
      },
      {
        "unittype": "overmind5",
        "val": 1e+58
      },
      {
        "unittype": "larva",
        "val": 1
      }
    ],
    "prod": [
      {
        "unittype": "overmind5",
        "val": 20
      }
    ],
    "column": 1,
    "tier": 20
  },
  {
    "name": "swarmling",
    "tab": "territory",
    "l": {
      "description": "Your swarm's smallest and weakest warriors. They use their teeth and claws to attack foes, and can be vicious in large numbers.",
      "label": "swarmling",
      "plural": "swarmlings",
      "lol": "Groups of six at the wrong time are pretty vicious too.",
      "verb": "hatch",
      "verbing": "hatching",
      "verbone": "hatches"
    },
    "requires": [
      {
        "val": 225,
        "unittype": "meat"
      },
      {
        "val": 5,
        "unittype": "queen"
      }
    ],
    "cost": [
      {
        "unittype": "meat",
        "val": 750
      },
      {
        "unittype": "larva",
        "val": 1
      }
    ],
    "prod": [
      {
        "unittype": "territory",
        "val": 0.07
      }
    ],
    "column": 2,
    "tier": 1
  },
  {
    "name": "stinger",
    "tab": "territory",
    "l": {
      "description": "Weak flying warriors. They roam in packs, attacking any threats with venomous stingers.",
      "label": "stinger",
      "plural": "stingers",
      "lol": "Reasonably smart critters - they consistently earn a 3.0 GPA.",
      "verb": "hatch",
      "verbing": "hatching",
      "verbone": "hatches"
    },
    "requires": [
      {
        "val": 101250,
        "unittype": "meat"
      },
      {
        "val": 5,
        "unittype": "queen"
      }
    ],
    "cost": [
      {
        "unittype": "meat",
        "val": 337500
      },
      {
        "unittype": "larva",
        "val": 1
      }
    ],
    "prod": [
      {
        "unittype": "territory",
        "val": 3.15
      }
    ],
    "column": 2,
    "tier": 2
  },
  {
    "name": "spider",
    "tab": "territory",
    "l": {
      "description": "Terrifying eight-legged beasts who leap upon their prey, ensnare it in sticky traps, and finally liquify it into a delicious beverage.",
      "label": "arachnomorph",
      "plural": "arachnomorphs",
      "lol": "Four legs good. Eight legs better.",
      "verb": "hatch",
      "verbing": "hatching",
      "verbone": "hatches"
    },
    "requires": [
      {
        "val": 45562500,
        "unittype": "meat"
      },
      {
        "val": 5,
        "unittype": "queen"
      }
    ],
    "cost": [
      {
        "unittype": "meat",
        "val": 151875000
      },
      {
        "unittype": "larva",
        "val": 1
      }
    ],
    "prod": [
      {
        "unittype": "territory",
        "val": 141.75
      }
    ],
    "column": 2,
    "tier": 3
  },
  {
    "name": "mosquito",
    "tab": "territory",
    "l": {
      "description": "These hated creatures feast on the blood of their victims, and spread disease to larger prey they cannot kill outright.",
      "label": "culicimorph",
      "plural": "culicimorphs",
      "lol": "These guys really suck.",
      "verb": "hatch",
      "verbing": "hatching",
      "verbone": "hatches"
    },
    "requires": [
      {
        "val": 20503125000,
        "unittype": "meat"
      },
      {
        "val": 5,
        "unittype": "queen"
      }
    ],
    "cost": [
      {
        "unittype": "meat",
        "val": 68343750000
      },
      {
        "unittype": "larva",
        "val": 1
      }
    ],
    "prod": [
      {
        "unittype": "territory",
        "val": 6378.75
      }
    ],
    "column": 2,
    "tier": 4
  },
  {
    "name": "locust",
    "tab": "territory",
    "l": {
      "description": "Groups of hungry locusts devour any creature that makes the mistake of standing in their way.",
      "label": "locust",
      "plural": "locusts",
      "lol": "Preceded by fiery hail, followed by darkness.",
      "verb": "hatch",
      "verbing": "hatching",
      "verbone": "hatches"
    },
    "requires": [
      {
        "val": 9226406250000,
        "unittype": "meat"
      },
      {
        "val": 5,
        "unittype": "queen"
      }
    ],
    "cost": [
      {
        "unittype": "meat",
        "val": 30754687500000
      },
      {
        "unittype": "larva",
        "val": 1
      }
    ],
    "prod": [
      {
        "unittype": "territory",
        "val": 287043.75
      }
    ],
    "column": 2,
    "tier": 5
  },
  {
    "name": "roach",
    "tab": "territory",
    "l": {
      "description": "The hard shell of the roach makes it a fearsome opponent; it is nearly impossible to kill.",
      "label": "roach",
      "plural": "roaches",
      "lol": "ROOSTERS.",
      "verb": "hatch",
      "verbing": "hatching",
      "verbone": "hatches"
    },
    "requires": [
      {
        "val": 4151880000000000,
        "unittype": "meat"
      },
      {
        "val": 5,
        "unittype": "queen"
      }
    ],
    "cost": [
      {
        "unittype": "meat",
        "val": 13839600000000000
      },
      {
        "unittype": "larva",
        "val": 1
      }
    ],
    "prod": [
      {
        "unittype": "territory",
        "val": 12916968.75
      }
    ],
    "column": 2,
    "tier": 6
  },
  {
    "name": "giantspider",
    "tab": "territory",
    "l": {
      "description": "The larger, and more fearsome, cousin of the arachnomorph.",
      "label": "giant arachnomorph",
      "plural": "giant arachnomorphs",
      "lol": "Rest assured that you do not swallow eight of these per year while sleeping.",
      "verb": "hatch",
      "verbing": "hatching",
      "verbone": "hatches"
    },
    "requires": [
      {
        "val": 1868350000000000000,
        "unittype": "meat"
      },
      {
        "val": 5,
        "unittype": "queen"
      }
    ],
    "cost": [
      {
        "unittype": "meat",
        "val": 6227820000000000000
      },
      {
        "unittype": "larva",
        "val": 1
      }
    ],
    "prod": [
      {
        "unittype": "territory",
        "val": 581263593.8
      }
    ],
    "column": 2,
    "tier": 7
  },
  {
    "name": "centipede",
    "tab": "territory",
    "l": {
      "description": "Swift wormlike creatures with hundreds of legs and an extremely venomous bite.",
      "label": "chilopodomorph",
      "plural": "chilopodomorphs",
      "lol": "Hi Mom!",
      "verb": "hatch",
      "verbing": "hatching",
      "verbone": "hatches"
    },
    "requires": [
      {
        "val": 840756000000000000000,
        "unittype": "meat"
      },
      {
        "val": 5,
        "unittype": "queen"
      }
    ],
    "cost": [
      {
        "unittype": "meat",
        "val": 2.80252e+21
      },
      {
        "unittype": "larva",
        "val": 1
      }
    ],
    "prod": [
      {
        "unittype": "territory",
        "val": 26156861719
      }
    ],
    "column": 2,
    "tier": 8
  },
  {
    "name": "wasp",
    "tab": "territory",
    "l": {
      "description": "An advanced cousin of the stinger, wasps are far more aggressive and much better hunters.",
      "label": "wasp",
      "plural": "wasps",
      "lol": "I can't beelieve you're actually reading this.",
      "verb": "hatch",
      "verbing": "hatching",
      "verbone": "hatches"
    },
    "requires": [
      {
        "val": 3.7834e+23,
        "unittype": "meat"
      },
      {
        "val": 5,
        "unittype": "queen"
      }
    ],
    "cost": [
      {
        "unittype": "meat",
        "val": 1.26113e+24
      },
      {
        "unittype": "larva",
        "val": 1
      }
    ],
    "prod": [
      {
        "unittype": "territory",
        "val": 1177058777344
      }
    ],
    "column": 2,
    "tier": 9
  },
  {
    "name": "devourer",
    "tab": "territory",
    "l": {
      "description": "Huge burrowing worms, devourers appear from beneath the earth to swallow their prey before it can react.",
      "label": "devourer",
      "plural": "devourers",
      "lol": "Extra fun in hardcore leagues and fractured maps.",
      "verb": "hatch",
      "verbing": "hatching",
      "verbone": "hatches"
    },
    "requires": [
      {
        "val": 1.70253e+26,
        "unittype": "meat"
      },
      {
        "val": 5,
        "unittype": "queen"
      }
    ],
    "cost": [
      {
        "unittype": "meat",
        "val": 5.6751e+26
      },
      {
        "unittype": "larva",
        "val": 1
      }
    ],
    "prod": [
      {
        "unittype": "territory",
        "val": 52967644980469
      }
    ],
    "column": 2,
    "tier": 10
  },
  {
    "name": "goon",
    "tab": "territory",
    "l": {
      "description": "Goons cannot fly on their own, but instead use metal to construct powerful flying exoskeletons that rule the skies.",
      "label": "goon",
      "plural": "goons",
      "lol": "They like spreadsheets too.",
      "verb": "hatch",
      "verbing": "hatching",
      "verbone": "hatches"
    },
    "requires": [
      {
        "val": 7.66139e+28,
        "unittype": "meat"
      },
      {
        "val": 5,
        "unittype": "queen"
      }
    ],
    "cost": [
      {
        "unittype": "meat",
        "val": 2.5538e+29
      },
      {
        "unittype": "larva",
        "val": 1
      }
    ],
    "prod": [
      {
        "unittype": "territory",
        "val": 2383540000000000
      }
    ],
    "column": 2,
    "tier": 11
  },
  {
    "name": "nightbug",
    "tab": "energy",
    "l": {
      "description": "-",
      "label": "nightbug",
      "plural": "nightbugs",
      "lol": "Often seen in the company of an ice fairy, a singing sparrow, and a ball of darkness.",
      "verb": "hatch",
      "verbing": "hatching",
      "verbone": "hatches"
    },
    "requires": [
      {
        "val": 3,
        "unittype": "nexus"
      }
    ],
    "cost": [
      {
        "unittype": "energy",
        "val": 10
      },
      {
        "unittype": "larva",
        "val": 1
      }
    ],
    "effect": [
      {
        "type": "asympStat",
        "stat": "capMult",
        "unittype": "energy",
        "val": 6,
        "val2": 0.001
      }
    ]
  },
  {
    "name": "moth",
    "tab": "energy",
    "l": {
      "description": "-",
      "label": "lepidoptera",
      "plural": "lepidoptera",
      "lol": "on the one ton temple bell / a moon-moth, folded into sleep, / sits still.",
      "verb": "hatch",
      "verbing": "hatching",
      "verbone": "hatches"
    },
    "requires": [
      {
        "val": 4,
        "unittype": "nexus"
      }
    ],
    "cost": [
      {
        "unittype": "energy",
        "val": 10
      },
      {
        "unittype": "larva",
        "val": 1
      }
    ],
    "effect": [
      {
        "type": "asympStat",
        "stat": "prod",
        "unittype": "nexus",
        "val": 2,
        "val2": 0.001
      }
    ]
  },
  {
    "name": "bat",
    "tab": "energy",
    "l": {
      "description": "-",
      "label": "bat",
      "plural": "bats",
      "lol": "\"Bats aren't bugs!!\" \"Look, who's giving this report? You chowderheads... or me?!\"",
      "verb": "raise",
      "verbing": "raising",
      "verbone": "raises"
    },
    "requires": [
      {
        "val": 5,
        "unittype": "nexus"
      }
    ],
    "cost": [
      {
        "unittype": "energy",
        "val": 100
      },
      {
        "unittype": "larva",
        "val": 1
      }
    ],
    "effect": [
      {
        "type": "asympStat",
        "stat": "power",
        "unittype": "energy",
        "val": 1.6,
        "val2": 0.001
      }
    ]
  },
  {
    "name": "mutanthatchery",
    "tab": "mutagen",
    "l": {
      "description": "-",
      "label": "hatchery mutation",
      "plural": "hatchery mutations",
      "lol": "",
      "verb": "mutate",
      "verbing": "mutating",
      "verbone": "mutates"
    },
    "requires": [
      {
        "val": 1,
        "upgrade": "mutatehatchery"
      }
    ],
    "cost": [
      {
        "unittype": "mutagen",
        "val": 1
      }
    ],
    "effect": [
      {
        "type": "logStat",
        "stat": "prod",
        "unittype": "invisiblehatchery",
        "val": 1,
        "val2": 10,
        "val3": 1
      }
    ],
    "ascendPreserve": true
  },
  {
    "name": "mutantbat",
    "tab": "mutagen",
    "l": {
      "description": "-",
      "label": "bat mutation",
      "plural": "bat mutations",
      "lol": "",
      "verb": "mutate",
      "verbing": "mutating",
      "verbone": "mutates"
    },
    "requires": [
      {
        "val": 1,
        "upgrade": "mutatebat"
      }
    ],
    "cost": [
      {
        "unittype": "mutagen",
        "val": 1
      }
    ],
    "effect": [
      {
        "type": "logStat",
        "stat": "power",
        "unittype": "energy",
        "val": 0.1,
        "val2": 10,
        "val3": 1
      }
    ],
    "ascendPreserve": true
  },
  {
    "name": "mutantclone",
    "tab": "mutagen",
    "l": {
      "description": "-",
      "label": "clone mutation",
      "plural": "clone mutations",
      "lol": "",
      "verb": "mutate",
      "verbing": "mutating",
      "verbone": "mutates"
    },
    "requires": [
      {
        "val": 1,
        "upgrade": "mutateclone"
      }
    ],
    "cost": [
      {
        "unittype": "mutagen",
        "val": 1
      }
    ],
    "effect": [
      {
        "type": "logStat",
        "stat": "power.clonelarvae",
        "unittype": "energy",
        "val": 1,
        "val2": 10,
        "val3": 1.8
      }
    ],
    "ascendPreserve": true
  },
  {
    "name": "mutantswarmwarp",
    "tab": "mutagen",
    "l": {
      "description": "-",
      "label": "warp mutation",
      "plural": "warp mutations",
      "lol": "",
      "verb": "mutate",
      "verbing": "mutating",
      "verbone": "mutates"
    },
    "requires": [
      {
        "val": 1,
        "upgrade": "mutateswarmwarp"
      }
    ],
    "cost": [
      {
        "unittype": "mutagen",
        "val": 1
      }
    ],
    "effect": [
      {
        "type": "logStat",
        "stat": "power.swarmwarp",
        "unittype": "energy",
        "val": 1,
        "val2": 10,
        "val3": 2
      }
    ],
    "ascendPreserve": true
  },
  {
    "name": "mutantrush",
    "tab": "mutagen",
    "l": {
      "description": "-",
      "label": "rush mutation",
      "plural": "rush mutations",
      "lol": "",
      "verb": "mutate",
      "verbing": "mutating",
      "verbone": "mutates"
    },
    "requires": [
      {
        "val": 1,
        "upgrade": "mutaterush"
      }
    ],
    "cost": [
      {
        "unittype": "mutagen",
        "val": 1
      }
    ],
    "effect": [
      {
        "type": "logStat",
        "stat": "power.larvarush",
        "unittype": "energy",
        "val": 1,
        "val2": 10,
        "val3": 3
      },
      {
        "type": "logStat",
        "stat": "power.meatrush",
        "unittype": "energy",
        "val": 1,
        "val2": 10,
        "val3": 13
      },
      {
        "type": "logStat",
        "stat": "power.territoryrush",
        "unittype": "energy",
        "val": 1,
        "val2": 10,
        "val3": 13
      }
    ],
    "ascendPreserve": true
  },
  {
    "name": "mutanteach",
    "tab": "mutagen",
    "l": {
      "description": "-",
      "label": "meta-mutation",
      "plural": "meta-mutations",
      "lol": "",
      "verb": "mutate",
      "verbing": "mutating",
      "verbone": "mutates"
    },
    "requires": [
      {
        "val": 1,
        "upgrade": "mutateeach"
      }
    ],
    "cost": [
      {
        "unittype": "mutagen",
        "val": 1
      }
    ],
    "effect": [
      {
        "type": "logStat",
        "stat": "random.each",
        "unittype": "invisiblehatchery",
        "val": 0.1,
        "val2": 10,
        "val3": 0.5
      },
      {
        "type": "initStat",
        "stat": "random.minlevel.hatchery",
        "unittype": "invisiblehatchery",
        "val": 40
      },
      {
        "type": "initStat",
        "stat": "random.minlevel.expansion",
        "unittype": "invisiblehatchery",
        "val": 80
      }
    ],
    "ascendPreserve": true
  },
  {
    "name": "mutantfreq",
    "tab": "mutagen",
    "l": {
      "description": "-",
      "label": "mutation frequency",
      "plural": "mutation frequency",
      "lol": "Savescumming won't work, by the way.",
      "verb": "mutate",
      "verbing": "mutating",
      "verbone": "mutates"
    },
    "requires": [
      {
        "val": 1,
        "upgrade": "mutatefreq"
      }
    ],
    "cost": [
      {
        "unittype": "mutagen",
        "val": 1
      }
    ],
    "effect": [
      {
        "type": "asympStat",
        "stat": "random.freq",
        "unittype": "invisiblehatchery",
        "val": 5,
        "val2": 0.001,
        "val3": 5
      },
      {
        "type": "initStat",
        "stat": "random.freq",
        "unittype": "invisiblehatchery",
        "val": 0.2
      }
    ],
    "ascendPreserve": true
  },
  {
    "name": "mutantnexus",
    "tab": "mutagen",
    "l": {
      "description": "-",
      "label": "lepidoptera mutation",
      "plural": "lepidoptera mutations",
      "lol": "",
      "verb": "mutate",
      "verbing": "mutating",
      "verbone": "mutates"
    },
    "requires": [
      {
        "val": 1,
        "upgrade": "mutatenexus"
      }
    ],
    "cost": [
      {
        "unittype": "mutagen",
        "val": 1
      }
    ],
    "effect": [
      {
        "type": "asympStat",
        "stat": "prod",
        "unittype": "nexus",
        "val": 2,
        "val2": 0.0005,
        "val3": 5
      },
      {
        "type": "asympStat",
        "stat": "capMult",
        "unittype": "energy",
        "val": 2,
        "val2": 0.0005,
        "val3": 5
      },
      {
        "type": "asympStat",
        "stat": "ascendCost",
        "unittype": "mutagen",
        "val": 1.6,
        "val2": 0.0005,
        "val3": 5
      }
    ],
    "ascendPreserve": true
  },
  {
    "name": "mutantarmy",
    "tab": "mutagen",
    "l": {
      "description": "-",
      "label": "territory mutation",
      "plural": "territory mutations",
      "lol": "",
      "verb": "mutate",
      "verbing": "mutating",
      "verbone": "mutates"
    },
    "requires": [
      {
        "val": 1,
        "upgrade": "mutatearmy"
      }
    ],
    "cost": [
      {
        "unittype": "mutagen",
        "val": 1
      }
    ],
    "effect": [
      {
        "type": "expStat",
        "stat": "prod",
        "unittype": "swarmling",
        "val": 0.2,
        "val2": 0.001
      },
      {
        "type": "expStat",
        "stat": "prod",
        "unittype": "stinger",
        "val": 0.2,
        "val2": 0.001
      },
      {
        "type": "expStat",
        "stat": "prod",
        "unittype": "spider",
        "val": 0.2,
        "val2": 0.001
      },
      {
        "type": "expStat",
        "stat": "prod",
        "unittype": "mosquito",
        "val": 0.2,
        "val2": 0.001
      },
      {
        "type": "expStat",
        "stat": "prod",
        "unittype": "locust",
        "val": 0.2,
        "val2": 0.001
      },
      {
        "type": "expStat",
        "stat": "prod",
        "unittype": "roach",
        "val": 0.2,
        "val2": 0.001
      },
      {
        "type": "expStat",
        "stat": "prod",
        "unittype": "giantspider",
        "val": 0.2,
        "val2": 0.001
      },
      {
        "type": "expStat",
        "stat": "prod",
        "unittype": "centipede",
        "val": 0.2,
        "val2": 0.001
      },
      {
        "type": "expStat",
        "stat": "prod",
        "unittype": "wasp",
        "val": 0.2,
        "val2": 0.001
      },
      {
        "type": "expStat",
        "stat": "prod",
        "unittype": "devourer",
        "val": 0.2,
        "val2": 0.001
      },
      {
        "type": "expStat",
        "stat": "prod",
        "unittype": "goon",
        "val": 0.2,
        "val2": 0.001
      }
    ],
    "ascendPreserve": true
  },
  {
    "name": "mutantmeat",
    "tab": "mutagen",
    "l": {
      "description": "-",
      "label": "meat mutation",
      "plural": "meat mutations",
      "lol": "",
      "verb": "mutate",
      "verbing": "mutating",
      "verbone": "mutates"
    },
    "requires": [
      {
        "val": 1,
        "upgrade": "mutatemeat"
      }
    ],
    "cost": [
      {
        "unittype": "mutagen",
        "val": 1
      }
    ],
    "effect": [
      {
        "type": "logStat",
        "stat": "prod",
        "unittype": "drone",
        "val": 0.1,
        "val2": 10,
        "val3": 0.48
      },
      {
        "type": "logStat",
        "stat": "prod",
        "unittype": "queen",
        "val": 0.1,
        "val2": 10,
        "val3": 0.408
      },
      {
        "type": "logStat",
        "stat": "prod",
        "unittype": "nest",
        "val": 0.1,
        "val2": 10,
        "val3": 0.3468
      },
      {
        "type": "logStat",
        "stat": "prod",
        "unittype": "greaterqueen",
        "val": 0.1,
        "val2": 10,
        "val3": 0.29478
      },
      {
        "type": "logStat",
        "stat": "prod",
        "unittype": "hive",
        "val": 0.1,
        "val2": 10,
        "val3": 0.250563
      },
      {
        "type": "logStat",
        "stat": "prod",
        "unittype": "hivequeen",
        "val": 0.1,
        "val2": 10,
        "val3": 0.21297855
      },
      {
        "type": "logStat",
        "stat": "prod",
        "unittype": "empress",
        "val": 0.1,
        "val2": 10,
        "val3": 0.1810317675
      },
      {
        "type": "logStat",
        "stat": "prod",
        "unittype": "prophet",
        "val": 0.1,
        "val2": 10,
        "val3": 0.1538770024
      },
      {
        "type": "logStat",
        "stat": "prod",
        "unittype": "goddess",
        "val": 0.1,
        "val2": 10,
        "val3": 0.130795452
      },
      {
        "type": "logStat",
        "stat": "prod",
        "unittype": "pantheon",
        "val": 0.1,
        "val2": 10,
        "val3": 0.1111761342
      },
      {
        "type": "logStat",
        "stat": "prod",
        "unittype": "pantheon2",
        "val": 0.1,
        "val2": 10,
        "val3": 0.09449971408
      },
      {
        "type": "logStat",
        "stat": "prod",
        "unittype": "pantheon3",
        "val": 0.1,
        "val2": 10,
        "val3": 0.08032475697
      },
      {
        "type": "logStat",
        "stat": "prod",
        "unittype": "pantheon4",
        "val": 0.1,
        "val2": 10,
        "val3": 0.06827604343
      },
      {
        "type": "logStat",
        "stat": "prod",
        "unittype": "pantheon5",
        "val": 0.1,
        "val2": 10,
        "val3": 0.05803463691
      },
      {
        "type": "logStat",
        "stat": "prod",
        "unittype": "overmind",
        "val": 0.1,
        "val2": 10,
        "val3": 0.04932944137
      },
      {
        "type": "logStat",
        "stat": "prod",
        "unittype": "overmind2",
        "val": 0.1,
        "val2": 10,
        "val3": 0.04193002517
      },
      {
        "type": "logStat",
        "stat": "prod",
        "unittype": "overmind3",
        "val": 0.1,
        "val2": 10,
        "val3": 0.03564052139
      },
      {
        "type": "logStat",
        "stat": "prod",
        "unittype": "overmind4",
        "val": 0.1,
        "val2": 10,
        "val3": 0.03029444318
      },
      {
        "type": "logStat",
        "stat": "prod",
        "unittype": "overmind5",
        "val": 0.1,
        "val2": 10,
        "val3": 0.02575027671
      },
      {
        "type": "logStat",
        "stat": "prod",
        "unittype": "overmind6",
        "val": 0.1,
        "val2": 10,
        "val3": 0.0218877352
      }
    ],
    "ascendPreserve": true
  }
];
export default list;
