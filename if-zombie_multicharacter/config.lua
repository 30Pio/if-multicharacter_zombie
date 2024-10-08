Config = {
    Locale = 'en',

    Framework = '', -- ESX or QB

    -- Default number of slots for players
    DefaultSlots = 3,
    PlayerSlots = { -- Define maximum amount of player characters by R* license
        { license = "license:xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx", numberOfChars = 5 },
    },

    -- Sets the location for the character SELECTION SCENE
    SelectionSpawn = vector4(-284.2856, 562.4627, 172.9182, 19.9895),

    -- ONLY FOR QB!!! - FOR ESX, MODIFY THE DEFAULT VALUE IN THE USERS SQL TABLE OR CHECK es_extended CONFIG
    QBDefaultSpawn = vector3(-1035.71, -2731.87, 12.86),

    -- Allows players to delete their characters
    CanDelete = true,

    -- Allows players to relog and select other character
    Relog = {
        enabled = true,
        command = 'relog'
    },
}

Config.DefaultESXSkin = {
    [0] = {
        mom = 43,
        dad = 29,
        face_md_weight = 61,
        skin_md_weight = 27,
        nose_1 = -5,
        nose_2 = 6,
        nose_3 = 5,
        nose_4 = 8,
        nose_5 = 10,
        nose_6 = 0,
        cheeks_1 = 2,
        cheeks_2 = -10,
        cheeks_3 = 6,
        lip_thickness = -2,
        jaw_1 = 0,
        jaw_2 = 0,
        chin_1 = 0,
        chin_2 = 0,
        chin_13 = 0,
        chin_4 = 0,
        neck_thickness = 0,
        hair_1 = 76,
        hair_2 = 0,
        hair_color_1 = 61,
        hair_color_2 = 29,
        tshirt_1 = 4,
        tshirt_2 = 2,
        torso_1 = 23,
        torso_2 = 2,
        decals_1 = 0,
        decals_2 = 0,
        arms = 1,
        arms_2 = 0,
        pants_1 = 28,
        pants_2 = 3,
        shoes_1 = 70,
        shoes_2 = 2,
        mask_1 = 0,
        mask_2 = 0,
        bproof_1 = 0,
        bproof_2 = 0,
        chain_1 = 22,
        chain_2 = 2,
        helmet_1 = -1,
        helmet_2 = 0,
        glasses_1 = 0,
        glasses_2 = 0,
        watches_1 = -1,
        watches_2 = 0,
        bracelets_1 = -1,
        bracelets_2 = 0,
        bags_1 = 0,
        bags_2 = 0,
        eye_color = 0,
        eye_squint = 0,
        eyebrows_2 = 0,
        eyebrows_1 = 0,
        eyebrows_3 = 0,
        eyebrows_4 = 0,
        eyebrows_5 = 0,
        eyebrows_6 = 0,
        makeup_1 = 0,
        makeup_2 = 0,
        makeup_3 = 0,
        makeup_4 = 0,
        lipstick_1 = 0,
        lipstick_2 = 0,
        lipstick_3 = 0,
        lipstick_4 = 0,
        ears_1 = -1,
        ears_2 = 0,
        chest_1 = 0,
        chest_2 = 0,
        chest_3 = 0,
        bodyb_1 = -1,
        bodyb_2 = 0,
        bodyb_3 = -1,
        bodyb_4 = 0,
        age_1 = 0,
        age_2 = 0,
        blemishes_1 = 0,
        blemishes_2 = 0,
        blush_1 = 0,
        blush_2 = 0,
        blush_3 = 0,
        complexion_1 = 0,
        complexion_2 = 0,
        sun_1 = 0,
        sun_2 = 0,
        moles_1 = 0,
        moles_2 = 0,
        beard_1 = 11,
        beard_2 = 10,
        beard_3 = 0,
        beard_4 = 0,
    },
    [1] = {
        mom = 28,
        dad = 6,
        face_md_weight = 63,
        skin_md_weight = 60,
        nose_1 = -10,
        nose_2 = 4,
        nose_3 = 5,
        nose_4 = 0,
        nose_5 = 0,
        nose_6 = 0,
        cheeks_1 = 0,
        cheeks_2 = 0,
        cheeks_3 = 0,
        lip_thickness = 0,
        jaw_1 = 0,
        jaw_2 = 0,
        chin_1 = -10,
        chin_2 = 10,
        chin_13 = -10,
        chin_4 = 0,
        neck_thickness = -5,
        hair_1 = 43,
        hair_2 = 0,
        hair_color_1 = 29,
        hair_color_2 = 35,
        tshirt_1 = 111,
        tshirt_2 = 5,
        torso_1 = 25,
        torso_2 = 2,
        decals_1 = 0,
        decals_2 = 0,
        arms = 3,
        arms_2 = 0,
        pants_1 = 12,
        pants_2 = 2,
        shoes_1 = 20,
        shoes_2 = 10,
        mask_1 = 0,
        mask_2 = 0,
        bproof_1 = 0,
        bproof_2 = 0,
        chain_1 = 85,
        chain_2 = 0,
        helmet_1 = -1,
        helmet_2 = 0,
        glasses_1 = 33,
        glasses_2 = 12,
        watches_1 = -1,
        watches_2 = 0,
        bracelets_1 = -1,
        bracelets_2 = 0,
        bags_1 = 0,
        bags_2 = 0,
        eye_color = 8,
        eye_squint = -6,
        eyebrows_2 = 7,
        eyebrows_1 = 32,
        eyebrows_3 = 52,
        eyebrows_4 = 9,
        eyebrows_5 = -5,
        eyebrows_6 = -8,
        makeup_1 = 0,
        makeup_2 = 0,
        makeup_3 = 0,
        makeup_4 = 0,
        lipstick_1 = 0,
        lipstick_2 = 0,
        lipstick_3 = 0,
        lipstick_4 = 0,
        ears_1 = -1,
        ears_2 = 0,
        chest_1 = 0,
        chest_2 = 0,
        chest_3 = 0,
        bodyb_1 = -1,
        bodyb_2 = 0,
        bodyb_3 = -1,
        bodyb_4 = 0,
        age_1 = 0,
        age_2 = 0,
        blemishes_1 = 0,
        blemishes_2 = 0,
        blush_1 = 0,
        blush_2 = 0,
        blush_3 = 0,
        complexion_1 = 0,
        complexion_2 = 0,
        sun_1 = 0,
        sun_2 = 0,
        moles_1 = 12,
        moles_2 = 8,
        beard_1 = 0,
        beard_2 = 0,
        beard_3 = 0,
        beard_4 = 0,
    }
}
Config.DefaulQBSkin = {
    [0] = {
        ["face"] = { item = 0, texture = 0 },
        ["mask"] = { item = 0, texture = 0 },
        ["torso2"] = { item = 0, texture = 0 },
        ["pants"] = { item = 0, texture = 0 },
        ["bag"] = { item = 0, texture = 0 },
        ["shoes"] = { item = 0, texture = 0 },
        ["accessory"] = { item = 0, texture = 0 },
        ["t-shirt"] = { item = 0, texture = 0 },
        ["vest"] = { item = 0, texture = 0 },
        ["decals"] = { item = 0, texture = 0 },
        ["torso1"] = { item = 0, texture = 0 },
        ["hat"] = { item = -1, texture = -1 },
        ["glass"] = { item = -1, texture = -1 },
        ["ear"] = { item = -1, texture = -1 },
        ["watch"] = { item = -1, texture = -1 },
        ["bracelet"] = { item = -1, texture = -1 },
        ["hair"] = { item = 0, texture = 0 },
    },
    [1] = {
        ["face"] = { item = 0, texture = 0 },
        ["mask"] = { item = 0, texture = 0 },
        ["hair"] = { item = 0, texture = 0 },
        ["torso2"] = { item = 0, texture = 0 },
        ["pants"] = { item = 0, texture = 0 },
        ["bag"] = { item = 0, texture = 0 },
        ["shoes"] = { item = 0, texture = 0 },
        ["accessory"] = { item = 0, texture = 0 },
        ["t-shirt"] = { item = 0, texture = 0 },
        ["vest"] = { item = 0, texture = 0 },
        ["decals"] = { item = 0, texture = 0 },
        ["torso1"] = { item = 0, texture = 0 },
        ["hat"] = { item = -1, texture = -1 },
        ["glass"] = { item = -1, texture = -1 },
        ["ear"] = { item = -1, texture = -1 },
        ["watch"] = { item = -1, texture = -1 },
        ["bracelet"] = { item = -1, texture = -1 },
    }
}
