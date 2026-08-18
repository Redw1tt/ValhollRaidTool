local addonName, VRT = ...
local UI = VRT.UI

local Options = {}
VRT:RegisterModule("Options", Options)

local PANEL_WIDTH, PANEL_HEIGHT = 960, 640
local SIDEBAR_WIDTH = 140
local TITLEBAR_HEIGHT = 28

local optionsFrame
local tabButtons = {}
local activeTabKey

-- Chaque entrée : { key, label, moduleName (optionnel, pour le toggle enabled) }
local TABS = {
    { key = "General", label = "Général" },
    { key = "AuraTracking", label = "Auras", moduleName = "AuraTracking" },
    { key = "CooldownCheck", label = "Cooldowns", moduleName = "CooldownCheck" },
    { key = "Reminders", label = "Reminders", moduleName = "Reminders" },
    { key = "Nicknames", label = "Surnoms", moduleName = "Nicknames" },
    { key = "ReadyCheck", label = "Ready Check", moduleName = "ReadyCheck" },
    { key = "Assignments", label = "Assignments", moduleName = "Assignments" },
    { key = "PaceComparison", label = "Pace", moduleName = "PaceComparison" },
    { key = "WAImports", label = "WA Imports", moduleName = "WAImports" },
    { key = "VersionCheck", label = "Version", moduleName = "VersionCheck" },
    { key = "BossTimelines", label = "Timelines", moduleName = "BossTimelines" },
    { key = "EncounterAlerts", label = "Alerts", moduleName = "EncounterAlerts" },
}

local function CreateSidebarButton(parent, index, tab)
    local btn = CreateFrame("Button", nil, parent)
    btn:SetSize(SIDEBAR_WIDTH, 24)
    btn:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, -(index - 1) * 24)

    local bg = btn:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(0, 0, 0, 0)
    btn.bg = bg

    local text = btn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    text:SetPoint("LEFT", btn, "LEFT", 12, 0)
    text:SetText(tab.label)
    btn.text = text

    btn:SetScript("OnEnter", function()
        if activeTabKey ~= tab.key then
            bg:SetColorTexture(1, 1, 1, 0.05)
        end
    end)
    btn:SetScript("OnLeave", function()
        if activeTabKey ~= tab.key then
            bg:SetColorTexture(0, 0, 0, 0)
        end
    end)
    btn:SetScript("OnClick", function() Options:SelectTab(tab.key) end)

    return btn
end

local function BuildFrame()
    if optionsFrame then return optionsFrame end

    optionsFrame = CreateFrame("Frame", "ValhollOptionsFrame", UIParent)
    optionsFrame:SetSize(PANEL_WIDTH, PANEL_HEIGHT)
    optionsFrame:SetPoint("CENTER")
    optionsFrame:SetMovable(true)
    optionsFrame:EnableMouse(true)
    optionsFrame:RegisterForDrag("LeftButton")
    optionsFrame:SetScript("OnDragStart", optionsFrame.StartMoving)
    optionsFrame:SetScript("OnDragStop", optionsFrame.StopMovingOrSizing)
    optionsFrame:SetFrameStrata("DIALOG")
    optionsFrame:Hide()
    tinsert(UISpecialFrames, "ValhollOptionsFrame")

    local bg = optionsFrame:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(0.07, 0.07, 0.08, 0.97)
    UI.ApplyBorder(optionsFrame, 0.05, 0.05, 0.05, 1)

    -- Barre de titre
    local titleBar = CreateFrame("Frame", nil, optionsFrame)
    titleBar:SetPoint("TOPLEFT", 0, 0)
    titleBar:SetPoint("TOPRIGHT", 0, 0)
    titleBar:SetHeight(TITLEBAR_HEIGHT)
    local titleBarBg = titleBar:CreateTexture(nil, "ARTWORK")
    titleBarBg:SetAllPoints()
    titleBarBg:SetColorTexture(VRT.ACCENT[1] * 0.18, VRT.ACCENT[2] * 0.18, VRT.ACCENT[3] * 0.18, 1)

    local title = titleBar:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    title:SetPoint("LEFT", titleBar, "LEFT", 10, 0)
    title:SetText("Valhöll Raid Tool")

    local closeBtn = CreateFrame("Button", nil, titleBar)
    closeBtn:SetSize(20, 20)
    closeBtn:SetPoint("RIGHT", titleBar, "RIGHT", -6, 0)
    local closeText = closeBtn:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    closeText:SetAllPoints()
    closeText:SetText("x")
    closeBtn:SetScript("OnEnter", function() closeText:SetTextColor(1, 0.3, 0.3) end)
    closeBtn:SetScript("OnLeave", function() closeText:SetTextColor(1, 1, 1) end)
    closeBtn:SetScript("OnClick", function() optionsFrame:Hide() end)

    -- Sidebar
    local sidebar = CreateFrame("Frame", nil, optionsFrame)
    sidebar:SetPoint("TOPLEFT", titleBar, "BOTTOMLEFT", 0, 0)
    sidebar:SetPoint("BOTTOMLEFT", optionsFrame, "BOTTOMLEFT", 0, 0)
    sidebar:SetWidth(SIDEBAR_WIDTH)

    local sidebarBg = sidebar:CreateTexture(nil, "BACKGROUND")
    sidebarBg:SetAllPoints()
    sidebarBg:SetColorTexture(0.045, 0.045, 0.05, 1)

    local sidebarDivider = sidebar:CreateTexture(nil, "ARTWORK")
    sidebarDivider:SetPoint("TOPRIGHT", 0, 0)
    sidebarDivider:SetPoint("BOTTOMRIGHT", 0, 0)
    sidebarDivider:SetWidth(1)
    sidebarDivider:SetColorTexture(1, 1, 1, 0.08)

    local buttonList = CreateFrame("Frame", nil, sidebar)
    buttonList:SetPoint("TOPLEFT", 0, -10)
    buttonList:SetSize(SIDEBAR_WIDTH, #TABS * 24)

    for i, tab in ipairs(TABS) do
        tabButtons[tab.key] = CreateSidebarButton(buttonList, i, tab)
    end

    -- Zone de contenu (scrollable : chaque onglet peut dépasser la hauteur visible)
    local scrollFrame = CreateFrame("ScrollFrame", "ValhollOptionsScrollFrame", optionsFrame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", sidebar, "TOPRIGHT", 12, -12)
    scrollFrame:SetPoint("BOTTOMRIGHT", optionsFrame, "BOTTOMRIGHT", -28, 12)

    local content = CreateFrame("Frame", nil, scrollFrame)
    content:SetSize(PANEL_WIDTH - SIDEBAR_WIDTH - 40, 1) -- hauteur ajustée par onglet via SetHeight
    scrollFrame:SetScrollChild(content)
    optionsFrame.scrollFrame = scrollFrame
    optionsFrame.content = content

    return optionsFrame
end

-- ===== Contenu de l'onglet "Général" =====

local generalPanelBuilt = false
local generalWidgets = {}

local function BuildGeneralPanel(container)
    if generalPanelBuilt then return end
    generalPanelBuilt = true

    local lockCheck = UI.CreateFlatCheck(container, "ValhollLockCheck", "Verrouiller les fenêtres", container, 0)
    lockCheck:ClearAllPoints()
    lockCheck:SetPoint("TOPLEFT", container, "TOPLEFT", 0, 0)
    lockCheck:SetScript("OnClick", function(self)
        VRT.db.general.locked = self:GetChecked() and true or false
        VRT:GetModule("AnchorManager"):SetAllLocked(VRT.db.general.locked)
    end)
    generalWidgets.lockCheck = lockCheck

    local scaleSlider = UI.CreateFlatSlider(container, "ValhollScaleSlider", "Échelle globale", 0.5, 2.0, 0.1, lockCheck, -30)
    scaleSlider:SetScript("OnValueChanged", function(self, value)
        VRT.db.general.scale = value
        self.valueText:SetText(string.format("%.1f", value))
    end)
    generalWidgets.scaleSlider = scaleSlider

    local modulesLabel = UI.CreateSectionLabel(container, scaleSlider, "Modules actifs", -30)
    modulesLabel:ClearAllPoints()
    modulesLabel:SetPoint("TOPLEFT", scaleSlider, "BOTTOMLEFT", 0, -30)

    local anchor = modulesLabel
    generalWidgets.moduleChecks = {}
    for _, tab in ipairs(TABS) do
        if tab.moduleName then
            local check = UI.CreateFlatCheck(container, "ValhollModCheck" .. tab.moduleName, tab.label, anchor, -10)
            check:SetScript("OnClick", function(self)
                VRT.db.modules[tab.moduleName].enabled = self:GetChecked() and true or false
                print("|cFF25C7EB[Valholl]|r " .. tab.label .. " " .. (self:GetChecked() and "activé" or "désactivé") .. " (effectif après /reload).")
            end)
            generalWidgets.moduleChecks[tab.moduleName] = check
            anchor = check
        end
    end

    local resetBtn = UI.CreateFlatButton(container, "ValhollResetBtn", "Réinitialiser", 140, 22)
    resetBtn:SetPoint("TOP", anchor, "BOTTOM", 0, -24)
    resetBtn.bg:SetColorTexture(0.3, 0.12, 0.12, 1)
    resetBtn:SetScript("OnClick", function()
        SlashCmdList["VALHOLLRAIDTOOL"]("reset")
        Options:RefreshGeneral()
    end)

    -- Hauteur totale connue: lockCheck(16) + slider(30+14) + label(30+20) + N checks(26 chacun) + reset(24+22)
    local numModuleChecks = 0
    for _, tab in ipairs(TABS) do
        if tab.moduleName then numModuleChecks = numModuleChecks + 1 end
    end
    container.contentHeight = 16 + 30 + 14 + 30 + 20 + (numModuleChecks * 26) + 24 + 22 + 20
end

function Options:RefreshGeneral()
    if not generalPanelBuilt then return end
    generalWidgets.lockCheck:SetChecked(VRT.db.general.locked and true or false)
    generalWidgets.scaleSlider:SetValue(VRT.db.general.scale or 1.0)
    for moduleName, check in pairs(generalWidgets.moduleChecks) do
        local modDB = VRT.db.modules[moduleName]
        check:SetChecked(modDB and modDB.enabled and true or false)
    end
end

-- ===== Placeholder pour les modules sans panneau dédié encore =====

local function BuildPlaceholderPanel(container, tab)
    if container.placeholderBuilt then return end
    container.placeholderBuilt = true

    local text = container:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    text:SetPoint("TOPLEFT", container, "TOPLEFT", 0, 0)
    text:SetText("Pas encore de panneau de configuration pour " .. tab.label .. ".\nActive/désactive ce module depuis l'onglet Général.")
    text:SetJustifyH("LEFT")
    text:SetWidth(320)

    container.contentHeight = 40
end

-- ===== Gestion des onglets =====

local tabContainers = {}

function Options:SelectTab(key)
    local frame = BuildFrame()
    activeTabKey = key

    for tabKey, btn in pairs(tabButtons) do
        if tabKey == key then
            btn.bg:SetColorTexture(VRT.ACCENT[1] * 0.25, VRT.ACCENT[2] * 0.25, VRT.ACCENT[3] * 0.25, 1)
            btn.text:SetTextColor(VRT.ACCENT[1], VRT.ACCENT[2], VRT.ACCENT[3])
        else
            btn.bg:SetColorTexture(0, 0, 0, 0)
            btn.text:SetTextColor(1, 1, 1)
        end
    end

    for tabKey, container in pairs(tabContainers) do
        container:SetShown(tabKey == key)
    end

    local tab
    for _, t in ipairs(TABS) do
        if t.key == key then tab = t; break end
    end
    local ownerModule = tab and tab.moduleName and VRT:GetModule(tab.moduleName)

    if not tabContainers[key] then
        local container = CreateFrame("Frame", nil, frame.content)
        container:SetPoint("TOPLEFT", 0, 0)
        container:SetPoint("TOPRIGHT", 0, 0)
        tabContainers[key] = container

        if key == "General" then
            BuildGeneralPanel(container)
            self:RefreshGeneral()
        elseif ownerModule and ownerModule.BuildOptionsPanel then
            ownerModule:BuildOptionsPanel(container)
        else
            BuildPlaceholderPanel(container, tab or { label = key })
        end
    elseif key == "General" then
        self:RefreshGeneral()
    elseif ownerModule and ownerModule.RefreshOptionsPanel then
        ownerModule:RefreshOptionsPanel()
    end

    self:RefreshLayout()
end

-- Chaque panneau déclare sa propre hauteur (container.contentHeight) ; le scroll child
-- adopte la plus grande valeur entre celle-ci et la zone visible. Le container lui-même
-- a aussi besoin d'une hauteur explicite : sans point BOTTOM ni SetHeight, sa position
-- (GetTop/GetBottom) n'est pas résolvable, ce qui casse l'ancrage de tous ses enfants
-- (ils restent "shown" mais jamais réellement visibles à l'écran). Un module dont le
-- contenu change de taille sans changer d'onglet (ex: repli/dépli d'une section) doit
-- rappeler ceci après avoir mis à jour son propre container.contentHeight.
function Options:RefreshLayout()
    if not optionsFrame or not activeTabKey then return end
    local activeContainer = tabContainers[activeTabKey]
    local minHeight = optionsFrame.scrollFrame:GetHeight()
    local wantedHeight = (activeContainer and activeContainer.contentHeight) or minHeight
    local finalHeight = math.max(wantedHeight, minHeight)
    optionsFrame.content:SetHeight(finalHeight)
    if activeContainer then
        activeContainer:SetHeight(activeContainer.contentHeight or finalHeight)
    end
end

function Options:Toggle()
    local frame = BuildFrame()
    if frame:IsShown() then
        frame:Hide()
    else
        frame:Show()
        self:SelectTab(activeTabKey or "General")
    end
end

function Options:OnInitialize()
    -- Le cadre est construit à la demande (lazy) via Toggle().
end
