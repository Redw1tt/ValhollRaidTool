local addonName, VRT = ...

-- Compare le temps écoulé sur le pull actuel au meilleur temps enregistré pour ce boss
-- (ex: "en avance de 12s sur le meilleur pull"). Les records sont stockés localement.
-- VRT.db.modules.PaceComparison.bestPulls[tier][boss] = bestElapsedSeconds

local PaceComparison = {}
VRT:RegisterModule("PaceComparison", PaceComparison)

local currentTier, currentBoss

function PaceComparison:GetBest(tier, boss)
    local db = VRT.db.modules.PaceComparison
    db.bestPulls = db.bestPulls or {}
    db.bestPulls[tier] = db.bestPulls[tier] or {}
    return db.bestPulls[tier][boss]
end

function PaceComparison:RecordPull(tier, boss, elapsed, wasKill)
    local db = VRT.db.modules.PaceComparison
    db.bestPulls = db.bestPulls or {}
    db.bestPulls[tier] = db.bestPulls[tier] or {}

    local best = db.bestPulls[tier][boss]
    if wasKill and (not best or elapsed < best) then
        db.bestPulls[tier][boss] = elapsed
    end
end

function PaceComparison:GetDelta(tier, boss, elapsed)
    local best = self:GetBest(tier, boss)
    if not best then return nil end
    return elapsed - best
end

function PaceComparison:OnInitialize()
    local db = VRT.db.modules.PaceComparison
    if not db or not db.enabled then return end
    db.bestPulls = db.bestPulls or {}
end
