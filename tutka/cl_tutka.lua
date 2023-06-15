local run = false
local runSpeed = false
local direction = "front"
local speedlimit = nil
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1)
        local letSleep = true
        local playerPed = PlayerPedId()
        if IsPedInAnyVehicle(playerPed) then
            letSleep = false
            if IsControlJustPressed(0, 159) then
                if not run then
                    SendNUIMessage({
                        action = "radarOn"
                    })
                    run = true
                    --
                    SendNUIMessage({
                        action = "extraText",
                        value = direction
                    })
                else
                    SendNUIMessage({
                        action = "radarOff"
                    })
                    run = false
                    runSpeed = false
                end
            end
            -- Jos tutka päällä jo ja autossa
            if run then
                if IsControlJustPressed(0, 161) then -- Suunnan vaihto
                    PlaySound(-1, "NAV_UP_DOWN", "HUD_MINI_GAME_SOUNDSET", 0, 0, 1)
                    if direction == "front" then
                        direction = "rear"
                        SendNUIMessage({
                            action = "extraText",
                            value = direction
                        })
                    else
                        direction = "front"
                        SendNUIMessage({
                            action = "extraText",
                            value = direction
                        })
                    end
                elseif IsControlJustPressed(0, 162) then
                    AddTextEntry('FMMC_MPM_NA', 'Nopeusrajoitus')
                    DisplayOnscreenKeyboard(1, "FMMC_MPM_NA", "", "", "", "", "", 6)
                    while (UpdateOnscreenKeyboard() == 0) do
                    DisableAllControlActions(0);
                    Wait(0);
                    end
                    if (GetOnscreenKeyboardResult()) then
                        PlaySound(-1, "NAV_UP_DOWN", "HUD_MINI_GAME_SOUNDSET", 0, 0, 1)
                        local value = tonumber(GetOnscreenKeyboardResult())
                        speedlimit = value
                        SendNUIMessage({
                            action = "extraText",
                            value = "fast",
                            value2 = true
                        })
                    end
                elseif IsControlJustPressed(0, 163) then
                    PlaySoundFrontend(-1, 'CONFIRM_BEEP', 'HUD_MINI_GAME_SOUNDSET', false)
                    runSpeed = false
                    direction = "front"
                    --
                    SendNUIMessage({
                        action = "extraText",
                        value  = "front",
                    })
                    --
                    if speedlimit then
                        SendNUIMessage({
                            action = "extraText",
                            value  = "fast",
                            value2 = false
                        })
                    end
                    speedlimit = nil
                    --
                    SendNUIMessage({
                        action = "patrolSpeed",
                        value  = false,
                    })
                end
            end
        else
            if run then
                SendNUIMessage({
                    action = "radarOff"
                })
                run = false
                runSpeed = false
            end
        end
        if letSleep then
            Citizen.Wait(1000)
        end
    end
end)

local oldVeh = nil
local cleared = false
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(250)
        if run then
            -- Target auto
            local veh = targetVehicle(allVehicles())
            if oldVeh ~= veh then
                if veh ~= -1 then
                    runSpeed = false
                    Citizen.Wait(250)
                    runSpeed = true
                    oldVeh = veh
                    getSpeed(veh)
                else
                    runSpeed = false
                end
            end
            -- Partion nopeuden seuranta
            local playerPed = PlayerPedId()
            local patrolVeh = GetVehiclePedIsIn(playerPed)
            local rawSpeed = GetEntitySpeed(patrolVeh) * 3.6
            local speed = math.floor(rawSpeed)
            if speed > 5 then
                SendNUIMessage({
                    action = "patrolSpeed",
                    value  = speed,
                })
                cleared = false
            else
                if not cleared then
                    SendNUIMessage({
                        action = "patrolSpeed",
                        value  = false,
                    })
                    cleared = true
                end
            end
        else
            Citizen.Wait(1000)
        end
    end
end)

local oldOverspeedVeh = nil
function getSpeed(veh)
    print("nopeuslooppi auki")
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(250)
            if runSpeed then
                local rawSpeed = GetEntitySpeed(veh) * 3.6
                local speed = math.floor(rawSpeed)
                SendNUIMessage({
                    action = "targetSpeed",
                    value  = speed,
                })
                print(veh, speed)
                if speedlimit then
                    if speed > speedlimit then
                        if veh ~= oldOverspeedVeh then -- Yhden auton ylinopeus
                            PlaySoundFrontend(-1, 'Beep_Green', 'DLC_HEIST_HACKING_SNAKE_SOUNDS', false)
                            oldOverspeedVeh = veh
                            SendNUIMessage({
                                action = "fastSpeed",
                                value  = speed
                            })
                        end
                    end
                end
            else
                print("nopeuslooppi kiinni")
                SendNUIMessage({
                    action = "targetSpeed",
                    value  = false,
                })
                break
            end
        end
    end)
end

function vehicleData(veh)
    local plate = GetVehicleNumberPlateText(veh)
    return plate
end


function allVehicles()
    local vehicles = {}

	for vehicle in EnumerateVehicles() do
		table.insert(vehicles, vehicle)
	end

	return vehicles
end

function targetVehicle(entities)
    local closestEntity, closestEntityDistance = -1, -1
    local playerPed = PlayerPedId()
    local playerVeh = GetVehiclePedIsIn(playerPed)
    local coords = GetEntityCoords(playerPed)
    local centerPoint = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 18.0, 0.0)

    if direction == "front" then
        centerPoint = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 18.0, 0.0)
    else
        centerPoint = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, -18.0, 0.0)
    end

	for k,entity in pairs(entities) do
		local distance = #(coords - GetEntityCoords(entity))
		if closestEntityDistance == -1 or distance < closestEntityDistance then
            if entity ~= playerVeh then
                local distance2 = #(GetEntityCoords(entity) - centerPoint)

                if distance2 <= 18.0 then
                    closestEntity, closestEntityDistance = false and k or entity, distance
                end
            end
		end
	end

	return closestEntity, closestEntityDistance
end

local entityEnumerator = {
	__gc = function(enum)
		if enum.destructor and enum.handle then
			enum.destructor(enum.handle)
		end

		enum.destructor = nil
		enum.handle = nil
	end
}

local function EnumerateEntities(initFunc, moveFunc, disposeFunc)
	return coroutine.wrap(function()
		local iter, id = initFunc()
		if not id or id == 0 then
			disposeFunc(iter)
			return
		end

		local enum = {handle = iter, destructor = disposeFunc}
		setmetatable(enum, entityEnumerator)
		local next = true

		repeat
			coroutine.yield(id)
			next, id = moveFunc(iter)
		until not next

		enum.destructor, enum.handle = nil, nil
		disposeFunc(iter)
	end)
end

function EnumerateVehicles()
	return EnumerateEntities(FindFirstVehicle, FindNextVehicle, EndFindVehicle)
end

--[[ Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1)
        local playerPos = GetEntityCoords(PlayerPedId())
        local centerPointF = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 18.0, 0.0)
        DrawMarker(1, centerPointF.x, centerPointF.y, centerPointF.z-1, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 30.0, 30.0, 1.0, 255, 0, 0, 255, false, true, 2, false, nil, nil, false)

        local centerPointB = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, -18.0, 0.0)
        --DrawMarker(1, centerPointB.x, centerPointB.y, centerPointB.z-1, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 30.0, 30.0, 1.0, 255, 0, 0, 255, false, true, 2, false, nil, nil, false)
    end
end) ]]