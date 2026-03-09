require("worldsettingsutil")

local assets =
{
    Asset("ANIM", "anim/mesa_cactus_small.zip"),

    Asset("IMAGE", "images/oe_minimapimages.tex"),
    Asset("ATLAS", "images/oe_minimapimages.xml"),
}

local prefabs =
{
    "cactus_meat",
    "cactus_flower",
}

local function OnPicked(inst, picker)
    if inst.Physics ~= nil then
        inst.Physics:SetActive(false)
    end

    inst.AnimState:PlayAnimation(inst.has_flower and "picked_flower" or "picked")
    inst.AnimState:PushAnimation("empty", true)

    if picker ~= nil then
        if picker.components.combat ~= nil
        and not (picker.components.inventory ~= nil and picker.components.inventory:EquipHasTag("bramble_resistant"))
        and not picker:HasTag("shadowminion") then
            picker.components.combat:GetAttacked(inst, TUNING.OE_MESA_CACTUS_DAMAGE) -- Smaller cactus, smaller damage!
            picker:PushEvent("thorns")
        end

        if inst.has_flower then
            local loot = SpawnPrefab("cactus_flower")

            if loot ~= nil and loot.components.inventoryitem ~= nil then
                loot.components.inventoryitem:InheritWorldWetnessAtTarget(inst)

                if picker.components.inventory ~= nil then
                    picker.components.inventory:GiveItem(loot, nil, inst:GetPosition())
                else
                    local x, y, z = inst.Transform:GetWorldPosition()
                    loot.components.inventoryitem:DoDropPhysics(x, y, z, true)
                end
            end
        end
    end

    inst.has_flower = false
end

local function OnRegen(inst, issummer)
    if TheWorld.state.issummer then
        inst.AnimState:PlayAnimation("grow_flower")
        inst.AnimState:PushAnimation("idle_flower", true)
        
        inst.has_flower = true
    else
        inst.AnimState:PlayAnimation("grow")
        inst.AnimState:PushAnimation("idle", true)
        inst.has_flower = false
    end

    if inst.Physics ~= nil then
        inst.Physics:SetActive(true)
    end
end

local function OnEmpty(inst)
    if inst.Physics ~= nil then
        inst.Physics:SetActive(false)
    end

    inst.AnimState:PlayAnimation("empty", true)
    inst.has_flower = false
end

local function GetStatus(inst, viewer)
    return (inst.components.burnable:IsBurning() and "BURNING")
    or (not inst.components.pickable:CanBePicked() and "PICKED")
    or "GENERIC"
end

local function OnEntityWake(inst, issummer)
    if inst.components.pickable ~= nil and inst.components.pickable.canbepicked then
        inst.has_flower = TheWorld.state.issummer
        inst.AnimState:PlayAnimation(inst.has_flower and "idle_flower" or "idle", true)
    else
        inst.AnimState:PlayAnimation("empty", true)
        inst.has_flower = false
    end
end

local function OnPreLoad(inst, data)
    WorldSettings_Pickable_PreLoad(inst, data, TUNING.OE_MESA_CACTUS_SMALL_REGROW_TIME)
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    local minimap = inst.entity:AddMiniMapEntity()
    minimap:SetIcon("oe_mesa_cactus_small.tex")

    MakeObstaclePhysics(inst, .25)

    inst.AnimState:SetBank("mesa_cactus_small")
    inst.AnimState:SetBuild("mesa_cactus_small")
    inst.AnimState:PlayAnimation("idle", true)

    inst:AddTag("plant")
    inst:AddTag("thorny")

    MakeSnowCoveredPristine(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = GetStatus

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

    inst:AddComponent("pickable")
    inst.components.pickable.picksound = "dontstarve/wilson/harvest_sticks"
    -- TO DO: World Customization.
    -- WorldSettings_Pickable_RegenTime(inst, TUNING.OE_MESA_CACTUS_SMALL_REGROW_TIME)
    inst.components.pickable:SetUp("cactus_meat", TUNING.OE_MESA_CACTUS_SMALL_REGROW_TIME)
    inst.components.pickable.onregenfn      = OnRegen
    inst.components.pickable.onpickedfn     = OnPicked
    inst.components.pickable.makeemptyfn    = OnEmpty

    -- inst.OnPreLoad = OnPreLoad
    inst.OnEntityWake = OnEntityWake

    -- KYNO:
    -- Do we want to mess with this? If yes, then could do like 
    -- normal cactus which only regrow if you burn them.
    -- AddToRegrowthManager(inst)

    MakeSnowCovered(inst)

    MakeSmallBurnable(inst)
    MakeSmallPropagator(inst)
    MakeHauntableIgnite(inst)

    return inst
end

return Prefab("oe_mesa_cactus_small", fn, assets, prefabs)