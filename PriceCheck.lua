addon.name      = 'PriceCheck';
addon.author    = 'Ethoc';
addon.version   = '0.0.4';
addon.desc      = 'Display the Base npc price of the item being looked at';
addon.link      = 'https://github.com/96mnk28/PriceCheck';

--[[ TODO 
    save textbox position when exiting
    currently dosnt work with gamepad because i run on key input. . . Change event register to something else
    add description tag to some items that are used in hxi quests
    add the ability to toggle lines of the text on and off 
--]]
--Horizon Addon approval 
--see ticket general-contact-1008

require('common');
local ItemIDTable = require('ItemIDTable');
local fonts = require('fonts');
local PriceCheck = T{};
local useHxiData = 1-- set this to 1 to use hxi data set to 0 to use just lsb data
local fontSettings = T{
	visible = true,
	font_family = 'Calibri',--Arial
	font_height = 13,
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

----------------------------------
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
    local hxibase = ""; 
    local stacksize = "";
    local ahLocation = "";
    
    local outText = 'Price Check '..addon.version;
    local baseText = "";
    local stacksellText = "";
    local ahLocationText ="";
    local nametext = "";
    local stackselltxt = "";
    local database = "";
    local mult = 1;
    
        
    if TargetItemID ~= nil then
        local menuName = GetMenuName();
        -- List of allowed menu keywords
        -- only display when these menus are open
        -- this prevents the text box from staying open when in non item related menus like magic or job ability 
        local allowedMenus = {"auc", "moneyctr", "inv", "bank", "equip", "loot", "delivery", "shop"};
        
        -- Function to check if menu name contains any of the allowed keywords
        local function isAllowedMenu(name)
            for _, keyword in ipairs(allowedMenus) do
                if string.find(name, keyword) then
                    return true
                end
            end
            return false
        end
    
        if (ItemIDTable[TargetItemID] ~= nil) then
            if isAllowedMenu(menuName) then
                base = ItemIDTable[TargetItemID].base;
                name =  ItemIDTable[TargetItemID].name;
                stacksize = ItemIDTable[TargetItemID].stacksize;
                ahLocation = ItemIDTable[TargetItemID].ahLocation;
           
                hxibase = ItemIDTable[TargetItemID].hxibase;

                mult = 1; -- by default mult is set to 1 and then modified 
                database = "Lsb"

                if base ~= nil then 
                    if (useHxiData == 1) and (hxibase ~= nil) then -- if useHxiData is set to 1 and hxibase is not nil then set base to the hxibase data
                        base = hxibase;
                        database = "Hxi"
                    end

                    if (base == 0) then -- Sinlge qty Sell range
                        baseText= "Sell= 0";
                    else
                        if (base >= 160) then -- muilt factor changes based on the items basesell value
                            mult = 1.025; -- rank 9 factor for all items greater than or equal to 160 base gil
                        else
                            mult = 1.10; -- items under 160 base gil
                        end
                        baseText = "SellRange= ".. base.." ~ "..math.floor(base*mult);
                    end
                    if stacksize ~= nil then
                        if stacksize > 1 then
                            if base == 0  then
                                stackselltxt = "\nStackSell("..stacksize..")= 0"
                            else
                                stackselltxt = "\nStackSell("..stacksize..")= ".. base * stacksize.." ~ ".. math.floor(base*mult)*stacksize ;
                            end

                        end

                    end
                end
   
                if name ~= nil then -- add item name to the print string
                    nametext = name;
                end

                if ahLocation~= nil then -- add auction house location to the string
                    ahLocationText = ahLocation;
                end
                outText = outText .. '\n'..nametext .." ["..TargetItemID..'] |'..database..'|\n'..baseText .. stackselltxt..'\n'..ahLocationText;
                PriceCheck.FontObject.text = outText;
            else
                TargetItemID=""
                outText="";
                PriceCheck.FontObject.text = outText;
            end
        else-- if the item is NOT in the ItemIDTable AND the TargetItemID is NOT nil then show this text
            if isAllowedMenu(menuName) then
            outText = outText.. "\nItem Not Found\nTargetItemID = "..TargetItemID;
            PriceCheck.FontObject.text = outText;
            end
        end
        
        if (TargetItemID == 0) or(TargetItemID == nil) then
            TargetItemID=""
            outText="";
            PriceCheck.FontObject.text = outText;
        end--]]
    end
end);