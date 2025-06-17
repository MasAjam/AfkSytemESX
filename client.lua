local lastPosition = nil
local afkTime = 0
local isInAFKZone = false
local afkZone = vector3(3070.78, -4702.41, 15.26)
local prevPosition = nil
local redeemCode = nil
local waitingRedeem = false

-- Fungsi untuk generate kode acak
local function generateCode()
    math.randomseed(GetGameTimer())
    return tostring(math.random(1000, 9999))
end

-- Fungsi reset status AFK
local function resetAFKState()
    afkTime = 0
    waitingRedeem = false
    redeemCode = nil
end

-- Loop utama AFK detection
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        local ped = PlayerPedId()

        if not isInAFKZone then
            local currentPosition = GetEntityCoords(ped)

            if lastPosition and #(currentPosition - lastPosition) < 0.1 then
                afkTime = afkTime + 1
            else
                resetAFKState()
            end

            lastPosition = currentPosition

            if afkTime == 600 and not waitingRedeem then
                redeemCode = generateCode()
                waitingRedeem = true
                TriggerEvent('chat:addMessage', {
                    color = {255, 200, 0},
                    args = {"AFK SYSTEM", "⚠️ Kamu tidak bergerak selama 10 menit! Ketik /redeemafk " .. redeemCode .. " untuk membuktikan kamu aktif."}
                })
            elseif afkTime >= 59 and waitingRedeem then
                prevPosition = currentPosition
                SetEntityCoords(ped, afkZone.x, afkZone.y, afkZone.z)
                isInAFKZone = true
                waitingRedeem = false
                TriggerEvent('chat:addMessage', {
                    color = {255, 0, 0},
                    args = {"AFK SYSTEM", "🚷 Kamu tidak merespons, kamu telah dipindahkan ke zona AFK."}
                })
            end
        end
    end
end)

-- Tampilkan notifikasi saat di zona AFK
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if isInAFKZone then
            DrawTextOnScreen(0.5, 0.9, "[ZONA AFK] Gunakan /quitafk untuk kembali", 0.6, {r = 255, g = 255, b = 255, a = 255})
        end
    end
end)

-- Keluar dari zona AFK
RegisterNetEvent("esx_afk:tryExitAFK")
AddEventHandler("esx_afk:tryExitAFK", function()
    if isInAFKZone then
        local ped = PlayerPedId()
        if prevPosition then
            SetEntityCoords(ped, prevPosition.x, prevPosition.y, prevPosition.z)
        end
        isInAFKZone = false
        resetAFKState()
        lastPosition = GetEntityCoords(ped)
        TriggerEvent('chat:addMessage', {
            color = {0, 255, 0},
            args = {"AFK SYSTEM", "✅ Kamu telah kembali dari zona AFK."}
        })
    else
        TriggerEvent('chat:addMessage', {
            color = {255, 100, 100},
            args = {"AFK SYSTEM", "❌ Kamu tidak sedang berada di zona AFK!"}
        })
    end
end)

-- Redeem command dari server
RegisterNetEvent("esx_afk:clientRedeem")
AddEventHandler("esx_afk:clientRedeem", function(code)
    if waitingRedeem and code == redeemCode then
        resetAFKState()
        TriggerEvent('chat:addMessage', {
            color = {0, 255, 0},
            args = {"AFK SYSTEM", "✅ Redeem berhasil! Status AFK dibatalkan."}
        })
    else
        TriggerEvent('chat:addMessage', {
            color = {255, 0, 0},
            args = {"AFK SYSTEM", "❌ Redeem gagal. Kode salah atau tidak dalam status verifikasi AFK."}
        })
    end
end)

-- Fungsi untuk menggambar teks di layar
function DrawTextOnScreen(x, y, text, scale, color)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextScale(scale, scale)
    SetTextColour(color.r, color.g, color.b, color.a)
    SetTextOutline()
    SetTextCentre(true)
    BeginTextCommandDisplayText("STRING")
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayText(x, y)
end
