-- defines
local TESTMODE = false;

local PLAYER_SIZE = 150;
local PARTY_SIZE = 59;

local SNARE = 10;
local DISARM = 30;
local ROOT = 50;
local STUN = 70;
local CC = 90;
local SILENCE = 90;

local MAGIC = 4;
local DISEASE = 3;
local POISON = 2;
local CURSE = 1;

local IMMUNE = 20;

local FILTER_SNARES = {
		-- Death Knight
		{ id = 45524, priority = SNARE + MAGIC }, -- Chains of Ice
		{ id = 55741, priority = SNARE }, -- Desecration (no duration, lasts as long as you stand in it)
		{ id = 58617, priority = SNARE }, -- Glyph of Heart Strike
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
		{ id = 3409, priority = SNARE }, -- Crippling Poison
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
		-- Druid
		{ id = 339, priority = ROOT + MAGIC }, -- Entangling Roots
		{ id = 45334, priority = ROOT }, -- Feral Charge Effect
		-- Hunter
		{ id = 19306, priority = ROOT }, -- Counterattack
		{ id = 19185, priority = ROOT + MAGIC }, -- Entrapment
		{ id = 50245, priority = ROOT + MAGIC }, -- Pin (Crab)
		{ id = 54706, priority = ROOT + MAGIC }, -- Venom Web Spray (Silithid)
		{ id = 4167, priority = ROOT + MAGIC }, -- Web (Spider)
		-- Mage
		{ id = 33395, priority = ROOT + MAGIC }, -- Freeze (Water Elemental)
		{ id = 122, priority = ROOT + MAGIC }, -- Frost Nova
		{ id = 55080, priority = ROOT + MAGIC }, -- Shattered Barrier
		-- Shaman
		{ id = 64695, priority = ROOT }, -- Earthgrab
		{ id = 63685, priority = ROOT + MAGIC }, -- Freeze
		-- Warrior
		{ id = 58373, priority = ROOT }, -- Glyph of Hamstring
		{ id = 23694, priority = ROOT }, -- Improved Hamstring
	};

local FILTER_STUNS = {
		-- Death Knight
		{ id = 47481, priority = STUN }, -- Gnaw (Ghoul)
		-- Druid
		{ id = 5211, priority = STUN }, -- Bash
		{ id = 22570, priority = STUN }, -- Maim
		{ id = 9005, priority = STUN }, -- Pounce
		-- Hunter
		{ id = 24394, priority = STUN }, -- Intimidation
		{ id = 50519, priority = STUN }, -- Sonic Blast (Bat)
		{ id = 50518, priority = STUN }, -- Ravage (Ravager)
		-- Mage
		{ id = 44572, priority = STUN + MAGIC }, -- Deep Freeze
		{ id = 12355, priority = STUN }, -- Impact
		-- Paladin
		{ id = 853, priority = STUN + MAGIC }, -- Hammer of Justice
		{ id = 2812, priority = STUN + MAGIC }, -- Holy Wrath
		{ id = 20170, priority = STUN }, -- Stun (Seal of Justice proc)
		-- Rogue
		{ id = 1833, priority = STUN }, -- Cheap Shot
		{ id = 408, priority = STUN }, -- Kidney Shot
		-- Shaman
		{ id = 39796, priority = STUN + MAGIC }, -- Stoneclaw Stun
		-- Warlock
		{ id = 30283, priority = STUN + MAGIC }, -- Shadowfury
		{ id = 30153, priority = STUN }, -- Intercept (Felguard)
		-- Warrior
		{ id = 7922, priority = STUN }, -- Charge Stun
		{ id = 12809, priority = STUN }, -- Concussion Blow
		{ id = 20253, priority = STUN }, -- Intercept
		{ id = 12798, priority = STUN }, -- Revenge Stun
		{ id = 46968, priority = STUN }, -- Shockwave
		-- Racials
		{ id = 20549, priority = STUN }, -- War Stomp
	};

local FILTER_SILENCES = {
		-- Death Knight
		{ id = 47476, priority = SILENCE + MAGIC }, -- Strangulate
		-- Hunter
		{ id = 34490, priority = SILENCE + MAGIC }, -- Silencing Shot
		-- Mage
		{ id = 18469, priority = SILENCE + MAGIC }, -- Silenced - Improved Counterspell
		-- Paladin
		{ id = 63529, priority = SILENCE + MAGIC }, -- Shield of the Templar
		-- Priest
		{ id = 15487, priority = SILENCE + MAGIC }, -- Silence
		-- Rogue
		{ id = 1330, priority = SILENCE }, -- Garrote - Silence
		{ id = 18425, priority = SILENCE + MAGIC }, -- Silenced - Improved Kick
		-- Warlock
		{ id = 24259, priority = SILENCE }, -- Spell Lock (Felhunter)
		-- Warrior
		{ id = 18498, priority = SILENCE }, -- Silenced (Gag Order)
		-- Racials
		{ id = 25046, priority = SILENCE + MAGIC }, -- Arcane Torrent
	};

local FILTER_DISARMS = {
		-- Hunter
		{ id = 53359, priority = DISARM }, -- Chimera Shot - Scorpid
		{ id = 50541, priority = DISARM }, -- Snatch (Bird of Prey)
		-- Priest
		{ forceId = 64058, priority = DISARM }, -- Psychic Horror
		-- Rogue
		{ id = 51722, priority = DISARM }, -- Dismantle
		-- Warrior
		{ id = 676, priority = DISARM }, -- Disarm
	};

local FILTER_CCS = {
		-- Death Knight
		{ id = 51209, priority = CC + MAGIC }, -- Hungering Cold
		-- Druid
		{ id = 33786, priority = CC + IMMUNE }, -- Cyclone
		{ id = 2637, priority = CC + MAGIC }, -- Hibernate
		-- Hunter
		{ id = 3355, priority = CC + MAGIC }, -- Freezing Trap Effect
		{ id = 60210, priority = CC + MAGIC }, -- Freezing Arrow Effect
		{ id = 1513, priority = CC + MAGIC }, -- Scare Beast
		{ id = 19503, priority = CC }, -- Scatter Shot
		{ forceId = 19386, priority = CC + POISON }, -- Wyvern Sting 1
		{ forceId = 24132, priority = CC + POISON }, -- Wyvern Sting 2
		{ forceId = 24133, priority = CC + POISON }, -- Wyvern Sting 3
		{ forceId = 27068, priority = CC + POISON }, -- Wyvern Sting 4
		{ forceId = 49011, priority = CC + POISON }, -- Wyvern Sting 5
		{ forceId = 49012, priority = CC + POISON }, -- Wyvern Sting 6
		-- Mage
		{ id = 31661, priority = CC + MAGIC }, -- Dragon's Breath
		{ id = 118, priority = CC + MAGIC }, -- Polymorph
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
		{ id = 6789, priority = CC + MAGIC }, -- Death Coil
		{ id = 5782, priority = CC + MAGIC }, -- Fear
		{ id = 5484, priority = CC + MAGIC }, -- Howl of Terror
		{ id = 6358, priority = CC + MAGIC }, -- Seduction (Succubus)
		-- Warrior
		{ id = 20511, priority = CC }, -- Intimidating Shout
	};

local FILTER_BUFFS = {
		-- Buffs
		{ id = 1022, priority = 1 }, -- Hand of Protection
		{ id = 1044, priority = 1 }, -- Hand of Freedom
		{ id = 2825, priority = 1 }, -- Bloodlust
		{ id = 32182, priority = 1 }, -- Heroism
		{ id = 33206, priority = 1 }, -- Pain Suppression
		{ id = 29166, priority = 1 }, -- Innervate
		{ id = 18708, priority = 1 }, -- Fel Domination
		{ id = 54428, priority = 1 }, -- Divine Plea
		{ id = 31821, priority = 1 }, -- Aura mastery

		-- Turtling abilities
		{ id = 871, priority = 1 }, -- Shield Wall
		{ id = 48707, priority = 1 }, -- Anti-Magic Shell
		{ id = 31224, priority = 1 }, -- Cloak of Shadows
		{ id = 19263, priority = 1 }, -- Deterrence

		-- Immunities
		{ id = 34471, priority = 2 }, -- The Beast Within
		{ id = 45438, priority = 2 }, -- Ice Block
		{ id = 642, priority = 2 }, -- Divine Shield
		{ forceId = 50334, priority = 2 }, -- Berserk
	};

local FILTER_TEST = {
		{ id = 48068, priority = 500 }, -- Renew
	};

-- imports
local AuraAlertFrame = kCore.AuraAlertFrame;

-- main

-- player
local ccFrame = AuraAlertFrame( "player" );
ccFrame:AddFilter( FILTER_STUNS );
ccFrame:AddFilter( FILTER_SILENCES );
ccFrame:AddFilter( FILTER_DISARMS );
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
local focusFrame = oUF_Tukz_focus;
if ( focusFrame ) then
	local ccFrame = AuraAlertFrame( "focus" );
	ccFrame:AddFilter( FILTER_STUNS );
	ccFrame:AddFilter( FILTER_SILENCES );
	ccFrame:AddFilter( FILTER_DISARMS );
	ccFrame:AddFilter( FILTER_CCS );
	if ( TESTMODE ) then
		ccFrame:AddFilter( FILTER_TEST );
	end
	ccFrame:SetWidth( PARTY_SIZE );
	ccFrame:SetHeight( PARTY_SIZE );
	ccFrame:SetParent( focusFrame );
	ccFrame:SetPoint( "BOTTOM", focusFrame, "TOP", 0, 10 );
end

-- arena frames
for index = 1, 5 do
	local unit = TESTMODE and "player" or ( "arena" .. tostring( index ) );
	local parent = TESTMODE and UIParent or ( _G[ "oUF_Arena" .. tostring( index ) ] );

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
	rootFrame:AddFilter( FILTER_DISARMS );
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

-- party anchoring is handled runtime because party frames are created on demand
local partyAuraFrames = { };
for index = 0, 4 do
	local unit = TESTMODE and "player" or ( index == 0 and "player" or "party" .. tostring( index ) );

	local ccFrame = AuraAlertFrame( unit );
	ccFrame:AddFilter( FILTER_STUNS );
	ccFrame:AddFilter( FILTER_SILENCES );
	ccFrame:AddFilter( FILTER_CCS );
	if ( TESTMODE ) then
		ccFrame:AddFilter( FILTER_TEST );
	end
	ccFrame:SetWidth( PARTY_SIZE );
	ccFrame:SetHeight( PARTY_SIZE );

	local rootFrame = AuraAlertFrame( unit );
	rootFrame:AddFilter( FILTER_ROOTS );
	rootFrame:AddFilter( FILTER_DISARMS );
	if ( TESTMODE ) then
		rootFrame:AddFilter( FILTER_TEST );
	end
	rootFrame:SetWidth( PARTY_SIZE / 2 + 0.5 );
	rootFrame:SetHeight( PARTY_SIZE / 2 + 0.5 );
	rootFrame:SetPoint( "TOPLEFT", ccFrame, "TOPRIGHT", -1, 0 );
	ccFrame.rootFrame = rootFrame;

	local snareFrame = AuraAlertFrame( unit );
	snareFrame:AddFilter( FILTER_SNARES );
	if ( TESTMODE ) then
		snareFrame:AddFilter( FILTER_TEST );
	end
	snareFrame:SetWidth( PARTY_SIZE / 2 + 0.5 );
	snareFrame:SetHeight( PARTY_SIZE / 2 + 0.5 );
	snareFrame:SetPoint( "BOTTOMLEFT", ccFrame, "BOTTOMRIGHT", -1, 0 );
	ccFrame.snareFrame = snareFrame;

	tinsert( partyAuraFrames, ccFrame );
end

local OnPartyMembersChanged = function( self )
	for _, frame in ipairs( partyAuraFrames ) do
		local unit = frame:GetUnit();
		local parent;

		for index = 1, 5 do
			parent = _G[ "oUF_GroupUnitButton" .. tostring( index ) ];

			if ( parent and parent:GetAttribute( "unit" ) == unit ) then
				break;
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
kEvents.RegisterEvent( "PARTY_MEMBERS_CHANGED", OnPartyMembersChanged );