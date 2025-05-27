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
local core = require("openmw.core")
local T = require("openmw.types")

local S = require("scripts.ErnGearRandomizer.settings")
local U = require("scripts.ErnGearRandomizer.uniques")

local storage = require("openmw.storage")

local function chance()
    return S.settingsStore:get("chance")
end

local function clothes()
    return S.settingsStore:get("clothes")
end

local function armor()
    return S.settingsStore:get("armor")
end

local function weapons()
    return S.settingsStore:get("weapons")
end

local function enchanted()
    return S.settingsStore:get("enchanted")
end

local function extraRandom()
    return S.settingsStore:get("extraRandom")
end

local function itemBan()
    return S.settingsStore:get("itemBan")
end

local function lookupTable()
    return storage.globalSection(S.MOD_NAME .. "_swap_tables")
end


armorWeightSplit = {
    -- just take the heaviest light armor's weight
    [T.Armor.TYPE.Boots] = 8,
    [T.Armor.TYPE.Cuirass] = 18,
    [T.Armor.TYPE.Greaves] = 9,
    [T.Armor.TYPE.Helmet] = 3,
    [T.Armor.TYPE.LBracer] = 3,
    [T.Armor.TYPE.LGauntlet] = 3,
    [T.Armor.TYPE.LPauldron] = 4,
    [T.Armor.TYPE.RBracer] = 4,
    [T.Armor.TYPE.RGauntlet] = 4,
    [T.Armor.TYPE.RPauldron] = 4,
    [T.Armor.TYPE.Shield] = 9
}

local function quantize(num, size)
    return (size * math.floor(tonumber(num) / size))
end

-- lookupArmorTableName returns the lookuptable containing similar armors.
local function lookupArmorTableName(record)
    if extraRandom() then
        return S.MOD_NAME .. "a" .. record.type
    end
    -- include bucketed weight in the table name so we try to pair
    -- armors of similar skills.
    weightBucket = "!"
    weightBucketDivisor = armorWeightSplit[record.type]
    if weightBucketDivisor == false then
        weightBucket = "!"
    else
        weightBucket = quantize(record.weight, weightBucketDivisor)
    end

    -- https://openmw.readthedocs.io/en/latest/reference/lua-scripting/openmw_types.html##(Armor).TYPE
    return S.MOD_NAME ..
        "a" ..
            record.type ..
                "e" .. quantize(record.enchantCapacity, 2) .. "w" .. weightBucket .. "c" .. quantize(record.value, 4000)
end

-- lookupClothingTableName returns the lookuptable containing similar clothing.
local function lookupClothingTableName(record)
    if extraRandom() then
        return S.MOD_NAME .. "c" .. record.type
    end
    -- https://openmw.readthedocs.io/en/latest/reference/lua-scripting/openmw_types.html##(Clothing).TYPE
    return S.MOD_NAME ..
        "c" .. record.type .. "e" .. quantize(record.enchantCapacity, 2) .. "c" .. quantize(record.value, 20)
end

-- lookupWeaponTableName returns the lookuptable containing similar weapons.
local function lookupWeaponTableName(record)
    if extraRandom() then
        return S.MOD_NAME .. "w" .. record.type
    end
    -- https://openmw.readthedocs.io/en/latest/reference/lua-scripting/openmw_types.html##(Weapon).TYPE
    return S.MOD_NAME ..
        "w" .. record.type .. "e" .. quantize(record.enchantCapacity, 2) .. "c" .. quantize(record.value, 10000)
end

local function addToTable(tableKey, recordID)
    if lookupTable():get(tableKey) == nil then
        lookupTable():set(tableKey, {})
        lookupTable():set("COUNT" .. tableKey, 0)
    end
    list = lookupTable():getCopy(tableKey)
    table.insert(list, recordID)
    lookupTable():set(tableKey, list)
    -- count of the list
    count = lookupTable():get("COUNT" .. tableKey)
    lookupTable():set("COUNT" .. tableKey, count + 1)

    --S.debugPrint("table " .. tableKey .. " added " .. recordID)
end

local function filter(record)
    if U.uniqueID(record.id) == true then
        return false
    end
    if enchanted() == false and record.enchant ~= nil then
        return false
    end
    if string.find(string.lower(record.id), ".*fake.*") ~= nil then
        return false
    end
    if string.find(string.lower(record.id), ".*theater.*") ~= nil then
        return false
    end
    if string.find(string.lower(record.id), ".*unique.*") ~= nil then
        return false
    end
    if string.find(string.lower(record.id), ".*dummy.*") ~= nil then
        return false
    end
    if string.find(string.lower(record.id), ".*reward.*") ~= nil then
        return false
    end
    if string.find(string.lower(record.id), ".*curse.*") ~= nil then
        return false
    end
    if itemBan() ~= "" and string.find(string.lower(record.id), itemBan()) ~= nil then
        return false
    end

    return true
end

-- initTables builds the swap tables.
local function initTables()
    S.debugPrint("loading armors tables")
    for i, record in pairs(T.Armor.records) do
        recordID = string.lower(record.id)
        if filter(record) then
            -- actual list
            tableKey = lookupArmorTableName(record)
            addToTable(tableKey, recordID)
        end
    end

    S.debugPrint("loading clothing tables")
    for i, record in pairs(T.Clothing.records) do
        recordID = string.lower(record.id)
        if filter(record) then
            tableKey = lookupClothingTableName(record)
            addToTable(tableKey, recordID)
        end
    end

    S.debugPrint("loading weapons tables")
    for i, record in pairs(T.Weapon.records) do
        recordID = string.lower(record.id)
        if filter(record) then
            tableKey = lookupWeaponTableName(record)
            addToTable(tableKey, recordID)
        end
    end

    S.debugPrint("done loading swap tables")

    lookupTable():setLifeTime(storage.LIFE_TIME.GameSession)
end

-- returns record id if replacement needed.
-- returns nil if no replacement.
function getArmorRecordID(armorItem)
    -- https://openmw.readthedocs.io/en/latest/reference/lua-scripting/openmw_core.html##(GameObject)
    if armor() ~= true then
        S.debugPrint("armor swap disabled")
        return nil
    end
    if filter(armorItem) == false then
        S.debugPrint("armor filtered")
        return nil
    end
    if chance() < math.random(0, 99) then
        S.debugPrint("die roll failed")
        return nil
    end

    lookupKey = lookupArmorTableName(T.Armor.record(armorItem))
    return pickNewRecordFromTable(lookupKey)
end

function pickNewRecordFromTable(lookupKey)
    size = lookupTable():get("COUNT" .. lookupKey)
    if size == nil then
        S.debugPrint("bad table " .. lookupKey)
        return nil
    end
    if size <= 1 then
        S.debugPrint("small table " .. lookupKey)
        return nil
    end

    randIndex = math.random(1, size)
    return lookupTable():get(lookupKey)[randIndex]
end

-- returns record id if replacement needed.
-- returns nil if no replacement.
function getClothingRecordID(clothingItem)
    -- https://openmw.readthedocs.io/en/latest/reference/lua-scripting/openmw_core.html##(GameObject)
    if clothes() ~= true then
        return nil
    end
    if filter(clothingItem) == false then
        return nil
    end
    if chance() < math.random(0, 99) then
        return nil
    end

    lookupKey = lookupClothingTableName(T.Clothing.record(clothingItem))
    return pickNewRecordFromTable(lookupKey)
end

-- returns record id if replacement needed.
-- returns nil if no replacement.
function getWeaponRecordID(weaponItem)
    -- https://openmw.readthedocs.io/en/latest/reference/lua-scripting/openmw_core.html##(GameObject)
    if weapons() ~= true then
        return nil
    end
    if filter(weaponItem) == false then
        return nil
    end
    if chance() < math.random(0, 99) then
        return nil
    end

    lookupKey = lookupWeaponTableName(T.Weapon.record(weaponItem))
    return pickNewRecordFromTable(lookupKey)
end

return {
    initTables = initTables,
    getArmorRecordID = getArmorRecordID,
    getClothingRecordID = getClothingRecordID,
    getWeaponRecordID = getWeaponRecordID
}
