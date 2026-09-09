local Integrity = Class(function (self, inst)
    self.inst = inst

    local classified = inst.player_classified
    if TheWorld.ismastersim then
        self.classified = classified
    elseif classified and self.classified == nil then
        self:AttachClassified(classified)
    end

end)
function Integrity:AttachClassified(classified)
    self.classified = classified
    self.ondetachclassified = function() self:DetachClassified() end
    self.inst:ListenForEvent("onremove", self.ondetachclassified, classified)
end

function Integrity:DetachClassified()
    self.classified = nil
    self.ondetachclassified = nil
end

function Integrity:SetCurrent(currentintegrity)
    if self.classified ~= nil then
        -- self.classified:SetValue("currentblood", currentblood)
    end
end

function Integrity:GetCurrent()

end

function Integrity:GetMax()

end

function Integrity:GetPercent()

end

function Integrity:IsDepleted() -- TODO: иное название.

end


return Integrity