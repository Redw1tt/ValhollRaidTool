local addonName, VRT = ...

-- Source : notes de stratégie communautaires (pas de timers précis publiés, uniquement
-- l'ordre et la nature des mécaniques). journalEncounterID à renseigner en jeu via
-- EJ_GetEncounterInfo une fois le raid disponible.
VRT.Timelines["MidnightS2"]["VashnikTheMalignant"] = {
    name = "Vashnik the Malignant",
    journalEncounterID = nil,
    heroismTiming = "Au pull",
    notes = "Trois fontaines entourent la salle (Sang, Feu, Ombre). Le boss s'infuse du pouvoir des deux fontaines les plus proches puis explose sur le raid en invoquant des adds qui rampent vers la fontaine centrale. On déplace le boss entre les fontaines pour choisir les survoltes (elles se cumulent), en gérant les adds et mécaniques propres à chaque élément.",
    keyNotes = {
        immunities = "Aucune",
        dispels = "Aucun",
        interrupts = "Aucune",
    },
    phases = {
        {
            name = "Phase 1",
            events = {
                { spellID = 1283164, text = "Imbibe : le boss s'infuse des deux fontaines les plus proches, survolte le prochain Imbibe et explose sur le raid en invoquant des adds vers la fontaine centrale.", duration = 0 },
                { spellID = nil, text = "Infusions/Empowerments : chaque nouveau tirage de fontaine augmente les dégâts d'explosion et la vie des adds de cette fontaine — cumulatif, bien choisir le déplacement.", duration = 0 },
                { spellID = 1280189, text = "Malignant Burst : si un add atteint la fontaine centrale, il explose et applique un DoT cumulatif 30s au raid — ne pas laisser les adds passer.", duration = 30 },
                { spellID = 1280935, text = "[Tank] Dripping Fangs : DoT cumulatif sur le tank, augmente les dégâts subis.", duration = 0 },
                { spellID = nil, text = "[Sang] Clotting Venom : add immunisé au CC jusqu'à destruction, se scinde ensuite en adds plus petits.", duration = 0 },
                { spellID = 1299941, text = "[Sang] Siphoning Infection : le joueur marqué ne peut être soigné, siphonne la vie des alliés proches, subit des dégâts jusqu'à avoir assez siphonné.", duration = 0 },
                { spellID = nil, text = "[Feu] Burning Venom : 2 adds pulsant des dégâts, explosent avec DoT cumulatif à la mort — tuer un par un, CC-ables (immunisés après 60s).", duration = 60 },
                { spellID = 1295173, text = "[Feu] Exploding Infection : le joueur marqué explose, dégâts au raid réduits par la distance — s'écarter, désormais dispellable.", duration = 0 },
                { spellID = nil, text = "[Ombre] Shrouded Venom : adds boucliers à 100% PV max, projettent des swirlies esquivables à la mort — CC en attendant.", duration = 0 },
                { spellID = 1294994, text = "[Ombre] Stygian Infection : absorption de soin sur le joueur marqué, à retirer en le soignant, projette des swirlies jusqu'au retrait.", duration = 0 },
                { spellID = 1282525, text = "Malignant Catalyst : dégâts au raid qui projettent de la Catalytic Bile à récupérer (soak), explose si personne ne la soak.", duration = 0 },
                { spellID = 1281907, text = "Plague Froth : joueurs debuffés, après 8s projettent des Plague Waves dans les 4 directions cardinales — courir à l'écart, orienter loin du raid.", duration = 8 },
                { spellID = 1284561, text = "Toxic Vapor : légers dégâts cumulatifs au raid toutes les 2s.", duration = 0 },
                { spellID = nil, text = "[Mythique] Malignant Tumors se forment — uniquement retirables en les touchant avec une Plague Wave (viser). Une seule oubliée wipe le raid.", duration = 0 },
            },
        },
    },
}
