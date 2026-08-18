local addonName, VRT = ...

VRT.Alerts["MidnightS2"]["EntombedSentinels"] = {
    { trigger = "SPELL_CAST_START", spellID = 1284458, message = "Empowering Slam (Tank)", sound = nil, color = {0.42, 0.69, 0.95} },
    { trigger = "SPELL_CAST_START", spellID = 1284487, message = "Bloodvenom Injection (Tank)", sound = nil, color = {0.42, 0.69, 0.95} },
    { trigger = "SPELL_CAST_START", spellID = 1284588, message = "Vitriolic Stasis — Interphase !", sound = nil, color = {1, 0.62, 0.26} },
    { trigger = "SPELL_AURA_APPLIED", spellID = 1288232, message = "Unstable Miasma sur toi — soak !", sound = nil, color = {0.92, 0.35, 0.14} },
    { trigger = "SPELL_AURA_APPLIED", spellID = 1284471, message = "Blighted Blood sur toi — dispel", sound = nil, color = {0.71, 0.49, 0.86} },
    { trigger = "SPELL_AURA_APPLIED", spellID = 1284590, message = "Helical Toxins — trouve ton partenaire (total = 4) !", sound = nil, color = {0.31, 0.82, 0.77} },
    { trigger = "SPELL_AURA_APPLIED", spellID = 1284494, message = "Mark of Acid/Blood — change de gardien !", sound = nil, color = {1, 0.62, 0.26} },
}
