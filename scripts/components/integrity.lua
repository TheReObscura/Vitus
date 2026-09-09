local Integrity = Class(function (self, inst)
self.inst = inst

self.max_integrity = 100
self.current_integrity = self.max_integrity

self.max_overheal= 100
self.current_overheal = 0

self._integrity_redirect = false

end)

function Integrity:SetCurrent(integrity )
end

function Integrity:GetCurrent()
end

function Integrity:GetPercent()

end

function Integrity:SetPercent(percent )
end

function Integrity:DoDelta(delta)
end

function Integrity:SetOverheal(overheal)
end

function Integrity:GetOverheal()
end

function Integrity:GetOverhealPercent()
end

function Integrity:DoOverhealDelta(delta)
end

function Integrity:ApplyDamage(damage)
end

return Integrity