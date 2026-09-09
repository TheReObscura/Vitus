local MakePlayerCharacter = require "prefabs/player_common"

local assets =
{
    Asset("ANIM", "anim/vitus.zip"),
    Asset("ANIM", "anim/ghost_vitus_build.zip"),

    Asset("ATLAS", "bigportraits/vitus.xml"),
    Asset("IMAGE", "bigportraits/vitus.tex"),
}
local prefabs = {}

local function master_postinit(inst)
        -- работа с температурой
    inst:AddComponent("temperaturecoefficients")

    inst.components.health:SetMaxHealth(100)

    inst.components.hunger:SetMax(100)
    inst.components.hunger:Pause()
        -- работа с резервами. 
    inst:AddComponent("bloodreserves")
        -- работа с энергией
    inst:AddComponent("energy")
    
    inst.components.sanity:SetMax(200)

    inst:ListenForEvent("respawn", function(inst)
        print("V1 RESPAWNED!")
        inst.components.bloodreserves:SetCurrent(70)
        inst.components.energy:SetCurrent(300)
    end)
end

local common_postinit = function(inst)

end

return MakePlayerCharacter(
    "vitus",
    prefabs,
    assets,
    common_postinit,
    master_postinit
)