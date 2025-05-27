--[[
ErnGearRandomizer for OpenMW.
Copyright (C) 2025 Erin Pentecost

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as
published by the Free Software Foundation, either version 3 of the
License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
]]
local S = require("scripts.ErnGearRandomizer.settings")
local core = require("openmw.core")
local T = require("openmw.types")
local world = require("openmw.world")
local storage = require("openmw.storage")
local swapTable = require("scripts.ErnGearRandomizer.swaptable")

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
    S.debugPrint("npc " .. actor.id .. " swapping item " .. oldItem.id .. " to " .. newItemRecordID)
    oldItem:remove()
    inventory = T.Actor.inventory(actor)
    newItemInstance = world.createObject(newItemRecordID)
    newItemInstance:moveInto(inventory)
    core.sendGlobalEvent("UseItem", {object = newItemInstance, actor = actor, force = true})
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
        LMmarkAsDone = markAsDone
    },
    engineHandlers = {
        onSave = saveState,
        onLoad = loadState
    }
}
