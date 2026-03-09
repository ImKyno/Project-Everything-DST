local assets =
{
    Asset("ANIM", "anim/mesa_flipping_rock.zip"),
    --Asset("MINIMAP_IMAGE", "rock_flipping"), -- TODO
}

local prefabs =
{
    "oe_mesa_clay",
}

local function wobble(inst)
    if inst.AnimState:IsCurrentAnimation("idle") then
        inst.AnimState:PlayAnimation("wobble")
        inst.AnimState:PushAnimation("idle")
        --inst.SoundEmitter:PlaySound("dontstarve_DLC003/common/harvested/flipping_rock/move")
    end
end

local function dowobbletest(inst)
    if math.random() < 0.5 then
        wobble(inst)
    end
end

local function onpickedfn(inst, picker)
    inst.AnimState:PlayAnimation("flip_over", false)
    inst.SoundEmitter:PlaySound("dontstarve_DLC003/common/harvested/flipping_rock/open")
    inst.components.lootdropper:DropLoot(inst:GetPosition())
end

local function makefullfn(inst)
    inst.AnimState:PlayAnimation("flip_close")
    inst.AnimState:PushAnimation("idle")
    inst.SoundEmitter:PlaySound("dontstarve_DLC003/common/harvested/flipping_rock/open")

    inst:DoTaskInTime(0)
end

local function makeemptyfn(inst)
    inst.AnimState:PlayAnimation("flip_over", false)
end

local function getregentimefn(inst)
    return TUNING.FLIPPABLE_ROCK_REPOPULATE_TIME  + math.random() * TUNING.FLIPPABLE_ROCK_REPOPULATE_VARIANCE
end

local function OnEntitySleep(inst)
    if inst.fliptask then
        inst.fliptask:Cancel()
        inst.fliptask = nil
    end
end

local function OnEntityWake(inst)
    if inst.fliptask then
        inst.fliptask:Cancel()
    end
    inst.fliptask = inst:DoPeriodicTask(10 + (math.random() * 10), dowobbletest)
end

local function OnWorked(inst, worker, workleft)
    if workleft <= 0 then
        inst.SoundEmitter:PlaySound("dontstarve/wilson/rock_break")
        inst.components.lootdropper:DropLootPrefab(SpawnPrefab("rocks"))

        if math.random() < 0.3 then
            inst.components.lootdropper:DropLootPrefab(SpawnPrefab("rocks"))
        end

        if inst.components.pickable.canbepicked then
            inst.components.lootdropper:DropLoot()
        end

        inst:Remove()
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddMiniMapEntity()
    --inst.MiniMapEntity:SetIcon("rock_flipping.tex")
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst:AddTag("rock")
    inst:AddTag("flippable")

    MakeObstaclePhysics(inst, .1)

    inst.AnimState:SetBank("mesa_flipping_rock")
    inst.AnimState:SetBuild("mesa_flipping_rock")
    inst.AnimState:PlayAnimation("idle", true)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("pickable")
    inst.components.pickable:SetUp(nil, TUNING.FLIPPABLE_ROCK_REPOPULATE_TIME)
    inst.components.pickable.getregentimefn = getregentimefn
    inst.components.pickable.onpickedfn     = onpickedfn
    inst.components.pickable.makefullfn     = makefullfn
    inst.components.pickable.makeemptyfn    = makeemptyfn
    inst.components.pickable.quickpick      = true

    -- TODO
	inst:AddComponent("lootdropper")
    inst.components.lootdropper:AddRandomLoot("oe_mesa_clay",   .5)
    inst.components.lootdropper:AddRandomLoot("fossil_piece",   .5)
    inst.components.lootdropper.numrandomloot = 2

    inst:AddComponent("inspectable")

    inst.fliptask = inst:DoPeriodicTask(10 + (math.random() * 10), dowobbletest)

    inst.OnEntitySleep  = OnEntitySleep
    inst.OnEntityWake   = OnEntityWake

    MakeHauntableWork(inst)

    return inst
end

return Prefab("oe_mesa_flipping_rock", fn, assets, prefabs)
