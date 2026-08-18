local addonName, VRT = ...

VRT.Alerts["MidnightS2"]["NekzaliTheSoulcoiler"] = {
    { trigger = "SPELL_CAST_START", spellID = 1284103, message = "Possession Barrage (Tank)", sound = nil, color = {0.42, 0.69, 0.95} },
    { trigger = "SPELL_CAST_START", spellID = 1287426, message = "Essence Rend — courir à l'écart !", sound = nil, color = {0.71, 0.49, 0.86} },
    { trigger = "SPELL_CAST_START", spellID = 1285681, message = "Soulcoil Ignition (x4 Rite)", sound = nil, color = {1, 0.62, 0.26} },
    { trigger = "SPELL_CAST_START", spellID = 1289855, message = "Hungering Pyre — soak !", sound = nil, color = {0.92, 0.35, 0.14} },
    { trigger = "SPELL_CAST_START", spellID = 1299673, message = "Invoke — À INTERROMPRE", sound = nil, color = {1, 0.2, 0.2} },
    { trigger = "SPELL_AURA_APPLIED", spellID = 1287426, message = "Essence Rend sur toi — écarte-toi !", sound = nil, color = {0.71, 0.49, 0.86} },
    { trigger = "SPELL_AURA_APPLIED", spellID = 1294933, message = "Slithering Flames sur toi", sound = nil, color = {0.31, 0.82, 0.77} },
}
