local TemperatureCoefficients  = Class(function (self, inst)
    -- COLD
    self.cold_start_temp = 0
    self.cold_end_temp = -20

    self.cold_blooddraining_start = 0.5 -- т.к мы получаем значение, на которое будем умножать. 0.5 ибо по задумке у него медленее циркулирует кровь из-за замерезания системы.
    self.cold_blooddraining_end = 0.2 -- конечный результат. Хочу поработать с линейной зависимостью.

    -- HELL(hot i mean)
    self.hot_start_temp = 70
    self.hot_end_temp = 90

    self.hot_blooddraining_start = 2
    self.hot_blooddraining_end = 2.5
end)

function TemperatureCoefficients:GetBloodDraining()
    local temperature = self.inst.components.temperature

    if temperature:IsFreezing() then
        local progress = (temperature.current - self.cold_start_temp)
            / (self.cold_end_temp - self.cold_start_temp)

        progress = math.clamp(progress, 0, 1)

        return self.cold_blooddraining_start
            + (self.cold_blooddraining_end - self.cold_blooddraining_start) * progress

    elseif temperature:IsOverheating() then
        local progress = (temperature.current - self.hot_start_temp)
            / (self.hot_end_temp - self.hot_start_temp)

        progress = math.clamp(progress, 0, 1)

        return self.hot_blooddraining_start
            + (self.hot_blooddraining_end - self.hot_blooddraining_start) * progress
    end

    return 1
end

return TemperatureCoefficients 