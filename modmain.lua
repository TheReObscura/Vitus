PrefabFiles = {
    "vitus",
}

AddReplicableComponent("bloodreserves")
AddReplicableComponent("energy")

AddPrefabPostInit("player_classified", function(inst)
    inst.currentblood = GLOBAL.net_ushortint(
        inst.GUID,
        "bloodreserves.currentblood",
        "bloodreservesdirty"
    )
    inst.currentenergy = GLOBAL.net_ushortint(
        inst.GUID,
        "energy.currentenergy",
        "energydirty"
    )
end)

AddComponentPostInit("bloodreserves")
AddComponentPostInit("energy")

AddModCharacter("V1", "MALE")