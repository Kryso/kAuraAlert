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
	{ id = 96294, priority = ROOT }, -- Chains of Ice (Chilblains Root)
	{ id = 204085, priority = ROOT }, -- Deathchill (pvp talent)
	-- Druid
	{ id = 339, priority = ROOT }, -- Entangling Roots
	{ id = 102359, priority = ROOT }, -- Mass Entanglement (talent)
	{ id = 45334, priority = ROOT }, -- Immobilized (wild charge, bear form)
	-- Hunter
	{ id = 53148, priority = ROOT }, -- Charge (Tenacity pet)
	{ id = 162480, priority = ROOT }, -- Steel Trap
	{ id = 190927, priority = ROOT }, -- Harpoon
	{ id = 200108, priority = ROOT }, -- Ranger's Net
	{ id = 212638, priority = ROOT }, -- tracker's net
	{ id = 201158, priority = ROOT }, -- Super Sticky Tar (Expert Trapper, Hunter talent, Tar Trap effect)
	-- Mage
	{ id = 122, priority = ROOT }, -- Frost Nova
	{ id = 33395, priority = ROOT }, -- Freeze (Water Elemental)
	-- { id = 157997, priority = ROOT }, -- Ice Nova -- since 6.1, ice nova doesn't DR with anything
	{ id = 228600, priority = ROOT }, -- Glacial spike (talent)
	-- Monk
	{ id = 116706, priority = ROOT }, -- Disable
	-- Priest
	-- Shaman
	{ id = 64695, priority = ROOT }, -- Earthgrab Totem
};

local FILTER_STUNS = {
	-- Death Knight
	-- Abomination's Might note: 207165 is the stun, but is never applied to players,
	-- so I haven't included it.
	{ id = 108194, priority = STUN }, -- Asphyxiate (talent for unholy)
	{ id = 221562, priority = STUN }, -- Asphyxiate (baseline for blood)
	{ id = 91800, priority = STUN }, -- Gnaw (Ghoul)
	{ id = 91797, priority = STUN }, -- Monstrous Blow (Dark Transformation Ghoul)
	{ id = 207171, priority = STUN }, -- Winter is Coming (Remorseless winter stun)
	-- Demon Hunter
	{ id = 179057, priority = STUN }, -- Chaos Nova
	{ id = 200166, priority = STUN }, -- Metamorphosis
	{ id = 205630, priority = STUN }, -- Illidan's Grasp, primary effect
	{ id = 208618, priority = STUN }, -- Illidan's Grasp, secondary effect
	{ id = 211881, priority = STUN }, -- Fel Eruption
	-- Druid
	{ id = 203123, priority = STUN }, -- Maim
	{ id = 5211, priority = STUN }, -- Mighty Bash
	{ id = 163505, priority = STUN }, -- Rake (Stun from Prowl)
	-- Hunter
	{ id = 117526, priority = STUN }, -- Binding Shot
	{ id = 24394, priority = STUN }, -- Intimidation
	-- Mage

	-- Monk
	{ id = 119381, priority = STUN }, -- Leg Sweep
	-- Paladin
	{ id = 853, priority = STUN }, -- Hammer of Justice
	-- Priest
	{ id = 200200, priority = STUN }, -- Holy word: Chastise
	{ id = 226943, priority = STUN }, -- Mind Bomb
	-- Rogue
	-- Shadowstrike note: 196958 is the stun, but it never applies to players,
	-- so I haven't included it.
	{ id = 1833, priority = STUN }, -- Cheap Shot
	{ id = 408, priority = STUN }, -- Kidney Shot
	{ id = 199804, priority = STUN }, -- Between the Eyes
	-- Shaman
	{ id = 118345, priority = STUN }, -- Pulverize (Primal Earth Elemental)
	{ id = 118905, priority = STUN }, -- Static Charge (Capacitor Totem)
	{ id = 204399, priority = STUN }, -- Earthfury (pvp talent)
	-- Warlock
	{ id = 89766, priority = STUN }, -- Axe Toss (Felguard)
	{ id = 30283, priority = STUN }, -- Shadowfury
	{ id = 22703, priority = STUN }, -- Summon Infernal
	-- Warrior
	{ id = 132168, priority = STUN }, -- Shockwave
	{ id = 132169, priority = STUN }, -- Storm Bolt
	-- Tauren
	{ id = 20549, priority = STUN }, -- War Stomp
};

local FILTER_SILENCES = {
	-- Death Knight
	{ id = 47476, priority = SILENCE }, -- Strangulate
	-- Demon Hunter
	{ id = 204490, priority = SILENCE }, -- Sigil of Silence
	-- Druid
	-- Hunter
	{ id = 202933, priority = SILENCE }, -- Spider Sting (pvp talent)
	-- Mage
	-- Paladin
	{ id = 31935, priority = SILENCE }, -- Avenger's Shield
	-- Priest
	{ id = 15487, priority = SILENCE }, -- Silence
	{ id = 199683, priority = SILENCE }, -- Last Word (SW: Death silence)
	-- Rogue
	{ id = 1330, priority = SILENCE }, -- Garrote
	-- Blood Elf
	{ id = 25046, priority = SILENCE }, -- Arcane Torrent (Energy version)
	{ id = 28730, priority = SILENCE }, -- Arcane Torrent (Priest/Mage/Lock version)
	{ id = 50613, priority = SILENCE }, -- Arcane Torrent (Runic power version)
	{ id = 69179, priority = SILENCE }, -- Arcane Torrent (Rage version)
	{ id = 80483, priority = SILENCE }, -- Arcane Torrent (Focus version)
	{ id = 129597, priority = SILENCE }, -- Arcane Torrent (Monk version)
	{ id = 155145, priority = SILENCE }, -- Arcane Torrent (Paladin version)
	{ id = 202719, priority = SILENCE }, -- Arcane Torrent (DH version)
};

local FILTER_CCS = {
	-- Death Knight
	{ id = 207167, priority = CC }, -- Blinding Sleet (talent) -- FIXME: is this the right category?
	-- Demon Hunter
	{ id = 207685, priority = CC }, -- Sigil of Misery
	-- Druid
	{ id = 33786, priority = CC }, -- Cyclone
	-- Hunter
	{ id = 186387, priority = CC }, -- Bursting Shot
	-- Mage
	{ id = 31661, priority = CC }, -- Dragon's Breath
	-- Monk
	{ id = 198909, priority = CC }, -- Song of Chi-ji -- FIXME: is this the right category( tooltip specifically says disorient, so I guessed here)
	{ id = 202274, priority = CC }, -- Incendiary Brew -- FIXME: is this the right category( tooltip specifically says disorient, so I guessed here)
	-- Paladin
	{ id = 105421, priority = CC }, -- Blinding Light -- FIXME: is this the right category? Its missing from blizzard's list
	-- Priest
	{ id = 8122, priority = CC }, -- Psychic Scream
	-- Rogue
	{ id = 2094, priority = CC }, -- Blind
	-- Warlock
	{ id = 5782, priority = CC }, -- Fear -- probably unused
	{ id = 118699, priority = CC }, -- Fear -- new debuff ID since MoP
	{ id = 130616, priority = CC }, -- Fear (with Glyph of Fear)
	{ id = 5484, priority = CC }, -- Howl of Terror (talent)
	{ id = 115268, priority = CC }, -- Mesmerize (Shivarra)
	{ id = 6358, priority = CC }, -- Seduction (Succubus)
	-- Warrior
	{ id = 5246, priority = CC }, -- Intimidating Shout (main target)

	-- Druid
	{ id = 99, priority = CC }, -- Incapacitating Roar (talent)
	{ id = 203126, priority = CC }, -- Maim (with blood trauma pvp talent)
	-- Hunter
	{ id = 3355, priority = CC }, -- Freezing Trap
	{ id = 19386, priority = CC }, -- Wyvern Sting
	{ id = 209790, priority = CC }, -- Freezing Arrow
	{ id = 213691, priority = CC }, -- Scatter Shot
	-- Mage
	{ id = 118, priority = CC }, -- Polymorph
	{ id = 28272, priority = CC }, -- Polymorph (pig)
	{ id = 28271, priority = CC }, -- Polymorph (turtle)
	{ id = 61305, priority = CC }, -- Polymorph (black cat)
	{ id = 61721, priority = CC }, -- Polymorph (rabbit)
	{ id = 61780, priority = CC }, -- Polymorph (turkey)
	{ id = 126819, priority = CC }, -- Polymorph (procupine)
	{ id = 161353, priority = CC }, -- Polymorph (bear cub)
	{ id = 161354, priority = CC }, -- Polymorph (monkey)
	{ id = 161355, priority = CC }, -- Polymorph (penguin)
	{ id = 161372, priority = CC }, -- Polymorph (peacock)
	{ id = 82691, priority = CC }, -- Ring of Frost
	-- Monk
	{ id = 115078, priority = CC }, -- Paralysis
	-- Paladin
	{ id = 20066, priority = CC }, -- Repentance
	-- Priest
	{ id = 605, priority = CC }, -- Mind Control
	{ id = 9484, priority = CC }, -- Shackle Undead
	{ id = 64044, priority = CC }, -- Psychic Horror (Horror effect)
	{ id = 88625, priority = CC }, -- Holy Word: Chastise
	-- Rogue
	{ id = 1776, priority = CC }, -- Gouge
	{ id = 6770, priority = CC }, -- Sap
	-- Shaman
	{ id = 51514, priority = CC }, -- Hex
	{ id = 211004, priority = CC }, -- Hex (spider)
	{ id = 210873, priority = CC }, -- Hex (raptor)
	{ id = 211015, priority = CC }, -- Hex (cockroach)
	{ id = 211010, priority = CC }, -- Hex (snake)
	-- Warlock
	{ id = 710, priority = CC }, -- Banish
	{ id = 6789, priority = CC }, -- Mortal Coil
	-- Pandaren
	{ id = 107079, priority = CC }, -- Quaking Palm
};

local FILTER_BUFFS = {
	-- Immune
	{ id = 19263, priority = 1 },	-- Deterrence
	{ id = 186265, priority = 1 },  -- Aspect of the Turtle
	{ id = 45438, priority = 1 },	-- Ice Block
	{ id = 642, priority = 1 },		-- Divine Shield    
	{ id = 115018, priority = 1 },	-- Desecrated Ground
	{ id = 31821, priority = 1 },	-- Aura Mastery
	{ id = 1022, priority = 1 },	-- Hand of Protection
	{ id = 47585, priority = 1 },	-- Dispersion
	{ id = 31224, priority = 1 },	-- Cloak of Shadows
	{ id = 8178, priority = 1 },	-- Grounding Totem Effect (Grounding Totem)
	{ id = 76577, priority = 1 },	-- Smoke Bomb
	{ id = 88611, priority = 1 },	-- Smoke Bomb
	{ id = 46924, priority = 1 },	-- Bladestorm

	-- Anti CC
	{ id = 48792, priority = 1 },	-- Icebound Fortitude
	{ id = 48707, priority = 1 },	-- Anti-Magic Shell
	{ id = 23920, priority = 1 },	-- Spell Reflection
	{ id = 114028, priority = 1 },	-- Mass Spell Reflection
	{ id = 5384, priority = 1 },	-- Feign Death

	-- Offensive Buffs
	{ id = 51690, priority = 1 },	-- Killing Spree
	{ id = 13750, priority = 1 },	-- Adrenaline Rush
	{ id = 31884, priority = 1 },	-- Avenging Wrath
	{ id = 1719, priority = 1 },	-- Battle Cry
	{ id = 102543, priority = 1 },	-- Incarnation: King of the Jungle
	{ id = 106951, priority = 1 },	-- Berserk
	{ id = 102560, priority = 1 },	-- Incarnation: Chosen of Elune
	{ id = 12472, priority = 1 },	-- Icy Veins
	{ id = 193526, priority = 1 }, -- Trueshot
	{ id = 19574, priority = 1 },	-- Bestial Wrath
	{ id = 186289, priority = 1 },	-- Aspect of the Eagle
	{ id = 51271, priority = 1 },	-- Pillar of Frost
	{ id = 152279, priority = 1 },	-- Breath of Sindragosa
	{ id = 105809, priority = 1 },	-- Holy Avenger
	{ id = 16166, priority = 1 },	-- Elemental Mastery
	{ id = 114050, priority = 1 },	-- Ascendance
	{ id = 107574, priority = 1 },	-- Avatar
	{ id = 121471, priority = 1 },	-- Shadow Blades
	{ id = 12292, priority = 1 },	-- Bloodbath
	{ id = 162264, priority = 1 },	-- Metamorphosis
	
	-- Defensive Buffs
	{ id = 122470, priority = 1 },	-- Touch of Karma
	{ id = 116849, priority = 1 },	-- Life Cocoon
	{ id = 33206, priority = 1 },	-- Pain Suppression
	{ id = 49039, priority = 1 },	-- Lichborne
	{ id = 5277, priority = 1 },	-- Evasion
	{ id = 199754, priority = 1 },	-- Riposte
	{ id = 108359, priority = 1 },	-- Dark Regeneration
	{ id = 104773, priority = 1 },	-- Unending Resolve
	{ id = 18499, priority = 1 },	-- Berserker Rage
	{ id = 61336, priority = 1 },	-- Survival Instincts
	{ id = 22812, priority = 1 },	-- Barkskin
	{ id = 102342, priority = 1 },	-- Iron Bark
	{ id = 6940, priority = 1 },	-- Hand of Sacrifice
	{ id = 110909, priority = 1 },	-- Alter Time
	{ id = 118038, priority = 1 },	-- Die by the Sword
	{ id = 33891, priority = 1 },	-- Incarnation: Tree of Life
	{ id = 74001, priority = 1 },	-- Combat Readiness
	{ id = 108271, priority = 1 },	-- Astral Shift
	{ id = 108416, priority = 1 },	-- Dark Pact
	{ id = 47788, priority = 1 },	-- Guardian Spirit
	{ id = 122783, priority = 1 },	-- Diffuse Magic
	{ id = 12975, priority = 1 },	-- Last Stand
	{ id = 871, priority = 1 },		-- Shield Wall
	{ id = 212800, priority = 1 },	-- Blur
	{ id = 55233, priority = 1 },	-- Vampiric Blood
	{ id = 194679, priority = 1 },	-- Rune Tap
	{ id = 207319, priority = 1 },	-- Corpse Shield
};

local FILTER_TEST = {
	{ id = 194384, priority = 500 }, -- Atonement
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