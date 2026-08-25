-- =====================================================
-- 独立模块：BoneBreakUtils
-- 提供 CheckPredicate 和 BreakBoneIf 两个函数
-- =====================================================

local M = {}

-- =====================================================
-- 谓词检查工具
-- 支持函数或表（集合）形式
-- =====================================================
local function CheckPredicate(predicate, boneID)
    if type(predicate) == "function" then
        return predicate(boneID)
    elseif type(predicate) == "table" then
        return predicate[boneID] == true
    end
    return false
end

-- =====================================================
-- 通用断骨辅助函数
-- 参数：
--   ragdoll        : 目标 ragdoll 实体
--   childBoneID    : 子骨骼 ID
--   childPredicate : 子骨骼满足的条件（函数或表）
--   parentPredicate: 父骨骼满足的条件（函数或表），可选，默认与 childPredicate 相同
-- 返回值：
--   成功时返回创建的 phys_lengthconstraint 实体
--   失败时返回 nil
-- =====================================================
local function BreakBoneIf(ragdoll, childBoneID, childPredicate, parentPredicate)
    if not IsValid(ragdoll) then return nil end
    if not childPredicate then return nil end

    -- 父谓词默认与子谓词相同
    parentPredicate = parentPredicate or childPredicate

    -- 检查子骨骼是否满足条件
    if not CheckPredicate(childPredicate, childBoneID) then
        return nil
    end

    -- 获取父骨骼 ID
    local parentBoneID = ragdoll:GetBoneParent(childBoneID)
    if parentBoneID < 0 then
        return nil
    end

    -- 检查父骨骼是否满足条件
    if not CheckPredicate(parentPredicate, parentBoneID) then
        return nil
    end

    -- 转换为物理对象 ID
    local childPhysID = ragdoll:TranslateBoneToPhysBone(childBoneID)
    local parentPhysID = ragdoll:TranslateBoneToPhysBone(parentBoneID)

    if childPhysID < 0 or parentPhysID < 0 then
        return nil
    end

    local childPhys = ragdoll:GetPhysicsObjectNum(childPhysID)
    local parentPhys = ragdoll:GetPhysicsObjectNum(parentPhysID)

    if not childPhys or not parentPhys then
        return nil
    end

    -- 移除内部约束，让骨骼可以自由活动
    ragdoll:RemoveInternalConstraint(childPhysID)

    -- 创建新的长度约束，模拟骨折后仍相连但可活动
    local constraint = ents.Create("phys_lengthconstraint")
    constraint:SetPhysConstraintObjects(childPhys, parentPhys)
    constraint:SetKeyValue("minlength", "0.0")
    constraint:SetKeyValue("length", "0.1") -- 可调整松弛程度
    constraint:Spawn()
    constraint:Activate()

    -- 成功，返回约束实体
    return constraint
end

M.CheckPredicate = CheckPredicate
M.BreakBoneIf = BreakBoneIf

return M
