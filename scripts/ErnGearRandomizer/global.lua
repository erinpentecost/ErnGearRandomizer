local S = require('scripts.ErnGearRandomizer.settings')
local core = require('openmw.core')
local T = require('openmw.types')
local world = require('openmw.world')
local storage = require('openmw.storage')
local swapTable = require('scripts.ErnGearRandomizer.swaptable')

if require("openmw.core").API_REVISION < 62 then
	error("OpenMW 0.49 or newer is required!")
end

-- Init settings first to init storage which is used everywhere
S.initSettings()
-- Init swap table
swapTable.initTables()

local swapMarker = storage.globalSection(S.MOD_NAME .. "SwapMarker")
swapMarker:setLifeTime(storage.LIFE_TIME.GameSession)


local function swapItem(data)
    actor = data.actor
    oldItem = data.oldItem
    newItemRecordID = data.newItemRecordID
    S.debugPrint("npc ".. actor.id .. " swapping item " .. oldItem.id .. " to " .. newItemRecordID)
    oldItem:remove()
    inventory = T.Actor.inventory(actor)
    newItemInstance = world.createObject(newItemRecordID)
    newItemInstance:moveInto(inventory)
    core.sendGlobalEvent('UseItem', {object = newItemInstance, actor = actor, force = true})
end


local function markAsDone(data)
    actor = data.actor
    S.debugPrint("marking " .. actor.id .. " as done")
    -- mark swap as done
    swapMarker:set(actor.id, true)
end

local function saveState()
    return swapMarker:asTable()
end

local function loadState(saved)
	swapMarker:reset(saved)
end

return {
    eventHandlers = {
        LMswapItem = swapItem,
        LMmarkAsDone = markAsDone,
    },
    engineHandlers = {
        onSave = saveState,
		onLoad = loadState,
    }
}