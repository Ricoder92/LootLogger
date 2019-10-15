
 -- ElvUI Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local E, L, V, P, G = unpack(ElvUI);

 -- ElvUI Skin Import
local S = E:GetModule('Skins')

-- lua stuff
local select, tostring, time, unpack, tonumber, floor, pairs, tinsert, smatch, math, gsub = 
select, tostring, time, unpack, tonumber, floor, pairs, table.insert, string.match, math, gsub

-- vars
local PATTERN_LOOT_ITEM_SELF = LOOT_ITEM_SELF:gsub("%%s", "(.+)")
local PATTERN_LOOT_ITEM_SELF_MULTIPLE = LOOT_ITEM_SELF_MULTIPLE:gsub("%%s", "(.+)"):gsub("%%d", "(%%d+)")
local startTop = 0;
allMoney = 0;

--options
local option = {}
option['default_height'] = 400
option['default_width'] = 250
option['list_anmount'] = 20
option['list_height_line'] = 16
option['button_height'] = 24
local i = 0;

--title frame
local tf = CreateFrame("Frame", "LootLooger_MainFrame", UIParent)
tf:EnableMouse(true)
tf:SetPoint("CENTER")
tf:SetSize(option['default_width'] - (option['button_height']*2) - 4, option['button_height'])
tf:SetTemplate('Transparent')
tf:EnableMouse(true)
tf:SetMovable(true)
tf:RegisterForDrag("LeftButton")
tf:SetScript("OnDragStart", tf.StartMoving)
tf:SetScript("OnDragStop", tf.StopMovingOrSizing)



--title frame text
local tt = tf:CreateFontString(nil, "OVERLAY", "GameFontNormal")
tt:SetPoint("CENTER")
tt:SetText("LootLogger")

--parent frame 
local frame = CreateFrame("Frame", "MyFrame", tf) 
frame:SetSize(option['default_width']-19, (option['list_anmount'] * option['list_height_line']) + 20) 
frame:Point("TOPLEFT", tf, "TOPLEFT", 0, -(option['button_height']+2)) 
frame:SetTemplate('Transparent')

--scrollframe 
scrollframe = CreateFrame("ScrollFrame", nil, frame) 
scrollframe:SetPoint("TOPLEFT", 12, -12) 
scrollframe:SetPoint("BOTTOMRIGHT", -12, 12) 
frame.scrollframe = scrollframe 

--scrollbar 
scrollbar = CreateFrame("Slider", nil, scrollframe, "UIPanelScrollBarTemplate") 
scrollbar:SetPoint("TOPLEFT", frame, "TOPRIGHT", 2, -18) 
scrollbar:SetPoint("BOTTOMLEFT", frame, "BOTTOMRIGHT", 2, 18) 

local wf, hf = frame:GetSize()
scrollbar:SetMinMaxValues(1, hf)
scrollbar:SetValueStep(option['list_height_line']) 
scrollbar.scrollStep = 1 
scrollbar:SetValue(0) 
scrollbar:SetWidth(option['list_height_line']) 
scrollbar:SetScript("OnValueChanged", function (self, value) 
	self:GetParent():SetVerticalScroll(value) 
end) 
frame.scrollbar = scrollbar 
S:HandleScrollBar(scrollbar)

--content frame 
local content = CreateFrame("Frame", nil, scrollframe) 
content:SetSize(option['default_width']-20, (option['list_anmount'] * option['list_height_line']) - 20) 
scrollframe.content = content 
scrollframe:SetScrollChild(content)

--get lootet item
local lootevent = CreateFrame("Frame")
lootevent:RegisterEvent("CHAT_MSG_LOOT")
lootevent:SetScript("OnEvent", function(self, event, msg)
	local loottype, itemLink, quantity, source
	if msg:match(PATTERN_LOOT_ITEM_SELF_MULTIPLE) then
		loottype = "## self (multi) ##"
		itemLink, quantity = smatch(msg, PATTERN_LOOT_ITEM_SELF_MULTIPLE)
	elseif msg:match(PATTERN_LOOT_ITEM_SELF) then
		loottype = "## self (single) ##"
		itemLink = smatch(msg, PATTERN_LOOT_ITEM_SELF)
		quantity = 1
	end

	local itemID = ItemStringToItemID(itemLink)
	addToList(itemLink, quantity, itemID)
	--addToList(itemLink.."x"..quantity.." - "..MoneyToString(GetItemValue(itemID, 'dbminbuyout')*quantity))

end)

local toggleButton2 = CreateFrame('Button', 'PluginInstallCloseButton',tf)
toggleButton2:SetPoint("TOPLEFT", tf, "TOPRIGHT", 2, 0)
toggleButton2:SetScript('OnClick', function()
	if(frame:IsShown()) then
		frame:Hide()
		money:SetPoint("TOPLEFT", tf, "BOTTOMLEFT", 0, -2)
	else
		frame:Show()
		money:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", 0, -2)
	end
end)
toggleButton2:SetSize(option['button_height'], option['button_height'])
S:HandleButton(toggleButton2, true, true)
toggleButton2.text = toggleButton2:CreateFontString(nil, 'OVERLAY')
toggleButton2.text:SetAllPoints()
toggleButton2.text:FontTemplate()
toggleButton2.text:SetJustifyH("CENTER")
toggleButton2.text:SetJustifyV("MIDDLE")
toggleButton2.text:SetText("T")

--close button title frame
local closeFrame = CreateFrame('Frame', 'PluginInstallCloseButton',tf)
closeFrame:SetPoint("TOPLEFT", toggleButton2, "TOPRIGHT", 2, 0)
closeFrame:SetSize(option['button_height'], option['button_height'])
closeFrame:SetTemplate()

local close = CreateFrame('Button', 'PluginInstallCloseButton',tf, 'UIPanelCloseButton')
close:SetPoint("CENTER", closeFrame)
close:SetScript('OnClick', function() tf:Hide() end)
close:SetSize(option['button_height'], option['button_height'])
S:HandleCloseButton(close)

--toggle window
SLASH_LOOTLOGGERTOGGLE1 = '/lltoggle'; -- 3.
function SlashCmdList.LOOTLOGGERTOGGLE(msg, editbox) -- 4.
	if(tf:IsShown()) then
		tf:Hide();
		print('LootLogger - Verstecke Fenster')
	else
		tf:Show();
		print('LootLogger - Zeige Fenster LootLogger')
	end
end


money = CreateFrame("Frame", nil, tf) 
money:Size(floor((option['default_width'] / 2)) - 2 , option['button_height'])
money:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", 0, -2)
money:SetTemplate('Transparent')

local moneyAllText = money:CreateFontString(nil, "OVERLAY")
moneyAllText:SetPoint("CENTER")
moneyAllText:FontTemplate()
moneyAllText:SetText("-")
duration = CreateFrame("Frame", nil, tf) 
duration:Size((option['default_width'] / 2) , option['button_height'])
duration:SetPoint("TOPLEFT", money, "TOPRIGHT", 2, 0)
duration:SetTemplate('Transparent')


startButton = CreateFrame("Button", nil, tf) 
startButton:Size(option['default_width'] / 4, option['button_height'])
startButton:SetPoint("TOPLEFT", money, "BOTTOMLEFT", 0, -2)
startButton:SetScript('OnClick', function() 
end)
S:HandleButton(startButton, true)
startButton.text = startButton:CreateFontString(nil, 'OVERLAY')
startButton.text:SetAllPoints()
startButton.text:FontTemplate()
startButton.text:SetJustifyH("CENTER")
startButton.text:SetJustifyV("MIDDLE")
startButton.text:SetText("Start")


resetButton = CreateFrame("Button", nil, tf) 
resetButton:Size(option['default_width'] / 4, option['button_height'])
resetButton:SetPoint("TOPLEFT", startButton, "TOPRIGHT", 2, 0)
resetButton:SetText(L["Reset"])
resetButton:SetScript('OnClick', function() 
end)
S:HandleButton(resetButton, true)
resetButton.text = resetButton:CreateFontString(nil, 'OVERLAY')
resetButton.text:FontTemplate()
resetButton.text:SetAllPoints()
resetButton.text:SetJustifyH("CENTER")
resetButton.text:SetJustifyV("MIDDLE")
resetButton.text:SetText("Reset")


toggleListButton = CreateFrame("Button", nil, tf) 
toggleListButton:Size(floor((option['default_width'] / 2)) - 4, option['button_height'])
toggleListButton:SetPoint("TOPLEFT", resetButton, "TOPRIGHT", 2, 0)
toggleListButton:SetText("Toggle" .. " ")
toggleListButton:SetScript('OnClick', function() 
	if(frame:IsShown()) then
		frame:Hide()
		money:SetPoint("TOPLEFT", tf, "BOTTOMLEFT", 0, -2)
	else
		frame:Show()
		money:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", 0, -2)
	end
end)
S:HandleButton(toggleListButton, true)

-- lua api
local abs, floor, string, pairs, table, tonumber = 
      abs, floor, string, pairs, table, tonumber


function addToList(itemLink, quantity, itemID) 

	i = i + 1;

	local money = GetItemValue(itemID, 'dbminbuyout') * quantity
	allMoney = allMoney + money
	moneyAllText:SetText(MoneyToString(allMoney))

	local w, h = content:GetSize()
	w = floor(w);
	h = floor(h);

	local helloFS = content:CreateFontString(nil, 'OVERLAY')
	helloFS:FontTemplate()
	helloFS:SetPoint("TOPLEFT", content, "TOPLEFT", 0, startTop)
	startTop = startTop - option['list_height_line']
	helloFS:SetText(itemLink.."x"..quantity.." - "..MoneyToString(money))
    
	if((option['list_anmount'] * option['list_height_line']) < (i*option['list_height_line'])) then
		content:SetSize(w , (i*option['list_height_line']) - (option['list_anmount'] * option['list_height_line']))
		scrollbar:SetMinMaxValues(1,content:GetHeight())
		scrollbar:SetValue(content:GetHeight())
	end
	

	print("Scrollframe Height:"..content:GetHeight())
	print("Scrollframe Width:"..content:GetWidth())
	print("StartTopPosition:"..abs(startTop))
	print("Iteration: "..i)

end

function ItemStringToItemID(itemString)
    if not itemString then
        return
    end

    --local printable = gsub(itemString, "\124", "\124\124");
    --ChatFrame1:AddMessage("Here's what it really looks like: \"" .. printable .. "\"");

    --local itemId = LA.TSM.GetItemID(itemString)

    local _, _, Color, Ltype, Id, Enchant, Gem1, Gem2, Gem3, Gem4, Suffix, Unique, LinkLvl, reforging, Name = string.find(itemString, "|?c?f?f?(%x*)|?H?([^:]*):?(%d+):?(%d*):?(%d*):?(%d*):?(%d*):?(%d*):?(%-?%d*):?(%-?%d*):?(%d*):?(%d*)|?h?%[?([^%[%]]*)%]?|?h?|?r?")

    --ChatFrame1:AddMessage("Id: " .. Id .. " vs. " .. itemId);
    return tonumber(Id)
end

function round(num, numDecimalPlaces)
	return num - (num % 1)
end


-- Lua APIs
local tostring, pairs, ipairs, table, select, sort =
	  tostring, pairs, ipairs, table, select, sort


-- TSM3
local TSMAPI = _G.TSMAPI

-- TSM4
local TSM_API = _G.TSM_API


function GetItemValue(itemID, priceSource)

	-- TSM 3
	if TSMAPI and TSMAPI.GetItemValue then
		return TSMAPI:GetItemValue(itemID, priceSource)
	end

	-- TSM 4
	if TSM_API and TSM_API.GetCustomPriceValue then
		local itemLink
		itemLink = "i:" .. tostring(itemID)
		return TSM_API.GetCustomPriceValue(priceSource, itemLink) -- "i:" .. tostring(itemID)
	end

	return 0
end

local goldText, silverText, copperText = "|cffffd70ag|r", "|cffc7c7cfs|r", "|cffeda55fc|r"
function MoneyToString(money, ...)
    money = tonumber(money)
    if not money then return end

    local isNegative = money < 0
    money = abs(money)

    local gold = floor(money / COPPER_PER_GOLD)
    local silver = floor((money % COPPER_PER_GOLD) / COPPER_PER_SILVER)
    local copper = floor(money % COPPER_PER_SILVER)

    if money == 0 then
        return "0"..copperText
    end

    local text
    if gold > 0 then
        text = gold..goldText.." "..silver..silverText.." "..copper..copperText
    elseif silver > 0 then
        text = silver..silverText.." "..copper..copperText
    else
        text = copper..copperText
    end

    if isNegative then
        return "-"..text
    else
        return text
    end
end