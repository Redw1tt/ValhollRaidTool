local addonName, VRT = ...

--[[
Format attendu pour chaque fichier de boss (rempli au fur et à mesure des kills) :

VRT.Timelines["MidnightS2"]["Sszorak"] = {
    name = "Sszorak",
    journalEncounterID = nil,
    notes = "Résumé général du combat.",
    phases = {
        { name = "Phase 1", events = {
            { time = 8,  spellID = nil, text = "Premier cast", duration = 4 },
            { time = 20, spellID = nil, text = "Mécanique X", duration = 0 },
        }},
    },
    cooldowns = {
        -- Cooldowns de raid à prévoir/aligner sur ce boss (défensifs externes, immunités...)
        { text = "CD raid externe conseillé avant le 1er Ravenous Feast" },
    },
    reminders = {
        -- Rappels courts à afficher/relire juste avant le pull ou une phase clé
        { text = "Vérifier les assignations de soak avant le pull" },
    },
}
]]

VRT.Timelines = VRT.Timelines or {}
for _, tier in ipairs(VRT.RAID_TIERS) do
    VRT.Timelines[tier] = VRT.Timelines[tier] or {}
end

local BossTimelines = {}
VRT:RegisterModule("BossTimelines", BossTimelines)

local activeTimeline = nil
local encounterStart = nil
local timerFrame = CreateFrame("Frame")

function BossTimelines:GetTimeline(tier, boss)
    local tierData = VRT.Timelines[tier]
    return tierData and tierData[boss]
end

function BossTimelines:StartEncounter(tier, boss)
    local timeline = self:GetTimeline(tier, boss)
    if not timeline then return end
    activeTimeline = timeline
    encounterStart = GetTime()
end

function BossTimelines:StopEncounter()
    activeTimeline = nil
    encounterStart = nil
end

function BossTimelines:GetElapsed()
    if not encounterStart then return nil end
    return GetTime() - encounterStart
end

-- ===== Panneau intégré au shell d'options (onglet "Codex") =====
local UI = VRT.UI

local ROW_HEIGHT = 20
local PHASE_HEADER_HEIGHT = 26
local SECTION_GAP = 10
local BLOCK_GAP = 16
local DETAIL_WIDTH = 580

local bossListContainer, detailContainer
local selectedTier, selectedBoss
local bossButtons = {}
local tierLabels = {}

-- Pools de widgets séparés par bloc pour ne jamais réutiliser une ligne de mécanique
-- comme ligne de cooldown/reminder (types de contenu différents, layout indépendant).
local mechPhaseHeaderPool, mechRowPool = {}, {}
local cooldownRowPool, reminderRowPool = {}, {}

local function HideList(pool)
    for _, widget in ipairs(pool) do widget:Hide() end
end

local function HideAllDetailRows()
    HideList(mechPhaseHeaderPool)
    HideList(mechRowPool)
    HideList(cooldownRowPool)
    HideList(reminderRowPool)
end

-- Ligne "puce + texte" générique, réutilisée pour Cooldowns et Reminders (simple liste
-- plate, contrairement aux Mécaniques qui ont des en-têtes de phase).
local function AcquireBulletRow(pool, index, parent, accentColor)
    local row = pool[index]
    if row then return row end

    row = CreateFrame("Frame", nil, parent)
    row:SetSize(DETAIL_WIDTH, ROW_HEIGHT)

    local bullet = row:CreateTexture(nil, "ARTWORK")
    bullet:SetSize(4, 4)
    bullet:SetPoint("LEFT", row, "LEFT", 4, 0)
    bullet:SetColorTexture(accentColor[1], accentColor[2], accentColor[3], 0.9)
    row.bullet = bullet

    local text = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    text:SetPoint("LEFT", row, "LEFT", 16, 0)
    text:SetPoint("RIGHT", row, "RIGHT", 0, 0)
    text:SetJustifyH("LEFT")
    text:SetWordWrap(true)
    row.text = text

    pool[index] = row
    return row
end

-- Empile une liste plate d'entrées {text=...} sous `anchorFrame`, chacune dans son propre
-- pool. Retourne la hauteur totale utilisée (0 si la liste est vide).
local function LayoutBulletList(entries, pool, parent, anchorFrame, accentColor)
    local y = 0
    for i, entry in ipairs(entries or {}) do
        local row = AcquireBulletRow(pool, i, parent, accentColor)
        row:ClearAllPoints()
        row:SetPoint("TOPLEFT", anchorFrame, "TOPLEFT", 0, -y)
        row.text:SetText(entry.text or "")
        row:Show()

        local lineHeight = row.text:GetStringHeight()
        local rowHeight = math.max(ROW_HEIGHT, lineHeight + 6)
        row:SetHeight(rowHeight)
        y = y + rowHeight + 2
    end
    return y
end

-- Bloc "Mécaniques" : phases + événements, avec en-tête de phase teinté.
local function LayoutMechanics(timeline, anchorFrame)
    local y = 0
    local phaseCount, rowCount = 0, 0

    for _, phase in ipairs(timeline.phases or {}) do
        phaseCount = phaseCount + 1
        local header = mechPhaseHeaderPool[phaseCount]
        if not header then
            header = CreateFrame("Frame", nil, detailContainer)
            header:SetSize(DETAIL_WIDTH, PHASE_HEADER_HEIGHT)

            local bg = header:CreateTexture(nil, "BACKGROUND")
            bg:SetAllPoints()
            bg:SetColorTexture(VRT.ACCENT[1] * 0.16, VRT.ACCENT[2] * 0.16, VRT.ACCENT[3] * 0.16, 1)
            header.bg = bg

            local text = header:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            text:SetPoint("LEFT", header, "LEFT", 8, 0)
            text:SetTextColor(VRT.ACCENT[1], VRT.ACCENT[2], VRT.ACCENT[3])
            header.text = text

            mechPhaseHeaderPool[phaseCount] = header
        end
        header:ClearAllPoints()
        header:SetPoint("TOPLEFT", anchorFrame, "TOPLEFT", 0, -y)
        header.text:SetText(phase.name or ("Phase " .. phaseCount))
        header:Show()
        y = y + PHASE_HEADER_HEIGHT + 4

        for _, event in ipairs(phase.events or {}) do
            rowCount = rowCount + 1
            local row = AcquireBulletRow(mechRowPool, rowCount, detailContainer, VRT.ACCENT)
            row:ClearAllPoints()
            row:SetPoint("TOPLEFT", anchorFrame, "TOPLEFT", 0, -y)
            row.text:SetText(event.text or "")
            row:Show()

            local lineHeight = row.text:GetStringHeight()
            local rowHeight = math.max(ROW_HEIGHT, lineHeight + 6)
            row:SetHeight(rowHeight)
            y = y + rowHeight + 2
        end

        y = y + SECTION_GAP
    end

    return y
end

local function ShowTimelineDetail(tier, boss)
    selectedTier, selectedBoss = tier, boss
    local timeline = BossTimelines:GetTimeline(tier, boss)
    HideAllDetailRows()

    if not timeline then
        detailContainer.emptyText:Show()
        detailContainer.titleText:SetText("")
        detailContainer.notesText:SetText("")
        detailContainer.mechPanel:Hide()
        detailContainer.cooldownPanel:Hide()
        detailContainer.reminderPanel:Hide()
        return
    end

    detailContainer.emptyText:Hide()
    detailContainer.titleText:SetText(timeline.name or boss)
    detailContainer.notesText:SetText(timeline.notes or "")

    local notesHeight = detailContainer.notesText:GetStringHeight()
    local y = math.max(notesHeight, 16) + 18

    -- Bloc Mécaniques
    local mechPanel = detailContainer.mechPanel
    mechPanel:ClearAllPoints()
    mechPanel:SetPoint("TOPLEFT", detailContainer, "TOPLEFT", 0, -y)
    local mechHeight = LayoutMechanics(timeline, mechPanel.contentTop)
    mechPanel:SetHeight(24 + mechHeight + 10)
    mechPanel:Show()
    y = y + mechPanel:GetHeight() + BLOCK_GAP

    -- Bloc Cooldowns
    local cooldownPanel = detailContainer.cooldownPanel
    cooldownPanel:ClearAllPoints()
    cooldownPanel:SetPoint("TOPLEFT", detailContainer, "TOPLEFT", 0, -y)
    local cooldownEntries = timeline.cooldowns or {}
    local cooldownHeight = LayoutBulletList(cooldownEntries, cooldownRowPool, detailContainer, cooldownPanel.contentTop, {0.42, 0.69, 0.95})
    if #cooldownEntries > 0 then
        cooldownPanel:SetHeight(24 + cooldownHeight + 10)
        cooldownPanel:Show()
        y = y + cooldownPanel:GetHeight() + BLOCK_GAP
    else
        cooldownPanel:Hide()
    end

    -- Bloc Reminders
    local reminderPanel = detailContainer.reminderPanel
    reminderPanel:ClearAllPoints()
    reminderPanel:SetPoint("TOPLEFT", detailContainer, "TOPLEFT", 0, -y)
    local reminderEntries = timeline.reminders or {}
    local reminderHeight = LayoutBulletList(reminderEntries, reminderRowPool, detailContainer, reminderPanel.contentTop, {0.92, 0.35, 0.14})
    if #reminderEntries > 0 then
        reminderPanel:SetHeight(24 + reminderHeight + 10)
        reminderPanel:Show()
    else
        reminderPanel:Hide()
    end
end

local function RefreshBossList()
    if not bossListContainer then return end
    local y = 0
    for _, tier in ipairs(VRT.RAID_TIERS) do
        local tierLabel = tierLabels[tier]
        if not tierLabel then
            tierLabel = bossListContainer:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            tierLabel:SetTextColor(VRT.ACCENT[1], VRT.ACCENT[2], VRT.ACCENT[3])
            tierLabels[tier] = tierLabel
        end
        tierLabel:ClearAllPoints()
        tierLabel:SetPoint("TOPLEFT", bossListContainer, "TOPLEFT", 0, -y)
        tierLabel:SetText(VRT.RAID_TIER_LABELS[tier] or tier)
        tierLabel:Show()
        y = y + 22

        for _, boss in ipairs(VRT.BOSS_LIST[tier] or {}) do
            local key = tier .. "/" .. boss
            local btn = bossButtons[key]
            if not btn then
                btn = CreateFrame("Button", nil, bossListContainer)
                btn:SetSize(160, ROW_HEIGHT)
                local text = btn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
                text:SetPoint("LEFT", btn, "LEFT", 8, 0)
                btn.text = text
                btn:SetScript("OnClick", function() ShowTimelineDetail(tier, boss) end)
                bossButtons[key] = btn
            end
            btn:ClearAllPoints()
            btn:SetPoint("TOPLEFT", bossListContainer, "TOPLEFT", 0, -y)
            local timeline = BossTimelines:GetTimeline(tier, boss)
            btn.text:SetText(timeline and timeline.name or boss)
            btn:Show()
            y = y + ROW_HEIGHT
        end

        y = y + SECTION_GAP
    end
end

function BossTimelines:BuildOptionsPanel(container)
    bossListContainer = CreateFrame("Frame", nil, container)
    bossListContainer:SetPoint("TOPLEFT", container, "TOPLEFT", 0, 0)
    bossListContainer:SetSize(150, 400)

    local divider = container:CreateTexture(nil, "ARTWORK")
    divider:SetPoint("TOPLEFT", bossListContainer, "TOPRIGHT", 8, 0)
    divider:SetPoint("BOTTOMLEFT", bossListContainer, "BOTTOMRIGHT", 8, 0)
    divider:SetWidth(1)
    divider:SetColorTexture(1, 1, 1, 0.08)

    detailContainer = CreateFrame("Frame", nil, container)
    detailContainer:SetPoint("TOPLEFT", bossListContainer, "TOPRIGHT", 18, 0)
    detailContainer:SetPoint("RIGHT", container, "RIGHT", 0, 0)

    detailContainer.emptyText = detailContainer:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    detailContainer.emptyText:SetPoint("TOPLEFT", 0, 0)
    detailContainer.emptyText:SetText("Sélectionne un boss dans la liste à gauche.")

    detailContainer.titleText = detailContainer:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    detailContainer.titleText:SetPoint("TOPLEFT", 0, 0)

    detailContainer.notesText = detailContainer:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    detailContainer.notesText:SetPoint("TOPLEFT", detailContainer.titleText, "BOTTOMLEFT", 0, -8)
    detailContainer.notesText:SetWidth(DETAIL_WIDTH)
    detailContainer.notesText:SetJustifyH("LEFT")
    detailContainer.notesText:SetWordWrap(true)

    detailContainer.mechPanel = UI.CreateSectionPanel(detailContainer, "Mécaniques", DETAIL_WIDTH)
    detailContainer.cooldownPanel = UI.CreateSectionPanel(detailContainer, "Cooldowns à prévoir", DETAIL_WIDTH)
    detailContainer.reminderPanel = UI.CreateSectionPanel(detailContainer, "Reminders", DETAIL_WIDTH)
    detailContainer.mechPanel:Hide()
    detailContainer.cooldownPanel:Hide()
    detailContainer.reminderPanel:Hide()

    RefreshBossList()
    -- Hauteur généreuse fixe : le plus long boss (Coiled Altar, 4 phases ~25 events)
    -- tient dans cet espace ; le scroll du panneau principal gère le débordement éventuel.
    container.contentHeight = 900
end

function BossTimelines:RefreshOptionsPanel()
    RefreshBossList()
    if selectedTier and selectedBoss then
        ShowTimelineDetail(selectedTier, selectedBoss)
    end
end

-- Enregistré au chargement du fichier (pas dans un handler PLAYER_LOGIN retardé) :
-- s'enregistrer pendant un combat en cours peut déclencher ADDON_ACTION_FORBIDDEN.
timerFrame:RegisterEvent("ENCOUNTER_START")
timerFrame:RegisterEvent("ENCOUNTER_END")
timerFrame:SetScript("OnEvent", function(self, event, encounterID, encounterName, ...)
    local db = VRT.db and VRT.db.modules.BossTimelines
    if not db or not db.enabled then return end

    if event == "ENCOUNTER_START" then
        for tier, bosses in pairs(VRT.BOSS_LIST) do
            for _, boss in ipairs(bosses) do
                local timeline = BossTimelines:GetTimeline(tier, boss)
                if timeline and timeline.journalEncounterID == encounterID then
                    BossTimelines:StartEncounter(tier, boss)
                    return
                end
            end
        end
    elseif event == "ENCOUNTER_END" then
        BossTimelines:StopEncounter()
    end
end)
