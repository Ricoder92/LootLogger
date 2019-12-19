local AceGUI = LibStub("AceGUI-3.0")
local E, L, V, P, G = unpack(ElvUI);
local S = E:GetModule('Skins')
local pairs, assert, type = pairs, assert, type

-- WoW APIs
local PlaySound = PlaySound
local CreateFrame, UIParent = CreateFrame, UIParent

do
	local Type = "LootLoggerMainContainer"
	local Version = 5

	local function SetTitle(self,title)
		self.titletext:SetText(title)
	end


	local function SetStatusText(self,text)
		-- self.statustext:SetText(text)
	end
	
	local function Hide(self)
		self.frame:Hide()
	end
	
	local function Show(self)
		self.frame:Show()
	end

	local function SetMinResize(self, width, height)
		self.frame:SetMinResize(width, height)
	end
	
	local function OnAcquire(self)
		self.frame:SetParent(UIParent)
		self.frame:SetFrameStrata("FULLSCREEN_DIALOG")
		self:ApplyStatus()
		--self:EnableResize(true)
		self:Show()
	end
	
	local function OnRelease(self)
		self.status = nil
		for k in pairs(self.localstatus) do
			self.localstatus[k] = nil
		end
	end
	
	-- called to set an external table to store status in
	local function SetStatusTable(self, status)
		assert(type(status) == "table")
		self.status = status
		self:ApplyStatus()
	end
	
	local function ApplyStatus(self)
		local status = self.status or self.localstatus
		local frame = self.frame
		self:SetWidth(status.width or 700)
		self:SetHeight(status.height or 500)
		if status.top and status.left then
			frame:SetPoint("TOP",UIParent,"BOTTOM",0,status.top)
			frame:SetPoint("LEFT",UIParent,"LEFT",status.left,0)
		else
			frame:SetPoint("CENTER",UIParent,"CENTER")
		end
	end
	
	local function OnWidthSet(self, width)
		local content = self.content
		local contentwidth = width - 34
		if contentwidth < 0 then
			contentwidth = 0
		end
		content:SetWidth(contentwidth)
		content.width = contentwidth
	end
	
	
	local function OnHeightSet(self, height)
		local content = self.content
		local contentheight = height - 57
		if contentheight < 0 then
			contentheight = 0
		end
		content:SetHeight(contentheight)
		content.height = contentheight
	end
	
	local function Constructor()
		local frame = CreateFrame("Frame",nil,UIParent)
		local self = {}
		self.type = "LootLoggerMainContainer"
		
		self.Hide = Hide
		self.Show = Show
		self.SetTitle =  SetTitle
		self.OnRelease = OnRelease
		self.OnAcquire = OnAcquire
		self.SetStatusText = SetStatusText
		self.SetStatusTable = SetStatusTable
		self.ApplyStatus = ApplyStatus
		self.OnWidthSet = OnWidthSet
		self.OnHeightSet = OnHeightSet
		--self.EnableResize = EnableResize
		
		self.localstatus = {}
		
		self.frame = frame
		frame.obj = self

		local titlebar = CreateFrame("Frame", nil, frame)
		titlebar:SetPoint("BOTTOMLEFT", frame, "TOPLEFT", 0, 2)
		titlebar:SetSize(270 -26, 24)
		titlebar:EnableMouse(true)
		titlebar:SetMovable(true)
		titlebar:RegisterForDrag("LeftButton")
		titlebar:SetScript("OnDragStart", titlebar.StartMoving)
		titlebar:SetScript("OnDragStop", titlebar.StopMovingOrSizing)
		titlebar:SetTemplate()

		local titletext = titlebar:CreateFontString(nil, "ARTWORK")
		titletext:SetFontObject(GameFontNormal)
		titletext:SetPoint("CENTER")
		self.titletext = titletext
			
		local closeFrame = CreateFrame('Frame', nil ,titlebar)
		closeFrame:SetPoint("TOPLEFT", titlebar, "TOPRIGHT", 2, 0)
		closeFrame:SetSize(24, 24)
		closeFrame:SetTemplate()

		local close = CreateFrame('Button', nil ,titlebar)
		close:SetPoint("CENTER", closeFrame)
		close:SetScript('OnClick', function() frame:Hide() end)
		close:SetSize(24, 24)
		S:HandleCloseButton(close)

		local content_container = CreateFrame("Frame", nil, titlebar)
		content_container:SetPoint("TOPLEFT", titlebar, "BOTTOMLEFT", 0, -2)
		content_container:SetSize(270, 400)
		content_container:SetTemplate("Transparent")

		local content = CreateFrame("Frame",nil,content_container)
		self.content = content
		content.obj = self
		content:SetPoint("TOPLEFT",content_container,"TOPLEFT",20,-20)
		content:SetPoint("BOTTOMRIGHT",content_container,"BOTTOMRIGHT",-20,20)

		AceGUI:RegisterAsContainer(self)
		return self	
	end
	
	AceGUI:RegisterWidgetType(Type,Constructor,Version)
end