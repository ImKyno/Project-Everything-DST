local prefabs =
{

}

local assets =
{
    Asset("ANIM", "anim/pillar_cave_rock.zip"),
    Asset("ANIM", "anim/moonglasspool_tile.zip"),
}

--------------------------------------------------------------------------

local function SpawnMesaPool(inst)

    local pool = CreateEntity()

    pool.entity:AddTransform()
    pool.entity:AddAnimState()

    -- non-networked FX entity
    pool:AddTag("FX")
    pool:AddTag("NOCLICK")

    pool.entity:SetParent(inst.entity)
    pool.Transform:SetPosition(0, 0, 0)

    pool.AnimState:SetBuild("moonglasspool_tile")
    pool.AnimState:SetBank("moonglasspool_tile")
    pool.AnimState:PlayAnimation("smallpool_idle", true)

    pool.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    pool.AnimState:SetLayer(LAYER_BACKGROUND)
    pool.AnimState:SetSortOrder(3)
    pool.AnimState:SetLightOverride(0.25)

    pool.entity:SetCanSleep(false)
    pool.persists = false

end

--------------------------------------------------------------------------

local function mesa_pillar_tree()

    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeObstaclePhysics(inst, 3, 24)

    inst.entity:AddMiniMapEntity()
    inst.MiniMapEntity:SetIcon("tree_pillar.tex")

    inst:AddTag("tree_pillar")
    inst:AddTag("shadecanopysmall")

    inst.AnimState:SetBank("pillar_cave")
    inst.AnimState:SetBuild("pillar_cave")
    inst.AnimState:PlayAnimation("idle", true)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    return inst
end

--------------------------------------------------------------------------

local function mesa_pillar_rock()

    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeObstaclePhysics(inst, 3, 24)

    inst:AddTag("tree_pillar")

    inst.AnimState:SetBank("pillar_cave")
    inst.AnimState:SetBuild("pillar_cave")
    inst.AnimState:PlayAnimation("idle", true)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    return inst
end

--------------------------------------------------------------------------

local function mesa_pillar_stalactite()

    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeObstaclePhysics(inst, 3, 24)

    inst:AddTag("tree_pillar")

    inst.AnimState:SetBank("bigwaterfall")
    inst.AnimState:SetBuild("bigwaterfall")
    inst.AnimState:PlayAnimation("idle", true)

    inst.entity:SetPristine()

    ------------------------------------------------

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    -- spawn visual pool
    inst:DoTaskInTime(0, function(inst)
        SpawnMesaPool(inst)
    end)

    ------------------------------------------------

    return inst
end

--------------------------------------------------------------------------

return Prefab("oe_mesa_pillar_tree",        mesa_pillar_tree,       assets, prefabs),
       Prefab("oe_mesa_pillar_rock",        mesa_pillar_rock,       assets, prefabs),
       Prefab("oe_mesa_pillar_stalactite",  mesa_pillar_stalactite, assets, prefabs)