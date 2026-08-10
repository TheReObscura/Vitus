local BloodReserves = Class(function(self, inst)
    self.inst = inst

    local classified = inst.player_classified
    if TheWorld.ismastersim then
        self.classified = classified
    elseif classified and self.classified == nil then
        self:AttachClassified(classified)
    end
    
end)

function BloodReserves:AttachClassified(classified)
    self.classified = classified
    self.ondetachclassified = function() self:DetachClassified() end
    self.inst:ListenForEvent("onremove", self.ondetachclassified, classified)
end

function BloodReserves:DetachClassified()
    self.classified = nil
    self.ondetachclassified = nil
end

function BloodReserves:SetCurrent(currentblood)
    if self.classified ~= nil then
        self.classified:SetValue("currentblood", currentblood)
    end
    print("Current blood:", self.classified.currentblood:value())
end

function BloodReserves:GetCurrent()
    if self.inst.components.bloodreserves ~= nil then
        return self.inst.components.bloodreserves.current
    elseif self.classified ~= nil then
        return self.classified.currentblood:value()
    else
        return 100
    end
end

function BloodReserves:GetMax()
    return 100
end

function BloodReserves:GetPercent()
    return self:GetCurrent() / self:GetMax()
end

function BloodReserves:IsDepleted()
    if self.inst.components.bloodreserves ~= nil then
        return self.inst.components.bloodreserves:IsDepleted()
    else
        return self.classified ~= nil and self.classified.currentblood:value() <= 0
    end
end
return BloodReserves
