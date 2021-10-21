-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

local function applyOngoingDamageAdjustment(nodeActor, nodeEffect, rEffectComp)
	-- EXIT IF EMPTY REGEN
	if #(rEffectComp.dice) == 0 and rEffectComp.mod == 0 then
		return;
	end

	-- BUILD MESSAGE
	local aResults = {};
	if rEffectComp.type == "REGEN" then
		local rActor = ActorManager.resolveActor(nodeActor);
		local nPercentWounded = ActorHealthManager.getWoundPercent(rActor);

		-- If not wounded, then return
		if nPercentWounded <= 0 then
			return;
		end
		-- Regeneration does not work once creature falls below 1 hit point
		if nPercentWounded >= 1 then
			return;
		end

		table.insert(aResults, "[HEAL] Regeneration");
	elseif rEffectComp.type == "TEMPO" or rEffectComp.type == "TEMPA" then
		local rActor = ActorManager.resolveActor(nodeActor);
		local nPercentWounded = ActorHealthManager.getWoundPercent(rActor);
		
		-- Temporary hitpoints don't work once creature falls below 1 hit point
		if nPercentWounded >= 1 then
			return;
		end

		table.insert(aResults, "[HEAL] [TEMP] Temporary hit points");
	else
		table.insert(aResults, "[DAMAGE] Ongoing damage");
		if #(rEffectComp.remainder) > 0 then
			table.insert(aResults, "[TYPE: " .. string.lower(table.concat(rEffectComp.remainder, ",")) .. "]");
		end
	end

	-- MAKE ROLL AND APPLY RESULTS
	local rTarget = ActorManager.resolveActor(nodeActor);
	local rRoll = { sType = "damage", sDesc = table.concat(aResults, " "), aDice = rEffectComp.dice, nMod = rEffectComp.mod };
	if EffectManager.isGMEffect(nodeActor, nodeEffect) then
		rRoll.bSecret = true;
	end
	ActionsManager.roll(nil, rTarget, rRoll);
end

local aFixedEffectTEMPO = {};
local aFixedEffectREGEN = {};
local aFixedEffectDMGO = {};
function onEffectActorStartTurn(nodeActor, nodeEffect)
	local rEffectRegen = nil;
	local aEffectOngoingDamage = {};
	
	local sEffName = DB.getValue(nodeEffect, "label", "");
	local aEffectComps = EffectManager.parseEffect(sEffName);
	for _,sEffectComp in ipairs(aEffectComps) do
		local rEffectComp = EffectManager.parseEffectCompSimple(sEffectComp);
		-- Follow-on effects
		if rEffectComp.type == "AFTER" or rEffectComp.type == "FAIL" then
			break;
		
		-- Conditionals
		elseif rEffectComp.type == "IFT" then
			break;
		elseif rEffectComp.type == "IF" then
			local rActor = ActorManager.resolveActor(nodeActor);
			if not EffectManager4E.checkConditional(rActor, nodeEffect, rEffectComp) then
				break;
			end
		
		-- Ongoing damage and regeneration
		-- From PHB, fixed regeneration and fixed ongoing damage of same damage type do not stack
		elseif rEffectComp.type == "DMGO" or rEffectComp.type == "TEMPO" or rEffectComp.type == "REGEN" then
			local nActive = DB.getValue(nodeEffect, "isactive", 0);
			if nActive == 2 then
				DB.setValue(nodeEffect, "isactive", "number", 1);
			else
				if (#rEffectComp.dice) > 0 then
					applyOngoingDamageAdjustment(nodeActor, nodeEffect, rEffectComp);
				elseif rEffectComp.mod > 0 then
					if rEffectComp.type == "REGEN" then
						if aFixedEffectREGEN[nodeActor] then
							if aFixedEffectREGEN[nodeActor].rComp.mod < rEffectComp.mod then
								aFixedEffectREGEN[nodeActor] = { rComp = rEffectComp, node = nodeEffect };
							end
						else
							aFixedEffectREGEN[nodeActor] = { rComp = rEffectComp, node = nodeEffect };
						end
					elseif rEffectComp.type == "TEMPO" then
						if aFixedEffectTEMPO[nodeActor] then
							if aFixedEffectTEMPO[nodeActor].rComp.mod < rEffectComp.mod then
								aFixedEffectTEMPO[nodeActor] = { rComp = rEffectComp, node = nodeEffect };
							end
						else
							aFixedEffectTEMPO[nodeActor] = { rComp = rEffectComp, node = nodeEffect };
						end
					else
						local sKey = table.concat(rEffectComp.remainder, ","):lower();
						if not aFixedEffectDMGO[nodeActor] then
							aFixedEffectDMGO[nodeActor] = {};
						end
						if aFixedEffectDMGO[nodeActor][sKey] then
							if aFixedEffectDMGO[nodeActor][sKey].rComp.mod < rEffectComp.mod then
								aFixedEffectDMGO[nodeActor][sKey] = { rComp = rEffectComp, node = nodeEffect };
							end
						else
							aFixedEffectDMGO[nodeActor][sKey] = { rComp = rEffectComp, node = nodeEffect };
						end
					end
				end
			end

		-- NPC power recharge
		elseif rEffectComp.type == "RCHG" then
			local nActive = DB.getValue(nodeEffect, "isactive", 0);
			if nActive == 2 then
				DB.setValue(nodeEffect, "isactive", "number", 1);
			else
				EffectManager4E.applyRecharge(nodeActor, nodeEffect, rEffectComp);
			end
		end
	end
end

local onEffectActorEndTurn_old
function onEffectActorEndTurn_new(nodeActor, nodeEffect, ...)
	local sEffName = DB.getValue(nodeEffect, "label", "");
	local aEffectComps = EffectManager.parseEffect(sEffName);
	for _,sEffectComp in ipairs(aEffectComps) do
		local rEffectComp = EffectManager.parseEffectCompSimple(sEffectComp);

		-- Conditionals
		if rEffectComp.type == "IFT" then
			break;
		elseif rEffectComp.type == "IF" then
			local rActor = ActorManager.resolveActor(nodeActor);
			if not EffectManager4E.checkConditional(rActor, nodeEffect, rEffectComp) then
				break;
			end

		-- Ongoing damage and regeneration
		elseif rEffectComp.type == "TEMPA" then
			local nActive = DB.getValue(nodeEffect, "isactive", 0);
			if nActive == 2 then
				DB.setValue(nodeEffect, "isactive", "number", 1);
			else
				applyOngoingDamageAdjustment(nodeActor, nodeEffect, rEffectComp);
			end
		end
	end
	onEffectActorEndTurn_old(nodeActor, nodeEffect, ...)
end

-- NOTE: Apply fixed regeneration and ongoing damage on the next init change. 
--		Since multiple turns can be passed on round advancement, the stacking needs to be tracked on a per actor basis.
--		Then, when the init gets set (via nextActor or nextRound), then apply all that have built up.
local onActorTurnStart_old
function onActorTurnStart_new(nodeActor, ...)
	for nodeActor,rEffectTEMPO in pairs(aFixedEffectTEMPO) do
		applyOngoingDamageAdjustment(nodeActor, rEffectTEMPO.node, rEffectTEMPO.rComp);
	end
	aFixedEffectTEMPO = {};

	onActorTurnStart_old(nodeActor, ...)
end

function onInit()
	EffectManager.setCustomOnEffectActorStartTurn(onEffectActorStartTurn);

	EffectManager.setCustomOnEffectActorEndTurn(onEffectActorEndTurn_new);
	onEffectActorEndTurn_old = EffectManager4E.onEffectActorEndTurn
	EffectManager4E.onEffectActorEndTurn = onEffectActorEndTurn_new

	CombatManager.setCustomTurnStart(onActorTurnStart_new);
	onActorTurnStart_old = EffectManager4E.onEffectActorStartTurn
	EffectManager4E.onEffectActorStartTurn = onActorTurnStart_new
end