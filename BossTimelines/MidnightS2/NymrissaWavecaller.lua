local addonName, VRT = ...

-- Source : notes de stratégie communautaires (pas de timers précis publiés, uniquement
-- l'ordre et la nature des mécaniques). journalEncounterID à renseigner en jeu via
-- EJ_GetEncounterInfo une fois le raid disponible.
VRT.Timelines["MidnightS2"]["NymrissaWavecaller"] = {
    name = "Nymrissa Wavecaller",
    journalEncounterID = nil,
    heroismTiming = "Au pull",
    notes = "Combat mono-boss (repaire The Tidebound Grotto) : timing des soaks de Frost Orb pour gérer les dégâts d'explosion, contrôle des murlocs qui spawn et convergent vers la Bulle centrale (Alluring Bubble), et esquive des vagues d'eau (Swirling Whirlpools) venant des bords de l'arène. Les dégâts raid montent tout le long du combat (ramp).",
    keyNotes = {
        immunities = "Frost Orb Soaking (spellID 1313402)",
        dispels = "Aucun",
        interrupts = "Aucune",
    },
    phases = {
        {
            name = "Phase 1",
            events = {
                { spellID = 1257717, text = "Alluring Bubble : une bulle se forme au centre de l'arène et attire les murlocs vers elle.", duration = 0 },
                { spellID = nil, text = "Murlocs spawn et convergent vers la Bulle — CC/slow/knock pour les empêcher de l'atteindre, sinon ils deviennent Bubblefin Berserker (pulsent des dégâts raid jusqu'à leur mort).", duration = 0 },
                { spellID = 1258150, text = "Pop! : quand la bulle éclate, knockback les joueurs et inflige des dégâts au raid.", duration = 0 },
                { spellID = 1282937, text = "[Tank] Iceblade Flurry : dégâts canalisés sur le tank, augmente les dégâts de Flurry subis.", duration = 0 },
                { spellID = 1313393, text = "Chilling Frost : joueurs debuffés et ralentis, lâchent quelques Frost Orb à leur position.", duration = 0 },
                { spellID = 1313402, text = "Frost Orb : dégâts + DoT au contact (+15% dégâts d'orbe subis, 16s, cumulatif), laisse une flaque glissante — déposer groupés au bord côté raid, courir dessus avant Shatter.", duration = 16 },
                { spellID = 1313456, text = "Shatter : un orbe laissé intact explose en dégâts raid et applique un DoT cumulatif — éclater les orbes à temps.", duration = 0 },
                { spellID = 1260837, text = "Abyssal Rain : dégâts raid, augmente les dégâts de givre du boss de 5% cumulatif à chaque cast.", duration = 0 },
                { spellID = 1258668, text = "Swirling Whirlpools : vagues d'eau foncent vers la Bulle depuis les bords de l'arène, gros dégâts si touché — rester mobile.", duration = 0 },
                { spellID = 1257654, text = "Lingering Frost : flaque persistante, dégâts de givre + fait glisser.", duration = 0 },
                { spellID = nil, text = "[Mythique] Bubblefin Frostscale : murloc protégeant les murlocs proches d'un bouclier — à tuer en priorité.", duration = 0 },
                { spellID = 1258901, text = "[Mythique/Tank] Water Jet : jet d'eau haute pression sur le tank, nettoie les flaques de Lingering Frost (qui sinon ne disparaissent plus seules).", duration = 0 },
            },
        },
        {
            name = "Interphase",
            events = {
                { spellID = 1294867, text = "Unending Tides : l'eau s'abat en continu et wipe le raid — mécanique d'enrage, survivre jusqu'au bout du combat avant qu'elle n'arrive.", duration = 0 },
            },
        },
    },
}
