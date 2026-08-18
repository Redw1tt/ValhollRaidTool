local addonName, VRT = ...

-- Source : notes de stratégie communautaires (pas de timers précis publiés, uniquement
-- l'ordre et la nature des mécaniques). journalEncounterID à renseigner en jeu via
-- EJ_GetEncounterInfo une fois le raid disponible.
VRT.Timelines["MidnightS2"]["EntombedSentinels"] = {
    name = "Entombed Sentinels",
    journalEncounterID = nil,
    heroismTiming = "Au pull",
    notes = "Deux boss (Gardiens) combattus simultanément à 40m d'écart minimum (sinon 99% de réduction de dégâts). Le raid est coupé en deux, chaque moitié gère un Gardien et ses mécaniques (côté Sang / côté Acide), avec switch de côté à l'interphase. Garder les deux boss à vie égale.",
    keyNotes = {
        immunities = "Aucune",
        dispels = "Blighted Blood (spellID 1284471)",
        interrupts = "Aucune",
    },
    phases = {
        {
            name = "Phase 1",
            events = {
                { spellID = 1290193, text = "Ula'tek's Dominance : les boss subissent 99% de dégâts en moins s'ils sont à moins de 40m l'un de l'autre — les séparer.", duration = 0 },
                { spellID = 1284494, text = "Mark of Acid/Blood : DoT cumulatif pour les joueurs restant à moins de 40m d'un gardien — changer de gardien pour le retirer.", duration = 0 },
                { spellID = 1284458, text = "[Tank] Empowering Slam : grosse frappe sur le tank, augmente les dégâts du gardien jusqu'au swap de cible.", duration = 0 },
                { spellID = 1284487, text = "[Tank] Bloodvenom Injection : grosse frappe sur le tank, applique un DoT/blood venom cumulatif.", duration = 0 },
                { spellID = 1288232, text = "[Côté Sang] Unstable Miasma : cercle rouge à soak en groupe, partage les dégâts et stacks de Blood Venom.", duration = 0 },
                { spellID = 1284208, text = "[Côté Sang] Blood Venom : à expiration, dépose une void zone (taille selon stacks) — déposer près des autres puddles.", duration = 0 },
                { spellID = 1284471, text = "[Côté Sang] Blighted Blood : dégâts d'ombre périodiques, dispellable — le joueur dispellé dépose une puddle près des autres.", duration = 0 },
                { spellID = 1284434, text = "[Côté Acide] Toxic Droplets : gouttes au sol, marcher dessus pour empêcher leur explosion.", duration = 0 },
                { spellID = 1284207, text = "[Côté Acide] Living Venom : vase réaspirée vers le boss, dégâts aux joueurs sur le trajet — esquiver les lignes vertes.", duration = 0 },
                { spellID = 1284251, text = "[Côté Acide] Venom Coagulation : add de vase pulsant des dégâts jusqu'à sa mort — focus prioritaire.", duration = 0 },
                { spellID = nil, text = "[Mythique] Certains joueurs reçoivent un cercle orange — se connecter à un autre joueur au même cercle pour retirer le debuff. Mauvais partenaire = gros dégâts + repoussée.", duration = 0 },
            },
        },
        {
            name = "Interphase",
            events = {
                { spellID = 1284588, text = "Vitriolic Stasis : à 100 énergie, les gardiens s'entrechoquent au centre — le moins vivant se soigne au niveau du plus vivant.", duration = 0 },
                { spellID = 1284590, text = "Helical Toxins : 1 à 3 stacks de toxine par joueur pendant la canalisation. Se percuter avec quelqu'un dont le numéro + le sien = 4 pour retirer le debuff. Échec = dégâts au raid.", duration = 0 },
                { spellID = nil, text = "Switch de côté après l'interphase (le groupe change de gardien).", duration = 0 },
            },
        },
    },
}
