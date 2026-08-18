local addonName, VRT = ...

VRT.Alerts["MidnightS2"]["Sszorak"] = {
    { trigger = "SPELL_CAST_START", spellID = 1277002, message = "Ravage - Tank solo", sound = nil, color = {0.42, 0.69, 0.95} },
    { trigger = "SPELL_CAST_START", spellID = 1277027, message = "Mutilate - split raid", sound = nil, color = {0.42, 0.69, 0.95} },
    { trigger = "SPELL_CAST_START", spellID = 1287072, message = "Tempest - esquive les tornades", sound = nil, color = {0.71, 0.49, 0.86} },
    { trigger = "SPELL_CAST_START", spellID = 1285732, message = "Howling Maelstrom - INTERPHASE, vents !", sound = nil, color = {1, 0.62, 0.26} },
    { trigger = "SPELL_AURA_APPLIED", spellID = 1305959, message = "Venomous Surge sur toi - depose le Cyst au bord", sound = nil, color = {0.31, 0.82, 0.77} },
    { trigger = "SPELL_AURA_APPLIED", spellID = 1285419, message = "Raging Crosswinds - trouve ton partenaire oppose !", sound = nil, color = {0.31, 0.82, 0.77} },
    { trigger = "SPELL_AURA_APPLIED", spellID = 1287072, message = "Tempest sur toi - dispel", sound = nil, color = {0.71, 0.49, 0.86} },
}
