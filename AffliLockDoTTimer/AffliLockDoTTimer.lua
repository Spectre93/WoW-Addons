-- Author      : Daniel, Riraeyi@MagtheridonEU
-- Create Date : 21/07/2014
-- Based on http://www.curse.com/addons/wow/shadow-priest-dot-timer by Bathral

local _; -- workaround to prevent leaking globals

local ALDT_UpdateInterval = 0.05; 	-- How often the OnUpdate code will run (in seconds)
local TimeSinceLastUpdate = 0;

local buffscorecurrent = 0;
local buffscoresavedAgony = 0;
local buffscoresavedCorruption = 0;
local buffscoresavedUnstableAffliction = 0;

local firstLoadPerGameStart = true;

--Used to keep track of the DoTs on a Mob.
local moblist = {}; -- GUID, buffScoreAgony, buffScoreCorruption, buffScoreUnstableAffliction, buffScoreSeedOfCorruption
local inCombat = false;
local currentmob = nil;
local maxmoblist = 10;
----------------------------------------------
local agonyID = 980;
local nameAgony, _, iconAgony, _, _, _, _, _, _ = GetSpellInfo(agonyID);
----------------------------------------------
local corruptionID = 172;
local nameCorruption, _, iconCorruption, _, _, _, _ = GetSpellInfo(corruptionID);	
----------------------------------------------
local unstableAfflictionID = 30108;
local nameUnstableAffliction, _, iconUnstableAffliction = GetSpellInfo(unstableAfflictionID);
----------------------------------------------
local seedOfCorruptionID = 27243;
local nameSeedOfCorruption, _, iconSeedOfCorruption = GetSpellInfo(seedOfCorruptionID);
----------------------------------------------
local soulShardID = 117198;
local _, _, iconSoulShard = GetSpellInfo(soulShardID);
----------------------------------------------
local hauntID = 48181; 
local nameHaunt, _, iconHaunt = GetSpellInfo(hauntID);
----------------------------------------------
local miseryID = 113860; 
local nameMisery, _, iconMisery = GetSpellInfo(miseryID);
----------------------------------------------
local soulSwapInhaleID = 86121
local soulSwapExhaleID = 86213; 
local soulSwapSoulBurnID = 119678; 
----------------------------------------------
local spells = {nameAgony, nameCorruption, nameUnstableAffliction, nameSeedOfCorruption, nameHaunt};

function isAffliWarlock()
	local _, englishClass = UnitClass("player");
	if(englishClass == "WARLOCK") then 
		return GetSpecialization() == 1
	end
	return false;
end

local function HideAll()
	--DEFAULT_CHAT_FRAME:AddMessage("HIDE ALL");
	ALDT_Texture1:Hide();
	ALDT_Texture2:Hide();
	ALDT_Texture3:Hide();
	ALDT_Texture4:Hide();
	ALDT_Texture5:Hide();
	ALDT_Texture6:Hide();
	ALDT_Texture7:Hide();
	ALDT_Texture8:Hide();

	ALDT_TEXT1:Hide();
	ALDT_TEXT2:Hide();	
	ALDT_TEXT3:Hide();
	ALDT_TEXT4:Hide();
	ALDT_TEXT5:Hide();
	ALDT_TEXT6:Hide();
	ALDT_TEXT7:Hide();
	ALDT_TEXT8:Hide();
	
	ALDT_TEXT1Above:Hide();
	ALDT_TEXT2Above:Hide();
	ALDT_TEXT3Above:Hide();
	ALDT_TEXT5Above:Hide();
	ALDT_TEXT6Above:Hide();
	ALDT_TEXT7Above:Hide();
	ALDT_TEXT8Above:Hide();
	
	buffscorecurrent = 0;
end

function FindOrCreateCurrentMob()
	--DEFAULT_CHAT_FRAME:AddMessage("FIND OR CREATE MOB");
	local targetguid = UnitGUID("target");
	currentmob = nil;

	if (targetguid) then
		--DEFAULT_CHAT_FRAME:AddMessage("ALDT Player Target: " .. targetguid);
		local i = 1;
		while not currentmob and i <= #moblist do
			if (moblist[i][1] == targetguid) then
				currentmob = moblist[i];
			end
			i = i + 1;
		end

		if (not currentmob) then
			currentmob = {targetguid, 0, 0, 0, 0, 0};
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
	--DEFAULT_CHAT_FRAME:AddMessage("CHECK CURRENT TARGET DEBUFFS");
	for i = 1, 5 do
		local name, _, _, count, _, _, expirationTime, unitCaster, _, _, spellId = UnitDebuff("target", spells[i]);		
		
		if(name and (unitCaster == "player")) then
		--display time left on overlay + colouring
			show(i);
			
			local timeleft = floor((((expirationTime-GetTime())*10)+ 0.5))/10;
			if(timeleft <= 5.0) then
				setText(i, string.format("%1.1f",timeleft));
			else
				setText(i, string.format("%d",timeleft));
			end	
			
			FindOrCreateCurrentMob();
			if (currentmob) then
				setAboveText(i, string.format("%d", currentmob[i+1]));
			end
			
			if(buffscorecurrent > currentmob[i+1]) then
				setAboveTextColour(i, "green");
			else
				setAboveTextColour(i, "yellow");
			end	
			
			if(timeleft < offsets[i]/1000) then
				setTextureColour(i , "red");
			else
				setTextureColour(i, "none");
			end	
		else 
			hide(i);
		end
		
		local name, _, _, _, _, _, expirationTime, _, _, _, _ = UnitBuff("player", nameMisery);
		
		if(name) then
			local timeleft = floor((((expirationTime-GetTime())*10)+ 0.5))/10;
			if(timeleft <= 5.0) then
				ALDT_TEXT8:SetText(string.format("%1.1f",timeleft));
				ALDT_Texture8:SetVertexColor(1.0, 0.9, 0.1);		
			else
				ALDT_TEXT8:SetText(string.format("%d",timeleft));
				ALDT_Texture8:SetVertexColor(1.0,1.0,1.0);
			end	
			ALDT_TEXT8:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE");
			ALDT_TEXT8:SetVertexColor(1.0,1.0,1.0);
			ALDT_TEXT8:Show();
			ALDT_Texture8:Show();
		else
			ALDT_TEXT8Above:Hide();
			ALDT_TEXT8:Hide();
			ALDT_Texture8:Hide();
		end
	end
end

function show(i)
	if(i == 1) then
		ALDT_TEXT1Above:Show();
		ALDT_TEXT1:Show();
		ALDT_Texture1:Show();
	elseif(i == 2) then
		ALDT_TEXT2Above:Show();
		ALDT_TEXT2:Show();
		ALDT_Texture2:Show();
	elseif(i == 3) then
		ALDT_TEXT3Above:Show();
		ALDT_TEXT3:Show();
		ALDT_Texture3:Show();
	elseif(i == 5) then
		--ALDT_TEXT6Above:Show();
		ALDT_TEXT6:Show();
		ALDT_Texture6:Show();
	elseif(i == 4) then
		ALDT_TEXT7Above:Show();
		ALDT_TEXT7:Show();
		ALDT_Texture7:Show();
	end
end

function hide(i)
	if(i == 1) then
		ALDT_TEXT1Above:Hide();
		ALDT_TEXT1:Hide();
		ALDT_Texture1:Hide();
	elseif(i == 2) then
		ALDT_TEXT2Above:Hide();
		ALDT_TEXT2:Hide();
		ALDT_Texture2:Hide();
	elseif(i == 3) then
		ALDT_TEXT3Above:Hide();
		ALDT_TEXT3:Hide();
		ALDT_Texture3:Hide();
	elseif(i == 5) then
		ALDT_TEXT6Above:Hide();
		ALDT_TEXT6:Hide();
		ALDT_Texture6:Hide();
	elseif(i == 4) then
		ALDT_TEXT7Above:Hide();
		ALDT_TEXT7:Hide();
		ALDT_Texture7:Hide();
	end
end

function setText(i, text)
	if(i == 1) then
		ALDT_TEXT1:SetText(text);
		ALDT_TEXT1:SetVertexColor(1.0,1.0,1.0);
		ALDT_TEXT1:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE");
	elseif(i == 2) then
		ALDT_TEXT2:SetText(text);
		ALDT_TEXT2:SetVertexColor(1.0,1.0,1.0);
		ALDT_TEXT2:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE");
	elseif(i == 3) then
		ALDT_TEXT3:SetText(text);
		ALDT_TEXT3:SetVertexColor(1.0,1.0,1.0);
		ALDT_TEXT3:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE");
	elseif(i == 5) then
		ALDT_TEXT6:SetText(text); --ITS 6
		ALDT_TEXT6:SetVertexColor(1.0,1.0,1.0);
		ALDT_TEXT6:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE");
	elseif(i == 4) then
		ALDT_TEXT7:SetText(text);
		ALDT_TEXT7:SetVertexColor(1.0,1.0,1.0);
		ALDT_TEXT7:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE");
	end	
end

function setAboveText(i, text)
	if(i == 1) then
		ALDT_TEXT1Above:SetText(text);
	elseif(i == 2) then
		ALDT_TEXT2Above:SetText(text);
	elseif(i == 3) then
		ALDT_TEXT3Above:SetText(text);
	elseif(i == 5) then		
		ALDT_TEXT6Above:SetText(text);
	elseif(i == 4) then
		ALDT_TEXT7Above:SetText(text);
	end	
end

function setTextureColour(i, textureColour)
	local r = 1.0;
	local b = 1.0;
	local g = 1.0;
	
	if(textureColour == "red") then
		r = 1.0; b = 0.9; g = 0.1;
	elseif(textureColour == "yellow") then 
		r = 1.0; b = 0.9; g = 0.1;
	elseif(textureColour == "green") then 
		r = 0.1; b = 0.6; g = 0.1;
	elseif(textureColour == "none") then 
		r = 1.0; b = 1.0; g = 1.0;
	end	
	
	if(i == 1) then
		ALDT_Texture1:SetVertexColor(r, b, g);
	elseif(i == 2) then
		ALDT_Texture2:SetVertexColor(r, b, g);
	elseif(i == 3) then
		ALDT_Texture3:SetVertexColor(r, b, g);
	elseif(i == 5) then
		ALDT_Texture6:SetVertexColor(r, b, g);
	elseif(i == 4) then
		ALDT_Texture7:SetVertexColor(r, b, g);
	end	
end

function setAboveTextColour(i, textColour)
	local r = 1.0;
	local b = 1.0;
	local g = 1.0;
	
	if(textColour == "red") then
		r = 1.0; b = 0.9; g = 0.1;
	elseif(textColour == "yellow") then 
		r = 1.0; b = 0.9; g = 0.1;
	elseif(textColour == "green") then 
		r = 0.1; b = 0.6; g = 0.1;
	elseif(textColour == "none") then 
		r = 1.0; b = 1.0; g = 1.0;
	end	
	
	if(i == 1) then
		ALDT_TEXT1Above:SetVertexColor(r, b, g);
	elseif(i == 2) then
		ALDT_TEXT2Above:SetVertexColor(r, b, g);
	elseif(i == 3) then
		ALDT_TEXT3Above:SetVertexColor(r, b, g);
	elseif(i == 5) then
		ALDT_TEXT6Above:SetVertexColor(r, b, g);
	elseif(i == 4) then
		ALDT_TEXT7Above:SetVertexColor(r, b, g);
	end	
end

local function CheckPlayerBuffs()	
	local finished = false;
	local found = false;
	local i = 0;
	local j = 0;
	local count = 0;

	buffscorecurrent = 0;
	local buffscorehaste = 0;
	local buffscoredamagetemp = 1;
	local modifiedint = 0;
	local base, stat, posBuff, negBuff = UnitStat("player",4);

	while not finished do
		count = count+1;
		local bn,_,_,bcount,_,bduration,bexpirationTime,_,_,_,bspellId =  UnitBuff("player", count, 0);

		modifiedint = base + buffscorecurrent;
		
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

						if (string.lower(entry[2]) == "int") then
							buffscorecurrent = buffscorecurrent + (entry[3] * bcount);
						elseif (string.lower(entry[2]) == "mastery") then
							buffscorecurrent = buffscorecurrent + (entry[3] * bcount * MasteryWeight);
						elseif (string.lower(entry[2]) == "crit") then
							buffscorecurrent = buffscorecurrent + (entry[3] * bcount * CritWeight);
						elseif (string.lower(entry[2]) == "haste") then
							buffscorecurrent = buffscorecurrent + (entry[3] * bcount * HasteWeight);
						elseif (string.lower(entry[2]) == "damage") then
							for j = bcount, 1, -1 do
								buffscoredamagetemp = buffscoredamagetemp * ((entry[3] / 100) + 1);
							end
						elseif (string.lower(entry[2]) == "spellpower") then
							buffscorecurrent = buffscorecurrent + (entry[3] * bcount * SpellpowerWeight);
						end
					end
				end

				i = i + 1;
			end

			found = false;
			i = 1;
			while found == false and i <= #ClassBuffList do
				local entry1 = ClassBuffList[i];
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
							if (entry1[3] > 100) then
								buffscorehaste = entry1[3];
							else
								buffscorehaste = (entry1[3] * 425.2);
							end
							buffscorecurrent = buffscorecurrent + (buffscorehaste * bcount * HasteWeight);
						elseif (string.lower(entry1[2]) == "damage") then
							for j = bcount, 1, -1 do
								buffscoredamagetemp = buffscoredamagetemp * ((entry1[3] / 100) + 1);
							end
						elseif (string.lower(entry1[2]) == "spellpower") then
							buffscorecurrent = buffscorecurrent + (entry1[3] * bcount * SpellpowerWeight);
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
		buffscoredamagetemp = buffscoredamagetemp * modifiedint * DamageWeight;
		--add the multiplied Damagebuff to the buffscore
		buffscorecurrent = buffscorecurrent + buffscoredamagetemp;
	end
end

function AffliLockDoTTimerFrame_OnLoad(self)			
	AffliLockDoTTimerFrame:RegisterEvent("PLAYER_LOGOUT");
	AffliLockDoTTimerFrame:RegisterEvent("ADDON_LOADED");
	AffliLockDoTTimerFrame:RegisterEvent("SPELLS_CHANGED");
	AffliLockDoTTimerFrame:RegisterEvent("SAVED_VARIABLES_TOO_LARGE");	
	AffliLockDoTTimerFrame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED");
	AffliLockDoTTimerFrame:RegisterEvent("PLAYER_REGEN_ENABLED");
	AffliLockDoTTimerFrame:RegisterEvent("PLAYER_REGEN_DISABLED");
	AffliLockDoTTimerFrame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED");
	AffliLockDoTTimerFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
	AffliLockDoTTimerFrame:RegisterEvent("PLAYER_ENTERING_WORLD");

	TimeSinceLastUpdate = 0;

	AffliLockDoTTimerFrame:RegisterForDrag("LeftButton", "RightButton");
	AffliLockDoTTimerFrame:EnableMouse(false);
end

function CheckSoulShards()
	local amount = UnitPower("player" , 7);
	
	if(inCombat) then
		ALDT_TEXT5:SetText(string.format("%d", amount));
		ALDT_TEXT5:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE");
		ALDT_TEXT5:SetVertexColor(1.0,1.0,1.0);
		ALDT_TEXT5:Show();
		ALDT_Texture5:Show();
	else
		ALDT_TEXT5:Hide();
		ALDT_Texture5:Hide();
	end
end

function AffliLockDoTTimerFrame_OnUpdate(elapsed)
	if (isAffliWarlock()) then
		TimeSinceLastUpdate = TimeSinceLastUpdate + elapsed; 		
		while (TimeSinceLastUpdate > ALDT_UpdateInterval) do
	
			CheckSoulShards();
			CheckCurrentTargetDeBuffs();
			CheckPlayerBuffs();
			
			if (buffscorecurrent > 0) then
				ALDT_TEXT4:SetText(string.format("%d", buffscorecurrent));
				ALDT_TEXT4:SetVertexColor(1.0, 0.9, 0.1);	--yellow
				ALDT_TEXT4:Show();
			else
				ALDT_TEXT4:Hide();
			end
			TimeSinceLastUpdate = TimeSinceLastUpdate - ALDT_UpdateInterval;
		end
	else
		HideAll();
	end
end

function AffliLockDoTTimerFrame_OnEvent(self, event, ...)
	local arg1 = ...;
	
	if (event == "SPELLS_CHANGED" and firstLoadPerGameStart) then
		if (not isAffliWarlock()) then
			HideAll();
			return;
		else
			ALDT_Texture1:SetTexture(iconAgony);				--Agony
			ALDT_Texture2:SetTexture(iconCorruption);			--Corruption
			ALDT_Texture3:SetTexture(iconUnstableAffliction);	--Unstable Affliction
																--hier zit de strength
			ALDT_Texture5:SetTexture(iconSoulShard);			--soul shards
			ALDT_Texture6:SetTexture(iconHaunt);				--haunt	
			ALDT_Texture7:SetTexture(iconSeedOfCorruption);		
			ALDT_Texture8:SetTexture(iconMisery);				--ds misery
			
			firstLoadPerGameStart = false;
			DEFAULT_CHAT_FRAME:AddMessage("[AffliLockDoTTimer] Loaded.");
		end
	end
	
	if (event == "UNIT_SPELLCAST_SUCCEEDED") then
		local unit, _, _, _, spellid = ...;
		if (unit == "player") then
			FindOrCreateCurrentMob();
			if(currentmob) then
				if (spellid == agonyID) then			
					currentmob[2] = buffscorecurrent;						
				elseif (spellid == corruptionID) then
					currentmob[3] = buffscorecurrent;
				elseif (spellid == unstableAfflictionID) then
					currentmob[4] = buffscorecurrent;
				elseif (spellid == seedOfCorruptionID) then
					currentmob[5] = buffscorecurrent;
				elseif (spellid == soulSwapSoulBurnID) then
					currentmob[2] = buffscorecurrent;	
					currentmob[3] = buffscorecurrent;
					currentmob[4] = buffscorecurrent;
				elseif (spellid == soulSwapInhaleID) then
					buffscoresavedAgony = currentmob[2];
					buffscoresavedCorruption = currentmob[3];
					buffscoresavedUnstableAffliction = currentmob[4];
				elseif (spellid == soulSwapExhaleID) then
					currentmob[2] = buffscoresavedAgony;	
					currentmob[3] = buffscoresavedCorruption;
					currentmob[4] = buffscoresavedUnstableAffliction;
				end	
			end
		end
	elseif ((event == "ADDON_LOADED") and arg1 == ("AffliLockDoTTimer")) then
		if (not AffliLockDoTTimerFrameScaleFrame) then
			AffliLockDoTTimerFrameScaleFrame = 1.0;
		end
		AffliLockDoTTimerFrame:SetScale(AffliLockDoTTimerFrameScaleFrame);
	elseif ((event == "SAVED_VARIABLES_TOO_LARGE") and (arg1 == "AffliLockDoTTimer")) then
		AffliLockDoTTimerFrameScaleFrame = 1.0;
		AffliLockDoTTimerFrame:SetScale(AffliLockDoTTimerFrameScaleFrame);
	elseif (event == "PLAYER_LOGOUT") then
		AffliLockDoTTimerFrameScaleFrame = AffliLockDoTTimerFrame:GetScale();
		local point, relativeTo, relativePoint, xOffset, yOffset;
		point, relativeTo, relativePoint, xOffset, yOffset = self:GetPoint(1);
		AffliLockDoTTimerxPosiFrame = xOffset;
	elseif (event == "PLAYER_REGEN_ENABLED") then
		inCombat = false;
	elseif (event == "PLAYER_REGEN_DISABLED") then
		inCombat = true;
	end
end

SLASH_AFFLILOCKDOTTIMER1, AFFLILOCKDOTTIMER2 = '/aldt', '/AFFLILOCKDOTTIMER';

local function SLASH_AFFLILOCKDOTTIMERhandler(msg, editbox)
	
	if msg == 'show' then
		AffliLockDoTTimerFrame:Show();
	elseif  msg == 'hide' then
		AffliLockDoTTimerFrame:Hide();
	elseif  msg == 'reset' then
		AffliLockDoTTimerFrame:Hide();
		AffliLockDoTTimerFrame:Show();
		ClearMobList();
	elseif  msg == 'clear' then
		ClearMobList();
	elseif  msg == 'noconfigmode' then
		AffliLockDoTTimerFrame:EnableMouse(false);
		AffliLockDoTTimerFrame:SetBackdrop(nil);
	elseif  msg == 'configmode' then
		AffliLockDoTTimerFrame:EnableMouse(true);
		AffliLockDoTTimerFrame:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background", edgeFile= "Interface/Tooltips/UI-Tooltip-Border", edgeSize = 4, tile = false, tileSize =16, insets = { left = 0, right = 0, top = 0, bottom = 0 }});
	elseif  msg == 'options' then
		InterfaceOptionsFrame_OpenToCategory("AffliLockDoTTimer");
	elseif  msg == 'scale1' then
		AffliLockDoTTimerScaleFrame = 0.5
		AffliLockDoTTimerFrame:SetScale(AffliLockDoTTimerScaleFrame);
	elseif  msg == 'scale2' then
		AffliLockDoTTimerScaleFrame = 0.6
		AffliLockDoTTimerFrame:SetScale(AffliLockDoTTimerScaleFrame);
	elseif  msg == 'scale3' then
		AffliLockDoTTimerScaleFrame = 0.7
		AffliLockDoTTimerFrame:SetScale(AffliLockDoTTimerScaleFrame);
	elseif  msg == 'scale4' then
		AffliLockDoTTimerScaleFrame = 0.8
		AffliLockDoTTimerFrame:SetScale(AffliLockDoTTimerScaleFrame);
	elseif  msg == 'scale5' then
		AffliLockDoTTimerScaleFrame = 0.9
		AffliLockDoTTimerFrame:SetScale(AffliLockDoTTimerScaleFrame);
	elseif  msg == 'scale6' then
		AffliLockDoTTimerScaleFrame = 1.0
		AffliLockDoTTimerFrame:SetScale(AffliLockDoTTimerScaleFrame);
	else
		print("Syntax: /ALDT (show | hide | reset | configmode | noconfigmode | options | clearmoblist )");
		print("Syntax: /ALDT (scale1 | scale2 | scale3 | scale4 | scale5 | scale6)");
	end
end

SlashCmdList["AFFLILOCKDOTTIMER"] = SLASH_AFFLILOCKDOTTIMERhandler;