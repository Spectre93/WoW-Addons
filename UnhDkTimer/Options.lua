-- Author      : Daniel Riraeyi@MagtheridonEU
-- Create Date : 29/07/2014

local defaultdamageweight = 1.58;
local defaultmasteryweight = .56;
local defaultcritweight = .62;
local defaulthasteweight = .52;
local defaultAttackPowerweight = .33;

local defaultOffsetPlagues = 7000;

local firstLoadPerGameStart = true;
local maxentries = 6;
local defaultbufftable = {}

parentaddon = {};

table.insert(defaultbufftable, {"Velocity", "Haste", 3278, 1});

local defaultclbufftable = {}

--class abilities
table.insert(defaultclbufftable, {32182, "Haste", 30, 1});      -- Heroism
table.insert(defaultclbufftable, {2825, "Haste", 30, 1});       -- Bloodlust
table.insert(defaultclbufftable, {80353, "Haste", 30, 1});      -- Time Warp
table.insert(defaultclbufftable, {90355, "Haste", 30, 1});      -- Ancient Hysteria
table.insert(defaultclbufftable, {114207, "Crit", 12000, 1});	-- Skullbanner
table.insert(defaultclbufftable, {57934, "Damage", 15, 1});		-- Tricks of the Trade (Rogue)
table.insert(defaultclbufftable, {49016, "Damage", 10, 1});      -- Unholy Frenzy (Unholy Death Knight)

--race abilities
table.insert(defaultclbufftable, {26297, "Haste", 20, 1});      -- Berserking

--profession abilities
table.insert(defaultclbufftable, {96230, "Strength", 1920, 1});      -- Synapse Spring
table.insert(defaultclbufftable, {121279, "Haste", 2880, 1});   	-- Lifeblood
table.insert(defaultclbufftable, {55777, "AttackPower", 4000, 1});  -- Swordguard Embroidery

--manufactured items
table.insert(defaultclbufftable, {146555, "Haste", 25, 1});     -- Drums of Rage
table.insert(defaultclbufftable, {76095, "Strength", 4000, 1});  -- Potion of Mogu Power

--weapon enchants
table.insert(defaultclbufftable, {104510, "Mastery", 1500, 1}); -- Windsong Mastery
table.insert(defaultclbufftable, {104423, "Haste", 1500, 1});   -- Windsong Haste
table.insert(defaultclbufftable, {104509, "Crit", 1500, 1});    -- Windsong Crit
table.insert(defaultclbufftable, {104434, "Strength", 1650, 1}); -- Dancing Steel

--death knight
table.insert(defaultclbufftable, {53365, "Strength", 15, 1});	-- Unholy Strength effect from Rune of the Fallen Crusader
--table.insert(defaultclbufftable, {144901, "Mastery", 15, 10});	--Death Shroud	

--boss ability buffs
table.insert(defaultclbufftable, {140741, "Damage", 100, 1});	-- Primal Nutriment in ToT 6.Boss
table.insert(defaultclbufftable, {118977, "Damage", 60, 1});	-- Fearless in ToeS 4. Boss(Sha)

function OptionsFrame_OnLoad(panel)	
    -- Set the name for the Category for the Panel
	panel:RegisterEvent("ADDON_LOADED");
	panel:RegisterEvent("PLAYER_LOGOUT");
	panel:RegisterEvent("SPELLS_CHANGED");
    panel.name = "UnhDkTimer";

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
	--if (event == "ADDON_LOADED" and arg1 == "UnhDkTimer") then
	if (event == "SPELLS_CHANGED" and firstLoadPerGameStart) then
	if(not isUnhDk()) then return; end
		if(not HasteWeight) then
			HasteWeight = defaulthasteweight;
			DEFAULT_CHAT_FRAME:AddMessage("[UnhDkTimer] Default HasteWeight Loaded.");
		end
		if(not CritWeight) then
			CritWeight = defaultcritweight;
			DEFAULT_CHAT_FRAME:AddMessage("[UnhDkTimer] Default CritWeight Loaded.");
		end
		if(not MasteryWeight) then
			MasteryWeight = defaultmasteryweight;
			DEFAULT_CHAT_FRAME:AddMessage("[UnhDkTimer] Default MasteryWeight Loaded.");
		end
		if(not DamageWeight) then
			DamageWeight = defaultdamageweight;
			DEFAULT_CHAT_FRAME:AddMessage("[UnhDkTimer] Default DamageWeight Loaded.");
		end
		if(not AttackPowerWeight) then
			AttackPowerWeight = defaultAttackPowerweight;
			DEFAULT_CHAT_FRAME:AddMessage("[UnhDkTimer] Default AttackPowerWeight Loaded.");
		end
		if(not offsetPlagues) then
			offsetPlagues = defaultOffsetPlagues;
			DEFAULT_CHAT_FRAME:AddMessage("[UnhDkTimer] Default Offset for Plagues Loaded.");
		end
		if(not BuffList) then
			BuffList = defaultbufftable;
			DEFAULT_CHAT_FRAME:AddMessage("[UnhDkTimer] Default BuffList Loaded.");
		end

		ClassBuffList = defaultclbufftable;		

		fillBoxesWithSavedVariables();
		BuffListBoxUpdate();

		firstLoadPerGameStart = false;
		DEFAULT_CHAT_FRAME:AddMessage("[UnhDkTimer] Stat weights loaded.");
	elseif (event == "PLAYER_LOGOUT") then
		saveVariables();
	end
end

function resetStatWeights()
	--set the Weights to the defaults
	HasteWeight = defaulthasteweight;
	CritWeight = defaultcritweight;
	MasteryWeight = defaultmasteryweight;
	DamageWeight = defaultdamageweight;
	AttackPowerWeight = defaultAttackPowerweight;

	--Set the Edit Boxes to the new values
	EditBoxHaste:SetText(string.format("%1.2f", HasteWeight));
	EditBoxCrit:SetText(string.format("%1.2f", CritWeight));
	EditBoxMastery:SetText(string.format("%1.2f", MasteryWeight));
	EditBoxDamage:SetText(string.format("%1.2f", DamageWeight));
	EditBoxAttackPower:SetText(string.format("%1.2f", AttackPowerWeight));

	FontStringError:SetText("Stat weights reset to defaults.");
end

function resetOffsets()
	offsetPlagues = defaultOffsetPlagues;
	EditBoxOffsetPlagues:SetText(string.format("%d", offsetPlagues));

	FontStringError:SetText("Offsets reset to defaults.");
end

function saveVariables()
	HasteWeight = EditBoxHaste:GetNumber();
	CritWeight = EditBoxCrit:GetNumber();
	MasteryWeight = EditBoxMastery:GetNumber();
	DamageWeight = EditBoxDamage:GetNumber();
	AttackPowerWeight = EditBoxAttackPower:GetNumber();
	
	offsetPlagues = EditBoxOffsetPlauges:GetNumber();	
	
	DEFAULT_CHAT_FRAME:AddMessage("[UnhDkTimer] Variables Saved.");
end

function fillBoxesWithSavedVariables()
	EditBoxHaste:SetText(string.format("%1.2f", HasteWeight));
	EditBoxCrit:SetText(string.format("%1.2f", CritWeight));
	EditBoxMastery:SetText(string.format("%1.2f", MasteryWeight));
	EditBoxDamage:SetText(string.format("%1.2f", DamageWeight));
	EditBoxAttackPower:SetText(string.format("%1.2f", AttackPowerWeight));
	
	EditBoxOffsetPlagues:SetText(string.format("%d", offsetPlagues));				
end

function ButtonAddBuff_OnClick()
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
			if (string.lower(stat) == "strength" or
				string.lower(stat) == "mastery" or
				string.lower(stat) == "haste" or
				string.lower(stat) == "crit" or
				string.lower(stat) == "attackpower" or
				string.lower(stat) == "damage") then
				table.insert(BuffList, {buff, stat, modifier, maxstacks});
    			sort(BuffList, function(a,b) return a[1] < b[1] end);
				FontStringError:SetText("Added...");
			else
				FontStringError:SetText("Stat must be one of: strength, mastery, haste, crit, attackpower or damage.");
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