-- Author      : Daniel, Riraeyi@MagtheridonEU
-- Create Date : 27/07/2014
-- Based on http://www.curse.com/addons/wow/shadow-priest-dot-timer by Bathral

local _; -- workaround to prevent leaking globals

local SRT_UpdateInterval = 0.05; 	-- How often the OnUpdate code will run (in seconds)
local TimeSinceLastUpdate = 0;
local firstLoadPerGameStart = true;
local buffscorecurrent = 0;

--Used to keep track of the DoTs on a Mob.
local moblist = {}; -- GUID, buffScoreHemorrhage, buffScoreRupture, buffScoreGarrote, buffScoreCrimsonTempest
local inCombat = false;
local currentmob = nil;
local maxmoblist = 10;
----------------------------------------------
local hemorrhageID = 16511;
local nameHemorrhage, _, iconHemorrhage = GetSpellInfo(hemorrhageID);
----------------------------------------------
local ruptureID = 1943;
local nameRupture, _, iconRupture = GetSpellInfo(ruptureID);	
----------------------------------------------
local crimsonTempestID 	= 121411;
local nameCrimsonTempest, _, iconCrimsonTempest = GetSpellInfo(crimsonTempestID);	
----------------------------------------------
local garroteID = 703;
local nameGarrote, _, iconGarrote = GetSpellInfo(garroteID);	
----------------------------------------------
local sliceAndDiceID = 5171;
local nameSliceAndDice, _, iconSliceAndDice = GetSpellInfo(sliceAndDiceID);
----------------------------------------------
local recuperateID = 73651;	
local nameRecuperate, _, iconRecuperate = GetSpellInfo(recuperateID);
----------------------------------------------
local findWeaknessID = 91023;
local nameFindWeakness, _, iconFindWeakness = GetSpellInfo(findWeaknessID);
----------------------------------------------
local sanguinaryVeinID = 79147;	 
local _, _, iconSanguinaryVein = GetSpellInfo(sanguinaryVeinID);
----------------------------------------------
local anticipationID = 114015;	 
local nameAnticipation, _, iconAnticipation = GetSpellInfo(anticipationID);
----------------------------------------------
local shadowDanceID = 51713;	 
local nameShadowDance, _, iconShadowDance = GetSpellInfo(shadowDanceID);
----------------------------------------------

function isSubRogue()
	local _, englishClass = UnitClass("player");
	if(englishClass == "ROGUE") then 
		return GetSpecialization() == 3;
	end
	return false;
end

local function HideAll()
	SRT_Texture1:Hide();
	SRT_Texture2:Hide();
	SRT_Texture3:Hide();
	SRT_Texture4:Hide();
	SRT_Texture5:Hide();
	SRT_Texture6:Hide();
	SRT_Texture7:Hide();
	SRT_Texture8:Hide();

	SRT_TEXT1:Hide();
	SRT_TEXT2:Hide();	
	SRT_TEXT3:Hide();
	SRT_TEXT4:Hide();
	SRT_TEXT5:Hide();
	SRT_TEXT6:Hide();
	SRT_TEXT7:Hide();
	SRT_TEXT8:Hide();
	
	SRT_TEXT1Above:Hide();
	SRT_TEXT2Above:Hide();
	SRT_TEXT3Above:Hide();
	SRT_TEXT5Above:Hide();
	SRT_TEXT6Above:Hide();
	SRT_TEXT7Above:Hide();
	SRT_TEXT8Above:Hide();
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
			currentmob = {targetguid, 0, 0, 0, 0};
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
	local timeLeftHemorrhage = 0;
	local timeLeftSanguinaryVein = 0;
	local timeLeftRupture = 0;
	---------------------------------------------
	local name, _, _, _, _, _, expirationTime, unitCaster, _, _, spellId = UnitDebuff("target", nameHemorrhage);	
	if(name and (unitCaster == "player")) then
		timeLeftHemorrhage = floor((((expirationTime-GetTime())*10)+ 0.5))/10;		
		if(hasGlyphOfHemorrhagingVeins()) then			
			timeLeftSanguinaryVein  = timeLeftHemorrhage;
		end		
	end
	---------------------------------------------
	local name, _, _, _, _, _, expirationTime, unitCaster, _, _, spellId = UnitDebuff("target", nameRupture);	
	if(name and (unitCaster == "player")) then
		timeLeftRupture = floor((((expirationTime-GetTime())*10)+ 0.5))/10;
	end
	---------------------------------------------
	local name, _, _, _, _, _, expirationTime, unitCaster, _, _, spellId = UnitDebuff("target", nameGarrote);	
	if(name and (unitCaster == "player")) then
		local timeLeft = floor((((expirationTime-GetTime())*10)+ 0.5))/10;	
		if(timeLeft > timeLeftSanguinaryVein) then
			timeLeftSanguinaryVein = timeLeft;
		end
	end
	---------------------------------------------
	local name, _, _, _, _, _, expirationTime, unitCaster, _, _, spellId = UnitDebuff("target", nameCrimsonTempest);	
	if(name and (unitCaster == "player")) then
		local timeLeft = floor((((expirationTime-GetTime())*10)+ 0.5))/10;	
		if(timeLeft > timeLeftSanguinaryVein) then
			timeLeftSanguinaryVein = timeLeft;
		end
	end
	---------------------------------------------
	local name, _, _, _, _, _, expirationTime, unitCaster, _, _, spellId = UnitDebuff("target", nameFindWeakness);	
	if(name and (unitCaster == "player")) then
		local timeLeft = floor((((expirationTime-GetTime())*10)+ 0.5))/10;
		if(timeLeft <= 5) then
			SRT_TEXT7:SetText(string.format("%1.1f",timeLeft));
			SRT_Texture7:SetVertexColor(1.0, 1.0, 0.0);	
		else
			SRT_TEXT7:SetText(string.format("%d",timeLeft));
			SRT_Texture7:SetVertexColor(1.0,1.0,1.0);
		end	
		SRT_TEXT7:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE");
		SRT_TEXT7:SetVertexColor(1.0,1.0,1.0);
		SRT_TEXT7:Show();
		SRT_Texture7:Show();
	else
		SRT_TEXT7Above:Hide();
		SRT_TEXT7:Hide();
		SRT_Texture7:Hide();
	end	
	---------------------------------------------
	FindOrCreateCurrentMob();
	
	SRT_TEXT1:SetVertexColor(1.0,1.0,1.0);
	SRT_TEXT1:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE");
	
	if(timeLeftHemorrhage > 0) then
		SRT_TEXT1Above:Show();
		SRT_TEXT1:Show();
		SRT_Texture1:Show();
		
		if(timeLeftHemorrhage <= offsetHemorrhage/1000) then
			SRT_TEXT1:SetText(string.format("%1.1f",timeLeftHemorrhage));
			SRT_Texture1:SetVertexColor(1.0, 1.0, 0.0);	
		else
			SRT_TEXT1:SetText(string.format("%d",timeLeftHemorrhage));
			SRT_Texture1:SetVertexColor(1.0, 1.0, 1.0);
		end
		
		if(currentmob) then
			SRT_TEXT1Above:SetText(string.format("%d",currentmob[2]));
			
			if(buffscorecurrent > currentmob[2]) then
				SRT_TEXT1Above:SetVertexColor(0.0, 1.0, 0.0); --green
				
			else
				SRT_TEXT1Above:SetVertexColor(1.0, 1.0, 0.0); --none
				
			end	
		else
			SRT_TEXT1Above:Hide();
		end
	else
		SRT_TEXT1Above:Hide();
		SRT_TEXT1:Hide();
		SRT_Texture1:Hide();
	end
	
	SRT_TEXT2:SetVertexColor(1.0,1.0,1.0);
	SRT_TEXT2:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE");
	
	if(timeLeftSanguinaryVein > 0 or timeLeftRupture > 0) then
		SRT_TEXT2:Show();
		SRT_Texture2:Show();
		if(timeLeftRupture > 0) then
			SRT_Texture2:SetTexture(iconRupture);
			
			if(timeLeftRupture <= offsetSanguinaryVein/1000) then
				SRT_TEXT2:SetText(string.format("%1.1f",timeLeftRupture));
				SRT_Texture2:SetVertexColor(1.0, 1.0, 0.0);	
			else
				SRT_TEXT2:SetText(string.format("%d",timeLeftRupture));
				SRT_Texture2:SetVertexColor(1.0, 1.0, 1.0);
			end		
				
			if(currentmob) then
				SRT_TEXT2Above:Show();
				SRT_TEXT2Above:SetText(string.format("%d",currentmob[3]));
				
				if(buffscorecurrent > currentmob[3]) then
					SRT_TEXT2Above:SetVertexColor(0.0, 1.0, 0.0); --green
				else
					SRT_TEXT2Above:SetVertexColor(1.0, 1.0, 0.0); --none
				end	
			else
				SRT_TEXT2Above:Hide();
			end
		else
			SRT_TEXT2Above:Hide();
			SRT_Texture2:SetTexture(iconSanguinaryVein);
			if(timeLeftSanguinaryVein <= offsetSanguinaryVein/1000) then
				SRT_TEXT2:SetText(string.format("%1.1f",timeLeftSanguinaryVein));
				SRT_Texture2:SetVertexColor(1.0, 1.0, 0.0);	
			else
				SRT_TEXT2:SetText(string.format("%d",timeLeftSanguinaryVein));
				SRT_Texture2:SetVertexColor(1.0, 1.0, 1.0);
			end	
		end
	else
		SRT_TEXT2Above:Hide();
		SRT_TEXT2:Hide();
		SRT_Texture2:Hide();
	end		
end

local function CheckPlayerBuffs()	
	local name, _, _, _, _, _, expirationTime, _, _, _, _ = UnitBuff("player", nameSliceAndDice);
	
	if(name) then
		local timeleft = floor((((expirationTime-GetTime())*10)+ 0.5))/10;
		if(timeleft <= offsetSliceAndDice/1000) then
			SRT_TEXT3:SetText(string.format("%1.1f",timeleft));
			SRT_Texture3:SetVertexColor(1.0, 1.0, 0.0);	
		else
			SRT_TEXT3:SetText(string.format("%d",timeleft));
			SRT_Texture3:SetVertexColor(1.0,1.0,1.0);
		end	
		SRT_TEXT3:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE");
		SRT_TEXT3:SetVertexColor(1.0,1.0,1.0);
		SRT_TEXT3:Show();
		SRT_Texture3:Show();
	else
		SRT_TEXT3Above:Hide();
		SRT_TEXT3:Hide();
		SRT_Texture3:Hide();
	end
	
	local name, _, _, _, _, _, expirationTime, _, _, _, _ = UnitBuff("player", nameRecuperate);
	
	if(name) then
		local timeleft = floor((((expirationTime-GetTime())*10)+ 0.5))/10;
		if(timeleft <= offsetRecuperate/1000) then
			SRT_TEXT6:SetText(string.format("%1.1f",timeleft));
			SRT_Texture6:SetVertexColor(1.0, 0.9, 0.1);		
		else
			SRT_TEXT6:SetText(string.format("%d",timeleft));
			SRT_Texture6:SetVertexColor(1.0,1.0,1.0);
		end	
		SRT_TEXT6:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE");
		SRT_TEXT6:SetVertexColor(1.0,1.0,1.0);
		SRT_TEXT6:Show();
		SRT_Texture6:Show();
	else
		SRT_TEXT6Above:Hide();
		SRT_TEXT6:Hide();
		SRT_Texture6:Hide();
	end
	
	local name, _, _, _, _, _, expirationTime, _, _, _, _ = UnitBuff("player", nameShadowDance);
	
	if(name) then
		local timeleft = floor((((expirationTime-GetTime())*10)+ 0.5))/10;
		if(timeleft <= 4.0) then
			SRT_TEXT8:SetText(string.format("%1.1f",timeleft));
			SRT_Texture8:SetVertexColor(1.0, 0.9, 0.1);		
		else
			SRT_TEXT8:SetText(string.format("%d",timeleft));
			SRT_Texture8:SetVertexColor(1.0,1.0,1.0);
		end	
		SRT_TEXT8:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE");
		SRT_TEXT8:SetVertexColor(1.0,1.0,1.0);
		SRT_TEXT8:Show();
		SRT_Texture8:Show();
	else
		SRT_TEXT8Above:Hide();
		SRT_TEXT8:Hide();
		SRT_Texture8:Hide();
	end
		
	local finished = false;
	local found = false;
	local i = 0;
	local j = 0;
	local count = 0;

	buffscorecurrent = 0;
	local buffscorehaste = 0;
	local buffscoredamagetemp = 1;
	local baseAgility = UnitStat("player",2);
	local modifiedAgility = 0;

	while not finished do
		count = count+1;
		local bn,_,_,bcount,_,_,bexpirationTime,_,_,_,bspellId =  UnitBuff("player", count, 0);

		modifiedAgility = baseAgility + buffscorecurrent;
		
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

						if (string.lower(entry[2]) == "agility") then
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

						if (string.lower(entry[2]) == "agility") then
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
				
		end --one buff check finished
	end --finished buff loop check of all buffs
	
	--Has there been an active Damage buff?
	if (buffscoredamagetemp ~= 1) then
		--Add the DamageWeight to the Damage score
		buffscoredamagetemp = buffscoredamagetemp * modifiedAgility * DamageWeight;
		--add the multiplied Damagebuff to the buffscore
		buffscorecurrent = buffscorecurrent + buffscoredamagetemp;
	end
end

function SubRogueTimerFrame_OnLoad(self)				
	SubRogueTimerFrame:RegisterEvent("PLAYER_LOGOUT");
	SubRogueTimerFrame:RegisterEvent("ADDON_LOADED");
	SubRogueTimerFrame:RegisterEvent("SPELLS_CHANGED");	
	SubRogueTimerFrame:RegisterEvent("SAVED_VARIABLES_TOO_LARGE");	
	SubRogueTimerFrame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED");
	SubRogueTimerFrame:RegisterEvent("PLAYER_REGEN_ENABLED");
	SubRogueTimerFrame:RegisterEvent("PLAYER_REGEN_DISABLED");
	SubRogueTimerFrame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED");
	SubRogueTimerFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
	SubRogueTimerFrame:RegisterEvent("PLAYER_ENTERING_WORLD");
	
	TimeSinceLastUpdate = 0;

	SubRogueTimerFrame:RegisterForDrag("LeftButton", "RightButton");
	SubRogueTimerFrame:EnableMouse(false);
end

function CheckComboPoints()
	local amount = GetComboPoints("player", "target");
	
	local name, _, _, count = UnitBuff("player", nameAnticipation); 
	
	if(name) then
		amount = amount + count;
		SRT_Texture5:Show();
		if(amount == 8 or amount == 9) then
			SRT_Texture5:SetVertexColor(1.0, 1.0, 0.0); --yellow
		elseif(amount == 10) then
			SRT_Texture5:SetVertexColor(1.0, 0.0, 0.0); --red
		else
			SRT_Texture5:SetVertexColor(1.0, 1.0, 1.0); --none
		end
	else
		SRT_Texture5:Hide();
	end
	
	if(amount ~= 0) then
		SRT_TEXT5:SetText(string.format("%d", amount));
		SRT_TEXT5:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE");
		SRT_TEXT5:SetVertexColor(1.0,1.0,1.0);
		SRT_TEXT5:Show();
	else
		SRT_TEXT5:Hide();
	end
end

function hasGlyphOfHemorrhagingVeins()
	for i = 1, NUM_GLYPH_SLOTS do
		local enabled, glyphType, glyphTooltipIndex, glyphSpellID, icon = GetGlyphSocketInfo(i);
		if (glyphSpellID == 146631) then
			return true;
		end
	end
	return false;
end

function SubRogueTimerFrame_OnUpdate(elapsed)
	if (isSubRogue()) then
		TimeSinceLastUpdate = TimeSinceLastUpdate + elapsed; 		
		while (TimeSinceLastUpdate > SRT_UpdateInterval) do
	
			CheckComboPoints();
			CheckCurrentTargetDeBuffs();
			CheckPlayerBuffs();
			
			if (buffscorecurrent > 0) then
				SRT_TEXT4:SetText(string.format("%d", buffscorecurrent));
				SRT_TEXT4:SetVertexColor(1.0, 0.9, 0.1);	--yellow
				SRT_TEXT4:Show();
			else
				SRT_TEXT4:Hide();
			end
			TimeSinceLastUpdate = TimeSinceLastUpdate - SRT_UpdateInterval;
		end
	else
		HideAll();
	end
end

function SubRogueTimerFrame_OnEvent(self, event, ...)
	local arg1 = ...;
	
	if (event == "SPELLS_CHANGED" and firstLoadPerGameStart) then
	
		if (not isSubRogue()) then
			HideAll();
			return;
		else
			SRT_Texture1:SetTexture(iconHemorrhage);		--Hemorrhage
			SRT_Texture2:SetTexture(iconSanguinaryVein);	--Sanguinary Vein		
			SRT_Texture3:SetTexture(iconSliceAndDice);		--Slice and Dice
															--buffstrength
			SRT_Texture5:SetTexture(iconAnticipation);		--Combo Points
			SRT_Texture6:SetTexture(iconRecuperate);		--Recuperate
			SRT_Texture7:SetTexture(iconFindWeakness);		--Find Weakness	
			SRT_Texture8:SetTexture(iconShadowDance);
			
			firstLoadPerGameStart = false;
			DEFAULT_CHAT_FRAME:AddMessage("[SubRogueTimer] Loaded.");
		end
	end
	
	if (event == "UNIT_SPELLCAST_SUCCEEDED") then
		local unit, _, _, _, spellid = ...;
		if (unit == "player") then
			FindOrCreateCurrentMob();
			if(currentmob) then
				if (spellid == hemorrhageID) then		
					currentmob[2] = buffscorecurrent;
				elseif (spellid == ruptureID) then
					currentmob[3] = buffscorecurrent;
				elseif (spellid == garroteID) then
					currentmob[4] = buffscorecurrent;
				elseif (spellid == crimsonTempestID) then
					currentmob[5] = buffscorecurrent;
				end	
			end
		end
	elseif ((event == "ADDON_LOADED") and arg1 == ("SubRogueTimer")) then
		if (not SubRogueTimerFrameScaleFrame) then
			SubRogueTimerFrameScaleFrame = 1.0;
		end
		SubRogueTimerFrame:SetScale(SubRogueTimerFrameScaleFrame);
	elseif ((event == "SAVED_VARIABLES_TOO_LARGE") and (arg1 == "SubRogueTimer")) then
		SubRogueTimerFrameScaleFrame = 1.0;
		SubRogueTimerFrame:SetScale(SubRogueTimerFrameScaleFrame);
	elseif (event == "PLAYER_LOGOUT") then
		SubRogueTimerFrameScaleFrame = SubRogueTimerFrame:GetScale();
		local point, relativeTo, relativePoint, xOffset, yOffset;
		point, relativeTo, relativePoint, xOffset, yOffset = self:GetPoint(1);
		SubRogueTimerxPosiFrame = xOffset;
	elseif (event == "PLAYER_REGEN_ENABLED") then
		inCombat = false;
	elseif (event == "PLAYER_REGEN_DISABLED") then
		inCombat = true;
	end
end

SLASH_SubRogueTimer1, SubRogueTimer2 = '/SRT', '/SubRogueTimer';

local function SLASH_SubRogueTimerhandler(msg, editbox)
	
	if msg == 'show' then
		SubRogueTimerFrame:Show();
	elseif  msg == 'hide' then
		SubRogueTimerFrame:Hide();
	elseif  msg == 'reset' then
		SubRogueTimerFrame:Hide();
		SubRogueTimerFrame:Show();
		ClearMobList();
	elseif  msg == 'clear' then
		ClearMobList();
	elseif  msg == 'noconfigmode' then
		SubRogueTimerFrame:EnableMouse(false);
		SubRogueTimerFrame:SetBackdrop(nil);
	elseif  msg == 'configmode' then
		SubRogueTimerFrame:EnableMouse(true);
		SubRogueTimerFrame:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background", edgeFile= "Interface/Tooltips/UI-Tooltip-Border", edgeSize = 4, tile = false, tileSize =16, insets = { left = 0, right = 0, top = 0, bottom = 0 }});
	elseif  msg == 'options' then
		InterfaceOptionsFrame_OpenToCategory("SubRogueTimer");
	elseif  msg == 'scale1' then
		SubRogueTimerScaleFrame = 0.5
		SubRogueTimerFrame:SetScale(SubRogueTimerScaleFrame);
	elseif  msg == 'scale2' then
		SubRogueTimerScaleFrame = 0.6
		SubRogueTimerFrame:SetScale(SubRogueTimerScaleFrame);
	elseif  msg == 'scale3' then
		SubRogueTimerScaleFrame = 0.7
		SubRogueTimerFrame:SetScale(SubRogueTimerScaleFrame);
	elseif  msg == 'scale4' then
		SubRogueTimerScaleFrame = 0.8
		SubRogueTimerFrame:SetScale(SubRogueTimerScaleFrame);
	elseif  msg == 'scale5' then
		SubRogueTimerScaleFrame = 0.9
		SubRogueTimerFrame:SetScale(SubRogueTimerScaleFrame);
	elseif  msg == 'scale6' then
		SubRogueTimerScaleFrame = 1.0
		SubRogueTimerFrame:SetScale(SubRogueTimerScaleFrame);
	else
		print("Syntax: /SRT (show | hide | reset | configmode | noconfigmode | options | clearmoblist )");
		print("Syntax: /SRT (scale1 | scale2 | scale3 | scale4 | scale5 | scale6)");
	end
end

SlashCmdList["SubRogueTimer"] = SLASH_SubRogueTimerhandler;