TOOL.Category = "Debug"

local function GetHairTopology(ent)
    local boneCount = ent:GetBoneCount()
    local hair = {}     -- [boneID] = {name, parent, parentName}
    local children = {} -- [parentBoneID] = {childBoneID, ...}

    -- 1. 找出所有头发骨骼，并读取每个头发骨骼的直接父骨骼
    for id = 0, boneCount - 1 do
        local name = ent:GetBoneName(id)
        if name and name:lower():find("hair", 1, true) then
            local parent = ent:GetBoneParent(id)
            local parentName = (parent >= 0) and ent:GetBoneName(parent) or nil

            hair[id] = {
                name = name,
                parent = parent,
                parentName = parentName
            }
        end
    end

    -- 2. 根据 parent 关系建立 children 表
    for id, info in pairs(hair) do
        local p = info.parent
        -- 只记录父骨骼也是头发骨骼的情况
        if p >= 0 and hair[p] then
            children[p] = children[p] or {}
            table.insert(children[p], id)
        end
    end

    return hair, children
end

local function PrintHairTopology(ent)
    local hair, children = GetHairTopology(ent)

    local function printNode(id, indent)
        indent = indent or ""
        local info = hair[id]
        if not info then return end

        local parentStr
        if info.parentName then
            parentStr = string.format("parent = [%d] %s", info.parent, info.parentName)
        else
            parentStr = "parent = ROOT / 非头发骨骼"
        end

        print(string.format("%s[%d] %s  (%s)", indent, id, info.name, parentStr))

        local kids = children[id] or {}
        table.sort(kids)
        for _, childID in ipairs(kids) do
            printNode(childID, indent .. "    ")
        end
    end

    -- 找出“根头发骨骼”：它的 parent 不是头发骨骼
    local roots = {}
    for id, info in pairs(hair) do
        if info.parent < 0 or not hair[info.parent] then
            table.insert(roots, id)
        end
    end
    table.sort(roots)

    print("==== Hair Topology ====")
    for _, rootID in ipairs(roots) do
        printNode(rootID)
    end
end

function TOOL:LeftClick(tr)
    PrintHairTopology(self:GetOwner())
    return true
end
