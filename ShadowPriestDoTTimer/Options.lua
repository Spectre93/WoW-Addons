-- Author      : Riraeyi @MagtheridonEU, Bathral @BlackhandEU
-- Create Date : 11/09/2013

local defaultdamageweight = .17;
local defaultmasteryweight = .56;
local defaultcritweight = .59;
local defaulthasteweight = .69;
local defaultspellpowerweight = .77;
local defaultOffsetbuffscoreSWP = 0;
local defaultOffsetbuffscoreVT = 2500;
local maxentries = 6;
local defaulthidepinf = 0;
local defaultHideSoD = 0;
local defaulthidevembrace = 0;
local defaulthideorbs = 0;
local defaulthidemb = 0;
local defaulthideswd = 0;
local defaulthidedp = 0;
local defaultshowmboffcd = 0;
local defaultcooldownoffset = 0;
local defaultCalcHasteNew = 0;
local defaulthidenumberabovevt = 0;
local defaulthidenumberaboveswp = 0;
local defaulthidenumberabovesai = 0;
local defaulthidebuffscore = 0;
local defaulthidetimervt = 0;
local defaulthidetimerswp = 0;
local defaulthidetimerdp = 0;
local defaulthideiconvt = 0;
local defaulthideiconswp = 0;
local defaulthideicondp = 0;
local defaultshowpioffcd = 0;
local defaultshowveoffcd = 0;
local defaultshowuvlsicon = 0;
local defaultcolorbuffswithbuffscore = 0;
local defaultshowdotssooutoffcombat = 0;
local defaultshoweverythingoutofcombat = 0;

local defaultbufftable = {}

table.insert(defaultbufftable, {"Mark of the Thunderlord", "Crit", 500, 1});			-- Enchant Weapon - Mark of the Thunderlord
table.insert(defaultbufftable, {"Mark of Warsong", "Haste", 1, 10});							-- Enchant Weapon - Mark of Warsong (100 haste rating (1% at level 100) per stack, starts at 10, drops 1 every 2 seconds)
table.insert(defaultbufftable, {"Mark of Bleeding Hollow", "Mastery", 500, 1});		-- Enchant Weapon - Mark of Bleeding Hollow
table.insert(defaultbufftable, {"Mark of the Frostwolf", "Multistrike", 500, 1});	-- Enchant Weapon - Mark of the Frostwolf

local defaultclbufftable = {}

--class abilities
table.insert(defaultclbufftable, {32182, "Haste", 30, 1});      -- Heroism
table.insert(defaultclbufftable, {2825, "Haste", 30, 1});       -- Bloodlust
table.insert(defaultclbufftable, {80353, "Haste", 30, 1});      -- Time Warp
table.insert(defaultclbufftable, {90355, "Haste", 30, 1});      -- Ancient Hysteria

--race abilities
table.insert(defaultclbufftable, {26297, "Haste", 15, 1});      -- Berserking

--manufactured items
table.insert(defaultclbufftable, {146555, "Haste", 25, 1});     -- Drums of Rage
table.insert(defaultclbufftable, {105702, "Int", 456, 1});     -- Potion of the Jade Serpent

--weapon enchants
table.insert(defaultclbufftable, {104510, "Mastery", 75, 1}); -- Windsong Mastery
table.insert(defaultclbufftable, {104423, "Haste", 75, 1});   -- Windsong Haste
table.insert(defaultclbufftable, {104509, "Crit", 75, 1});    -- Windsong Crit
table.insert(defaultclbufftable, {104993, "Int", 83, 1});     -- Jade Spirit

--priest abilities
table.insert(defaultclbufftable, {10060, "Haste", 25, 1});      -- Power Infusion Buff Haste Part
--table.insert(defaultclbufftable, {10060, "Damage", 5, 1});      -- Power Infusion Buff 5% Damage Part
table.insert(defaultclbufftable, {123254, "Damage", 15, 1});    -- Twist of Fate

--legendary stuff
table.insert(defaultclbufftable, {137590, "Haste", 30, 1});     -- Tempus Repit (Legendary Meta Gem Proc)

--boss ability buffs
table.insert(defaultclbufftable, {140741, "Damage", 100, 1});	-- Primal Nutriment in ToT 6.Boss
table.insert(defaultclbufftable, {118977, "Damage", 60, 1});	-- Fearless in ToeS 4. Boss(Sha)

function CancelButton_OnClick()
end

function SaveButton_OnClick()
	--Save the dialog's variables here.
	HasteWeight = EditBoxHaste:GetNumber();
	CritWeight = EditBoxCrit:GetNumber();
	MasteryWeight = EditBoxMastery:GetNumber();
	DamageWeight = EditBoxDamage:GetNumber();
	SpellpowerWeight = EditBoxSpellPower:GetNumber();
	CooldownOffset = EditBoxCooldownOffset:GetNumber();
	SetCooldownOffsets();
	OffsetbuffscoreSWP = EditBoxOffsetbuffscoreSWP:GetNumber();
	OffsetbuffscoreVT = EditBoxOffsetbuffscoreVT:GetNumber();

	if (CheckButtonHideVEmbrace:GetChecked() == 1) then
		HideVEmbrace = 1;
	else
		HideVEmbrace = 0;
	end		
	if (CheckButtonHideOrbs:GetChecked() == 1) then
		HideOrbs = 1;
	else
		HideOrbs = 0;
	end		
	if (CheckButtonHidePInf:GetChecked() == 1) then
		HidePInf = 1;
	else
		HidePInf = 0;
	end		
	if (CheckButtonHideSoD:GetChecked() == 1) then
		HideSoD = 1;
	else
		HideSoD = 0;
	end		
	if (CheckButtonHideMB:GetChecked() == 1) then
		HideMB = 1;
	else
		HideMB = 0;
	end
	if (CheckButtonShowMBOffCD:GetChecked() == 1) then
		ShowMBOffCD = 1;
	else
		ShowMBOffCD = 0;
	end
	if (CheckButtonCalcHasteNew:GetChecked() == 1) then
		CalcHasteNew = 1;
	else
		CalcHasteNew = 0;
	end	
	if (CheckButtonHideSWD:GetChecked() == 1) then
		HideSWD = 1;
	else
		HideSWD = 0;
	end
	if (CheckButtonHideDP:GetChecked() == 1) then
		HideDP = 1;
	else
		HideDP = 0;
	end	
	if (CheckButtonHideNumberAboveVT:GetChecked() == 1) then
		HideNumberAboveVT = 1;
	else
		HideNumberAboveVT = 0;
	end	
	if (CheckButtonHideNumberAboveSWP:GetChecked() == 1) then
		HideNumberAboveSWP = 1;
	else
		HideNumberAboveSWP = 0;
	end	
	if (CheckButtonHideNumberAboveSaI:GetChecked() == 1) then
		HideNumberAboveSaI = 1;
	else
		HideNumberAboveSaI = 0;
	end	
	if (CheckButtonHideBuffscore:GetChecked() == 1) then
		HideBuffscore = 1;
	else
		HideBuffscore = 0;
	end
	if (CheckButtonHideTimerVT:GetChecked() == 1) then
		HideTimerVT = 1;
	else
		HideTimerVT = 0;
	end	
	if (CheckButtonHideTimerSWP:GetChecked() == 1) then
		HideTimerSWP = 1;
	else
		HideTimerSWP = 0;
	end	
	if (CheckButtonHideTimerDP:GetChecked() == 1) then
		HideTimerDP = 1;
	else
		HideTimerDP = 0;
	end	
	if (CheckButtonHideIconVT:GetChecked() == 1) then
		HideIconVT = 1;
	else
		HideIconVT = 0;
	end	
	if (CheckButtonHideIconSWP:GetChecked() == 1) then
		HideIconSWP = 1;
	else
		HideIconSWP = 0;
	end	
	if (CheckButtonHideIconDP:GetChecked() == 1) then
		HideIconDP = 1;
	else
		HideIconDP = 0;
	end
	if (CheckButtonShowPIOffCD:GetChecked() == 1) then
		ShowPIOffCD = 1;
	else
		ShowPIOffCD = 0;
	end
	if (CheckButtonShowVEOffCD:GetChecked() == 1) then
		ShowVEOffCD = 1;
	else
		ShowVEOffCD = 0;
	end
	if (CheckButtonShowUVLSicon:GetChecked() == 1) then
		Show_UVLSicon = 1;
	else
		Show_UVLSicon = 0;
	end
	if (CheckButtonColorBuffsWithBuffScore:GetChecked() == 1) then
		ColorBuffsWithBuffScore = 1;
	else
		ColorBuffsWithBuffScore = 0;
	end
	if (CheckButtonShowDotsSoOutOffCombat:GetChecked() == 1) then
		ShowDotsSoOutOffCombat = 1;
		HideIconVT = 0;
		HideIconSWP = 0;
		HideIconDP = 0;
	else
		ShowDotsSoOutOffCombat = 0;
	end
	if (CheckButtonShowEverythingOutOfCombat:GetChecked() == 1) then
		ShowEverythingOutOfCombat = 1;
		HideIconVT = 0;
		HideIconSWP = 0;
		HideIconDP = 0;
	else
		ShowEverythingOutOfCombat = 0;
	end
	
	--DEFAULT_CHAT_FRAME:AddMessage("Shadow Priest DoT Timer Options Saved...");
end

parentaddon = {};
function OptionsFrame_OnLoad(panel)
    -- Set the name for the Category for the Panel
    --
	panel:RegisterEvent("ADDON_LOADED");
	panel:RegisterEvent("PLAYER_LOGOUT");
    panel.name = "Shadow Priest DoT Timer";

    -- When the player clicks okay, run this function.
    --
    panel.okay = function (self) SaveButton_OnClick(); end;

    -- When the player clicks cancel, run this function.
    --
    panel.cancel = function (self) CancelButton_OnClick();  end;

	--Build the list of buttons in the table.
		
	--DEFAULT_CHAT_FRAME:AddMessage("Building Entry Frames");
	local entry = CreateFrame("Button", "$parentEntry1", BuffListTable, "BuffListEntry");
	entry:SetID(1);
	entry:SetPoint("TOPLEFT", 4, -32);

	for i = 2, maxentries do
		local entry = CreateFrame("Button", "$parentEntry" .. i, BuffListTable, "BuffListEntry");
		entry:SetID(i);
		entry:SetPoint("TOP", "$parentEntry" .. (i - 1), "BOTTOM");
	end
	--DEFAULT_CHAT_FRAME:AddMessage("Done Building Entry Frames");

    -- Add the panel to the Interface Options
    --
    InterfaceOptions_AddCategory(panel);
    OptionsFrame:Hide();
    parentaddon = panel;
end

function OptionsFrameChild_OnLoad(childpanel)    

     -- Make a child panel
 	childpanel.name = "Additional Options";
 	-- Specify childness of this panel (this puts it under the little red [+], instead of giving it a normal AddOn category)
 	childpanel.parent = parentaddon.name;
 	-- Add the child to the Interface Options
 	InterfaceOptions_AddCategory(childpanel);
    childpanel:Hide();

end

function OptionsFrameChild1_OnLoad(childpanel1)    

     -- Make a child panel
 	childpanel1.name = "Position Options";
 	-- Specify childness of this panel (this puts it under the little red [+], instead of giving it a normal AddOn category)
 	childpanel1.parent = parentaddon.name;
 	-- Add the child to the Interface Options
 	InterfaceOptions_AddCategory(childpanel1);
    childpanel1:Hide();

end

function OptionsFrame_OnEvent(self, event, ...)
	local arg1 = ...;
	local arg2 = ...;
	if (event == "ADDON_LOADED" and arg1 == "ShadowPriestDoTTimer") then
		if(not HasteWeight) then
			HasteWeight = defaulthasteweight;
			-- arg2 = "Haste Weight";
			DEFAULT_CHAT_FRAME:AddMessage("Shadow Priest DoT Timer Default HasteWeight Loaded...");
		end
		if(not CritWeight) then
			CritWeight = defaultcritweight;
			-- arg2 = " Crit Weight";
			DEFAULT_CHAT_FRAME:AddMessage("Shadow Priest DoT Timer Default CritWeight Loaded...");
		end
		if(not MasteryWeight) then
			MasteryWeight = defaultmasteryweight;
			-- arg2 = " Mastery Weight";
			DEFAULT_CHAT_FRAME:AddMessage("Shadow Priest DoT Timer Default MasteryWeight Loaded...");
		end
		if(not DamageWeight) then
			DamageWeight = defaultdamageweight;
			-- arg2 = " DamageWeight";
			DEFAULT_CHAT_FRAME:AddMessage("Shadow Priest DoT Timer Default DamageWeight Loaded...");
		end
		if(not SpellpowerWeight) then
			SpellpowerWeight = defaultspellpowerweight;
			-- arg2 = " Spellpower Weight";
			DEFAULT_CHAT_FRAME:AddMessage("Shadow Priest DoT Timer Default SpellpowerWeight Loaded...");
		end
		if(not OffsetbuffscoreSWP) then
			OffsetbuffscoreSWP = defaultOffsetbuffscoreSWP;
			-- arg2 = " SW:P buffscore Offset";
			DEFAULT_CHAT_FRAME:AddMessage("Shadow Priest DoT Timer Default Offset for SW:P Loaded...");
		end
		if(not OffsetbuffscoreVT) then
			OffsetbuffscoreVT = defaultOffsetbuffscoreVT;
			-- arg2 = " VT buffscore Offset";
			DEFAULT_CHAT_FRAME:AddMessage("Shadow Priest DoT Timer Default Offset for VT Loaded...");
		end
		if(not BuffList) then
			BuffList = defaultbufftable;
			-- arg2 = " Buff List";
			DEFAULT_CHAT_FRAME:AddMessage("Shadow Priest DoT Timer Default BuffList Loaded...");
		end
		--This shall always be updated
		--if(not ClassBuffList) then
			ClassBuffList = defaultclbufftable;		
			-- arg2 = " ClassBuffList";
		--	DEFAULT_CHAT_FRAME:AddMessage("Shadow Priest DoT Timer Default ClassBuffList Loaded...");
		--end
		--This shall always be updated
		if(not HideVEmbrace) then
			HideVEmbrace = defaulthidevembrace;	
			-- arg2 = " Hide VEmbrace";
			DEFAULT_CHAT_FRAME:AddMessage("Shadow Priest DoT Timer Default VEmbrace Loaded...");
		end
		if(not HideOrbs) then
			HideOrbs = defaulthideorbs;		
			-- arg2 = " Hide Orbs";
			DEFAULT_CHAT_FRAME:AddMessage("Shadow Priest DoT Timer Default HideOrbs Loaded...");
		end
		if(not HideSoD) then
			HideSoD = defaultHideSoD;
			-- arg2 = " Hide SoD";
			DEFAULT_CHAT_FRAME:AddMessage("Shadow Priest DoT Timer Default HideSoD Loaded...");
		end
		if(not HidePInf) then
			HidePInf = defaulthidepinf;	
			-- arg2 = " HidePInf";
			DEFAULT_CHAT_FRAME:AddMessage("Shadow Priest DoT Timer Default HidePInf Loaded...");
		end
		if(not HideMB) then
			HideMB = defaulthidemb;
			-- arg2 = " Hide MindBlast";
			DEFAULT_CHAT_FRAME:AddMessage("Shadow Priest DoT Timer Default HideMB Loaded...");
		end
		if(not ShowMBOffCD) then
			ShowMBOffCD = defaultshowmboffcd;
			-- arg2 = " Hide MindBlast";
			DEFAULT_CHAT_FRAME:AddMessage("Shadow Priest DoT Timer Default ShowMBOffCD Loaded...");
		end
		if(not CalcHasteNew) then
			CalcHasteNew = defaultCalcHasteNew;
			-- arg2 = " Hide MindBlast";
			DEFAULT_CHAT_FRAME:AddMessage("Shadow Priest DoT Timer Default CalcHasteNew Loaded...");
		end
		if(not HideSWD) then
			HideSWD = defaulthideswd;
			-- arg2 = " Hide ShadowWordDeath";
			DEFAULT_CHAT_FRAME:AddMessage("Shadow Priest DoT Timer Default HideSWD Loaded...");
		end
		if(not HideDP) then
			HideDP = defaulthidedp;
			-- arg2 = " Hide ShadowWordDeath";
			DEFAULT_CHAT_FRAME:AddMessage("Shadow Priest DoT Timer Default HideDP Loaded...");
		end
		if(not CooldownOffset) then			
			CooldownOffset = defaultcooldownoffset;
			--arg2 = "Cooldown Offset"
			DEFAULT_CHAT_FRAME:AddMessage("Shadow Priest DoT Timer Default Cooldown Offset Loaded...");
		end
		if(not HideNumberAboveVT) then			
			HideNumberAboveVT = defaulthidenumberabovevt;
			--arg2 = "Cooldown Offset"
			DEFAULT_CHAT_FRAME:AddMessage("Shadow Priest DoT Timer Default HideNumberAboveVT Loaded...");
		end
		if(not HideNumberAboveSWP) then			
			HideNumberAboveSWP = defaulthidenumberaboveswp;
			--arg2 = "Cooldown Offset"
			DEFAULT_CHAT_FRAME:AddMessage("Shadow Priest DoT Timer Default HideNumberAboveSWP Loaded...");
		end
		if(not HideNumberAboveSaI) then			
			HideNumberAboveSaI = defaulthidenumberabovesai;
			--arg2 = "Cooldown Offset"
			DEFAULT_CHAT_FRAME:AddMessage("Shadow Priest DoT Timer Default HideNumberAboveSaI Loaded...");
		end
		if(not HideBuffscore) then			
			HideBuffscore = defaulthidebuffscore;
			--arg2 = "Cooldown Offset"
			DEFAULT_CHAT_FRAME:AddMessage("Shadow Priest DoT Timer Default HideBuffscore Loaded...");
		end	
		if(not HideTimerVT) then			
			HideTimerVT = defaulthidetimervt;
			--arg2 = "Cooldown Offset"
			DEFAULT_CHAT_FRAME:AddMessage("Shadow Priest DoT Timer Default HideTimerVT Loaded...");
		end	
		if(not HideTimerSWP) then			
			HideTimerSWP = defaulthidetimerswp;
			--arg2 = "Cooldown Offset"
			DEFAULT_CHAT_FRAME:AddMessage("Shadow Priest DoT Timer Default HideTimerSWP Loaded...");
		end	
		if(not HideTimerDP) then			
			HideTimerDP = defaulthidetimerdp;
			--arg2 = "Cooldown Offset"
			DEFAULT_CHAT_FRAME:AddMessage("Shadow Priest DoT Timer Default HideTimerDP Loaded...");
		end	
		if(not HideIconVT) then			
			HideIconVT = defaulthideiconvt;
			--arg2 = "Cooldown Offset"
			DEFAULT_CHAT_FRAME:AddMessage("Shadow Priest DoT Timer Default HideIconVT Loaded...");
		end	
		if(not HideIconSWP) then			
			HideIconSWP = defaulthideiconswp;
			--arg2 = "Cooldown Offset"
			DEFAULT_CHAT_FRAME:AddMessage("Shadow Priest DoT Timer Default HideIconSWP Loaded...");
		end	
		if(not HideIconDP) then			
			HideIconDP = defaulthideicondp;
			--arg2 = "Cooldown Offset"
			DEFAULT_CHAT_FRAME:AddMessage("Shadow Priest DoT Timer Default HideIconDP Loaded...");
		end	
		if(not ShowPIOffCD) then			
			ShowPIOffCD = defaultshowpioffcd;
			--arg2 = "Cooldown Offset"
			DEFAULT_CHAT_FRAME:AddMessage("Shadow Priest DoT Timer Default ShowPIOffCD Loaded...");
		end	
		if(not ShowVEOffCD) then			
			ShowVEOffCD = defaultshowveoffcd;
			--arg2 = "Cooldown Offset"
			DEFAULT_CHAT_FRAME:AddMessage("Shadow Priest DoT Timer Default ShowVEOffCD Loaded...");
		end
		if(not Show_UVLSicon) then			
			Show_UVLSicon = defaultshowuvlsicon;
			--arg2 = "Cooldown Offset"
			DEFAULT_CHAT_FRAME:AddMessage("Shadow Priest DoT Timer Default ShowUVLSicon Loaded...");
		end
		if(not ColorBuffsWithBuffScore) then			
			ColorBuffsWithBuffScore = defaultcolorbuffswithbuffscore;
			--arg2 = "Cooldown Offset"
			DEFAULT_CHAT_FRAME:AddMessage("Shadow Priest DoT Timer Default ColorBuffsWithBuffScore Loaded...");
		end
		if(not ShowDotsSoOutOffCombat) then			
			ShowDotsSoOutOffCombat = defaultshowdotssooutoffcombat;
			--arg2 = "Cooldown Offset"
			DEFAULT_CHAT_FRAME:AddMessage("Shadow Priest DoT Timer DefaultShowDotsSoOutOffCombat Loaded...");
		end
		if(not ShowEverythingOutOfCombat) then			
			ShowEverythingOutOfCombat = defaultshoweverythingoutofcombat;
			--arg2 = "Cooldown Offset"
			DEFAULT_CHAT_FRAME:AddMessage("Shadow Priest DoT Timer DefaultShowEverythingOutOffCombat Loaded...");
		end

		EditBoxHaste:SetText(string.format("%1.2f", HasteWeight));
		EditBoxCrit:SetText(string.format("%1.2f", CritWeight));
		EditBoxMastery:SetText(string.format("%1.2f", MasteryWeight));
		EditBoxDamage:SetText(string.format("%1.2f", DamageWeight));
		EditBoxSpellPower:SetText(string.format("%1.2f", SpellpowerWeight));
		EditBoxCooldownOffset:SetText(string.format("%d", CooldownOffset));
		EditBoxOffsetbuffscoreSWP:SetText(string.format("%d", OffsetbuffscoreSWP));			
		EditBoxOffsetbuffscoreVT:SetText(string.format("%d", OffsetbuffscoreVT));			


		if (HideSoD == 1) then
			--DEFAULT_CHAT_FRAME:AddMessage("Shadow Priest DoT Timer: Hide Tier 3 Talents");
			CheckButtonHideSoD:SetChecked(true);
		end
		if (HideVEmbrace == 1) then
			--DEFAULT_CHAT_FRAME:AddMessage("Shadow Priest DoT Timer: Hide Evangelism");
			CheckButtonHideVEmbrace:SetChecked(true);
		end
		if (HidePInf == 1) then
			--DEFAULT_CHAT_FRAME:AddMessage("Shadow Priest DoT Timer: Hide Tier 5 Talents");
			CheckButtonHidePInf:SetChecked(true);
		end
		if (HideOrbs == 1) then
			--DEFAULT_CHAT_FRAME:AddMessage("Shadow Priest DoT Timer: Hide Shadow Orbs");
			CheckButtonHideOrbs:SetChecked(true);
		end
		if (HideMB == 1) then
			--DEFAULT_CHAT_FRAME:AddMessage("Shadow Priest DoT Timer: Hide Mind Blast");
			CheckButtonHideMB:SetChecked(true);
		end
		if (ShowMBOffCD == 1) then
			--DEFAULT_CHAT_FRAME:AddMessage("Shadow Priest DoT Timer: Show MB off CD");
			CheckButtonShowMBOffCD:SetChecked(true);
		end
		if (CalcHasteNew == 1) then
			CheckButtonCalcHasteNew:SetChecked(true);
			--DEFAULT_CHAT_FRAME:AddMessage("Shadow Priest DoT Timer: Better Haste buff calculation");
		end
		if (HideSWD == 1) then
			--DEFAULT_CHAT_FRAME:AddMessage("Shadow Priest DoT Timer: Hide ShadowWord:Death");
			CheckButtonHideSWD:SetChecked(true);
		end
		if (HideDP == 1) then
			--DEFAULT_CHAT_FRAME:AddMessage("Shadow Priest DoT Timer: Hide DevouringPlague");
			CheckButtonHideDP:SetChecked(true);
		end
		if (HideNumberAboveVT == 1) then
			--DEFAULT_CHAT_FRAME:AddMessage("Shadow Priest DoT Timer: Hide Numbers above VT");
			CheckButtonHideNumberAboveVT:SetChecked(true);
		end
		if (HideNumberAboveSWP == 1) then
			--DEFAULT_CHAT_FRAME:AddMessage("Shadow Priest DoT Timer: Hide Numbers above SWP");
			CheckButtonHideNumberAboveSWP:SetChecked(true);
		end
		if (HideNumberAboveSaI == 1) then
			--DEFAULT_CHAT_FRAME:AddMessage("Shadow Priest DoT Timer: Hide Numbers above SaI");
			CheckButtonHideNumberAboveSaI:SetChecked(true);
		end
		if (HideBuffscore == 1) then
			--DEFAULT_CHAT_FRAME:AddMessage("Shadow Priest DoT Timer: Hide Buffscore");
			CheckButtonHideBuffscore:SetChecked(true);
		end
		if (HideTimerVT == 1) then
			--DEFAULT_CHAT_FRAME:AddMessage("Shadow Priest DoT Timer: Hide Timer VT");
			CheckButtonHideTimerVT:SetChecked(true);
		end
		if (HideTimerSWP == 1) then
			--DEFAULT_CHAT_FRAME:AddMessage("Shadow Priest DoT Timer: Hide Timer SWP");
			CheckButtonHideTimerSWP:SetChecked(true);
		end
		if (HideTimerDP == 1) then
			--DEFAULT_CHAT_FRAME:AddMessage("Shadow Priest DoT Timer: Hide Timer DP");
			CheckButtonHideTimerDP:SetChecked(true);
		end
		if (HideIconVT == 1) then
			--DEFAULT_CHAT_FRAME:AddMessage("Shadow Priest DoT Timer: Hide Icon VT");
			CheckButtonHideIconVT:SetChecked(true);
		end
		if (HideIconSWP == 1) then
			--DEFAULT_CHAT_FRAME:AddMessage("Shadow Priest DoT Timer: Hide Icon SWP");
			CheckButtonHideIconSWP:SetChecked(true);
		end
		if (HideIconDP == 1) then
			--DEFAULT_CHAT_FRAME:AddMessage("Shadow Priest DoT Timer: Hide Icon DP");
			CheckButtonHideIconDP:SetChecked(true);
		end
		if (ShowPIOffCD == 1) then
			--DEFAULT_CHAT_FRAME:AddMessage("Shadow Priest DoT Timer: Show PI Off CD");
			CheckButtonShowPIOffCD:SetChecked(true);
		end	
		if (ShowVEOffCD == 1) then
			--DEFAULT_CHAT_FRAME:AddMessage("Shadow Priest DoT Timer: Show VE Off CD");
			CheckButtonShowVEOffCD:SetChecked(true);
		end
		if (Show_UVLSicon == 1) then
			--DEFAULT_CHAT_FRAME:AddMessage("Shadow Priest DoT Timer: Show UVLS icon on procc");
			CheckButtonShowUVLSicon:SetChecked(true);
		end
		if (ColorBuffsWithBuffScore == 1) then
			--DEFAULT_CHAT_FRAME:AddMessage("Shadow Priest DoT Timer: Color buffs like buff score to on");
			CheckButtonColorBuffsWithBuffScore:SetChecked(true);
		end
		if (ShowDotsSoOutOffCombat == 1) then
			--DEFAULT_CHAT_FRAME:AddMessage("Shadow Priest DoT Timer: Color buffs like buff score to on");
			CheckButtonShowDotsSoOutOffCombat:SetChecked(true);
		end
		if (ShowEverythingOutOfCombat == 1) then
			--DEFAULT_CHAT_FRAME:AddMessage("Shadow Priest DoT Timer: Color buffs like buff score to on");
			CheckButtonShowEverythingOutOfCombat:SetChecked(true);
		end

		BuffListBoxUpdate();

		DEFAULT_CHAT_FRAME:AddMessage("Shadow Priest DoT Timer Stat Weights Loaded...");
	elseif (event == "SAVED_VARIABLES_TOO_LARGE" and arg1 == "ShadowPriestDoTTimer") then
		HasteWeight = defaulthasteweight;
		
		CritWeight = defaultcritweight;
		
		MasteryWeight = defaultmasteryweight;
		
		DamageWeight = defaultdamageweight;

		SpellpowerWeight = defaultspellpowerweight;

		OffsetbuffscoreSWP = defaultOffsetbuffscoreSWP;

		OffsetbuffscoreVT = defaultOffsetbuffscoreVT;

		BuffList = defaultbufftable;

		ClassBuffList = defaultclbufftable;		

		HideVEmbrace = defaulthidevembrace;	

		HideOrbs = defaulthideorbs;		

		HideSoD = defaultHideSoD;

		HidePInf = defaulthidepinf;	

		HideMB = defaulthidemb;

		ShowMBOffCD = defaultshowmboffcd;

		CalcHasteNew = defaultCalcHasteNew;
		
		HideSWD = defaulthideswd;
		
		HideDP = defaulthidedp;
	
		CooldownOffset = defaultcooldownoffset;
	
		HideNumberAboveVT = defaulthidenumberabovevt;
	
		HideNumberAboveSWP = defaulthidenumberaboveswp;
	
		HideNumberAboveSaI = defaulthidenumberabovesai;
	
		HideBuffscore = defaulthidebuffscore;

		HideTimerVT = defaulthidetimervt;
	
		HideTimerSWP = defaulthidetimerswp;
	
		HideTimerDP = defaulthidetimerdp;

		HideIconVT = defaulthideiconvt;
	
		HideIconSWP = defaulthideiconswp;
	
		HideIconDP = defaulthideicondp;
		
		ShowPIOffCD = defaultshowpioffcd;
	
		ShowVEOffCD = defaultshowveoffcd;
		
		Show_UVLSicon = defaultshowuvlsicon;
		
		ColorBuffsWithBuffScore = defaultcolorbuffswithbuffscore;
	
		ShowDotsSoOutOffCombat = defaultshowdotssooutoffcombat;
		
		ShowEverythingOutOfCombat = defaultshoweverythingoutofcombat;


		EditBoxHaste:SetText(string.format("%1.2f", HasteWeight));
		EditBoxCrit:SetText(string.format("%1.2f", CritWeight));
		EditBoxMastery:SetText(string.format("%1.2f", MasteryWeight));
		EditBoxDamage:SetText(string.format("%1.2f", DamageWeight));
		EditBoxSpellPower:SetText(string.format("%1.2f", SpellpowerWeight));
		EditBoxCooldownOffset:SetText(string.format("%d", CooldownOffset));
		EditBoxOffsetbuffscoreSWP:SetText(string.format("%d", OffsetbuffscoreSWP));			
		EditBoxOffsetbuffscoreVT:SetText(string.format("%d", OffsetbuffscoreVT));			


		if (HideSoD == 1) then
			--DEFAULT_CHAT_FRAME:AddMessage("Shadow Priest DoT Timer: Hide Tier 3 Talents");
			CheckButtonHideSoD:SetChecked(true);
		end
		if (HideVEmbrace == 1) then
			--DEFAULT_CHAT_FRAME:AddMessage("Shadow Priest DoT Timer: Hide Evangelism");
			CheckButtonHideVEmbrace:SetChecked(true);
		end
		if (HidePInf == 1) then
			--DEFAULT_CHAT_FRAME:AddMessage("Shadow Priest DoT Timer: Hide Tier 5 Talents");
			CheckButtonHidePInf:SetChecked(true);
		end
		if (HideOrbs == 1) then
			--DEFAULT_CHAT_FRAME:AddMessage("Shadow Priest DoT Timer: Hide Shadow Orbs");
			CheckButtonHideOrbs:SetChecked(true);
		end
		if (HideMB == 1) then
			--DEFAULT_CHAT_FRAME:AddMessage("Shadow Priest DoT Timer: Hide Mind Blast");
			CheckButtonHideMB:SetChecked(true);
		end
		if (ShowMBOffCD == 1) then
			--DEFAULT_CHAT_FRAME:AddMessage("Shadow Priest DoT Timer: Show MB off CD");
			CheckButtonShowMBOffCD:SetChecked(true);
		end
		if (CalcHasteNew == 1) then
			CheckButtonCalcHasteNew:SetChecked(true);
			--DEFAULT_CHAT_FRAME:AddMessage("Shadow Priest DoT Timer: Better Haste buff calculation");
		end
		if (HideSWD == 1) then
			--DEFAULT_CHAT_FRAME:AddMessage("Shadow Priest DoT Timer: Hide ShadowWord:Death");
			CheckButtonHideSWD:SetChecked(true);
		end
		if (HideDP == 1) then
			--DEFAULT_CHAT_FRAME:AddMessage("Shadow Priest DoT Timer: Hide DevouringPlague");
			CheckButtonHideDP:SetChecked(true);
		end
		if (HideNumberAboveVT == 1) then
			--DEFAULT_CHAT_FRAME:AddMessage("Shadow Priest DoT Timer: Hide Numbers above VT");
			CheckButtonHideNumberAboveVT:SetChecked(true);
		end
		if (HideNumberAboveSWP == 1) then
			--DEFAULT_CHAT_FRAME:AddMessage("Shadow Priest DoT Timer: Hide Numbers above SWP");
			CheckButtonHideNumberAboveSWP:SetChecked(true);
		end
		if (HideNumberAboveSaI == 1) then
			--DEFAULT_CHAT_FRAME:AddMessage("Shadow Priest DoT Timer: Hide Numbers above SaI");
			CheckButtonHideNumberAboveSaI:SetChecked(true);
		end
		if (HideBuffscore == 1) then
			--DEFAULT_CHAT_FRAME:AddMessage("Shadow Priest DoT Timer: Hide Buffscore");
			CheckButtonHideBuffscore:SetChecked(true);
		end
		if (HideTimerVT == 1) then
			--DEFAULT_CHAT_FRAME:AddMessage("Shadow Priest DoT Timer: Hide Timer VT");
			CheckButtonHideTimerVT:SetChecked(true);
		end
		if (HideTimerSWP == 1) then
			--DEFAULT_CHAT_FRAME:AddMessage("Shadow Priest DoT Timer: Hide Timer SWP");
			CheckButtonHideTimerSWP:SetChecked(true);
		end
		if (HideTimerDP == 1) then
			--DEFAULT_CHAT_FRAME:AddMessage("Shadow Priest DoT Timer: Hide Timer DP");
			CheckButtonHideTimerDP:SetChecked(true);
		end
		if (HideIconVT == 1) then
			--DEFAULT_CHAT_FRAME:AddMessage("Shadow Priest DoT Timer: Hide Icon VT");
			CheckButtonHideIconVT:SetChecked(true);
		end
		if (HideIconSWP == 1) then
			--DEFAULT_CHAT_FRAME:AddMessage("Shadow Priest DoT Timer: Hide Icon SWP");
			CheckButtonHideIconSWP:SetChecked(true);
		end
		if (HideIconDP == 1) then
			--DEFAULT_CHAT_FRAME:AddMessage("Shadow Priest DoT Timer: Hide Icon DP");
			CheckButtonHideIconDP:SetChecked(true);
		end
		if (ShowPIOffCD == 1) then
			--DEFAULT_CHAT_FRAME:AddMessage("Shadow Priest DoT Timer: Show PI Off CD");
			CheckButtonShowPIOffCD:SetChecked(true);
		end	
		if (ShowVEOffCD == 1) then
			--DEFAULT_CHAT_FRAME:AddMessage("Shadow Priest DoT Timer: Show VE Off CD");
			CheckButtonShowVEOffCD:SetChecked(true);
		end
		if (Show_UVLSicon == 1) then
			--DEFAULT_CHAT_FRAME:AddMessage("Shadow Priest DoT Timer: Show UVLS icon on procc");
			CheckButtonShowUVLSicon:SetChecked(true);
		end
		if (ColorBuffsWithBuffScore == 1) then
			--DEFAULT_CHAT_FRAME:AddMessage("Shadow Priest DoT Timer: Color buffs like buff score to on");
			CheckButtonColorBuffsWithBuffScore:SetChecked(true);
		end
		if (ShowDotsSoOutOffCombat == 1) then
			--DEFAULT_CHAT_FRAME:AddMessage("Shadow Priest DoT Timer: Color buffs like buff score to on");
			CheckButtonShowDotsSoOutOffCombat:SetChecked(true);
		end
		if (ShowEverythingOutOfCombat == 1) then
			--DEFAULT_CHAT_FRAME:AddMessage("Shadow Priest DoT Timer: Color buffs like buff score to on");
			CheckButtonShowEverythingOutOfCombat:SetChecked(true);
		end

		BuffListBoxUpdate();

		DEFAULT_CHAT_FRAME:AddMessage("Shadow Priest DoT Timer Default Stat Weights Loaded, because your memory is too low!");	
	elseif (event == "PLAYER_LOGOUT") then
		HasteWeight = EditBoxHaste:GetNumber();
		CritWeight = EditBoxCrit:GetNumber();
		MasteryWeight = EditBoxMastery:GetNumber();
		DamageWeight = EditBoxDamage:GetNumber();
		SpellpowerWeight = EditBoxSpellPower:GetNumber();
		CooldownOffset = EditBoxCooldownOffset:GetNumber();
		OffsetbuffscoreSWP = EditBoxOffsetbuffscoreSWP:GetNumber();
		OffsetbuffscoreVT = EditBoxOffsetbuffscoreVT:GetNumber();

		if (CheckButtonHideVEmbrace:GetChecked() == 1) then
			HideVEmbrace = 1;
		else
			HideVEmbrace = 0;
		end		
		if (CheckButtonHideOrbs:GetChecked() == 1) then
			HideOrbs = 1;
		else
			HideOrbs = 0;
		end		
		if (CheckButtonHidePInf:GetChecked() == 1) then
			HidePInf = 1;
		else
			HidePInf = 0;
		end		
		if (CheckButtonHideSoD:GetChecked() == 1) then
			HideSoD = 1;
		else
			HideSoD = 0;
		end		
		if (CheckButtonHideMB:GetChecked() == 1) then
			HideMB = 1;
		else
			HideMB = 0;
		end
		if (CheckButtonShowMBOffCD:GetChecked() == 1) then
			ShowMBOffCD = 1;
		else
			ShowMBOffCD = 0;
		end
		if (CheckButtonCalcHasteNew:GetChecked() == 1) then
			CalcHasteNew = 1;
		else
			CalcHasteNew = 0;
		end
		if (CheckButtonHideSWD:GetChecked() == 1) then
			HideSWD = 1;
		else
			HideSWD = 0;
		end
		if (CheckButtonHideDP:GetChecked() == 1) then
			HideDP = 1;
		else
			HideDP = 0;
		end
		if (CheckButtonHideNumberAboveVT:GetChecked() == 1) then
			HideNumberAboveVT = 1;
		else
			HideNumberAboveVT = 0;
		end
		if (CheckButtonHideNumberAboveSWP:GetChecked() == 1) then
			HideNumberAboveSWP = 1;
		else
			HideNumberAboveSWP = 0;
		end
		if (CheckButtonHideNumberAboveSaI:GetChecked() == 1) then
			HideNumberAboveSaI = 1;
		else
			HideNumberAboveSaI = 0;
		end	
		if (CheckButtonHideBuffscore:GetChecked() == 1) then
			HideBuffscore = 1;
		else
			HideBuffscore = 0;
		end
		if (CheckButtonHideTimerVT:GetChecked() == 1) then
			HideTimerVT = 1;
		else
			HideTimerVT = 0;
		end	
		if (CheckButtonHideTimerSWP:GetChecked() == 1) then
			HideTimerSWP = 1;
		else
			HideTimerSWP = 0;
		end	
		if (CheckButtonHideTimerDP:GetChecked() == 1) then
			HideTimerDP = 1;
		else
			HideTimerDP = 0;
		end	
		if (CheckButtonHideIconVT:GetChecked() == 1) then
			HideIconVT = 1;
		else
			HideIconVT = 0;
		end	
		if (CheckButtonHideIconSWP:GetChecked() == 1) then
			HideIconSWP = 1;
		else
			HideIconSWP = 0;
		end	
		if (CheckButtonHideIconDP:GetChecked() == 1) then
			HideIconDP = 1;
		else
			HideIconDP = 0;
		end
		if (CheckButtonShowPIOffCD:GetChecked() == 1) then
			ShowPIOffCD = 1;
		else
			ShowPIOffCD = 0;
		end	
		if (CheckButtonShowVEOffCD:GetChecked() == 1) then
			ShowVEOffCD = 1;
		else
			ShowVEOffCD = 0;
		end	
		if (CheckButtonShowUVLSicon:GetChecked() == 1) then
			Show_UVLSicon = 1;
		else
			Show_UVLSicon = 0;
		end
		if (CheckButtonColorBuffsWithBuffScore:GetChecked() == 1) then
			ColorBuffsWithBuffScore = 1;
		else
			ColorBuffsWithBuffScore = 0;
		end
		if (CheckButtonShowDotsSoOutOffCombat:GetChecked() == 1) then
			ShowDotsSoOutOffCombat = 1;
			HideIconVT = 0;
			HideIconSWP = 0;
			HideIconDP = 0;
		else
			ShowDotsSoOutOffCombat = 0;
		end
		if (CheckButtonShowEverythingOutOfCombat:GetChecked() == 1) then
			ShowEverythingOutOfCombat = 1;
			HideIconVT = 0;
			HideIconSWP = 0;
			HideIconDP = 0;
		else
			ShowEverythingOutOfCombat = 0;
		end	
			
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
	
	--DEFAULT_CHAT_FRAME:AddMessage("Updating scroll bar");
	FauxScrollFrame_Update(BuffListScrollFrame, #BuffList, maxentries, 24, "BuffListTableEntry", 464, 480, BuffListTableHeaderMaxStacks, 88, 104);
	--DEFAULT_CHAT_FRAME:AddMessage("Done Updating scroll bar");
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

function ResetDefaultBuffsButton_OnClick()
	DEFAULT_CHAT_FRAME:AddMessage("Resetting Buff List");
	ClearBuffList();

	BuffList = defaultbufftable;

	BuffListBoxUpdate();
	FontStringError:SetText("Buff List reset to defaults.");
end

function ResetStatWeightsButton_OnClick()
	DEFAULT_CHAT_FRAME:AddMessage("Resetting Stat Weights");

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

	FontStringError:SetText("Stat Weights reset to defaults.");
end

function ClearBuffList()
	for i = 1, #BuffList do
		table.remove(BuffList, i);
	end
end
