local addonName, VRT = ...

--[[
Format attendu pour chaque fichier de boss (rempli au fur et à mesure des kills) :

VRT.Timelines["MidnightS1"]["Beloren"] = {
    name = "Beloren",
    journalEncounterID = nil,
    phases = {
        { name = "Phase 1", events = {
            { time = 8,  spellID = nil, text = "Premier cast", duration = 4 },
            { time = 20, spellID = nil, text = "Mécanique X", duration = 0 },
        }},
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

-- ===== Panneau intégré au shell d'options (onglet "Timelines") =====

local optionsContainer, bossListContainer, detailContainer
local selectedTier, selectedBoss
local bossButtons = {}
local tierLabels = {}
local phaseLabelPool = {}
local eventRowPool = {}

local function HideDetailRows()
    for _, label in ipairs(phaseLabelPool) do label:Hide() end
    for _, row in ipairs(eventRowPool) do row:Hide() end
end

local function ShowTimelineDetail(tier, boss)
    selectedTier, selectedBoss = tier, boss
    local timeline = BossTimelines:GetTimeline(tier, boss)
    HideDetailRows()

    if not timeline then
        detailContainer.emptyText:Show()
        detailContainer.titleText:SetText("")
        detailContainer.notesText:SetText("")
        return
    end

    detailContainer.emptyText:Hide()
    detailContainer.titleText:SetText(timeline.name or boss)
    detailContainer.notesText:SetText(timeline.notes or "")

    local anchor = detailContainer.notesText
    local phaseIndex, rowIndex = 0, 0

    for _, phase in ipairs(timeline.phases or {}) do
        phaseIndex = phaseIndex + 1
        local phaseLabel = phaseLabelPool[phaseIndex]
        if not phaseLabel then
            phaseLabel = detailContainer:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            phaseLabel:SetTextColor(VRT.ACCENT[1], VRT.ACCENT[2], VRT.ACCENT[3])
            phaseLabelPool[phaseIndex] = phaseLabel
        end
        phaseLabel:ClearAllPoints()
        phaseLabel:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -14)
        phaseLabel:SetText(phase.name or ("Phase " .. phaseIndex))
        phaseLabel:Show()
        anchor = phaseLabel

        for _, event in ipairs(phase.events or {}) do
            rowIndex = rowIndex + 1
            local row = eventRowPool[rowIndex]
            if not row then
                row = detailContainer:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
                row:SetWidth(580)
                row:SetJustifyH("LEFT")
                eventRowPool[rowIndex] = row
            end
            row:ClearAllPoints()
            row:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 8, -6)
            row:SetText("- " .. (event.text or ""))
            row:Show()
            anchor = row
        end
    end
end

local function RefreshBossList()
    if not bossListContainer then return end
    local index = 0
    for _, tier in ipairs(VRT.RAID_TIERS) do
        local tierLabel = tierLabels[tier]
        if not tierLabel then
            tierLabel = bossListContainer:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            tierLabel:SetTextColor(VRT.ACCENT[1], VRT.ACCENT[2], VRT.ACCENT[3])
            tierLabels[tier] = tierLabel
        end
        index = index + 1
        tierLabel:ClearAllPoints()
        tierLabel:SetPoint("TOPLEFT", bossListContainer, "TOPLEFT", 0, -(index - 1) * 22 - (index > 1 and 10 or 0))
        tierLabel:SetText(VRT.RAID_TIER_LABELS[tier] or tier)
        tierLabel:Show()

        for _, boss in ipairs(VRT.BOSS_LIST[tier] or {}) do
            index = index + 1
            local key = tier .. "/" .. boss
            local btn = bossButtons[key]
            if not btn then
                btn = CreateFrame("Button", nil, bossListContainer)
                btn:SetSize(160, 20)
                local text = btn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
                text:SetPoint("LEFT", btn, "LEFT", 8, 0)
                btn.text = text
                btn:SetScript("OnClick", function() ShowTimelineDetail(tier, boss) end)
                bossButtons[key] = btn
            end
            btn:ClearAllPoints()
            btn:SetPoint("TOPLEFT", bossListContainer, "TOPLEFT", 0, -(index - 1) * 22 - 10)
            local timeline = BossTimelines:GetTimeline(tier, boss)
            btn.text:SetText(timeline and timeline.name or boss)
            btn:Show()
        end
    end
end

function BossTimelines:BuildOptionsPanel(container)
    optionsContainer = container

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
    detailContainer.notesText:SetWidth(580)
    detailContainer.notesText:SetJustifyH("LEFT")

    RefreshBossList()
    -- Hauteur généreuse fixe : le plus long boss (Coiled Altar, 4 phases ~25 events)
    -- tient dans cet espace ; le scroll du panneau principal gère le débordement éventuel.
    container.contentHeight = 700
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
