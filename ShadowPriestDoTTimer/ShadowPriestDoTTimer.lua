-- Author      : Riraeyi @MagtheridonEU, Bathral@BlackhandEU, Kressilac @Duskwood
-- UI elements borrowed from Shadow Timer and extended for better use.
-- Create Date : 11/09/2013

local _; -- workaround to prevent leaking globals

local MyAddon_UpdateInterval = 0.05; -- How often the OnUpdate code will run (in seconds)
local TimeSinceLastUpdate = 0;

local WarningTime = 600; -- WarningTime (in milliseconds)
local buffscorecurrent = 0;

--Used to proove that a Priest is being played
local Priest = false;
local ShadowSpecc = false;

--Used to keep track if player is in combat.
local isincombat = false;

--MindFlay Insanity active indication
local MFI_Active = false;

--Used to prioritize DP texture over Shadoworbs
local Texture3used = false;

--Used to share Texture5 for Mindblast and SW:D
local Texture5used = false;

----------------------------------------------
local SWP_ID = 589;
local SWP_Name, _, SWP_Icon = GetSpellInfo(SWP_ID);						--"Shadow Word: Pain"
----------------------------------------------
local VT_ID = 34914
local VT_Name, _, VT_Icon, VT_CastTime = GetSpellInfo(VT_ID) 	--"Vampiric Touch"
----------------------------------------------
local DP_ID = 2944
local DP_Name, _, DP_Icon = GetSpellInfo(DP_ID);							--"Devouring Plague"
----------------------------------------------
local SWD_ID = 32379;
local SWD_Name, _, SWD_Icon = GetSpellInfo(SWD_ID);						--"Shadow Word: Death"
----------------------------------------------
local SPELL_POWER_SHADOW_ORBS  = SPELL_POWER_SHADOW_ORBS 
local ShadowOrbs_Icon = "Interface\\ICONS\\spell_priest_shadoworbs.blp"
----------------------------------------------
local MB_ID = 8092;
local MB_Name, _, MB_Icon = GetSpellInfo(MB_ID);							--"Mind Blast"
----------------------------------------------
local VE_ID = 15286;
local VE_Name, _, VE_Icon = GetSpellInfo(VE_ID);							--"Vampiric Embrace"
----------------------------------------------
local PI_ID = 10060;
local PI_Name, _, PI_Icon = GetSpellInfo(PI_ID);
----------------------------------------------
local SoD_ID = 87160;
local SoD_Name, _, SoD_Icon = GetSpellInfo(SoD_ID);
----------------------------------------------
local Insanity_ID = 129197;
local Insanity_Name, _, Insanity_Icon = GetSpellInfo(Insanity_ID);
---------------------------------------------- 
local SI_ID = 124430;
local SI_Name, _, SI_Icon = GetSpellInfo(SI_ID);
----------------------------------------------
local Mindbender_ID = 123040;
local Mindbender_Name, _, Mindbender_Icon = GetSpellInfo(Mindbender_ID);
----------------------------------------------
local Shadowy_Apparitions_ID = 148859;
----------------------------------------------
local UVLS_procID = 138963;
local _, _, IconUVLS = GetSpellInfo(UVLS_procID);
----------------------------------------------
local fluidity_ID = 138002;
local fluidity_name = GetSpellInfo(fluidity_ID);
------------------------------

function PriestCheck()
	local _, englishClass = UnitClass("player");
	return englishClass;
end

local function HideAll()
	SPDT_Texture1:Hide();
	SPDT_Texture2:Hide();
	SPDT_Texture3:Hide();
	SPDT_Texture4:Hide();
	SPDT_Texture5:Hide();
	SPDT_Texture6:Hide();
	SPDT_Texture7:Hide();
	SPDT_Texture8:Hide();

	SPDT_TEXT1:Hide();
	SPDT_TEXT2:Hide();	
	SPDT_TEXT3:Hide();
	SPDT_TEXT4:Hide();
	SPDT_TEXT5:Hide();
	SPDT_TEXT6:Hide();
	SPDT_TEXT7:Hide();
	SPDT_TEXT8:Hide();
	
	SPDT_TEXT3Above:Hide();
	SPDT_TEXT6Above:Hide();
	SPDT_TEXT7Above:Hide();
	
	buffscorecurrent = 0;
end

local function SetCooldownOffsets()
	local point, relativeTo, relativePoint, xOfs, yOfs;
	point, relativeTo, relativePoint, xOfs, yOfs = SPDT_TEXT1:GetPoint();
	SPDT_TEXT1:SetPoint(point, relativeTo, relativePoint, xOfs, CooldownOffset);
	point, relativeTo, relativePoint, xOfs, yOfs = SPDT_TEXT2:GetPoint();
	SPDT_TEXT2:SetPoint(point, relativeTo, relativePoint, xOfs, CooldownOffset);
	point, relativeTo, relativePoint, xOfs, yOfs = SPDT_TEXT3:GetPoint();
	SPDT_TEXT3:SetPoint(point, relativeTo, relativePoint, xOfs, CooldownOffset);
	--nothing for SPDT_TEXT4
	point, relativeTo, relativePoint, xOfs, yOfs = SPDT_TEXT5:GetPoint();
	SPDT_TEXT5:SetPoint(point, relativeTo, relativePoint, xOfs, CooldownOffset);
	point, relativeTo, relativePoint, xOfs, yOfs = SPDT_TEXT6:GetPoint();
	SPDT_TEXT6:SetPoint(point, relativeTo, relativePoint, xOfs, CooldownOffset);
	point, relativeTo, relativePoint, xOfs, yOfs = SPDT_TEXT7:GetPoint();
	SPDT_TEXT7:SetPoint(point, relativeTo, relativePoint, xOfs, CooldownOffset);
	point, relativeTo, relativePoint, xOfs, yOfs = SPDT_TEXT8:GetPoint();
	SPDT_TEXT8:SetPoint(point, relativeTo, relativePoint, xOfs, CooldownOffset);
end

-- check for talent Insanity is learned
local function Insanity_Check()
	local name, texture, tier, column, selected = GetTalentInfo(3, 3, 1)	
	if (selected == true) then
		return true
	else
		return false
	end
end

-- check for talent Mindbender is learned
local function Mindbender_Check()
	local name, texture, tier, column, selected = GetTalentInfo(3, 2, 1);
	if (selected == true) then
		return true;
	else
		return false;
	end
end

-- check for talent Surge of Darkness is learned -- surge of darkness
local function SoD_Check()
	local name, texture, tier, column, selected = GetTalentInfo(3, 1, 1);
	if (selected == true) then
		return true;
	else
		return false;
	end	
end

-- check for talent Power Infusion is learned
local function PowInf_Check()
	local name, texture, tier, column, selected = GetTalentInfo(5, 2, 1);
	if (selected == true) then
		return true;
	else
		return false;
	end	
end

-- check for talent Shadowy Insight is learned -- Shadowy insight
local function SI_Check()
	local name, texture, tier, column, selected = GetTalentInfo(5, 3, 1);
	if (selected == true) then
		return true;
	else
		return false;
	end	
end

local function CheckCurrentTargetDeBuffs()
	local finished = false;
	local count = 0;
	local VTFound = 0;
	local VTLeft = 0;
	local VTlefttime = 0;
	local VTlasttickTime = 0;
	local VTlasttickcastTime = 0;
	local VTleftMS = 0;
	local PlagueFound = 0;
	local PlagueLeft = 0;
	local Plaguelefttime = 0;
	local WordPainFound = 0;
	local WordPainLeft = 0;
	local WordPainlefttime = 0;
	local WordPainleftMS = 0;
	local WordPainlasttickTime = 0;
	local WordPainlasttickCastTime = 0;
	local CastTime = 0;

	VTlasttickTime = VT_CastTime*3+WarningTime;
	VTlasttickcastTime = VT_CastTime*3;
	WordPainlasttickTime = VT_CastTime*2+WarningTime;
	WordPainlasttickCastTime = VT_CastTime*2;

	while not finished do
		count = count+1;

		local buffName,_,_,_,_,buffDuration,expireTime,caster =  UnitDebuff("target", count, 0);
		if not buffName then
			finished = true;
		else
			if caster == "player" then				
				if buffName == VT_Name then 
					VTFound = 1;
					VTlefttime = floor((((expireTime-GetTime())*10)+ 0.5))/10;
					if(VTlefttime <= 5.0) then				
						VTLeft = string.format("%1.1f",VTlefttime);
					else
						VTLeft = string.format("%d",VTlefttime);
					end
					VTleftMS = VTlefttime*1000;
					CastTime = VT_CastTime;
					--VTleftMSSafe = VTleftMS-WarningTime;
					--VTduration = buffDuration;
				end
				if buffName == DP_Name then 
					PlagueFound = 1;
					Plaguelefttime = floor((((expireTime-GetTime())*10)+ 0.5))/10;		
					PlagueLeft = string.format("%1.1f",Plaguelefttime);

				end
				if buffName == SWP_Name then 
					WordPainFound = 1;
					WordPainlefttime = floor((((expireTime-GetTime())*10)+ 0.5))/10;
					if (WordPainlefttime <= 4.0) then
						WordPainLeft = string.format("%1.1f",WordPainlefttime);
					else
						WordPainLeft = string.format("%d",WordPainlefttime);
					end  
					WordPainleftMS = WordPainlefttime*1000;
					--SWPduration = bduration;
				end
			end
		end
	end

	if (VTFound == 1) then
		--VTIcon display, coloring and hide procedure
		if (HideIconVT == 0) then
			SPDT_Texture1:Show();
			if  VTleftMS < VTlasttickTime then
				if VTleftMS < VTlasttickcastTime then
					SPDT_Texture1:SetVertexColor(0.1, 0.6, 0.1);		--green
				else 
					SPDT_Texture1:SetVertexColor(0.9, 0.2, 0.2);		--red
				end
			else
				SPDT_Texture1:SetVertexColor(1.0, 1.0, 1.0);			--nothing
			end
		else 
			if (ShowDotsSoOutOffCombat == 0) then
				SPDT_Texture1:Hide();
			else
				SPDT_Texture1:SetVertexColor(1.0, 1.0, 1.0);		--no color
			end
		end
		
		if (HideTimerVT == 0) then
			SPDT_TEXT1:SetText(VTLeft);
			SPDT_TEXT1:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE")
			SPDT_TEXT1:Show();
		else
			SPDT_TEXT1:Hide();
		end
	else
		SPDT_TEXT1:Hide();
		if (ShowDotsSoOutOffCombat == 0) then
			SPDT_Texture1:Hide();
		else 
			SPDT_Texture1:SetVertexColor(1.0, 1.0, 1.0);		--no color
			SPDT_Texture1:Show();
		end		
	end

	if (WordPainFound == 1) then
		--SWP number above assignment
	
		--SWPIcon display, coloring and hide procedure
		if(HideIconSWP == 0) then
			SPDT_Texture2:Show();
			if  WordPainleftMS < WordPainlasttickTime then
				if (WordPainleftMS < WordPainlasttickCastTime)  then
					SPDT_Texture2:SetVertexColor(0.1, 0.6, 0.1);	--green
				else				
					SPDT_Texture2:SetVertexColor(0.9, 0.2, 0.2);	--red
				end
			else
				SPDT_Texture2:SetVertexColor(1.0, 1.0, 1.0);		--no color
			end
		else
			if (ShowDotsSoOutOffCombat == 0) then
				SPDT_Texture2:Hide();
			else 
				SPDT_Texture2:SetVertexColor(1.0, 1.0, 1.0);		--no color
				SPDT_TEXT2:Show();
			end	
		end
		
		if (HideTimerSWP == 0) then 
			SPDT_TEXT2:SetText(WordPainLeft);
			SPDT_TEXT2:SetTextColor(1.0, 1.0, 1.0);
			SPDT_TEXT2:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE")
			SPDT_TEXT2:Show();
		else
			SPDT_TEXT2:Hide();
		end
	else

		SPDT_TEXT2:Hide();
		if (ShowDotsSoOutOffCombat == 0) then
			SPDT_Texture2:Hide();
		else 
			SPDT_Texture2:SetVertexColor(1.0, 1.0, 1.0);		--no color
			SPDT_Texture2:Show();
		end	
	end
	
	if (PlagueFound == 1) then
		Texture3used = true;
		if (Insanity_Check() == true and HideSoD == 0) then
		--Mindflay: Insanity Active Time Procedure
		--Cooldown -> No Color
			MFI_Active = true;
			SPDT_Texture3:SetVertexColor(0.1, 0.6, 0.1);		--green with the correct cooldown
			SPDT_Texture3:SetTexture(Insanity_Icon);
			SPDT_Texture3:Show();
			SPDT_TEXT3Above:Hide();
			if (HideTimerDP == 0) then
				SPDT_TEXT3:SetText(PlagueLeft);
				SPDT_TEXT3:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE")
				SPDT_TEXT3:Show();
			else
				SPDT_TEXT3:Hide();
			end
		elseif(HideDP == 0) then
			MFI_Active = false;
			if (HideIconDP == 0) then
				SPDT_Texture3:SetTexture(DP_Icon);
				SPDT_Texture3:SetVertexColor(1.0, 1.0, 1.0);		--no color
				SPDT_Texture3:Show();
			else
				SPDT_Texture3:Hide();
			end
			SPDT_TEXT3Above:Hide();
			if (HideTimerDP == 0) then
				SPDT_TEXT3:SetText(PlagueLeft);
				SPDT_TEXT3:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE")
				SPDT_TEXT3:Show();
			else
				SPDT_TEXT3:Hide();
			end
		else
			MFI_Active = false;
			SPDT_Texture3:Hide();
			SPDT_TEXT3:Hide();
			SPDT_TEXT3Above:Hide();
		end
	else
		MFI_Active = false;
		Texture3used = false;
		SPDT_Texture3:Hide();
		SPDT_TEXT3:Hide();
		SPDT_TEXT3Above:Hide();
	end
end

local function CheckPlayerBuffs()
	local Texture6CD = 0;
	local Texture7CD = 0;
	local finished = false;
	local count = 0;
	local EmbraceFound = 0;
	local EmbraceLeft = 0;
	local PowerInfusionFound = 0;
	local SurgeOfDarknessStacks = 0;
	local PowerInfusionLeft = 0;
	local SurgeOfDarknessFound = 0;
	local SurgeOfDarknessLeft = 0;
	local MindbenderLeft = 0;
	local DivInFound = 0;
	local DivInLeft = 0;
	local MBLeft = 0;
	local PowerInfCD = 0;
	local EmbraceCD = 0;
	local SurgeOfDarknessCD = 0;
	local MindbenderCD = 0;
	SPDT_Texture4:Hide();
	
	local found = false;
	local i = 0;
	local found1 = false;
	local j = 0;
	local k = 0;
	local l = 0;
	local m = 0;
	local n = 0;
	
	local SPELL_POWER_SHADOW_ORBS  = SPELL_POWER_SHADOW_ORBS;
	local NumOfOrbs = UnitPower('player', SPELL_POWER_SHADOW_ORBS);

	buffscorecurrent = 0;
	local buffscorehaste = 1;
	local buffscorehastetemp = 0;
	local buffscorehastetemp2 = 0;
	local buffscoredamagetemp = 1;
	local modifiedint = 0;
	local fluidity_active 	= UnitAura("player", fluidity_name, nil, "HARMFUL");
	local base, stat, posBuff, negBuff = UnitStat("player",4);

	--[[
	while not finished do
		count = count+1;
		local bn,_,_,bcount,_,_,bexpirationTime,_,_,_,bspellId =  UnitBuff("player", count, 0);

		modifiedint = base + buffscorecurrent;
		
		if not bn then
			finished = true;
		else
			--UVLS check for indication of 100% CritBuff
			if (bspellId == UVLS_procID) then
				if (Show_UVLSicon == 1) then
					SPDT_Texture4:SetTexture(IconUVLS);
					SPDT_Texture4:Show();
				end
			end
			if (bn == VE_Name) then 
				EmbraceFound = 1;
				EmbraceLeft = string.format("%1.1f",floor((((bexpirationTime-GetTime())*10)+ 0.5))/10);		-- as formated string						
			end
			if (bn == PI_Name) then
				PowerInfusionFound	= 1;
				PowerInfusionLeft = string.format("%1.1f",floor((((bexpirationTime-GetTime())*10)+ 0.5))/10); 
			end	
			if (bn == SoD_Name) then
				SurgeOfDarknessFound	= 1;
				SurgeOfDarknessStacks = bcount;
				SurgeOfDarknessLeft = string.format("%1.1f",floor((((bexpirationTime-GetTime())*10)+ 0.5))/10);
			end
			if (bn == SI_Name) then
				DivInFound = 1;
				DivInLeft = string.format("%1.1f",floor((((bexpirationTime-GetTime())*10)+ 0.5))/10);
			end 
			
			-------------------------------------
			--loop the buffs in the list until we find a match.
			found = false;
			i = 1;
			while found == false and i <= #BuffList do
				local entry = BuffList[i];
				if (entry) then
					if (bn == entry[1]) then
						found = true;

						if (bcount <= 0) then
							bcount = entry[4];
						end

						if (string.lower(entry[2]) == "int") then
							buffscorecurrent = buffscorecurrent + (entry[3] * bcount);
						elseif (string.lower(entry[2]) == "mastery") then
							buffscorecurrent = buffscorecurrent + (entry[3] * bcount * MasteryWeight);
						elseif (string.lower(entry[2]) == "crit") then
							buffscorecurrent = buffscorecurrent + (entry[3] * bcount * CritWeight);
						elseif (string.lower(entry[2]) == "haste") then
							if (CalcHasteNew == 1) then
							--the more accurate haste calculation
								for k = bcount, 1, -1 do
									buffscorehastetemp = (entry[3] / 425.2);
									buffscorehastetemp = (buffscorehastetemp / 100);
									buffscorehastetemp = buffscorehastetemp + 1;
									buffscorehaste     = buffscorehaste * buffscorehastetemp;
								end
								--DEFAULT_CHAT_FRAME:AddMessage("Hastebuff: " .. buffscorehaste);
							else
							--the old standard calculation
								buffscorecurrent = buffscorecurrent + (entry[3] * bcount * HasteWeight);
							end	
						elseif (string.lower(entry[2]) == "damage") then
							for m = bcount, 1, -1 do
								buffscoredamagetemp = buffscoredamagetemp * ((entry[3] / 100) + 1);
							end
						elseif (string.lower(entry[2]) == "spellpower") then
							buffscorecurrent = buffscorecurrent + (entry[3] * bcount * SpellpowerWeight);
						end
					end
				end

				i = i + 1;
			end

			found1 = false;
			j = 1;
			while found1 == false and j <= #ClassBuffList do
				local entry1 = ClassBuffList[j];
				if (entry1) then
					if (bspellId == entry1[1]) then
						found1 = true;

						if (bcount <= 0) then
							bcount = entry1[4];
						end

						if (string.lower(entry1[2]) == "int") then
							buffscorecurrent = buffscorecurrent + (entry1[3] * bcount);
						elseif (string.lower(entry1[2]) == "mastery") then
							buffscorecurrent = buffscorecurrent + (entry1[3] * bcount * MasteryWeight);
						elseif (string.lower(entry1[2]) == "crit") then
							buffscorecurrent = buffscorecurrent + (entry1[3] * bcount * CritWeight);
						elseif (string.lower(entry1[2]) == "haste") then
							if (CalcHasteNew == 1) then
								for l = bcount, 1, -1 do
									if (entry1[3] > 100) then
										buffscorehastetemp = (entry1[3] / 425.2);
									else
										buffscorehastetemp = entry1[3];
									end
									buffscorehastetemp = (buffscorehastetemp / 100);
									buffscorehastetemp = buffscorehastetemp + 1;
									buffscorehaste   = buffscorehaste   * buffscorehastetemp;
								end
								--DEFAULT_CHAT_FRAME:AddMessage("Hastebuff 2: " .. buffscorehaste);
							else
								if (entry1[3] > 100) then
									buffscorehastetemp2 = entry1[3];
								else
									buffscorehastetemp2 = (entry1[3] * 425.2);
								end
								buffscorecurrent = buffscorecurrent + (buffscorehastetemp2 * bcount * HasteWeight);
							end
							--workaround to trigger the +dmg buff of PI
							if (bspellId == PI_ID) then
								found1 = false;
							end
						elseif (string.lower(entry1[2]) == "damage") then
							for n = bcount, 1, -1 do
								buffscoredamagetemp = buffscoredamagetemp * ((entry1[3] / 100) + 1);
								--DEFAULT_CHAT_FRAME:AddMessage("Damage buff summed: " .. buffscoredamagetemp);
							end
						elseif (string.lower(entry1[2]) == "spellpower") then
							buffscorecurrent = buffscorecurrent + (entry1[3] * bcount * SpellpowerWeight);
						end
					end
				end

				j = j + 1;
			end		
				
		end --one buff check finished
	end --finished buff loop check of all buffs
	
	if (fluidity_active) then
		buffscoredamagetemp = buffscoredamagetemp * 1.4;
	end	

	--Has there been an active Haste buff?
	if (CalcHasteNew == 1 and buffscorehaste ~= 1) then
		--Add the HasteWeight to the haste score
		--DEFAULT_CHAT_FRAME:AddMessage("Haste Buff Score Sum: " .. buffscorehaste);
		buffscorehastetemp = (((buffscorehaste -1) *100 ) * 425.2);
		--DEFAULT_CHAT_FRAME:AddMessage("Haste Buff Score Sum after recalculation: " .. buffscorehastetemp);	
		buffscorehaste = buffscorehastetemp * HasteWeight;
		--DEFAULT_CHAT_FRAME:AddMessage("Haste Buff Score with Weight: " .. buffscorehaste);
		--Add the multiplied Hastebuffs to the buffscore
		buffscorecurrent = buffscorecurrent + buffscorehaste;
	else
		--If no Haste buff is active, don't calculate the 1 to the buffscore
	end
	
	--Has there been an active Damage buff?
	if (buffscoredamagetemp ~= 1) then
		--Add the DamageWeight to the Damage score
		--DEFAULT_CHAT_FRAME:AddMessage("Damage Buff Score Sum: " .. buffscoredamagetemp);
		buffscoredamagetemp = buffscoredamagetemp * modifiedint * DamageWeight;
		--DEFAULT_CHAT_FRAME:AddMessage("Damage Buff Score Sum with Weights: " .. buffscoredamagetemp);
		--add the multiplied Damagebuff to the buffscore
		buffscorecurrent = buffscorecurrent + buffscoredamagetemp;
	end
	
	--]]
	
	buffscorecurrent = 100;
	
	local baseInt 							= 5731;
	local baseCritRating				= 1056;
	local baseHasteRating 			= 1369;
	local baseMasteryRating 		= 1602;
	local baseMultistrikeRating = 1025;
	local baseVersatilityRating = 361;
	local baseSpellPower 				= 7945;
	
	local intWeight = 1;
	local spWeight = 0.9;
	local hasteWeight = 0.74;
	local masteryWeight = 0.69;
	local critWeight = 0.68;
	local multiWeight = 0.64;
	local versaWeight = 0.63

	local _, curInt 				= UnitStat("player",4); --int
	local curCritRating 		= GetCombatRating(CR_CRIT_SPELL);
	local curHasteRating 		= GetCombatRating(CR_HASTE_SPELL);
	local curMasteryRating	= GetCombatRating(CR_MASTERY);
	local curMultiRating 		= GetCombatRating(CR_MULTISTRIKE);
	local curSP							= GetSpellBonusDamage(7);
	local curVersaRating		= GetCombatRating(CR_VERSATILITY_DAMAGE_DONE);
	
	local intPercentage = (curInt-baseInt)/baseInt + 1;
	if(intPercentage > 1.001) then buffscorecurrent = buffscorecurrent + 1 * intPercentage * intWeight; end
		--print("Int" .. intPercentage);
	
	local critPercentage = (curCritRating-baseCritRating)/baseCritRating + 1;
	if(critPercentage > 1.001) then buffscorecurrent = buffscorecurrent + 1 * critPercentage * critWeight; end
		--print("Crit " .. critPercentage);	
	
	local hastePercentage = (curHasteRating-baseHasteRating)/baseHasteRating + 1;
	if(hastePercentage > 1.001) then buffscorecurrent = buffscorecurrent + 1 * hastePercentage * hasteWeight; end
		--print("Haste " .. hastePercentage);
	
	local masteryPercentage = (curMasteryRating-baseMasteryRating)/baseMasteryRating + 1;
	if(masteryPercentage > 1.001) then buffscorecurrent = buffscorecurrent + 1 * masteryPercentage * masteryWeight; end
		--print("Mastery " .. masteryPercentage);

	local multistrikePercentage = (curMultiRating-baseMultistrikeRating)/baseMultistrikeRating + 1;
	if(multistrikePercentage > 1.001) then buffscorecurrent = buffscorecurrent + 1 * multistrikePercentage * multiWeight; end
		--print("Multi " .. multistrikePercentage);
	
	local versatilityPercentage = (curVersaRating-baseVersatilityRating)/baseVersatilityRating + 1;
	if(versatilityPercentage > 1.001) then buffscorecurrent = buffscorecurrent + 1 * versatilityPercentage * versaWeight; end
		--print("Versa " .. versatilityPercentage);
	
	local spellPowerPercentage = (curSP-baseSpellPower)/baseSpellPower + 1;
	if(spellPowerPercentage > 1.001) then buffscorecurrent = buffscorecurrent + 1 * spellPowerPercentage * spWeight; end
	--print("SP " .. spellPowerPercentage);

	-- ShadowWord:Death Icon and Display Procedure --
	if ((HideSWD == 0) and (UnitExists("target")) and (UnitCanAttack("player", "target"))) then
		local SWDstart, SWDduration, SWDenabled = GetSpellCooldown(SWD_ID);
		local UnitHP = ceil(((UnitHealth("target")) / (UnitHealthMax("target"))) * 100);
		if  ((UnitHP <= 20) and (UnitHP > 0)) then
			if (SWDstart == 0 and SWDenabled == 1 and ((isincombat == true) or (ShowEverythingOutOfCombat == 1))) then
				SPDT_Texture5:SetTexture(SWD_Icon);
				SPDT_Texture5:SetVertexColor(0.1, 0.6, 0.1);			--green
				SPDT_Texture5:Show();
				Texture5used = true;
				SPDT_TEXT5:Hide();
			else
				SPDT_TEXT5:Hide();
				SPDT_Texture5:Hide();		
				Texture5used = false;	
			end
		else				
			SPDT_TEXT5:Hide();
			SPDT_Texture5:Hide();
			Texture5used = false;
		end
	else
		SPDT_Texture5:Hide();
		SPDT_TEXT5:Hide();
		Texture5used = false;
	end	
	
	--Mindblast Icon and Cooldown Procedure
	if (Texture5used == false) then
		local MBstart, MBduration, MBenabled = GetSpellCooldown(MB_ID);	--MB CD
		local MBLeft = MBduration - (floor((((GetTime()-MBstart)*10)+ 0.5))/10);
		if (HideMB == 0 and MBstart > 0 and MBduration > 1.5 and ((isincombat == true) or (ShowEverythingOutOfCombat == 1))) then
			SPDT_TEXT5:SetText(string.format("%1.1f", MBLeft));
			SPDT_TEXT5:Show();
			SPDT_TEXT5:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE")
			SPDT_Texture5:SetVertexColor(1.0, 1.0, 1.0);		--no colour
			SPDT_Texture5:SetTexture(MB_Icon);		
			SPDT_Texture5:Show();
		elseif (ShowMBOffCD == 1 and HideMB == 0 and ((isincombat == true) or (ShowEverythingOutOfCombat == 1))) then
			SPDT_TEXT5:Hide();
			if (isincombat == true) then
				SPDT_Texture5:SetVertexColor(0.1, 0.6, 0.1);		--green
			else
				SPDT_Texture5:SetVertexColor(1.0, 1.0, 1.0);		--no colour
			end
			SPDT_Texture5:SetTexture(MB_Icon);	
			SPDT_Texture5:Show();
		else
			SPDT_TEXT5:Hide();
			SPDT_Texture5:Hide();
		end
	end
		
	--Shadoworbs Icon and Count Procedure
	if (Texture3used == false) then 
		if (NumOfOrbs > 0 and HideOrbs == 0  and ((isincombat == true) or (ShowDotsSoOutOffCombat == 1) or (ShowEverythingOutOfCombat == 1)) ) then
			SPDT_Texture3:SetTexture(ShadowOrbs_Icon);
			SPDT_Texture3:Show();
			SPDT_TEXT3Above:SetText(NumOfOrbs);
			SPDT_TEXT3Above:Show();
			
			if (NumOfOrbs >= 3) then
				SPDT_Texture3:SetVertexColor(0.1, 0.6, 0.1);		--green
			else if (isincombat == false) then
					SPDT_Texture3:SetVertexColor(1.0, 1.0, 1.0);		--no colour
				else
					SPDT_Texture3:SetVertexColor(0.9, 0.2, 0.2);	--red
				end
			end
			
		else 
			SPDT_Texture3:Hide();
			SPDT_TEXT3:Hide();	
			SPDT_TEXT3Above:Hide();
		end	
	end

	if (PowInf_Check() == true) then
		--PowerInfusion Icon and Cooldown Procedure	
		local PowerInfStart, PowerInfDuration, _ = GetSpellCooldown(PI_ID);	--PowerInfusion CD
		PowerInfCD = PowerInfDuration - (floor((((GetTime()-PowerInfStart)*10)+ 0.5))/10);
		--Cooldown -> No Color
		if (HidePInf == 0 and PowerInfStart > 0 and PowerInfDuration > 0.5 and ((isincombat == true) or (ShowEverythingOutOfCombat == 1))) then
			if (PowerInfusionFound == 1) then
				SPDT_Texture6:SetVertexColor(0.1, 0.6, 0.1);		--green with PowerInfusion Icon
				SPDT_Texture6:SetTexture(PI_Icon);
				SPDT_Texture6:Show();
				SPDT_TEXT6:SetText(PowerInfusionLeft);
				SPDT_TEXT6:Show();
				SPDT_TEXT6Above:Hide()
			else 
				SPDT_Texture6:SetVertexColor(0.9, 0.2, 0.2);		--red with the correct cooldown
				SPDT_Texture6:Show();
				Texture6CD = PowerInfCD;
				SPDT_Texture6:SetTexture(PI_Icon);
				SPDT_TEXT6:SetText(string.format("%1.0f", Texture6CD));
				SPDT_TEXT6:Show();
				SPDT_TEXT6Above:Hide();
			end
		elseif (HidePInf == 0 and ShowPIOffCD == 1 and ((isincombat == true) or (ShowEverythingOutOfCombat == 1))) then
			SPDT_Texture6:SetVertexColor(1.0, 1.0, 1.0);		--no colour
			SPDT_Texture6:Show();
			SPDT_TEXT6Above:Hide();
			SPDT_TEXT6:Hide()
		else
			SPDT_Texture6:Hide();
			SPDT_TEXT6:Hide();
			SPDT_TEXT6Above:Hide();
		end
	end		
		
	if (SI_Check() == true) then
			--Cooldown -> No Color
		if (HidePInf == 0 and DivInFound == 1 and ((isincombat == true) or (ShowEverythingOutOfCombat == 1))) then
			SPDT_Texture6:SetVertexColor(0.1, 0.6, 0.1);		--green with Divine Insight Icon
			SPDT_Texture6:SetTexture(SI_Icon);
			SPDT_Texture6:Show();
			SPDT_TEXT6:SetText(DivInLeft);
			SPDT_TEXT6:Show();
			SPDT_TEXT6Above:Hide()	
		else
			SPDT_Texture6:Hide();
			SPDT_TEXT6:Hide();
			SPDT_TEXT6Above:Hide();
		end
	end
	
	if (SoD_Check() == true) then
		--SurgeOfDarkness Icon Procedure
		--Cooldown -> No Color
		if (HideSoD == 0 and SurgeOfDarknessFound == 1 and ((isincombat == true) or (ShowEverythingOutOfCombat == 1))) then
			SPDT_Texture7:SetVertexColor(0.1, 0.6, 0.1);		--green with Surge of Darkness
			SPDT_Texture7:SetTexture(SoD_Icon);
			SPDT_Texture7:Show();
			SPDT_TEXT7:SetText(SurgeOfDarknessLeft);
			SPDT_TEXT7:Show();
			SPDT_TEXT7Above:SetText(SurgeOfDarknessStacks);
			SPDT_TEXT7Above:Show()
		else
			SPDT_Texture7:Hide();
			SPDT_TEXT7:Hide();
			SPDT_TEXT7Above:Hide();
		end	
	end
	
	if (Mindbender_Check() == true) then
		--Mindbender Icon and CD Procedure
		local MindbenderStart, MindbenderDuration, MindbenderEnabled = GetSpellCooldown(Mindbender_ID);	--Mindbender CD
		MindbenderCD = MindbenderDuration - (floor((((GetTime()-MindbenderStart)*10)+ 0.5))/10);
		if (HideSoD == 0 and MindbenderStart > 0 and MindbenderDuration > 0.5 and ((isincombat == true) or (ShowEverythingOutOfCombat == 1))) then
			MindbenderLeft = string.format("%1.1f", 15.5 + (MindbenderStart - GetTime()));
			if (IsPetAttackActive() == true or MindbenderCD > 45) then
				SPDT_Texture7:SetVertexColor(1.0, 1.0, 1.0);		--no colour
				SPDT_Texture7:SetTexture(Mindbender_Icon);
				SPDT_Texture7:Show();
				SPDT_TEXT7:SetText(MindbenderLeft);
				SPDT_TEXT7:Show();
				SPDT_TEXT7Above:Hide()
			elseif (MindbenderDuration >= 2) then
				SPDT_Texture7:SetVertexColor(0.9, 0.2, 0.2);		--red with the correct cooldown
				SPDT_Texture7:SetTexture(Mindbender_Icon);
				SPDT_Texture7:Show();
				Texture7CD = MindbenderCD;
				SPDT_TEXT7:SetText(string.format("%1.0f", Texture7CD));
				SPDT_TEXT7:Show();
				SPDT_TEXT7Above:Hide();
			end
		else
			SPDT_Texture7:Hide();
			SPDT_TEXT7:Hide();
			SPDT_TEXT7Above:Hide();
		end
	end			

	--Vampiric Embrace Icon and Cooldown Procedure
	local EmbraceStart, EmbraceDuration, EmbraceEnabled = GetSpellCooldown(VE_ID);  --VampiricEmbrace  CD
	EmbraceCD = EmbraceDuration - (floor((((GetTime()-EmbraceStart)*10)+ 0.5))/10); 
	if (HideVEmbrace == 0 and EmbraceStart > 0 and EmbraceDuration > 0.5 and ((isincombat == true) or (ShowEverythingOutOfCombat == 1))) then
		if (EmbraceFound == 1 ) then
			SPDT_Texture8:SetVertexColor(0.1, 0.6, 0.1);		--green
			SPDT_Texture8:Show();
			SPDT_TEXT8:SetText(EmbraceLeft);
			SPDT_TEXT8:Show();
		else
			SPDT_Texture8:SetVertexColor(0.9, 0.2, 0.2);		--red
			SPDT_Texture8:Show();
			SPDT_TEXT8:SetText(string.format("%1.0f", EmbraceCD));
			SPDT_TEXT8:Show();
		end
	elseif (ShowVEOffCD == 1 and HideVEmbrace == 0 and ((isincombat == true) or (ShowEverythingOutOfCombat == 1))) then
		SPDT_Texture8:SetVertexColor(1.0, 1.0, 1.0);		--no colour
		SPDT_Texture8:Show();
		SPDT_TEXT8:Hide()
	else
		SPDT_Texture8:Hide();
		SPDT_TEXT8:Hide();
	end
end

function ShadowPriestDoTTimerFrame_OnLoad(self)
	ShadowPriestDoTTimerFrame:RegisterEvent("PLAYER_LOGOUT");
	ShadowPriestDoTTimerFrame:RegisterEvent("ADDON_LOADED");
	ShadowPriestDoTTimerFrame:RegisterEvent("SAVED_VARIABLES_TOO_LARGE");	
	ShadowPriestDoTTimerFrame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED");
	ShadowPriestDoTTimerFrame:RegisterEvent("PLAYER_REGEN_ENABLED");
	ShadowPriestDoTTimerFrame:RegisterEvent("PLAYER_REGEN_DISABLED");
	ShadowPriestDoTTimerFrame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED");
	ShadowPriestDoTTimerFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
	ShadowPriestDoTTimerFrame:RegisterEvent("PLAYER_ENTERING_WORLD");
	
	local Class = PriestCheck();
	local currentSpec = GetSpecialization();
	if (Class ~= "PRIEST") then
		--not a Priest
		Priest = false;
		DEFAULT_CHAT_FRAME:AddMessage("---Shadow Priest DoT Timer Not Loaded---");
	else -- Is a Priest
		Priest = true;
		--with Shadow Spec
		if (currentSpec == 3) then
			ShadowSpecc = true;
			DEFAULT_CHAT_FRAME:AddMessage("---Shadow Priest DoT Timer Loaded---");
		--with another specc
		else 
			local currentSpecName = currentSpec and select(2, GetSpecializationInfo(currentSpec)) or "None";
			ShadowSpecc = false;
			DEFAULT_CHAT_FRAME:AddMessage("You are now playing in " .. currentSpecName .. " Specc!");
			DEFAULT_CHAT_FRAME:AddMessage("---Shadow Priest DoT Timer turned off---");
		end
	end
	
	SPDT_Texture1:SetTexture(VT_Icon);
	SPDT_Texture2:SetTexture(SWP_Icon);
	SPDT_Texture3:SetTexture(DP_Icon);
	SPDT_Texture5:SetTexture(MB_Icon);
	SPDT_Texture6:SetTexture(PI_Icon);
	SPDT_Texture7:SetTexture(SoD_Icon);
	SPDT_Texture8:SetTexture(VE_Icon);
	
	HideAll();
	
	TimeSinceLastUpdate = 0;

	ShadowPriestDoTTimerFrame:RegisterForDrag("LeftButton", "RightButton");
	ShadowPriestDoTTimerFrame:EnableMouse(false);
end

function ShadowPriestDoTTimerFrame_OnUpdate(elapsed)
	-- check if Class is a Priest
	if (Priest == true) then
		--Specc is Shadow
		if (GetSpecialization() == 3) then
			ShadowSpecc = true;
			TimeSinceLastUpdate = TimeSinceLastUpdate + elapsed; 	
			while (TimeSinceLastUpdate > MyAddon_UpdateInterval) do
				CheckCurrentTargetDeBuffs();
				CheckPlayerBuffs();
		
				if ((isincombat == true) and (HideBuffscore == 0)) then
					SPDT_TEXT4:SetText(string.format("%d", buffscorecurrent));
					SPDT_TEXT4:SetVertexColor(1.0, 0.9, 0.1);	--yellow
					SPDT_TEXT4:Show();
				else
					SPDT_TEXT4:Hide();
				end
				TimeSinceLastUpdate = TimeSinceLastUpdate - MyAddon_UpdateInterval;
			end
		--Check if the specialization has changed to Holy or Disc
		else
			ShadowSpecc = false;
			Priest = false;
			HideAll();
		end
	else
		--Check if the specialization has changed to shadow and Class is Priest
		if (GetSpecialization() == 3 and PriestCheck() == "PRIEST") then
			ShadowSpecc = true;
			Priest = true;
		else
			HideAll();
			--do nothing;
		end
	end
end

function ShadowPriestDoTTimerFrame_OnEvent(self, event, ...)
	local arg1 = ...;

	if ((event == "ADDON_LOADED") and arg1 == ("ShadowPriestDoTTimer")) then
		if (not ShadowPriestDoTTimerFrameScaleFrame) then
			ShadowPriestDoTTimerFrameScaleFrame = 1.0;
		end
		ShadowPriestDoTTimerFrame:SetScale(ShadowPriestDoTTimerFrameScaleFrame);
		SetCooldownOffsets();
	elseif ((event == "SAVED_VARIABLES_TOO_LARGE") and (arg1 == "ShadowPriestDoTTimer")) then
		ShadowPriestDoTTimerFrameScaleFrame = 1.0;
		ShadowPriestDoTTimerFrame:SetScale(ShadowPriestDoTTimerFrameScaleFrame);
		SetCooldownOffsets();
	elseif (event == "PLAYER_LOGOUT") then
		ShadowPriestDoTTimerFrameScaleFrame = ShadowPriestDoTTimerFrame:GetScale();
		local point, relativeTo, relativePoint, xOffset, yOffset;
		point, relativeTo, relativePoint, xOffset, yOffset = self:GetPoint(1);
		ShadowPriestDoTTimerxPosiFrame = xOffset;
	elseif (event == "PLAYER_REGEN_ENABLED") then
		isincombat = false;
	elseif (event == "PLAYER_REGEN_DISABLED") then
		isincombat = true;
	end
end

SLASH_SHADOWPRIESTDOTTIMER1, SLASH_SHADOWPRIESTDOTTIMER2 = '/spdt', '/ShadowPriestDoTTimer';

local function SLASH_SHADOWPRIESTDOTTIMERhandler(msg, editbox)
	if msg == 'show' then
		ShadowPriestDoTTimerFrame:Show();
	elseif  msg == 'hide' then
		ShadowPriestDoTTimerFrame:Hide();
	elseif  msg == 'reset' then
		ShadowPriestDoTTimerFrame:Hide();
		ShadowPriestDoTTimerFrame:Show();
	elseif  msg == 'noconfigmode' then
		if (isincombat == false) then	
			ShadowPriestDoTTimerFrame:EnableMouse(false);
			ShadowPriestDoTTimerFrame:SetBackdrop(nil);
			SetCooldownOffsets();
		else
			print("Please wait for beeing Out of Combat, to stop moving SPDT")	
		end
	elseif  msg == 'configmode' then
		if(isincombat == false) then
			ShadowPriestDoTTimerFrame:EnableMouse(true);
			ShadowPriestDoTTimerFrame:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background", edgeFile= "Interface/Tooltips/UI-Tooltip-Border", edgeSize = 4, tile = false, tileSize =16, insets = { left = 0, right = 0, top = 0, bottom = 0 }});
		else
			print("Please wait for beeing Out of Combat, to move SPDT")
		end
	elseif  msg == 'options' then
		InterfaceOptionsFrame_OpenToCategory("Shadow Priest DoT Timer");
	elseif  msg == 'scale1' then
		ShadowPriestDoTTimerScaleFrame = 0.5
		ShadowPriestDoTTimerFrame:SetScale(ShadowPriestDoTTimerScaleFrame);
	elseif  msg == 'scale2' then
		ShadowPriestDoTTimerScaleFrame = 0.6
		ShadowPriestDoTTimerFrame:SetScale(ShadowPriestDoTTimerScaleFrame);
	elseif  msg == 'scale3' then
		ShadowPriestDoTTimerScaleFrame = 0.7
		ShadowPriestDoTTimerFrame:SetScale(ShadowPriestDoTTimerScaleFrame);
	elseif  msg == 'scale4' then
		ShadowPriestDoTTimerScaleFrame = 0.8
		ShadowPriestDoTTimerFrame:SetScale(ShadowPriestDoTTimerScaleFrame);
	elseif  msg == 'scale5' then
		ShadowPriestDoTTimerScaleFrame = 0.9
		ShadowPriestDoTTimerFrame:SetScale(ShadowPriestDoTTimerScaleFrame);
	elseif  msg == 'scale6' then
		ShadowPriestDoTTimerScaleFrame = 1.0
		ShadowPriestDoTTimerFrame:SetScale(ShadowPriestDoTTimerScaleFrame);
	else
		print("Syntax: /spdt (show | hide | reset | configmode | noconfigmode | options)");
		print("Syntax: /spdt (scale1 | scale2 | scale3 | scale4 | scale5 | scale6)");
	end
end

SlashCmdList["SHADOWPRIESTDOTTIMER"] = SLASH_SHADOWPRIESTDOTTIMERhandler;