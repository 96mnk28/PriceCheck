addon.name      = 'PriceCheck';
addon.author    = 'Ethoc';
addon.version   = '0.02';
addon.desc      = 'Display the Base npc price of the item being looked at';
addon.link      = '';

-- TODO save textbox position when exiting


require('common');
local ItemIDTable = require('ItemIDTable');
local fonts = require('fonts');
local PriceCheck = T{};

local fontSettings = T{
	visible = true,
	font_family = 'Calibri',--Arial
	font_height = 12,
	color = 0xFFFFFFFF,
	position_x = 400,
	position_y = 900,
	background = T{
		visible = true,
		color = 0xFF000000,
	}
};

PriceCheck.Initialize = function()
	PriceCheck.FontObject = fonts.new(fontSettings);	
end
PriceCheck.Initialize();

-- debugging text box

local Debug = T{};
local fontSettings2 = T{
	visible = true,
	font_family = 'Arial',
	font_height = 12,
	color = 0xFFFFFFFF,
	position_x = 400,
	position_y = 700,
	background = T{
		visible = true,
		color = 0xFF000000,
	}
};

Debug.Initialize = function()
	Debug.FontObject = fonts.new(fontSettings2);	
end
Debug.Initialize();
--]]
------------------------------------
--- Check what menu we have open
------------------------------------
local pGameMenu = ashita.memory.find('FFXiMain.dll', 0, "8B480C85C974??8B510885D274??3B05", 16, 0);
local function GetMenuName()
    local subPointer = ashita.memory.read_uint32(pGameMenu);
    local subValue = ashita.memory.read_uint32(subPointer);
    if (subValue == 0) then
        return '';
    end
    local menuHeader = ashita.memory.read_uint32(subValue + 4);
    local menuName = ashita.memory.read_string(menuHeader + 0x46, 16);
    return string.gsub(menuName, '\x00', '');
end
------------------------------------
------------------------------------


------------------------------------
---run on keybord input
------------------------------------
ashita.events.register('key', 'key_callback', function (e)
    local TargetItemID = AshitaCore:GetMemoryManager():GetInventory():GetSelectedItemId()
        local base = "";
        local basetext = "";
        local outText = 'Price Check';
    if TargetItemID ~= nil then
       --AshitaCore:GetChatManager():AddChatMessage(8, false, tostring(TargetItemID))
        --local base = "";
        --local basetext = "";
        --local outText = 'Price Check';
        local menuName = GetMenuName();
        -- only display when these menus are open
        -- this prevents the text box from staying open when in non item related menus like magic or job ability 
        local menuNameCheckAcu = string.find(menuName, "auc") 
        local menuNameCheckMoneyctr = string.find(menuName, "moneyctr") 
        local menuNameCheckInv = string.find(menuName, "inv") 
        local menuNameCheckBank = string.find(menuName, "bank") 
        local menuNameCheckEquip = string.find(menuName, "equip") 
        local menuNameCheckLoot = string.find(menuName, "loot") 
        local menuNameCheckDelivery = string.find(menuName, "delivery") 
        local menuNameCheckShop = string.find(menuName, "shop") --

        -- AshitaCore:GetChatManager():AddChatMessage(8, false, tostring(TargetItemID)) --chat message debug
        if (ItemIDTable[TargetItemID] ~= nil) then
            --[[----Debugging text for debug text box
            outTextDebug ="Price Check Debug"..'\n'..'menu='..menuName..'\n'..'ID='..TargetItemID;--debugging
            Debug.FontObject.text = outTextDebug;--debugging
            --]]
            if ((menuNameCheckAcu~=nil) or (menuNameCheckMoneyctr~=nil) or (menuNameCheckInv~=nil) or (menuNameCheckBank~=nil) or (menuNameCheckEquip~=nil) or (menuNameCheckLoot~=nil) or (menuNameCheckDelivery~=nil) or (menuNameCheckShop~=nil))  then
                base = ItemIDTable[TargetItemID].base;
                name =  ItemIDTable[TargetItemID].name;
                --check for nil text incase it isnt in the table
                if base ~= nil then 
                    basetext = " base= ".. base;
                else
                    basetext = "";
                end
                if name ~= nil then 
                    nametext = name .. '\n';
                else
                    nametext = "";
                end
                outText = outText .. '\n'..nametext .."ID= "..TargetItemID..basetext;
                PriceCheck.FontObject.text = outText;
            else
                TargetItemID=""
                outText="";
                PriceCheck.FontObject.text = outText;
            end
        end
        if TargetItemID == 0 then
            TargetItemID=""
            outText="";
            PriceCheck.FontObject.text = outText;
        end--]]
    --[[else;TargetItemID="";outText="";PriceCheck.FontObject.text = outText; --]]
    end
end);
