local addonName, VRT = ...

VRT.Alerts["MidnightS2"]["VashnikTheMalignant"] = {
    { trigger = "SPELL_CAST_START", spellID = 1283164, message = "Imbibe - adds en approche, garde la fontaine centrale !", sound = nil, color = {1, 0.62, 0.26} },
    { trigger = "SPELL_AURA_APPLIED", spellID = 1281907, message = "Plague Froth sur toi - ecarte-toi !", sound = nil, color = {0.31, 0.82, 0.77} },
    { trigger = "SPELL_AURA_APPLIED", spellID = 1295173, message = "Exploding Infection sur toi - ecarte-toi !", sound = nil, color = {0.31, 0.82, 0.77} },
    { trigger = "SPELL_AURA_APPLIED", spellID = 1299941, message = "Siphoning Infection sur toi", sound = nil, color = {0.92, 0.35, 0.14} },
    { trigger = "SPELL_AURA_APPLIED", spellID = 1294994, message = "Stygian Infection sur toi - fais-toi soigner", sound = nil, color = {1, 0.62, 0.26} },
    { trigger = "SPELL_AURA_APPLIED", spellID = 1282525, message = "Catalytic Bile sur toi - soak !", sound = nil, color = {0.92, 0.35, 0.14} },
}
