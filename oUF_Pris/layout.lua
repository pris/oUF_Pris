--[[
	
	oUF_Maneut

	Author:	Maneut
	Mail:		maneut@gmx.net
	
	Credits:	ouf_Lyn - Layout is based on this awesome thing - http://www.wowinterface.com/downloads/info10326-oUF_Lyn.html
			oUF_Caellian - Code for partypets
			Haste - for coding this awesome unitframes

--]]

-- ------------------------------------------------------------------------
-- local horror
-- ------------------------------------------------------------------------
local select = select
local UnitClass = UnitClass
local UnitIsDead = UnitIsDead
local UnitIsPVP = UnitIsPVP
local UnitIsGhost = UnitIsGhost
local UnitIsPlayer = UnitIsPlayer
local UnitReaction = UnitReaction
local UnitIsConnected = UnitIsConnected
local UnitCreatureType = UnitCreatureType
local UnitClassification = UnitClassification
local UnitReactionColor = UnitReactionColor
local RAID_CLASS_COLORS = RAID_CLASS_COLORS

-- ------------------------------------------------------------------------
-- font, fontsize and textures
-- ------------------------------------------------------------------------
local font = "Interface\\AddOns\\!MSettings\\fonts\\font.ttf"
local fontsize = 15
local bartex = "Interface\\AddOns\\!MSettings\\textures\\statusbar"
local bufftex = "Interface\\AddOns\\!MSettings\\textures\\bufftex"
local frameborder = "Interface\\AddOns\\!MSettings\\textures\\frameborder"
local playerClass = select(2, UnitClass("player"))


-- ------------------------------------------------------------------------
-- castbar position
-- ------------------------------------------------------------------------
local playerCastBar_x = 0
local playerCastBar_y = -460
local targetCastBar_x = 0
local targetCastBar_y = -420

-- ------------------------------------------------------------------------
-- change some colors :)
-- ------------------------------------------------------------------------
oUF.colors.happiness = {
	[1] = {182/225, 34/255, 32/255},	-- unhappy
	[2] = {220/225, 180/225, 52/225},	-- content
	[3] = {158/255, 191/255, 86/255},	-- happy
}

-- border color
local color_rb = 0.4
local color_gb = 0.4
local color_bb = 0.4


-- ------------------------------------------------------------------------
-- right click
-- ------------------------------------------------------------------------
local menu = function(self)
	local unit = self.unit:sub(1, -2)
	local cunit = self.unit:gsub("(.)", string.upper, 1)

	if(unit == "party" or unit == "partypet") then
		ToggleDropDownMenu(1, nil, _G["PartyMemberFrame"..self.id.."DropDown"], "cursor", 0, 0)
	elseif(_G[cunit.."FrameDropDown"]) then
		ToggleDropDownMenu(1, nil, _G[cunit.."FrameDropDown"], "cursor", 0, 0)
	end
end

-- ------------------------------------------------------------------------
-- reformat everything above 9999, i.e. 10000 -> 10k and reformat everything above 999 in raidframes
-- ------------------------------------------------------------------------
local numberize = function(v)
	if v <= 9999 then return v end
	if v >= 1000000 then
		local value = string.format("%.1fm", v/1000000)
		return value
	elseif v >= 10000 then
		local value = string.format("%.1fk", v/1000)
		return value
	end
end

-- ------------------------------------------------------------------------
-- level update
-- ------------------------------------------------------------------------
local updateLevel = function(self, unit, name)
	local lvl = UnitLevel(unit)
	local typ = UnitClassification(unit)
	
	local color = GetDifficultyColor(lvl)  
        
	if lvl <= 0 then	lvl = "??" end
            
	if typ=="worldboss" then
	    self.Level:SetText("|cffff0000"..lvl.."b|r")
	elseif typ=="rareelite" then
	    self.Level:SetText(lvl.."r+")
		self.Level:SetTextColor(color.r, color.g, color.b)
	elseif typ=="elite" then
	    self.Level:SetText(lvl.."+")
		self.Level:SetTextColor(color.r, color.g, color.b)
	elseif typ=="rare" then
		self.Level:SetText(lvl.."r")
		self.Level:SetTextColor(color.r, color.g, color.b)
	else
		if UnitIsConnected(unit) == 1 then
			self.Level:SetText(lvl)
		else
			self.Level:SetText("??")
		end
		if(not UnitIsPlayer(unit)) then  
			self.Level:SetTextColor(color.r, color.g, color.b)
		else
			local _, class = UnitClass(unit) 
			color = self.colors.class[class] 
			self.Level:SetTextColor(color[1], color[2], color[3])  
		end			
	end
end

-- ------------------------------------------------------------------------
-- name update
-- ------------------------------------------------------------------------
local updateName = function(self, event, unit)
	if(self.unit ~= unit) then return end

	local name = UnitName(unit)
    	self.Name:SetText(name)	

	if unit=="targettarget" then
		local totName = UnitName(unit)
		local pName = UnitName("player")
	else
		self.Name:SetTextColor(1,1,1)
	end
	   
    if unit=="target" then -- Show level value on targets only
		updateLevel(self, unit, name)      
    end

    if(self:GetParent():GetName():match"oUF_Raid") then -- Truncate Names in Raidframes
	self.Name:SetText(string.sub(name,1,3))
    end
end


-- ------------------------------------------------------------------------
-- health update
-- ------------------------------------------------------------------------
local updateHealth = function(self, event, unit, bar, min, max)  
    local cur, maxhp = min, max
    local missing = maxhp-cur
    
    local d = floor(cur/maxhp*100)
    
	if(UnitIsDead(unit)) then
		bar:SetValue(0)
		bar.value:SetText"DEAD"
	elseif(UnitIsGhost(unit)) then
		bar:SetValue(0)
		bar.value:SetText"GHOST"
	elseif(not UnitIsConnected(unit)) then
		bar.value:SetText"D/C"

    	elseif(unit == "player") then
		if(min ~= max) then
			bar.value:SetText("|cffB62220".."-"..numberize(missing) .."|r." .."|cff9EBF56"..numberize(cur) .."|r.".. d.."%")
		else
			bar.value:SetText(" ")
		end
	elseif(unit == "targettarget") then
		bar.value:SetText(d.."%")

    	elseif(unit == "target") then
		if(d < 100) then
			bar.value:SetText("|cffB62220".."-"..numberize(missing) .."|r." .."|cff9EBF56"..numberize(cur) .."|r.".. d.."%")
		else
			bar.value:SetText("|cff9EBF56"..numberize(cur))
		end

	elseif(min == max) then
        if unit == "pet" then
			bar.value:SetText(" ") -- just here if otherwise wanted
		else
			bar.value:SetText(" ")
		end
		
      else
        if((max-min) < max) then
			if unit == "pet" then
				bar.value:SetText("|cffB62220".."-"..missing) -- negative values as for party, just here if otherwise wanted
			else
				bar.value:SetText("|cffB62220".."-"..missing) -- this makes negative values (easier as a healer)
			end
	    end
    end

    self:UNIT_NAME_UPDATE(event, unit)
end


-- ------------------------------------------------------------------------
-- power update
-- ------------------------------------------------------------------------
local updatePower = function(self, event, unit, bar, min, max)  
	if UnitIsPlayer(unit)==nil then 
		bar.value:SetText()
	else
		local _, ptype = UnitPowerType(unit)
		local color = oUF.colors.power[ptype]
		if(min==0) then 
			bar.value:SetText()
		elseif(UnitIsDead(unit) or UnitIsGhost(unit)) then
			bar:SetValue(0)
		elseif(not UnitIsConnected(unit)) then
			bar.value:SetText()
		elseif unit=="player" then 
			if((max-min) > 0) then
	            bar.value:SetText(min)
				if color then
					bar.value:SetTextColor(color[1], color[2], color[3])
				else
					bar.value:SetTextColor(0.2, 0.66, 0.93)
				end
			elseif(min==max) then
				bar.value:SetText("")
	        else
				bar.value:SetText(min)
				if color then
					bar.value:SetTextColor(color[1], color[2], color[3])
				else
					bar.value:SetTextColor(0.2, 0.66, 0.93)
				end
			end
        else
			if((max-min) > 0) then
				bar.value:SetText(min)
				if color then
					bar.value:SetTextColor(color[1], color[2], color[3])
				else
					bar.value:SetTextColor(0.2, 0.66, 0.93)
				end
			else
				bar.value:SetText(min)
				if color then
					bar.value:SetTextColor(color[1], color[2], color[3])
				else
					bar.value:SetTextColor(0.2, 0.66, 0.93)
				end
			end
		end
	end
end

-- ------------------------------------------------------------------------
-- aura reskin
-- ------------------------------------------------------------------------
local auraIcon = function(self, button, icons)
	icons.showDebuffType = true -- show debuff border type color  
	
	button.icon:SetTexCoord(.07, .93, .07, .93)
	button.icon:SetPoint("TOPLEFT", button, "TOPLEFT", 1, -1)
	button.icon:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -1, 1)
	
	button.overlay:SetTexture(bufftex)
	button.overlay:SetTexCoord(0,1,0,1)
	button.overlay.Hide = function(self) 
        self:SetVertexColor(color_rb,color_gb,color_bb) end
	
	button.cd:SetReverse()
	button.cd:SetPoint("TOPLEFT", button, "TOPLEFT", 2, -2) 
	button.cd:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -2, 2)     
end


-- ------------------------------------------------------------------------
-- the layout starts here
-- ------------------------------------------------------------------------

local func = function(self, unit)
	self.menu = menu -- Enable the menus

	self:SetScript("OnEnter", UnitFrame_OnEnter)
	self:SetScript("OnLeave", UnitFrame_OnLeave)
    
	self:RegisterForClicks"anyup"
	self:SetAttribute("*type2", "menu")

	--
	-- background
	--
	self:SetBackdrop{
	bgFile = "Interface\\ChatFrame\\ChatFrameBackground", tile = true, tileSize = 16,
	insets = {left = -2, right = -2, top = -2, bottom = -2},
	}
	self:SetBackdropColor(0,0,0,1) -- and color the backgrounds
	self:SetFrameLevel(1) 
	
	--
	-- border
	--	
	local TopLeft = self:CreateTexture(nil, "OVERLAY")
	TopLeft:SetTexture(frameborder)
	TopLeft:SetTexCoord(0, 1/3, 0, 1/3)
	TopLeft:SetPoint("TOPLEFT", self, -6, 6)
	TopLeft:SetWidth(16) TopLeft:SetHeight(16)
	TopLeft:SetVertexColor(color_rb,color_gb,color_bb)

	local TopRight = self:CreateTexture(nil, "OVERLAY")
	TopRight:SetTexture(frameborder)
	TopRight:SetTexCoord(2/3, 1, 0, 1/3)
	TopRight:SetPoint("TOPRIGHT", self, 6, 6)
	TopRight:SetWidth(16) TopRight:SetHeight(16)
	TopRight:SetVertexColor(color_rb,color_gb,color_bb)

	local BottomLeft = self:CreateTexture(nil, "OVERLAY")
	BottomLeft:SetTexture(frameborder)
	BottomLeft:SetTexCoord(0, 1/3, 2/3, 1)
	BottomLeft:SetPoint("BOTTOMLEFT", self, -6, -6)
	BottomLeft:SetWidth(16) BottomLeft:SetHeight(16)
	BottomLeft:SetVertexColor(color_rb,color_gb,color_bb)

	local BottomRight = self:CreateTexture(nil, "OVERLAY")
	BottomRight:SetTexture(frameborder)
	BottomRight:SetTexCoord(2/3, 1, 2/3, 1)
	BottomRight:SetPoint("BOTTOMRIGHT", self, 6, -6)
	BottomRight:SetWidth(16) BottomRight:SetHeight(16)
	BottomRight:SetVertexColor(color_rb,color_gb,color_bb)

	local TopEdge = self:CreateTexture(nil, "OVERLAY")
	TopEdge:SetTexture(frameborder)
	TopEdge:SetTexCoord(1/3, 2/3, 0, 1/3)
	TopEdge:SetPoint("TOPLEFT", TopLeft, "TOPRIGHT")
	TopEdge:SetPoint("TOPRIGHT", TopRight, "TOPLEFT")
	TopEdge:SetHeight(16)
	TopEdge:SetVertexColor(color_rb,color_gb,color_bb)
		
	local BottomEdge = self:CreateTexture(nil, "OVERLAY")
	BottomEdge:SetTexture(frameborder)
	BottomEdge:SetTexCoord(1/3, 2/3, 2/3, 1)
	BottomEdge:SetPoint("BOTTOMLEFT", BottomLeft, "BOTTOMRIGHT")
	BottomEdge:SetPoint("BOTTOMRIGHT", BottomRight, "BOTTOMLEFT")
	BottomEdge:SetHeight(16)
	BottomEdge:SetVertexColor(color_rb,color_gb,color_bb)
		
	local LeftEdge = self:CreateTexture(nil, "OVERLAY")
	LeftEdge:SetTexture(frameborder)
	LeftEdge:SetTexCoord(0, 1/3, 1/3, 2/3)
	LeftEdge:SetPoint("TOPLEFT", TopLeft, "BOTTOMLEFT")
	LeftEdge:SetPoint("BOTTOMLEFT", BottomLeft, "TOPLEFT")
	LeftEdge:SetWidth(16)
	LeftEdge:SetVertexColor(color_rb,color_gb,color_bb)
		
	local RightEdge = self:CreateTexture(nil, "OVERLAY")
	RightEdge:SetTexture(frameborder)
	RightEdge:SetTexCoord(2/3, 1, 1/3, 2/3)
	RightEdge:SetPoint("TOPRIGHT", TopRight, "BOTTOMRIGHT")
	RightEdge:SetPoint("BOTTOMRIGHT", BottomRight, "TOPRIGHT")
	RightEdge:SetWidth(16)
	RightEdge:SetVertexColor(color_rb,color_gb,color_bb)
    

	--
	-- healthbar
	--
	self.Health = CreateFrame"StatusBar"
	self.Health:SetHeight(11)
	self.Health:SetStatusBarTexture(bartex)
    	self.Health:SetParent(self)
	self.Health:SetPoint"TOP"
	self.Health:SetPoint"LEFT"
	self.Health:SetPoint"RIGHT"
	self.Health:SetFrameLevel(1)
	self.Health.Smooth = true
	
	--
	-- healthbar background
	--
	self.Health.bg = self.Health:CreateTexture(nil, "BORDER")
	self.Health.bg:SetAllPoints(self.Health)
	self.Health.bg:SetTexture(bartex)
	self.Health.bg:SetAlpha(0.40)

	
	--
	-- healthbar text
	--
	self.Health.value = self.Health:CreateFontString(nil, "OVERLAY")
	self.Health.value:SetPoint("TOPRIGHT", self.Health, 0, 0)
	self.Health.value:SetFont(font, fontsize)
	self.Health.value:SetTextColor(1,1,1)
	self.Health.value:SetShadowOffset(1, -1)

	--
	-- healthbar functions
	--
	self.Health.colorClass = true
	self.Health.colorReaction = true 
	self.Health.colorDisconnected = true 
	self.Health.colorTapping = true  
	self.PostUpdateHealth = updateHealth -- let the colors be  

	--
	-- powerbar
	--
	self.Power = CreateFrame"StatusBar"
	self.Power:SetHeight(5)
	self.Power:SetStatusBarTexture(bartex)
	self.Power:SetParent(self)
	self.Power:SetPoint"LEFT"
	self.Power:SetPoint"RIGHT"
	self.Power:SetPoint("TOP", self.Health, "BOTTOM", 0, -1.45) -- Little offset to make it pretty
	self.Power.frequentUpdates = true
	self.Power:SetFrameLevel(1)
	self.Power.Smooth = true

	--
	-- powerbar background
	--
	self.Power.bg = self.Power:CreateTexture(nil, "BORDER")
	self.Power.bg:SetAllPoints(self.Power)
	self.Power.bg:SetTexture(bartex)
	self.Power.bg:SetAlpha(0.30)  

	--
	-- powerbar text
	--
	self.Power.value = self.Power:CreateFontString(nil, "OVERLAY")
    	self.Power.value:SetPoint("TOPLEFT", self.Health, 0, 0)
	self.Power.value:SetFont(font, fontsize)
	self.Power.value:SetTextColor(1,1,1)
	self.Power.value:SetShadowOffset(1, -1)
    	self.Power.value:Hide()
    
    --
	-- powerbar functions
	--
	self.Power.colorTapping = true 
	self.Power.colorDisconnected = true 
	self.Power.colorClass = true 
	self.Power.colorPower = true 
	self.Power.colorHappiness = false  
	self.PostUpdatePower = updatePower -- let the colors be  

	--
	-- names
	--
	self.Name = self.Health:CreateFontString(nil, "OVERLAY")
    	self.Name:SetPoint("TOPLEFT", self.Health, 0, 0)
    	self.Name:SetJustifyH("LEFT")
	self.Name:SetFont(font, fontsize)
	self.Name:SetShadowOffset(1, -1)
    	self.UNIT_NAME_UPDATE = updateName

	--
	-- level
	--
	self.Level = self.Health:CreateFontString(nil, "OVERLAY")
	self.Level:SetPoint("TOPLEFT", self.Health, 0, 0)
	self.Level:SetJustifyH("LEFT")
	self.Level:SetFont(font, fontsize)
    	self.Level:SetTextColor(1,1,1)
	self.Level:SetShadowOffset(1, -1)
	self.UNIT_LEVEL = updateLevel
	
	-- ------------------------------------
	-- player
	-- ------------------------------------
	if unit=="player" then
        self:SetWidth(252)
        self:SetHeight(18)
	    self.Name:Hide()
	    self.Health.value:SetPoint("TOPRIGHT", self.Health, 0, -25)
        self.Power.value:Show()
	    self.Power.value:SetPoint("TOPLEFT", self.Health, 0, -25)
	    self.Power.value:SetJustifyH("LEFT")
	    self.Level:Hide()
		
		--
		-- debuffs
		--
		self.Debuffs = CreateFrame("Frame", nil, self)
		self.Debuffs.size = 40
		self.Debuffs:SetHeight(self.Debuffs.size)
		self.Debuffs:SetWidth(self.Debuffs.size * 5)
		self.Debuffs:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", 0, 15)
		self.Debuffs.initialAnchor = "BOTTOMRIGHT"
		self.Debuffs["growth-y"] = "TOP"
		self.Debuffs["growth-x"] = "LEFT"
		self.Debuffs.num = 10
		self.Debuffs.spacing = 3

		--
		-- leader icon
		--
		self.Leader = self.Health:CreateTexture(nil, "OVERLAY")
		self.Leader:SetHeight(12)
		self.Leader:SetWidth(12)
		self.Leader:SetPoint("TOPLEFT", self, -2, 17)
		self.Leader:SetTexture"Interface\\GroupFrame\\UI-Group-LeaderIcon"
		        
		--
		-- oUF_PowerSpark support
		--
        self.Spark = self.Power:CreateTexture(nil, "OVERLAY")
		self.Spark:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
		self.Spark:SetVertexColor(1, 1, 1, 1)
		self.Spark:SetBlendMode("ADD")
		self.Spark:SetHeight(self.Power:GetHeight()*2.5)
		self.Spark:SetWidth(self.Power:GetHeight()*2)		
	end

	-- ------------------------------------
	-- pet
	-- ------------------------------------
	if unit=="pet" then
        self:SetWidth(120)
        self:SetHeight(18)
	    self.Health.value:SetPoint("TOPRIGHT", self.Health, 0, -25)
	    self.Power.value:Hide()
	    self.Level:Hide()
	    self.Name:Show()
	    self.Name:SetPoint("TOPLEFT", self.Health, 0, -25)
	    self.Name:SetWidth(95)
	    self.Name:SetHeight(fontsize)
        self.Health.value:SetHeight(fontsize)
		
		if playerClass=="HUNTER" then
			self.Health.colorReaction = false
			self.Health.colorClass = false
			self.Health.colorHappiness = true  
		end
	end

	-- ------------------------------------
	-- target
	-- ------------------------------------
    if unit=="target" then
	    self:SetWidth(252)
	    self:SetHeight(18)
	    self.Power.value:Hide()
	    self.Health.value:SetPoint("TOPRIGHT", self.Health, 0, -25)
	    self.Level:SetPoint("TOPLEFT", self.Health, 0, -25)
	    self.Name:SetPoint("TOPLEFT", self.Level, "TOPRIGHT", 3, 0)
	    self.Name:SetWidth(100)			
	    self.Name:SetHeight(fontsize)
	    self.Health.value:SetHeight(fontsize)
		
		--
		-- combo points
		--
		self.CPoints = self:CreateFontString(nil, "OVERLAY")
		self.CPoints:SetPoint("RIGHT", self, "RIGHT", 18, 0)
		self.CPoints:SetFont(font, 18, "OUTLINE")
		self.CPoints:SetTextColor(0, 0.81, 1)
		self.CPoints:SetShadowOffset(1, -1)
		self.CPoints:SetJustifyH"RIGHT"
		
		--
		-- raid target icons
		--
		self.RaidIcon = self.Health:CreateTexture(nil, "OVERLAY")
		self.RaidIcon:SetHeight(16)
		self.RaidIcon:SetWidth(16)
		self.RaidIcon:SetPoint("CENTER", self, "CENTER", 0, 10)
		self.RaidIcon:SetTexture"Interface\\TargetingFrame\\UI-RaidTargetingIcons"
		
		--
		-- auras
		--
		self.Auras = CreateFrame("Frame", nil, self)
		self.Auras.size = 24
		self.Auras.gap = true
		self.Auras:SetHeight(self.Auras.size)
		self.Auras:SetWidth(self.Auras.size * 11)
		self.Auras:SetPoint("BOTTOMLEFT", self, "TOPLEFT", -4, 15)
		self.Auras.initialAnchor = "TOPLEFT"
		self.Auras["growth-y"] = "TOP"
		self.Auras.numBuffs = 40
		self.Auras.numDebuffs = 40
		self.Auras.spacing = 2
	end


	-- ------------------------------------
	-- target of target and focus
	-- ------------------------------------

	if unit=="targettarget" or unit=="focus" then
	  self:SetWidth(120)
	  self:SetHeight(18)
	  self.Power.value:Hide()
	  self.Health.value:SetPoint("TOPRIGHT", self.Health, 0, -25)
	  self.Name:SetPoint("TOPLEFT", self.Health, 0, -25)
	  self.Name:SetWidth(95)
	  self.Name:SetHeight(fontsize)
	  self.Health.value:SetHeight(fontsize)

	  self.ignoreDruidHots = true
		
		--
		-- raid target icons
		--
		self.RaidIcon = self.Health:CreateTexture(nil, "OVERLAY")
		self.RaidIcon:SetHeight(16)
		self.RaidIcon:SetWidth(16)
		self.RaidIcon:SetPoint("CENTER", self, 0, 10)
		self.RaidIcon:SetTexture"Interface\\TargetingFrame\\UI-RaidTargetingIcons"
		
	end
	

	-- ------------------------------------
	-- player and target castbar
	-- ------------------------------------	
	if(unit == 'player' or unit == 'target') then
	    self.Castbar = CreateFrame('StatusBar', nil, self)
	    self.Castbar:SetStatusBarTexture(bartex)
	    		
	if(unit == "player") then
		local _, class = UnitClass(unit) 
		color = self.colors.class[class] 
		self.Castbar:SetStatusBarColor(color[1], color[2], color[3]) 
		self.Castbar:SetHeight(11)
		self.Castbar:SetWidth(252)

			self.Castbar:SetBackdrop{
				bgFile = "Interface\\ChatFrame\\ChatFrameBackground", tile = true, tileSize = 16,
				insets = {left = -2, right = -2, top = -2, bottom = -2}}

			self.Castbar.SafeZone = self.Castbar:CreateTexture(nil,"ARTWORK")
			self.Castbar.SafeZone:SetTexture(bartex)
			self.Castbar.SafeZone:SetVertexColor(.75,.10,.10,.6)
			self.Castbar.SafeZone:SetPoint("TOPRIGHT")
			self.Castbar.SafeZone:SetPoint("BOTTOMRIGHT")
			
			self.Castbar:SetPoint('CENTER', UIParent, 'CENTER', playerCastBar_x, playerCastBar_y)

		else
			self.Castbar:SetStatusBarColor(0.80, 0.01, 0)
			self.Castbar:SetHeight(11)
			self.Castbar:SetWidth(252)
			
			self.Castbar:SetBackdrop{
				bgFile = "Interface\\ChatFrame\\ChatFrameBackground", tile = true, tileSize = 16,
				insets = {left = -2, right = -2, top = -2, bottom = -2}}

			self.Castbar:SetPoint('CENTER', UIParent, 'CENTER', targetCastBar_x, targetCastBar_y)
		end
		
			self.Castbar:SetBackdropColor(0, 0, 0, 0.5)
		
			self.Castbar.Text = self.Castbar:CreateFontString(nil, 'OVERLAY')
	    	self.Castbar.Text:SetPoint('LEFT', self.Castbar, 0, -20)
	    	self.Castbar.Text:SetFont(font, fontsize)
			self.Castbar.Text:SetShadowOffset(1, -1)
	    	self.Castbar.Text:SetTextColor(1, 1, 1)
	    	self.Castbar.Text:SetJustifyH('LEFT')

	    	self.Castbar.Time = self.Castbar:CreateFontString(nil, 'OVERLAY')
	    	self.Castbar.Time:SetPoint('RIGHT', self.Castbar, 0, -20)
	    	self.Castbar.Time:SetFont(font, fontsize)
			self.Castbar.Time:SetShadowOffset(1, -1)
	    	self.Castbar.Time:SetTextColor(1, 1, 1)
	    	self.Castbar.Time:SetJustifyH('RIGHT')
			
			--
			-- Castbar frameborder
			--
			local TopLeft = self.Castbar:CreateTexture(nil, "OVERLAY")
			TopLeft:SetTexture(frameborder)
			TopLeft:SetTexCoord(0, 1/3, 0, 1/3)
			TopLeft:SetPoint("TOPLEFT", -6, 6)
			TopLeft:SetWidth(16) TopLeft:SetHeight(16)
			TopLeft:SetVertexColor(color_rb,color_gb,color_bb)
	
			local TopRight = self.Castbar:CreateTexture(nil, "OVERLAY")
			TopRight:SetTexture(frameborder)
			TopRight:SetTexCoord(2/3, 1, 0, 1/3)
			TopRight:SetPoint("TOPRIGHT", 6, 6)
			TopRight:SetWidth(16) TopRight:SetHeight(16)
			TopRight:SetVertexColor(color_rb,color_gb,color_bb)

			local BottomLeft = self.Castbar:CreateTexture(nil, "OVERLAY")
			BottomLeft:SetTexture(frameborder)
			BottomLeft:SetTexCoord(0, 1/3, 2/3, 1)
			BottomLeft:SetPoint("BOTTOMLEFT", -6, -6)
			BottomLeft:SetWidth(16) BottomLeft:SetHeight(16)
			BottomLeft:SetVertexColor(color_rb,color_gb,color_bb)

			local BottomRight = self.Castbar:CreateTexture(nil, "OVERLAY")
			BottomRight:SetTexture(frameborder)
			BottomRight:SetTexCoord(2/3, 1, 2/3, 1)
			BottomRight:SetPoint("BOTTOMRIGHT", 6, -6)
			BottomRight:SetWidth(16) BottomRight:SetHeight(16)
			BottomRight:SetVertexColor(color_rb,color_gb,color_bb)

			local TopEdge = self.Castbar:CreateTexture(nil, "OVERLAY")
			TopEdge:SetTexture(frameborder)
			TopEdge:SetTexCoord(1/3, 2/3, 0, 1/3)
			TopEdge:SetPoint("TOPLEFT", TopLeft, "TOPRIGHT")
			TopEdge:SetPoint("TOPRIGHT", TopRight, "TOPLEFT")
			TopEdge:SetHeight(16)
			TopEdge:SetVertexColor(color_rb,color_gb,color_bb)
		
			local BottomEdge = self.Castbar:CreateTexture(nil, "OVERLAY")
			BottomEdge:SetTexture(frameborder)
			BottomEdge:SetTexCoord(1/3, 2/3, 2/3, 1)
			BottomEdge:SetPoint("BOTTOMLEFT", BottomLeft, "BOTTOMRIGHT")
			BottomEdge:SetPoint("BOTTOMRIGHT", BottomRight, "BOTTOMLEFT")
			BottomEdge:SetHeight(16)
			BottomEdge:SetVertexColor(color_rb,color_gb,color_bb)
		
			local LeftEdge = self.Castbar:CreateTexture(nil, "OVERLAY")
			LeftEdge:SetTexture(frameborder)
			LeftEdge:SetTexCoord(0, 1/3, 1/3, 2/3)
			LeftEdge:SetPoint("TOPLEFT", TopLeft, "BOTTOMLEFT")
			LeftEdge:SetPoint("BOTTOMLEFT", BottomLeft, "TOPLEFT")
			LeftEdge:SetWidth(16)
			LeftEdge:SetVertexColor(color_rb,color_gb,color_bb)
		
			local RightEdge = self.Castbar:CreateTexture(nil, "OVERLAY")
			RightEdge:SetTexture(frameborder)
			RightEdge:SetTexCoord(2/3, 1, 1/3, 2/3)
			RightEdge:SetPoint("TOPRIGHT", TopRight, "BOTTOMRIGHT")
			RightEdge:SetPoint("BOTTOMRIGHT", BottomRight, "TOPRIGHT")
			RightEdge:SetWidth(16)
			RightEdge:SetVertexColor(color_rb,color_gb,color_bb)			
	end

 	
	-- ------------------------------------
	-- party 
	-- ------------------------------------
	if(self:GetParent():GetName():match"oUF_Party") then
	  self:SetWidth(200)
	  self:SetHeight(18)
	  self.Power.value:Hide()
	  self.Health.value:SetPoint("TOPRIGHT", self.Health, 0, -25)
	  self.Name:SetPoint("TOPLEFT", self.Health, 0, -25)
	  self.Name:SetWidth(150)
		
		--
		-- raid target icons
		--
		self.RaidIcon = self.Health:CreateTexture(nil, "OVERLAY")
		self.RaidIcon:SetHeight(16)
		self.RaidIcon:SetWidth(16)
		self.RaidIcon:SetPoint("CENTER", self, 0, 10)
		self.RaidIcon:SetTexture"Interface\\TargetingFrame\\UI-RaidTargetingIcons"

		--
		-- leader icon
		--
		self.Leader = self.Health:CreateTexture(nil, "OVERLAY")
		self.Leader:SetHeight(12)
		self.Leader:SetWidth(12)
		self.Leader:SetPoint("BOTTOMLEFT", self, -17, 6)
		self.Leader:SetTexture"Interface\\GroupFrame\\UI-Group-LeaderIcon"
       		
		--
		-- auras
		--
		self.Auras = CreateFrame("Frame", nil, self) -- auras
		self.Auras.buffFilter= "HELPFUL|RAID"
		self.Auras.size = 24
		self.Auras.gap = true
		self.Auras:SetHeight(self.Auras.size)
		self.Auras:SetWidth(self.Auras.size * 9)
		self.Auras:SetPoint("BOTTOMLEFT", self, "TOPLEFT", -4, 10)
		self.Auras.initialAnchor = "TOPLEFT"
		self.Auras.numBuffs = 5
		self.Auras.numDebuffs = 2
		self.Auras.spacing = 2

	end

	-- ------------------------------------
	-- partypets
	-- ------------------------------------
	if(unit and unit:find('partypet%d')) then
	  self:SetWidth(150)
	  self:SetHeight(18)
	  self.Power.value:Hide()
	  self.Health.value:SetPoint("TOPRIGHT", self.Health, 0, -25)
	  self.Name:SetPoint("TOPLEFT", self.Health, 0, -25)
	  self.Name:SetWidth(150)
	
		--
		-- auras
		--
		self.Auras = CreateFrame("Frame", nil, self) -- auras
		self.Auras.buffFilter= "HELPFUL|RAID"
		self.Auras.size = 24
		self.Auras.gap = true
		self.Auras:SetHeight(self.Auras.size)
		self.Auras:SetWidth(self.Auras.size * 6)
		self.Auras:SetPoint("BOTTOMLEFT", self, "TOPLEFT", -4, 10)
		self.Auras.initialAnchor = "TOPLEFT"
		self.Auras.numBuffs = 4
		self.Auras.numDebuffs = 2
		self.Auras.spacing = 2

	end

    --
	-- fading
	--
	  self.SpellRange = true -- put true to make party/raid frames fade out if not in your range
	  self.inRangeAlpha = 1.0 -- what alpha if IN range
	  self.outsideRangeAlpha = 0.5 -- the alpha it will fade out to if not in range
	 
	--
	-- custom aura textures
	--
	  self.PostCreateAuraIcon = auraIcon
	  self.SetAuraPosition = auraOffset

	return self
	
end
-- ------------------------------------------------------------------------
-- spawning the frames
-- ------------------------------------------------------------------------

--
-- normal frames
--
oUF:RegisterStyle("Maneut", func)
oUF:SetActiveStyle("Maneut")

local player = oUF:Spawn("player", "oUF_Player")
player:SetPoint("CENTER", -210, -325)

local target = oUF:Spawn("target", "oUF_Target")
target:SetPoint("CENTER", 210, -325) 

local pet = oUF:Spawn("pet", "oUF_Pet")
pet:SetPoint("BOTTOMLEFT", player, 0, -50)

local tot = oUF:Spawn("targettarget", "oUF_TargetTarget")
tot:SetPoint("CENTER", 0, -325)

local focus	= oUF:Spawn("focus", "oUF_Focus")
focus:SetPoint("BOTTOMLEFT", tot, 0, -50)

--
-- party
--
local party = oUF:Spawn("header", "oUF_Party")
party:SetManyAttributes("showParty", true, "yOffset", 105)
party:SetPoint("TOPLEFT", player, -225, 0)
party:Show()
party:SetAttribute("showRaid", false)


--
-- partypets
--
local partypet = {}
partypet[1] = oUF:Spawn('partypet1', 'oUF_PartyPet1')
partypet[1]:SetPoint('TOPLEFT', party, 'TOPLEFT', -170, 0)
for i =2, 4 do
	partypet[i] = oUF:Spawn('partypet'..i, 'oUF_PartyPet'..i)
	partypet[i]:SetPoint('TOP', partypet[i-1], 'BOTTOM', 0, 105)
end

    --
-- party toggle in raid
--
local partyToggle = CreateFrame('Frame')
partyToggle:RegisterEvent('PLAYER_LOGIN')
partyToggle:RegisterEvent('RAID_ROSTER_UPDATE')
partyToggle:RegisterEvent('PARTY_LEADER_CHANGED')
partyToggle:RegisterEvent('PARTY_MEMBERS_CHANGED')
partyToggle:SetScript('OnEvent', function(self)
	if(InCombatLockdown()) then
		self:RegisterEvent('PLAYER_REGEN_ENABLED')
	else
		self:UnregisterEvent('PLAYER_REGEN_ENABLED')
		if(GetNumRaidMembers() > 1) then
			party:Hide()
			for i,v in ipairs(partypet) do v:Disable()	end
		else
			party:Show()
			for i,v in ipairs(partypet) do v:Enable()	end
		end
	end
end)