local addonName, VRT = ...

VRT.CLASS_COLORS = {
    ["DEATHKNIGHT"] = {0.77, 0.12, 0.23}, ["DEMONHUNTER"] = {0.64, 0.19, 0.79},
    ["DRUID"]       = {1.00, 0.49, 0.04}, ["EVOKER"]      = {0.20, 0.58, 0.50},
    ["HUNTER"]      = {0.67, 0.83, 0.45}, ["MAGE"]        = {0.25, 0.78, 0.92},
    ["MONK"]        = {0.00, 1.00, 0.60}, ["PALADIN"]     = {0.96, 0.55, 0.73},
    ["PRIEST"]      = {1.00, 1.00, 1.00}, ["ROGUE"]       = {1.00, 0.96, 0.41},
    ["SHAMAN"]      = {0.00, 0.44, 0.87}, ["WARLOCK"]     = {0.53, 0.53, 0.93},
    ["WARRIOR"]     = {0.78, 0.61, 0.43},
}

VRT.ACCENT = {0.25, 0.78, 0.92}

-- Sorts d'interruption majeurs par classe (utilisé par CooldownCheck, pas d'affichage dédié)
VRT.CLASS_INTERRUPTS = {
    ["ROGUE"]       = 1766,  ["WARRIOR"]     = 6552,  ["MAGE"]        = 2139,
    ["SHAMAN"]      = 57994, ["PALADIN"]     = 96231, ["DEATHKNIGHT"] = 47528,
    ["DEMONHUNTER"] = 183752, ["DRUID"]      = 106839, ["HUNTER"]      = 147362,
    ["MONK"]        = 116705, ["EVOKER"]     = 351338, ["PRIEST"]      = 15487,
}

VRT.RAID_TIERS = {
    "MidnightS2",
}

VRT.RAID_TIER_LABELS = {
    MidnightS2 = "Midnight - Saison 2",
}

VRT.BOSS_LIST = {
    MidnightS2 = {
        "EntombedSentinels",
        "NekzaliTheSoulcoiler",
        "NymrissaWavecaller",
        "Sszorak",
        "TheCoiledAltar",
        "TheLostExplorers",
        "TheTwinFangs",
        "Ulatek",
        "VashnikTheMalignant",
    },
}
