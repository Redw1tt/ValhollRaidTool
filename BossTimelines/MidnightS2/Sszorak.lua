local addonName, VRT = ...

-- Source : notes de stratégie communautaires (pas de timers précis publiés, uniquement
-- l'ordre et la nature des mécaniques). journalEncounterID à renseigner en jeu via
-- EJ_GetEncounterInfo une fois le raid disponible.
VRT.Timelines["MidnightS2"]["Sszorak"] = {
    name = "Sszorak",
    journalEncounterID = nil,
    heroismTiming = "À l'interphase",
    notes = "Des indicateurs au sol prédisent la direction des vents qui pousseront le raid pendant l'interphase. Placer les Kystes de repoussée (Viscous Cyst) aux bons endroits pour contrer la glissade hors de la plateforme. Combo tank en 5 temps à gérer avant chaque interphase (Ravage solo, Mutilate partagée, Tempest).",
    keyNotes = {
        immunities = "Aucune",
        dispels = "Tempest / Poison (spellID 1287072)",
        interrupts = "Aucune",
    },
    phases = {
        {
            name = "Phase 1",
            events = {
                { spellID = 1277025, text = "[Tank] Apex Predator : combinaison d'attaques sur le tank actif, peut changer de cible pendant l'incantation.", duration = 0 },
                { spellID = 1277002, text = "[Tank] Ravage : cône frontal, augmente les dégâts de Ravage subis de 400% — le tank soak en solo.", duration = 0 },
                { spellID = 1277027, text = "[Tank] Mutilate : cône frontal, dégâts partagés entre joueurs touchés + DoT augmentant les dégâts de Mutilate de 500% — Tank1 vise Groupe1, Tank2 vise Groupe2.", duration = 0 },
                { spellID = 1282869, text = "[Tank] Corroding Venom : attaques de mêlée +3% dégâts physiques subis pendant 12s, cumulatif.", duration = 12 },
                { spellID = 1287072, text = "Tempest : tornades esquivables apparaissent autour du boss et jaillissent — si touché, ralentit et applique DoT poison cumulatif dispellable.", duration = 0 },
                { spellID = 1305959, text = "Venomous Surge : DoT qui pose un Viscous Cyst à expiration, explose selon la distance au raid.", duration = 0 },
                { spellID = 1287008, text = "Viscous Cyst : globe toxique — touché, repousse tous les joueurs et ralentit 5s (cumulatif). Déposer au bord, à l'opposé des tornades visibles sur les murs.", duration = 5 },
                { spellID = 1305998, text = "Caustic Claws : swirlies formant des flaques augmentant les dégâts subis — bait au bord de l'arène après le combo tank.", duration = 0 },
                { spellID = 1286033, text = "Dig In : le boss subit +30% de dégâts pendant 25s — aligner les cooldowns pour l'interphase.", duration = 25 },
                { spellID = nil, text = "[Mythique] Serpent's Fury : un joueur marqué, le boss gagne de l'énergie (100 = wipe). Au moins 14 joueurs doivent se stacker sur le marqué pour déclencher un saut qui réduit l'énergie et partage les dégâts.", duration = 0 },
            },
        },
        {
            name = "Interphase",
            events = {
                { spellID = 1285419, text = "Raging Crosswinds : chaque joueur reçoit une flèche de direction de poussée. Se faire pousser vers un joueur de direction opposée pour se renvoyer mutuellement en sécurité.", duration = 0 },
                { spellID = 1285732, text = "Howling Maelstrom : salve de 3 rafales de vent (directions différentes, ordre 1 tornade / 2 tornades / 3 tornades) qui tentent de souffler le raid hors de la plateforme.", duration = 0 },
            },
        },
    },
}
