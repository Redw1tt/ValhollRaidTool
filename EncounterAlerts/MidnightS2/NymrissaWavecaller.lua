local addonName, VRT = ...

VRT.Alerts["MidnightS2"]["NymrissaWavecaller"] = {
    { trigger = "SPELL_CAST_START", spellID = 1258150, message = "Pop! - la bulle va exploser", sound = nil, color = {1, 0.62, 0.26} },
    { trigger = "SPELL_CAST_START", spellID = 1258668, message = "Swirling Whirlpools - reste mobile !", sound = nil, color = {0.31, 0.82, 0.77} },
    { trigger = "SPELL_CAST_START", spellID = 1294867, message = "Unending Tides - ENRAGE en approche", sound = nil, color = {1, 0.2, 0.2} },
    { trigger = "SPELL_AURA_APPLIED", spellID = 1313393, message = "Chilling Frost sur toi", sound = nil, color = {0.31, 0.82, 0.77} },
    { trigger = "SPELL_AURA_APPLIED", spellID = 1313402, message = "Frost Orb sur toi - soak !", sound = nil, color = {0.92, 0.35, 0.14} },
    { trigger = "SPELL_AURA_APPLIED", spellID = 1257654, message = "Lingering Frost sous toi", sound = nil, color = {0.31, 0.82, 0.77} },
}
