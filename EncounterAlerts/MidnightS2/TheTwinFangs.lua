local addonName, VRT = ...

VRT.Alerts["MidnightS2"]["TheTwinFangs"] = {
    { trigger = "SPELL_CAST_START", spellID = 1288538, message = "Stone Breaker - soak le fracas (Tank)", sound = nil, color = {0.42, 0.69, 0.95} },
    { trigger = "SPELL_CAST_START", spellID = 1289192, message = "Caustic Deluge (Tank)", sound = nil, color = {0.42, 0.69, 0.95} },
    { trigger = "SPELL_CAST_START", spellID = 1290516, message = "Ravenous Feast - soak group !", sound = nil, color = {0.92, 0.35, 0.14} },
    { trigger = "SPELL_CAST_START", spellID = 1291404, message = "Venomous Emergence - ne bouge pas erratiquement", sound = nil, color = {0.31, 0.82, 0.77} },
    { trigger = "SPELL_AURA_APPLIED", spellID = 1290336, message = "Eternal Venom sur toi - attention aux stacks !", sound = nil, color = {1, 0.62, 0.26} },
    { trigger = "SPELL_AURA_APPLIED", spellID = 1289993, message = "Caustic Globule sur toi - soak !", sound = nil, color = {0.92, 0.35, 0.14} },
    { trigger = "SPELL_AURA_APPLIED", spellID = 1290809, message = "Coiling Ichor sur toi - cours au bord", sound = nil, color = {0.31, 0.82, 0.77} },
}
