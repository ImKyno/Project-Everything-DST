
--------------------------------------------------------------------------

local assets =
{
    Asset("ANIM",   "anim/mesa_agave_bush.zip"),
    Asset("ANIM",   "anim/mesa_agave_nectar.zip"),
    Asset("ATLAS",  "images/oe_inventoryimages.xml"),
    Asset("IMAGE",  "images/oe_inventoryimages.tex"),
}

--------------------------------------------------------------------------

local BERRY_SYMBOL = "berries"

--------------------------------------------------------------------------

local function setberries(inst, show)
    if show then
        inst.AnimState:Show(BERRY_SYMBOL)
    else
        inst.AnimState:Hide(BERRY_SYMBOL)
    end
end

--------------------------------------------------------------------------

local function makeemptyfn(inst)
    inst.AnimState:PlayAnimation("idle", true)
    setberries(inst, false)
end

local function makebarrenfn(inst)
    inst.AnimState:PlayAnimation("dead", false)
    setberries(inst, false)
end

local function makefullfn(inst)
    inst.AnimState:PlayAnimation("grow")
    inst.AnimState:PushAnimation("idle", true)
    setberries(inst, true)
end

local function spawnperd(inst)
    if inst:IsValid() then
        local perd = SpawnPrefab("perd")
        local x, y, z = inst.Transform:GetWorldPosition()
        local angle = math.random() * PI2
        perd.Transform:SetPosition(x + math.cos(angle), 0, z + math.sin(angle))
        perd.sg:GoToState("appear")
        perd.components.homeseeker:SetHome(inst)
    end
end

-- We can make something other than a Turkey spawn from it.
local function onpickedfn(inst, picker)
    inst.AnimState:PlayAnimation("picked")
    inst.AnimState:PushAnimation("idle", true)
    setberries(inst, false)

    if not (picker and picker:HasTag("berrythief") or inst._noperd)
        and math.random() < TUNING.PERD_SPAWNCHANCE then
        inst:DoTaskInTime(3 + math.random() * 3, spawnperd)
    end
end

--------------------------------------------------------------------------

local function getregentimefn(inst)
    local max_cycles = inst.components.pickable.max_cycles
    local cycles_left = inst.components.pickable.cycles_left or max_cycles
    local num_cycles_passed = math.max(0, max_cycles - cycles_left)

    return TUNING.BERRY_REGROW_TIME
        + TUNING.BERRY_REGROW_INCREASE * num_cycles_passed
        + TUNING.BERRY_REGROW_VARIANCE * math.random()
end


--------------------------------------------------------------------------

local function dig_up(inst, worker)

    if worker ~= nil then
        worker.SoundEmitter:PlaySound("dontstarve/common/plantdig")
    end

    if inst.components.pickable and inst.components.lootdropper then
        if inst.components.pickable:IsBarren() then
            inst.components.lootdropper:SpawnLootPrefab("twigs")
            inst.components.lootdropper:SpawnLootPrefab("twigs")
        else
            if inst.components.pickable:CanBePicked() then
                for i = 1, 2 do
                    inst.components.lootdropper:SpawnLootPrefab("mesa_agave_nectar")
                end
            end
            inst.components.lootdropper:SpawnLootPrefab("mesa_agave_bush_dug")
        end
    end
    inst:Remove()
end

--------------------------------------------------------------------------

local function mesa_agave_bush()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    MakeSmallObstaclePhysics(inst, .1)

    inst:AddTag("bush")
    inst:AddTag("plant")
    inst:AddTag("renewable")
    inst:AddTag("witherable")

    --inst.MiniMapEntity:SetIcon("mesa_agave_bush.png") -- TODO

    inst.AnimState:SetBank("mesa_agave_bush")
    inst.AnimState:SetBuild("mesa_agave_bush")
    inst.AnimState:PlayAnimation("idle", true)

    setberries(inst, false)

    MakeSnowCoveredPristine(inst)
    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    -- Adjust accordingly, just using berry bush shit for now.
    inst:AddComponent("pickable")
    inst.components.pickable:SetUp("mesa_agave_nectar", TUNING.BERRY_REGROW_TIME, 2)
    inst.components.pickable.onpickedfn     = onpickedfn
    inst.components.pickable.makeemptyfn    = makeemptyfn
    inst.components.pickable.makebarrenfn   = makebarrenfn
    inst.components.pickable.makefullfn     = makefullfn
    inst.components.pickable.getregentimefn = getregentimefn
    inst.components.pickable.max_cycles     = TUNING.BERRYBUSH_CYCLES + math.random(2)
    inst.components.pickable.cycles_left    = inst.components.pickable.max_cycles
    inst.components.pickable:MakeEmpty()

    -- Maybe not?
    inst:AddComponent("witherable")

    MakeLargeBurnable(inst)
    MakeMediumPropagator(inst)

    inst:AddComponent("lootdropper")

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.DIG)
    inst.components.workable:SetWorkLeft(1)
    inst.components.workable:SetOnFinishCallback(dig_up)

    inst:AddComponent("inspectable")

    MakeHauntableIgnite(inst)

    MakeSnowCovered(inst)
    MakeNoGrowInWinter(inst)
    MakeWaxablePlant(inst)  -- TODO

    return inst
end

--------------------------------------------------------------------------

local function ondeploy_dug(inst, pt, deployer)

    if deployer ~= nil then
        deployer.SoundEmitter:PlaySound("dontstarve/common/plant")
    end

    local bush = SpawnPrefab("mesa_agave_bush")
    if bush ~= nil then
        bush.Transform:SetPosition(pt.x, pt.y, pt.z)
        bush.components.pickable:MakeEmpty()
        inst:Remove()
    end
end

local function mesa_agave_bush_dug()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("mesa_agave_bush")
    inst.AnimState:SetBuild("mesa_agave_bush")
    inst.AnimState:PlayAnimation("dropped") -- Looks like a Mini Agave Bush!

    inst:AddTag("deployedplant")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "mesa_agave_bush_dug"               -- TODO
    inst.components.inventoryitem.atlasname = "images/oe_inventoryimages.xml"     -- TODO

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = 20

    inst:AddComponent("deployable")
    inst.components.deployable.ondeploy = ondeploy_dug
    inst.components.deployable:SetDeployMode(DEPLOYMODE.PLANT)
    inst.components.deployable:SetDeploySpacing(1)

    inst:AddComponent("inspectable")

    MakeHauntableLaunch(inst)

    return inst
end


--------------------------------------------------------------------------

local function mesa_agave_nectar()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("mesa_agave_nectar")
    inst.AnimState:SetBuild("mesa_agave_nectar")
    inst.AnimState:PlayAnimation("idle", true)

    inst:AddTag("cattoy")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    -- TODO
    inst:AddComponent("edible")
    inst.components.edible.foodtype     = FOODTYPE.VEGGIE
    inst.components.edible.healthvalue  = 1
    inst.components.edible.hungervalue  = 15

    -- TODO
    inst:AddComponent("perishable")
    inst.components.perishable:SetPerishTime(TUNING.PERISH_FAST)
    inst.components.perishable:StartPerishing()
    inst.components.perishable.onperishreplacement = "spoiled_food"

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "mesa_agave_nectar"                   -- TODO
    inst.components.inventoryitem.atlasname = "images/oe_inventoryimages.xml"       -- TODO

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("inspectable")

    MakeHauntableLaunch(inst)

    return inst
end

-- The snow should auto-hide but it doesn't with placers and I don't know how else to hide them lol!
--------------------------------------------------------------------------

local function mesa_agave_bush_placer_postinit(inst)

    inst.AnimState:ClearOverrideSymbol("snow")
    inst.AnimState:ClearOverrideSymbol("snow_cover")

    inst.AnimState:Hide("snow")
    inst.AnimState:Hide("snow1")
    inst.AnimState:Hide("snow2")
    inst.AnimState:Hide("snow3")
    inst.AnimState:Hide("snow_cover")

end

--------------------------------------------------------------------------

return
    Prefab("oe_mesa_agave_bush",       mesa_agave_bush,        assets, { "mesa_agave_nectar", "mesa_agave_bush_dug", "perd", "twigs" }),
    Prefab("oe_mesa_agave_bush_dug",   mesa_agave_bush_dug,    assets),
    Prefab("oe_mesa_agave_nectar",     mesa_agave_nectar,      assets),

    MakePlacer("oe_mesa_agave_bush_dug_placer", "mesa_agave_bush", "mesa_agave_bush", "idle", nil, nil, nil, nil, nil, nil, mesa_agave_bush_placer_postinit)