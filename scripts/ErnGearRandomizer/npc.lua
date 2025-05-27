local core = require('openmw.core')
local self = require('openmw.self')
local storage = require('openmw.storage')
local T = require('openmw.types')
local S = require('scripts.ErnGearRandomizer.settings')
local swapTable = require('scripts.ErnGearRandomizer.swaptable')

local swapMarker = storage.globalSection(S.MOD_NAME .. "SwapMarker")

local function swapItems(npc)
    -- https://openmw.readthedocs.io/en/latest/reference/lua-scripting/openmw_types.html##(Actor)
    equipmentSlotToItem = T.Actor.getEquipment(npc)
    for slot, oldItem in pairs(equipmentSlotToItem) do
        if oldItem ~= nil then
            newSwapRecord = nil
            if T.Armor.objectIsInstance(oldItem) then
                newSwapRecord = swapTable.getArmorRecordID(oldItem)
            end
            if T.Clothing.objectIsInstance(oldItem) then
                newSwapRecord = swapTable.getClothingRecordID(oldItem)
            end
            if T.Weapon.objectIsInstance(oldItem) then
                newSwapRecord = swapTable.getWeaponRecordID(oldItem)
            end

            if newSwapRecord then
                core.sendGlobalEvent('LMswapItem', {actor=npc, oldItem=oldItem, newItemRecordID=newSwapRecord})
            end
        end
    end
    -- mark swap as done
    core.sendGlobalEvent('LMmarkAsDone', {actor=npc})
end

local function onActive()
    id = self.id
    if id == false then
        S.debugPrint("npc doesn't have an id???")
        return
    end

    -- filters so things don't get out of hand
    if self.type ~= T.NPC then
        S.debugPrint("npc script not applied on an NPC")
        return
    end

    if swapMarker:get(id, true) then
        S.debugPrint("npc " .. id .. " already handled")
        return
    end

    if T.NPC.objectIsInstance(self) == false then 
        S.debugPrint("not an instance!")
        return
    end
    if T.Actor.isDead(self) or T.Actor.isDeathFinished(self) then
        S.debugPrint("npc " .. id .. " is dead, won't swap")
        return
    end
    record = T.NPC.record(self)
    if record == nil then
        S.debugPrint("npc " .. id .. " has no record?")
        return
    end
    if record.isEssential then
        S.debugPrint("npc record " .. record.id .. " is essential, won't swap")
        return
    end

    swapItems(self)
end


return {
    engineHandlers = {
        onActive = onActive,
    }
}
