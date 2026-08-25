local PLUGIN_NAME = "Heavier Ragdolls"
local BONE_NAMES = include("heavier_ragdolls/bone_names.lua")

-- 物理参数：利用“质量杠杆”原理
-- 力 = 总质量 × FORCE_TO_BODY_RATIO   → 对整体而言极小的力
-- 头发质量 = 总质量 × HAIR_MASS_TO_BODY_RATIO → 发丝极轻，因此同等力产生巨大向下加速度
-- local FORCE_TO_BODY_RATIO = 0.01
-- local FORCE_TO_HAIR_MASS_RATIO = 0.0001

-- local ragdollToCustomBonePhysObjects = {}
-- local ragdollToMass = {}

-- hook.Add("EntityRemoved", PLUGIN_NAME .. "EntityRemoved", function(ent)
--     ragdollToCustomBonePhysObjects[ent] = nil
--     ragdollToMass[ent] = nil
-- end)

hook.Add("CreateEntityRagdoll", PLUGIN_NAME .. "CreateEntityRagdoll", function(owner, ragdoll)
    if not IsValid(ragdoll) then return end
    ragdoll:SetFriction(5)

    local boneCount = ragdoll:GetBoneCount()
    if not boneCount or boneCount == 0 then return end

    -- local totalMass = 0
    for boneIndex = 0, boneCount - 1 do
        local physIndex = ragdoll:TranslateBoneToPhysBone(boneIndex)
        if not physIndex then continue end
        local physObj = ragdoll:GetPhysicsObjectNum(physIndex)
        if not IsValid(physObj) then continue end

        local boneName = ragdoll:GetBoneName(boneIndex)
        if BONE_NAMES[boneName] then
            -- totalMass = totalMass + physObj:GetMass()
            physObj:EnableDrag(true)
            physObj:SetAngleDragCoefficient(2)
        end
    end
    -- ragdollToMass[ragdoll] = totalMass

    -- for boneIndex = 0, boneCount - 1 do
    --     local physIndex = ragdoll:TranslateBoneToPhysBone(boneIndex)
    --     if not physIndex then continue end
    --     local physObj = ragdoll:GetPhysicsObjectNum(physIndex)
    --     if not IsValid(physObj) then continue end

    --     local boneName = ragdoll:GetBoneName(boneIndex)
    --     if string.find(boneName, "Hair") or string.find(boneName, "Cape") then
    --         local forceMagnitude = totalMass * FORCE_TO_BODY_RATIO
    --         physObj:SetMass(forceMagnitude * FORCE_TO_HAIR_MASS_RATIO) -- 头发极轻
    --         physObj:SetDamping(100, 100)                               -- 建议保留，防止碰撞后弹飞
    --         physObj:EnableCollisions(false)

    --         ragdollToCustomBonePhysObjects[ragdoll] = ragdollToCustomBonePhysObjects[ragdoll] or {}
    --         table.insert(ragdollToCustomBonePhysObjects[ragdoll], physObj)
    --     end
    -- end
end)

-- hook.Add("Think", PLUGIN_NAME .. "Think", function()
--     for ragdoll, physObjects in pairs(ragdollToCustomBonePhysObjects) do
--         if not IsValid(ragdoll) then
--             ragdollToCustomBonePhysObjects[ragdoll] = nil
--             ragdollToMass[ragdoll] = nil
--             continue
--         end

--         local totalMass = ragdollToMass[ragdoll]
--         if not totalMass then continue end

--         local validObjects = {}
--         for _, physObj in ipairs(physObjects) do
--             if not IsValid(physObj) then continue end
--             table.insert(validObjects, physObj)

--             -- 力 = 总质量 × 比例系数（对整体很小，但对头发效果显著）
--             local forceMagnitude = totalMass * FORCE_TO_BODY_RATIO
--             local force = Vector(0, 0, -forceMagnitude) -- 向下
--             physObj:ApplyForceCenter(force)
--         end

--         if #validObjects > 0 then
--             ragdollToCustomBonePhysObjects[ragdoll] = validObjects
--         else
--             ragdollToCustomBonePhysObjects[ragdoll] = nil
--         end
--     end
-- end)
