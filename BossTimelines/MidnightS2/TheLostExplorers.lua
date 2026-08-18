local addonName, VRT = ...

-- Source : notes de stratégie communautaires (pas de timers précis publiés, uniquement
-- l'ordre et la nature des mécaniques). journalEncounterID à renseigner en jeu via
-- EJ_GetEncounterInfo une fois le raid disponible.
VRT.Timelines["MidnightS2"]["TheLostExplorers"] = {
    name = "The Lost Explorers",
    journalEncounterID = nil,
    heroismTiming = "Au pull",
    notes = "Trois Tortollans (Gebbo, Iku, Nama) possédés par Mor'zahl, combattus simultanément. Casser les caisses qui apparaissent dans la salle pour trouver un poisson et le donner à l'un des trois pour interrompre le channel de Mor'zahl — le Tortollan nourri (\"survolté\") gagne des capacités supplémentaires et change la stratégie.",
    keyNotes = {
        immunities = "Mighty Thud (Nama, spellID 1296092)",
        dispels = "Icebound Flames (spellID 1286921)",
        interrupts = "Icebound Flames (spellID 1286921)",
    },
    phases = {
        {
            name = "Phase 1",
            events = {
                { spellID = 1297646, text = "United Defense : si les 3 boss sont à moins de 30m les uns des autres, 99% de dégâts en moins — séparer 2 boss ensemble et le 3e à l'écart.", duration = 0 },
                { spellID = nil, text = "Throw Junk : des caisses apparaissent — marcher dessus applique un saignement (Splinter) mais peut révéler un poisson. Non ouvertes, elles explosent.", duration = 0 },
                { spellID = 1297022, text = "Mor'zahl's Command : donner le poisson (Disgusting Fish) à un Tortollan kick le channel de Mor'zahl et le force à reposséder ce Tortollan, lui donnant des capacités survoltées.", duration = 0 },
                { spellID = 1292780, text = "Final Ascension : si Mor'zahl canalise trop longtemps et atteint 100 énergie, il pulse des dégâts au raid — donner le poisson à temps pour l'éviter.", duration = 0 },
                { spellID = 1295854, text = "[Tank/Gebbo] Shredding Shards : dégâts de givre canalisés sur le tank actif, +50% dégâts de shard subis pendant 1.3min.", duration = 0 },
                { spellID = 1291930, text = "[Tank/Nama] Steady Strikes : chaque attaque augmente les dégâts subis du tank actif de 4%.", duration = 0 },
                { spellID = 1296092, text = "[Nama] Mighty Thud : trois joueurs marqués — Nama leur saute dessus, dégâts partagés selon le nombre de soakers, laisse une void zone.", duration = 0 },
                { spellID = 1296061, text = "[Nama] Shell Spin : cône de carapaces sur la mêlée, étourdit les joueurs touchés — s'écarter.", duration = 0 },
                { spellID = 1291933, text = "[Gebbo] Throw Junk — Trader Gebbo est intankable et se déplace librement dans la salle.", duration = 0 },
                { spellID = 1292104, text = "[Gebbo survolté] Mushroom Toss : champignons qui propulsent en l'air, explosent peu après.", duration = 0 },
                { spellID = 1297625, text = "[Gebbo survolté] Explosive Surprise : un joueur reçoit une bombe, explose en flaque de feu + onde de choc (peut être franchie en sautant).", duration = 0 },
                { spellID = 1295893, text = "[Iku survolté] Frostfire Volley : marque Feu ou Glace, explose et pose une flaque correspondante + debuff.", duration = 0 },
                { spellID = 1295952, text = "[Iku survolté] Elemental Explosion : un debuff touchant une flaque de l'élément opposé explose, dégâts raid.", duration = 0 },
                { spellID = 1296025, text = "[Nama survolté] Blink Nova : joueur marqué explose peu après, dégâts au raid selon la distance — s'éloigner.", duration = 0 },
                { spellID = 1286921, text = "[Iku] Icebound Flames : grosse attaque interruptible, laisse un DoT ralentissant dispellable — à kick ou dispel.", duration = 0 },
            },
        },
    },
}
