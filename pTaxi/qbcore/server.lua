-- Made with ❤️ by noahpombas.ch
local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent("taxi:verificarSaldo")
AddEventHandler("taxi:verificarSaldo", function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player.Functions.GetMoney("bank") >= Pombas.minBalance then
        TriggerClientEvent("taxi:saldoVerificado", src, true)
    else
        TriggerClientEvent("taxi:saldoVerificado", src, false)
    end
end)

RegisterNetEvent("taxi:charge")
AddEventHandler("taxi:charge", function(amount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    Player.Functions.RemoveMoney("bank", amount, "Pagamento do Taxi")
end)

-- Made with ❤️ by noahpombas.ch