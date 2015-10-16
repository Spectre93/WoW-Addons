-- Author      : Daniel, Riraeyi@MagtheridonEU
-- Create Date : 21/07/2014
-- Based on http://www.curse.com/addons/wow/shadow-priest-dot-timer by Bathral

local defaultdamageweight = .17;
local defaultmasteryweight = .62;
local defaultcritweight = .54;
local defaulthasteweight = .64;
local defaultspellpowerweight = .79;

local defaultOffsetAgony = 12000;	--36-24=12
local defaultOffsetCorruption = 8000;	--26-18=8
local defaultOffsetUnstableAffliction = 5800; --20-13+0.8=7
local defaultOffsetHaunt = 3150; --2+1.15

local maxentries = 6;
local defaultbufftable = {}
offsets = {0, 0, 0, 0, 0}
local firstLoadPerGameStart = true;

parentaddon = {};

table.insert(defaultbufftable, {"Power Torrent", "Int", 500, 1});
table.insert(defaultbufftable, {"Velocity", "Haste", 3278, 1});
table.insert(defaultbufftable, {"Inner Brilliance", "Int", 2866, 1});               -- Light of the Cosmos
table.insert(defaultbufftable, {"Blessing of the Celestials", "Int", 3027, 1});     -- Reliq of Yu'lon

local defaultclbufftable = {}

--class abilities
table.insert(defaultclbufftable, {32182, "Haste", 30, 1});      -- Heroism
table.insert(defaultclbufftable, {2825, "Haste", 30, 1});       -- Bloodlust
table.insert(defaultclbufftable, {80353, "Haste", 30, 1});      -- Time Warp
table.insert(defaultclbufftable, {90355, "Haste", 30, 1});      -- Ancient Hysteria
table.insert(defaultclbufftable, {114207, "Crit", 12000, 1});	-- Skullbanner
table.insert(defaultclbufftable, {57934, "Damage", 15, 1});		-- Tricks of the Trade (Rogue)

--race abilities
table.insert(defaultclbufftable, {26297, "Haste", 20, 1});      -- Berserking

--profession abilities
table.insert(defaultclbufftable, {96230, "Int", 1920, 1});      -- Synapse Spring
table.insert(defaultclbufftable, {121279, "Haste", 2880, 1});   -- Lifeblood
table.insert(defaultclbufftable, {125484, "Int", 2000, 1});     -- Lightweave Embroidery

--manufactured items
table.insert(defaultclbufftable, {146555, "Haste", 25, 1});     -- Drums of Rage
table.insert(defaultclbufftable, {105702, "Int", 4000, 1});     -- Potion of the Jade Serpent

--weapon enchants
table.insert(defaultclbufftable, {104510, "Mastery", 1500, 1}); -- Windsong Mastery
table.insert(defaultclbufftable, {104423, "Haste", 1500, 1});   -- Windsong Haste
table.insert(defaultclbufftable, {104509, "Crit", 1500, 1});    -- Windsong Crit
table.insert(defaultclbufftable, {104993, "Int", 1650, 1});     -- Jade Spirit

--warlock abilities
table.insert(defaultclbufftable, {113860, "Haste", 30, 1});      -- Dark Soul: Misery

--legendary stuff
table.insert(defaultclbufftable, {137590, "Haste", 30, 1});     -- Tempus Repit (Legendary Meta Gem Proc)

--boss ability buffs
table.insert(defaultclbufftable, {140741, "Damage", 100, 1});	-- Primal Nutriment in ToT 6.Boss
table.insert(defaultclbufftable, {118977, "Damage", 60, 1});	-- Fearless in ToeS 4. Boss(Sha)

function OptionsFrame_OnLoad(panel)	
    -- Set the name for the Category for the Panel
	panel:RegisterEvent("ADDON_LOADED");
	panel:RegisterEvent("PLAYER_LOGOUT");
	panel:RegisterEvent("SPELLS_CHANGED");	
    panel.name = "AffliLockDoTTimer";

    -- When the player clicks okay, run this function.
    panel.okay = function (self) saveVariables(); end;

    -- When the player clicks cancel, run this function.
    panel.cancel = function (self) fillBoxesWithSavedVariables();  end;

	--Build the list of buttons in the table.
	local entry = CreateFrame("Button", "$parentEntry1", BuffListTable, "BuffListEntry");
	entry:SetID(1);
	entry:SetPoint("TOPLEFT", 4, -32);

	for i = 2, maxentries do
		local entry = CreateFrame("Button", "$parentEntry" .. i, BuffListTable, "BuffListEntry");
		entry:SetID(i);
		entry:SetPoint("TOP", "$parentEntry" .. (i - 1), "BOTTOM");
	end

    -- Add the panel to the Interface Options
    InterfaceOptions_AddCategory(panel);
    OptionsFrame:Hide();
    parentaddon = panel;
end

function OptionsFrame_OnEvent(self, event, ...)
	local arg1 = ...;
	if (event == "SPELLS_CHANGED" and firstLoadPerGameStart) then
	if(not isAffliWarlock()) then return; end
	--if (event == "ADDON_LOADED" and arg1 == "AffliLockDoTTimer") then
		if(not HasteWeight) then
			HasteWeight = defaulthasteweight;
			DEFAULT_CHAT_FRAME:AddMessage("[AffliLockDoTTimer] Default HasteWeight Loaded.");
		end
		if(not CritWeight) then
			CritWeight = defaultcritweight;
			DEFAULT_CHAT_FRAME:AddMessage("[AffliLockDoTTimer] Default CritWeight Loaded.");
		end
		if(not MasteryWeight) then
			MasteryWeight = defaultmasteryweight;
			DEFAULT_CHAT_FRAME:AddMessage("[AffliLockDoTTimer] Default MasteryWeight Loaded.");
		end
		if(not DamageWeight) then
			DamageWeight = defaultdamageweight;
			DEFAULT_CHAT_FRAME:AddMessage("[AffliLockDoTTimer] Default DamageWeight Loaded.");
		end
		if(not SpellpowerWeight) then
			SpellpowerWeight = defaultspellpowerweight;
			DEFAULT_CHAT_FRAME:AddMessage("[AffliLockDoTTimer] Default SpellpowerWeight Loaded.");
		end
		if(not offsetAgony) then
			offsetAgony = defaultOffsetAgony;
			DEFAULT_CHAT_FRAME:AddMessage("[AffliLockDoTTimer] Default Offset for Agony Loaded.");
		end
		if(not offsetCorruption) then
			offsetCorruption = defaultOffsetCorruption;
			DEFAULT_CHAT_FRAME:AddMessage("[AffliLockDoTTimer] Default Offset for Corruption Loaded.");
		end
		if(not offsetUnstableAffliction) then
			offsetUnstableAffliction = defaultOffsetUnstableAffliction;
			DEFAULT_CHAT_FRAME:AddMessage("[AffliLockDoTTimer] Default Offset for Unstable Affliction Loaded.");
		end
		if(not offsetHaunt) then
			offsetHaunt = defaultOffsetHaunt;
			DEFAULT_CHAT_FRAME:AddMessage("[AffliLockDoTTimer] Default Offset for Haunt Loaded.");
		end
		if(not BuffList) then
			BuffList = defaultbufftable;
			DEFAULT_CHAT_FRAME:AddMessage("[AffliLockDoTTimer] Default BuffList Loaded.");
		end

		offsets = {offsetAgony, offsetCorruption, offsetUnstableAffliction, 0, offsetHaunt};
		ClassBuffList = defaultclbufftable;		

		fillBoxesWithSavedVariables();
		BuffListBoxUpdate();

		firstLoadPerGameStart = false;
		DEFAULT_CHAT_FRAME:AddMessage("[AffliLockDoTTimer] Stat weights loaded.");
	elseif (event == "PLAYER_LOGOUT") then
		saveVariables();
	end
end

function ButtonAddBuff_OnClick()
	-- Find the buff in the list
	local selection = nil;

	for i = 1, #BuffList do
		local entry = BuffList[i]
		if (entry) then
			if (entry[1] == EditBoxAddBuffName:GetText()) then
				selection = entry;
			end
		end
	end

	if (not selection) then
		-- If we have data, add the buff to the list.
		local stat = EditBoxAddStat:GetText();
		local buff = EditBoxAddBuffName:GetText();
		local modifier = EditBoxAddModifier:GetNumber();
		local maxstacks = EditBoxAddMaxStacks:GetNumber();

		if (stat and buff and modifier and maxstacks) then
			if (string.lower(stat) == "int" or
				string.lower(stat) == "mastery" or
				string.lower(stat) == "haste" or
				string.lower(stat) == "crit" or
				string.lower(stat) == "spellpower" or
				string.lower(stat) == "damage") then
				table.insert(BuffList, {buff, stat, modifier, maxstacks});
    			sort(BuffList, function(a,b) return a[1] < b[1] end);
				FontStringError:SetText("Added...");
			else
				FontStringError:SetText("Stat must be one of: int, mastery, haste, crit, spellpower or damage.");
			end
		else
			FontStringError:SetText("All fields are required to add a buff. Modifier and maxstacks must be numeric.");
		end
	else
		FontStringError:SetText("Buff already exists.  Remove it first.");
	end

	EditBoxAddStat:SetText("");
	EditBoxAddBuffName:SetText("");
	EditBoxAddModifier:SetText("");
	EditBoxAddMaxStacks:SetText("");
	BuffListBoxUpdate();
end
 
function BuffListBoxUpdate(self)
	--DEFAULT_CHAT_FRAME:AddMessage("Entered the BuffListBoxUpdate function");
	--DEFAULT_CHAT_FRAME:AddMessage("Updating frames with data");
	for i = 1, maxentries do
		local entry = BuffList[i + BuffListScrollFrame.offset];
		local frame = getglobal("BuffListTableEntry" .. i);

		if (entry) then
			frame:Show();
			getglobal(frame:GetName() .. "Name"):SetText(entry[1]);
			getglobal(frame:GetName() .. "Stat"):SetText(entry[2]);
			if (entry[2] == "Damage") then
				getglobal(frame:GetName() .. "Modifier"):SetText(entry[3] .. "%");
			else
				getglobal(frame:GetName() .. "Modifier"):SetText(entry[3]);
			end
			getglobal(frame:GetName() .. "MaxStacks"):SetText(entry[4]);
		else
			frame:Hide();
		end
	end
	
	FauxScrollFrame_Update(BuffListScrollFrame, #BuffList, maxentries, 24, "BuffListTableEntry", 464, 480, BuffListTableHeaderMaxStacks, 88, 104);
end

function BuffListScrollFrame_OnVerticalScroll(self, value, itemHeight, updateFunction)
	local scrollbar = getglobal(self:GetName() .. "ScrollBar");
	scrollbar:SetValue(value);
	self.offset = floor((value / itemHeight) + 0.5);
	BuffListBoxUpdate(self);
end

function ScrollFrameTemplate_OnMouseWheel(self, value, scrollBar)
	scrollBar = scrollBar or getglobal(self:GetName() .. "ScrollBar");
	if (value > 0) then
		scrollBar:SetValue(scrollBar:GetValue() - (scrollBar:GetHeight() /2));
	else
		scrollBar:SetValue(scrollBar:GetValue() + (scrollBar:GetHeight() /2));
	end
end

function BuffListEntry_OnClick(self)
	local id = self:GetID();
	local entry = BuffList[id + BuffListScrollFrame.offset];

	if (entry) then
		table.remove(BuffList, id + BuffListScrollFrame.offset);
		FontStringError:SetText("Removed: " .. entry[1] );
	end

	BuffListBoxUpdate();
end

function resetStatWeights()
	--set the Weights to the defaults
	HasteWeight = defaulthasteweight;
	CritWeight = defaultcritweight;
	MasteryWeight = defaultmasteryweight;
	DamageWeight = defaultdamageweight;
	SpellpowerWeight = defaultspellpowerweight;

	--Set the Edit Boxes to the new values
	EditBoxHaste:SetText(string.format("%1.2f", HasteWeight));
	EditBoxCrit:SetText(string.format("%1.2f", CritWeight));
	EditBoxMastery:SetText(string.format("%1.2f", MasteryWeight));
	EditBoxDamage:SetText(string.format("%1.2f", DamageWeight));
	EditBoxSpellPower:SetText(string.format("%1.2f", SpellpowerWeight));

	FontStringError:SetText("Stat weights reset to defaults.");
end

function resetOffsets()
	--set the offsets to the defaults	
	offsetAgony = defaultOffsetAgony;
	offsetCorruption = defaultOffsetCorruption;
	offsetUnstableAffliction = defaultOffsetUnstableAffliction;
	offsetHaunt = defaultOffsetHaunt;

	--Set the Edit Boxes to the new values	
	EditBoxOffsetAgony:SetText(offsetAgony);
	EditBoxOffsetCorruption:SetText(offsetCorruption);
	EditBoxOffsetUnstableAffliction:SetText(offsetUnstableAffliction);
	EditBoxOffsetHaunt:SetText(offsetHaunt);

	FontStringError:SetText("Offsets reset to defaults.");
end

function saveVariables()
	HasteWeight = EditBoxHaste:GetNumber();
	CritWeight = EditBoxCrit:GetNumber();
	MasteryWeight = EditBoxMastery:GetNumber();
	DamageWeight = EditBoxDamage:GetNumber();
	SpellpowerWeight = EditBoxSpellPower:GetNumber();
	
	offsetAgony = EditBoxOffsetAgony:GetNumber();	
	offsetCorruption = EditBoxOffsetCorruption:GetNumber();
	offsetUnstableAffliction = EditBoxOffsetUnstableAffliction:GetNumber();
	offsetHaunt = EditBoxOffsetHaunt:GetNumber();
	
	offsets = {offsetAgony, offsetCorruption, offsetUnstableAffliction, 0, offsetHaunt};
	DEFAULT_CHAT_FRAME:AddMessage("[AffliLockDoTTimer] Variables Saved.");
end

function fillBoxesWithSavedVariables()
	EditBoxHaste:SetText(string.format("%1.2f", HasteWeight));
	EditBoxCrit:SetText(string.format("%1.2f", CritWeight));
	EditBoxMastery:SetText(string.format("%1.2f", MasteryWeight));
	EditBoxDamage:SetText(string.format("%1.2f", DamageWeight));
	EditBoxSpellPower:SetText(string.format("%1.2f", SpellpowerWeight));
	
	EditBoxOffsetAgony:SetText(string.format("%d", offsetAgony));			
	EditBoxOffsetCorruption:SetText(string.format("%d", offsetCorruption));	
	EditBoxOffsetUnstableAffliction:SetText(string.format("%d", offsetUnstableAffliction));
	EditBoxOffsetHaunt:SetText(string.format("%d", offsetHaunt));	
end