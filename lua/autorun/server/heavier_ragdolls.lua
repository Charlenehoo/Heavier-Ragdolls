local PLUGIN_NAME = "Heavier Ragdolls"

hook.Add("CreateEntityRagdoll", PLUGIN_NAME .. "CreateEntityRagdoll", function(owner, ragdoll)
    if not IsValid(ragdoll) then return end
    ragdoll:SetFriction(100)

    local physObjCount = ragdoll:GetPhysicsObjectCount()
    if not physObjCount or physObjCount == 0 then return end

    for count = 0, physObjCount - 1 do
        local physObj = ragdoll:GetPhysicsObjectNum(count)
        if not IsValid(physObj) then continue end

        physObj:EnableDrag(true)
        -- physObj:SetDragCoefficient(100)
        physObj:SetAngleDragCoefficient(10)
    end
end)
