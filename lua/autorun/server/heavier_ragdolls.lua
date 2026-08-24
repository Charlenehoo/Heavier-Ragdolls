local PLUGIN_NAME = "Heavier Ragdolls"

local BONE_NAMES = include("heavier_ragdolls/bone_names.lua")

local HAIR_MAIN = {
    ["Ab-HairVFLL01"] = true,
    ["Ab-HairVFLL02"] = true,
    ["Ab-HairVFLL03"] = true,
    ["Ab-HairVFL01"] = true,
    ["Ab-HairVFL02"] = true,
    ["Ab-HairVFL03"] = true,
    ["Ab-HairVFR01"] = true,
    ["Ab-HairVFR02"] = true,
    ["Ab-HairVFR03"] = true,
    ["Ab-HairVFRR01"] = true,
    ["Ab-HairVFRR03"] = true,
}

local HAIR_SIDE = {
    ["Ab_Hair_exR01"] = true,
    ["Ab_Hair_exR02"] = true,
    ["Ab_Hair_exR03"] = true,
    ["Ab_Hair_exR04"] = true,
    ["Ab_Hair_exL01"] = true,
    ["Ab_Hair_exL02"] = true,
    ["Ab_Hair_exL03"] = true,
    ["Ab_Hair_exL04"] = true,
}

local HAIR_TAIL = {
    ["Ab-TL-HairB01"] = true,
    ["Ab-TL-HairB02"] = true,
    ["Ab-TL-HairB03"] = true,
    ["Ab-TL-HairB04"] = true,
    ["Ab-TL-HairB05"] = true,
    ["Ab-TL-HairB06"] = true,
    ["Ab-TL-HairB07"] = true,
    ["Ab-TL-HairB08"] = true,
    ["Ab-TL-HairB09"] = true,
}

local ragdollToCustomBonePhysObjects = {}

hook.Add("CreateEntityRagdoll", PLUGIN_NAME .. "CreateEntityRagdoll", function(owner, ragdoll)
    if not IsValid(ragdoll) then return end
    ragdoll:SetFriction(5)

    local boneCount = ragdoll:GetBoneCount()
    if not boneCount or boneCount == 0 then return end

    local cTable = constraint.FindConstraints(ragdoll, "Elastic")
    PrintTable(cTable)

    for boneIndex = 0, boneCount - 1 do
        local physIndex = ragdoll:TranslateBoneToPhysBone(boneIndex)
        if not physIndex then continue end

        local physObj = ragdoll:GetPhysicsObjectNum(physIndex)
        if not IsValid(physObj) then continue end

        local boneName = ragdoll:GetBoneName(boneIndex)
        if BONE_NAMES[boneName] then -- Valve Biped Bone
            physObj:EnableDrag(true)
            -- physObj:SetDragCoefficient(100)
            physObj:SetAngleDragCoefficient(2)
        elseif HAIR_MAIN[boneName] then
            physObj:SetMass(0.005)

            ragdollToCustomBonePhysObjects[ragdoll] = ragdollToCustomBonePhysObjects[ragdoll] or {}
            table.insert(ragdollToCustomBonePhysObjects[ragdoll], physObj)
        elseif HAIR_SIDE[boneName] then
            physObj:SetMass(0.002)

            ragdollToCustomBonePhysObjects[ragdoll] = ragdollToCustomBonePhysObjects[ragdoll] or {}
            table.insert(ragdollToCustomBonePhysObjects[ragdoll], physObj)
        elseif HAIR_TAIL[boneName] then
            physObj:SetMass(0.001)

            ragdollToCustomBonePhysObjects[ragdoll] = ragdollToCustomBonePhysObjects[ragdoll] or {}
            table.insert(ragdollToCustomBonePhysObjects[ragdoll], physObj)
        elseif string.find(boneName, "Cape") then
            physObj:SetMass(0.01)

            ragdollToCustomBonePhysObjects[ragdoll] = ragdollToCustomBonePhysObjects[ragdoll] or {}
            table.insert(ragdollToCustomBonePhysObjects[ragdoll], physObj)
        else
        end
    end
end)


local force = Vector(0, 0, -1)

hook.Add("Think", PLUGIN_NAME .. "Think", function()
    local newRagdollToCustomBonePhysObjects = {}
    for ragdoll, physObjects in pairs(ragdollToCustomBonePhysObjects) do
        if not IsValid(ragdoll) then continue end

        local newphysObjects = {}
        for _, physObj in ipairs(physObjects) do
            if not IsValid(physObj) then continue end
            table.insert(newphysObjects, physObj)
            physObj:ApplyForceCenter(force)
        end
        newRagdollToCustomBonePhysObjects[ragdoll] = newphysObjects
    end
    ragdollToCustomBonePhysObjects = newRagdollToCustomBonePhysObjects
end)
