Firepoints = 0

Fighters = {}
Fighters.FireFighters = {}
Fighters.Ammount = 3 -- 0 = 1, 1 = 2, 2 = 3 And So On.
Fighters.GuardSkin = 's_m_y_fireman_01' -- Fighters ped.
Fighters.GiveWeapon = true -- Give weapon to Fighters.
Fighters.GuardWeapon = '0x060EC506' -- Weapon for Fighters.
Fighters.Healthbar = 0.6
-- OnMission = false
---------------------------------------------------------------------------------------
---------------------------constant on screen points earned----------------------------
------------------------------------Always True----------------------------------------

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        SetTextFont(2) -- 0-4 
        SetTextScale(0.7, 0.7) -- Size of text
        SetTextColour(255, 0, 0, 255) -- RGBA
        SetTextEntry("STRING")
        AddTextComponentString("FireFighter points = ~r~~h~" .. Firepoints) -- Main Text string
        DrawText(0.0, 0.095) -- x,y of the screen
        DrawRect(0.0, 0.12, 0.5, 0.04, 24, 0, 0, 200)
    end
end)
---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if OnMission then
            SetTextFont(2) -- 0-4 
            SetTextScale(0.6, 0.6) -- Size of text
            SetTextColour(255, 255, 255, 255) -- RGBA
            SetTextEntry("STRING")
            AddTextComponentString("Heath level") -- Main Text string
            DrawText(0.020, 0.55) -- x,y of the screen
            DrawRect(0.055, --[[x]] 0.6, --[[y]] 0.11, --[[W]] 0.1, --[[H]] 24, --[[R]] 0, --[[G]] 255, --[[B]] 100 --[[A]] )
            for k, ped in pairs(Fighters.FireFighters) do
                local Healthbar = GetEntityHealth(ped)
                local startY = 0.595
                local y = startY + (k) * 0.012
                local coords = GetEntityCoords(ped)
                DrawRect(0.055, y, 0.10, --[[W]] 0.01, --[[H]] 24, --[[R]] 0, --[[G]] 0, --[[B]] 255 --[[A]] )
                DrawRect(0.055, --[[x]] y, --[[y]] -- Actual health
                Healthbar / 2000, --[[W]] 0.01, --[[H]] 0, --[[R]] 255, --[[G]] 0, --[[B]] 255 --[[A]] )
                DrawMarker(0, coords.x, coords.y, coords.z + 1.5, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 0.4, 0.4, 0.8, 255, 0, 0,
                    255, false, true, 2, false, false, false, false)
            end
        end
    end
end)

---------------------------------------------------------------------------------------
------------------------------Checking if in Truck-------------------------------------
------------------------------------Or Not---------------------------------------------

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local VehIAmIn = 'firetruk'
        local IsInFireTruck = IsVehicleModel(GetVehiclePedIsUsing(PlayerPedId()), VehIAmIn)
        if IsInFireTruck then
            StartMarker = false
        else
            StartMarker = true
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if OnMission then
            local VehIAmIn = GetHashKey('firetruk')
            local IsInFireTruck = IsVehicleModel(GetVehiclePedIsUsing(PlayerPedId()), VehIAmIn)
            local Player = PlayerPedId()
            local MyCoords = GetEntityCoords(Player)
            local TruckId = GetVehiclePedIsIn(Player, true)
            local Vehcoords = GetEntityCoords(TruckId)
            if not IsInFireTruck and #(MyCoords - Vehcoords) >= 25.0 then
                notify("End mission All False")
            
                SetMarkerForfirst = false -- do not need marker any more 
                RemoveBlip(FireBlip) -- so remove marker also
                GoToFire = false -- not on way to fire anymore 
                AtFire = false -- not at fire anymore 
                UnloadFighters()
                DeleteEntity(TruckId)



                OnMission = false --- at end because dose the most 
            end
        end
    end
end)

---------------------------------------------------------------------------------------
--------------------------Draw markers for Fire stations-------------------------------
---------------------------------------------------------------------------------------

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        for _, FireStation in pairs(FIRESTARTLOC) do
            local Player = PlayerPedId()
            local coords = GetEntityCoords(Player)
            if StartMarker and #(coords - FireStation.xyz) <= 40.0 then

                DrawMarker(0, FireStation.x, FireStation.y, FireStation.z, -- Draws Marker for FireStation
                0.0, 0.0, 0.0, 0, 0.0, 0.0, 5.0, 5.0, 5.0, 255, 0, 0, 255, false, true, 2, false, false, false, false)
                SetPedInTruck = true

            end
        end
    end
end)

---------------------------------------------------------------------------------------
-----------------------Put Ped in truck and start mission------------------------------
---------------------------------------------------------------------------------------
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if SetPedInTruck then
            local Player = PlayerPedId()
            local coords = GetEntityCoords(Player)
            for _, FireStation in pairs(FIRESTARTLOC) do
                if #(coords - FireStation.xyz) <= 4.0 then -- If in zone for FireStation then 
                    GiveWeaponToPed(PlayerPedId(), 0x060EC506, 999, false, true)
                    StartMarker = false
                    PutPedInFireTruck('firetruk')
                    SpawnFirefighters()
                    setlights()
                    OnMission = true
                    Wait(2000)

                    local vehicle = GetVehiclePedIsIn(PlayerPedId(-1), false)
                    for k, FireFighter in pairs(Fighters.FireFighters) do
                        TaskEnterVehicle(FireFighter, vehicle, -1, k + 1, 2.0, 1, 0)
                        SetPedInTruck = false
                        SetMarkerForfirst = true -- sets first fire to attend
                    end
                end
            end
        end
    end
end)

---------------------------------------------------------------------------------------
---------------------------------Set fire weypoint-------------------------------------
---------------------------------------------------------------------------------------

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if SetMarkerForfirst then
            nextloc = FIRESRANDOM[math.random(#FIRESRANDOM)]
            AFire(nextloc)
            SetMarkerForfirst = false
            GoToFire = true
        end
    end
end)
---------------------------------------------------------------------------------------
---------------------------------Going to fire-----------------------------------------
---------------------------------------------------------------------------------------

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        SetMarkerForfirst = false
        if GoToFire then

            local coords = GetEntityCoords(PlayerPedId())
            if #(coords - nextloc) <= 70.0 then -- If in zone for Car Fire then
                Createcarfire(RandomCar[math.random(#RandomCar)], nextloc)
                AddExplosion(nextloc, 0, 0.2, true, true, false)
                GoToFire = false
                AtFire = true
            end
        end
    end
end)
---------------------------------------------------------------------------------------
------------------------------------When get to fire-----------------------------------
---------------------------------------------------------------------------------------

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if AtFire then
            local player = PlayerPedId()
            local coords = GetEntityCoords(player)
            local coordsVehOnFire = GetEntityCoords(VehOnFire)
            if #(coords - nextloc) <= 15.0 then -- If in zone for Car Fire then 
                RemoveBlip(FireBlip)
                FightFire()
                AtFire = false

            end
        end
    end
end)

---------------------------------------------------------------------------------------
---------------------------------Place Marker of fire----------------------------------
---------------------------------------------------------------------------------------
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local coords = GetEntityCoords(VehOnFire)
        if IsEntityOnFire(VehOnFire) then
            DrawMarker(0, coords.x, coords.y, coords.z + 4.5, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 1.0, 1.0, 2.0, 255, 0, 0, 255,
                false, true, 2, false, false, false, false)
        end
    end
end)
---------------------------------------------------------------------------------------
----------------------------Once Fire Is Put Out---------------------------------------
---------------------------------------------------------------------------------------

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        local coords = GetEntityCoords(PlayerPedId())
        local coordsVehOnFire = GetEntityCoords(VehOnFire)
        if #(coords - coordsVehOnFire) <= 15.0 and not IsEntityOnFire(VehOnFire) then
            GetInTruck()
            DeleteEntity(VehOnFire)
            Firepoints = Firepoints + 100
            SetMarkerForNext = true
        end
    end
end)
---------------------------------------------------------------------------------------
---------------------------------Sets Next Fire----------------------------------------
--------------------------And loops Back to gotofire-----------------------------------

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if SetMarkerForNext then
            nextloc = FIRESRANDOM[math.random(#FIRESRANDOM)]
            AFire(nextloc)
            SetMarkerForNext = false
            GoToFire = true
        end
    end
end)

----------------------------------------------------------------------------------------------------
-------------------------------Checking if ped is Dead or Alive-------------------------------------
-----------------------------------------Check alive------------------------------------------------

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        if OnMission then
            local Player = PlayerPedId()
            local MyCoords = GetEntityCoords(Player)
            for k, ped in pairs(Fighters.FireFighters) do
                local IsPedDead = IsEntityDead(ped)
                local PedCoords = GetEntityCoords(ped)
                if IsPedDead and #(MyCoords - PedCoords) <= 0.9 then
                    TaskStartScenarioInPlace(Player, "CODE_HUMAN_MEDIC_KNEEL", 0, true)
                    Wait(8000)
                    ClearPedTasksImmediately(Player)
                    ResurrectPed(ped)
                    Wait(200)
                    SetEntityCoords(MyCoords.x + 2, MyCoords.y + 2, MyCoords.z, false, false, false, true, false)
                    SetEntityHealth(ped, 200)
                    ClearPedTasksImmediately(ped)
                end
            end
        end
    end
end)

------------------------------------Functions------------------------------------------
---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------

function FightFire()
    local player = PlayerPedId()
    local coords = GetEntityCoords(player)
    local coordsVehOnFire = GetOffsetFromEntityInWorldCoords(VehOnFire, 1.0, 1.0, 0.0)
    local ShootAt = GetEntityCoords(VehOnFire)
    local vehicle = GetVehiclePedIsIn(player, false)
    local FirePattern = 'FIRING_PATTERN_FULL_AUTO'
    for k, ped in pairs(Fighters.FireFighters) do
        TaskLeaveVehicle(ped, vehicle, 1)
        GiveWeaponToPed(ped, 0x060EC506, 999, false, true)
        TaskGoToCoordWhileAimingAtCoord(ped, -- Ped
        coordsVehOnFire, -- XYZ
        ShootAt.x, ShootAt.y, ShootAt.z, -- AimAtXYZ
        1.0, -- Move speed
        true, -- Shoot
        0.5, -- p9s
        4.0, -- p10s
        true, -- p11
        0, -- flags
        false, FirePattern -- Firing pattern
        )

    end
end

function PutPedInFireTruck(FireTruck)

    local FireTruck = GetHashKey(FireTruck)
    local lastveh = GetVehiclePedIsIn(PlayerPedId(), true)
    RequestModel(FireTruck)
    while not HasModelLoaded(FireTruck) do
        RequestModel(FireTruck)
        Citizen.Wait(50)
    end
    local coords = GetEntityCoords(PlayerPedId())
    local foundNode, nodeLocation, nodeHeading = GetClosestVehicleNodeWithHeading(coords.x, coords.y, coords.z, 0, 3.0,
        0)
    local vehicle = CreateVehicle(FireTruck, nodeLocation, nodeHeading, true, false)
    SetPedIntoVehicle(PlayerPedId(), vehicle, -1)
    SetEntityHeading(vehicle, nodeHeading);
    SetEntityAsNoLongerNeeded(vehicle)
    SetModelAsNoLongerNeeded(car)
    SetEntityAsMissionEntity(lastveh, true, true)
    DeleteVehicle(lastveh)

end

function AFire(nextloc)
    FireBlip = AddBlipForCoord(nextloc)
    SetBlipRoute(FireBlip, true)
    SetBlipRouteColour(FireBlip, 6)
    SetBlipColour(FireBlip, 6)
end

function Createcarfire(Veh, nextloc)

    Veh = GetHashKey(Veh)
    RequestModel(Veh)
    while not HasModelLoaded(Veh) do
        RequestModel(Veh)
        Citizen.Wait(50)
    end
    for _, Firespot in pairs(FIRES) do
        local coords = GetEntityCoords(PlayerPedId())
        local foundNode, nodeLocation, nodeHeading = GetClosestVehicleNodeWithHeading(coords.x, coords.y, coords.z, 0,
            3.0, 0)
        VehOnFire = CreateVehicle(Veh, nextloc, nodeHeading, true, false)
        SetEntityAsNoLongerNeeded(VehOnFire)
        SetVehicleEngineHealth(VehOnFire, 0)
        SetVehicleDamage(VehOnFire, 0.0, 0.0, 100.0, 200.0, 100.0, true)
        SetModelAsNoLongerNeeded(Veh)

    end
end

function SpawnFirefighters()

    local FireMen = GetHashKey(Fighters.GuardSkin)
    local playerPed = PlayerPedId()
    local player = GetPlayerPed(playerPed)
    local playerPosition = GetOffsetFromEntityInWorldCoords(playerPed, 0.0, 0.0, 0.0)
    local playerGroup = GetPedGroupIndex(playerPed)
    Citizen.Wait(50)
    RequestModel(FireMen)
    while (not HasModelLoaded(FireMen)) do
        Citizen.Wait(10)
    end
    local MAX_RADIUS = 2
    local radius = math.random(2, 5) * MAX_RADIUS
    local x = playerPosition.x + math.random(-radius, radius)
    local y = playerPosition.y + math.random(-radius, radius)
    local z = playerPosition.z
    for i = 0, Fighters.Ammount, 1 do
        Fighters.FireFighters[i] = CreatePed(4, FireMen, x, y, playerPosition.z, 1, false, true)
        SetModelAsNoLongerNeeded(FireMen)
        SetPedConfigFlag(Fighters.FireFighters[i], 17, true)
        SetPedConfigFlag(Fighters.FireFighters[i], 128, false)
        SetPedConfigFlag(Fighters.FireFighters[i], 58, false)
        SetPedRandomProps(Fighters.FireFighters[i])
        SetEntityProofs(Fighters.FireFighters[i], false, true, false, false, false, true, 1, false)

    end
end

function GetInTruck()

    local vehicle = GetVehiclePedIsIn(PlayerPedId(-1), true)
    for k, FireFighter in pairs(Fighters.FireFighters) do
        TaskEnterVehicle(FireFighter, vehicle, -1, k + 1, 2.0, 1, 0)
        Wait(2000)
    end
end

---------------------------------------------------------------------------------------
------------------------------Notify---------------------------------------------------
---------------------------------------------------------------------------------------

function notify(text)

    SetNotificationTextEntry("STRING")
    AddTextComponentString(text)
    SetTextScale(1.0, 0.5)
    DrawText(0.0001, 0.0001)
    DrawNotification(true, true)
end


function UnloadFighters()
    for k, guard in pairs(Fighters.FireFighters) do
        if (guard ~= nil) then
            DeletePed(guard)
            --print(Fighters.FireFighters[k])
            Fighters.FireFighters[k] = nil
        end
    end
end

function setlights()
    local veh = GetVehiclePedIsUsing(PlayerPedId())
    SetVehicleSiren(veh, true)
end