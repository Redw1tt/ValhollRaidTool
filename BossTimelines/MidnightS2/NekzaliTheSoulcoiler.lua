local addonName, VRT = ...

-- Source : notes de stratégie communautaires (pas de timers précis publiés, uniquement
-- l'ordre et la nature des mécaniques). journalEncounterID à renseigner en jeu via
-- EJ_GetEncounterInfo une fois le raid disponible.
VRT.Timelines["MidnightS2"]["NekzaliTheSoulcoiler"] = {
    name = "Nek'zali the Soulcoiler",
    journalEncounterID = nil,
    heroismTiming = "Au pull",
    notes = "Stopper le rituel d'invocation en gérant des vagues d'adds qui marchent vers le puits central (Soul Well). S'ils atteignent le puits, ils accordent de l'énergie à Nek'zali (enrage à 100) et infligent des dégâts au raid. Brûler les corps sinon ils sont réinvoqués.",
    keyNotes = {
        immunities = "Aucune",
        dispels = "Essence Rend (spellID 1287426)",
        interrupts = "Uniquement en mythique (Invoke, spellID 1299673)",
    },
    phases = {
        {
            name = "Phase 1",
            events = {
                { spellID = 1287426, text = "Essence Rend : joueur ciblé aspiré vers le puits puis repoussé — courir à l'écart, dispel dépose une void zone.", duration = 0 },
                { spellID = 1284103, text = "Possession Barrage : vague d'esprits sur le tank actif, orienter loin du raid.", duration = 6 },
                { spellID = 1284110, text = "Hollowing Strikes : absorption/réduction de soins cumulative sur le tank.", duration = 0 },
                { spellID = nil, text = "Adds (Restless Amani) marchent vers le puits — CC pour ralentir, briser leur bouclier pour stopper la fixate, regrouper avant de tuer.", duration = 0 },
                { spellID = 1284033, text = "Soulcoil Rite : chaque add atteignant le puits inflige des dégâts cumulatifs au raid pendant 24s et augmente les dégâts des prochains Rites de 15% pendant 1min.", duration = 24 },
                { spellID = 1285681, text = "Soulcoil Ignition : déclenche Soulcoil Rite 4 fois au cours d'une incantation.", duration = 0 },
                { spellID = 1284034, text = "Uncoiled Rage : à 100 énergie, Nek'zali enrage (+500% dégâts). Éviter que les adds atteignent le puits.", duration = 0 },
            },
        },
        {
            name = "Interphase",
            events = {
                { spellID = nil, text = "Ritual of Awakening : deux Echoes of Jawae invoqués pour protéger Nek'zali (la rend insensible).", duration = 0 },
                { spellID = 1289855, text = "Hungering Pyre : dégâts de feu partagés entre joueurs qui soak, sinon Slithering Flames appliqué.", duration = 0 },
                { spellID = 1294933, text = "Slithering Flames : debuff 8s, explose à expiration et retire tout corps qu'il touche.", duration = 8 },
                { spellID = nil, text = "[Mythique] Strike Team envoyée au puits contre le Drowned Echo — le raid subit des dégâts pulsés et est aspiré vers le puits tant qu'il n'est pas vaincu.", duration = 0 },
                { spellID = 1299673, text = "[Mythique] Invoke — à interrompre (Soulcoiler's Curse), sinon l'équipe périt. Kick désormais aussi les casts.", duration = 0 },
            },
        },
        {
            name = "Phase finale",
            events = {
                { spellID = 1290003, text = "Uncoiling : après la mort des Echoes, le puits déborde et pulse des dégâts au raid pour le reste du combat.", duration = 0 },
            },
        },
    },
    -- Cooldowns de raid à prévoir/aligner sur ce combat (à ajuster selon la composition).
    cooldowns = {
        { text = "CD raid externe conseillé sur le premier Soulcoil Rite (24s de dégâts cumulatifs au raid)." },
        { text = "Garder un CD de dégâts/défensif pour l'interphase mythique (Strike Team vs Drowned Echo)." },
        { text = "Phase finale : le puits pulse en continu — prévoir un CD raid pour la fin du combat (Uncoiling)." },
    },
    -- Rappels courts à relire juste avant le pull ou une phase clé.
    reminders = {
        { text = "Ne jamais laisser un add atteindre le puits sans bouclier brisé — chaque add = énergie vers l'enrage." },
        { text = "Brûler systématiquement les corps des adds morts (Slithering Flames) pour empêcher leur réinvocation." },
        { text = "Mythique : désigner à l'avance qui interrompt Invoke — un raté = wipe garanti." },
    },
}
