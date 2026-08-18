local addonName, VRT = ...

--[[
Format attendu pour chaque fichier de boss :

VRT.Alerts["MidnightS1"]["Beloren"] = {
    { trigger = "SPELL_CAST_START", spellID = nil, message = "Interrompre !", sound = nil, color = {1, 0.2, 0.2} },
}

NOTE: le déclenchement en direct via COMBAT_LOG_EVENT_UNFILTERED a été retiré.
RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED") déclenche systématiquement
ADDON_ACTION_FORBIDDEN dans cet environnement (confirmé indépendant du combat,
du timing et du délai d'enregistrement — cause probable : interception de
Frame:RegisterEvent par !BugGrabber). Les données d'alertes (VRT.Alerts) restent
utilisables par d'autres modules (ex: affichage statique dans BossTimelines) ;
seul le déclenchement automatique en combat est désactivé pour l'instant.
]]

VRT.Alerts = VRT.Alerts or {}
for _, tier in ipairs(VRT.RAID_TIERS) do
    VRT.Alerts[tier] = VRT.Alerts[tier] or {}
end

local EncounterAlerts = {}
VRT:RegisterModule("EncounterAlerts", EncounterAlerts)

local activeAlerts = nil
local alertFrame = CreateFrame("Frame")

local function ShowAlertText(message, color)
    -- Fenêtre d'alerte centrale simple (texte temporaire à l'écran)
    local display = VRT.frames.AlertDisplay
    if not display then
        display = VRT.UI.CreateAnchoredWindow("ValhollAlertDisplay", "", 400, 50)
        display:SetFrameStrata("HIGH")
        display.header:Hide()
        display.text = display:CreateFontString(nil, "OVERLAY", "GameFontHighlightHuge")
        display.text:SetPoint("CENTER")
        VRT.frames.AlertDisplay = display
        VRT:GetModule("AnchorManager"):Register("AlertDisplay", display, "CENTER", 0, 200)
        display:Hide()
    end
    display.text:SetText(message)
    if color then
        display.text:SetTextColor(color[1], color[2], color[3])
    else
        display.text:SetTextColor(1, 1, 1)
    end
    display:Show()
    C_Timer.After(3, function() display:Hide() end)
end

function EncounterAlerts:GetAlerts(tier, boss)
    local tierData = VRT.Alerts[tier]
    return tierData and tierData[boss]
end

function EncounterAlerts:StartEncounter(tier, boss)
    activeAlerts = self:GetAlerts(tier, boss)
end

function EncounterAlerts:StopEncounter()
    activeAlerts = nil
end

-- ===== Panneau intégré au shell d'options (onglet "Alerts") =====
local ROW_HEIGHT = 22
local BOSS_ROW_HEIGHT = 24
local LIST_WIDTH = 560

local listContainer
local selectedFilter = "All"
local bossSections = {} -- key = tier/boss -> { header, expanded, rows = {} }
local sectionOrder = {}

local function GetSpellDisplay(spellID)
    if not spellID then return "Interface\\Icons\\INV_Misc_QuestionMark", "Mécanique" end
    local info = C_Spell and C_Spell.GetSpellInfo and C_Spell.GetSpellInfo(spellID)
    if info then return info.iconID, info.name end
    return "Interface\\Icons\\INV_Misc_QuestionMark", "Sort #" .. spellID
end

-- Clé stable par sort+trigger plutôt que par index de liste : réordonner ou insérer une
-- alerte dans un fichier boss ne fait pas glisser les toggles "désactivé" déjà enregistrés
-- vers la mauvaise entrée.
local function AlertKey(tier, boss, alert)
    return tier .. "/" .. boss .. "/" .. (alert.spellID or "?") .. "/" .. (alert.trigger or "?")
end

local function IsAlertEnabled(tier, boss, alert)
    local db = VRT.db.modules.EncounterAlerts
    db.disabled = db.disabled or {}
    return not db.disabled[AlertKey(tier, boss, alert)]
end

local function SetAlertEnabled(tier, boss, alert, enabled)
    local db = VRT.db.modules.EncounterAlerts
    db.disabled = db.disabled or {}
    local key = AlertKey(tier, boss, alert)
    if enabled then
        db.disabled[key] = nil
    else
        db.disabled[key] = true
    end
end

local function CreateAlertRow(parent)
    local row = CreateFrame("Frame", nil, parent)
    row:SetSize(LIST_WIDTH, ROW_HEIGHT)

    local icon = row:CreateTexture(nil, "ARTWORK")
    icon:SetSize(16, 16)
    icon:SetPoint("LEFT", row, "LEFT", 24, 0)
    row.icon = icon

    local check = VRT.UI.CreateFlatCheck(row, nil, "", row, 0)
    check:ClearAllPoints()
    check:SetPoint("LEFT", icon, "RIGHT", 8, 0)
    check.label:ClearAllPoints()
    check.label:SetPoint("LEFT", check, "RIGHT", 6, 0)
    row.check = check

    local triggerText = row:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    triggerText:SetPoint("RIGHT", row, "RIGHT", -4, 0)
    row.triggerText = triggerText

    return row
end

local TRIGGER_LABELS = {
    SPELL_CAST_START = "Cast",
    SPELL_AURA_APPLIED = "Debuff",
}

local function CreateBossSection(key, tier, boss)
    local header = CreateFrame("Button", nil, listContainer)
    header:SetSize(LIST_WIDTH, BOSS_ROW_HEIGHT)

    local bg = header:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(VRT.ACCENT[1] * 0.14, VRT.ACCENT[2] * 0.14, VRT.ACCENT[3] * 0.14, 1)

    local arrow = header:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    arrow:SetPoint("LEFT", header, "LEFT", 6, 0)
    arrow:SetTextColor(VRT.ACCENT[1], VRT.ACCENT[2], VRT.ACCENT[3])

    local title = header:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("LEFT", arrow, "RIGHT", 6, 0)
    title:SetTextColor(VRT.ACCENT[1], VRT.ACCENT[2], VRT.ACCENT[3])

    local count = header:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    count:SetPoint("RIGHT", header, "RIGHT", -8, 0)

    local section = {
        key = key, tier = tier, boss = boss,
        header = header, arrow = arrow, title = title, count = count,
        expanded = true, rows = {},
    }

    header:SetScript("OnClick", function()
        section.expanded = not section.expanded
        EncounterAlerts:RefreshOptionsPanel()
    end)

    bossSections[key] = section
    return section
end

local function LayoutAlertPanel()
    local y = 0
    for _, key in ipairs(sectionOrder) do
        local section = bossSections[key]
        local alerts = EncounterAlerts:GetAlerts(section.tier, section.boss) or {}

        section.header:ClearAllPoints()
        section.header:SetPoint("TOPLEFT", listContainer, "TOPLEFT", 0, -y)
        section.arrow:SetText(section.expanded and "v" or ">")
        local timeline = VRT:GetModule("BossTimelines"):GetTimeline(section.tier, section.boss)
        section.title:SetText(timeline and timeline.name or section.boss)
        section.count:SetText("(" .. #alerts .. ")")
        section.header:Show()
        y = y + BOSS_ROW_HEIGHT + 2

        if section.expanded then
            for i, alert in ipairs(alerts) do
                local row = section.rows[i]
                if not row then
                    row = CreateAlertRow(listContainer)
                    section.rows[i] = row
                end
                row:ClearAllPoints()
                row:SetPoint("TOPLEFT", listContainer, "TOPLEFT", 0, -y)
                local iconID, spellName = GetSpellDisplay(alert.spellID)
                row.icon:SetTexture(iconID)
                row.check.label:SetText(spellName .. (alert.message and (" — " .. alert.message) or ""))
                row.check:SetChecked(IsAlertEnabled(section.tier, section.boss, alert))
                row.check:SetScript("OnClick", function(self)
                    SetAlertEnabled(section.tier, section.boss, alert, self:GetChecked() and true or false)
                end)
                row.triggerText:SetText(TRIGGER_LABELS[alert.trigger] or alert.trigger or "")
                row:Show()
                y = y + ROW_HEIGHT
            end
        else
            for _, row in ipairs(section.rows) do row:Hide() end
        end

        y = y + 6
    end
    return y
end

function EncounterAlerts:BuildOptionsPanel(container)
    listContainer = CreateFrame("Frame", nil, container)
    listContainer:SetPoint("TOPLEFT", container, "TOPLEFT", 0, 0)
    listContainer:SetPoint("TOPRIGHT", container, "TOPRIGHT", 0, 0)

    sectionOrder = {}
    for _, tier in ipairs(VRT.RAID_TIERS) do
        for _, boss in ipairs(VRT.BOSS_LIST[tier] or {}) do
            local alerts = self:GetAlerts(tier, boss)
            if alerts and #alerts > 0 then
                local key = tier .. "/" .. boss
                table.insert(sectionOrder, key)
                CreateBossSection(key, tier, boss)
            end
        end
    end

    local totalHeight = LayoutAlertPanel()
    container.contentHeight = totalHeight + 20
end

function EncounterAlerts:RefreshOptionsPanel()
    if not listContainer then return end
    local totalHeight = LayoutAlertPanel()
    local container = listContainer:GetParent()
    if container then container.contentHeight = totalHeight + 20 end
    local options = VRT:GetModule("Options")
    if options and options.RefreshLayout then options:RefreshLayout() end
end

alertFrame:RegisterEvent("ENCOUNTER_START")
alertFrame:RegisterEvent("ENCOUNTER_END")
alertFrame:SetScript("OnEvent", function(self, event, encounterID, encounterName, ...)
    local db = VRT.db and VRT.db.modules.EncounterAlerts
    if not db or not db.enabled then return end

    if event == "ENCOUNTER_START" then
        for tier, bosses in pairs(VRT.BOSS_LIST) do
            for _, boss in ipairs(bosses) do
                local timeline = VRT:GetModule("BossTimelines"):GetTimeline(tier, boss)
                if timeline and timeline.journalEncounterID == encounterID then
                    EncounterAlerts:StartEncounter(tier, boss)
                    return
                end
            end
        end
    elseif event == "ENCOUNTER_END" then
        EncounterAlerts:StopEncounter()
    end
end)
