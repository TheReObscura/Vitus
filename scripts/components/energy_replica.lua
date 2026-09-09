local Energy = Class(function(self, inst)
    self.inst = inst

    local classified = inst.player_classified
    if TheWorld.ismastersim then
        self.classified = classified
    elseif classified and self.classified == nil then
        self:AttachClassified(classified)
    end
    
end)

function Energy:AttachClassified(classified)
    self.classified = classified
    self.ondetachclassified = function() self:DetachClassified() end
    self.inst:ListenForEvent("onremove", self.ondetachclassified, classified)
end

function Energy:DetachClassified()
    self.classified = nil
    self.ondetachclassified = nil
end

function Energy:SetCurrent(currentenergy)
    if self.classified ~= nil then
        self.classified:SetValue("currentenergy", currentenergy)
    end
end

function Energy:GetCurrent()
    if self.inst.components.energy ~= nil then
        return self.inst.components.energy.current
    elseif self.classified ~= nil then
        return self.classified.currentenergy:value()
    else
        return 300
    end
end

function Energy:GetMax()
    return 300
end

function Energy:GetPercent()
    return self:GetCurrent() / self:GetMax()
end

return Energy
