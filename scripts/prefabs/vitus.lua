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

    inst.components.health:SetMaxHealth(200)
    inst.components.hunger:SetMax(100)
    inst.components.sanity:SetMax(200)
        -- работа с температурой
    inst:AddComponent("temperaturecoefficients")
        -- работа с резервами. 
    inst:AddComponent("bloodreserves")

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