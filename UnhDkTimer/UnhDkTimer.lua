-- Author      : Daniel, Riraeyi@MagtheridonEU
-- Create Date : 29/07/2014
-- Based on http://www.curse.com/addons/wow/shadow-priest-dot-timer by Bathral

local _; -- workaround to prevent leaking globals

local UDKT_UpdateInterval = 0.05; 	-- How often the OnUpdate code will run (in seconds)
local TimeSinceLastUpdate = 0;
local firstLoadPerGameStart = true;
local buffscorecurrent = 0;

--Used to keep track of the DoTs on a Mob.
local moblist = {}; -- GUID, buffScoreHemorrhage, buffScoreRupture, buffScoreGarrote, buffScoreCrimsonTempest
local inCombat = false;
local currentmob = nil;
local maxmoblist = 10;
----------------------------------------------
--Frost Fever
--Blood Plague
--Shadow Infusion + Dark Transformation
--Buffscore
--Anti-Magic Shell
--Death and Decay
--Unholy Frenzy + Summon Gargoyle
--Soul Reaper

----------------------------------------------
local icyTouchID = 45477;
local nameIcyTouch, _, _ = GetSpellInfo(icyTouchID);	
----------------------------------------------
local plagueStrikeID = 45462;
local namePlagueStrike, _, _ = GetSpellInfo(plagueStrikeID);	
----------------------------------------------
local festeringStrikeID = 85948;
local nameFesteringStrike, _, _ = GetSpellInfo(festeringStrikeID);	

----------------------------------------------
local frostFeverID = 59921;
local nameFrostFever, _, iconFrostFever = GetSpellInfo(frostFeverID);
----------------------------------------------
local bloodPlagueID = 59879;
local nameBloodPlague, _, iconBloodPlague = GetSpellInfo(bloodPlagueID);	
----------------------------------------------
local shadowInfusionID 	= 49572;
local nameShadowInfusion, _, iconShadowInfusion = GetSpellInfo(shadowInfusionID);	
----------------------------------------------
local darkTransformationID = 63560;
local nameDarkTransformation, _, iconDarkTransformation = GetSpellInfo(darkTransformationID);	
----------------------------------------------
local antiMagicShellID = 48707;
local nameAntiMagicShell, _, iconAntiMagicShell = GetSpellInfo(antiMagicShellID);
----------------------------------------------
local deathAndDecayID = 43265;	
local nameDeathAndDecay, _, iconDeathAndDecay = GetSpellInfo(deathAndDecayID);
----------------------------------------------
local unholyFrenzyID = 49016;
local nameUnholyFrenzy, _, iconUnholyFrenzy = GetSpellInfo(unholyFrenzyID);
----------------------------------------------
local summonGargoyleID = 49206;
local nameSummonGargoyle, _, iconSummonGargoyle = GetSpellInfo(summonGargoyleID);
----------------------------------------------
local soulReaperID = 130736;	 
local nameSoulReaper, _, iconSoulReaper = GetSpellInfo(soulReaperID);
----------------------------------------------

function isUnhDk()
	local _, englishClass = UnitClass("player");
	if(englishClass == "DEATHKNIGHT") then 
		return GetSpecialization() == 3;
	end
	return false;
end

local function HideAll()
	UDKT_Texture1:Hide();
	UDKT_Texture2:Hide();
	UDKT_Texture3:Hide();
	UDKT_Texture4:Hide();
	UDKT_Texture5:Hide();
	UDKT_Texture6:Hide();
	UDKT_Texture7:Hide();
	UDKT_Texture8:Hide();

	UDKT_TEXT1:Hide();
	UDKT_TEXT2:Hide();	
	UDKT_TEXT3:Hide();
	UDKT_TEXT4:Hide();
	UDKT_TEXT5:Hide();
	UDKT_TEXT6:Hide();
	UDKT_TEXT7:Hide();
	UDKT_TEXT8:Hide();
	
	UDKT_TEXT1Above:Hide();
	UDKT_TEXT2Above:Hide();
	UDKT_TEXT3Above:Hide();
	UDKT_TEXT5Above:Hide();
	UDKT_TEXT6Above:Hide();
	UDKT_TEXT7Above:Hide();
	UDKT_TEXT8Above:Hide();
end

function FindOrCreateCurrentMob()
	local targetguid = UnitGUID("target");
	currentmob = nil;

	if (targetguid) then
		local i = 1;
		while not currentmob and i <= #moblist do
			if (moblist[i][1] == targetguid) then
				currentmob = moblist[i];
			end
			i = i + 1;
		end

		if (not currentmob) then
			currentmob = {targetguid, 0, 0};
			table.insert(moblist, currentmob);
		end
	end
end

local function ClearMobList()
	for i = 1, #moblist do
		table.remove(moblist, i);
	end
	currentmob = nil;
end

local function CheckCurrentTargetDeBuffs()	
	local timeLeftFrostFever = 0;
	local timeLeftBloodPlague = 0;
	
	local name, _, _, _, _, _, expirationTime, unitCaster, _, _, spellId = UnitDebuff("target", nameFrostFever);	
	if(name and (unitCaster == "player")) then
		timeLeftFrostFever = floor((((expirationTime-GetTime())*10)+ 0.5))/10;			
	end
	---------------------------------------------
	local name, _, _, _, _, _, expirationTime, unitCaster, _, _, spellId = UnitDebuff("target", nameBloodPlague);	
	if(name and (unitCaster == "player")) then
		timeLeftBloodPlague = floor((((expirationTime-GetTime())*10)+ 0.5))/10;
	end
	---------------------------------------------
	
	FindOrCreateCurrentMob();
	
	UDKT_TEXT1:SetVertexColor(1.0,1.0,1.0);
	UDKT_TEXT1:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE");
	
	if(timeLeftFrostFever > 0) then
		UDKT_TEXT1Above:Show();
		UDKT_TEXT1:Show();
		UDKT_Texture1:Show();
		
		if(timeLeftFrostFever <= offsetPlagues/1000) then
			UDKT_TEXT1:SetText(string.format("%1.1f",timeLeftFrostFever));
			UDKT_Texture1:SetVertexColor(1.0, 1.0, 0.0);	
		else
			UDKT_TEXT1:SetText(string.format("%d",timeLeftFrostFever));
			UDKT_Texture1:SetVertexColor(1.0, 1.0, 1.0);
		end
		
		if(currentmob) then
			UDKT_TEXT1Above:SetText(string.format("%d",currentmob[2]));
			
			if(buffscorecurrent > currentmob[2]) then
				UDKT_TEXT1Above:SetVertexColor(0.0, 1.0, 0.0); --green
			else
				UDKT_TEXT1Above:SetVertexColor(1.0, 1.0, 0.0); --none		
			end	
		else
			UDKT_TEXT1Above:Hide();
		end
	else
		UDKT_TEXT1Above:Hide();
		UDKT_TEXT1:Hide();
		UDKT_Texture1:Hide();
	end
	
	UDKT_TEXT2:SetVertexColor(1.0,1.0,1.0);
	UDKT_TEXT2:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE");
	
	if(timeLeftBloodPlague > 0) then
		UDKT_TEXT2Above:Show();
		UDKT_TEXT2:Show();
		UDKT_Texture2:Show();
		
		if(timeLeftBloodPlague <= offsetPlagues/1000) then
			UDKT_TEXT2:SetText(string.format("%1.1f",timeLeftBloodPlague));
			UDKT_Texture2:SetVertexColor(1.0, 1.0, 0.0);	
		else
			UDKT_TEXT2:SetText(string.format("%d",timeLeftBloodPlague));
			UDKT_Texture2:SetVertexColor(1.0, 1.0, 1.0);
		end
		
		if(currentmob) then
			UDKT_TEXT2Above:SetText(string.format("%d",currentmob[3]));
			
			if(buffscorecurrent > currentmob[3]) then
				UDKT_TEXT2Above:SetVertexColor(0.0, 1.0, 0.0); --green
			else
				UDKT_TEXT2Above:SetVertexColor(1.0, 1.0, 0.0); --none		
			end	
		else
			UDKT_TEXT2Above:Hide();
		end
	else
		UDKT_TEXT2Above:Hide();
		UDKT_TEXT2:Hide();
		UDKT_Texture2:Hide();
	end	
end

local function CheckPlayerCooldowns()
	local start, duration, enabled = GetSpellCooldown(deathAndDecayID);
	UDKT_Texture6:Show();
	if(start) then
		if(duration == 0) then
			UDKT_Texture6:SetVertexColor(1.0,1.0,1.0);
			UDKT_TEXT6:Hide();
			UDKT_TEXT6Above:Hide();
		else
			UDKT_TEXT6:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE");
			UDKT_TEXT6:SetVertexColor(1.0,1.0,1.0);
			UDKT_TEXT6:SetText(string.format("%d", floor((((duration - (GetTime() - start))*10)+ 0.5))/10));
			UDKT_TEXT6:Show();
			UDKT_Texture6:SetVertexColor(1.0,0.0,0.0);	
		end
	end
	UDKT_Texture8:Hide();
	UDKT_TEXT8:Hide();
	UDKT_TEXT8Above:Hide();
	
	local unitHpPercentage = ceil(((UnitHealth("target")) / (UnitHealthMax("target"))) * 100);
	
	if(unitHpPercentage) then
		local start, duration, enabled = GetSpellCooldown(nameSoulReaper);	
		if(start and unitHpPercentage < 35 and unitHpPercentage ~= 0) then
			UDKT_Texture8:Show();
			if(duration == 0) then
				UDKT_Texture8:SetVertexColor(1.0,1.0,1.0);	
				UDKT_TEXT8:Hide();
				UDKT_TEXT8Above:Hide();
			else
				UDKT_TEXT8:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE");
				UDKT_TEXT8:SetVertexColor(1.0,1.0,1.0);
				UDKT_TEXT8:SetText(string.format("%d", floor((((duration - (GetTime() - start))*10)+ 0.5))/10));
				UDKT_TEXT8:Show();
				UDKT_Texture8:SetVertexColor(1.0,0.0,0.0);	
			end
		else
			UDKT_Texture8:Hide();
		end
	end
end

local function CheckPlayerBuffs()
	local name, _, _, count, _, _, expirationTime, _, _, _, _ = UnitBuff("player", nameShadowInfusion);
	
	if(name) then
		local timeleft = floor((((expirationTime-GetTime())*10)+ 0.5))/10;
		UDKT_TEXT3:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE");
		UDKT_TEXT3:SetVertexColor(1.0,1.0,1.0);
		UDKT_TEXT3:SetText(string.format("%d", count));
		UDKT_TEXT3:Show();
		
		UDKT_Texture3:SetVertexColor(1.0,1.0,1.0);	
		UDKT_Texture3:Show();
	else
		UDKT_TEXT3Above:Hide();
		UDKT_TEXT3:Hide();
		UDKT_Texture3:Hide();
	end
	
	local name, _, _, _, _, _, expirationTime, _, _, _, _ = UnitBuff("player", nameAntiMagicShell);
	
	local start, duration, enabled = GetSpellCooldown(antiMagicShellID);
	UDKT_Texture5:Show();
	if(start) then
		if(duration == 0) then
			UDKT_Texture5:SetVertexColor(1.0,1.0,1.0);
			UDKT_TEXT5:Hide();
			UDKT_TEXT5Above:Hide();
		else
			UDKT_TEXT5:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE");
			UDKT_TEXT5:SetVertexColor(1.0,1.0,1.0);
			UDKT_TEXT5:SetText(string.format("%d", floor((((duration - (GetTime() - start))*10)+ 0.5))/10));
			UDKT_TEXT5:Show();
			UDKT_Texture5:SetVertexColor(1.0,0.0,0.0);	
		end
	end
	
	if(name) then
		local timeleft = floor((((expirationTime-GetTime())*10)+ 0.5))/10;
		UDKT_TEXT5:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE");
		UDKT_TEXT5:SetVertexColor(1.0,1.0,1.0);
		UDKT_TEXT5:SetText(string.format("%d",timeleft));
		UDKT_TEXT5:Show();
		
		UDKT_Texture5:SetVertexColor(1.0,1.0,1.0);
		UDKT_Texture5:Show();
	else
		UDKT_TEXT5Above:Hide();
		--UDKT_TEXT5:Hide();
		--UDKT_Texture5:Hide();
	end
	
	local name, _, _, _, _, _, expirationTime, _, _, _, _ = UnitBuff("player", nameUnholyFrenzy);
	
	local start, duration, enabled = GetSpellCooldown(unholyFrenzyID);
	UDKT_Texture7:Show();
	if(start) then
		if(duration == 0) then
			UDKT_Texture7:SetVertexColor(1.0,1.0,1.0);
			UDKT_TEXT7:Hide();
			UDKT_TEXT7Above:Hide();
		else
			UDKT_TEXT7:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE");
			UDKT_TEXT7:SetVertexColor(1.0,1.0,1.0);
			UDKT_TEXT7:SetText(string.format("%d", floor((((duration - (GetTime() - start))*10)+ 0.5))/10));
			UDKT_TEXT7:Show();
			UDKT_Texture7:SetVertexColor(1.0,0.0,0.0);	
		end
	end
	
	
	if(name) then
		local timeleft = floor((((expirationTime-GetTime())*10)+ 0.5))/10;
		UDKT_TEXT7:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE");
		UDKT_TEXT7:SetVertexColor(1.0,1.0,1.0);
		UDKT_TEXT7:SetText(string.format("%d",timeleft));
		UDKT_TEXT7:Show();
		
		UDKT_Texture7:SetVertexColor(1.0,1.0,1.0);
		UDKT_Texture7:Show();
	else
		UDKT_TEXT7Above:Hide();
		--UDKT_TEXT7:Hide();
		--UDKT_Texture7:Hide();
	end
		
	local finished = false;
	local found = false;
	local i = 0;
	local j = 0;
	local count = 0;

	buffscorecurrent = 0;
	local buffscorehaste = 0;
	local buffscorestrength = 0;
	local buffscoredamagetemp = 1;
	local baseStrength = UnitStat("player",1);
	local modifiedStrength = 0;

	while not finished do
		count = count+1;
		local bn,_,_,bcount,_,_,bexpirationTime,_,_,_,bspellId =  UnitBuff("player", count, 0);

		modifiedStrength = baseStrength + buffscorecurrent;
		
		if not bn then
			finished = true;
		else		
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

						if (string.lower(entry[2]) == "strength") then
							buffscorecurrent = buffscorecurrent + (entry[3] * bcount);
						elseif (string.lower(entry[2]) == "mastery") then
							buffscorecurrent = buffscorecurrent + (entry[3] * bcount * MasteryWeight);
						elseif (string.lower(entry[2]) == "crit") then
							buffscorecurrent = buffscorecurrent + (entry[3] * bcount * CritWeight);
						elseif (string.lower(entry[2]) == "haste") then
							if (entry[3] > 100) then
								buffscorehaste = entry[3];
							else
								buffscorehaste = (entry[3] * 425.2);
							end
							buffscorecurrent = buffscorecurrent + (buffscorehaste * bcount * HasteWeight);
						elseif (string.lower(entry[2]) == "damage") then
							for j = bcount, 1, -1 do
								buffscoredamagetemp = buffscoredamagetemp * ((entry[3] / 100) + 1);
							end
						elseif (string.lower(entry[2]) == "attackpower") then
							buffscorecurrent = buffscorecurrent + (entry[3] * bcount * AttackPowerWeight);
						end
					end
				end
				i = i + 1;
			end

			found = false;
			i = 1;
			while found == false and i <= #ClassBuffList do
				local entry = ClassBuffList[i];
				if (entry) then
					if (bspellId == entry[1]) then
						found1 = true;

						if (bcount <= 0) then
							bcount = entry[4];
						end

						if (string.lower(entry[2]) == "strength") then
							if (entry[3] > 100) then
								buffscorestrength = entry[3];
							else
								buffscorestrength = (entry[3] * 425.2);
							end
							buffscorecurrent = buffscorecurrent + (buffscorestrength * bcount);
						elseif (string.lower(entry[2]) == "mastery") then
							buffscorecurrent = buffscorecurrent + (entry[3] * bcount * MasteryWeight);
						elseif (string.lower(entry[2]) == "crit") then
							buffscorecurrent = buffscorecurrent + (entry[3] * bcount * CritWeight);
						elseif (string.lower(entry[2]) == "haste") then
							if (entry[3] > 100) then
								buffscorehaste = entry[3];
							else
								buffscorehaste = (entry[3] * 425.2);
							end
							buffscorecurrent = buffscorecurrent + (buffscorehaste * bcount * HasteWeight);
						elseif (string.lower(entry[2]) == "damage") then
							for j = bcount, 1, -1 do
								buffscoredamagetemp = buffscoredamagetemp * ((entry[3] / 100) + 1);
							end
						elseif (string.lower(entry[2]) == "attackpower") then
							buffscorecurrent = buffscorecurrent + (entry[3] * bcount * AttackPowerWeight);
						end
					end
				end
				i = i + 1;
			end		
				
		end --one buff check finished
	end --finished buff loop check of all buffs
	
	--Has there been an active Damage buff?
	if (buffscoredamagetemp ~= 1) then
		--Add the DamageWeight to the Damage score
		buffscoredamagetemp = buffscoredamagetemp * modifiedStrength * DamageWeight;
		--add the multiplied Damagebuff to the buffscore
		buffscorecurrent = buffscorecurrent + buffscoredamagetemp;
	end
end

function UnhDkTimerFrame_OnLoad(self)				
	UnhDkTimerFrame:RegisterEvent("PLAYER_LOGOUT");
	UnhDkTimerFrame:RegisterEvent("ADDON_LOADED");
	UnhDkTimerFrame:RegisterEvent("SPELLS_CHANGED");	
	UnhDkTimerFrame:RegisterEvent("SAVED_VARIABLES_TOO_LARGE");	
	UnhDkTimerFrame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED");
	UnhDkTimerFrame:RegisterEvent("PLAYER_REGEN_ENABLED");
	UnhDkTimerFrame:RegisterEvent("PLAYER_REGEN_DISABLED");
	UnhDkTimerFrame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED");
	UnhDkTimerFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
	UnhDkTimerFrame:RegisterEvent("PLAYER_ENTERING_WORLD");
	
	TimeSinceLastUpdate = 0;

	UnhDkTimerFrame:RegisterForDrag("LeftButton", "RightButton");
	UnhDkTimerFrame:EnableMouse(false);
end

function UnhDkTimerFrame_OnUpdate(elapsed)
	if (isUnhDk()) then
		TimeSinceLastUpdate = TimeSinceLastUpdate + elapsed; 		
		while (TimeSinceLastUpdate > UDKT_UpdateInterval) do
		
			CheckPlayerCooldowns();
			CheckCurrentTargetDeBuffs();
			CheckPlayerBuffs();
			
			if (buffscorecurrent > 0) then
				UDKT_TEXT4:SetText(string.format("%d", buffscorecurrent));
				UDKT_TEXT4:SetVertexColor(1.0, 1.0, 0.0);	--yellow
				UDKT_TEXT4:Show();
			else
				UDKT_TEXT4:Hide();
			end
			TimeSinceLastUpdate = TimeSinceLastUpdate - UDKT_UpdateInterval;
		end
	else
		HideAll();
	end
end

function UnhDkTimerFrame_OnEvent(self, event, ...)
	local arg1 = ...;
	
	if (event == "SPELLS_CHANGED" and firstLoadPerGameStart) then
		if (not isUnhDk()) then
			HideAll();
			return;
		else
			UDKT_Texture1:SetTexture(iconFrostFever);
			UDKT_Texture2:SetTexture(iconBloodPlague);		
			UDKT_Texture3:SetTexture(iconShadowInfusion);
															--buffstrength
			UDKT_Texture5:SetTexture(iconAntiMagicShell);
			UDKT_Texture6:SetTexture(iconDeathAndDecay);
			UDKT_Texture7:SetTexture(iconUnholyFrenzy);
			UDKT_Texture8:SetTexture(iconSoulReaper);
			
			firstLoadPerGameStart = false;
			DEFAULT_CHAT_FRAME:AddMessage("[UnhDkTimer] Loaded.");
		end
	end
	
	if (event == "UNIT_SPELLCAST_SUCCEEDED") then
		local unit, _, _, _, spellid = ...;
		if (unit == "player") then
			FindOrCreateCurrentMob();
			if(currentmob) then
				if (spellid == icyTouchID) then		
					currentmob[2] = buffscorecurrent;
				elseif (spellid == plagueStrikeID) then
					currentmob[2] = buffscorecurrent;
					currentmob[3] = buffscorecurrent;
				--elseif pestilence/blood boil
				end	
			end
		end
	elseif ((event == "ADDON_LOADED") and arg1 == ("UnhDkTimer")) then
		if (not UnhDkTimerFrameScaleFrame) then
			UnhDkTimerFrameScaleFrame = 1.0;
		end
		UnhDkTimerFrame:SetScale(UnhDkTimerFrameScaleFrame);
	elseif (event == "PLAYER_LOGOUT") then
		UnhDkTimerFrameScaleFrame = UnhDkTimerFrame:GetScale();
		local point, relativeTo, relativePoint, xOffset, yOffset;
		point, relativeTo, relativePoint, xOffset, yOffset = self:GetPoint(1);
		UnhDkTimerxPosiFrame = xOffset;
	elseif (event == "PLAYER_REGEN_ENABLED") then
		inCombat = false;
	elseif (event == "PLAYER_REGEN_DISABLED") then
		inCombat = true;
	end
end

SLASH_UnhDkTimer1, UnhDkTimer2 = '/UDKT', '/UnhDkTimer';

local function SLASH_UnhDkTimerhandler(msg, editbox)
	
	if msg == 'show' then
		UnhDkTimerFrame:Show();
	elseif  msg == 'hide' then
		UnhDkTimerFrame:Hide();
	elseif  msg == 'reset' then
		UnhDkTimerFrame:Hide();
		UnhDkTimerFrame:Show();
		ClearMobList();
	elseif  msg == 'clear' then
		ClearMobList();
	elseif  msg == 'noconfigmode' then
		UnhDkTimerFrame:EnableMouse(false);
		UnhDkTimerFrame:SetBackdrop(nil);
	elseif  msg == 'configmode' then
		UnhDkTimerFrame:EnableMouse(true);
		UnhDkTimerFrame:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background", edgeFile= "Interface/Tooltips/UI-Tooltip-Border", edgeSize = 4, tile = false, tileSize =16, insets = { left = 0, right = 0, top = 0, bottom = 0 }});
	elseif  msg == 'options' then
		InterfaceOptionsFrame_OpenToCategory("UnhDkTimer");
	elseif  msg == 'scale1' then
		UnhDkTimerScaleFrame = 0.5
		UnhDkTimerFrame:SetScale(UnhDkTimerScaleFrame);
	elseif  msg == 'scale2' then
		UnhDkTimerScaleFrame = 0.6
		UnhDkTimerFrame:SetScale(UnhDkTimerScaleFrame);
	elseif  msg == 'scale3' then
		UnhDkTimerScaleFrame = 0.7
		UnhDkTimerFrame:SetScale(UnhDkTimerScaleFrame);
	elseif  msg == 'scale4' then
		UnhDkTimerScaleFrame = 0.8
		UnhDkTimerFrame:SetScale(UnhDkTimerScaleFrame);
	elseif  msg == 'scale5' then
		UnhDkTimerScaleFrame = 0.9
		UnhDkTimerFrame:SetScale(UnhDkTimerScaleFrame);
	elseif  msg == 'scale6' then
		UnhDkTimerScaleFrame = 1.0
		UnhDkTimerFrame:SetScale(UnhDkTimerScaleFrame);
	else
		print("Syntax: /UDKT (show | hide | reset | configmode | noconfigmode | options | clearmoblist )");
		print("Syntax: /UDKT (scale1 | scale2 | scale3 | scale4 | scale5 | scale6)");
	end
end

SlashCmdList["UnhDkTimer"] = SLASH_UnhDkTimerhandler;