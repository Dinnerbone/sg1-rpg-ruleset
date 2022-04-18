-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

-- Examples:
-- { type = "attack", range = "[M|R]", [modifier = #] }
--      If modifier defined, then attack bonus will be this fixed value
--      Otherwise, the attack bonus will be the ability bonus defined for the spell group
--
-- { type = "damage", clauses = { { dice = { "d#", ... }, modifier = #, type = "", [stat = ""] }, ... } }
--      Each damage action can have multiple clauses which can do different damage types
--
-- { type = "heal", [subtype = "temp", ][sTargeting = "self", ] clauses = { { dice = { "d#", ... }, bonus = #, [stat = ""] }, ... } }
--      Each heal action can have multiple clauses 
--      Heal actions are either direct healing or granting temporary hit points (if subtype = "temp" set)
--      If sTargeting = "self" set, then the heal will always be applied to self instead of target.
--
-- { type = "powersave", save = "<ability>", [savemod = #, ][savestat = "<ability>", ][onmissdamage = "half"] }
--      If savemod defined, then the DC will be this fixed value.
--      If savestat defined, then the DC will be calculated as 8 + specified ability bonus + proficiency bonus
--      Otherwise, the save DC will be the same as the spell group
--
-- { type = "effect", sName = "<effect text>", [sTargeting = "self", ][nDuration = #, ][sUnits = "[<empty>|minute|hour|day]", ][sApply = "[<empty>|action|roll|single]"] }
--      If sTargeting = "self" set, then the effect will always be applied to self instead of target.
--      If nDuration not set or is equal to zero, then the effect will not expire.
--[[	[""] = {
		["actions"] = {
			{ type = "attack", range = "[M|R]", [modifier = #] },
			{ type = "damage", clauses = { { dice = { "d#", ... }, modifier = #, dmgtype = "", [stat = ""] }, ... } },
			{ type = "heal", [subtype = "temp", ][sTargeting = "self", ] clauses = { { dice = { "d#", ... }, bonus = #, [stat = ""] }, ... } },
			{ type = "powersave", save = "<ability>", [savemod = #, ][savestat = "<ability>", ][onmissdamage = "half"] },
			{ type = "effect", sName = "<effect text>", [sTargeting = "self", ][nDuration = #, ][sUnits = "[<empty>|minute|hour|day]", ][sApply = "[<empty>|action|roll|single]"] },
		},
	},
--]]
parsedata = {
	--
	-- CLASSES
	--
	-- Artificier
    -- Artificer - Alchemist
    ["toolproficiency_alchemist_"] = {
        ["proficiency"] = {
            innate = {"alchemist's supplies"},
        },
    },
    ["alchemist_sspells"] = {
        ["spells"] = {
            innate = {
                [3] = {"healing word", "ray of sickness"},
                [5] = {"flaming sphere", "melf's acid arrow"},
                [9] = {"gaseous form", "mass healing word"},
                [13] = {"blight", "death ward"},
                [17] = {"cloudkill", "raise dead"},
            },
        },
    },
    ["experimentalelixier"] = {
        ["multiple_actions"] = {
            ["Healing Elixir"] = {
                ["actions"] = {
                    { type = "heal", clauses = { { dice = { "d4", "d4" }, bonus = 0, stat = "intelligence" }, } },
                },
            },
            ["Resilience Elixir"] = {
                ["actions"] = {
                    { type = "effect", sName = "AC: 1", nDuration = 10, sUnits = "minute", },
                },
            },
            ["Boldness Elixir"] = {
                ["actions"] = {
                    { type = "effect", sName = "ATK: d4", nDuration = 1, sUnits = "minute", },
                    { type = "effect", sName = "SAVE: d4", nDuration = 1, sUnits = "minute", },
                },
            },
        },
    },
    ["restorativereagents"] = {
        ["actions"] = {
            { type = "heal", subtype = "temp", clauses = { { dice = { "d6", "d6" }, bonus = 0, stat = "intelligence" }, } },
        },
    },
    ["chemicalmastery"] = {
        ["actions"] = {
            { type = "effect", sName = "Chemical Mastery; RESIST: acid; RESIST: poison; IMMUNE: poisoned", sTargeting = "self", },
        },
        ["spells"] = {
            [0] = {"greater restoration"}
        },
    },
    -- Artificer - Armorer
    ["toolsofthetraide_armorer_"] = {
        ["proficiency"] = {
            innate = {"heavy armor", "smith's tools"},
        },
    },
    ["armorerspells"] = {
        ["spells"] = {
            innate = {
                [3] = {"magic missile", "thunderwave"},
                [5] = {"mirror image", "shatter"},
                [9] = {"hypnotic pattern", "lightning bolt"},
                [13] = {"fire shield", "greater invisibility"},
                [17] = {"passwall", "wall of force"},
            },
        },
    },
    ["armormodel"] = {
        ["multiple_actions"] = {
            ["Thunder Gauntlets"] = {
                ["actions"] = {
                    { type = "damage", clauses = { { dice = { "d8", }, modifier = 0, dmgtype = "thunder", }, } },
                },
            },
            ["Defensive Field"] = {
                ["actions"] = {
                    { type = "heal", subtype = "temp", sTargeting = "self", clauses = { { dice = { }, bonus = 0, stat = "artificer" }, } },
                },
            },
            ["Lightning Launcher"] = {
                ["actions"] = {
                    { type = "attack", range = "R", },
                    { type = "damage", clauses = { { dice = { "d6", }, modifier = 0, dmgtype = "lightning", }, } },
                },
            },
            ["Dampening Field"] = {
                ["actions"] = {
                    { type = "effect", sName = "Dampening Field; ADVSAV: stealth", sTargeting = "self", },
                },
            },
        },
    },
    -- Artificer - Artillerist
    ["toolsofthetraide_artillerist_"] = {
        ["proficiency"] = {
            innate = {"woodcarver's tools"},
        },
    },
    ["artilleristspells"] = {
        ["spells"] = {
            innate = {
                [3] = {"shield", "thunderwave"},
                [5] = {"scorching ray", "shatter"},
                [9] = {"fireball", "wind wall"},
                [13] = {"ice storm", "wall of fire"},
                [17] = {"cone of cold", "wall of force"},
            },
        },
    },
    ["eldritchcannon"] = {
        ["actions"] = {
            { type = "heal", clauses = { { dice = { "d6", "d6" }, bonus = 0, }, } },
        },
    },
    ["arcanefirearm"] = {
        ["actions"] = {
            { type = "effect", sName = "DMG: 1d8", nDuration = 1, sApply = "roll" },
        },
    },
    ["explosivecannon"] = {
        ["actions"] = {
            { type = "damage", clauses = { { dice = { "d8", "d8", "d8" }, modifier = 0, dmgtype = "force", }, } },
            { type = "powersave", save = "dexterity", savestat = "spell", onmissdamage = "half" },
        },
    },
    -- Artificer - Battle Smith
    ["toolproficiency_battlesmith_"] = {
        ["proficiency"] = {
            innate = {"smith's tools"},
        },
    },
    ["battlesmithspells"] = {
        ["spells"] = {
            innate = {
                [3] = {"heroism", "shield"},
                [5] = {"branding smite", "warding bond"},
                [9] = {"aura of vitality", "conjure barrage"},
                [13] = {"aura of purity", "fire shield"},
                [17] = {"banishing smite", "mass cure wounds"},
            },
        },
    },
    ["battleready"] = {
        ["proficiency"] = {
            innate = {"martial weapons"},
        },
    },
    ["arcanejolt"] = {
        ["actions"] = {
            { type = "damage", clauses = { { dice = { "d6", "d6" }, modifier = 0, dmgtype = "force", }, } },
            { type = "heal", clauses = { { dice = { "d6", "d6" }, bonus = 0, }, } },
        },
    },
    -- Barbarian
    ["rage"] = {
        ["actions"] = {
            { type = "effect", sName = "Rage; ADVCHK: strength; ADVSAV: strength; DMG: 4, melee; RESIST: bludgeoning, piercing, slashing", sTargeting = "self", nDuration = 1, sUnits = "minute" },
        },
        prepared = 2,
    },
    ["recklessattack"] = {
        ["actions"] = {
            { type = "effect", sName = "Reckless Attack; ADVATK: melee; GRANTADVATK:", sTargeting = "self", nDuration = 1,  },
        },
    },
    ["feralinstinct"] = {
        ["actions"] = {
            { type = "effect", sName = "Feral Instinct; ADViNIT:", sTargeting = "self" },
        },
    },
    ["relentlessrage"] = {
        ["actions"] = {
            { type = "effect", sName = "Relentless Rage - CON save;", sTargeting = "self", },
        },
    },
    ["brutalcritical"] = {
        ["actions"] = {
            { type = "effect", sName = "Brutal Critical; DMG: 3d8, melee, critical", sTargeting = "self", }
        },
    },
    ["dangersense"] = {
        ["actions"] = {
            { type = "effect", sName = "Danger Sense; ADVSAV: dexterity", sTargeting = "self", sApply = "action" }
        },
    },
    -- Barbarian - Path of the Ancestral Guardian
    ["ancestralprotectors"] = {
        ["actions"] = {
            { type = "effect", sName = "Protected", sTargeting = "self", nDuration = 1 },
            { type = "effect", sName = "IFT: CUSTOM(Protected);DISATK", sTargeting = "self", nDuration = 1 },
            { type = "effect", sName = "RESIST: all", sTargeting = "self", nDuration = 1 },
        },
    },
    ["spiritshield"] = {
        ["actions"] = {
            { type = "effect", sName = "DMG: -2d6", sTargeting = "self", sApply = "action" },
        }
    },
    ["consultthespirits"] = {
        ["actions"] = {},
        usesperiod = "enc",
    },
    ["vengefulancestors"] = {
        ["actions"] = {
            { type = "damage", clauses = { { dice = { }, modifier = 1, dmgtype = "force", }, } },
        },
    },
    -- Barbarian - Path of the Battlerager
    ["battleragerarmor"] = {
        ["actions"] = {
            { type = "attack", range = "M", },
            { type = "damage", clauses = { { dice = { "d4", }, modifier = 0, dmgtype = "piercing", stat = "strength" }, } },
            { type = "damage", clauses = { { dice = { }, modifier = 3, dmgtype = "piercing", }, } },
        },
    },
    ["recklessabandon"] = {
        ["actions"] = {
            { type = "heal", subtype = "temp", sTargeting = "self", clauses = { { dice = { }, bonus = 0, stat = "constitution" }, } },
        },
    },
    ["spikedretribution"] = {
        ["actions"] = {
            { type = "damage", clauses = { { dice = { }, modifier = 3, dmgtype = "piercing", }, } },
        },
    },
    -- Barbarian - Path of the Beast
    ["formofthebeast"] = {
        ["multiple_actions"] = {
            ["Bite"] = {
                ["actions"] = {
                    { type = "attack", range = "M", },
                    { type = "damage", clauses = { { dice = { "d8", }, modifier = 0, dmgtype = "piercing", stat = "strength" }, } },
                    { type = "heal", sTargeting = "self", clauses = { { dice = { }, bonus = 0, stat = "prf" }, } },
                },
            },
            ["Claws"] = {
                ["actions"] = {
                    { type = "attack", range = "M", },
                    { type = "damage", clauses = { { dice = { "d6", }, modifier = 0, dmgtype = "slashing", stat = "strength" }, } },
                },
            },
            ["Tail"] = {
                ["actions"] = {
                    { type = "attack", range = "M", },
                    { type = "damage", clauses = { { dice = { "d8", }, modifier = 0, dmgtype = "piercing", stat = "strength" }, } },
                    { type = "effect", sName = "AC: 1d8", sTargeting = "self", sApply = "single" },
                },
            },
        },
    },
    ["infectiousfury"] = {
        ["actions"] = {
            { type = "powersave", save = "wisdom", savestat = "constitution", },
            { type = "damage", clauses = { { dice = { "d12", "d12" }, modifier = 0, dmgtype = "psychic", }, } },
        },
    },
    ["callthehunt"] = {
       ["actions"] = {
            { type = "heal", subtype = "temp", sTargeting = "self", clauses = { { dice = { }, bonus = 5, }, } },
            { type = "effect", sName = "DMG: 1d6", },
       },
    },
    -- Barbarian - Path of the Berserker
    ["mindlessrage"] = {
        ["actions"] = {
            { type = "effect", sName = "Rage; ADVCHK: strength; ADVSAV: strength; DMG: 4, melee; RESIST: bludgeoning, piercing, slashing; IMMUNE: charmed; IMMUNE: frightened", sTargeting = "self", nDuration = 1, sUnits = "minute" },
        },
        prepared = 6,
    },
    ["intimidatingpresence"] = {
        ["actions"] = {
            { type = "powersave", save = "wisdom", savemod = 0, savestat = "charisma", },
            { type = "effect", sName = "Frightened", nDuration = 1 },
        },
    },
    -- Barbarian - Path of the Storm Herald
    ["stormaura"] = {
        ["actions"] = {
            { type = "damage", clauses = { { dice = { }, modifier = 2, dmgtype = "fire", }, } },
            { type = "powersave", save = "dexterity", onmissdamage = "half" },
            { type = "damage", clauses = { { dice = { "d6" }, modifier = 0, dmgtype = "lightning", }, } },
            { type = "heal", subtype = "temp", sTargeting = "self", clauses = { { dice = { }, bonus = 2 }, } },
            { type = "effect", sName = "Storm Aura", sTargeting = "self", nDuration = 1, sUnits = "minute" },
        },
    },
    ["stormsoul"] = {
        ["actions"] = {
            { type = "effect", sName = "RESIST: fire", sTargeting = "self", nDuration = 1, sUnits = "minute" },
            { type = "effect", sName = "RESIST: lightning", sTargeting = "self", nDuration = 1, sUnits = "minute" },
            { type = "effect", sName = "RESIST: cold", sTargeting = "self", nDuration = 1, sUnits = "minute" },
        },
    },
    ["shieldingstorm"] = {
        ["actions"] = {
            { type = "effect", sName = "RESIST: fire", nDuration = 1, sUnits = "minute" },
            { type = "effect", sName = "RESIST: lightning", nDuration = 1, sUnits = "minute" },
            { type = "effect", sName = "RESIST: cold", nDuration = 1, sUnits = "minute" },
        },
    },
    ["ragingstorm"] = {
        ["actions"] = {
            { type = "powersave", save = "dexterity" },
            { type = "damage", clauses = { { dice = { }, modifier = -10, dmgtype = "fire", stat = "barbarian" }, } },
            { type = "powersave", save = "strength" },
            { type = "effect", sName = "prone" },
            { type = "effect", sName = "Speed reduced to zero", nDuration = 1 },
        },
    },
    -- Barbarian - Path of the Totem Warrior
    ["spiritseeker"] = {
        ["spells"] = {
            {"beast sense", "speak with animals"},
        },
    },
    ["totemspirit"] = {
        ["actions"] = {
            { type = "effect", sName = "Rage Bear; ADVCHK: strength; ADVSAV: strength; DMG: 4, melee; RESIST: all, !psychic", sTargeting = "self", nDuration = 1, sUnits = "minute" },
            { type = "effect", sName = "Rage Eagle; ADVCHK: strength; ADVSAV: strength; DMG: 4, melee; GRANTDISATK: opportunity; RESIST: bludgeoning, piercing, slashing", sTargeting = "self", nDuration = 1, sUnits = "minute" },
            { type = "effect", sName = "Rage Wolf; ADVATK: melee", sTargeting = "self", nDuration = 1, sUnits = "minute" },
        },
    },
    ["totemicattunement"] = {
        ["actions"] = {
             { type = "effect", sName = "GRANTDISATK:", sTargeting = "self", nDuration = 1, sUnits = "minute", }
        },
    },
    -- Barbarian - Path of the Zealot
    ["divinefury"] = {
        ["actions"] = {
            { type = "damage", clauses = { { dice = { "d6" }, modifier = -10, dmgtype = "necrotic", stat = "barbarian" } } },
            { type = "effect", sName = "DMG: 1d6+10, radiant", sTarget = "self" },
        },
    },
    ["zealouspresence"] = {
        ["actions"] = {
            { type = "effect", sName = "ADVATK; ADVSAV", nDuration = 1 },
        },
    },
    -- Bard
    ["bardicinspiration"] = {
        ["actions"] = {
            { type = "effect", sName = "Bardic Inspiration;", nDuration = 10, nUnits = "minute" },
        },
    },
    ["countercharm"] = {
        ["actions"] = {
            { type = "effect", sName = "Countercharm;", sTarget = "self", nDuration = 1 },
        },
    },
    ["jackofalltrades"] = {
        ["actions"] = {
            { type = "effect", sName = "Jack of all Trades; INIT:[HPRF]", sTarget = "self" },
            { type = "effect", sName = "Jack of all Trades; CHECK:[HPRF], all", sTarget = "self", sApply = "roll" },
        },
    },
    ["songofrest"] = {
        ["actions"] = {
            { type = "heal", clauses = { { dice = { "d12" }, bonus = 0 }, } },
        },
    },
    -- Bard - College of Creation
    ["moteofpotential"] = {},
    ["performanceofcreation"] = {},
    ["animatingperformance"] = {},
    ["creativecrescendo"] = {},
    -- Bard - College of Eloquence
    ["silvertongue"] = {},
    ["unsettlingwords"] = {},
    ["unfailinginspiration"] = {},
    ["universalspeech"] = {},
    ["infectiousinspiration"] = {},
    -- Bard - College of Glamour
    ["mantleofinspiration"] = {
        ["actions"] = {
            { type = "heal", subtype = "temp", clauses = { { dice = { }, bonus = 5, }, } },
        },
    },
    ["enthrallingperformance"] = {
        ["actions"] = {
            { type = "powersave", save = "wisdom" },
            { type = "effect", sName = "Charmed", nDuration = 60, sUnits = "minute" },
        },
        prepared = 1,
        usesperiod = "enc",
    },
    ["mantleofmajesty"] = {
        ["actions"] = {
            { type = "effect", sName = "Mantle of Majesty; (C)", sTargeting = "self", nDuration = 1, sUnits = "minute" },
        },
        prepared = 1,
        usesperiod = "enc",
    },
    ["unbreakablemajesty"] = {
        ["actions"] = {
            { type = "powersave", save = "charisma" },
            { type = "effect", sName = "Unbreakable Majesty", sTargeting = "self", nDuration = 1, sUnits = "minute", },
            { type = "effect", sName = "DISSAV", sApply = "action" },
        },
        prepared = 1,
        usesperiod = "enc",
    },
    -- Bard - College of Lore
    ["bonusproficiencies_lore_"] = {
        ["skills"] = {
            choice = 3,
            choice_skills = {"any"},
        },
    },
    ["cuttingwords"] = {
    },
    ["additionalmagicalsecrets"] = {
        ["spells"] = {
            choice = 2,
        }
    },
    ["peerlessskill"] = {},
    -- Bard - College of Spirits
    ["guidingwhispers"] = {
        ["spells"] = {
            innate = {"guidance"},
        },
    },
    ["spiritualfocus"] = {},
    ["talesfrombeyond"] = {},
    ["spiritsession"] = {},
    ["mythicalconnection"] = {},
    -- Bard - College of Swords
    ["bonusproficiencies_lore_swords_"] = {
        ["proficiency"] = {
            innate = {"medium armor", "scimitar"},
        },
    },
    ["fightingstyle"] = {
        ["actions"] = {
            { type = "effect", sName = "DMG: 2, melee", sTargeting = "self", },
        },
    },
    ["bladeflourish"] = {
        ["actions"] = {
            { type = "effect", sName = "DMG: 1", sTargeting = "self", sApply = "action" },
            { type = "effect", sName = "AC: 1", sTargeting = "self", nDuration = 1, },
        },
    },
    -- Bard - College of Valor
    ["bonusproficiencies_valor_"] = {
        ["proficiency"] = {
            innate = {"medium armor", "shields", "martial weapons"},
        },
    },
    ["combatinspiration"] = {},
    -- Bard - College of Whispers
    ["psychicblades"] = {
        ["actions"] = {
            { type = "effect", sName = "DMG: 2d6 psychic", sTargeting = "self", sApply = "roll" },
        },
    },
    ["wordsofterror"] = {
        ["actions"] = {
            { type = "powersave", save = "wisdom", },
            { type = "effect", sName = "Frightened", nDuration = 60, sUnits = "minute", },
        },
        prepared = 1,
        usesperiod = "enc",
    },
    ["mantleofwhispers"] = {
        ["actions"] = {
            { type = "effect", sName = "Mantle of Whispers", sTargeting = "self", nDuration = 60, sUnits = "minute", },
            { type = "effect", sName = "SKILL: 5, deception", sTargeting = "self", sApply = "action" },
        },
        prepared = 1,
        usesperiod = "enc",
    },
    ["shadowlore"] = {
        ["actions"] = {
            { type = "powersave", save = "wisdom" },
            { type = "effect", sName = "Charmed", nDuration = 8, sUnits = "hour", },
        },
        prepared = 1,
    },
    -- Cleric
    ["channeldivinity"] = {
        ["multiple_actions"] = {
            ["Turn Undead"] = {
                ["actions"] = {
                    { type = "powersave", save = "wisdom", },
                    { type = "effect", sName = "Turned", nDuration = 1, sUnits = "minute", },
                },
            },
        },
    },
    -- Cleric - Arcana Domain
    ["domainspells_arcana_"] = {
        ["spells"] = {
            innate = {
                [1] = {"detect magic" , "magic missile"},
                [3] = {"magic weapon", "nystul's magic aura"},
                [5] = {"dispel magic", "magic circle"},
                [7] = {"arcane eye", "leomund's secret chest"},
                [9] = {"planar binding", "teleportation circle"},
            },
        },
    },
    ["arcanainitiate"] = {
        ["skills"] = {
            innate = {"arcana"},
        },
        ["spells"] = {
            choice = 2,
            choice_spells = {"any"},
            spelllist = {"wizard"},
        },
    },
    ["channeldivinity_arcaneabjuration"] = {
        ["actions"] = {
            { type = "powersave", save = "wisdom", },
            { type = "effect", sName = "Turned", nDuration = 1, sUnits = "minute", },
        },
    },
    ["arcanemastery"] = {
        ["spells"] = {
            choice = 4,
            choice_spells = {"any"},
            spelllist = {"wizard"},
        },
    },
    -- Cleric - Death Domain
    ["domainspells_deathdomain_"] = {
        ["spells"] = {
            innate = {
                [1] = {"false life", "ray of sickness"},
                [3] = {"blindness/deafness", "ray of enfeeblement"},
                [5] = {"animate dead", "vampiric touch"},
                [7] = {"blight", "death ward"},
                [9] = {"antilife shell", "cloudkill"},
            },
        },
    },
    ["bonusproficiencies_death_"] = {
        ["proficiency"] = {
            innate = {"martial weapons"},
        },
    },
    ["reaper"] = {
        ["spells"] = {
            choice = 1,
            school = {"necromancy"},
            level = {0},
        },
    },
    ["channeldivinity_touchofdeath"] = {
        ["actions"] = {
            { type = "damage", clauses = { { dice = { }, modifier = 5, dmgtype = "necrotic", stat = "cleric" }, } },
        },
    },
    ["divinestrike_deathdomain_"] = {
        ["actions"] = {
            { type = "damage", clauses = { { dice = { "d8" }, modifier = 0, dmgtype = "necrotic", }, } },
        },
    },
    -- Cleric - Forge Domain
    ["domainspells_forge_"] = {
        ["spells"] = {
            innate = {
                [1] = {"indentify", "searing smite"},
                [3] = {"heat metal", "magic weapon"},
                [5] = {"elemental weapon", "protection from enegery"},
                [7] = {"fabricate", "wall of fire"},
                [9] = {"animate objects", "creation"},
            },
        },
    },
    ["bonusproficiencies_forgedomain_"] = {
        ["proficiency"] = {
            innate = {"heavy armor", "smith's tools"},
        },
    },
    ["blessingoftheforge"] = {
        ["actions"] = {
            { type = "effect", sName = "Blessing of the Forge; ATK:1; DMG: 1; DMGTYPE: magic", nDuration = 8, sUnits = "hour", },
            { type = "effect", sName = "AC: 1", nDuration = 8, sUnits = "hour", },
        },
        prepared = 1,
    },
    ["souloftheforge"] = {
        ["actions"] = {
            { type = "effect", sName = "Soul of the Forge; RESIST: fire; AC:1", sTargeting = "self", },
        },
    },
    ["divinestrike_forgedomain_"] = {
        ["actions"] = {
            { type = "effect", sName = "DMG: 1d8 fire", sTargeting = "self", sApply = "roll" },
        },
    },
    ["saintofforgeandfire"] = {
        ["actions"] = {
            { type = "effect", sName = "Saint of Forge; IMMUNE: fire; RESIST: bludgeoning, piercing, slashing, !magic", sTargeting = "self", },
        },
    },
    -- Cleric - Grave Domain
    ["domainspells_gravedomain_"] = {
        ["spells"] = {
            innate = {
                [1] = {"bane", "false life"},
                [3] = {"gentle repose", "ray of enfeeblement"},
                [5] = {"revivify", "vampiric touch"},
                [7] = {"blight", "death ward"},
                [9] = {"antilife shell", "raise dead"},
            },
        },
    },
    ["eyesofthegrave"] = {
        ["actions"] = {},
        prepared = 2,
    },
    ["channeldivinity_pathtothegrave"] = {
        ["actions"] = {
            { type = "effect", sName = "VULN: all", sApply = "action" },
        },
    },
    ["sentinelatdeath_sdoor"] = {
        ["actions"] = {},
        prepared = 2,
    },
    ["potentspellcasting"] = {
        ["actions"] = {
            { type = "effect", sName = "DMG: [WIS]", sTargeting = "self", sApply = "action" },
        },
    },
    ["keeperofsouls"] = {
        ["actions"] = {
            { type = "heal", clauses = { { dice = { }, bonus = 1, }, } },
        },
    },
    -- Cleric - Knowledge Domain
    ["domainspells_knowledgedomain_"] = {
        ["spells"] = {
            innate = {
                [1] = {"command", "indentify"},
                [3] = {"augury", "suggestion"},
                [5] = {"nondetection", "speak with dead"},
                [7] = {"arcane eye", "confusion"},
                [9] = {"legend lore", "scrying"},
            },
        },
    },
    ["blessingsofknowledge"] = {
        ["languages"] = {
            choice = 2,
            choice_languages = {"any"},
        },
        ["skills"] = {
            choice = 2,
            choice_skills = {"arcana", "history", "nature", "religion"},
            prof = "double",
        },
    },
    ["channeldivinity_readthoughts"] = {
        ["actions"] = {
            { type = "powersave", save = "wisdom", },
        },
    },
    -- Cleric - Life Domain
    ["domainspells_life_"] = {
        ["spells"] = {
            innate = {
                [1] = {"bless", "cure wounds"},
                [3] = {"lesser restoration", "spiritual weapon"},
                [5] = {"beacon of hope", "revivify"},
                [7] = {"death ward", "guardian of faith"},
                [9] = {"mass cure wounds", "raise dead"},
            },
        },
    },
    ["bonusproficiencies_life_"] = {
        ["proficiency"] = {
            innate = {"heavy armor"},
        },
    },
    ["discipleoflife"] = {
        ["actions"] = {
            { type = "heal", clauses = { { dice = { }, bonus = 2, }, } },
        },
    },
    ["channeldivinity_preservelife"] = {
        ["actions"] = {
            { type = "heal", clauses = { { dice = { }, bonus = 0, stat = "cleric" }, } },
        },
    },
    ["blessedhealer"] = {
        ["actions"] = {
            { type = "heal", sTargeting = "self", clauses = { { dice = { }, bonus = 2, }, } },
        },
    },
    ["divinestrike_life_"] = {
        ["actions"] = {
            { type = "effect", sName = "DMG: 1d8 radiant", sTargeting = "self", sApply = "roll" },
        },
    },
    ["supremeheal"] = {
        ["actions"] = {
            { type = "heal", clauses = { { dice = { }, bonus = 8, }, } },
        },
    },
    -- Cleric - Light Domain
    ["domainspells_light_"] = {
        ["spells"] = {
            innate = {
                [1] = {"burning hands", "faerie fire"},
                [3] = {"flaming sphere", "scorching ray"},
                [5] = {"daylight", "fireball"},
                [7] = {"guardian of faith", "wall of fire"},
                [9] = {"flame strike", "scrying"},
            },
        },
    },
    ["bonuscantrip_lightdomain_"] = {
        ["spells"] = {
            innate = {"light"},
        },
    },
    ["wardingflare"] = {
        ["actions"] = {
            { type = "effect", sName = "DISATK:", sApply = "action" },
        },
    },
    ["channeldivinity_radianceofthedawn"] = {
        ["actions"] = {
            { type = "powersave", save = "constitution", onmissdamage = "half" },
            { type = "damage", clauses = { { dice = { "d10", "d10" }, modifier = 0, dmgtype = "radiant", stat = "cleric" }, } },
        },
    },
    ["coronaoflight"] = {
        ["actions"] = {
            { type = "effect", sName = "DISSAV: dexterity", nDuration = 1, sUnits = "minute", },
        },
    },
    -- Cleric - Nature Domain
    ["domainspells_nature_"] = {
        ["spells"] = {
            innate = {
                [1] = {"animal friendship", "speak with animals"},
                [3] = {"barkskin", "spike growth"},
                [5] = {"plant growth", "wind wall"},
                [7] = {"dominate beast", "grasping vine"},
                [9] = {"insect plague", "tree stride"},
            },
        },
    },
    ["acolyteofnature"] = {
        ["spells"] = {
            choice = 1,
            spelllist = {"druid"},
            level = 0,
        },
        ["skills"] = {
            choice = 1,
            choice_skills = {"animal handling", "nature", "survival"},
        },
    },
    ["bonusproficiencies_nature_"] = {
        ["proficiency"] = {
            innate = {"heavy armor"},
        },
    },
    ["channeldivinity_charmanimalsandplants"] = {
        ["actions"] = {
            { type = "effect", sName = "Charmed", },
            { type = "powersave", save = "wisdom", },
        },
    },
    ["dampenelements"] = {
        ["actions"] = {
            { type = "effect", sName = "RESIST: acid,cold,fire,lightning,thunder", sApply = "roll" },
        },
    },
    ["divinestrike_nature_"] = {
        ["actions"] = {
            { type = "effect", sName = "DMG: 1d8 cold, fire, or lightning", sTargeting = "self", sApply = "roll" },
        },
    },
    -- Cleric - Order Domain
    ["domainspells_order_"] = {
        ["spells"] = {
            innate = {
                [1] = {"command", "heroism"},
                [3] = {"hold person", "zone of truth"},
                [5] = {"mass healing ward", "slow"},
                [7] = {"compulsion", "locate creature"},
                [9] = {"commune", "dominate person"},
            },
        },
    },
    ["bonusproficiencies_order_"] = {
        ["proficiency"] = {
            innate = {"heavy armor"},
        },
        ["skills"] = {
            choice = 1,
            choice_skills = {"intimidation", "persuasion"},
        }
    },
    ["cahnneldivinity_order_sdemand"] = {
        ["actions"] = {
            { type = "powersave", save = "wisdom", },
            { type = "effect", sName = "Order's Demand; Charmed", },
        },
    },
    ["divinestrike_order_"] = {
        ["actions"] = {
            { type = "effect", sName = "DMG: 1d8 psychic", sTargeting = "self", },
        },
    },
    ["order_swrath"] = {},
    -- Cleric - Peace Domain
    ["domainspells_peace_"] = {
        ["spells"] = {
            innate = {
                [1] = {"heroism", "sanctuary"},
                [3] = {"aid", "warding bond"},
                [5] = {"beacon of hope", "sending"},
                [7] = {"aura of purity", "otiluke's resilient sphere"},
                [9] = {"restoration", "rary's telepathic bond"},
            },
        },
    },
    ["implementofpeace"] = {
        ["skills"] = {
            choice = 1,
            choice_skills = {"insight", "performance", "persuasion"}
        },
    },
    ["emboldeningbond"] = {
    },
    ["channeldivinity_balmofpeace"] = {
        ["actions"] = {
            { type = "heal", clauses = { { dice = { "d6", "d6" }, bonus = 0, stat = "wisdom" }, } },
        },
    },
    -- Cleric - Tempest Domain
    ["domainspells_tempest_"] = {
        ["spells"] = {
            innate = {
                [1] = {"fog cloud", "thunderwave"},
                [3] = {"gust of wind", "shatter"},
                [5] = {"call lightning", "sleet storm"},
                [7] = {"control water", "ice storm"},
                [9] = {"destructive wave", "insect plague"},
            },
        },
    },
    ["bonusproficiencies_tempest_"] = {
        ["proficiency"] = {
            innate = {"martial weapons", "heavy armor"},
        },
    },
    ["wrathofthestorm"] = {
        ["actions"] = {
            { type = "powersave", save = "dexterity", onmissdamage = "half" },
            { type = "damage", clauses = { { dice = { "d8", "d8" }, modifier = 0, dmgtype = "lightning", }, } },
            { type = "damage", clauses = { { dice = { "d8", "d8" }, modifier = 0, dmgtype = "thunder", }, } },
        },
    },
    ["divinestrike_tempest_"] = {
        ["actions"] = {
            { type = "effect", sName = "DMG: 1d8 thunder", sTargeting = "self", },
        },
    },
    -- Cleric - Trickery Domain
    ["domainspells_trickery_"] = {
        ["spells"] = {
            innate = {
                [1] = {"charm person", "disguise self"},
                [3] = {"mirror image", "pass without trace"},
                [5] = {"blink", "dispel magic"},
                [7] = {"dimension door", "polymorph"},
                [9] = {"dominate person", "modify memory"},
            },
        },
    },
    ["blessingofthetrickster"] = {
        ["actions"] = {
            { type = "effect", sName = "ADVSKILL:stealth", nDuration = 1, sUnits = "hour", },
        },
    },
    ["channeldivinity_cloakofshadows"] = {
        ["actions"] = {
            { type = "effect", sName = "Invisible", sTargeting = "self", nDuration = 1, },
        },
    },
    ["divinestrike_trickery_"] = {
        ["actions"] = {
            { type = "effect", sName = "DMG: 1d8 poison", sTargeting = "self", },
        },
    },
    -- Cleric - Twilight Domain
    ["domainspells_twilight_"] = {
        ["spells"] = {
            innate = {
                [1] = {"faerie fire", "sleep"},
                [3] = {"moonbeam", "see invisibility"},
                [5] = {"aura of vitality", "leomund's tiny hut"},
                [7] = {"aura of life", "greater invisibility"},
                [9] = {"circle of power", "mislead"},
            },
        },
    },
    ["bonusproficiencies_twilight_"] = {
        ["proficiency"] = {
            innate = {"martial weapons", "heavy armor"},
        },
    },
    ["vigilantblessing"] = {
        ["actions"] = {
            { type = "effect", sName = "Vigilant Blessing;ADVINIT", sApply = "roll" },
        },
    },
    ["channeldivinity_twilightsanctuary"] = {
        ["actions"] = {
            { type = "heal", subtype = "temp", clauses = { { dice = { "d6" }, bonus = 0, stat = "cleric" }, } },
            { type = "effect", sName = "Twilight Sanctuary;Charmed", },
            { type = "effect", sName = "Twilight Sanctuary;Frightened", },
        },
    },
    ["stepsofnight"] = {},
    ["divinestrike_twilight_"] = {
        ["actions"] = {
            { type = "effect", sName = "DMG: 1d8 radiant", sTargeting = "self", sApply = "roll" },
        },
    },
    ["twilightshroud"] = {},
    -- Cleric - War Domain
    ["domainspells_war_"] = {
        ["spells"] = {
            innate = {
                [1] = {"divine favor", "shield of faith"},
                [3] = {"magic weapon", "spiritual weapon"},
                [5] = {"crusader's mantle", "spirit guardians"},
                [7] = {"freedom of movement", "stoneskin"},
                [9] = {"flame strike", "hold monster"},
            },
        },
    },
    ["bonusproficiencies_wardomain_"] = {
        ["proficiency"] = {
            innate = {"martial weapons", "heavy armor"},
        },
    },
    ["warpriest"] = {},
    ["channeldivinity_guidedstrike"] = {
        ["actions"] = {
            { type = "effect", sName = "ATK: 10", sTargeting = "self", sApply = "roll" },
        },
    },
    ["channeldivinity_wargod_sblessing"] = {
        ["actions"] = {
            { type = "effect", sName = "ATK: 10", sApply = "roll" },
        },
    },
    ["divinestrike_war_"] = {
        ["actions"] = {
            { type = "effect", sName = "DMG: 1d8", sTargeting = "self", sApply = "roll" },
        },
    },
    ["avatarofbattle"] = {
        ["actions"] = {
            { type = "effect", sName = "RESIST:bludgeoning,piercing,slashing,!magic", sTargeting = "self", },
        },
    },
    -- Druid
    ["druidic"] = {
        ["languages"] = {
            innate = {"druidic"},
        },
    },
    ["wildshape"] = {
        ["actions"] = {},
        prepared = 2,
        usesperiod = "enc",
    },
    ["wildshape"] = {},
    -- Druid - Circle of Dreams
    ["balmofthesummercourt"] = {
        ["actions"] = {
            { type = "heal", clauses = { { dice = { "d6", }, bonus = 0, }, } },
            { type = "heal", subtype = "temp", clauses = { { dice = { }, bonus = 1, }, } },
        },
        prepared = 1,
    },
    ["hearthofmoonlightandshadow"] = {
        ["actions"] = {
            { type = "effect", sName = "SKILL: 5, stealth, perception", },
        },
    },
    ["hiddenpaths"] = {
        ["actions"] = {},
        prepared = 1,
    },
    ["walkerindreams"] = {
        ["actions"] = {},
        prepared = 1,
    },
    -- Druid - Circle of Spores
    ["circlespells_spores_"] = {
        ["spells"] = {
            innate = {
                [2] = {"chill touch"},
                [3] = {"blindness/deafness", "gentle repose"},
                [5] = {"animate dead", "gaseous form"},
                [7] = {"blight", "confusion"},
                [9] = {"cloudkill", "contagion" },
            },
        },
    },
    ["haloofspores"] = {
        ["actions"] = {
            { type = "powersave", save = "constitution", savestat = "spell", },
            { type = "damage", clauses = { { dice = { "d4" }, modifier = 0, dmgtype = "necrotic", }, } },
        },
    },
    ["symbioticentity"] = {
        ["actions"] = {
            { type = "heal", subtype = "temp", sTargeting = "self", clauses = { { dice = { }, bonus = 4 }, } },
            { type = "effect", sName = "DMG: 1d6 necrotic", sTargeting = "self", nDuration = 10, sUnits = "minute", },
        },
    },
    ["fungalinfestation"] = {},
    ["spreadingspores"] = {
        ["actions"] = {
            { type = "powersave", save = "constitution", savestat = "spell", },
        },
    },
    ["fungalbody"] = {
        ["actions"] = {
            { type = "effect", sName = "IMMUNE: blind, deaf, frightened, poisoned, critical", sTargeting = "self", },
        },
    },
    -- Druid - Circle of Stars
    ["starmap"] = {
        ["spells"] = {
            innate = {"guidance", "guiding bolt"}
        },
    },
    ["starryform"] = {
        ["multiple_actions"] = {
            ["Archer"] = {
                ["actions"] = {
                    { type = "attack", range = "R", },
                    { type = "damage", clauses = { { dice = { "d8" }, modifier = 0, dmgtype = "radiant", stat = "wisdom" }, } },
                },
            },
            ["Chalice"] = {
                ["actions"] = {
                    { type = "heal", sTargeting = "self", clauses = { { dice = { "d8" }, bonus = 0, stat = "wisdom" }, } },
                },
            },
        },
    },
    ["cosmicomen"] = {
        ["multiple_actions"] = {
            ["Weal (even)"] = {
                ["actions"] = {},
            },
            ["Woe (odd)"] = {
                ["actions"] = {},
            },
        },
    },
    ["twinklingconstellations"] = {},
    ["fullofstars"] = {
        ["actions"] = {
            { type = "effect", sName = "RESIST: bludgeoning, piercing, slashing", sTargeting = "self", },
        },
    },
    -- Druid - Circle of the Land
    ["bonuscantrip_land_"] = {
        ["spells"] = {
            choice = 1,
            spelllist = "druid",
            level = 0,
        },
    },
    ["circlespells_arctic"] = {},
    ["circlespells_coast"] = {},
    ["circlespells_desert"] = {},
    ["circlespells_forest"] = {},
    ["circlespells_grassland"] = {},
    ["circlespells_mountain"] = {},
    ["circlespells_swamp"] = {},
    ["circlespells_underdark"] = {},
    ["land_sstride"] = {
        ["actions"] = {
            { type = "effect", sName = "Land's Stride; ADVSAV:all", sTargeting = "self", sApply = "action" },
        },
    },
    ["nature_sward"] = {
        ["actions"] = {
            { type = "effect", sName = "IMMUNE:poison; IMMUNE:poisoned; IFT:TYPE(elemental,fey);IMMUNE:charmed;IMMUNE:frightened", sTargeting = "self", },
            { type = "effect", sName = "Nature's Ward;IMMUNE: disease", sTargeting = "self", },
        },
    },
    ["nature_ssanctuary"] = {
        ["actions"] = {
            { type = "powersave", save = "wisdom", },
        },
    },
    -- Druid - Circle of the Moon
    ["combatwildshape"] = {
        ["actions"] = {
            { type = "heal", sTargeting = "self", clauses = { { dice = { "d8" }, bonus = 0 }, } },
            { type = "heal", sTargeting = "self", clauses = { { dice = { "d8", "d8" }, bonus = 0, }, } },
        },
        usesperiod = "enc",
    },
    ["primalstrike"] = {
        ["actions"] = {
            { type = "effect", sName = "DMGTYPE:magic", sTargeting = "self", },
        },
    },
    -- Druid - Circle of the Shepherd
    ["spirittotem"] = {
        ["actions"] = {
            { type = "effect", sName = "Spirit Totem", sTargeting = "self", nDuration = 1, sUnits = "minute", },
            { type = "heal", clauses = { { dice = { }, bonus = 0, }, } },
            { type = "effect", sName = "Spirit Totem (Hawk);ADVATK", sApply = "action" },
            { type = "effect", sName = "Spirit Totem (Hawk);ADVSKILL: perception", nDuration = 1, sUnits = "minute", },
            { type = "heal", subtype = "temp", clauses = { { dice = { }, bonus = 5, }, } },
            { type = "effect", sName = "Spirit Totem (Bear);AVDCHK: strength;ADVSAV: strength", nDuration = 1, sUnits = "minute", },
        },
    },
    ["mightysummoner"] = {
        ["actions"] = {
            { type = "effect", sName = "DMGTYPE: magic", },
        },
    },
    ["guardianspirit"] = {
        ["actions"] = {
            { type = "heal", clauses = { { dice = { }, bonus = -10, }, } },
        },
    },
    ["faithfulsummons"] = {
        ["actions"] = {},
        prepared = 1,
    },
    -- Druid - Circle of Wildfire
    ["circlespells_wildfire_"] = {},
    ["summonwildfirespirit"] = {},
    ["enhancedbond"] = {},
    ["cauterizingflames"] = {},
    ["blazingrevival"] = {},
    -- Fighter
    ["secondwind"] = {
        ["actions"] = {
            { type = "heal", sTargeting = "self", clauses = { { dice = { "d10" }, bonus = 0, stat = "fighter" }, } },
        },
        usesperiod = "enc",
    },
    ["actionsurge"] = {
        ["actions"] = {},
        prepared = 2,
        usesperiod = "enc",
    },
    ["indomitable"] = {
        ["actions"] = {},
        prepared = 4,
    },
    -- Fighter - Arcane Archer
    ["arcanearcherlore"] = {
        ["skills"] = {
            choice = 1,
            choice_skills = {"arcana", "nature"},
        },
        ["spells"] = {
            choice = 1,
            choice_spells = {"prestidigitation", "druidcraft"},
        },
    },
    ["arcaneshot"] = {
        ["multiple_actions"] = {
            ["Banishing Arrow"] = {
                ["actions"] = {
                    { type = "effect", sName = "Banishing Arrow;Incapacitated", nDuration = 1, },
                    { type = "powersave", save = "charisma", },
                },
            },
            ["Beguiling Arrow"] = {
                ["actions"] = {
                    { type = "effect", sName = "Beguiling Arrow;DMG: 2d6, psychic", sTargeting = "self", sApply = "action" },
                    { type = "powersave", save = "wisdom", },
                    { type = "effect", sName = "Beguiling Arrow;Charmed", nDuration = 1 },
                },
            },
            ["Bursting Arrow"] = {
                ["actions"] = {
                    { type = "damage", clauses = { { dice = { "d6", "d6" }, modifier = 0, dmgtype = "force", }, } },
                },
            },
            ["Enfeebling Arrow"] = {
                ["actions"] = {
                    { type = "effect", sName = "Enfeebling Arrow;DMG: 2d6, necrotic", sTargeting = "self", sApply = "action" },
                    { type = "powersave", save = "constitution", },
                    { type = "effect", sName = "Enfeebling Arrow;Damage Halved", },
                },
            },
            ["Grasping Arrow"] = {
                ["actions"] = {
                    { type = "effect", sName = "Grasping Arrow;DMG: 2d6, poison", sTargeting = "self", sApply = "action" },
                    { type = "damage", clauses = { { dice = { "d6", "d6" }, modifier = 0, dmgtype = "slashing", }, } },
                    { type = "effect", sName = "Grasping Arrow;Takes damage on move", nDuration = 1, sUnits = "minute", },
                },
            },
            ["Piercing Arrow"] = {
                ["actions"] = {
                    { type = "powersave", save = "dexterity", onmissdamage = "half" },
                    { type = "effect", sName = "Piercing Arrow;DMG: 1d6, piercing", sTargeting = "self", sApply = "action" },
                },
            },
            ["Seeking Arrow"] = {
                ["actions"] = {
                    { type = "powersave", save = "dexterity", onmissdamage = "half" },
                    { type = "effect", sName = "Seeking Arrow;DMG: 1d6, force", sTargeting = "self", sApply = "action" },
                },
            },
            ["Shadow Arrow"] = {
                ["actions"] = {
                    { type = "effect", sName = "Shadow Arrow;DMG: 2d6, psychic", sTargeting = "self", sApply = "action" },
                    { type = "powersave", save = "wisdom", },
                    { type = "effect", sName = "Shadow Arrow; Can't see beyond 5 ft; Blinded", nDuration = 1, },
                },
            },
        },
    },
    ["magicarrow"] = {
        ["actions"] = {
            { type = "effect", sName = "Magic Arrow;DMGTYPE: magic", sTargeting = "self", sApply = "action" },
        },
    },
    ["curvingshot"] = {},
    ["ever_readyshot"] = {},
    -- Fighter - Battle Master
    ["combatsuperiority"] = {
        ["multiple_actions"] = {
            ["Commander's Strike"] = {
                ["actions"] = {
                    { type = "effect", sName = "Commander's Strike;DMG: 1d8", sApply = "roll" },
                },
            },
            ["Disarming Strike"] = {
                ["actions"] = {
                    { type = "effect", sName = "Disarming Strike; DMG: 1d8", sTargeting = "self", sApply = "action" },
                    { type = "powersave", save = "strength", },
                    { type = "effect", sName = "Disarming Strike - item dropped;", nDuration = 1, },
                },
            },
            ["Distracting Strike"] = {
                ["actions"] = {
                    { type = "effect", sName = "Distracting Strike; DMG: 1d8", sApply = "action" },
                    { type = "effect", sName = "Distracting Strike; GRANTADVATK:", nDuration = 1, sApply = "action" },
                },
            },
            ["Feinting Attack"] = {
                ["actions"] = {
                    { type = "effect", sName = "Feinting Attack; DMG: 1d8", sTargeting = "self", sApply = "roll" },
                    { type = "effect", sName = "Feinting Attack; ADVATK:", sTargeting = "self", nDuration = 1, sApply = "action" },
                },
            },
            ["Goading Attack"] = {
                ["actions"] = {
                    { type = "effect", sName = "Goading Attack; DMG: 1d8", sTargeting = "self", sApply = "action" },
                    { type = "powersave", save = "wisdom", },
                    { type = "effect", sName = "Goaded; DISATK:", nDuration = 1 },
                },
            },
            ["Lunging Attack"] = {
                ["actions"] = {
                    { type = "effect", sName = "Lunging Attack; DMG: 1d8", sTargeting = "self", sApply = "action" },
                },
            },
            ["Maneuvering Attack"] = {
                ["actions"] = {
                    { type = "effect", sName = "Maneuvering Attack; DMG: 1d8", sTargeting = "self", sApply = "action" },
                },
            },
            ["Menacing Attack"] = {
                ["actions"] = {
                    { type = "powersave", save = "wisdom", },
                    { type = "effect", sName = "Menaced; frightened", nDuration = 1 },
                    { type = "effect", sName = "Menacing Attack; DMG: 1d8", sTargeting = "self", sApply = "action" },
                },
            },
            ["Precision Attack"] = {
                ["actions"] = {
                    { type = "effect", sName = "Precision Attack; ATK:1d8", sTargeting = "self", sApply = "action" },
                },
            },
            ["Pushing Attack"] = {
                ["actions"] = {
                    { type = "powersave", save = "strength", },
                    { type = "effect", sName = "Pushing Attack; DMG: 1d8", sTargeting = "self", sApply = "action" },
                },
            },
            ["Rally"] = {
                ["actions"] = {
                    { type = "heal", subtype = "temp", clauses = { { dice = { "d8" }, bonus = 0, stat = "charisma" }, } },
                },
            },
            ["Riposte"] = {
                ["actions"] = {
                    { type = "effect", sName = "Riposte; DMG:1d8", sTargeting = "self", nDuration = 1, sApply = "action" },
                },
            },
            ["Sweeping Attack"] = {
                ["actions"] = {
                    { type = "damage", clauses = { { dice = { "d8" }, modifier = 0, dmgtype = "slashing", }, } },
                    { type = "damage", clauses = { { dice = { "d8" }, modifier = 0, dmgtype = "piercing, magic", }, } },
                },
            },
            ["Trip Attack"] = {
                ["actions"] = {
                    { type = "powersave", save = "strength", },
                    { type = "effect", sName = "Trip Attack; prone", },
                    { type = "effect", sName = "Trip Attack; DMG:1d8", sTargeting = "self", sApply = "action" },
                    { type = "effect", sName = "Eldritch Strike; DISSAV:all;", nDuration = 1, sApply = "action" },
                },
            },
        },
    },
    ["studentofwar"] = {
        ["proficiency"] = {
            choice = 1,
            choice_profs = {"artisan's tools"},
        },
    },
    -- Fighter - Cavalier
    ["bonusproficiency_cavalier_"] = {
        ["multiple_choice"] = {
            ["skills"] = {
                choice = 1,
                choice_skills = {"animal handling", "history", "insight", "performance", "persuasion"},
            },
            ["languages"] = {
                choice = 1,
                choice_languages = "any",
            },
        },
    },
    ["borntothesaddle"] = {
        ["actions"] = {
            { type = "effect", sName = "ASVSAV", sTargeting = "self", sApply = "action" },
        },
    },
    ["unwaveringmark"] = {
        ["actions"] = {
            { type = "effect", sName = "Protected", nDuration = 1, },
            { type = "effect", sName = "IFT: CUSTOM (Protected); DISATK", nDuration = 1, },
            { type = "effect", sName = "ADVATK", sTargeting = "self", sApply = "action" },
            { type = "effect", sName = "DMG: [HLVL]", sTargeting = "self", sApply = "action" },
        },
    },
    ["wardingmaneuver"] = {
        ["actions"] = {
            { type = "effect", sName = "AC: 1", sApply = "action" },
            { type = "effect", sName = "RESIST: all", sApply = "action" },
        },
        prepared = 2,
    },
    ["ferociouscharger"] = {
        ["actions"] = {
            { type = "powersave", save = "strength", },
            { type = "effect", sName = "Prone", },
        },
    },
    -- Fighter - Champion
    ["improvedcritical"] = {},
    ["remarkableathlete"] = {
        ["actions"] = {
            { type = "effect", sName = "CHECK:[HPRF], strength; CHECK:[HPRF],dexterity; CHECK:[HPRF],constitution", sTargeting = "self", sApply = "action" },
            { type = "effect", sName = "INIT:[HPRF]", sTargeting = "self", },
        },
    },
    ["superiorcritical"] = {},
    ["survivor"] = {
        ["actions"] = {
            { type = "effect", sName = "IF:Bloodied; REGEN:5 [CON]", sTargeting = "self", },
        },
    },
    -- Fighter - Echo Knight
    ["manifestecho"] = {},
    ["unleashincarnation"] = {},
    ["echoavatar"] = {},
    ["shadowmartyr"] = {},
    ["reclaimpotential"] = {
        ["actions"] = {
            { type = "heal", subtype = "temp", sTargeting = "self", clauses = { { dice = { "d6", "d6" }, bonus = 0, stat = "constitution" }, } },
        },
    },
    ["legionofone"] = {},
    -- Fighter - Eldritch Knight
    -- Fighter - Psi Warrior
    ["psionicpower"] = {},
    ["telekineticadept"] = {},
    ["guardedmind"] = {},
    ["bulwarkofforce"] = {},
    ["telekineticmaster"] = {},
    -- Figther - Purple Dragon Knight
    ["rallyingcry"] = {
        ["actions"] = {
            { type = "heal", sTargeting = "self", clauses = { { dice = { }, bonus = 0, stat = "fighter" }, } },
        },
        usesperiod = "enc",
    },
    ["royalenvoy"] = {
        ["actions"] = {
            { type = "effect", sName = "SKILL:[PRF], persuasion", sTargeting = "self", },
        },
    },
    -- Fighter - Rune Knight
    ["bonusproficiencies_runeknight_"] = {
        ["proficiency"] = {
            innate = {"smith's tools"},
        },
        ["languages"] = {
            innate = {"giant"},
        },
    },
    ["runecarver"] = {},
    ["giant_smight"] = {},
    ["runicshield"] = {},
    ["greatstature"] = {},
    ["masterofrunes"] = {},
    ["runicjuggernaut"] = {},
    -- Fighter - Samurai
    ["bonusproficiency_samurai_"] = {
        ["skills"] = {
            choice = 1,
            choice_skills = {"history", "insight", "performance", "persuasion"},
        },
        ["languages"] = {
            choice = 1,
            choice_languages = {"any"},
        },
    },
    ["fightingspirit"] = {
        ["actions"] = {
            { type = "heal", subtype = "temp", sTargeting = "self", clauses = { { dice = { }, bonus = 5, }, } },
            { type = "effect", sName = "ADVATK", sTargeting = "self", sApply = "action" },
        },
        prepared = 3
    },
    ["elegantcourtier"] = {
        ["actions"] = {
            { type = "effect", sName = "SKILL: [WIS], persuasion", sTargeting = "self", },
        },
    },
    ["rapidstrike"] = {
        ["actions"] = {
            { type = "effect", sName = "ADVATK:", sTargeting = "self", sApply = "action" },
        },
    },
    -- Monk
    ["martialarts"] = {
        ["actions"] = {
            { type = "attack", range = "M", },
            { type = "damage", clauses = { { dice = { "d4", }, modifier = 0, dmgtype = "bludgeoning", stat = "dexterity" }, } },
        },
    },
    ["ki"] = {
        ["multiple_actions"] = {
            ["Flurry of Blows"] = {
                ["actions"] = {
                    { type = "powersave", save = "dexterity", },
                    { type = "effect", sName = "Flurry of Blows;Prone", },
                    { type = "powersave", save = "strength", },
                },
            },
            ["Patient Defense"] = {
                ["actions"] = {
                    { type = "effect", sName = "Patient Defense;Dodge", sTargeting = "self", nDuration = 1, },
                },
            },
        },
    },
    ["deflectmissiles"] = {},
    ["slowfall"] = {
        ["actions"] = {
            { type = "heal", sTargeting = "self", clauses = { { dice = { }, bonus = 0, stat = "level" }, } },
        },
    },
    ["quickenedhealing_option_"] = {},
    ["stunningstrike"] = {
        ["actions"] = {
            { type = "powersave", save = "constitution", },
            { type = "effect", sName = "Stunned", nDuration = 1, },
        },
    },
    ["ki_empoweredstrikes"] = {},
    ["evasion"] = {
        ["actions"] = {
            { type = "effect", sName = "Evasion", sTargeting = "self", },
        },
    },
    ["purityofbody"] = {
        ["actions"] = {
            { type = "effect", sName = "IMMUNE: poison,poisoned", sTargeting = "self", },
            { type = "effect", sName = "Immunity to disease", sTargeting = "self", },
        },
    },
    ["tongueofthesunandmoon"] = {},
    ["diamondsoul"] = {},
    ["timelessbody"] = {},
    ["emptybody"] = {
        ["actions"] = {
            { type = "effect", sName = "Invisible", sTargeting = "self", nDuration = 1, sUnits = "minute", },
            { type = "effect", sName = "RESIST:all,!force", sTargeting = "self", nDuration = 1, sUnits = "minute", },
        },
    },
    ["perfectself"] = {},
    -- Monk - Way of Mercy
    ["implementsofmercy"] = {
        ["skills"] = {
            innate = {"insight", "medicine"},
        },
        ["proficiency"] = {
            innate = {"herbalism kit"},
        },
    },
    ["handofhealing"] = {},
    ["handofharm"] = {},
    ["physician_stouch"] = {},
    ["flurryofhealingandharm"] = {},
    ["handofultimatemercy"] = {},
    -- Monk - Way of Shadow
    ["shadowarts"] = {
        ["spells"] = {
            ["spells"] = {
                innate = {"minor illusion"},
            },
        },
    },
    ["shadowstep"] = {
        ["actions"] = {
            { type = "effect", sName = "ADVATK: melee", sTargeting = "self", nDuration = 1, sApply = "action" },
        },
    },
    ["cloakofshadows"] = {
        ["actions"] = {
            { type = "effect", sName = "Invisible", sTargeting = "self", },
        },
    },
    ["opportunist"] = {},
    -- Monk - Way of the Ascendant
    ["draconicdisciple"] = {
        ["multiple_actions"] = {},
        ["languages"] = {
            innate = {"Draconic"},
        },
    },
    ["breathofthedragon"] = {},
    ["wingsunfurled"] = {},
    ["aspectofthewyrm"] = {},
    ["ascendantaspect"] = {},
    -- Monk - Way of the Astral Self
    ["armsoftheastralself"] = {},
    ["visageoftheastralself"] = {},
    ["bodyoftheastralself"] = {},
    ["awakenedastralself"] = {},
    -- Monk - Way of the Drunken Master
    ["bonusproficiencies_drunkenmaster_"] = {
        ["skills"] = {
            innate = {"performance"},
        },
        ["proficiency"] = {
            innate = {"brewer's supplies"},
        },
    },
    ["drunkentechnique"] = {},
    ["tipsysway"] = {},
    ["drunkard_sluck"] = {
        ["actions"] = {
            { type = "effect", sName = "ADVATK", sTargeting = "self", sApply = "action" },
            { type = "effect", sName = "ADVCHK", sTargeting = "self", sApply = "action" },
            { type = "effect", sName = "ADVSAV", sTargeting = "self", sApply = "action" },
        },
    },
    ["intoxicatedfrenzy"] = {},
    -- Monk - Way of the Four Elements
    ["discipleoftheelements"] = {
        ["multiple_actions"] = {
            ["Breath of Winter"] = {},
            ["Clench of the North Wind"] = {},
            ["Eternal Mountain Defense"] = {},
            ["Fangs of the Fire Snake"] = {},
            ["Fist of the Four Thunders"] = {},
            ["Flames of the Phoenix"] = {},
            ["Gong of the Summit"] = {},
            ["Mist Stance"] = {},
            ["Ride the Wind"] = {},
            ["River of Hungry Flame"] = {},
            ["Rush of the Gale Spirits"] = {},
            ["Sweeping Cinder Strike"] = {},
            ["Water Whip"] = {},
            ["Wave of Rolling Earth"] = {},
        },
    },
    -- Monk - Way of the Kensei
    ["pathofthekensei"] = {
        ["actions"] = {
            { type = "effect", sName = "Path of the Kensei;AC: 2", sTargeting = "self", nDuration = 1, },
            { type = "effect", sName = "Path of the Kensei;DMG: 1d4, ranged", sTargeting = "self", sApply = "action" },
        },
        ["proficiency"] = {
            choice = 1,
            choice_profs = {"calligrapher's supplies", "painter's supplies"},
        },
    },
    ["onewiththeblade"] = {
        ["actions"] = {
            { type = "effect", sName = "One with the Blade;DMGTYPE: magic", sTargeting = "self", },
            { type = "effect", sName = "One with the Blade;DMG: 1d10", sTargeting = "self", sApply = "action" },
        },
    },
    ["sharpentheblade"] = {
        ["actions"] = {
            { type = "effect", sName = "Sharpen the Blade One Point; ATK: 1; DMG: 1", sTargeting = "self", nDuration = 1, sUnits = "minute", },
            { type = "effect", sName = "Sharpen the Blade Two Points; ATK: 2; DMG: 2", sTargeting = "self", nDuration = 1, sUnits = "minute", },
            { type = "effect", sName = "Sharpen the Blade Three Points; ATK: 3; DMG: 3", sTargeting = "self", nDuration = 1, sUnits = "minute", },
        },
    },
    -- Monk - Way of the Long Death
    ["touchofdeath"] = {
        ["actions"] = {
            { type = "heal", subtype = "temp", sTargeting = "self", clauses = { { dice = { }, bonus = 0, stat = "wisdom" }, { dice = { }, bonus = 0, stat = "monk" }, }, },
        },
    },
    ["hourofreaping"] = {
        ["actions"] = {
            { type = "powersave", save = "wisdom", },
            { type = "effect", sName = "Frightened", nDuration = 1, },
        },
    },
    ["touchofthelongdeath"] = {
        ["actions"] = {
            { type = "powersave", save = "constitution", onmissdamage = "half" },
            { type = "damage", clauses = { { dice = { "d10", "d10" }, modifier = 0, dmgtype = "necrotic", }, } },
        },
    },
    -- Monk - Way of the Open Hand
    ["openhandtechnique"] = {},
    ["wholenessofbody"] = {
        ["actions"] = {
            { type = "heal", sTargeting = "self", clauses = { { dice = { }, bonus = 0, stat = "monk" }, } },
        },
    },
    ["tranquility"] = {
        ["actions"] = {
            { type = "powersave", save = "wisdom", savestat = "wisdom", },
            { type = "effect", sName = "Tranquility", sTargeting = "self", },
        },
    },
    ["quiveringpalm"] = {},
    -- Monk - Way of the Sun Soul
    ["radiantsunbolt"] = {
        ["actions"] = {
            { type = "attack", range = "R" },
            { type = "damage", clauses = { { dice = { "d4" }, modifier = 0, dmgtype = "radiant", stat = "dexterity" }, } },
        },
    },
    ["searingarcstrike"] = {},
    ["searingsunburst"] = {},
    ["sunshield"] = {
        ["actions"] = {
            { type = "damage", clauses = { { dice = { }, modifier = 5, dmgtype = "radiant", stat = "wisdom" }, } },
        },
    },
    -- Paladin
    ["divinesense"] = {
        ["actions"] = {},
        prepared = 2,
    },
    ["layonhands"] = {
        ["actions"] = {
            { type = "heal", clauses = { { dice = { }, bonus = 5, }, } },
        },
    },
    ["divinesmite"] = {
        ["actions"] = {
            { type = "effect", sName = "DMG: 2d8 radiant; IFT: TYPE(fiend,undead);DMG:1d8 radiant", sTargeting = "self", sApply = "action" },
            { type = "effect", sName = "DMG: 3d8 radiant; IFT: TYPE(fiend,undead);DMG:1d8 radiant", sTargeting = "self", sApply = "action" },
        },
    },
    ["divinehealth"] = {
        ["actions"] = {
            { type = "effect", sName = "Divine Health - immune to disease;", sTargeting = "self", },
        },
    },
    ["auraofprotection"] = {
        ["actions"] = {
            { type = "effect", sName = "Aura of Protection; SAVE: [CHA]", },
        },
    },
    ["auraofcourage"] = {
        ["actions"] = {
            { type = "effect", sName = "Aura of Courage; IMMUNE: frightened", },
        },
    },
    ["improveddivinesmite"] = {
        ["actions"] = {
            { type = "effect", sName = "DMG: 1d8 radiant, melee", sTargeting = "self", },
        },
    },
    ["cleansingtouch"] = {},
    -- Paladin - Oath of Conquest
    ["conquestoathspells"] = {
        ["spells"] = {
            innate = {
                [3] = {"armor of agathys", "command"},
                [5] = {"hold person", "spiritual weapon"},
                [9] = {"bestow curse", "fear"},
                [13] = {"dominate beast", "stoneskin"},
                [17] = {"cloudkill", "dominate person"},
            },
        },
    },
    ["channeldivinity_conquest_"] = {},
    ["auraofconquest"] = {
        ["actions"] = {
            { type = "damage", clauses = { { dice = { }, modifier = -10, dmgtype = "psychic", stat = "paladin" }, } },
            { type = "effect", sName = "Speed Reduced to Zero", },
        },
    },
    ["scornfulrebuke"] = {
        ["actions"] = {
            { type = "damage", clauses = { { dice = { }, modifier = 0, dmgtype = "psychic", stat = "charisma" }, } },
        },
    },
    ["invincibleconqueror"] = {
        ["actions"] = {
            { type = "effect", sName = "Invincible; RESIST: all", sTargeting = "self", nDuration = 1, sUnits = "minute", },
            { type = "effect", sName = "Critical on 19 or 20", sTargeting = "self", nDuration = 1, sUnits = "minute", },
        },
    },
    -- Paladin - Oath of Devotion
    ["oathspells_devotion_"] = {
        ["spells"] = {
            innate = {
                [3] = {"protection from evil and good", "sanctuary"},
                [5] = {"lesser restoration", "zone of truth"},
                [9] = {"beacon of hope", "dispel magic"},
                [13] = {"freedom of movement", "guardian of faith"},
                [17] = {"commune", "flame strike"},
            },
        },
    },
    ["channeldivinity_devotion_"] = {},
    ["auraofdevotion"] = {
        ["actions"] = {
            { type = "effect", sName = "IMMUNE: charmed", },
        },
    },
    ["purityofspirit"] = {
        ["actions"] = {
            { type = "effect", sName = "IFT: TYPE(aberration,celestial,elemental,fey,fiend,undead);GRANTDISATK:", sTargeting = "self", },
            { type = "effect", sName = "IFT: TYPE(aberration,celestial,elemental,fey,fiend,undead); IMMUNE: charmed, frightened", sTargeting = "self", },
        },
    },
    ["holynimbus"] = {
        ["actions"] = {
            { type = "damage", clauses = { { dice = { }, modifier = 10, dmgtype = "radiant", }, } },
        },
    },
    -- Paladin - Oath of Glory
    ["oathspells_glory_"] = {
        ["spells"] = {
            innate = {
                [3] = {"", ""},
                [5] = {"", ""},
                [9] = {"", ""},
                [13] = {"", ""},
                [17] = {"", ""},
            },
        },
    },
    ["channeldivinity_glory_"] = {},
    ["auraofalacrity"] = {},
    ["gloriousdefense"] = {},
    ["livinglegend"] = {},
    -- Paladin - Oath of Redemption
    ["oathspells_redemption_"] = {
        ["spells"] = {
            innate = {
                [3] = {"", ""},
                [5] = {"", ""},
                [9] = {"", ""},
                [13] = {"", ""},
                [17] = {"", ""},
            },
        },
    },
    ["channeldivinity_redemption_"] = {},
    ["auraoftheguardian"] = {},
    ["protectivespirit"] = {
        ["actions"] = {
            { type = "effect", sName = "IF: Bloodied;REGEN: [HLVL];REGEN: 1d6", sTargeting = "self", },
            { type = "heal", clauses = { { dice = { "d6" }, bonus = 0, stat = "paladin" }, } },
        },
    },
    ["emissaryofredemption"] = {
        ["actions"] = {
            { type = "effect", sName = "RESIST: all", sTargeting = "self", },
            { type = "damage", clauses = { { dice = { }, modifier = 1, dmgtype = "radiant", }, } },
        },
    },
    -- Paladin - Oath of the Ancients
    ["oathspells_ancients_"] = {
        ["spells"] = {
            innate = {
                [3] = {"", ""},
                [5] = {"", ""},
                [9] = {"", ""},
                [13] = {"", ""},
                [17] = {"", ""},
            },
        },
    },
    ["channeldivinity_ancients_"] = {},
    ["auraofwarding"] = {
        ["actions"] = {
            { type = "effect", sName = "RESIST: all", sApply = "action" },
        },
    },
    ["undyingsentinel"] = {},
    ["elderchampion"] = {
        ["actions"] = {
            { type = "effect", sName = "Elder Champion; REGEN: 10", sTargeting = "self", },
            { type = "effect", sName = "DISSAV: all", sApply = "action" },
        },
    },
    -- Paladin - Oath of the Crown
    ["oathspells_crown_"] = {
        ["spells"] = {
            innate = {
                [3] = {"", ""},
                [5] = {"", ""},
                [9] = {"", ""},
                [13] = {"", ""},
                [17] = {"", ""},
            },
        },
    },
    ["channeldivinity_crown_"] = {},
    ["divineallegiance"] = {},
    ["unyieldingspirit"] = {
        ["actions"] = {
            { type = "effect", sName = "Oath of the Crown adv to save vs stunned or paralyzed;", sTargeting = "self", },
        },
    },
    ["exaltedchampion"] = {
        ["actions"] = {
            { type = "effect", sName = "RESIST:bludgeoning,piercing,slashing,!magic;ADVSAV: wisdom; ADVDEATH", nDuration = 1, sUnits = "hour", },
        },
    },
    -- Paladin - Oath of the Watchers
    ["oathspells_watcher_"] = {
        ["spells"] = {
            innate = {
                [3] = {"", ""},
                [5] = {"", ""},
                [9] = {"", ""},
                [13] = {"", ""},
                [17] = {"", ""},
            },
        },
    },
    ["channeldivinity_watcher_"] = {},
    ["auraofthesentinel"] = {},
    ["vigilantrebuke"] = {},
    ["mortalbulwark"] = {},
    -- Paladin - Oath of Vengeance
    ["oathspells_vengeance_"] = {
        ["spells"] = {
            innate = {
                [3] = {"", ""},
                [5] = {"", ""},
                [9] = {"", ""},
                [13] = {"", ""},
                [17] = {"", ""},
            },
        },
    },
    ["channeldivinity_vengeance_"] = {},
    ["relentlessavenger"] = {},
    ["soulofvengeance"] = {},
    ["avengingangel"] = {
        ["actions"] = {
            { type = "powersave", save = "wisdom", },
            { type = "effect", sName = "frightened", nDuration = 1, sUnits = "minute", },
            { type = "effect", sName = "GRANTADVATK:", nDuration = 1, sUnits = "minute", },
        },
    },
    -- Paladin - Oathbreaker
    ["oathspells_oathbreaker_"] = {
        ["spells"] = {
            innate = {
                [3] = {"", ""},
                [5] = {"", ""},
                [9] = {"", ""},
                [13] = {"", ""},
                [17] = {"", ""},
            },
        },
    },
    ["channeldivinity_oathbreaker_"] = {},
    ["auraofhate"] = {},
    ["supernaturalresistance"] = {},
    ["dreadlord"] = {},
    -- Ranger
    ["favoredenemy"] = {
        ["actions"] = {
            { type = "effect", sName = "ADVSKILL: survival", sTargeting = "self", sApply = "action" },
            { type = "effect", sName = "ADVCHK:intelligence", sTargeting = "self", sApply = "action" },
        },
    },
    ["naturalexplorer"] = {},
    ["primalawareness"] = {},
    ["land_sstride"] = {
        ["actions"] = {
            { type = "effect", sName = "ADVSAV:all", sTargeting = "self", sApply = "action" },
        },
    },
    ["hideinplainsight"] = {
        ["actions"] = {
            { type = "effect", sName = "SKILL: 10, stealth", sTargeting = "self", sApply = "action" },
        },
    },
    ["nature_sveil_optionalreplacement_"] = {},
    ["vanish"] = {},
    ["feralsenses"] = {
        ["actions"] = {
            { type = "effect", sName = "IFT: invisible;ADVATK:", sTargeting = "self", },
        },
    },
    ["foeslayer"] = {
        ["actions"] = {
            { type = "effect", sName = "ATK:[WIS]", sTargeting = "self", sApply = "action" },
            { type = "effect", sName = "IFT: TYPE(giant,orc); DMG:[WIS]", sTargeting = "self", sApply = "action" },
        },
    },
    -- Ranger - Beast Master
    ["ranger_scompanion"] = {},
    ["exceptionaltraining"] = {},
    ["bestialfury"] = {},
    ["sharespells"] = {},
    -- Ranger - Drakewarden
    ["draconicgift"] = {},
    ["drakecompanion"] = {},
    ["bondoffangandscale"] = {},
    ["drake_sbreath"] = {},
    ["perfectedbond"] = {},
    -- Ranger - Fey Wanderer
    ["dreadfulstrikes"] = {},
    ["feywanderermagic"] = {},
    ["otherworldlyglamour"] = {},
    ["beguilingtwist"] = {},
    ["feyreinforcements"] = {},
    ["mistywanderer"] = {},
    -- Ranger - Gloom Stalker
    ["gloomstalkermagic"] = {},
    ["dreadambusher"] = {},
    ["umbralsight"] = {},
    ["ironmind"] = {},
    ["stalker_sflurry"] = {},
    ["shadowydodge"] = {},
    -- Ranger - Horizon Walker
    ["horizonwalkerspells"] = {},
    ["detectportal"] = {},
    ["planarwarrior"] = {},
    ["etherealstep"] = {},
    ["distantstrike"] = {},
    ["spectraldefense"] = {},
    -- Ranger - Hunter
    ["hunter_sprey"] = {},
    ["defensivetactics"] = {
        ["actions"] = {
            { type = "effect", sName = "AC:4", sTargeting = "self", nDuration = 1, },
        },
    },
    ["superiorhunter_sdefense"] = {
        ["actions"] = {
            { type = "effect", sName = "Evasion", sTargeting = "self", },
        },
    },
    -- Ranger - Monster Slayer
    ["monsterslyermagic"] = {},
    ["hunter_ssense"] = {},
    ["slayer_sprey"] = {},
    ["supernaturaldefense"] = {},
    ["magic_user_snemesis"] = {},
    ["slayer_scounter"] = {},
    -- Ranger - Swarmkeeper
    ["gatheredswarm"] = {},
    ["swarmkeepermagic"] = {},
    ["writhingtide"] = {},
    ["mightyswarm"] = {},
    ["swarmingdispersal"] = {},
    -- Rogue
    ["sneakattack"] = {
    	["actions"] = {
			{ type = "effect", sName = "DMG: 1d6", sTargeting = "self", sApply = "action" },
    	},
    },
    ["thieves_cant"] = {
        ["languages"] = {
            innate = {"Thieves' Cant"},
        }
    },
    ["cunningaction"] = {},
    ["uncannydodge"] = {},
    ["evasion"] = {},
    ["reliabletalent"] = {},
    ["blindsense"] = {},
    ["slipperymind"] = {},
    ["elusive"] = {},
    ["strokeofluck"] = {},
    -- Rogue - Arcane Trickster
    ["magehandlegerdemain"] = {},
    ["magicalambush"] = {},
    ["versatiletrickster"] = {},
    ["spellthief"] = {},
    -- Rogue - Assassin
    ["bonusproficiencies_assassin_"] = {
        ["proficiency"] = {
            innate = {"disguise kit", "poisoner's kit"},
        },
    },
    ["assassinate"] = {},
    ["infiltrationexpertise"] = {},
    ["impostor"] = {},
    ["deathstrike"] = {},
    -- Rogue - Inquisitive
    ["earfordeceit"] = {},
    ["eyefordetail"] = {},
    ["insightfulfighting"] = {},
    ["steadyeye"] = {},
    ["unerringeye"] = {},
    ["eyeforweakness"] = {},
    -- Rogue - Mastermind
    ["masterofintrigue"] = {
        ["proficiency"] = {
            choice = 1,
            choice_profs = {"disguise kit", "forgery kit", "gaming set"},
        },
        ["languages"] = {
            choice = 1,
            choice_languages = {"any"},
        },
    },
    ["masteroftactics"] = {},
    ["insightfulmanipulator"] = {},
    ["misdirection"] = {},
    ["soulofdeceit"] = {},
    -- Rogue - Phantom
    ["whispersofthedead"] = {},
    ["wailsfromthegrave"] = {},
    ["tokensofthedeparted"] = {},
    ["ghostwalk"] = {},
    ["death_sfriend"] = {},
    -- Rogue - Scout
    ["skirmisher"] = {},
    ["survivalist"] = {
        ["skills"] = {
            innate = {"nature", "survival"},
        },
    },
    ["superiormobility"] = {},
    ["ambushmaster"] = {},
    ["suddenstrike"] = {},
    -- Rogue - Soulknife
    ["psionicpower"] = {},
    ["psychicblades"] = {},
    ["soulblades"] = {},
    ["psychicveil"] = {},
    ["rendmind"] = {},
    -- Rogue - Swashbuckler
    ["fancyfootwork"] = {},
    ["rakishaudacity"] = {},
    ["panache"] = {},
    ["elegantmaneuver"] = {},
    ["masterduelist"] = {},
    -- Rogue - Thief
    ["fasthands"] = {},
    ["second_storywork"] = {},
    ["supremesneak"] = {},
    ["usemagicdevice"] = {},
    ["thief_sreflexes"] = {},
    -- Sorcerer
    ["fontofmagic"] = {},
    -- Sorcerer - Aberrant Mind
    ["psionicspells"] = {},
    ["telepathicspeech"] = {},
    ["psionicsorcery"] = {},
    ["psychicdefenses"] = {},
    ["revelationinflesh"] = {},
    ["warpingimplosion"] = {},
    -- Sorcerer - Clockwork Soul
    ["clockworkmagic"] = {},
    ["restorebalance"] = {},
    ["bastionoflaw"] = {},
    ["tranceoforder"] = {},
    ["clockworkcavalcade"] = {},
    -- Sorcerer - Divine Soul
    ["divinemagic"] = {},
    ["favoredbythegods"] = {},
    ["empoweredhealing"] = {},
    ["otherworldlywings"] = {},
    ["unearthlyrecovery"] = {},
    -- Sorcerer - Draconic Bloodline
    ["dragonancestor"] = {},
    ["draconicresilience"] = {},
    ["elementalaffinity"] = {},
    ["dragonwings"] = {},
    ["draconicpresence"] = {},
    -- Sorcerer - Shadow Magic
    ["eyesofthedark"] = {},
    ["strengthofthegrave"] = {},
    ["houndofillomen"] = {},
    ["shadowwalk"] = {},
    ["umbralform"] = {},
    -- Sorcerer - Storm Sorcery
    ["windspeaker"] = {},
    ["tempestuousmagic"] = {},
    ["heartofthestorm"] = {},
    ["stormguide"] = {},
    ["storm_sfury"] = {},
    ["windsoul"] = {},
    -- Sorcerer - Wild Magic
    ["wildmagicsurge"] = {},
    ["tidesofchaos"] = {},
    ["bendluck"] = {},
    ["controlledchaos"] = {},
    ["spellbombardment"] = {},
    -- Warlock
    -- Warlock - Hexblade
    ["expandedspellslist_hexblade_"] = {},
    ["hexblade_scurse"] = {},
    ["hexwarrior"] = {
        ["proficiency"] = {
            innate = {"medium armor", "shields", "martial weapons"},
        },
    },
    ["accursedspecter"] = {},
    ["armorofhexes"] = {},
    ["masterofhexes"] = {},
    -- Warlock - The Archfey
    ["expandedspelllist_archfey_"] = {},
    ["feypresence"] = {},
    ["msityescape"] = {},
    ["beguilingdefenses"] = {},
    ["darkdelirium"] = {},
    -- Warlock - The Celestial
    ["expandedspelllist_celestial_"] = {},
    ["bonuscantrips"] = {},
    ["healinglight"] = {},
    ["radiantsoul"] = {},
    ["celestialresilience"] = {},
    ["searingvengeance"] = {},
    -- Warlock - The Fathomless
    ["expandedspelllist_fathomless_"] = {},
    ["tentacleofthedeeps"] = {},
    ["giftofthesea"] = {},
    ["oceanicsoul"] = {},
    ["guardiancoil"] = {},
    ["graspingtentacles"] = {},
    ["fathomlesplunge"] = {},
    -- Warlock - The Fiend
    ["expandedspelllist_fiend_"] = {},
    ["darkone_sblessing"] = {},
    ["darkone_sownluck"] = {},
    ["fiendishresilience"] = {},
    ["hurlthroughhell"] = {},
    -- Warlock - The Genie
    ["expandedspelllist_genie_"] = {},
    ["genie_svessel"] = {},
    ["elementalgift"] = {},
    ["sanctuary vessel"] = {},
    ["limitedwish"] = {},
    -- Warlock - The Great Old One
    ["expandedspelllist_greatoldone_"] = {},
    ["awakenedmind"] = {},
    ["entropicward"] = {},
    ["thoughtshield"] = {},
    ["createthrall"] = {},
    -- Warlock - The Undead
    ["expandedspelllist_theundead_"] = {},
    ["formofdread"] = {},
    ["gravetouched"] = {},
    ["necrotichusk"] = {},
    ["spiritprojection"] = {},
    -- Warlock - The Undying
    ["expandedspelllist_undying_"] = {},
    ["amongthedead"] = {},
    ["defydeath"] = {},
    ["undyingnature"] = {},
    ["indestructiblelife"] = {},
    -- Wizard
    -- Wizard - Bladesinging
    ["bladesong"] = {},
    ["songofdefense"] = {},
    ["songofvictory"] = {},
    -- Wizard - Chronurgy Magic
    ["chronalshift"] = {},
    ["temporalawareness"] = {},
    ["momentarystatis"] = {},
    ["arcaneabeyance"] = {},
    ["convergentfuture"] = {},
    -- Wizard - Graviturgy Magic
    ["adjustdensity"] = {},
    ["gravitywell"] = {},
    ["violentattraction"] = {},
    ["eventhorizon"] = {},
    -- Wizard - Order of Scribes
    ["wizardlyquill"] = {},
    ["awakenedspellbook"] = {},
    ["manifestmind"] = {},
    ["masterscrivener"] = {},
    ["onewiththeword"] = {},
    -- Wizard - School of Abjuration
    ["abjurationsavant"] = {},
    ["arcaneward"] = {},
    ["projectedward"] = {},
    ["improvedabjuration"] = {},
    ["spellresistance"] = {},
    -- Wizard - School of Conjuration
    ["conjurationsavant"] = {},
    ["minorconjuration"] = {},
    ["benigntransposition"] = {},
    ["focusedconjuration"] = {},
    ["durablesummons"] = {},
    -- Wizard - School of Divination
    ["divinationsavant"] = {},
    ["portent"] = {},
    ["expertdivination"] = {},
    ["thethirdeye"] = {},
    ["greaterportent"] = {},
    -- Wizard - School of Enchantment
    ["enchantementsavant"] = {},
    ["hypnoticgaze"] = {},
    ["instinctivecharm"] = {},
    ["splitenchantment"] = {},
    ["altermemories"] = {},
    -- Wizard - School of Evocation
    ["evocationsavant"] = {},
    ["sculptspells"] = {},
    ["potentcantrip"] = {},
    ["empoweredevocation"] = {},
    ["overchannel"] = {},
    -- Wizard - School of Illusion
    ["illusionsavant"] = {},
    ["imporvedminorillusion"] = {},
    ["malleableillusions"] = {},
    ["illusoryself"] = {},
    ["illusoryreality"] = {},
    -- Wizard - School of Necromancy
    ["necromancysavant"] = {},
    ["grimharvest"] = {},
    ["undeadthralls"] = {},
    ["inuredtoundeath"] = {},
    ["commandundead"] = {},
    -- Wizard - School of Transmutation
    ["transmutationsavant"] = {},
    ["minoralchemy"] = {},
    ["transmuter_sstone"] = {},
    ["shapechanger"] = {},
    ["mastertransmuter"] = {},
    -- Wizard - School of War Magic
    ["arcanedeflection"] = {},
    ["tracticalwit"] = {},
    ["powersurge"] = {},
    ["durablemagic"] = {},
    ["deflectingshroud"] = {},
    --
    -- Races
    --
    -- Dragonborn
    ["reddragonbornbreathweapon"] = {
        ["actions"] = {
            { type = "powersave", save = "dexterity", savestat = "constitution", onmissdamage = "half" },
            { type = "damage", clauses = { { dice = { "d6", "d6" }, modifier = 0, dmgtype = "fire", }, } },
        },
    },
    ["reddragonbornresistance"] = {
        ["actions"] = {
            { type = "effect", sName = "Draconic Resistance; RESIST: fire;", sTargeting = "self", },
        },
    },
    ["bluedragonbornbreathweapon"] = {
        ["actions"] = {
            { type = "powersave", save = "dexterity", savestat = "constitution", onmissdamage = "half" },
            { type = "damage", clauses = { { dice = { "d6", "d6" }, modifier = 0, dmgtype = "lightning", }, } },
        },
    },
    ["bluedragonbornresistance"] = {
        ["actions"] = {
            { type = "effect", sName = "Draconic Resistance; RESIST: lightning;", sTargeting = "self", },
        },
    },
    ["greendragonbornbreathweapon"] = {
        ["actions"] = {
            { type = "powersave", save = "constitution", savestat = "constitution",  onmissdamage = "half" },
            { type = "damage", clauses = { { dice = { "d6", "d6" }, modifier = 0, dmgtype = "poison", }, } },
        },
    },
    ["greendragonbornresistance"] = {
        ["actions"] = {
            { type = "effect", sName = "Draconic Resistance; RESIST: poison;", sTargeting = "self", },
        },
    },
    ["bronzedragonbornbreathweapon"] = {
        ["actions"] = {
            { type = "powersave", save = "dexterity", savestat = "constitution",  onmissdamage = "half" },
            { type = "damage", clauses = { { dice = { "d6", "d6" }, modifier = 0, dmgtype = "lightning", }, } },
        },
    },
    ["bronzedragonbornresistance"] = {
        ["actions"] = {
            { type = "effect", sName = "Draconic Resistance; RESIST: lightning;", sTargeting = "self", },
        },
    },
    ["blackdragonbornbreathweapon"] = {
        ["actions"] = {
            { type = "powersave", save = "dexterity", savestat = "constitution",  onmissdamage = "half" },
            { type = "damage", clauses = { { dice = { "d6", "d6" }, modifier = 0, dmgtype = "acid", }, } },
        },
    },
    ["blackdragonbornresistance"] = {
        ["actions"] = {
            { type = "effect", sName = "Draconic Resistance; RESIST: acid;", sTargeting = "self", },
        },
    },
    ["whitedragonbornbreathweapon"] = {
        ["actions"] = {
            { type = "powersave", save = "constitution", savestat = "constitution",  onmissdamage = "half" },
            { type = "damage", clauses = { { dice = { "d6", "d6" }, modifier = 0, dmgtype = "cold", }, } },
        },
    },
    ["whitedragonbornresistance"] = {
        ["actions"] = {
            { type = "effect", sName = "Draconic Resistance; RESIST: cold;", sTargeting = "self", },
        },
    },
    ["golddragonbornbreathweapon"] = {
        ["actions"] = {
            { type = "powersave", save = "dexterity", savestat = "constitution",  onmissdamage = "half" },
            { type = "damage", clauses = { { dice = { "d6", "d6" }, modifier = 0, dmgtype = "fire", }, } },
        },
    },
    ["golddragonbornresistance"] = {
        ["actions"] = {
            { type = "effect", sName = "Draconic Resistance; RESIST: fire;", sTargeting = "self", },
        },
    },
    ["copperdragonbornbreathweapon"] = {
        ["actions"] = {
            { type = "powersave", save = "dexterity", savestat = "constitution",  onmissdamage = "half" },
            { type = "damage", clauses = { { dice = { "d6", "d6" }, modifier = 0, dmgtype = "acid", }, } },
        },
    },
    ["copperdragonbornresistance"] = {
        ["actions"] = {
            { type = "effect", sName = "Draconic Resistance; RESIST: acid;", sTargeting = "self", },
        },
    },
    ["brassdragonbornbreathweapon"] = {
        ["actions"] = {
            { type = "powersave", save = "dexterity", savestat = "constitution",  onmissdamage = "half" },
            { type = "damage", clauses = { { dice = { "d6", "d6" }, modifier = 0, dmgtype = "fire", }, } },
        },
    },
    ["brassdragonbornresistance"] = {
        ["actions"] = {
            { type = "effect", sName = "Draconic Resistance; RESIST: fire;", sTargeting = "self", },
        },
    },
    ["silverdragonbornbreathweapon"] = {
        ["actions"] = {
            { type = "powersave", save = "constitution", savestat = "constitution",  onmissdamage = "half" },
            { type = "damage", clauses = { { dice = { "d6", "d6" }, modifier = 0, dmgtype = "cold", }, } },
        },
    },
    ["silverdragonbornresistance"] = {
        ["actions"] = {
            { type = "effect", sName = "Draconic Resistance; RESIST: cold;", sTargeting = "self", },
        },
    },
    --[[
        Sunlight Sensitivity
        Master of Locks
        Duergar Resilience
        Fey Ancestry
        Gift of the Shadows
        Slip Into Shadow
        Gnome Cunning
        Artificer's Lore
        Stone Camouflage
        Relentless Endurace
        Savage Attacks
        Brave
        Lucky
        Medical Intuition
        Ever Hospitable
        Medical Intuition
        Healing Touch
        Stout Resilience
        Hellish Resistance
        Change Appearance
        Unsettling Visage
        Deductive Intuition
        Windwright's Intuition
        Storm's Blessing
        Hunter's Intuition
        Imprint Prey
        Wild Intuition
        Artisan's Intuition
        Spellsmith
        Intuitive Motion
        Shared Passage
        Sentinel's Intuition
        Psychic Glamour
        Shifting
        Mark the Scent
        Shifting Feature (need to check text)
        Warforged Resilience
        Integrated Tool
        Iron Fists
        Radiant Soul
        Built for Success
        Mechanical Nature
        True Life
        Charge
        Hooves
        Chromatic Warding
        Vampiric Bite
        Gem Flight
        Hippo Build
        Fey Resilience
        Fortune from the Many
        Draconic Legacy
        Draconic Roar
        Keen Smell
        Loxodon Bravery
        Stonecunning
        Horns
        Hammering Horns
        Amorphous
        Natural Resilience
        Hare-Trigger
        Lucky Footwork
        Rabbit Hop
        Deathless Nature
        Knowledge from a Past Life
        Acid Spit
        Grappling Appendages
        Carapace
        Chameleon Carapace
        Vedalken Dispassion
        Bite
        Lashing Tail
        Stone's Endurance
        Claws
        Shell Defense
        Echoing Soul
        Celestial Legacy
        Mountain Born
        Gathered Whispers
        Living Shadow
        Mist Walker
        Second Skin
        Symbiotic Being
        Touch of Death
        Watchers
    --]]

    --[[
    ["championchallenge_crown_"] = {
        ["actions"] = {
            { type = "powersave", save = "wisdom", },
        },
    },
    ["turnthetide_crown_"] = {
        ["actions"] = {
            { type = "heal", clauses = { { dice = { "d6" }, bonus = 0, stat = "charisma" }, } },
        },
    },
    ["sacredweapon_devotion_"] = {
        ["actions"] = {
            { type = "effect", sName = "Sacred Weapon; ATK: [CHA];  DMGTYPE: magic", sTargeting = "self", nDuration = 1, sUnits = "minute", },
        },
    },
    ["turntheunholy_devotion_"] = {
        ["actions"] = {
            { type = "powersave", save = "wisdom", },
            { type = "effect", sName = "turned", nDuration = 1, sUnits = "minute", },
        },
    },

    ["nature_swrath_acients_"] = {
        ["actions"] = {
            { type = "powersave", save = "strength", },
            { type = "powersave", save = "dexterity", },
            { type = "effect", sName = "restrained", },
        },
    },
    ["turnthefaithless_ancients_"] = {
        ["actions"] = {
            { type = "powersave", save = "wisdom", },
            { type = "effect", sName = "turned", nDuration = 1, sUnits = "minute", },
        },
    },

    ["abjureenemy_vengeance_"] = {
        ["actions"] = {
            { type = "powersave", save = "wisdom", },
            { type = "effect", sName = "frightened", nDuration = 1, sUnits = "minute", },
            { type = "effect", sName = "IF: TYPE(fiend,undead);DISSAV:", sApply = "action" },
        },
    },
    ["vowofenmity_vengeance_"] = {
        ["actions"] = {
            { type = "effect", sName = "ADVATK:", sTargeting = "self", nDuration = 1, sUnits = "minute", },
        },
    },

    ["conqueringpresence"] = {
        ["actions"] = {
            { type = "powersave", save = "wisdom", },
            { type = "effect", sName = "Frightened", nDuration = 1, sUnits = "minute", },
        },
    },
    ["guidedstrike"] = {
        ["actions"] = {
            { type = "effect", sName = "ATK:10", sTargeting = "self", sApply = "action" },
        },
    },

    ["emmissaryofpeace"] = {
        ["actions"] = {
            { type = "effect", sName = "SKILL: 5, persuasion", sTargeting = "self", nDuration = 10, sUnits = "minute", },
        },
    },
    ["rebuketheviolent"] = {
        ["actions"] = {
            { type = "powersave", save = "wisdom", },
            { type = "damage", clauses = { { dice = { }, modifier = 1, dmgtype = "radiant", }, } },
        },
    },
    --]]
}

