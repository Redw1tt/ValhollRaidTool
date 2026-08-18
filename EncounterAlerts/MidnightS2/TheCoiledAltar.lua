local addonName, VRT = ...

VRT.Alerts["MidnightS2"]["TheCoiledAltar"] = {
    { trigger = "SPELL_CAST_START", spellID = 1283489, message = "Guillotine - soak dans un coin (5 joueurs)", sound = nil, color = {0.92, 0.35, 0.14} },
    { trigger = "SPELL_CAST_START", spellID = 1286399, message = "Wail of Terror - INTERROMPRE", sound = nil, color = {1, 0.2, 0.2} },
    { trigger = "SPELL_CAST_START", spellID = 1286918, message = "Eternal Nightfall - INTERROMPRE le bouclier", sound = nil, color = {1, 0.2, 0.2} },
    { trigger = "SPELL_CAST_START", spellID = 1285643, message = "Dreadmarch - MC en approche", sound = nil, color = {1, 0.62, 0.26} },
    { trigger = "SPELL_CAST_START", spellID = 1304032, message = "Soulbinding - fonce dans les esprits !", sound = nil, color = {1, 0.62, 0.26} },
    { trigger = "SPELL_AURA_APPLIED", spellID = 1282419, message = "Volatile Venom sur toi", sound = nil, color = {0.31, 0.82, 0.77} },
    { trigger = "SPELL_AURA_APPLIED", spellID = 1282287, message = "Venomfang sur toi - dispel", sound = nil, color = {0.71, 0.49, 0.86} },
    { trigger = "SPELL_AURA_APPLIED", spellID = 1310882, message = "Gloombomb sur toi - ecarte-toi !", sound = nil, color = {0.31, 0.82, 0.77} },
    { trigger = "SPELL_AURA_APPLIED", spellID = 1285643, message = "Dreadmarch sur toi - MC actif !", sound = nil, color = {1, 0.2, 0.2} },
}
