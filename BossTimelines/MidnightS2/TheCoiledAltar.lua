local addonName, VRT = ...

-- Source : notes de stratégie communautaires (pas de timers précis publiés, uniquement
-- l'ordre et la nature des mécaniques). journalEncounterID à renseigner en jeu via
-- EJ_GetEncounterInfo une fois le raid disponible.
VRT.Timelines["MidnightS2"]["TheCoiledAltar"] = {
    name = "The Coiled Altar (Zul'jan & Malacrass)",
    journalEncounterID = nil,
    heroismTiming = "À l'interphase",
    notes = "P1 : gérer Zul'jan en ramassant/stackant des globules de venin à détruire au frontal du tank (Sever). P2 : gérer les esprits fixateurs invoqués par Malacrass, détruits au frontal du tank (Soul Sever). Interphase : rituel de soin de Malacrass sur Zul'jan (+100% dégâts subis 35s), foncer dans les esprits qui le fixent pour les faire disparaître avant qu'ils l'atteignent. Phase finale : combine les deux boss (Soulbind, +100% dégâts toutes les 5s à la mort du premier).",
    keyNotes = {
        immunities = "Aucune",
        dispels = "Venomfang (spellID 1282287)",
        interrupts = "Wail of Terror (spellID 1286399), Eternal Nightfall (spellID 1286918)",
    },
    phases = {
        {
            name = "P1 - Zul'jan",
            events = {
                { spellID = 1282487, text = "Fangs of the Coiled Altar : Noxious Ground sur la plateforme, pulse des dégâts 8s, frappe plus le tank actif.", duration = 8 },
                { spellID = nil, text = "Ramasser les green orbs (debuff dégâts pulsés 5s), les déposer devant le boss à l'expiration du debuff.", duration = 5 },
                { spellID = 1299680, text = "[Tank] Sever : cône frontal, augmente les dégâts de Sever subis. Orienter sur les orbes pour les détruire quelques-unes à la fois.", duration = 0 },
                { spellID = 1283489, text = "Guillotine : hache lancée sur un joueur, dégâts partagés aux proches, doit toucher 5 joueurs (sinon énormes dégâts au raid) — 2 groupes se séparent dans un coin pour soak.", duration = 0 },
                { spellID = 1283623, text = "Widow's Kiss : la hache de Guillotine explose sur 50m — courir hors de l'explosion.", duration = 0 },
                { spellID = 1299960, text = "Toxic Deluge : venin pleut, blesse quiconque reste dans le swirly, forme du Coalesced Venom — esquiver les flaques vertes grandissantes.", duration = 0 },
                { spellID = 1282403, text = "Coalesced Venom : globule pulsant des dégâts jusqu'à être ramassé, applique Volatile Venom au porteur.", duration = 0 },
                { spellID = 1282419, text = "Volatile Venom : pulse de l'AoE autour du joueur 5s puis reforme un globule au sol.", duration = 5 },
                { spellID = 1299838, text = "Venom Rupture : si détruit, le Globule inflige un DoT cumulatif au raid.", duration = 0 },
                { spellID = 1283832, text = "Axegrinder : haches jetées au sol, dégâts et tournoient dans l'arène — esquiver.", duration = 0 },
                { spellID = 1282287, text = "Venomfang : poison appliqué aux joueurs, dispellable.", duration = 0 },
                { spellID = nil, text = "[Mythique] Virulent Mutations : Globules survoltés qui explosent s'ils touchent d'autres globules.", duration = 0 },
            },
        },
        {
            name = "P2 - Malacrass",
            events = {
                { spellID = 1285643, text = "Dreadmarch : joueurs mind-controlés, forcés de marcher vers le bord (mort) — les dégâts subis peuvent briser le MC à temps.", duration = 0 },
                { spellID = nil, text = "Manifestation of Dread : au retrait du MC, deux esprits apparaissent et fixent un joueur au hasard. S'arrêtent si on les regarde, ré-appliquent le MC s'ils atteignent le joueur.", duration = 0 },
                { spellID = 1286620, text = "[Tank] Soul Sever : cône frontal sur le tank, détruit les esprits de Manifestation, fait apparaître 3 Souls à récupérer en 15s sinon mort.", duration = 15 },
                { spellID = 1310882, text = "Gloombomb : joueurs debuffés explosent après 5s, font apparaître 3 Souls à récupérer en 15s sinon mort.", duration = 5 },
                { spellID = 1286918, text = "Eternal Nightfall : percer le bouclier du boss pour kick le cast de wipe, en esquivant les swirlies.", duration = 0 },
                { spellID = nil, text = "Soulcoiler Add : lance un fear de 5s — à kick et tuer en priorité.", duration = 5 },
                { spellID = 1286399, text = "Wail of Terror : cri terrifiant du Spiteful Soulcoiler, fear tout le raid 5s — à kick.", duration = 5 },
                { spellID = nil, text = "[Mythique] Manifestations of Dread visibles seulement par les joueurs fixés (ou après kick du Soulcoil) — foudroient le joueur si 2 esprits se touchent.", duration = 0 },
                { spellID = 1310882, text = "[Mythique] Le Soulcoil a un bouclier retiré avec les Gloombombs.", duration = 0 },
            },
        },
        {
            name = "Interphase",
            events = {
                { spellID = 1304032, text = "Soulbinding : rituel de soin sur Zul'jan (+100% dégâts subis 35s), invoque des esprits qui le fixent — foncer dedans pour les faire disparaître avant qu'ils l'atteignent (sinon ils le soignent).", duration = 35 },
            },
        },
        {
            name = "Phase finale",
            events = {
                { spellID = nil, text = "Soulbind : Malacrass et Zul'jan enragent quand l'autre meurt (+100% dégâts toutes les 5s) — combat combiné avec toutes les mécaniques des deux phases précédentes.", duration = 5 },
            },
        },
    },
}
