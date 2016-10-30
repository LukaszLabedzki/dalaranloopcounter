-- Dalaran Loop Count
-- By Gusrim@Shadowsong

local updateInterval = 0.2
local timeSinceLastUpdate = 0
local color = "|cff00ffff"

local firstGate = 0
local firstGateTime = 0
local gateCount = 0
local lastGate = 0
local lastGateTime = 0
local DLC = CreateFrame("Frame")

DLC:RegisterEvent("ADDON_LOADED")
DLC:RegisterEvent("PLAYER_LOGOUT")
DLC:SetScript("OnEvent",function(self,event,...) self[event](self,event,...);end)

SLASH_DLC1 = "/dlc"

function round(num, idp)
  local mult = 10^(idp or 0)
  return math.floor(num * mult + 0.5) / mult
end

function ternary ( cond , F )
    if cond then return '' else return F end
end

function SecondsToClock(seconds)
  local seconds = tonumber(seconds)

  if seconds <= 0 then
    return "none";
  else
	days = math.floor(seconds/86400);
    hours = math.floor(seconds/3600);
    mins = math.floor(seconds/60 - (hours*60));
    secs = math.floor(seconds - hours*3600 - mins *60);
    return ternary(days==0, days .. 'd ') .. ternary(hours==0, hours .. 'h ') .. ternary(mins==0, mins .. 'm ') .. secs .. 's'
  end
end

function SlashCmdList.DLC(msg)
	msg = string.lower(msg)
	local command, rest = msg:match("^(%S*)%s*(.-)$")
	if (command == "reset" and rest == "count") then
		DEFAULT_CHAT_FRAME:AddMessage(color.."DLC: Total laps count resetted.")
		LoopCount = 0
	elseif (command == "reset" and rest == "time") then
		DEFAULT_CHAT_FRAME:AddMessage(color.."DLC: Total time resetted.")
		TotalTime = 0
	elseif (command == "reset" and rest == "record") then
		DEFAULT_CHAT_FRAME:AddMessage(color.."DLC: Record resetted.")
		LoopRecord = false
	elseif (command == "stats") then
		DEFAULT_CHAT_FRAME:AddMessage(color.."Dalaran Loop Count stats:")
		DEFAULT_CHAT_FRAME:AddMessage(color.."Total number of laps: " .. LoopCount)
		
		if(LoopRecord) then
			DEFAULT_CHAT_FRAME:AddMessage(color.."Best lap time: " .. LoopRecord .. 's')
		else
			DEFAULT_CHAT_FRAME:AddMessage(color.."Best lap time: not set")
		end
		
		DEFAULT_CHAT_FRAME:AddMessage(color.."Total time spent: " .. SecondsToClock(TotalTime))
	else
		DEFAULT_CHAT_FRAME:AddMessage(color.."Dalaran Loop Count")
		DEFAULT_CHAT_FRAME:AddMessage(color.."Ver: "..GetAddOnMetadata("DalaranLoopCounter", "Version"))
		DEFAULT_CHAT_FRAME:AddMessage(color.."Commands:")
		DEFAULT_CHAT_FRAME:AddMessage(color.."/dlc stats - shows total number of laps, best lap time and total time ")
		DEFAULT_CHAT_FRAME:AddMessage(color.."/dlc reset record - resets record loop time")
		DEFAULT_CHAT_FRAME:AddMessage(color.."/dlc reset time - resets total time spend on looping")
		DEFAULT_CHAT_FRAME:AddMessage(color.."/dlc reset count - resets total number of loops")
	end
end

function DLC:ADDON_LOADED()
	DLC:SetScript("OnUpdate", function(self, elapsed) DLC_OnUpdate(self, elapsed) end)
	
	if (not LoopCount) then
		LoopCount = 0
	end
	
	if (not LoopRecord) then
		LoopRecord = false
	end
	
	if (not TotalTime) then
		TotalTime = 0
	end	
	
end

function DLC_OnUpdate(self, elapsed)
	timeSinceLastUpdate = timeSinceLastUpdate + elapsed
	if (timeSinceLastUpdate > updateInterval) then
		timeSinceLastUpdate = 0
		DLC_UpdatePosition()
	end
end

function DLC_UpdatePosition()
	local px, py = GetPlayerMapPosition("player")
	if ( px ~= 0 and py ~= 0 ) then
		MinimapZoneText:SetText( format("(%d:%d) ",px*100.0,py*100.0) .. GetMinimapZoneText() );
		
		local gate = false
		
		if(GetMinimapZoneText()=='Dalaran') then
			if (py*100>39 and py*100 < 40 and px*100>=49 and px*100<=55) then
				gate = 1
			end
			
			if (py*100>43 and py*100 < 44 and px*100>=38 and px*100<=44) then
				gate = 2
			end
			
			if (py*100>54 and py*100 < 55 and px*100>=39 and px*100<=47) then
				gate = 3
			end				
			
			if (py*100>57 and py*100 < 58 and px*100>=51 and px*100<=57) then
				gate = 4
			end

			if (py*100>49 and py*100 < 50 and px*100>=56 and px*100<=60) then
				gate = 5
			end	

			if (py*100>31 and py*100 < 41 and px*100>=46 and px*100<=47) then
				gate = 6
			end			

			if(gate) then
				if(GetTime()-lastGateTime>60) then
					firstGate = 0
					gateCount = 0
				end
				
				lastGateTime = GetTime()
			
				if(firstGate==0) then
					firstGate = gate
					lastGate = gate
					gateCount = 0
					firstGateTime = GetTime()
				else
					if(gate ~= lastGate) then
						gateCount = gateCount + 1
						lastGate = gate
						
						if(gateCount>=6) then
							local lapTime = GetTime()-firstGateTime
							
							LoopCount = LoopCount + 1
							TotalTime = TotalTime + round(lapTime, 0)
							gateCount = 0
							firstGateTime = GetTime()
							
							if(LoopRecord == false or lapTime<LoopRecord) then
								UIErrorsFrame:AddMessage('Lap time: ' ..  round(lapTime, 3) .. 's. This is your new record!', 1.0, 1.0, 0.0, 3);
								LoopRecord = round(lapTime, 3)
							else
								UIErrorsFrame:AddMessage('Lap time: ' .. round(lapTime, 3) .. 's', 1.0, 1.0, 0.0, 3);
							end
						end
					end
				end
			end
		end
	end
end