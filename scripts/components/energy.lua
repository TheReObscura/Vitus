local UPDATE_PERIOD = 1

local function oncurrentenergy(self, currentenergy)
    self.inst.replica.energy:SetCurrent(currentenergy)
end
local function OnTaskTick(inst, self)
    self:Update(UPDATE_PERIOD)
end

local Energy = Class(function(self, inst)
    self.inst = inst
    self.maxenergy = 300
    self.currentenergy = self.maxenergy

    self.recovering = true

    self.recoverydelay= 0
    self.recoverytime = 3
    self.recoveryspeed = 0.5
    
    self.updatetask = self.inst:DoPeriodicTask(UPDATE_PERIOD, OnTaskTick, nil, self)
end,
nil,
{
    currentenergy = oncurrentenergy,
})

function Energy:IsPaused()
    return not self.recovering
end

function Energy:CanConsume(amount)
    return self.currentenergy >= amount
end

function Energy:Pause()
    self.recovering = false
    if self.updatetask ~= nil then
        self.updatetask:Cancel()
        self.updatetask = nil
    end
end

function Energy:Resume()
    self.recovering = true

    if self.updatetask == nil then
          self.updatetask = self.inst:DoPeriodicTask(UPDATE_PERIOD, OnTaskTick, nil, self)
    end
end

function Energy:GetPercent()
    return self.currentenergy / self.maxenergy
end

function  Energy:SetPercent(p, overtime)
    self:SetCurrent(p*self.maxenergy, overtime)
end

function Energy:SetCurrent(currentenergy, overtime)
    local oldenergy = self.currentenergy
    self.currentenergy = math.clamp(currentenergy, 0 , self.maxenergy)

    self.inst:PushEvent("energydelta",{
        oldprecent = oldenergy /self.maxenergy,
        newpercent = self.currentenergy/self.maxenergy,
        overtime = overtime,
        delta = self.currentenergy - oldenergy
    })
end

function Energy:DoDelta(delta, overtime)
    self:SetCurrent(self.currentenergy + delta, overtime)
end

function Energy:ConsumeEnergy(amount)
    if self:IsPaused() then
        return false
    end

    local temperaturemodifier =
        self.inst.components.temperaturecoefficients:GetEnergyRecovery()

    local actualamount = amount * temperaturemodifier

    print("[Energy] Consume:", amount, "actual:", actualamount, "current:", self.currentenergy)

    if not self:CanConsume(actualamount) then
        print("[Energy] Not enough energy")
        return false
    end

    self:DoDelta(-actualamount)

    self.recoverydelay = self.recoverytime

    print("[Energy] Consumed! Current:", self.currentenergy, "Recovery delay:", self.recoverydelay)

    return true
end

function Energy:RecoverEnergy(dt)
    if self:IsPaused() then
        return
    end

    if self.recoverydelay > 0 then
        self.recoverydelay = math.max(0, self.recoverydelay - dt)

        print("[Energy] Delay:", self.recoverydelay)

        return
    end

    local temperaturemodifier =
        self.inst.components.temperaturecoefficients:GetEnergyRecovery()

    local recovery = self.recoveryspeed * temperaturemodifier * dt

    self:DoDelta(recovery)

    print("[Energy] Recovery:", recovery, "Current:", self.currentenergy)
end

function Energy:Update(dt)
    self:RecoverEnergy(dt)
end

function Energy:LongUpdate(dt)
     self:Update(dt)
end

function Energy:OnSave()
   return self.currentenergy ~= self.maxenergy and {energy = self.currentenergy} or nil
end

function Energy:OnLoad(data)
        if data.energy ~= nil and self.currentenergy ~= data.energy then
        self.currentenergy = data.energy
        self:DoDelta(0)
    end
end

function Energy:OnRemoveFromEntity()
        if self.updatetask ~= nil then
        self.updatetask:Cancel()
        self.updatetask = nil
    end
end

function Energy:GetDebugString()
    return string.format(
        "%2.1f/%2.1f | Rate: %2.2f (%2.1f*%2.1f) | Paused: %s",
        self.currentenergy, self.maxenergy, self.recoveryspeed,
        self.inst.components.temperaturecoefficients:GetEnergyRecovery(),
        tostring(self:IsPaused())
    )
end


return Energy