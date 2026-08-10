local SourceModifierList = require("util/sourcemodifierlist")
local UPDATE_PERIOD = 1

local function oncurrentblood(self, currentblood)
    self.inst.replica.bloodreserves:SetCurrent(currentblood)
end

local function OnTaskTick(inst, self)
    self:Consume(UPDATE_PERIOD)
end

local Bloodreserves = Class(function (self, inst)
    self.inst = inst
    self.maxblood = 100
    self.currentblood = self.maxblood

    self.blooddrainrate = 0.235 -- Связано с тем, что игроку кровь нужна для всего. быстрая трата = быстрая смерть.
    self.integritydamagerate = 0.75 -- та же причина, что и выше.
    self.overridestarvefn = nil

    self.draining = true

    self.drainmult  = 1 -- пусть будет так. всё равно по коду будет использовать чаще V
    self.drainmultmodifiers = SourceModifierList(self.inst) -- вот это из-за Klei

    self.updatetask = self.inst:DoPeriodicTask(UPDATE_PERIOD, OnTaskTick, nil, self)

    print("BloodReserves created!")
end,
nil,
{
currentblood = oncurrentblood,    
})

function Bloodreserves:IsPaused()
    return not self.draining
end

function Bloodreserves:IsDepleted()
    return self.currentblood <= 0
end

function Bloodreserves:Pause()
    self.draining = false
    if self.updatetask ~= nil then
        self.updatetask:Cancel()
        self.updatetask = nil
    end
end

function Bloodreserves:Resume()
    self.draining = true
    
    if self.updatetask == nil then
        self.updatetask = self.inst:DoPeriodicTask(UPDATE_PERIOD, OnTaskTick, nil, self)
    end
end

function Bloodreserves:GetPercent()
    return self.currentblood / self.maxblood
end

function Bloodreserves:SetPercent(p, overtime)
    self:SetCurrent(p * self.maxblood, overtime)
end

function Bloodreserves:SetCurrent(currentblood, overtime)
    local oldblood = self.currentblood
    self.currentblood = math.clamp(currentblood, 0, self.maxblood)

    self.inst:PushEvent("blooddelta", {
        oldpercent = oldblood / self.maxblood,
        newpercent = self.currentblood/ self.maxblood,
        overtime = overtime,
        delta = self.currentblood-oldblood
    })

   -- if oldblood > 0 then
   --     if self.currentblood <= 0 then
   --         self.inst:PushEvent("startdepleting")
   --         ProfileStatsSet("started_depleting", true)
   --     end
   --  elseif self.currentblood > 0 then
   --     self.inst:PushEvent("stopdepleting")
   --     ProfileStatsSet("stoped_depleting", true)
   --  end
end

function Bloodreserves:DoDelta(delta, overtime, ignore_invincible) 
    -- if self.redirect ~= nil then
    --    self.redirect(self.inst, delta, overtime)
    --    return
    -- end

    -- if not ignore_invincible and self.inst.components.integrity and self.inst.components.integrity:IsInvincible() or self.inst.is_teleporting then
    --     return
    -- end 
    -- TODO: вернуть проверку invincibility после создания Integrity.

    self:SetCurrent(self.currentblood + delta, overtime)
end

function Bloodreserves:GetTemperatureModifier()
    return self.inst.components.temperaturemodifier.GetBloodDraining()
end

function Bloodreserves:Consume(dt, ignore_damage)
    if self:IsPaused() then
        return
    end
    

    if self.currentblood > 0 then
        self:DoDelta(-self.blooddrainrate * dt * self.drainmult * self.drainmultmodifiers:Get() * self:GetTemperatureModifier(), true)

    elseif not ignore_damage then
        if self.overridestarvefn ~= nil then
            self.overridestarvefn(self.inst, dt)
        else
            self.inst.components.integrity:DoDelta(-self.integritydamagerate * dt, true, "blood")
        end
    end
end

function Bloodreserves:LongUpdate(dt)
     self:Consume(dt, true)
end

function Bloodreserves:OnSave()
    return self.currentblood ~= self.maxblood and { bloodreserves = self.currentblood } or nil
end

function Bloodreserves:OnLoad(data)
        if data.bloodreserves ~= nil and self.currentblood ~= data.bloodreserves then
        self.currentblood = data.bloodreserves
        self:DoDelta(0)
    end
end

function Bloodreserves:OnRemoveFromEntity()
        if self.updatetask ~= nil then
        self.updatetask:Cancel()
        self.updatetask = nil
    end
end

function Bloodreserves:GetDebugString()
        local drainrate = self.drainmult * self.drainmultmodifiers:Get()

    return string.format(
        "%2.1f/%2.1f | Rate: %2.2f (%2.1f*%2.1f) | Paused: %s",
        self.currentblood, self.maxblood,
        self.blooddrainrate * drainrate, self.blooddrainrate, drainrate,
        tostring(self:IsPaused())
    )
end

return Bloodreserves