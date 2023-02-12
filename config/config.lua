Config = {}

--[[
    If you have an interior that requires more props, you can add them here.
    A prop list can be found here: https://gtahash.ru/
    A child of this table should look like this:
    { 
        coords = vector3(x, y, z), 
        model = "prop_name_or_hash",
        rotation = vector3(pitch, roll, yaw) -- OPTIONAL 
    }
]]
Config.Props = {}
Config.Locales = {
    -- CHATS
    ["CODE_INVALID"] = '<span style="width: 450px; display: inline-block; padding: 5px; border-radius: 5px; background-color: #e74c3c; font-size: 16px;"><b>Labs</b><br>You have entered an invalid code</span>',
    ["ACTION_CANCELLED"] = '<span style="width: 450px; display: inline-block; padding: 5px; border-radius: 5px; background-color: #e74c3c; font-size: 16px;"><b>Labs</b><br>You cancelled this action.</span>',
    ["CANT_CARRY"] = '<span style="width: 450px; display: inline-block; padding: 5px; border-radius: 5px; background-color: #e74c3c; font-size: 16px;"><b>Labs</b><br>Your inventory is full.</span>',
    ["NOT_ENOUGH_INGREDIENTS"] = '<span style="width: 450px; display: inline-block; padding: 5px; border-radius: 5px; background-color: #e74c3c; font-size: 16px;"><b>Labs</b><br>You don\'t have enough ingredients to process.</span>',
    ["INVALID_INPUT"] = '<span style="width: 450px; display: inline-block; padding: 5px; border-radius: 5px; background-color: #e74c3c; font-size: 16px;"><b>Labs</b><br>The input you\'ve entered is invalid.</span>',
    ["INVALID_CONFIRMATION"] = '<span style="width: 450px; display: inline-block; padding: 5px; border-radius: 5px; background-color: #e74c3c; font-size: 16px;"><b>Labs</b><br>The code you\'ve entered is not the same.</span>',
    ["LACKING_BUDGET"] = '<span style="width: 450px; display: inline-block; padding: 5px; border-radius: 5px; background-color: #e74c3c; font-size: 16px;"><b>Labs</b><br>You don\'t have enough cash on you to buy this lab.</span>',
    ["BOUGHT_LAB"] = '<span style="width: 450px; display: inline-block; padding: 5px; border-radius: 5px; background-color: #e74c3c; font-size: 16px;"><b>Labs</b><br>You have bought this lab. Your code is %i.</span>',
    ["INVALID_PERMISSIONS"] = '<span style="width: 450px; display: inline-block; padding: 5px; border-radius: 5px; background-color: #e74c3c; font-size: 16px;"><b>Labs</b><br>You don\'t have permissions to do this action.</span>',
    ["NOT_ENOUGH_SPACE"] = '<span style="width: 450px; display: inline-block; padding: 5px; border-radius: 5px; background-color: #e74c3c; font-size: 16px;"><b>Labs</b><br>You don\'t have enough space in storage.</span>',

    -- 3D TEXT
    ["ENTER_LAB"] = "~b~[E]~w~ - Enter lab",
    ["EXIT_LAB"] = "~b~[E]~w~ - Leave lab",
    ["PRODUCE"] = "~b~[E]~w~ - Collect drugs",
    ["PROCESS"] = "~b~[E]~w~ - Process drugs",
    ["MANAGE"] = "~b~[E]~w~ - Manage lab",
    ["BUY_LAB"] = "~b~[E]~w~ - Buy this lab",
    ["LABCREATOR_TELEPORTFROM"] = "Teleport from",
    ["LABCREATOR_MANAGELOC"] = "Manage",
    ["LABCREATOR_PROCESS"] = "Processing",
    ["LABCREATOR_PRODUCE"] = "Producing",

    -- LOADING SCREENS
    ["PRODUCING"] = "Collecting all drugs...",
    ["PROCESSING"] = "Collecting all drugs...",

    -- MENUS
    ["MANAGE_TITLE"] = "Manage Lab",
    ["MANAGE_CHANGE_CODE"] = "Change code",
    ["MANAGE_CHANGE_CODE_DESCRIPTION"] = "Change the code required for entering this lab.",
    ["CHANGE_CODE_PROMPT"] = "Enter a new code",
    ["CHANGE_CODE_PROMPT_CONFIRM"] = "Confirm the new code",
    ["MANAGE_OPEN_INV"] = "Open inventory",
    ["MANAGE_OPEN_INV_DESCRIPTION"] = "Enter the storage of the lab. Take or put items away in the storage.",
    ["INVENTORY_TITLE"] = "Lab inventory",
    ["DEPOSIT"] = '<span style="color: green">Deposit item<span>',
    ["LABCREATOR_TITLE"] = "Lab Creator",
    ["LABCREATOR_SET_LOCATION"] = "Set Location",
    ["LABCREATOR_SET_TELEPORTFROM"] = "Set teleport from",
    ["LABCREATOR_SET_MANAGELOC"] = "Set manage location",
    ["LABCREATOR_SET_STORAGEMAX"] = "Set storage limit",
    ["LABCREATOR_SET_BUYPRICE"] = "Set buy price",
    ["LABCREATOR_SET_PROCESS"] = "Set process location",
    ["LABCREATOR_SET_PRODUCE"] = "Set produce location",
    ["LABCREATOR_CONFIRM"] = "Confirm settings",
    ["COUNT"] = "Itemcount",

    -- OTHER
    ["CURRENCY"] = "€"
}

--[[
    A list of icons can be found here: https://fontawesome.com/search
    If you don't want an icon, you can leave it empty
]]
Config.Icons = {
    ["MANAGE_TITLE"] = "",
    ["MANAGE_CHANGE_CODE"] = "fa-solid fa-key",
    ["MANAGE_OPEN_INV"] = "fa-solid fa-warehouse",
}

--[[
    Time the action takes.
    Uses ms. Example: 7 * 1000 -- 7 seconds 
]]
Config.Delays = {
    producing = 7 * 1000,
    processing = 14 * 1000,
}

--[[
    Wether or not a lab can produce drugs.
    If disabled, you won't have the option to get all required materials
    for processing. Except if you have an other script giving these
    items.
]]
Config.CanLabProduce = true
Config.CanLabProcess = true
Config.CanLabManage  = true

--[[
    Emotes done when performing an action.
    You can change these. All emotes are found here: https://wiki.gtanet.work/index.php?title=Animations
]]
Config.ProduceEmoteDict = "mini@repair"
Config.ProduceEmoteName = "fixing_a_ped"
Config.ProcessEmoteDict = "mini@repair"
Config.ProcessEmoteName = "fixing_a_ped"

--[[
    The order of these items is very important. The player will
    receive the first item if producing. If the player is 
    processing, they will receive the second item.
]]
Config.Items = {
    "coke",
    "processed_coke",
}

--[[
    A player is required to have at least x (default 2) normal items (Config.Items[1]) to process.
    This means x (default 2) normal will be processed to 1 processed item.
]]
Config.MinNormalRequiredForProcessing = 2

--[[
    This account is used to buy a lab. Possible accounts: "money" | "bank" | "black_money".
    If you don't have enough budget on this account, you'll get the Config.Locales["LACKING_BUDGET"] in chat.
]]
Config.RequiredAccountToBuy = "money"

--[[
    See ox.md file for further information.
]]
Config.UseOXInventory = false

--[[
    Minimum group required to use the /labcreator command
]]
Config.LabCreatorMinGroup = "admin"

--[[
    WARNING: Please disable this in a live enviroment. This can be easily exploited by just triggering an event.
    In further updates, this might be fixed.
]]
Config.EnableLabCreator = true