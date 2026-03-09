local assets = 
{
    Asset("ANIM", "anim/mesa_rock_clay.zip"),

    Asset("IMAGE", "images/oe_minimapimages.tex"),
    Asset("ATLAS", "images/oe_minimapimages.xml"),
}

local prefabs = 
{
    "rocks",
    "rock_break_fx",
    "oe_mesa_clay",
    "succulent_plant",
}

--------------------------------------------------------------------------

SetSharedLootTable("oe_mesa_rock_clay",
{
    {"oe_mesa_clay", 1.00},
    {"oe_mesa_clay", 1.00},
    {"oe_mesa_clay", 1.00},
    {"oe_mesa_clay", 0.25},
})

---------------------------------------------------------------------------

local MAX_SUCCULENTS        = 5
local SUCCULENT_RANGE       = 2
local SUCCULENT_RANGE_MIN   = 2
local NOTENTCHECK_CANT_TAGS = { "FX", "INLIMBO" }
local SUCCULENT_TAGS        = { "succulent" }

local function SpawnSucculents(inst)

    local pt = inst:GetPosition()

    local function noentcheckfn(offset)
        return #TheSim:FindEntities(offset.x, offset.y, offset.z, 2, nil, NOTENTCHECK_CANT_TAGS) == 0
    end

    local succulents_to_spawn = math.max(0,
        MAX_SUCCULENTS -
        #TheSim:FindEntities(pt.x, pt.y, pt.z, SUCCULENT_RANGE, SUCCULENT_TAGS)
    )

    for i = 1, succulents_to_spawn do

        local offset = FindWalkableOffset(
            pt,
            math.random() * TWOPI,
            GetRandomMinMax(SUCCULENT_RANGE_MIN, SUCCULENT_RANGE),
            10,
            false,
            true,
            noentcheckfn
        )

        if offset ~= nil then

            local plant = SpawnPrefab("succulent_plant")

            plant.Transform:SetPosition((pt + offset):Get())
            plant.AnimState:PlayAnimation("place")
            plant.AnimState:PushAnimation("idle", false)

        end
    end
end

---------------------------------------------------------------------------

local function OnSeasonChange(inst, season)

    if season == "summer" then
        SpawnSucculents(inst)
    end

end

---------------------------------------------------------------------------

local function OnHit(inst, worker, workleft)
    if workleft > 0 then
        if not inst.AnimState:IsCurrentAnimation("idle_1") then
            inst.AnimState:PlayAnimation("idle_1")
        end
    end
end

local function OnWorked(inst, worker)

    local pt = inst:GetPosition()

    local fx = SpawnPrefab("rock_break_fx")
    fx.Transform:SetPosition(pt.x, pt.y, pt.z)

    if inst.components.lootdropper ~= nil then
        inst.components.lootdropper:DropLoot(pt)
    end

    inst:Remove()
end

---------------------------------------------------------------------------

local function OnSave(inst, data)

    data._succulents_spawned = inst._succulents_spawned

end

local function OnLoad(inst, data)

    if data ~= nil then
        inst._succulents_spawned = data._succulents_spawned
    end

end

---------------------------------------------------------------------------

local function fn()

    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    local minimap = inst.entity:AddMiniMapEntity()
    minimap:SetIcon("oe_mesa_rock_clay.tex")

    MakeObstaclePhysics(inst, 1)

    inst.AnimState:SetBank("mesa_rock_clay")
    inst.AnimState:SetBuild("mesa_rock_clay")
    inst.AnimState:PlayAnimation("idle_1", false)

    MakeSnowCoveredPristine(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    --------------------------------------------------

    local color = 0.75 + math.random() * 0.25
    inst.AnimState:SetMultColour(color, color, color, 1)

    inst:AddComponent("inspectable")

    --------------------------------------------------

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable("oe_mesa_rock_clay")

    --------------------------------------------------

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.MINE)
    inst.components.workable:SetWorkLeft(TUNING.OE_MESA_ROCK_CLAY_WORKLEFT)
    inst.components.workable:SetOnWorkCallback(OnHit)
    inst.components.workable:SetOnFinishCallback(OnWorked)

    --------------------------------------------------
    -- Spawn succulents once when rock first appears
    --------------------------------------------------

    inst:DoTaskInTime(0, function(inst)

        if not inst._succulents_spawned then
            SpawnSucculents(inst)
            inst._succulents_spawned = true
        end

    end)

    --------------------------------------------------
    -- Summer respawn
    --------------------------------------------------

    inst:WatchWorldState("season", OnSeasonChange)

    --------------------------------------------------

    MakeSnowCovered(inst)
    MakeHauntableWork(inst)

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad

    return inst
end

--------------------------------------------------------------------------

return Prefab("oe_mesa_rock_clay", fn, assets, prefabs)