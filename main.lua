local Mod = RegisterMod("Locked Starting Trinkets", 1)
local json = require("json")

--------------------------------------------------------------------------------
------------------------------- Mod Config Menu --------------------------------
--------------------------------------------------------------------------------

Mod.Config = {
    --EnableAfterTaintedPostItComplete = false,
    EnabledForEden = true,
}

Mod.ModConfigMenuCategoryName = "Locked Trinkets"

-- Callback: on start
function Mod:OnStart()
    -- Load mod data on start
    local config = json.decode(Mod:LoadData())
    if config then
        Mod.Config = config
    end
end

-- Add boolean function to mod menu
function Mod:AddBooleanSetting(
    subCategoryName, --[[string]]
    attribute,       --[[string (Mod.Config.*)]]
    settingText      --[[string]]
)
    ModConfigMenu.AddSetting(
        Mod.ModConfigMenuCategoryName,
        subCategoryName,
        {
            Attribute = attribute,
            Type = ModConfigMenu.OptionType.BOOLEAN,
            Default = Mod.Config[attribute],
            Display = function()
                local onOff = Mod.Config[attribute]

                if (onOff) then
                    onOff = "True"
                else
                    onOff = "False"
                end

                return settingText .. ": " .. onOff
            end,
            OnChange = function(value)
                Mod.Config[attribute] = value
                Isaac.SaveModData(Mod, json.encode(Mod.Config))
            end,
            CurrentSetting = function()
                return Mod.Config[attribute]
            end
        }
    )
end

-- Add settings to the mod menu
function Mod:SetupModConfigMenuSettings()
    if ModConfigMenu == nil then return end

    -- Enable for Eden
    Mod:AddBooleanSetting(
        nil,               -- Subcategory name
        "EnabledForEden",  -- Attribute
        "Enabled for Eden" -- Setting text
    )

    -- Enable after completing the post-it for the tainted character
    -- todo: does not work as its not possible to read post-it progress
    --Mod:AddBooleanSetting(
    --    nil,                                            -- Subcategory name
    --    "EnableAfterTaintedPostItComplete",             -- Attribute
    --    "Enable after completing the \ntainted post-it" -- Setting text
    --)
end

Mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, Mod.OnStart)
Mod:SetupModConfigMenuSettings()

--------------------------------------------------------------------------------
---------------------------- Locked trinket - logic ----------------------------
--------------------------------------------------------------------------------

-- Callback: on game start
function Mod:OnGameStart(isContinued)
    if isContinued then return end

    -- Only enable if the post-it for the taint is complete
    --if Mod.Config.EnableAfterTaintedPostItComplete == true then
    --    local player = Isaac.GetPlayer(0)
    --    local name = player:GetName()
    --    local taintedPlayerType = Isaac.GetPlayerTypeByName(name, true)
    --
    --    -- If tinted player found
    --    if taintedPlayerType ~= -1 then
    --        --todo: get post-it data
    --        --todo: does not work as its not possible to read post-it progress
    --    end
    --end

    local player = Isaac.GetPlayer(0)

    -- Check if the player is eden
    if Mod.Config.EnabledForEden == false then
        local playerType = player:GetPlayerType()

        if playerType == PlayerType.PLAYER_EDEN or playerType == PlayerType.PLAYER_EDEN_B then
            return
        end
    end

    player:UseActiveItem(
        CollectibleType.COLLECTIBLE_SMELTER,
        false, -- show animation
        false, -- keep active item
        false, -- allow non main player
        true -- add to custome
    )
end

Mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, Mod.OnGameStart)

--------------------------------------------------------------------------------