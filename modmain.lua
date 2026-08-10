PrefabFiles = {
    "vitus",
}

AddReplicableComponent("bloodreserves")

AddPrefabPostInit("player_classified", function(inst)
    inst.currentblood = GLOBAL.net_ushortint(
        inst.GUID,
        "bloodreserves.currentblood",
        "bloodreservesdirty"
    )

    inst.currentblood:set(70)
end)

AddComponentPostInit("bloodreserves", function(self)
    print("BLOODRESERVES CREATED")
end)

AddModCharacter("V1", "MALE")