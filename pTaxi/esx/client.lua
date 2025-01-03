-- Made with ❤️ by noahpombas.ch
if Pombas.legacy == true then
    ESX = exports["es_extended"]:getSharedObject()
else
    Citizen.CreateThread(function()
        while ESX == nil do
            TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
            Citizen.Wait(0)
        end
    end)
end

local lastTaxiCallTime = nil
local cooldownTime = Pombas.delay * 60

RegisterCommand("callTaxi", function(source, args, rawCommand)
    SetWaypointOff()
    local currentTime = GetGameTimer() / 1000
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)

    if lastTaxiCallTime ~= nil and (currentTime - lastTaxiCallTime < cooldownTime) then
        local remainingTime = cooldownTime - (currentTime - lastTaxiCallTime)
        local time = math.floor(remainingTime / 60)
        TriggerEvent("chat:addMessage", { args = { "^1Taxi ", "You need to wait " .. time .. " minutes to call another taxi!" } })
        return
    end


    lastTaxiCallTime = currentTime

    TriggerServerEvent("taxi:verificarSaldo")
end)

-- Made with ❤️ by noahpombas.ch
RegisterNetEvent("taxi:saldoVerificado")
AddEventHandler("taxi:saldoVerificado", function(temSaldo)
    if not temSaldo then
        TriggerEvent("chat:addMessage", { args = { "^1Taxi", "You do not have enough money!" } })
        return
    end

    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local taxiModel = GetHashKey(Pombas.car)
    local driverModel = GetHashKey(Pombas.driverModel)
    
    RequestModel(taxiModel)
    RequestModel(driverModel)
    while not HasModelLoaded(taxiModel) or not HasModelLoaded(driverModel) do
        Wait(500)
    end
    
    local foundRoad, outPos1, outPos2 = GetClosestRoad(coords.x, coords.y, coords.z, 1.0, 1, false)
    local spawnCoords = vector3(0.0, 0.0, 0.0)
    
    if foundRoad then
        spawnCoords = (outPos1 + outPos2) / 2 
    else
        spawnCoords = vector3(coords.x + 10, coords.y + 10, coords.z)
    end
    
    local taxi = CreateVehicle(taxiModel, spawnCoords.x, spawnCoords.y, spawnCoords.z, GetEntityHeading(ped), true, false)
    SetEntityAsMissionEntity(taxi, true, true)
    

    local driver = CreatePedInsideVehicle(taxi, 26, driverModel, -1, true, false)
    SetBlockingOfNonTemporaryEvents(driver, true) 
    SetPedCanBeDraggedOut(driver, false) 
    SetDriverAbility(driver, 1.0)
    SetDriverAggressiveness(driver, 0.0) 
    TaskVehicleDriveWander(driver, taxi, 20.0, 786603) 
    SetEntityInvincible(taxi, true)
    SetEntityInvincible(driver, true)
    SetEntityAsMissionEntity(driver, true, true)
    SetPedCombatAttributes(driver, 46, true) 
    SetPedFleeAttributes(driver, 0, false)  
    SetBlockingOfNonTemporaryEvents(driver, true)

    TaskVehicleDriveToCoord(driver, taxi, spawnCoords.x, spawnCoords.y, spawnCoords.z, 5000.0, 0, GetEntityModel(taxi), 786603, 1.0, true)


    local taxiBlip = AddBlipForEntity(taxi)
    SetBlipSprite(taxiBlip, 198) 
    SetBlipColour(taxiBlip, 46) 
    SetBlipScale(taxiBlip, 1.0)


    local playerEntered = false
    while not playerEntered do
        local taxiCoords = GetEntityCoords(taxi)
        local pedCoords = GetEntityCoords(ped)

        if #(pedCoords - taxiCoords) < 10.0 then
            SetWaypointOff()
            TaskEnterVehicle(ped, taxi, -1, 1, 1.0, 1, 0)
            playerEntered = true
        end
        Wait(500)
    end

    -- Solicitar que o jogador marque um destino no mapa
    TriggerEvent("chat:addMessage", { args = { "^2Táxi", "Please make a new Waypoint!" } })
    local destinoMarcado = false
    local waypointCoords = nil

    while not destinoMarcado do
        local waypointBlip = GetFirstBlipInfoId(8) -- 8 é o ID de waypoint
        if DoesBlipExist(waypointBlip) then
            waypointCoords = GetBlipInfoIdCoord(waypointBlip)
            destinoMarcado = true
        end
        Wait(500)
    end
    
    local isPassenger = GetPedInVehicleSeat(taxi, 1) 
    local playerInside = false

    while not playerInside do
        local pedCoords = GetEntityCoords(ped)
        local taxiCoords = GetEntityCoords(taxi)
        if #(pedCoords - taxiCoords) < 10.0 then
            TaskEnterVehicle(ped, taxi, -1, 1, 1.0, 1, 0)
            playerInside = true
        end
    end

    local foundRoad, outPos1, outPos2 = GetClosestRoad(waypointCoords.x, waypointCoords.y, waypointCoords.z, 1.0, 1, false)
    if foundRoad then
        spawnCoords = (outPos1 + outPos2) / 2
    else
        spawnCoords = vector3(waypointCoords.x, waypointCoords.y, waypointCoords.z)
    end


    local destinoBlip = AddBlipForCoord(spawnCoords.x, spawnCoords.y, spawnCoords.z)
    SetBlipSprite(destinoBlip, 1) 
    SetBlipColour(destinoBlip, 5) 
    SetBlipScale(destinoBlip, 1.0)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Destino")
    EndTextCommandSetBlipName(destinoBlip)


    local playerCoords = GetEntityCoords(PlayerPedId())
    local distancia = #(playerCoords - spawnCoords)
    local preco = math.floor(distancia * Pombas.price)
    
    TriggerEvent("chat:addMessage", { args = { "^2Táxi", "Waypoint marked! Estimated Fare: $" .. preco } })
    

    TaskVehicleDriveToCoord(driver, taxi, spawnCoords.x, spawnCoords.y, spawnCoords.z, 5000.0, 0, GetEntityModel(taxi), 2883621, 1.0, true)

    local playerExited = 0
    local arrivedAtDestination = false

    while true do
        local playerCoords = GetEntityCoords(PlayerPedId())
        local distancia = #(playerCoords - spawnCoords)
        local isPassenger = GetPedInVehicleSeat(taxi, 1) 


        if isPassenger == 0 then
            if playerExited == 0 then
                playerExited = 1
                TriggerEvent("chat:addMessage", { args = { "^1Táxi", "Destination Canceled!" } })
                TriggerServerEvent('taxi:chargeFullPrice', preco)  
                Wait(3000) 
                DeleteVehicle(taxi)
                DeletePed(driver) 
                RemoveBlip(destinoBlip)  
            end
        end


        if distancia < 10.0 and not arrivedAtDestination then 
                arrivedAtDestination = true 
                playerExited = 1
                TriggerEvent("chat:addMessage", { args = { "^1Táxi", "You arrived at your destination!" } })
                TriggerServerEvent('taxi:chargeFullPrice', preco)  
                TaskLeaveVehicle(PlayerPedId(), taxi, 0)
                Wait(3000) 
                DeleteVehicle(taxi)
                DeletePed(driver) 
                RemoveBlip(destinoBlip)
        end
        



        Wait(1000)
    end
end)
