-- Made with ❤️ by noahpombas.ch
local QBCore = exports['qb-core']:GetCoreObject()

local lastTaxiCallTime = nil
local cooldownTime = Pombas.delay * 60

-- Command to call a taxi
RegisterCommand("chamarTaxi", function()
    local currentTime = GetGameTimer() / 1000
    if lastTaxiCallTime and (currentTime - lastTaxiCallTime < cooldownTime) then
        local remainingTime = cooldownTime - (currentTime - lastTaxiCallTime)
        QBCore.Functions.Notify("Espere " .. math.floor(remainingTime / 60) .. " minutos para chamar outro táxi.", "error")
        return
    end

    lastTaxiCallTime = currentTime
    TriggerServerEvent("taxi:verificarSaldo")
end)

-- Handle balance verification
RegisterNetEvent("taxi:saldoVerificado")
AddEventHandler("taxi:saldoVerificado", function(hasBalance)
    if not hasBalance then
        QBCore.Functions.Notify("Você não tem dinheiro suficiente no banco.", "error")
        return
    end

    -- Spawn taxi and driver
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
    TriggerEvent('fuel:setFuel', taxi, 100.0)

    SetEntityAsMissionEntity(taxi, true, true)
    SetVehicleHasBeenOwnedByPlayer(taxi, true)
    SetVehicleDoorsLocked(taxi, 1) 
    SetVehicleDoorsLockedForAllPlayers(taxi, false)
    TriggerEvent('vehiclekeys:client:SetOwner', GetVehicleNumberPlateText(taxi))

    local driver = CreatePedInsideVehicle(taxi, 26, driverModel, -1, true, false)
    SetBlockingOfNonTemporaryEvents(driver, true) 
    SetPedCanBeDraggedOut(driver, false)
    SetDriverAbility(driver, 1.0) 
    SetDriverAggressiveness(driver, 0.0)
    SetEntityInvincible(taxi, true)
    SetEntityInvincible(driver, true)
    SetEntityAsMissionEntity(driver, true, true)
    SetPedCombatAttributes(driver, 46, true) 
    SetPedFleeAttributes(driver, 0, false)  
    SetBlockingOfNonTemporaryEvents(driver, true)


    TaskVehicleDriveToCoord(driver, taxi, spawnCoords.x, spawnCoords.y, spawnCoords.z, 5000.0, 0, GetEntityModel(taxi), 786603, 1.0, true)

    -- Taxi Blip
    local taxiBlip = AddBlipForEntity(taxi)
    SetBlipSprite(taxiBlip, 198)
    SetBlipColour(taxiBlip, 46)
    SetBlipScale(taxiBlip, 1.0)

    -- wait player to enter taxi
    local playerEntered = false
    while not playerEntered do
        local taxiCoords = GetEntityCoords(taxi)
        local pedCoords = GetEntityCoords(ped)

        if #(pedCoords - taxiCoords) < 10.0 then
            Wait(500)
            TaskEnterVehicle(ped, taxi, -1, 1, 1.0, 1, 0)
            playerEntered = true
        end
        Wait(500)
    end


    QBCore.Functions.Notify("Por favor, marque um destino no mapa!.", "warning")

    local destinoMarcado = false
    local waypointCoords = nil

    while not destinoMarcado do
        local isPassenger = GetPedInVehicleSeat(taxi, 1) 
        local waypointBlip = GetFirstBlipInfoId(8) -- 8 é o ID de waypoint
        if DoesBlipExist(waypointBlip) then
            print(isPassenger)
            if isPassenger ~= 0 then
                waypointCoords = GetBlipInfoIdCoord(waypointBlip)
                destinoMarcado = true
            end
        end
        Wait(500)
    end
    
    local playerInside = false

    while not playerInside do
        local pedCoords = GetEntityCoords(ped)
        local taxiCoords = GetEntityCoords(taxi)
    
        if IsPedInVehicle(ped, taxi, false) then
            playerInside = true
        else
            if #(pedCoords - taxiCoords) < 10.0 then
                TaskEnterVehicle(ped, taxi, -1, 1, 1.0, 1, 0)
            else
              
                QBCore.Functions.Notify("Aproxime-se do táxi para entrar!", "info")
                Wait(1000)
            end
        end
    
        Wait(500) 
    end

    local foundRoad, outPos1, outPos2 = GetClosestRoad(waypointCoords.x, waypointCoords.y, waypointCoords.z, 1.0, 1, false)
    if foundRoad then
        spawnCoords = (outPos1 + outPos2) / 2
    else
        spawnCoords = vector3(waypointCoords.x, waypointCoords.y, waypointCoords.z)
    end

    -- create new Blip named Destination
    local destinoBlip = AddBlipForCoord(spawnCoords.x, spawnCoords.y, spawnCoords.z)
    SetBlipSprite(destinoBlip, 1) -- Ícone simples
    SetBlipColour(destinoBlip, 5) -- Cor amarela
    SetBlipScale(destinoBlip, 1.0)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Destination")
    EndTextCommandSetBlipName(destinoBlip)

    -- calculate price in base of the distance
    local playerCoords = GetEntityCoords(PlayerPedId())
    local distancia = #(playerCoords - spawnCoords)
    local preco = math.floor(distancia * Pombas.price)

    QBCore.Functions.Notify("Destination marked! Estimated Price: $" .. preco, "error")


    -- taxi drives to destination
    TaskVehicleDriveToCoord(driver, taxi, spawnCoords.x, spawnCoords.y, spawnCoords.z, 5000.0, 0, GetEntityModel(taxi), 2883621, 1.0, true)
    
    local playerExited = 0
    local arrivedAtDestination = false
    

    Citizen.CreateThread(function()
        while DoesEntityExist(driver) do
            if not IsPedInVehicle(driver, taxi, true) then
                ClearPedTasks(driver)
            end
            Wait(500)
        end
    end)

    while true do
        local playerCoords = GetEntityCoords(PlayerPedId())
        local distancia = #(playerCoords - spawnCoords)
        local isPassenger = GetPedInVehicleSeat(taxi, 1) 


        if isPassenger == 0 then
            if playerExited == 0 then
                playerExited = 1
                QBCore.Functions.Notify("Destino cancelado!.", "error")
                TriggerServerEvent("taxi:charge", preco)
                Wait(3000) 
                DeleteVehicle(taxi)
                DeletePed(driver) 
                RemoveBlip(destinoBlip)  
            end
        end

        if distancia < 10.0 and not arrivedAtDestination then 
            arrivedAtDestination = true 
            playerExited = 1
            QBCore.Functions.Notify("Chegou ao seu Destino!", "error")
            TriggerServerEvent("taxi:charge", preco)
            TaskLeaveVehicle(PlayerPedId(), taxi, 0)
            Wait(3000) 
            DeleteVehicle(taxi)
            DeletePed(driver) 
            RemoveBlip(destinoBlip)
    end
    
    Wait(1000)
end
end)
-- Made with ❤️ by noahpombas.ch