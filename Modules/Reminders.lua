local addonName, VRT = ...

-- Rappels configurables affichés à des moments clés (ex: avant un pull, à un % de vie du boss).
-- VRT.db.modules.Reminders.list = { { text = "", trigger = "ENCOUNTER_START", tier = nil, boss = nil }, ... }

local Reminders = {}
VRT:RegisterModule("Reminders", Reminders)

local reminderFrame = CreateFrame("Frame")

local function ShowReminder(text)
    local display = VRT.frames.ReminderDisplay
    if not display then
        display = VRT.UI.CreateAnchoredWindow("ValhollReminderDisplay", "", 300, 60)
        display:SetFrameStrata("HIGH")
        display.header:Hide()
        display.text = display:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
        display.text:SetPoint("CENTER")
        display.text:SetJustifyH("CENTER")
        display.text:SetWidth(280)
        VRT.frames.ReminderDisplay = display
        VRT:GetModule("AnchorManager"):Register("ReminderDisplay", display, "TOP", 0, -150)
        display:Hide()
    end
    display.text:SetText(text)
    display:Show()
    C_Timer.After(5, function() display:Hide() end)
end

function Reminders:Fire(trigger, tier, boss)
    local db = VRT.db.modules.Reminders
    if not db or not db.enabled then return end

    for _, reminder in ipairs(db.list or {}) do
        if reminder.trigger == trigger
            and (not reminder.tier or reminder.tier == tier)
            and (not reminder.boss or reminder.boss == boss) then
            ShowReminder(reminder.text)
        end
    end
end

function Reminders:OnInitialize()
    local db = VRT.db.modules.Reminders
    if not db or not db.enabled then return end
    db.list = db.list or {}
end

-- Enregistré au chargement du fichier (pas dans un handler PLAYER_LOGIN retardé) :
-- s'enregistrer pendant un combat en cours peut déclencher ADDON_ACTION_FORBIDDEN.
reminderFrame:RegisterEvent("ENCOUNTER_START")
reminderFrame:RegisterEvent("READY_CHECK")
reminderFrame:SetScript("OnEvent", function(self, event, ...)
    local db = VRT.db and VRT.db.modules.Reminders
    if not db or not db.enabled then return end

    if event == "ENCOUNTER_START" then
        local encounterID = ...
        for tier, bosses in pairs(VRT.BOSS_LIST) do
            for _, boss in ipairs(bosses) do
                local timeline = VRT:GetModule("BossTimelines"):GetTimeline(tier, boss)
                if timeline and timeline.journalEncounterID == encounterID then
                    Reminders:Fire("ENCOUNTER_START", tier, boss)
                    return
                end
            end
        end
    elseif event == "READY_CHECK" then
        Reminders:Fire("READY_CHECK")
    end
end)
