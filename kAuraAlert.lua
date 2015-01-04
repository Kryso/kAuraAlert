local _, Internals = ...; 

-- defines
local TESTMODE = false;

local PLAYER_SIZE = 120;
local PARTY_SIZE = 59;

local SNARE = 10;
local ROOT = 50;
local STUN = 70;
local CC = 90;
local SILENCE = 90;

local MAGIC = 4;
local DISEASE = 3;
local POISON = 2;
local CURSE = 1;

local IMMUNE = 20;

-- TODO: update snares for WOD
local FILTER_SNARES = {
	-- Death Knight
	{ forceId = 45524, priority = SNARE + MAGIC }, -- Chains of Ice
	{ id = 50436, priority = SNARE }, -- Icy Clutch (Chilblains)
	-- Druid
	{ id = 58179, priority = SNARE + DISEASE }, -- Infected Wounds
	{ id = 61391, priority = SNARE }, -- Typhoon
	-- Hunter
	{ id = 35101, priority = SNARE }, -- Concussive Barrage
	{ id = 5116, priority = SNARE }, -- Concussive Shot
	{ id = 13810, priority = SNARE }, -- Frost Trap Aura
	{ id = 61394, priority = SNARE + MAGIC }, -- Glyph of Freezing Trap
	{ id = 2974, priority = SNARE }, -- Wing Clip
	-- Mage
	{ id = 11113, priority = SNARE }, -- Blast Wave
	{ id = 6136, priority = SNARE + MAGIC }, -- Chilled
	{ id = 120, priority = SNARE + MAGIC }, -- Cone of Cold
	{ id = 116, priority = SNARE + MAGIC }, -- Frostbolt
	{ id = 44614, priority = SNARE + MAGIC }, -- Frostfire Bolt
	{ id = 31589, priority = SNARE + MAGIC }, -- Slow
	-- Paladin
	{ id = 31935, priority = SNARE + MAGIC }, -- Avenger's Shield
	-- Priest
	{ id = 15407, priority = SNARE }, -- Mind Flay
	-- Rogue
	{ id = 31125, priority = SNARE }, -- Blade Twisting
	{ id = 3409, priority = SNARE + POISON, type = "DEBUFF" }, -- Crippling Poison
	{ id = 26679, priority = SNARE }, -- Deadly Throw
	-- Shaman
	{ id = 3600, priority = SNARE + MAGIC }, -- Earthbind
	{ id = 8056, priority = SNARE + MAGIC }, -- Frost Shock
	-- Warlock
	{ id = 18118, priority = SNARE + MAGIC }, -- Aftermath
	{ id = 18223, priority = SNARE + CURSE }, -- Curse of Exhaustion
	-- Hunter Pets
	{ id = 54644, priority = SNARE }, -- Froststorm Breath (Chimera)
	{ id = 50271, priority = SNARE }, -- Tendon Rip (Hyena)
	-- Warrior
	{ id = 1715, priority = SNARE }, -- Hamstring
	{ id = 12323, priority = SNARE }, -- Piercing Howl
};

local FILTER_ROOTS = {
	-- Death Knight
	{ forceId = 96294, priority = ROOT + MAGIC }, -- Chains of Ice (chillblains)
	-- Druid
	{ id = 12747, priority = ROOT + MAGIC }, -- Entangling Roots
	{ id = 102359, priority = ROOT + MAGIC }, -- Mass Entanglement
	-- Hunter
	{ id = 53148, priority = ROOT }, -- Charge (pet)
	{ id = 19387, priority = ROOT }, -- Entrapment
	{ id = 109298, priority = ROOT }, -- Narrow Escape
	-- Mage
	{ id = 33395, priority = ROOT + MAGIC }, -- Freeze (Water Elemental)
	{ id = 122, priority = ROOT + MAGIC }, -- Frost Nova
	-- Monk
	{ id = 116095, priority = ROOT }, -- Disable
	-- Priest
	{ id = 87194, priority = ROOT + MAGIC }, -- Glyph of Mind Blast
	{ id = 108920, priority = ROOT }, -- Void Tendrils
	-- Shaman
	{ id = 64695, priority = ROOT }, -- Earthgrab Totem
	{ id = 63685, priority = ROOT + MAGIC }, -- Frost Shock (Frozen Power)
	-- Warrior
	{ id = 58373, priority = ROOT }, -- Glyph of Hamstring
	{ id = 23694, priority = ROOT }, -- Improved Hamstring
};

local FILTER_STUNS = {
	-- Death Knight
	{ id = 108194, priority = STUN }, -- Asphyxiate
	{ id = 91800, priority = STUN }, -- Gnaw (Risen Ally)
	{ id = 47481, priority = STUN }, -- Gnaw (Ghoul)
	{ id = 91797, priority = STUN }, -- Monstrous Blow (DT Ghoul)
	{ id = 115001, priority = STUN + MAGIC }, -- Remorseless Winter
	-- Druid
	{ id = 5211, priority = STUN }, -- Mighty Bash
	{ id = 22570, priority = STUN }, -- Maim
	{ id = 163505, priority = STUN }, -- Rake
	-- Hunter
	{ id = 19577, priority = STUN }, -- Intimidation
	{ forceId = 117526, priority = STUN + MAGIC }, -- Binding Shot
	-- Mage
	{ id = 44572, priority = STUN + MAGIC }, -- Deep Freeze
	-- Monk
	{ id = 119392, priority = STUN + MAGIC }, -- Charging Ox Wave
	{ id = 120086, priority = STUN + MAGIC }, -- Fists of Fury
	{ id = 119381, priority = STUN + MAGIC }, -- Leg Sweep
	-- Paladin
	{ id = 105593, priority = STUN + MAGIC }, -- Fist of Justice
	{ id = 853, priority = STUN + MAGIC }, -- Hammer of Justice
	{ id = 119072, priority = STUN + MAGIC }, -- Holy Wrath
	-- Rogue
	{ id = 1833, priority = STUN }, -- Cheap Shot
	{ id = 408, priority = STUN }, -- Kidney Shot
	-- Shaman
	{ id = 118345, priority = STUN }, -- Pulverize (Primal Earth Elemental)
	{ id = 118905, priority = STUN + MAGIC }, -- Static Charge (Capacitor Totem)
	-- Warlock
	{ id = 30283, priority = STUN + MAGIC }, -- Shadowfury
	{ id = 89766, priority = STUN }, -- Axe Toss (Felguard)
	{ id = 22703, priority = STUN }, -- Summon Infernal
	-- Warrior
	{ id = 107570, priority = STUN }, -- Storm Bolt
	{ id = 46968, priority = STUN }, -- Shockwave
	-- Racials
	{ id = 20549, priority = STUN }, -- War Stomp
};

local FILTER_SILENCES = {
	-- Death Knight
	{ id = 47476, priority = SILENCE + MAGIC }, -- Strangulate
	-- Hunter
	-- Mage
	{ id = 102051, priority = SILENCE + MAGIC }, -- Frostjaw
	-- Monk
	-- Paladin
	{ id = 31935, priority = SILENCE + MAGIC }, -- Avenger's Shield
	-- Priest
	{ id = 15487, priority = SILENCE + MAGIC }, -- Silence
	-- Rogue
	{ id = 1330, priority = SILENCE }, -- Garrote - Silence
	-- Warlock
	-- Warrior
	-- Racials
	{ id = 28730, priority = SILENCE + MAGIC }, -- Arcane Torrent
};

local FILTER_CCS = {
	-- Death Knight
	-- Druid
	{ id = 33786, priority = CC + IMMUNE }, -- Cyclone
	{ id = 99, priority = CC }, -- Incapacitating Roar
	-- Hunter
	{ id = 3355, priority = CC + MAGIC }, -- Freezing Trap
	{ id = 19386, priority = CC + POISON }, -- Wyvern Sting
	-- Mage
	{ id = 31661, priority = CC + MAGIC }, -- Dragon's Breath
	{ id = 118, priority = CC + MAGIC }, -- Polymorph
	{ id = 82691, priority = CC + MAGIC }, -- Ring of Frost
	-- Monk
	{ id = 115078, priority = CC }, -- Paralysis
	{ id = 137460, priority = CC + MAGIC }, -- Ring of Peace
	-- Paladin
	{ id = 20066, priority = CC + MAGIC }, -- Repentance
	{ id = 10326, priority = CC + MAGIC }, -- Turn Evil
	-- Priest
	{ id = 605, priority = CC + MAGIC }, -- Mind Control
	{ forceId = 64044, priority = CC + MAGIC }, -- Psychic Horror
	{ id = 8122, priority = CC + MAGIC }, -- Psychic Scream
	{ id = 9484, priority = CC + MAGIC }, -- Shackle Undead
	-- Rogue
	{ id = 2094, priority = CC }, -- Blind
	{ id = 1776, priority = CC }, -- Gouge
	{ id = 6770, priority = CC }, -- Sap
	-- Shaman
	{ id = 51514, priority = CC + CURSE }, -- Hex
	-- Warlock
	{ id = 710, priority = CC + IMMUNE }, -- Banish
	{ id = 137143, priority = CC + MAGIC }, -- Blood  Horror
	{ id = 6789, priority = CC + MAGIC }, -- Mortal Coil
	{ id = 5782, priority = CC + MAGIC }, -- Fear
	{ id = 5484, priority = CC + MAGIC }, -- Howl of Terror
	{ id = 6358, priority = CC + MAGIC }, -- Seduction (Succubus)
	{ id = 115268, priority = CC + MAGIC }, -- Mesmerize (Shivarra)
	-- Warrior
	{ id = 5246, priority = CC }, -- Intimidating Shout
	-- Racial
	{ id = 107079, priority = CC }, -- Quaking Palm
};

local FILTER_BUFFS = {
	-- Buffs
	{ id = 1022, priority = 1 }, -- Hand of Protection
	{ id = 1044, priority = 1 }, -- Hand of Freedom
	{ id = 33206, priority = 1 }, -- Pain Suppression
	{ id = 31821, priority = 1 }, -- Aura mastery

	-- Burst
	{ forceId = 50334, priority = 2 }, -- Berserk
	{ forceId = 102560, priority = 2 }, -- Incarnation: Chosen of Elune
	{ forceId = 102543, priority = 2 }, -- Incarnation: King of the Jungle
	{ forceId = 102558, priority = 2 }, -- Incarnation: Son of Ursoc
	{ forceId = 31884, priority = 2 }, -- Avenging Wrath (retri)
	{ forceId = 165339, priority = 2 }, -- Ascendance (ele)
	{ forceId = 165341, priority = 2 }, -- Ascendance (enha)
	{ forceId = 12472, priority = 2 }, -- Icy Veins

	-- Turtle
	{ id = 871, priority = 1 }, -- Shield Wall
	{ id = 48707, priority = 1 }, -- Anti-Magic Shell
	{ id = 31224, priority = 1 }, -- Cloak of Shadows
	{ id = 19263, priority = 1 }, -- Deterrence

	-- Immunities
	{ id = 45438, priority = 2 }, -- Ice Block
	{ id = 642, priority = 2 }, -- Divine Shield
};

local FILTER_TEST = {
	{ id = 48068, priority = 500 }, -- Renew
	{ id = 17, priority = 500 }, -- Power Word: Shield
	{ id = 21562, priority = 500 }, -- Power Word: Fortitude
	{ name = "Blood Presence", priority = 500 }, -- Blood Presence
};

-- imports
local AuraAlertFrame = Internals.AuraAlertFrame;

-- main

-- player
local ccFrame = AuraAlertFrame( "player" );
ccFrame:AddFilter( FILTER_STUNS );
ccFrame:AddFilter( FILTER_SILENCES );
ccFrame:AddFilter( FILTER_CCS );
if ( TESTMODE ) then
	ccFrame:AddFilter( FILTER_TEST );
end
ccFrame:SetWidth( PLAYER_SIZE );
ccFrame:SetHeight( PLAYER_SIZE );
ccFrame:SetParent( UIParent );
ccFrame:SetPoint( "CENTER", UIParent, "CENTER", 0, 0 );

local rootFrame = AuraAlertFrame( "player" );
rootFrame:AddFilter( FILTER_ROOTS );
if ( TESTMODE ) then
	rootFrame:AddFilter( FILTER_TEST );
end
rootFrame:SetWidth( PLAYER_SIZE / 2 );
rootFrame:SetHeight( PLAYER_SIZE / 2 );
rootFrame:SetParent( UIParent );
rootFrame:SetPoint( "TOP", ccFrame, "BOTTOMRIGHT", 0, -5 );

local snareFrame = AuraAlertFrame( "player" );
snareFrame:AddFilter( FILTER_SNARES );
if ( TESTMODE ) then
	snareFrame:AddFilter( FILTER_TEST );
end
snareFrame:SetWidth( PLAYER_SIZE / 2 );
snareFrame:SetHeight( PLAYER_SIZE / 2 );
snareFrame:SetParent( UIParent );
snareFrame:SetPoint( "TOP", ccFrame, "BOTTOMLEFT", 0, -5 );

-- focus
--[[local focusFrame = oUF_Tukz_focus;
if ( focusFrame ) then
	local ccFrame = AuraAlertFrame( "focus" );
	ccFrame:AddFilter( FILTER_STUNS );
	ccFrame:AddFilter( FILTER_SILENCES );
	ccFrame:AddFilter( FILTER_CCS );
	if ( TESTMODE ) then
		ccFrame:AddFilter( FILTER_TEST );
	end
	ccFrame:SetWidth( PARTY_SIZE );
	ccFrame:SetHeight( PARTY_SIZE );
	ccFrame:SetParent( focusFrame );
	ccFrame:SetPoint( "BOTTOM", focusFrame, "TOP", 0, 10 );
end]]

-- arena frames
for index = 1, 5 do
	local unit = TESTMODE and "player" or ( "arena" .. tostring( index ) );
	local parent = --[[TESTMODE and UIParent or]] ( _G[ "ElvUF_Arena" .. tostring( index ) ] );

	if ( not parent ) then
		break;
	end

	local ccFrame = AuraAlertFrame( unit );
	ccFrame:AddFilter( FILTER_STUNS );
	ccFrame:AddFilter( FILTER_SILENCES );
	ccFrame:AddFilter( FILTER_CCS );
	ccFrame:AddFilter( FILTER_BUFFS );
	if ( TESTMODE ) then
		ccFrame:AddFilter( FILTER_TEST );
	end
	ccFrame:SetWidth( PARTY_SIZE );
	ccFrame:SetHeight( PARTY_SIZE );
	ccFrame:SetParent( parent );
	ccFrame:SetPoint( "RIGHT", parent, "LEFT", -10, 0 );

	local rootFrame = AuraAlertFrame( unit );
	rootFrame:AddFilter( FILTER_ROOTS );
	if ( TESTMODE ) then
		rootFrame:AddFilter( FILTER_TEST );
	end
	rootFrame:SetWidth( PARTY_SIZE / 2 + 0.5 );
	rootFrame:SetHeight( PARTY_SIZE / 2 + 0.5 );
	rootFrame:SetParent( parent );
	rootFrame:SetPoint( "TOPRIGHT", ccFrame, "TOPLEFT", 1, 0 );

	local snareFrame = AuraAlertFrame( unit );
	snareFrame:AddFilter( FILTER_SNARES );
	if ( TESTMODE ) then
		snareFrame:AddFilter( FILTER_TEST );
	end
	snareFrame:SetWidth( PARTY_SIZE / 2 + 0.5 );
	snareFrame:SetHeight( PARTY_SIZE / 2 + 0.5 );
	snareFrame:SetParent( parent );
	snareFrame:SetPoint( "BOTTOMRIGHT", ccFrame, "BOTTOMLEFT", 1, 0 );
end

-- party anchoring is handled runtime
local partyAuraFrames = { };
for index = 1, 5 do
	local unit = TESTMODE and "player" or ( index == 1 and "player" or "party" .. tostring( index - 1 ) );
	local parent = _G[ "ElvUF_PartyGroup1UnitButton" .. tostring( index ) ];

	local ccFrame = AuraAlertFrame( unit );
	ccFrame:AddFilter( FILTER_STUNS );
	ccFrame:AddFilter( FILTER_SILENCES );
	ccFrame:AddFilter( FILTER_CCS );
	if ( TESTMODE ) then
		ccFrame:AddFilter( FILTER_TEST );
	end
	ccFrame:SetWidth( PARTY_SIZE );
	ccFrame:SetHeight( PARTY_SIZE );
	if ( parent ) then
		ccFrame:SetParent( parent );
		ccFrame:SetPoint( "LEFT", parent, "RIGHT", 10, 0 );
	end

	local rootFrame = AuraAlertFrame( unit );
	rootFrame:AddFilter( FILTER_ROOTS );
	if ( TESTMODE ) then
		rootFrame:AddFilter( FILTER_TEST );
	end
	rootFrame:SetWidth( PARTY_SIZE / 2 + 0.5 );
	rootFrame:SetHeight( PARTY_SIZE / 2 + 0.5 );
	if ( parent ) then
		rootFrame:SetParent( parent );
	end
	rootFrame:SetPoint( "TOPLEFT", ccFrame, "TOPRIGHT", -1, 0 );
	ccFrame.rootFrame = rootFrame;

	local snareFrame = AuraAlertFrame( unit );
	snareFrame:AddFilter( FILTER_SNARES );
	if ( TESTMODE ) then
		snareFrame:AddFilter( FILTER_TEST );
	end
	snareFrame:SetWidth( PARTY_SIZE / 2 + 0.5 );
	snareFrame:SetHeight( PARTY_SIZE / 2 + 0.5 );
	if ( parent ) then
		snareFrame:SetParent( parent );
	end
	snareFrame:SetPoint( "BOTTOMLEFT", ccFrame, "BOTTOMRIGHT", -1, 0 );
	ccFrame.snareFrame = snareFrame;

	tinsert(partyAuraFrames, ccFrame);
end

local UpdatePoints = function() 

	for _, frame in ipairs( partyAuraFrames ) do
		local unit = frame:GetUnit();
		local unitGuid = UnitGUID(unit);
		local parent;

		for index = 1, 5 do
			parent = _G[ "ElvUF_PartyGroup1UnitButton" .. tostring( index ) ];

			if ( parent ) then
				local parentUnit = parent:GetAttribute( "unit" );

				if ( parentUnit ) then
					if ( UnitGUID( parentUnit ) == unitGuid ) then
						--print("setting point for unit " .. parentUnit);
						break;
					end
				end
			end

			parent = nil;
		end

		if ( parent ) then
			frame:SetParent( parent );
			frame.rootFrame:SetParent( parent );
			frame.snareFrame:SetParent( parent );
			frame:SetPoint( "LEFT", parent, "RIGHT", 10, 0 );
		end
	end

end

local OnGroupRosterUpdate = function( self )

	kEvents.RegisterTimer( 1, UpdatePoints );


end
kEvents.RegisterEvent( "GROUP_ROSTER_UPDATE", OnGroupRosterUpdate );
OnGroupRosterUpdate( nil );