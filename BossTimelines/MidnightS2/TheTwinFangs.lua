local addonName, VRT = ...

-- Source : notes de stratégie communautaires (pas de timers précis publiés, uniquement
-- l'ordre et la nature des mécaniques). journalEncounterID à renseigner en jeu via
-- EJ_GetEncounterInfo une fois le raid disponible.
VRT.Timelines["MidnightS2"]["TheTwinFangs"] = {
    name = "The Twin Fangs (Vexhul & Ithraz)",
    journalEncounterID = nil,
    heroismTiming = "Au pull",
    notes = "Deux serpents combattus simultanément (Vexhul et Ithraz). Applique Eternal Venom (DoT cumulatif de nature) retiré uniquement en soak les frappes de Ravenous Feast — à 10 stacks, mort instantanée. Garder les deux boss à vie égale (sinon Uncoiled Wrath : +25% dégâts toutes les 4s à la mort du premier).",
    keyNotes = {
        immunities = "Stone Breaker (soaks requis, spellID 1288538)",
        dispels = "Aucun",
        interrupts = "Aucune",
    },
    phases = {
        {
            name = "Phase 1",
            events = {
                { spellID = 1290336, text = "Eternal Venom : DoT de nature cumulatif — à 10 stacks, mort. Retirer un stack en soak Ravenous Feast.", duration = 0 },
                { spellID = 1289192, text = "[Tank/Vexhul] Caustic Deluge : rayon de repoussée canalisé sur le tank, augmente les dégâts de Deluge subis, crée des Caustic Globules — lutter contre la repoussée.", duration = 0 },
                { spellID = 1288538, text = "[Tank/Ithraz] Stone Breaker : repousse puis martèle plusieurs fois, chaque coup doit toucher un joueur (sinon dégâts+repoussée au raid) — soak les 3 fracas dans l'ordre, switch de serpent ensuite.", duration = 0 },
                { spellID = 1289993, text = "Caustic Globule : morve explosant après 10s (applique Venom à tous) sauf soak par un seul joueur — esquiver les cercles verts qui les posent.", duration = 10 },
                { spellID = 1290516, text = "Ravenous Feast : 3 frappes rapprochées, dégâts partagés entre proches + repoussée, +dégâts de Feast subis 8s — mais retire un stack de Venom. Se répartir en 3 groupes pour soak.", duration = 8 },
                { spellID = nil, text = "Focus l'add Blood Mass qui apparaît après le soak du Feast.", duration = 0 },
                { spellID = 1291404, text = "Venomous Emergence : invoque un Spawn of Vexhul crachant un rayon toxique rotatif — ne pas bouger de façon erratique si ciblé.", duration = 0 },
                { spellID = 1290809, text = "Coiling Ichor : joueurs debuffés pulsent des dégâts aux proches, pose une flaque à expiration — courir au bord pour poser en zone sûre.", duration = 0 },
                { spellID = 1290956, text = "Stir the Depths : vagues de vase traversant l'arène depuis le fond des plateformes — esquiver.", duration = 0 },
                { spellID = 1295049, text = "Toxic Fumes : dégâts passifs au raid.", duration = 0 },
                { spellID = 1308583, text = "Uncoiled Wrath : à la mort d'un serpent, l'autre gagne +25% dégâts toutes les 4s (cumulatif) — garder les deux boss à vie égale.", duration = 4 },
                { spellID = nil, text = "[Mythique] Vexhul saute au centre, projette un rayon toxique rotatif — observer le sens de rotation de ses orbes pour connaître la direction du rayon.", duration = 0 },
                { spellID = nil, text = "[Mythique] Eternal Venom fait mourir à 9 stacks et pose un Globule à la mort. Les Globules sont protégés par des Barbed Bulwarks — les étourdir pour les détruire.", duration = 0 },
                { spellID = nil, text = "[Mythique] Des bébés serpents apparaissent (AoE pulsée) — kick pour les forcer à fuir. Les Blood Founts doivent être occupés et vidés complètement, sinon ils explosent.", duration = 0 },
            },
        },
        {
            name = "Interphase",
            events = {
                { spellID = 1308556, text = "Submerge : des flaques de venin pleuvent sur la plateforme, dégâts + augmente les dégâts subis si on reste dedans.", duration = 0 },
            },
        },
    },
}
