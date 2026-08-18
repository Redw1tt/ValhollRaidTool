local addonName, VRT = ...

VRT.Alerts["MidnightS2"]["TheLostExplorers"] = {
    { trigger = "SPELL_CAST_START", spellID = 1286921, message = "Icebound Flames - INTERROMPRE (Iku)", sound = nil, color = {1, 0.2, 0.2} },
    { trigger = "SPELL_CAST_START", spellID = 1296092, message = "Mighty Thud - soak groupe (Nama)", sound = nil, color = {0.92, 0.35, 0.14} },
    { trigger = "SPELL_CAST_START", spellID = 1296061, message = "Shell Spin - ecarte-toi de la melee", sound = nil, color = {0.31, 0.82, 0.77} },
    { trigger = "SPELL_CAST_START", spellID = 1296025, message = "Blink Nova sur toi - eloigne-toi !", sound = nil, color = {0.31, 0.82, 0.77} },
    { trigger = "SPELL_AURA_APPLIED", spellID = 1297625, message = "Explosive Surprise sur toi", sound = nil, color = {0.31, 0.82, 0.77} },
    { trigger = "SPELL_AURA_APPLIED", spellID = 1295893, message = "Frostfire Volley sur toi", sound = nil, color = {0.31, 0.82, 0.77} },
    { trigger = "SPELL_AURA_APPLIED", spellID = 1286921, message = "Icebound Flames sur toi - dispel", sound = nil, color = {0.71, 0.49, 0.86} },
}
