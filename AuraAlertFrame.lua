-- imports
local UnitAuras = kCore.UnitAuras;
local Frame = kWidgets.Frame;
local Icon = kWidgets.Icon;
local AuraFilter = kCore.AuraFilter;

-- private
local UpdateFrame = function( self )
	local auraInfo = self.auraInfo;
	local icon = self.icon;
	
	icon:SetTexture( auraInfo.texture );	
	
	if ( auraInfo.duration ) then
		icon:ShowCooldown();
		icon:SetCooldown( auraInfo.startTime, auraInfo.duration );
	else
		icon:HideCooldown();
	end

	local auraType = auraInfo.auraType;
	if ( auraType == "Magic" ) then
		icon:SetBorderColor( 70 / 255, 70 / 255, 200 / 255 );
	elseif ( auraType == "Curse" ) then
		icon:SetBorderColor( 200 / 255, 70 / 255, 200 / 255 );
	elseif ( auraType == "Poison" ) then
		icon:SetBorderColor( 70 / 255, 200 / 255, 70 / 255 );
	else
		icon:SetBorderColor( 200 / 255, 70 / 255, 70 / 255 );
	end
end

-- event handlers
local OnUnitAura = function( self, unit )
	if ( unit ~= self.unit ) then
		return;
	end
	
	self:Update();
end

local OnPlayerTargetChanged = function( self, method )
	self:Update();
end

local OnPlayerFocusChanged = function( self )
	self:Update();
end

local OnPlayerEnteringWorld = function( self )
	self:Update();
end

-- frame scripts

-- public
local Update = function( self )
	local filter = self.filter;
	local selectedAura = self.auraInfo;
	
	selectedAura.name = nil;
	selectedAura.priority = 0;
	selectedAura.expirationTime = 0;
	
	for index, name, rank, texture, count, auraType, duration, expirationTime, _, _, _, spellId, priority in self.filter( self.unit ) do
		if ( priority and priority >= selectedAura.priority ) then
			selectedAura.name = name;
			selectedAura.texture = texture;
			selectedAura.count = count;
			selectedAura.auraType = auraType;
			selectedAura.duration = duration;
			selectedAura.startTime = expirationTime - duration;
			selectedAura.expirationTime = expirationTime;
			selectedAura.priority = priority;
		end
	end
	
	if ( selectedAura.name ) then
		UpdateFrame( self );
		self:Show();
	else
		self:Hide();
	end
end

local AddFilter = function( self, filter )
	if ( filter == nil ) then return; end
	
	self.filter:AddFilter( filter );
end

local GetUnit = function( self )
	return self.unit;
end

-- constructor
local ctor = function( self, baseCtor, unit )
	baseCtor( self );

	self.unit = unit;
	self.filter = AuraFilter( UnitAuras );
	self.auraInfo = { };
	
	local icon = Icon( true );
	icon:SetParent( self );
	icon:SetTexCoord( 0.15, 0.85, 0.15, 0.85 );
	icon:SetPoint( "TOPLEFT", self, "TOPLEFT", 0, 0 );
	icon:SetPoint( "BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, 0 );
	self.icon = icon;
	
	self:RegisterEvent( "PLAYER_ENTERING_WORLD", OnPlayerEnteringWorld );
	self:RegisterEvent( "UNIT_AURA", OnUnitAura );
	if ( unit == "target" ) then
		self:RegisterEvent( "PLAYER_TARGET_CHANGED", OnPlayerTargetChanged );
	elseif ( unit == "focus" ) then
		self:RegisterEvent( "PLAYER_FOCUS_CHANGED", OnPlayerFocusChanged );
	end
end

-- main
kCore.AuraAlertFrame = kCore.CreateClass( ctor, { 
		Update = Update,
		AddFilter = AddFilter,
		GetUnit = GetUnit
	}, Frame );