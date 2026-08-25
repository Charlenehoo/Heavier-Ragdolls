-- =====================================================
--  Toolgun Tool: Break Hair Bones
--  点击目标实体，打断其所有头发骨骼之间的内部连接，
--  并用长度约束重新连接，模拟头发骨折/松散效果。
-- =====================================================

TOOL.Category = "Debug"

-- 加载断骨工具模块
local BoneBreakUtils = include("heavier_ragdolls/break_bone_util.lua")

-- =====================================================
-- 谓词：骨骼名包含 "hair"（不区分大小写）
-- =====================================================
local function IsHairBone(ragdoll, boneID)
    local name = ragdoll:GetBoneName(boneID)
    return name and string.lower(name):find("hair", 1, true) ~= nil
end

-- =====================================================
-- 对指定 ragdoll 打断所有头发骨骼之间的连接
-- 遍历所有骨骼，找出头发骨骼，对每个头发骨骼调用 BreakBoneIf
-- 由于 BreakBoneIf 已检查父子条件，这里只需遍历所有骨骼并传入 hair 谓词
-- =====================================================
local function BreakAllHairBones(ragdoll)
    if not IsValid(ragdoll) then return end

    local boneCount = ragdoll:GetBoneCount()
    local brokenCount = 0

    for boneID = 0, boneCount - 1 do
        -- 只处理头发骨骼（通过谓词判断）
        local constraint = BoneBreakUtils.BreakBoneIf(
            ragdoll,
            boneID,
            function(id) return IsHairBone(ragdoll, id) end
        )
        if constraint then
            brokenCount = brokenCount + 1
        end
    end

    return brokenCount
end

-- =====================================================
-- 客户端：左键点击时向服务器发送请求
-- =====================================================
function TOOL:LeftClick(tr)
    local ent = tr.Entity
    if not IsValid(ent) then return false end

    local count = BreakAllHairBones(ent)
    if count and count > 0 then
        print("broke " .. count .. " hair constraints on " .. tostring(ent))
    end

    return true
end
