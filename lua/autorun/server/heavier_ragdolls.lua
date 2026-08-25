local PLUGIN_NAME = "Heavier Ragdolls"
local BONE_NAMES = include("heavier_ragdolls/bone_names.lua")

hook.Add("CreateEntityRagdoll", PLUGIN_NAME .. "CreateEntityRagdoll", function(owner, ragdoll)
    if not IsValid(ragdoll) then return end
    ragdoll:SetFriction(5)

    local boneCount = ragdoll:GetBoneCount()
    if not boneCount or boneCount == 0 then return end

    for boneIndex = 0, boneCount - 1 do
        local physIndex = ragdoll:TranslateBoneToPhysBone(boneIndex)
        if not physIndex then continue end
        local physObj = ragdoll:GetPhysicsObjectNum(physIndex)
        if not IsValid(physObj) then continue end

        local boneName = ragdoll:GetBoneName(boneIndex)
        if BONE_NAMES[boneName] then
            physObj:EnableDrag(true)
            physObj:SetAngleDragCoefficient(2)
        end
    end
end)
