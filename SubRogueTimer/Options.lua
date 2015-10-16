-- Author      : Daniel Riraeyi@MagtheridonEU
-- Create Date : 27/07/2014

local defaultdamageweight = .84;
local defaultmasteryweight = .37;
local defaultcritweight = .38;
local defaulthasteweight = .42;
local defaultAttackPowerweight = .26;

local defaultOffsetHemorrhage = 7000;
local defaultOffsetSanguinaryVein = 8000;	--(rupture or equal)
local defaultOffsetSliceAndDice = 8000;
local defaultOffsetRecuperate = 7000;

local firstLoadPerGameStart = true;
local maxentries = 6;
local defaultbufftable = {}
offsets = {0, 0, 0, 0, 0} --{offsetHemorrhage, offsetSanguinaryVein, offsetSliceAndDice, offsetRecuperate};

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

--race abilities
table.insert(defaultclbufftable, {26297, "Haste", 20, 1});      -- Berserking

--profession abilities
table.insert(defaultclbufftable, {96230, "Agility", 1920, 1});      -- Synapse Spring
table.insert(defaultclbufftable, {121279, "Haste", 2880, 1});   	-- Lifeblood
table.insert(defaultclbufftable, {55777, "AttackPower", 4000, 1});  -- Swordguard Embroidery

--manufactured items
table.insert(defaultclbufftable, {146555, "Haste", 25, 1});     -- Drums of Rage
table.insert(defaultclbufftable, {76089, "Agility", 4000, 1});  -- Potion of the Virmin's Bite

--weapon enchants
table.insert(defaultclbufftable, {104510, "Mastery", 1500, 1}); -- Windsong Mastery
table.insert(defaultclbufftable, {104423, "Haste", 1500, 1});   -- Windsong Haste
table.insert(defaultclbufftable, {104509, "Crit", 1500, 1});    -- Windsong Crit
table.insert(defaultclbufftable, {120032, "Agility", 1650, 1}); -- Dancing Steel

--sub rogue abilities
table.insert(defaultclbufftable, {31665, "Damage", 10, 1});      -- Master of subtlety

--boss ability buffs
table.insert(defaultclbufftable, {140741, "Damage", 100, 1});	-- Primal Nutriment in ToT 6.Boss
table.insert(defaultclbufftable, {118977, "Damage", 60, 1});	-- Fearless in ToeS 4. Boss(Sha)

function OptionsFrame_OnLoad(panel)	
    -- Set the name for the Category for the Panel
	panel:RegisterEvent("ADDON_LOADED");
	panel:RegisterEvent("PLAYER_LOGOUT");
	panel:RegisterEvent("SPELLS_CHANGED");
    panel.name = "SubRogueTimer";

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
	--if (event == "ADDON_LOADED" and arg1 == "SubRogueTimer") then
	if (event == "SPELLS_CHANGED" and firstLoadPerGameStart) then
	if(not isSubRogue()) then return; end
		if(not HasteWeight) then
			HasteWeight = defaulthasteweight;
			DEFAULT_CHAT_FRAME:AddMessage("[SubRogueTimer] Default HasteWeight Loaded.");
		end
		if(not CritWeight) then
			CritWeight = defaultcritweight;
			DEFAULT_CHAT_FRAME:AddMessage("[SubRogueTimer] Default CritWeight Loaded.");
		end
		if(not MasteryWeight) then
			MasteryWeight = defaultmasteryweight;
			DEFAULT_CHAT_FRAME:AddMessage("[SubRogueTimer] Default MasteryWeight Loaded.");
		end
		if(not DamageWeight) then
			DamageWeight = defaultdamageweight;
			DEFAULT_CHAT_FRAME:AddMessage("[SubRogueTimer] Default DamageWeight Loaded.");
		end
		if(not AttackPowerWeight) then
			AttackPowerWeight = defaultAttackPowerweight;
			DEFAULT_CHAT_FRAME:AddMessage("[SubRogueTimer] Default AttackPowerWeight Loaded.");
		end
		if(not offsetSliceAndDice) then
			offsetSliceAndDice = defaultOffsetSliceAndDice;
			DEFAULT_CHAT_FRAME:AddMessage("[SubRogueTimer] Default Offset for Slice and Dice Loaded.");
		end
		if(not offsetSanguinaryVein) then
			offsetSanguinaryVein = defaultOffsetSanguinaryVein;
			DEFAULT_CHAT_FRAME:AddMessage("[SubRogueTimer] Default Offset for Sanguinary Vein Loaded.");
		end
		if(not offsetHemorrhage) then
			offsetHemorrhage = defaultOffsetHemorrhage;
			DEFAULT_CHAT_FRAME:AddMessage("[SubRogueTimer] Default Offset for Hemorrhage Loaded.");
		end
		if(not offsetRecuperate) then
			offsetRecuperate = defaultOffsetRecuperate;
			DEFAULT_CHAT_FRAME:AddMessage("[SubRogueTimer] Default Offset for Recuperate Loaded.");
		end
		if(not BuffList) then
			BuffList = defaultbufftable;
			DEFAULT_CHAT_FRAME:AddMessage("[SubRogueTimer] Default BuffList Loaded.");
		end

		offsets = {offsetHemorrhage, offsetSanguinaryVein, offsetSliceAndDice, offsetRecuperate};
		ClassBuffList = defaultclbufftable;		

		fillBoxesWithSavedVariables();
		BuffListBoxUpdate();

		firstLoadPerGameStart = false;
		DEFAULT_CHAT_FRAME:AddMessage("[SubRogueTimer] Stat weights loaded.");
	elseif (event == "PLAYER_LOGOUT") then
		saveVariables();
	end
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
			if (string.lower(stat) == "agility" or
				string.lower(stat) == "mastery" or
				string.lower(stat) == "haste" or
				string.lower(stat) == "crit" or
				string.lower(stat) == "attackpower" or
				string.lower(stat) == "damage") then
				table.insert(BuffList, {buff, stat, modifier, maxstacks});
    			sort(BuffList, function(a,b) return a[1] < b[1] end);
				FontStringError:SetText("Added...");
			else
				FontStringError:SetText("Stat must be one of: agility, mastery, haste, crit, attackpower or damage.");
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
	--set the offsets to the defaults	
	offsetSliceAndDice = defaultOffsetSliceAndDice;
	offsetSanguinaryVein = defaultOffsetSanguinaryVein;
	offsetHemorrhage = defaultOffsetHemorrhage;
	offsetRecuperate = defaultOffsetRecuperate;
	
	--Set the Edit Boxes to the new values	
	EditBoxOffsetSliceAndDice:SetText(string.format("%d", offsetSliceAndDice));
	EditBoxOffsetSanguinaryVein:SetText(string.format("%d",offsetSanguinaryVein));
	EditBoxOffsetHemorrhage:SetText(string.format("%d",offsetHemorrhage));
	EditBoxOffsetRecuperate:SetText(string.format("%d",offsetRecuperate));

	FontStringError:SetText("Offsets reset to defaults.");
end

function saveVariables()
	HasteWeight = EditBoxHaste:GetNumber();
	CritWeight = EditBoxCrit:GetNumber();
	MasteryWeight = EditBoxMastery:GetNumber();
	DamageWeight = EditBoxDamage:GetNumber();
	AttackPowerWeight = EditBoxAttackPower:GetNumber();
	
	offsetSliceAndDice = EditBoxOffsetSliceAndDice:GetNumber();	
	offsetSanguinaryVein = EditBoxOffsetSanguinaryVein:GetNumber();
	offsetHemorrhage = EditBoxOffsetHemorrhage:GetNumber();
	offsetRecuperate = EditBoxOffsetRecuperate:GetNumber();
	
	offsets = {offsetSliceAndDice, offsetSanguinaryVein, offsetHemorrhage, offsetRecuperate};
	DEFAULT_CHAT_FRAME:AddMessage("[SubRogueTimer] Variables Saved.");
end

function fillBoxesWithSavedVariables()
	EditBoxHaste:SetText(string.format("%1.2f", HasteWeight));
	EditBoxCrit:SetText(string.format("%1.2f", CritWeight));
	EditBoxMastery:SetText(string.format("%1.2f", MasteryWeight));
	EditBoxDamage:SetText(string.format("%1.2f", DamageWeight));
	EditBoxAttackPower:SetText(string.format("%1.2f", AttackPowerWeight));
	
	EditBoxOffsetSliceAndDice:SetText(string.format("%d", offsetSliceAndDice));			
	EditBoxOffsetSanguinaryVein:SetText(string.format("%d", offsetSanguinaryVein));	
	EditBoxOffsetHemorrhage:SetText(string.format("%d", offsetHemorrhage));
	EditBoxOffsetRecuperate:SetText(string.format("%d", offsetRecuperate));	
end