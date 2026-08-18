local addonName, VRT = ...
VRT.UI = VRT.UI or {}
local UI = VRT.UI

-- Bordures sans SetBackdrop (obsolète)
function UI.ApplyBorder(frame, r, g, b, a)
    if not frame.borderLines then
        frame.borderLines = {}
        for i = 1, 4 do
            local line = frame:CreateTexture(nil, "OVERLAY")
            line:SetColorTexture(r or 0.1, g or 0.1, b or 0.1, a or 0.6)
            table.insert(frame.borderLines, line)
        end
        frame.borderLines[1]:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
        frame.borderLines[1]:SetPoint("BOTTOMRIGHT", frame, "TOPRIGHT", 0, -1)
        frame.borderLines[2]:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 0, 0)
        frame.borderLines[2]:SetPoint("TOPRIGHT", frame, "BOTTOMRIGHT", 0, 1)
        frame.borderLines[3]:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
        frame.borderLines[3]:SetPoint("BOTTOMRIGHT", frame, "BOTTOMLEFT", 1, 0)
        frame.borderLines[4]:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, 0)
        frame.borderLines[4]:SetPoint("BOTTOMLEFT", frame, "BOTTOMRIGHT", -1, 0)
    else
        for _, line in ipairs(frame.borderLines) do
            line:SetColorTexture(r or 0.1, g or 0.1, b or 0.1, a or 0.6)
        end
    end
end

function UI.CreateSectionLabel(parent, anchor, text, yOff)
    local label = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    label:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, yOff or -16)
    label:SetText(text)
    label:SetTextColor(VRT.ACCENT[1], VRT.ACCENT[2], VRT.ACCENT[3])
    local line = parent:CreateTexture(nil, "ARTWORK")
    line:SetColorTexture(1, 1, 1, 0.12)
    line:SetHeight(1)
    line:SetPoint("TOPLEFT", label, "BOTTOMLEFT", 0, -4)
    line:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -16, 0)
    line:SetPoint("LEFT", parent, "LEFT", 16, 0)
    return label
end

function UI.CreateFlatSlider(parent, name, label, min, max, step, anchor, yOff)
    local slider = CreateFrame("Slider", name, parent)
    slider:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, yOff or -28)
    slider:SetSize(260, 14)
    slider:SetOrientation("HORIZONTAL")
    slider:SetMinMaxValues(min, max)
    slider:SetValueStep(step)
    slider:EnableMouse(true)

    local track = slider:CreateTexture(nil, "BACKGROUND")
    track:SetPoint("LEFT", 0, 0)
    track:SetPoint("RIGHT", 0, 0)
    track:SetHeight(4)
    track:SetColorTexture(0.2, 0.2, 0.22, 1)

    local thumb = slider:CreateTexture(nil, "OVERLAY")
    thumb:SetSize(12, 16)
    thumb:SetColorTexture(VRT.ACCENT[1], VRT.ACCENT[2], VRT.ACCENT[3], 1)
    slider:SetThumbTexture(thumb)

    local labelText = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    labelText:SetPoint("BOTTOMLEFT", slider, "TOPLEFT", 0, 4)
    labelText:SetText(label)

    local valueText = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    valueText:SetPoint("BOTTOMRIGHT", slider, "TOPRIGHT", 0, 4)
    slider.valueText = valueText

    return slider
end

function UI.CreateFlatCheck(parent, name, label, anchor, yOff)
    local check = CreateFrame("CheckButton", name, parent)
    check:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, yOff or -18)
    check:SetSize(16, 16)

    local box = check:CreateTexture(nil, "ARTWORK")
    box:SetAllPoints()
    box:SetColorTexture(0.15, 0.15, 0.17, 1)
    UI.ApplyBorder(check, 0.05, 0.05, 0.05, 1)

    local mark = check:CreateTexture(nil, "OVERLAY")
    mark:SetPoint("TOPLEFT", 2, -2)
    mark:SetPoint("BOTTOMRIGHT", -2, 2)
    mark:SetColorTexture(VRT.ACCENT[1], VRT.ACCENT[2], VRT.ACCENT[3], 1)
    check:SetCheckedTexture(mark)

    local text = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    text:SetPoint("LEFT", check, "RIGHT", 8, 0)
    text:SetText(label)
    check.label = text

    return check
end

function UI.CreateFlatButton(parent, name, label, width, height)
    local btn = CreateFrame("Button", name, parent)
    btn:SetSize(width or 120, height or 22)
    local bg = btn:CreateTexture(nil, "ARTWORK")
    bg:SetAllPoints()
    bg:SetColorTexture(0.15, 0.15, 0.17, 1)
    UI.ApplyBorder(btn, 0.05, 0.05, 0.05, 1)
    local text = btn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    text:SetAllPoints()
    text:SetJustifyH("CENTER")
    text:SetJustifyV("MIDDLE")
    text:SetText(label)
    btn:SetScript("OnEnter", function() bg:SetColorTexture(VRT.ACCENT[1] * 0.3, VRT.ACCENT[2] * 0.3, VRT.ACCENT[3] * 0.3, 1) end)
    btn:SetScript("OnLeave", function() bg:SetColorTexture(0.15, 0.15, 0.17, 1) end)
    btn.bg = bg
    btn.text = text
    return btn
end

-- Fenêtre flottante générique de style "row list" (utilisée par plusieurs modules d'affichage)
function UI.CreateAnchoredWindow(name, title, defaultW, defaultH)
    local frame = CreateFrame("Frame", name, UIParent)
    frame:SetSize(defaultW or 180, defaultH or 18)
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")

    local header = frame:CreateTexture(nil, "BACKGROUND")
    header:SetAllPoints()
    header:SetColorTexture(0.05, 0.05, 0.05, 0.9)
    frame.header = header

    local titleText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    titleText:SetPoint("CENTER", frame, "CENTER", 0, 0)
    titleText:SetText(title or "")
    frame.titleText = titleText

    frame:SetScript("OnDragStart", function(self)
        if not self.locked then self:StartMoving() end
    end)
    frame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        if self.OnMoved then self:OnMoved() end
    end)

    function frame:SetLocked(locked)
        self.locked = locked
        if locked then
            self:EnableMouse(false)
            self.header:SetColorTexture(0, 0, 0, 0)
            self.titleText:SetText("")
        else
            self:EnableMouse(true)
            self.header:SetColorTexture(0.05, 0.05, 0.05, 0.9)
            self.titleText:SetText(title or "")
        end
    end

    return frame
end
