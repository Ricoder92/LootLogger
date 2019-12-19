local AceGUI = LibStub("AceGUI-3.0")
local E, L, V, P, G = unpack(ElvUI);
local S = E:GetModule('Skins')
local pairs, assert, type = pairs, assert, type

-- WoW APIs
local PlaySound = PlaySound
local CreateFrame, UIParent = CreateFrame, UIParent

do
	local Type = "LootLoggerScrollFrameContainer"
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
		self.type = "LootLoggerScrollFrameContainer"
		
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


		local content_container = CreateFrame("Frame", nil, frame)
		content_container:SetSize(40, 40)
        content_container:SetTemplate("Transparent")
        
        local titletext = content_container:CreateFontString(nil, "ARTWORK")
		titletext:SetFontObject(GameFontNormal)
		titletext:SetPoint("CENTER")
		self.titletext = titletext

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