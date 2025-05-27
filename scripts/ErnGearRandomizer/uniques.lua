

local function buildSet(list)
    local set = {}
    for _, v in ipairs(list) do
        set[string.lower(v)] = true
    end
    return set
end

local uniqueIDs = buildSet({
    -- https://en.uesp.net/wiki/Morrowind:Clothing_Artifacts
    "artifact_amulet of heartfire",
    "artifact_amulet of heartheal",
    "artifact_amulet of heartrime",
    "artifact_amulet of heartthrum",
    "amulet_usheeja",
    "madstone",
    "teeth",
    "thong",
    "belt of heartfire",
    "seizing",
    "blood ring",
    "ring_denstagmer_unique",
    "heart ring",
    "ring_mentor_unique",
    "moon_and_star",
    "ring_khajiit_unique",
    "ring_phynaster_unique",
    "ring_surrounding_unique",
    "ring_wind_unique",
    "soul ring",
    "ring_vampiric_unique",
    "ring_warlock_unique",
    "expensive_shirt_hair",
    "shoes of st. rilms",
    -- https://en.uesp.net/wiki/Morrowind:Quest_Items
    "lugrub's axe",
    "dwarven war axe_redas",
    "ebony staff caper",
    "wizard's staff",
    "Rusty_Dagger_UNIQUE",
    "devil_tanto_tgamg",
    "daedric wakizashi_hhst",
    "glass_dagger_enamor",
    "dart_uniq_judgement",
    "dwemer_boots of flying",
    "bonemold_gah-julan_hhda",
    "bonemold_tshield_hrlb",
    "amulet of ashamanu (unique)",
    "amuletfleshmadewhole_uniq",
    "amulet_Agustas_unique",
    "expensive_amulet_delyna",
    "expensive_amulet_aeta",
    "sarandas_amulet",
    "exquisite_amulet_hlervu1",
    "Julielle_Aumines_Amulet",
    "Linus_Iulus_Maran Amulet ",
    "amulet_skink_unique",
    "Linus_Iulus_Stendarran_Belt ",
    "sarandas_belt",
    "common_glove_l",
    "r_balmolagmer",
    "extravagant_rt_art_wild",
    "expensive_glove_left_ilmeni",
    "extravagant_glove_left",
    "right_maur",
    "common_pants_02_hentus",
    "sarandas_pants_2",
    "Adusamsi's_Ring ",
    "extravagant_ring_aund_uni",
    "ring_blackjinx_uniq",
    "exquisite_ring_brallion",
    "common_ring_danar ",
    "sarandas_ring_2",
    "ring_keley",
    "expensive_ring_01_BILL",
    "expensive_ring_aeta",
    "sarandas_ring_1",
    "Expensive_Ring_01_HRDT",
    "exquisite_ring_processus",
    "ring_dahrkmezalf_uniq",
    "Extravagant_Robe_01_Red",
    "robe of st roris",
    "exquisite_robe_drake's pride",
    "sarandas_shirt_2",
    "exquisite_shirt_01_rasha",
    "sarandas_shoes_2",
    "therana's skirt "
    -- https://en.uesp.net/wiki/Morrowind:Sanguine_Items
    -- TODO
    -- https://en.uesp.net/wiki/Morrowind:Weapon_Artifacts
    -- TODO
    -- https://en.uesp.net/wiki/Morrowind:Armor_Artifacts
    -- TODO
    -- TODO: do the same for Mournhold and Solstheim items.
})

-- uniqueID returns true if the item record is a unique that should NOT be swapped.
local function uniqueID(id)
    return uniqueIDs[string.lower(id)] == true
end

return {
    uniqueID = uniqueID
}