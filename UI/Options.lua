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

-- Chaque entrée : { key, label, moduleName (optionnel, pour le toggle enabled), group }
-- "group" sert uniquement à regrouper visuellement la sidebar (voir CreateSidebarButton) ;
-- il n'a aucun effet sur la logique de sélection/construction des panneaux.
local TABS = {
    { key = "General", label = "Général", group = 1 },
    { key = "AuraTracking", label = "Auras", moduleName = "AuraTracking", group = 1 },
    { key = "ReadyCheck", label = "Ready Check", moduleName = "ReadyCheck", group = 1 },

    { key = "BossTimelines", label = "Codex", moduleName = "BossTimelines", group = 2 },
    { key = "EncounterAlerts", label = "Alerts", moduleName = "EncounterAlerts", group = 2 },

    { key = "AuraSounds", label = "Aura Sounds", moduleName = "AuraSounds", group = 3 },
    { key = "Assignments", label = "Assignments", moduleName = "Assignments", group = 3 },
    { key = "Nicknames", label = "Surnoms", moduleName = "Nicknames", group = 3 },

    { key = "VersionCheck", label = "Version", moduleName = "VersionCheck", group = 4 },
}

-- fromBottom: si vrai, yOffset s'ancre au BOTTOMLEFT du parent (compté depuis le bas)
-- au lieu du TOPLEFT (compté depuis le haut).
local function CreateSidebarButton(parent, yOffset, tab, fromBottom)
    local btn = CreateFrame("Button", nil, parent)
    btn:SetSize(SIDEBAR_WIDTH, 24)
    if fromBottom then
        btn:SetPoint("BOTTOMLEFT", parent, "BOTTOMLEFT", 0, yOffset)
    else
        btn:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, -yOffset)
    end

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
    buttonList:SetPoint("BOTTOMLEFT", 0, 10)
    buttonList:SetWidth(SIDEBAR_WIDTH)

    -- Regroupe les onglets par "group" avec un séparateur entre chaque groupe. Le dernier
    -- groupe (ex: Version Check) est ancré au bas de la sidebar plutôt qu'à la suite des
    -- autres, pour rester visible et distinct peu importe le nombre d'onglets au-dessus.
    local GROUP_GAP = 14
    local lastGroupID = TABS[#TABS].group

    local y = 0
    local currentGroup = nil
    for _, tab in ipairs(TABS) do
        if tab.group ~= lastGroupID then
            if currentGroup and tab.group ~= currentGroup then
                y = y + GROUP_GAP
                local divider = buttonList:CreateTexture(nil, "ARTWORK")
                divider:SetPoint("TOPLEFT", buttonList, "TOPLEFT", 8, -(y - GROUP_GAP / 2))
                divider:SetPoint("TOPRIGHT", buttonList, "TOPRIGHT", -8, -(y - GROUP_GAP / 2))
                divider:SetHeight(1)
                divider:SetColorTexture(1, 1, 1, 0.08)
            end
            currentGroup = tab.group
            tabButtons[tab.key] = CreateSidebarButton(buttonList, y, tab)
            y = y + 24
        end
    end

    local bottomY = 0
    for i = #TABS, 1, -1 do
        local tab = TABS[i]
        if tab.group == lastGroupID then
            tabButtons[tab.key] = CreateSidebarButton(buttonList, bottomY, tab, true)
            bottomY = bottomY + 24
        end
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

local SECTION_WIDTH = 560

local function BuildGeneralPanel(container)
    if generalPanelBuilt then return end
    generalPanelBuilt = true

    -- Bloc "Général" : verrouillage et échelle des fenêtres flottantes
    local generalPanel = UI.CreateSectionPanel(container, "Général", SECTION_WIDTH)
    generalPanel:SetPoint("TOPLEFT", container, "TOPLEFT", 0, 0)

    local lockCheck = UI.CreateFlatCheck(generalPanel, "ValhollLockCheck", "Verrouiller les fenêtres", generalPanel.contentTop, -14)
    lockCheck:ClearAllPoints()
    lockCheck:SetPoint("TOPLEFT", generalPanel.contentTop, "BOTTOMLEFT", 12, -14)
    lockCheck:SetScript("OnClick", function(self)
        VRT.db.general.locked = self:GetChecked() and true or false
        VRT:GetModule("AnchorManager"):SetAllLocked(VRT.db.general.locked)
    end)
    generalWidgets.lockCheck = lockCheck

    local scaleSlider = UI.CreateFlatSlider(generalPanel, "ValhollScaleSlider", "Échelle globale", 0.5, 2.0, 0.1, lockCheck, -30)
    scaleSlider:ClearAllPoints()
    scaleSlider:SetPoint("TOPLEFT", lockCheck, "BOTTOMLEFT", 0, -30)
    scaleSlider:SetScript("OnValueChanged", function(self, value)
        VRT.db.general.scale = value
        self.valueText:SetText(string.format("%.1f", value))
    end)
    generalWidgets.scaleSlider = scaleSlider

    local generalPanelHeight = 24 + 14 + 16 + 30 + 14 + 16
    generalPanel:SetHeight(generalPanelHeight)

    -- Bloc "Modules actifs" : activer/désactiver chaque module (effectif après /reload)
    local modulesPanel = UI.CreateSectionPanel(container, "Modules actifs", SECTION_WIDTH)
    modulesPanel:SetPoint("TOPLEFT", generalPanel, "BOTTOMLEFT", 0, -16)

    local anchor = modulesPanel.contentTop
    generalWidgets.moduleChecks = {}
    local numModuleChecks = 0
    for _, tab in ipairs(TABS) do
        if tab.moduleName then
            local check = UI.CreateFlatCheck(modulesPanel, "ValhollModCheck" .. tab.moduleName, tab.label, anchor, -10)
            check:ClearAllPoints()
            check:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 12, -10)
            check:SetScript("OnClick", function(self)
                VRT.db.modules[tab.moduleName].enabled = self:GetChecked() and true or false
                print("|cFF25C7EB[Valholl]|r " .. tab.label .. " " .. (self:GetChecked() and "activé" or "désactivé") .. " (effectif après /reload).")
            end)
            generalWidgets.moduleChecks[tab.moduleName] = check
            anchor = check
            numModuleChecks = numModuleChecks + 1
        end
    end

    local modulesPanelHeight = 24 + (numModuleChecks * 26) + 14
    modulesPanel:SetHeight(modulesPanelHeight)

    -- Bloc "Gestion" : action de réinitialisation, mise en avant comme la référence
    local managePanel = UI.CreateSectionPanel(container, "Gestion", SECTION_WIDTH)
    managePanel:SetPoint("TOPLEFT", modulesPanel, "BOTTOMLEFT", 0, -16)

    local resetBtn = UI.CreateFlatButton(managePanel, "ValhollResetBtn", "Réinitialiser la configuration", 220, 24)
    resetBtn:SetPoint("TOPLEFT", managePanel.contentTop, "BOTTOMLEFT", 12, -14)
    resetBtn.bg:SetColorTexture(0.3, 0.12, 0.12, 1)
    resetBtn:SetScript("OnClick", function()
        SlashCmdList["VALHOLLRAIDTOOL"]("reset")
        Options:RefreshGeneral()
    end)

    local managePanelHeight = 24 + 14 + 24 + 14
    managePanel:SetHeight(managePanelHeight)

    container.contentHeight = generalPanelHeight + 16 + modulesPanelHeight + 16 + managePanelHeight + 20
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
