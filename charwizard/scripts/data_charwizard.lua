-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

genmethod = {
	"STANDARD ARRAY",
	"POINT BUY",
	"DICE ROLL",
	"MANUAL ENTRY",
};

aParseRaceLangChoices = {
	[", and fluency in one language of your choice."] = "",
	[" and one other language that you and your dm agree is appropriate for the character"] = "",
	[" and one other language that you and your dm agree is appropriate for your character"] = "",
	["one extra language of your choice"] = "",
	["one other language of your choice"] = "",
	["one additional language of your choice"] = "",
	["two other languages of your choice"] = "",
};

--[[aPriorTasha = {
	["DD Basic Rules - Player"] = "",
	["DD5E SRD Data"] = "",
	["DD PHB Deluxe"] = "",
	["DD Elemental Evil Players Companion"] = "",
	["DD Explorer's Guide to Wildemount - Players"] = "",
	["DD Mythic Odysseys of Theros, Players"] = "",
	["Volos Guide to Monsters Players"] = "",
	["DD Sword Coast Adventurer's Guide - Player's Guide"] = "",
	["The Tortle Package - Player"] = "",
	["D&D Wayfinder's Guide to Eberron"] = "",
	["DD Mordenkainen's Tome of Foes Players"] = "",
	["DD Guildmaster's Guide to Ravnica Players"] = "",
	["DD Acquisitions Incorporated Players"] = "",
	["Ruins of Symbaroum - Player's Guide"] = "",
};--]]

aRaceSkill = {
	["keensenses"] = "",
	["skillversatility"] = "",
	["menacing"] = "",
	["skills"] = "",
	["changelinginstincts"] = "",
	["graceful"] = "",
	["naturaltracker"] = "",
	["fierce"] = "",
	["tough"] = "",
	["specializeddesign"] = "",
	["survivor"] = "",
	["silentfeathers"] = "",
	["leporinesenses"] = "",
	["tirelessprecision"] = "",
	["wiryframe"] = "",
	["naturalathelete"] = "",
	["survivalinstinct"] = "",
	["kenkutraining"] = "",
	["primalintuition"] = "",
	["skill"] = "",
	["imposingpresence"] = "",
	["hunter_slore"] = "",
	["cat_stalent"] = "",
	["psychicglamour"] = "",
	["reveler"] = "",
	["sneaky"] = "",
};

aRaceProficiency = {
	["proficiency"] = "",
	["dwarvencombattraining"] = "",
	["toolproficiency"] = "",
	["dwarvenarmortraining"] = "",
	["drowweapontraining"] = "",
	["elfweapontraining"] = "",
	["giftedscribe"] = "",
	["tinker"] = "",
	["specializeddesign"] = "",
	["divergentpersona"] = "",
	["mason_sproficiency"] = "",
	["martialprodigy"] = "",
	["seaelftraining"] = "",
	["maker_sgift"] = "",
};

aRaceSpeed = {
	["speed"] = "",
	["fleetoffoot"] = "",
	["seamonkey"] = "",
	["courier_sspeed"] = "",
	["swiftstride"] = "",
	["spiderclimb"] = "",
	["fairyflight"] = "",
	["nimbleflight"] = "",
	["nimbleclimber"] = "",
	["underwateradaptation"] = "",
	["flight"] = "",
	["swimspeed"] = "",
	["swim"] = "",
	["winged"] = "",
	["cat_sclaws"] = "",
};

aRaceSpells = {
	["wardsandseals"] = "",
	["duergarmagic"] = "",
	["shapeshadows"] = "",
	["drowmagic"] = "",
	["scribe_sinsight"] = "",
	["whisperingwind"] = "",
	["naturalillusionist"] = "",
	["jorasco_sblessing"] = "",
	["innkeeper_scharms"] = "",
	["infernallegacy"] = "",
	["sensethreats"] = "",
	["headwinds"] = "",
	["nature_svoice"] = "",
	["primalconnection"] = "",
	["maker_sgift"] = "",
	["sentinel_sshield"] = "",
	["astralfire"] = "",
	["fairymagic"] = "",
	["sensethreats"] = "",
	["hexmagic"] = "",
	["draconiclegacy"] = "",
	["magicsight"] = "",
	["githyankipsionics"] = "",
	["githzeraipsionics"] = "",
	["calltothewave"] = "",
	["mergewithstone"] = "",
	["reachtotheblaze"] = "",
	["minglewiththewind"] = "",
	["celestiallegacy"] = "",
	["lightbearer"] = "",
	["firbolgmagic"] = "",
	["feystep"] = "",
	["innatespellcasting"] = "",
	["blessingofthemoonweaver"] = "",
	["childofthewood"] = "",
};

aRaceLanguages = {
	["languages"] = "",
	["extralanguage"] = "",
	["specializeddesign"] = "",
};

aRaceNonParse = {
	["age"] = "",
	["subrace"] = "",
	["abilityscoreincrease"] = "",
	["abilityscoreincreases"] = "",
}

caster_classes = {
	["artificer"] = "",
	["bard"] = "",
	["cleric"] = "",
	["druid"] = "",
	["paladin"] = "",
	["ranger"] = "",
	["sorcerer"] = "",
	["warlock"] = "",
	["wizard"] = "",
	["eldritch knight"] = "",
	["arcane trickster"] = "",
}

aAllArmor = {
	["light armor"] = "",
	["medium armor"] = "",
	["heavy armor"] = "",
};

aSimpleWeapons = {
	["clubs"] = "",
	["daggers"] = "",
	["greatclubs"] = "",
	["handaxes"] = "",
	["javelins"] = "",
	["light hammers"] = "",
	["maces"] = "",
	["quarterstaffs"] = "",
	["sickles"] = "",
	["spears"] = "",
	["light crossbows"] = "",
	["darts"] = "",
	["shortbows"] = "",
	["slings"] = "",
	["club"] = "",
	["dagger"] = "",
	["greatclub"] = "",
	["handaxe"] = "",
	["javelin"] = "",
	["light hammer"] = "",
	["mace"] = "",
	["quarterstaff"] = "",
	["sickle"] = "",
	["spear"] = "",
	["light crossbow"] = "",
	["dart"] = "",
	["shortbow"] = "",
	["sling"] = ""
};

aMartialWeapons = {
	["battleaxe"] = "",
	["flail"] = "",
	["glaive"] = "",
	["greataxe"] = "",
	["greatsword"] = "",
	["halberd"] = "",
	["lance"] = "",
	["longsword"] = "",
	["maul"] = "",
	["morningstar"] = "",
	["pike"] = "",
	["rapier"] = "",
	["scimitar"] = "",
	["shortsword"] = "",
	["trident"] = "",
	["war pick"] = "",
	["warhammer"] = "",
	["whip"] = "",
	["blowgun"] = "",
	["hand crossbow"] = "",
	["heavy crossbow"] = "",
	["longbow"] = "",
	["net"] = "",
	["battleaxes"] = "",
	["flails"] = "",
	["glaives"] = "",
	["greataxes"] = "",
	["greatswords"] = "",
	["halberds"] = "",
	["lances"] = "",
	["longswords"] = "",
	["mauls"] = "",
	["morningstars"] = "",
	["pikes"] = "",
	["rapiers"] = "",
	["scimitars"] = "",
	["shortswords"] = "",
	["tridents"] = "",
	["war picks"] = "",
	["warhammers"] = "",
	["whips"] = "",
	["blowguns"] = "",
	["hand crossbows"] = "",
	["heavy crossbows"] = "",
	["longbows"] = "",
	["nets"] = ""
};

SPELLSLOTS = {
	{2,0,0,0,0,0,0,0,0},
	{3,0,0,0,0,0,0,0,0},
	{4,2,0,0,0,0,0,0,0},
	{4,3,0,0,0,0,0,0,0},
	{4,3,2,0,0,0,0,0,0},
	{4,3,3,0,0,0,0,0,0},
	{4,3,3,1,0,0,0,0,0},
	{4,3,3,2,0,0,0,0,0},
	{4,3,3,3,1,0,0,0,0},
	{4,3,3,3,2,0,0,0,0},
	{4,3,3,3,2,1,0,0,0},
	{4,3,3,3,2,1,0,0,0},
	{3,3,3,2,1,1,0,0,0},
	{4,3,3,3,2,1,1,0,0},
	{4,3,3,3,2,1,1,1,0},
	{4,3,3,3,2,1,1,1,0},
	{4,3,3,3,2,1,1,1,1},
	{4,3,3,3,3,1,1,1,1},
	{4,3,3,3,3,2,1,1,1},
	{4,3,3,3,3,2,2,1,1}
};

--Cantrips,Spells Known
ARTIFICER_SPELLS = {{2,-1}, {2,-1}, {2,-1}, {2,-1}, {2,-1}, {2,-1}, {2,-1}, {2,-1}, {2,-1}, {3,-1}, {3,-1}, {3,-1}, {3,-1}, {4,-1}, {4,-1}, {4,-1}, {4,-1}, {4,-1}, {4,-1}, {4,-1}};
BARD_SPELLS = {{2,4},{2,5},{2,6},{3,7},{3,8},{3,9},{3,10},{3,11},{3,12},{3,14},{4,15},{4,15},{4,16},{4,18},{4,19},{4,19},{4,20},{4,22},{4,22},{4,22}};
CLERIC_SPELLS = {{3,-1},{3,-1},{3,-1},{4,-1},{4,-1},{4,-1},{4,-1},{4,-1},{4,-1},{5,-1},{5,-1},{5,-1},{5,-1},{5,-1},{5,-1},{5,-1},{5,-1},{5,-1},{5,-1},{5,-1}};
DRUID_SPELLS = {{2,-1},{2,-1},{2,-1},{3,-1},{3,-1},{3,-1},{3,-1},{3,-1},{3,-1},{3,-1},{4,-1},{4,-1},{4,-1},{4,-1},{4,-1},{4,-1},{4,-1},{4,-1},{4,-1},{4,-1}};
ELDRITCH_KNIGHT_SPELLS = {{0,0},{0,0},{2,3},{2,4},{2,4},{3,4},{3,5},{3,6},{3,6},{3,7},{3,8},{3,8},{4,9},{4,10},{4,10},{4,11},{4,11},{4,11},{4,12},{4,13}};
RANGER_SPELLS = {{0,0},{0,2},{0,3},{0,3},{0,4},{0,4},{0,5},{0,5},{0,6},{0,6},{0,7},{0,7},{0,8},{0,8},{0,9},{0,9},{0,10},{0,10},{0,11},{0,11}};
ARCANE_TRICKSTER_SPELLS = {{0,0},{0,0},{3,3},{3,4},{3,4},{3,4},{3,5},{3,6},{3,6},{4,7},{4,8},{4,8},{4,9},{4,10},{4,10},{4,11},{4,11},{4,11},{4,12},{4,13}};
SORCERER_SPELLS = {{4,2},{4,3},{4,4},{5,5},{5,6},{5,7},{5,8},{5,9},{5,10},{6,11},{6,12},{6,12},{6,13},{6,13},{6,14},{6,14},{6,15},{6,15},{6,15},{6,15}};
WARLOCK_SPELLS = {{2,2,1,1,0},{2,3,2,1,2},{2,4,2,2,2},{3,5,2,2,2},{3,6,2,3,3},{3,7,2,3,3},{3,8,2,4,4},{3,9,2,4,4},{3,10,2,5,5},{4,10,2,5,5},{4,11,3,5,5},{4,11,3,5,6},{4,12,3,5,6},{4,12,3,5,6},{4,13,3,5,7},{4,13,3,5,7},{4,14,4,5,7},{4,14,4,5,8},{4,15,4,5,8},{4,15,4,5,8}};
WIZARD_SPELLS = {{3,-1},{3,-1},{3,-1},{4,-1},{4,-1},{4,-1},{4,-1},{4,-1},{4,-1},{5,-1},{5,-1},{5,-1},{5,-1},{5,-1},{5,-1},{5,-1},{5,-1},{5,-1},{5,-1},{5,-1}};

function onInit()
	charwizard_starting_equipemnt = {
		["barbarian"] = {
			["CLASS CHOICE 1"] = {
				["add equipment"] = { "Weapon", "Martial" }
			},
			["CLASS CHOICE 2"] = {
				["add equipment"] = { "Weapon", "Simple" },
				["selection"] = {
					["2 handaxes"] = { tooltip = "2 Handaxes: DD PHB Deluxe", class = CharWizardManager.getShortcutClass("reference.equipmentdata.handaxe@DD PHB Deluxe"), record = "reference.equipmentdata.handaxe@DD PHB Deluxe" },
				},
			},
			["INCLUDED"] = {
				["selection_name"] = "an explorer's pack and four javelins",
				["addItemToInventory"] = {
					{ "Weapon", "javelin", 4 },
					{ "Adventuring Gear", "explorer's pack", 1 },
				},
			},
		},
		["bard"] = {
			["CLASS CHOICE 1"] = {
				["add equipment"] = { "Weapon", "Simple" },
				["selection"] = {
					["longsword"] = { tooltip = "Longsword: DD PHB Deluxe", class = CharWizardManager.getShortcutClass("reference.equipmentdata.longsword@DD PHB Deluxe"), record = "reference.equipmentdata.longsword@DD PHB Deluxe" },
					["rapier"] = { tooltip = "Rapier: DD PHB Deluxe", class = CharWizardManager.getShortcutClass("reference.equipmentdata.rapier@DD PHB Deluxe"), record = "reference.equipmentdata.rapier@DD PHB Deluxe" },
				},
			},
			["CLASS CHOICE 2"] = {
				["selection"] = {
					["diplomat's pack"] = { tooltip = "Diplomat's Pack: DD PHB Deluxe", class = CharWizardManager.getShortcutClass("reference.equipmentdata.diplomat_spack@DD PHB Deluxe"), record = "reference.equipmentdata.diplomat_spack@DD PHB Deluxe" },
					["entertainer's pack"] = { tooltip = "Diplomat's Pack: DD PHB Deluxe", class = CharWizardManager.getShortcutClass("reference.equipmentdata.entertainer_spack@DD PHB Deluxe"), record = "reference.equipmentdata.entertainer_spack@DD PHB Deluxe" },
				},
			},
			["CLASS CHOICE 3"] = {
				["tool selection"] = { "musical instrument"},
			},
			["INCLUDED"] = {
				["selection_name"] = "leather armor and a dagger",
				["addItemToInventory"] = {
					{ "Armor", "leather", 1 },
					{ "Weapon", "dagger", 1 },
				},
			}
		},
		["cleric"] = {
			["CLASS CHOICE 1"] = {
				["mace"] = { tooltip = "Mace: DD PHB Deluxe", class = CharWizardManager.getShortcutClass("reference.equipmentdata.mace@DD PHB Deluxe"), record = "reference.equipmentdata.mace@DD PHB Deluxe" },
				["warhammer"] = { tooltip = "Warhammer: DD PHB Deluxe", class = CharWizardManager.getShortcutClass("reference.equipmentdata.warhammer@DD PHB Deluxe"), record = "reference.equipmentdata.warhammer@DD PHB Deluxe" },
			},
			["CLASS CHOICE 2"] = {
				["selection"] = {
					["scale mail"] = { tooltip = "Scale Mail: DD PHB Deluxe", class = CharWizardManager.getShortcutClass("reference.equipmentdata.scalemail@DD PHB Deluxe"), record = "reference.equipmentdata.scalemail@DD PHB Deluxe" },
					["leather"] = { tooltip = "Leather Armor: DD PHB Deluxe", class = CharWizardManager.getShortcutClass("reference.equipmentdata.leather@DD PHB Deluxe"), record = "reference.equipmentdata.leather@DD PHB Deluxe" },
					["chain mail"] = { tooltip = "Chain Mail: DD PHB Deluxe", class = CharWizardManager.getShortcutClass("reference.equipmentdata.chainmail@DD PHB Deluxe"), record = "reference.equipmentdata.chainmail@DD PHB Deluxe" },
				},
			},
			["CLASS CHOICE 3"] = {
				["add equipment"] = { "Weapon", "Simple" },
			},
			["CLASS CHOICE 4"] = {
				["selection"] = {
					["priest's pack"] = { tooltip = "Priest's Pack: DD PHB Deluxe", class = CharWizardManager.getShortcutClass("reference.equipmentdata.priest_spack@DD PHB Deluxe"), record = "reference.equipmentdata.priest_spack@DD PHB Deluxe" },
					["explorer's pack"] = { tooltip = "Explorer's Pack: DD PHB Deluxe", class = CharWizardManager.getShortcutClass("reference.equipmentdata.explorer_spack@DD PHB Deluxe"), record = "reference.equipmentdata.explorer_spack@DD PHB Deluxe" },
				},
			},
			["CHOOSE HOLY SYMBOL"] = {
				["selection"] = {
					["amulet"] = { tooltip = "Amulet: DD PHB Deluxe", class = CharWizardManager.getShortcutClass("reference.equipmentdata.amulet@DD PHB Deluxe"), record = "reference.equipmentdata.amulet@DD PHB Deluxe" },
					["emblem"] = { tooltip = "Emblem: DD PHB Deluxe", class = CharWizardManager.getShortcutClass("reference.equipmentdata.emblem@DD PHB Deluxe"), record = "reference.equipmentdata.emblem@DD PHB Deluxe" },
					["reliquary"] = { tooltip = "Reliquary: DD PHB Deluxe", class = CharWizardManager.getShortcutClass("reference.equipmentdata.reliquary@DD PHB Deluxe"), record = "reference.equipmentdata.reliquary@DD PHB Deluxe" },
				},
			},
			["INCLUDED"] = {
				["selection_name"] = "A Shield",
				["addItemToInventory"] = {
					{ "Armor", "shield", 1 },
				},
			}
		},
		["druid"] = {
			["CLASS CHOICE 1"] = {
				["selection"] = {
					["shield"] = { tooltip = "Shield: DD PHB Deluxe", class = CharWizardManager.getShortcutClass("reference.equipmentdata.shield@DD PHB Deluxe"), record = "reference.equipmentdata.shield@DD PHB Deluxe" },
				},
				["add equipment"] = { "Weapon", "Simple" },
			},
			["CLASS CHOICE 2"] = {
				["selection"] = {
					["scimitar"] = { tooltip = "Scimitar: DD PHB Deluxe", class = CharWizardManager.getShortcutClass("reference.equipmentdata.scimitar@DD PHB Deluxe"), record = "reference.equipmentdata.scimitar@DD PHB Deluxe" },
				},
				["add equipment"] = { "Weapon", "Simple" },
			},
			["CHOOSE DRUIDIC FOCUS"] = {
				["selection"] = {
					["sprig of mistletoe"] = { tooltip = "Sprig of Mistletoe: DD PHB Deluxe", class = CharWizardManager.getShortcutClass("reference.equipmentdata.sprigofmistletoe@DD PHB Deluxe"), record = "reference.equipmentdata.sprigofmistletoe@DD PHB Deluxe" },
					["totem"] = { tooltip = "Totem: DD PHB Deluxe", class = CharWizardManager.getShortcutClass("reference.equipmentdata.totem@DD PHB Deluxe"), record = "reference.equipmentdata.totem@DD PHB Deluxe" },
					["wooden staff"] = { tooltip = "Wooden Staff: DD PHB Deluxe", class = CharWizardManager.getShortcutClass("reference.equipmentdata.totem@DD PHB Deluxe"), record = "reference.equipmentdata.totem@DD PHB Deluxe" },
					["yew wand"] = { tooltip = "Yew Wand: DD PHB Deluxe", class = CharWizardManager.getShortcutClass("reference.equipmentdata.yewwand@DD PHB Deluxe"), record = "reference.equipmentdata.yewwand@DD PHB Deluxe" },
				},
			},
			["INCLUDED"] = {
				["selection_name"] = "leather armor and an explorer's pack",
				["addItemToInventory"] = {
					{ "Armor", "leather", 1 },
					{ "Adventuring Gear", "explorer's pack", 1 },
				},
			},
		},
		["fighter"] = {
			["CLASS CHOICE 1"] = {
				["selection"] = {
					["chain mail"] = { tooltip = "Chain Mail: DD PHB Deluxe", class = CharWizardManager.getShortcutClass("reference.equipmentdata.chainmail@DD PHB Deluxe"), record = "reference.equipmentdata.chainmail@DD PHB Deluxe" },
					["leather"] = { tooltip = "Leather Armor: DD PHB Deluxe", class = CharWizardManager.getShortcutClass("reference.equipmentdata.leather@DD PHB Deluxe"), record = "reference.equipmentdata.leather@DD PHB Deluxe" },
				},
			},
			["CLASS CHOICE 2"] = {
				["selection"] = {
					["shield"] = { tooltip = "Shield: DD PHB Deluxe", class = CharWizardManager.getShortcutClass("reference.equipmentdata.shield@DD PHB Deluxe"), record = "reference.equipmentdata.shield@DD PHB Deluxe" },
				},
				["add equipment"] = { "Weapon", "Martial" },
			},
			["CLASS CHOICE 3"] = {
				["add equipment"] = { "Weapon", "Martial" },
			},
			["CLASS CHOICE 4"] = {
				["selection"] = {
					["2 handaxes"] = { tooltip = "2 Handaxes: DD PHB Deluxe", class = CharWizardManager.getShortcutClass("reference.equipmentdata.handaxe@DD PHB Deluxe"), record = "reference.equipmentdata.handaxe@DD PHB Deluxe", count = 2 },
					["crossbow, light"] = { tooltip = "Crossbow, Light: DD PHB Deluxe", class = CharWizardManager.getShortcutClass("reference.equipmentdata.crossbow_light@DD PHB Deluxe"), record = "reference.equipmentdata.crossbow_light@DD PHB Deluxe" },
				},
				["add equipment"] = { "Weapon", "Martial" },
			},
			["CLASS CHOICE 5"] = {
				["selection"] = {
					["dungeoneer's pack"] = { tooltip = "Dungeoneer's Pack: DD PHB Deluxe", class = CharWizardManager.getShortcutClass("reference.equipmentdata.dungeoneer_spack@DD PHB Deluxe"), record = "reference.equipmentdata.dungeoneer_spack@DD PHB Deluxe" },
					["explorer's pack"] = { tooltip = "Explorer's Pack: DD PHB Deluxe", class = CharWizardManager.getShortcutClass("reference.equipmentdata.explorer_spack@DD PHB Deluxe"), record = "reference.equipmentdata.explorer_spack@DD PHB Deluxe" },
				},
			},
		},
		["monk"] = {
			["CLASS CHOICE 1"] = {
				["selection"] = {
					["shortsword"] = { tooltip = "Shortsword: DD PHB Deluxe", class = CharWizardManager.getShortcutClass("reference.equipmentdata.shortsword@DD PHB Deluxe"), record = "reference.equipmentdata.shortsword@DD PHB Deluxe" },
				},
				["add equipment"] = { "Weapon", "Simple" },
			},
			["CLASS CHOICE 2"] = {
				["selection"] = {
					["dungeoneer's pack"] = { tooltip = "Dungeoneer's Pack: DD PHB Deluxe", class = CharWizardManager.getShortcutClass("reference.equipmentdata.dungeoneer_spack@DD PHB Deluxe"), record = "reference.equipmentdata.dungeoneer_spack@DD PHB Deluxe" },
					["explorer's pack"] = { tooltip = "Explorer's Pack: DD PHB Deluxe", class = CharWizardManager.getShortcutClass("reference.equipmentdata.explorer_spack@DD PHB Deluxe"), record = "reference.equipmentdata.explorer_spack@DD PHB Deluxe" },
				},
			},
			["INCLUDED"] = {
				["selection_name"] = "10 darts",
				["addItemToInventory"] = {
					{ "Weapon", "dart", 10 },
				},
			},
		},
		["paladin"] = {
			["CLASS CHOICE 1"] = {
				["selection"] = {
					["shield"] = { tooltip = "Shield: DD PHB Deluxe", class = CharWizardManager.getShortcutClass("reference.equipmentdata.shield@DD PHB Deluxe"), record = "reference.equipmentdata.shield@DD PHB Deluxe" },
				},
				["add equipment"] = { "Weapon", "Martial" },
			},
			["CLASS CHOICE 2"] = {
				["add equipment"] = { "Weapon", "Martial" },
			},
			["CLASS CHOICE 3"] = {
				["selection"] = {
					["5 javelins"] = { tooltip = "Javelins: DD PHB Deluxe", class = CharWizardManager.getShortcutClass("reference.equipmentdata.javelin@DD PHB Deluxe"), record = "reference.equipmentdata.javelin@DD PHB Deluxe", count = 5 },
				},
				["add equipment"] = { "Weapon", "Simple" },
			},
			["CLASS CHOICE 4"] = {
				["selection"] = {
					["priest's pack"] = { tooltip = "Priest's Pack: DD PHB Deluxe", class = CharWizardManager.getShortcutClass("reference.equipmentdata.priest_spack@DD PHB Deluxe"), record = "reference.equipmentdata.priest_spack@DD PHB Deluxe" },
					["explorer's pack"] = { tooltip = "Explorer's Pack: DD PHB Deluxe", class = CharWizardManager.getShortcutClass("reference.equipmentdata.explorer_spack@DD PHB Deluxe"), record = "reference.equipmentdata.explorer_spack@DD PHB Deluxe" },
				},
			},
			["CHOOSE HOLY SYMBOL"] = {
				["selection"] = {
					["amulet"] = { tooltip = "Amulet: DD PHB Deluxe", class = CharWizardManager.getShortcutClass("reference.equipmentdata.amulet@DD PHB Deluxe"), record = "reference.equipmentdata.amulet@DD PHB Deluxe" },
					["emblem"] = { tooltip = "Emblem: DD PHB Deluxe", class = CharWizardManager.getShortcutClass("reference.equipmentdata.emblem@DD PHB Deluxe"), record = "reference.equipmentdata.emblem@DD PHB Deluxe" },
					["reliquary"] = { tooltip = "Reliquary: DD PHB Deluxe", class = CharWizardManager.getShortcutClass("reference.equipmentdata.reliquary@DD PHB Deluxe"), record = "reference.equipmentdata.reliquary@DD PHB Deluxe" },
				},
			},
			["INCLUDED"] = {
				["selection_name"] = "chain mail",
				["addItemToInventory"] = {
					{ "Armor", "chain mail", 1 },
				},
			},
		},
		["ranger"] = {
			["CLASS CHOICE 1"] = {
				["selection"] = {
					["scale mail"] = { tooltip = "Scale Mail: DD PHB Deluxe", class = CharWizardManager.getShortcutClass("reference.equipmentdata.scalemail@DD PHB Deluxe"), record = "reference.equipmentdata.scalemail@DD PHB Deluxe" },
					["leather"] = { tooltip = "Leather Armor: DD PHB Deluxe", class = CharWizardManager.getShortcutClass("reference.equipmentdata.leather@DD PHB Deluxe"), record = "reference.equipmentdata.leather@DD PHB Deluxe" },
				},
			},
			["CLASS CHOICE 2"] = {
				["selection"] = {
					["shortsword"] = { tooltip = "Shortsword: DD PHB Deluxe", class = CharWizardManager.getShortcutClass("reference.equipmentdata.shortsword@DD PHB Deluxe"), record = "reference.equipmentdata.shortsword@DD PHB Deluxe" },
				},
				["add equipment"] = { "Weapon", "Simple" },
			},
			["CLASS CHOICE 3"] = {
				["selection"] = {
					["shortsword"] = { tooltip = "Shortsword: DD PHB Deluxe", class = CharWizardManager.getShortcutClass("reference.equipmentdata.shortsword@DD PHB Deluxe"), record = "reference.equipmentdata.shortsword@DD PHB Deluxe" },
				},
				["add equipment"] = { "Weapon", "Simple" },
			},
			["CLASS CHOICE 4"] = {
				["selection"] = {
					["dungeoneer's pack"] = { tooltip = "Dungeoneer's Pack: DD PHB Deluxe", class = CharWizardManager.getShortcutClass("reference.equipmentdata.dungeoneer_spack@DD PHB Deluxe"), record = "reference.equipmentdata.dungeoneer_spack@DD PHB Deluxe" },
					["explorer's pack"] = { tooltip = "Explorer's Pack: DD PHB Deluxe", class = CharWizardManager.getShortcutClass("reference.equipmentdata.explorer_spack@DD PHB Deluxe"), record = "reference.equipmentdata.explorer_spack@DD PHB Deluxe" },
				},
			},
			["INCLUDED"] = {
				["selection_name"] = "longbow",
				["addItemToInventory"] = {
					{ "Weapon", "longbow", 1 },
				},
			},
		},
		["rogue"] = {
			["CLASS CHOICE 1"] = {
				["selection"] = {
					["shortsword"] = { tooltip = "Shortsword: DD PHB Deluxe", class = CharWizardManager.getShortcutClass("reference.equipmentdata.shortsword@DD PHB Deluxe"), record = "reference.equipmentdata.shortsword@DD PHB Deluxe" },
					["rapier"] = { tooltip = "Rapier: DD PHB Deluxe", class = CharWizardManager.getShortcutClass("reference.equipmentdata.rapier@DD PHB Deluxe"), record = "reference.equipmentdata.rapier@DD PHB Deluxe" },
				},
			},
			["CLASS CHOICE 2"] = {
				["selection"] = {
					["shortsword"] = { tooltip = "Shortsword: DD PHB Deluxe", class = CharWizardManager.getShortcutClass("reference.equipmentdata.shortsword@DD PHB Deluxe"), record = "reference.equipmentdata.shortsword@DD PHB Deluxe" },
					["shortbow"] = { tooltip = "Shortbow: DD PHB Deluxe", class = CharWizardManager.getShortcutClass("reference.equipmentdata.shortbow@DD PHB Deluxe"), record = "reference.equipmentdata.shortbow@DD PHB Deluxe" },
				},
			},
			["CLASS CHOICE 3"] = {
				["selection"] = {
					["dungeoneer's pack"] = { tooltip = "Dungeoneer's Pack: DD PHB Deluxe", class = CharWizardManager.getShortcutClass("reference.equipmentdata.dungeoneer_spack@DD PHB Deluxe"), record = "reference.equipmentdata.dungeoneer_spack@DD PHB Deluxe" },
					["explorer's pack"] = { tooltip = "Explorer's Pack: DD PHB Deluxe", class = CharWizardManager.getShortcutClass("reference.equipmentdata.explorer_spack@DD PHB Deluxe"), record = "reference.equipmentdata.explorer_spack@DD PHB Deluxe" },
					["burglar's pack"] = { tooltip = "Burglar's Pack: DD PHB Deluxe", class = CharWizardManager.getShortcutClass("reference.equipmentdata.burglar_spack@DD PHB Deluxe"), record = "reference.equipmentdata.burglar_spack@DD PHB Deluxe" },
				},
			},
			["INCLUDED"] = {
				["selection_name"] = "leather, two daggers, and thieves' tools",
				["addItemToInventory"] = {
					{ "Armor", "leather", 1 },
					{ "Weapon", "dagger", 2 },
					{ "Adventuring Gear", "thieves' tools", 1 },
				},
			},
		},
		["sorcerer"] = {
			["CLASS CHOICE 1"] = {
				["selection"] = {
					["crossbow, light"] = { tooltip = "Crossbow, Light: DD PHB Deluxe", class = CharWizardManager.getShortcutClass("reference.equipmentdata.crossbow_light@DD PHB Deluxe"), record = "reference.equipmentdata.crossbow_light@DD PHB Deluxe" },
				},
				["add equipment"] = { "Weapon", "Simple" },
			},
			["CLASS CHOICE 2"] = {
				["selection"] = {
					["dungeoneer's pack"] = { tooltip = "Dungeoneer's Pack: DD PHB Deluxe", class = CharWizardManager.getShortcutClass("reference.equipmentdata.dungeoneer_spack@DD PHB Deluxe"), record = "reference.equipmentdata.dungeoneer_spack@DD PHB Deluxe" },
					["explorer's pack"] = { tooltip = "Explorer's Pack: DD PHB Deluxe", class = CharWizardManager.getShortcutClass("reference.equipmentdata.explorer_spack@DD PHB Deluxe"), record = "reference.equipmentdata.explorer_spack@DD PHB Deluxe" },
				},
			},
			["CHOOSE ARCANE FOCUS OR COMPONENT POUCH"] = {
				["selection"] = {
					["crystal"] = { tooltip = "Crystal: DD PHB Deluxe", class = CharWizardManager.getShortcutClass("reference.equipmentdata.crystal@DD PHB Deluxe"), record = "reference.equipmentdata.crystal@DD PHB Deluxe" },
					["orb"] = { tooltip = "Orb: DD PHB Deluxe", class = CharWizardManager.getShortcutClass("reference.equipmentdata.orb@DD PHB Deluxe"), record = "reference.equipmentdata.orb@DD PHB Deluxe" },
					["rod"] = { tooltip = "Rod: DD PHB Deluxe", class = CharWizardManager.getShortcutClass("reference.equipmentdata.rod@DD PHB Deluxe"), record = "reference.equipmentdata.rod@DD PHB Deluxe" },
					["staff"] = { tooltip = "Staff: DD PHB Deluxe", class = CharWizardManager.getShortcutClass("reference.equipmentdata.staff@DD PHB Deluxe"), record = "reference.equipmentdata.staff@DD PHB Deluxe" },
					["wand"] = { tooltip = "Wand: DD PHB Deluxe", class = CharWizardManager.getShortcutClass("reference.equipmentdata.wand@DD PHB Deluxe"), record = "reference.equipmentdata.wand@DD PHB Deluxe" },
					["component pouch"] = { tooltip = "Component Pouch: DD PHB Deluxe", class = CharWizardManager.getShortcutClass("reference.equipmentdata.componentpouch@DD PHB Deluxe"), record = "reference.equipmentdata.componentpouch@DD PHB Deluxe" },
				},
			},
			["INCLUDED"] = {
				["selection_name"] = "two daggers",
				["addItemToInventory"] = {
					{ "Weapon", "dagger", 2 },
				},
			},
		},
		["warlock"] = {
			["CLASS CHOICE 1"] = {
				["selection"] = {
					["crossbow, light"] = { tooltip = "Crossbow, Light: DD PHB Deluxe", class = CharWizardManager.getShortcutClass("reference.equipmentdata.crossbow_light@DD PHB Deluxe"), record = "reference.equipmentdata.crossbow_light@DD PHB Deluxe" },
				},
				["add equipment"] = { "Weapon", "Simple" },
			},
			["CLASS CHOICE 2"] = {
				["selection"] = {
					["dungeoneer's pack"] = { tooltip = "Dungeoneer's Pack: DD PHB Deluxe", class = CharWizardManager.getShortcutClass("reference.equipmentdata.dungeoneer_spack@DD PHB Deluxe"), record = "reference.equipmentdata.dungeoneer_spack@DD PHB Deluxe" },
					["scholar's pack"] = { tooltip = "Scholar's Pack: DD PHB Deluxe", class = CharWizardManager.getShortcutClass("reference.equipmentdata.scholar_spack@DD PHB Deluxe"), record = "reference.equipmentdata.scholar_spack@DD PHB Deluxe" },
				},
			},
			["FOCUS OR COMPONENT POUCH"] = {
				["selection"] = {
					["crystal"] = { tooltip = "Crystal: DD PHB Deluxe", class = CharWizardManager.getShortcutClass("reference.equipmentdata.crystal@DD PHB Deluxe"), record = "reference.equipmentdata.crystal@DD PHB Deluxe" },
					["orb"] = { tooltip = "Orb: DD PHB Deluxe", class = CharWizardManager.getShortcutClass("reference.equipmentdata.orb@DD PHB Deluxe"), record = "reference.equipmentdata.orb@DD PHB Deluxe" },
					["rod"] = { tooltip = "Rod: DD PHB Deluxe", class = CharWizardManager.getShortcutClass("reference.equipmentdata.rod@DD PHB Deluxe"), record = "reference.equipmentdata.rod@DD PHB Deluxe" },
					["staff"] = { tooltip = "Staff: DD PHB Deluxe", class = CharWizardManager.getShortcutClass("reference.equipmentdata.staff@DD PHB Deluxe"), record = "reference.equipmentdata.staff@DD PHB Deluxe" },
					["wand"] = { tooltip = "Wand: DD PHB Deluxe", class = CharWizardManager.getShortcutClass("reference.equipmentdata.wand@DD PHB Deluxe"), record = "reference.equipmentdata.wand@DD PHB Deluxe" },
					["component pouch"] = { tooltip = "Component Pouch: DD PHB Deluxe", class = CharWizardManager.getShortcutClass("reference.equipmentdata.componentpouch@DD PHB Deluxe"), record = "reference.equipmentdata.componentpouch@DD PHB Deluxe" },
				},
			},
			["CLASS CHOICE 3"] = {
				["add equipment"] = { "Weapon", "Simple" },
			},
			["INCLUDED"] = {
				["selection_name"] = "leather and two daggers",
				["addItemToInventory"] = {
					{ "Armor", "leather", 1 },
					{ "Weapon", "dagger", 2 },
				},
			},
		},
		["wizard"] = {
			["CLASS CHOICE 1"] = {
				["selection"] = {
					["quarterstaff"] = { tooltip = "Quarterstaff: DD PHB Deluxe", class = CharWizardManager.getShortcutClass("reference.equipmentdata.quarterstaff@DD PHB Deluxe"), record = "reference.equipmentdata.quarterstaff@DD PHB Deluxe" },
					["dagger"] = { tooltip = "Dagger: DD PHB Deluxe", class = CharWizardManager.getShortcutClass("reference.equipmentdata.dagger@DD PHB Deluxe"), record = "reference.equipmentdata.dagger@DD PHB Deluxe" },
				},
			},
			["CLASS CHOICE 2"] = {
				["selection"] = {
					["explorer's pack"] = { tooltip = "Explorer's Pack: DD PHB Deluxe", class = CharWizardManager.getShortcutClass("reference.equipmentdata.explorer_spack@DD PHB Deluxe"), record = "reference.equipmentdata.explorer_spack@DD PHB Deluxe" },
					["scholar's pack"] = { tooltip = "Scholar's Pack: DD PHB Deluxe", class = CharWizardManager.getShortcutClass("reference.equipmentdata.scholar_spack@DD PHB Deluxe"), record = "reference.equipmentdata.scholar_spack@DD PHB Deluxe" },
				},
			},
			["FOCUS OR COMPONENT POUCH"] = {
				["selection"] = {
					["crystal"] = { tooltip = "Crystal: DD PHB Deluxe", class = CharWizardManager.getShortcutClass("reference.equipmentdata.crystal@DD PHB Deluxe"), record = "reference.equipmentdata.crystal@DD PHB Deluxe" },
					["orb"] = { tooltip = "Orb: DD PHB Deluxe", class = CharWizardManager.getShortcutClass("reference.equipmentdata.orb@DD PHB Deluxe"), record = "reference.equipmentdata.orb@DD PHB Deluxe" },
					["rod"] = { tooltip = "Rod: DD PHB Deluxe", class = CharWizardManager.getShortcutClass("reference.equipmentdata.rod@DD PHB Deluxe"), record = "reference.equipmentdata.rod@DD PHB Deluxe" },
					["staff"] = { tooltip = "Staff: DD PHB Deluxe", class = CharWizardManager.getShortcutClass("reference.equipmentdata.staff@DD PHB Deluxe"), record = "reference.equipmentdata.staff@DD PHB Deluxe" },
					["wand"] = { tooltip = "Wand: DD PHB Deluxe", class = CharWizardManager.getShortcutClass("reference.equipmentdata.wand@DD PHB Deluxe"), record = "reference.equipmentdata.wand@DD PHB Deluxe" },
					["component pouch"] = { tooltip = "Component Pouch: DD PHB Deluxe", class = CharWizardManager.getShortcutClass("reference.equipmentdata.componentpouch@DD PHB Deluxe"), record = "reference.equipmentdata.componentpouch@DD PHB Deluxe" },
				},
			},
			["INCLUDED"] = {
				["selection_name"] = "a spellbook",
				["addItemToInventory"] = {
					{ "Adventuring Gear", "spellbook", 1 },
				},
			},
		},
		["artificer"] = {
			["CLASS CHOICE 1"] = {
				["add equipment"] = { "Weapon", "Simple" },
			},
			["CLASS CHOICE 2"] = {
				["add equipment"] = { "Weapon", "Simple" },
			},
			["CLASS CHOICE 3"] = {
				["selection"] = {
					["scale mail"] = { tooltip = "Scale Mail: DD PHB Deluxe", class = CharWizardManager.getShortcutClass("reference.equipmentdata.scalemail@DD PHB Deluxe"), record = "reference.equipmentdata.scalemail@DD PHB Deluxe" },
					["studded leather"] = { tooltip = "Studded Leather: DD PHB Deluxe", class = CharWizardManager.getShortcutClass("reference.equipmentdata.studdedleather@DD PHB Deluxe"), record = "reference.equipmentdata.studdedleather@DD PHB Deluxe" },
				},
			},
			["INCLUDED"] = {
				["selection_name"] = "light crossbow, 20 bolts, thieves' tools, dungeoneer's pack",
				["addItemToInventory"] = {
					{ "Adventuring Gear", "dungeoneer's pack" };
					{ "Weapon", "crossbow, light" };
					{ "Adventuring Gear", "thieves' tools" };
				},
			},
		},
	};
end

--
-- Registration
--

function getCasterClasses()
	return caster_classes;
end
function registerNewCasterClass(s)
	caster_classes[s] = "";
end

function getRaceSkill()
	return aRaceSkill;
end
function registerNewRaceSkill(s)
	aRaceSkill[s] = "";
end

function getRaceProficiency()
	return aRaceProficiency;
end
function registerNewRaceProficiency(s)
	aRaceProficiency[s] = "";
end

function getRaceSpeed()
	return aRaceSpeed;
end
function registerNewRaceSpeed(s)
	aRaceSpeed[s] = "";
end

function getRaceSpells()
	return aRaceSpells;
end
function registerNewRaceSpells(s)
	aRaceSpells[s] = "";
end

function getRaceLanguages()
	return aRaceLanguages;
end
function registerNewRaceLanguages(s)
	aRaceLanguages[s] = "";
end

function getCharWizardStartingEquipment()
	return charwizard_starting_equipemnt;
end

--
-- Registering custom kits will look for certain information
-- [CLASS CHOICE #] = {
-- 	["add equipment"] = { "Weapon", "Simple|Martial" },
-- 	["selection"] = {
--		["title on button"] = { tooltip = "", class = CharWizardManager.getShortcutClass("record link string"), record = "record link string" },
-- },

-- ["INCLUDED"] = {
-- 	["selection_name"] = "title on to dislay",
--	["addItemToInventory"] = {
--		{ "Weapon", "name", # },
--		{ "Adventuring Gear", "name", # },
--		{ "Armor", "name", # },
--	},
-- },

function registerNewCharWizardStartingEquipment(s, aEquipment)
	charwizard_starting_equipemnt[s] = aEquipment;
end

