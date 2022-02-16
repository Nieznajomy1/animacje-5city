local Keys = {
	["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
	["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
	["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
	["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
	["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
	["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
	["INSERT"] = 121, ["HOME"] = 213, ["PAGEUP"] = 10, ["DELETE"] = 178, ["PAGEDOWN"] = 11,  
	["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
	["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

ragdoll = false
isDead = false
prop = nil
prop2 = nil
prop3 = {}
local w_loop = false
loop = {
	status = nil,
	current = nil,
	finish = nil,
	delay = 0,
	dettach = false,
	last = 0
}
binds = nil
binding = nil
ESX = nil

CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end

	if not binds then
		TriggerEvent('esx_animations:load')
	end
	
	for _, group in ipairs(Config.Animations) do
		for _, item in ipairs(group.items) do
			if item.keyword ~= nil then
				TriggerEvent('chat:addSuggestion', '/e '..item.keyword, "["..group.label.."] "..item.label)
			end
		end
	end
end)

RegisterNetEvent('esx_animations:load')
AddEventHandler('esx_animations:load', function()
	binds = json.decode(GetResourceKvpString("AnimBinds"))
	if binds == nil then
		SetResourceKvp("AnimBinds", {})
		binds = {}
	end
end)

AddEventHandler('esx:onPlayerDeath', function(data)
	isDead = true
end)

AddEventHandler('playerSpawned', function(spawn)
	isDead = false
end)

RegisterNetEvent('esx_animations:trigger')
AddEventHandler('esx_animations:trigger', function(anim)
	if not anim then
		return
	end
	
	if anim.type == 'ragdoll' then
		if IsPedInAnyVehicle(PlayerPedId(), false) then
			ragdoll = true
		end
	elseif anim.type == 'attitude' then
		if anim.data.car == true then
			if IsPedInAnyVehicle(PlayerPedId(), false) then
				startAttitude(anim.data.lib, anim.data.anim)
			end
		else
			if not IsPedInAnyVehicle(PlayerPedId(), false) then
				startAttitude(anim.data.lib, anim.data.anim)
			end
		end
	elseif anim.type == 'scenario' then
		if anim.data.car == true then
			if IsPedInAnyVehicle(PlayerPedId(), false) then
				startScenario(anim.data.anim, anim.data.offset)
			end
		else
			if not IsPedInAnyVehicle(PlayerPedId(), false) then
				startScenario(anim.data.anim, anim.data.offset)
			end
		end
	elseif anim.type == 'anim' then
		if anim.data.car == true then
			if IsPedInAnyVehicle(PlayerPedId(), false) then
				startAnim(anim.data.lib, anim.data.anim, anim.data.mode, anim.data.prop)
			end
		else
			if not IsPedInAnyVehicle(PlayerPedId(), false) then
				startAnim(anim.data.lib, anim.data.anim, anim.data.mode, anim.data.prop)
			end
		end
	elseif anim.type == 'pies' then
		if isDog() and not IsPedInAnyVehicle(PlayerPedId(), false) then
			startAnim(anim.data.lib, anim.data.anim, anim.data.mode, anim.data.prop)
		end
	elseif anim.type == 'facial' then
		TriggerEvent('esx_voice:facial', anim.data)
	else
		if not IsPedInAnyVehicle(PlayerPedId(), false) then
			startAnimLoop(anim.data)
		end
	end
end)
  
function startAttitude(lib, anim)
	Citizen.CreateThread(function()
		RequestAnimSet(anim)
		while not HasAnimSetLoaded(anim) do
			Citizen.Wait(0)
		end
		
		SetPedMovementClipset(PlayerPedId(), anim, true)
	end)
end

function startScenario(anim, offset)
	if loop.status == true then
		finishLoop(function()
			startScenario(anim, offset)
		end)
	else
		local ped = PlayerPedId()
		if offset then
			local coords = GetEntityCoords(ped, true)
			TaskStartScenarioAtPosition(ped, anim, coords.x, coords.y, coords.z + offset, GetEntityHeading(ped), 0, true, true)
		else
			TaskStartScenarioInPlace(ped, anim, 0, false)
		end
	end
end

function startAnim(lib, anim, mode, obj)
	if loop.status == true then
		finishLoop(function()
			startAnim(lib, anim, mode, obj)
		end)
	else
		--print'wykon22')
		mode = mode or 0
		Citizen.CreateThread(function()
			RequestAnimDict(lib)
			while not HasAnimDictLoaded(lib) do
				Citizen.Wait(0)
			end
			local ped = PlayerPedId()
			if anim == "idle_ped06" then
				TaskPlayAnim(ped, lib, anim, 8.0, -8.0, -1, 49, 0, false, false, false)
			else
				TaskPlayAnim(ped, lib, anim, 8.0, -8.0, -1, mode, 0, false, false, false)
			end
			if obj then
				if type(prop) == 'table' then
					DeleteObject(prop.obj)
					if prop2 ~= nil then
						DeleteObject(prop2)
						prop2 = nil
					end
					for _, item in ipairs(prop3) do
						DeleteObject(item.obj)
					end
				end
				local coords = GetEntityCoords(ped)
				local boneIndex = GetPedBoneIndex(ped, obj.bone)
				ESX.Game.SpawnObject(obj.object, {
					x = coords.x,
					y = coords.y,
					z = coords.z + 2
				}, function(object)
					AttachEntityToEntity(object, ped, boneIndex, obj.offset.x + 0.0, obj.offset.y + 0.0, obj.offset.z + 0.0, obj.rotation.x + 0.0, obj.rotation.y + 0.0, obj.rotation.z + 0.0, true, true, false, true, 1, true)
					prop = {obj = object, lib = lib, anim = anim}
					table.insert(prop3, {obj = object})
				end)
				if obj.object2 ~= nil then
					ESX.Game.SpawnObject(obj.object2, {
						x = coords.x,
						y = coords.y,
						z = coords.z + 2
					}, function(object2)
						AttachEntityToEntity(object2, ped, GetPedBoneIndex(ped, obj.bone2), obj.offset2.x + 0.0, obj.offset2.y + 0.0, obj.offset2.z + 0.0, obj.rotation2.x + 0.0, obj.rotation2.y + 0.0, obj.rotation2.z + 0.0, true, true, false, true, 1, true)
						table.insert(prop3, {obj = object2})
						prop2 = object2
					end)
				end
			end
		end)
	end
end
  function startAnimLoop(data)
	if loop.status == true then
	  finishLoop(function()
	  startAnimLoop(data)
	  end)
	else
	  Citizen.CreateThread(function()
	  while loop.status ~= nil do
		Citizen.Wait(0)
	  end
	  RequestAnimDict(data.base.lib)
	  while not HasAnimDictLoaded(data.base.lib) do
		 Citizen.Wait(1)
	  end
	  RequestAnimDict(data.idle.lib)
	  while not HasAnimDictLoaded(data.idle.lib) do
	     Citizen.Wait(1)
	  end
	  RequestAnimDict(data.finish.lib)
	  while not HasAnimDictLoaded(data.finish.lib) do
	     Citizen.Wait(1)
	  end
	  local playerPed = PlayerPedId()
	  if data.prop then
		local coords	= GetEntityCoords(playerPed)
		local boneIndex = GetPedBoneIndex(playerPed, data.prop.bone)
		ESX.Game.SpawnObject(data.prop.object, {
		  x = coords.x,
		  y = coords.y,
		  z = coords.z + 2
		}, function(object)
		AttachEntityToEntity(object, playerPed, boneIndex, data.prop.offset.x + 0.0, data.prop.offset.y + 0.0, data.prop.offset.z + 0.0, data.prop.rotation.x + 0.0, data.prop.rotation.y + 0.0, data.prop.rotation.z + 0.0, true, true, false, true, 1, true)
		prop = object
		end)
	  end
	  TaskPlayAnim(PlayerPedId(), data.base.lib, data.base.anim, 8.0, -8.0, -1, data.mode, 0, false, false, false)
	  loop = {status = true, current = nil, finish = data.finish, delay = (GetGameTimer() + 100), last = 0}
	  loop.finish.mode = data.mode
	  if data.prop then
		loop.dettach = data.prop.dettach
	  else
		loop.dettach = false
	  end
	  Citizen.Wait(data.base.length)
	  while loop.status do
		local rng = #data.idle.anims
		if rng > 1 then
		  repeat
			rng = math.random((data.base.entering and 1 or 0), #data.idle.anims)
		  until rng ~= loop.last
		end
		loop.delay = GetGameTimer() + 100
		loop.last = rng
		if rng == 0 then
		  TaskPlayAnim(PlayerPedId(), data.base.lib, data.base.anim, 8.0, -8.0, -1, data.mode, 0, false, false, false)
		  loop.current = data.base
		  Citizen.Wait(data.base.length)
		else
		  TaskPlayAnim(PlayerPedId(), data.idle.lib, data.idle.anims[rng][1], 8.0, -8.0, -1, data.mode, 0, false, false, false)
		  loop.current = {lib = data.idle.lib, anim = data.idle.anims[rng][1]}
		  Citizen.Wait(data.idle.anims[rng][2])
		end
	  end
	  end)
	end
end

function finishLoop(cb)
	loop.status = false
	Citizen.CreateThread(function()
		TaskPlayAnim(PlayerPedId(), loop.finish.lib, loop.finish.anim, 8.0, 8.0, -1, loop.finish.mode, 0, false, false, false)
		Citizen.Wait(loop.finish.length)
		if loop.status == false and prop and type(prop) ~= 'table' then
			if loop.dettach then
				DetachEntity(prop, true, false)
			else
				DeleteObject(prop)
				--print'usunobj')
				if prop2 ~= nil then
					DeleteObject(prop2)
					prop2 = nil
				end
				for _, item in ipairs(prop3) do
					DeleteObject(item.obj)
				end
			end
			prop = nil
		end
		loop.status = nil
		if cb then
			cb()
		end
	end)
end

-- FIXED BY NIEZNAJOMY
-- FIXED BY NIEZNAJOMY
-- FIXED BY NIEZNAJOMY
-- FIXED BY NIEZNAJOMY
-- FIXED BY NIEZNAJOMY
-- FIXED BY NIEZNAJOMY
-- FIXED BY NIEZNAJOMY
function OpenSyncedMenu()
	local elements2 = {}

	for k, v in pairs(Config['Synced']) do
		table.insert(elements2, {['label'] = v['Label'], ['id'] = k})
	end
            
	ESX['UI']['Menu']['Open']('default', GetCurrentResourceName(), 'play_synced',
	{
		title = 'Wspólne animacje',
		align = 'bottom-right',
		elements = elements2
	}, function(data2, menu2)
		current = data2['current']
		local allowed = false
		if Config['Synced'][current['id']]['Car'] then
			if IsPedInAnyVehicle(PlayerPedId(), false) then
				allowed = true
			else
				ESX.ShowNotification('~r~Nie jesteś w pojeździe!')
			end
		else
			allowed = true
		end
		if allowed then
			local allowed = false
			ESX.UI.Inventory.Area.Build(3.0, false, false, function(target, _, npc)
				if npc then
					ESX.ShowNotification('~y~Oczekiwanie na akceptację przez obywatela')
					TriggerEvent('richrp_animacje:playSyncedWithPed', target, current['id'], 'Requester')
					FreezeEntityPosition(target, true)
				elseif target then
					ESX.ShowNotification('~y~Oczekiwanie na akceptację przez obywatela')
					TriggerServerEvent('richrp_animacje:requestSynced', target, current['id'])
				else
					ESX.ShowNotification('~r~Brak obywateli w pobliżu')
				end
			end, true, true)
		end
	end, function(data2, menu2)
		menu2['close']()
	end)
end

RegisterNetEvent('richrp_animacje:syncRequest')
AddEventHandler('richrp_animacje:syncRequest', function(requester, id)
    local accepted = false

	local elements = {}

	table.insert(elements, { label = "Zaakceptuj", value = true })
	table.insert(elements, { label = "Odrzuć", value = false })

	Citizen.CreateThread(function()		
		local menu = ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'synced_animation_request', {
			title = 'Propozycja animacji '..Config['Synced'][id]['Label']..' od '..requester,
			align = 'center',
			elements = {
				{ label = '<span style="color: lightgreen">Zaakceptuj</span>', value = true },
				{ label = '<span style="color: lightcoral">Odrzuć</span>', value = false },
			}
		}, function(data, menu)
			menu.close()
			if data.current.value then
				TriggerServerEvent('richrp_animacje:syncAccepted', requester, id)
			end
		end)
		Wait(5000)
		menu.close()
	end)
end)

RegisterNetEvent('richrp_animacje:playSyncedWithPed')
AddEventHandler('richrp_animacje:playSyncedWithPed', function(target, id, type)
	FreezeEntityPosition(target, false)
    local anim = Config['Synced'][id][type]

    if anim['Attach'] then
        local attach = anim['Attach']
        AttachEntityToEntity(target, PlayerPedId(), attach['Bone'], attach['xP'], attach['yP'], attach['zP'], attach['xR'], attach['yR'], attach['zR'], 0, 0, 0, 0, 2, 1)
		AttachEntityToEntity(PlayerPedId(), target, attach['Bone'], attach['xP'], attach['yP'], attach['zP'], attach['xR'], attach['yR'], attach['zR'], 0, 0, 0, 0, 2, 1)
    end
	
	FreezeEntityPosition(target, true)
	
    Wait(750)

    if anim['Type'] == 'animation' then
		PlayAnim(PlayerPedId(), anim['Dict'], anim['Anim'], anim['Flags'])
        PlayAnim(target, anim['Dict'], anim['Anim'], anim['Flags'])
    end

    if type == 'Requester' then
        anim = Config['Synced'][id]['Accepter']
    else
        anim = Config['Synced'][id]['Requester']
    end
    while not IsEntityPlayingAnim(target, anim['Dict'], anim['Anim'], 3) do
        Wait(0)
        SetEntityNoCollisionEntity(PlayerPedId(), target, true)
    end
    DetachEntity(PlayerPedId())
    while IsEntityPlayingAnim(target, anim['Dict'], anim['Anim'], 3) do
        Wait(0)
        SetEntityNoCollisionEntity(PlayerPedId(), target, true)
    end

    ClearPedTasks(PlayerPedId())
	FreezeEntityPosition(target, true)
end)

RegisterNetEvent('richrp_animacje:playSynced')
AddEventHandler('richrp_animacje:playSynced', function(serverid, id, type)
    local anim = Config['Synced'][id][type]

    local target = GetPlayerPed(GetPlayerFromServerId(serverid))
    if anim['Attach'] then
        local attach = anim['Attach']
        AttachEntityToEntity(PlayerPedId(), target, attach['Bone'], attach['xP'], attach['yP'], attach['zP'], attach['xR'], attach['yR'], attach['zR'], 0, 0, 0, 0, 2, 1)
    end

    Wait(750)

    if anim['Type'] == 'animation' then
        PlayAnim(PlayerPedId(), anim['Dict'], anim['Anim'], anim['Flags'])
    end

    if type == 'Requester' then
        anim = Config['Synced'][id]['Accepter']
    else
        anim = Config['Synced'][id]['Requester']
    end
    while not IsEntityPlayingAnim(target, anim['Dict'], anim['Anim'], 3) do
        Wait(0)
        SetEntityNoCollisionEntity(PlayerPedId(), target, true)
    end
    DetachEntity(PlayerPedId())
    while IsEntityPlayingAnim(target, anim['Dict'], anim['Anim'], 3) do
        Wait(0)
        SetEntityNoCollisionEntity(PlayerPedId(), target, true)
    end

    ClearPedTasks(PlayerPedId())
end)

PlayAnim = function(ped, Dict, Anim, Flag)
    LoadDict(Dict)
    TaskPlayAnim(ped, Dict, Anim, 8.0, -8.0, -1, Flag or 0, 0, false, false, false)
end

LoadDict = function(Dict)
    while not HasAnimDictLoaded(Dict) do 
        Wait(0)
        RequestAnimDict(Dict)
    end
end

local dogModels = {
	"a_c_shepherd", "a_c_rottweiler", "a_c_husky", "a_c_chop", "a_c_retriever"
}

function isDog()
	local playerModel = GetEntityModel(PlayerPedId())
	for i=1, #dogModels, 1 do
		if GetHashKey(dogModels[i]) == playerModel then
			return true
		end
	end
	return false
end
-- RICHRP

-- 77RP
function podkategoria(menu)
	local title, elements = nil, {}
	local sadadsad = menu
	if menu == "tancee" then
	  table.insert(elements, {label = "🕺 Tańce Zwykłe",  value = "tanceez"})
	  table.insert(elements, {label = "💃 Tańce Zabawne", value = "tanceezz"})
	  --table.insert(elements, {label = "👫 Tańce Wspólne", value = "tanceew"})
	elseif menu == 'siedzenie' then
	  table.insert(elements, {label = "💺 Siedzenie na krześle", value = "siedzeniek"})
	  table.insert(elements, {label = "💺 Siedzenie na ziemi",   value = "siedzeniez"})
	elseif menu == 'praca' then
	  table.insert(elements, {label = "👮 LSPD", 	   value = "lspd"})
	  table.insert(elements, {label = "💉 EMS",   	   value = "medyczne"})
	  table.insert(elements, {label = "🔧 LSC",        value = "mechanik"})
	  table.insert(elements, {label = "🧳 Inne", 	   value = "inne"})
	elseif menu == 'sytuacyjne' then
	  table.insert(elements, {label = "🥊 Sport",      value = "sport"})
	  table.insert(elements, {label = "❤️ Miłosne",    value = "milosne"})
	  table.insert(elements, {label = "🤐 Do Rozmowy", value = "dorozmowy"})
	  table.insert(elements, {label = "🔪 Gang", 	   value = "gang"})
	  table.insert(elements, {label = "🔞 PEGI 21",     value = "porn"})
	  table.insert(elements, {label = "🧳 Pozostałe",   value = "pozostale"})
	elseif menu == 'wspolne' then
	  OpenSyncedMenu()
	  return
	--[[
	  table.insert(elements, {label = "Bro", 				  value = "bro",   		  wsp = true})
	  table.insert(elements, {label = "Bro2",				  value = "bro2", 		  wsp = true})
	  table.insert(elements, {label = "Podaj", 				  value = "podaj", 		  wsp = true})
	  table.insert(elements, {label = "Podaj2", 			  value = "podaj2", 	  wsp = true})
	  table.insert(elements, {label = "Podnieś", 			  value = "podnies", 	  wsp = true})
	  table.insert(elements, {label = "Przytulenie",   		  value = "przytulenie",  wsp = true})
	  table.insert(elements, {label = "Przytulenie2",         value = "przytulenie2", wsp = true})
	  table.insert(elements, {label = "Uderz", 				  value = "uderz", 		  wsp = true})
	  table.insert(elements, {label = "Uderz2", 			  value = "uderz2", 	  wsp = true})
	  table.insert(elements, {label = "Siedzenie na krzesle", value = "siadd", 		  wsp = true})
	  table.insert(elements, {label = "Walizka", 			  value = "walizka2", 	  wsp = true})
	  table.insert(elements, {label = "Bukiet", 			  value = "bukiet", 	  wsp = true})
	  table.insert(elements, {label = "Joint", 				  value = "joint", 		  wsp = true})
	  table.insert(elements, {label = "Stulejka", 			  value = "segz", 		  wsp = true})
	  table.insert(elements, {label = "Lodzik", 			  value = "lodzik", 	  wsp = true})
	elseif menu == 'wspolnet' then
	  --print'wspolnett')
	  table.insert(elements, {label = "Taniec 1",  value = "taniec1",  wsp = true})
	  table.insert(elements, {label = "Taniec 2",  value = "taniec2",  wsp = true})
	  table.insert(elements, {label = "Taniec 3",  value = "taniec3",  wsp = true})
	  table.insert(elements, {label = "Taniec 4",  value = "taniec4",  wsp = true})
	  table.insert(elements, {label = "Taniec 5",  value = "taniec5",  wsp = true})
	  table.insert(elements, {label = "Taniec 6",  value = "taniec6",  wsp = true})
	  table.insert(elements, {label = "Taniec 7",  value = "taniec7",  wsp = true})
	  table.insert(elements, {label = "Taniec 8",  value = "taniec8",  wsp = true})
	  table.insert(elements, {label = "Taniec 9",  value = "taniec9",  wsp = true})
	  table.insert(elements, {label = "Taniec 10", value = "taniec10", wsp = true})
	  table.insert(elements, {label = "Taniec 11", value = "taniec11", wsp = true})
	  table.insert(elements, {label = "Taniec 12", value = "taniec12", wsp = true})
	]]
	end

	ESX.UI.Menu.Open( 'default', GetCurrentResourceName(), 'menuname', {
		title = "Animacje",
		align = 'bottom-right',
		elements = elements
	}, function(data, menu)
		if data.current.value == "tanceew" then
			menu.close()
			podkategoria('wspolnet')
		elseif data.current.wsp ~= true then
			OpenAnimationsSubMenu(data.current.value, sadadsad, true)
		elseif ESX.UI.Inventory.Area.Check(3.0, true) then
			ESX.UI.Inventory.Area.Build(3.0, false, false, function(target, _, npc)
				if target then
					menu.open()
					local id = target
					if data.current.value == "podnies" then
						TriggerServerEvent('w_animki:OdpalAnimacje4', id)
						ESX.ShowNotification('~y~Oczekiwanie na akceptację przez obywatela')
					else
						FreezeEntityPosition(PlayerPedId(), true)
						menu.close()
						local coords = GetEntityCoords(PlayerPedId())
						local heading = GetEntityHeading(PlayerPedId())
						local front = GetEntityForwardVector(PlayerPedId())
						local tabka = {}
						table.insert(tabka, {x = coords.x, y = coords.y, h = heading - 180, xx = front.x, yy = front.y})
						TriggerServerEvent('w_animki:propka', id, data.current.value, tabka)
						ESX.ShowNotification('~y~Oczekiwanie na akceptację przez obywatela')
						Citizen.Wait(5000)
						FreezeEntityPosition(PlayerPedId(), false)
					end
				else
					ESX.ShowNotification('~r~Brak obywateli w pobliżu')
				end
			end, true, true)
		else
			ESX.ShowNotification('~r~Brak obywateli w pobliżu')
		end
	end, function(data, menu)
		menu.close()
		OpenAnimationsMenu()
	end)
end

local jakieid = 0
local animacjajaka = ''
local tablica = {}
RegisterNetEvent('esx_animations:akcept')
AddEventHandler('esx_animations:akcept', function(ajdi, animka, tabka)
	tablica = tabka
	jakieid = ajdi
	SimpleNotify('Naciśnij [E] aby wykonać wspólną animację ('..animka..")")
	wspolnaanimka = true
	--printanimacjajaka)
	animacjajaka = animka
	--printanimacjajaka)
	ESX.SetTimeout(5000, function()
		wspolnaanimka = false
	end)
end)
	
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1)
		if wspolnaanimka then
			if IsControlJustPressed(0, Keys['E']) then
				--printjakieid.."Komu wysłać")
				--printanimacjajaka)
				TriggerServerEvent('w_animki:propka',"AKCEPT" ,jakieid, animacjajaka)
				TriggerEvent('esx_animations:graba', animacjajaka, "ja")
				wspolnaanimka = false
			end
		else
			Citizen.Wait(1500)
		end
	end
end)
	
function SimpleNotify(message)
	ESX.ShowNotification(message)
end

function GetPlayers()
	local players = {}
	for i = 0, 255 do
		if NetworkIsPlayerActive(i) then
			table.insert(players, i)
		end
	end
	return players
end

function GetClosestPlayer()
	local players = GetPlayers()
	local closestDistance = -1
	local closestPlayer = -1
	local ply = PlayerPedId()
	local plyCoords = GetEntityCoords(ply, 0)
	for index,value in ipairs(players) do
		local target = GetPlayerPed(value)
		if(target ~= ply) then
			local targetCoords = GetEntityCoords(GetPlayerPed(value), 0)
			local distance = GetDistanceBetweenCoords(targetCoords["x"], targetCoords["y"], targetCoords["z"], plyCoords["x"], plyCoords["y"], plyCoords["z"], true)
			if(closestDistance == -1 or closestDistance > distance) then
				closestPlayer = value
				closestDistance = distance
			end
		end
	end
	return closestPlayer, closestDistance
end

RegisterNetEvent('esx_animations:graba')
AddEventHandler('esx_animations:graba', function(anim, cc)
	FreezeEntityPosition(PlayerPedId(), false)
	if anim == "bro2" then
		local pedInFront = GetPlayerPed(GetClosestPlayer())
		--printGetPlayerServerId(GetClosestPlayer()))
		local heading = GetEntityHeading(pedInFront)
		local coords = GetOffsetFromEntityInWorldCoords(pedInFront, 0.0, 1.0, 0.0)
		local SyncOffsetFront = 1.34
		if SyncOffsetFront then
			coords = GetOffsetFromEntityInWorldCoords(pedInFront, 0.0, SyncOffsetFront, 0.0)
		end
		if cc == "ja" then
			SetEntityHeading(PlayerPedId(), heading - 180.1)
			SetEntityCoordsNoOffset(PlayerPedId(), tablica[1].x+tablica[1].xx*1.5, tablica[1].y+tablica[1].yy*1.5, coords.z, 0)
		end
		startAnim("mp_ped_interaction", "hugs_guy_b")
	elseif anim == "bro" then
		local pedInFront = GetPlayerPed(GetClosestPlayer())
		--printGetPlayerServerId(GetClosestPlayer()))
		local heading = GetEntityHeading(pedInFront)
		local coords = GetOffsetFromEntityInWorldCoords(pedInFront, 0.0, 1.0, 0.0)
		local SyncOffsetFront = 1.34
		if SyncOffsetFront then
			coords = GetOffsetFromEntityInWorldCoords(pedInFront, 0.0, SyncOffsetFront, 0.0)
		end
		if cc == "ja" then
			SetEntityHeading(PlayerPedId(), heading - 180.1)
			SetEntityCoordsNoOffset(PlayerPedId(), tablica[1].x+tablica[1].xx*0.9, tablica[1].y+tablica[1].yy*0.9, coords.z, 0)
		end
		startAnim("mp_ped_interaction", "hugs_guy_a")
	elseif anim == "podaj" then
		local pedInFront = GetPlayerPed(GetClosestPlayer())
		--printGetPlayerServerId(GetClosestPlayer()))
		local heading = GetEntityHeading(pedInFront)
		local coords = GetOffsetFromEntityInWorldCoords(pedInFront, 0.0, 1.0, 0.0)
		local SyncOffsetFront = 1.34
		if SyncOffsetFront then
			coords = GetOffsetFromEntityInWorldCoords(pedInFront, 0.0, SyncOffsetFront, 0.0)
		end
		if cc == "ja" then
			SetEntityHeading(PlayerPedId(), heading - 180.1)
			SetEntityCoordsNoOffset(PlayerPedId(), tablica[1].x+tablica[1].xx*0.8, tablica[1].y+tablica[1].yy*0.8, coords.z, 0)
		end
		startAnim("mp_common", "givetake1_a")
	elseif anim == "podaj2" then
		local pedInFront = GetPlayerPed(GetClosestPlayer())
		--printGetPlayerServerId(GetClosestPlayer()))
		local heading = GetEntityHeading(pedInFront)
		local coords = GetOffsetFromEntityInWorldCoords(pedInFront, 0.0, 1.0, 0.0)
		local SyncOffsetFront = 1.34
		if SyncOffsetFront then
			coords = GetOffsetFromEntityInWorldCoords(pedInFront, 0.0, SyncOffsetFront, 0.0)
		end
		if cc == "ja" then
			SetEntityHeading(PlayerPedId(), heading - 180.1)
			SetEntityCoordsNoOffset(PlayerPedId(), tablica[1].x+tablica[1].xx, tablica[1].y+tablica[1].yy, coords.z, 0)
		end
		startAnim("mp_common", "givetake1_b")
	elseif anim == "przytulenie" then
		local pedInFront = GetPlayerPed(GetClosestPlayer())
		--printGetPlayerServerId(GetClosestPlayer()))
		local heading = GetEntityHeading(pedInFront)
		local coords = GetOffsetFromEntityInWorldCoords(pedInFront, 0.0, 1.0, 0.0)
		local SyncOffsetFront = 1.34
		if SyncOffsetFront then
			coords = GetOffsetFromEntityInWorldCoords(pedInFront, 0.0, SyncOffsetFront, 0.0)
		end
		if cc == "ja" then
			SetEntityHeading(PlayerPedId(), heading - 180.1)
			SetEntityCoordsNoOffset(PlayerPedId(), tablica[1].x+tablica[1].xx, tablica[1].y+tablica[1].yy, coords.z, 0)
		end
		startAnim("mp_ped_interaction", "kisses_guy_a")
	elseif anim == "przytulenie2" then
		local pedInFront = GetPlayerPed(GetClosestPlayer())
		--printGetPlayerServerId(GetClosestPlayer()))
		local heading = GetEntityHeading(pedInFront)
		local coords = GetOffsetFromEntityInWorldCoords(pedInFront, 0.0, 1.0, 0.0)
		local SyncOffsetFront = 1.34
		if SyncOffsetFront then
			coords = GetOffsetFromEntityInWorldCoords(pedInFront, 0.0, SyncOffsetFront, 0.0)
		end
		if cc == "ja" then
			SetEntityHeading(PlayerPedId(), heading - 180.1)
			SetEntityCoordsNoOffset(PlayerPedId(), tablica[1].x+tablica[1].xx*1.2, tablica[1].y+tablica[1].yy*1.2, coords.z, 0)
		end
		startAnim("mp_ped_interaction", "kisses_guy_b")
	elseif anim == "uderz" then
		local pedInFront = GetPlayerPed(GetClosestPlayer())
		--printGetPlayerServerId(GetClosestPlayer()))
		local heading = GetEntityHeading(pedInFront)
		local coords = GetOffsetFromEntityInWorldCoords(pedInFront, 0.0, 1.0, 0.0)
		local SyncOffsetFront = 1.34
		if SyncOffsetFront then
			coords = GetOffsetFromEntityInWorldCoords(pedInFront, 0.0, SyncOffsetFront, 0.0)
		end
		if cc == "ja" then
			SetEntityHeading(PlayerPedId(), heading - 180.1)
			SetEntityCoordsNoOffset(PlayerPedId(), tablica[1].x+tablica[1].xx*1, tablica[1].y+tablica[1].yy*1, coords.z, 0)
			startAnim("anim@gangops@hostage@", "victim_fail")
		else
			startAnim("melee@unarmed@streamed_variations", "plyr_takedown_rear_lefthook")
		end
	elseif anim == "uderz2" then
	  local pedInFront = GetPlayerPed(GetClosestPlayer())
	  --printGetPlayerServerId(GetClosestPlayer()))
	  local heading = GetEntityHeading(pedInFront)
	  local coords = GetOffsetFromEntityInWorldCoords(pedInFront, 0.0, 1.0, 0.0)
	  local SyncOffsetFront = 1.34
	  if SyncOffsetFront then
		coords = GetOffsetFromEntityInWorldCoords(pedInFront, 0.0, SyncOffsetFront, 0.0)
	  end
	  if cc == "ja" then
		SetEntityHeading(PlayerPedId(), heading - 180.1)
		SetEntityCoordsNoOffset(PlayerPedId(), tablica[1].x+tablica[1].xx*1.3, tablica[1].y+tablica[1].yy*1.3, coords.z, 0)
		startAnim("anim@gangops@hostage@", "victim_fail")
	  else
		startAnim("melee@unarmed@streamed_variations", "plyr_takedown_front_backslap")
	  end
	elseif anim == "siadd" then
		local pedInFront = GetPlayerPed(GetClosestPlayer())
		--printGetPlayerServerId(GetClosestPlayer()))
		local heading = GetEntityHeading(pedInFront)
		local coords = GetOffsetFromEntityInWorldCoords(pedInFront, 0.0, 1.0, 0.0)
		local SyncOffsetFront = 1.34
		if SyncOffsetFront then
			coords = GetOffsetFromEntityInWorldCoords(pedInFront, 0.0, SyncOffsetFront, 0.0)
		end
		if cc == "ja" then
			SetEntityHeading(PlayerPedId(), heading -10)
			SetEntityCoordsNoOffset(PlayerPedId(), tablica[1].x+tablica[1].xx*0.15, tablica[1].y+tablica[1].yy*0.15, coords.z, 0)
			Citizen.Wait(1000)
			w_loop = true
			wloop("timetable@reunited@ig_10", "base_amanda")
		else
			w_loop = true
			wloop("timetable@ron@ig_5_p3", "ig_5_p3_base")
		end
	elseif anim == "walizka2" then
		clearTask()
		local pedInFront = GetPlayerPed(GetClosestPlayer())
		--printGetPlayerServerId(GetClosestPlayer()))
		local heading = GetEntityHeading(pedInFront)
		local coords = GetOffsetFromEntityInWorldCoords(pedInFront, 0.0, 1.0, 0.0)
		local SyncOffsetFront = 1.34
		if SyncOffsetFront then
			coords = GetOffsetFromEntityInWorldCoords(pedInFront, 0.0, SyncOffsetFront, 0.0)
		end
		if cc == "ja" then
			SetEntityHeading(PlayerPedId(), heading - 180.1)
			SetEntityCoordsNoOffset(PlayerPedId(), tablica[1].x+tablica[1].xx*1, tablica[1].y+tablica[1].yy*1, coords.z, 0)
			startAnim("mp_common", "givetake1_a")
			Citizen.Wait(1500)
			startAnim("rcmepsilonism8", "bag_handler_idle_a",49, {bone = 57005, object = "prop_security_case_01", offset = {x = 0.10, y = 0.0, z = 0.0}, rotation = {x = 0.0, y = 280.0, z = 53.0}})
		else
			startAnim("mp_common", "givetake1_a",1, {bone = 57005, object = "prop_security_case_01", offset = {x = 0.10, y = 0.0, z = 0.0}, rotation = {x = 0.0, y = 280.0, z = 53.0}})
			Citizen.Wait(1500)
			clearTask()
		end
	elseif anim == "bukiet" then
		local pedInFront = GetPlayerPed(GetClosestPlayer())
		--printGetPlayerServerId(GetClosestPlayer()))
		local heading = GetEntityHeading(pedInFront)
		local coords = GetOffsetFromEntityInWorldCoords(pedInFront, 0.0, 1.0, 0.0)
		local SyncOffsetFront = 1.34
		if SyncOffsetFront then
			coords = GetOffsetFromEntityInWorldCoords(pedInFront, 0.0, SyncOffsetFront, 0.0)
		end
		if cc == "ja" then
			SetEntityHeading(PlayerPedId(), heading - 180.1)
			SetEntityCoordsNoOffset(PlayerPedId(), tablica[1].x+tablica[1].xx*1, tablica[1].y+tablica[1].yy*1, coords.z, 0)
			startAnim("mp_common", "givetake1_a")
			Citizen.Wait(1500)
			startAnim("impexp_int-0", "mp_m_waremech_01_dual-0",49, {bone = 24817, object = "prop_snow_flower_02", offset = {x = -0.29, y = 0.40, z = -0.02}, rotation = {x = -90.0, y = -90.0, z = 0.0}})
		else
			startAnim("mp_common", "givetake1_a",1, {bone = 57005, object = "prop_snow_flower_02", offset = {x = 0.36, y = 0.0, z = -0.02}, rotation = {x = -30.0, y = 90.0, z = 0.0}})
			Citizen.Wait(1500)
			clearTask()
		end
	elseif anim == "joint" then
		local pedInFront = GetPlayerPed(GetClosestPlayer())
		--printGetPlayerServerId(GetClosestPlayer()))
		local heading = GetEntityHeading(pedInFront)
		local coords = GetOffsetFromEntityInWorldCoords(pedInFront, 0.0, 1.0, 0.0)
		local SyncOffsetFront = 1.34
		if SyncOffsetFront then
			coords = GetOffsetFromEntityInWorldCoords(pedInFront, 0.0, SyncOffsetFront, 0.0)
		end
		if cc == "ja" then
			SetEntityHeading(PlayerPedId(), heading - 180.1)
			SetEntityCoordsNoOffset(PlayerPedId(), tablica[1].x+tablica[1].xx*1, tablica[1].y+tablica[1].yy*1, coords.z, 0)
			Citizen.Wait(2500)
			startAnim("mp_common", "givetake1_a")
			Citizen.Wait(1500)
			startAnim("amb@world_human_aa_smoke@male@idle_a", "idle_c",49, {bone = 47419, object = "p_cs_joint_02", offset = {x = 0.015, y = -0.009, z = 0.003}, rotation = {x = 55.0, y = 0.0, z = 110.0}})
		else
			startAnim("amb@world_human_aa_smoke@male@idle_a", "idle_c",49, {bone = 47419, object = "p_cs_joint_02", offset = {x = 0.015, y = -0.009, z = 0.003}, rotation = {x = 55.0, y = 0.0, z = 110.0}})
			Citizen.Wait(2500)
			startAnim("mp_common", "givetake1_a",1, {bone = 57005, object = "p_cs_joint_02", offset = {x = 0.21, y = 0.0, z = -0.02}, rotation = {x = 0.0, y = 90.0, z = 0.0}})
			Citizen.Wait(1500)
			clearTask()
		end
	elseif anim == "segz" then
		local pedInFront = GetPlayerPed(GetClosestPlayer())
		--printGetPlayerServerId(GetClosestPlayer()))
		local heading = GetEntityHeading(pedInFront)
		local coords = GetOffsetFromEntityInWorldCoords(pedInFront, 0.0, 1.0, 0.0)
		local SyncOffsetFront = 1.34
		if SyncOffsetFront then
			coords = GetOffsetFromEntityInWorldCoords(pedInFront, 0.0, SyncOffsetFront, 0.0)
		end
		if cc == "ja" then
			SetEntityHeading(PlayerPedId(), heading)
			SetEntityCoordsNoOffset(PlayerPedId(), tablica[1].x+tablica[1].xx*0.4, tablica[1].y+tablica[1].yy*0.4, coords.z, 0)
			w_loop = true
			wloop("switch@trevor@mocks_lapdance", "001443_01_trvs_28_idle_stripper")
		else
			w_loop = true
			wloop("anim@mp_player_intupperair_shagging", "idle_a")
		end
	elseif anim == "lodzik" then
		local pedInFront = GetPlayerPed(GetClosestPlayer())
		--printGetPlayerServerId(GetClosestPlayer()))
		local heading = GetEntityHeading(pedInFront)
		local coords = GetOffsetFromEntityInWorldCoords(pedInFront, 0.0, 1.0, 0.0)
		local SyncOffsetFront = 1.34
		if SyncOffsetFront then
			coords = GetOffsetFromEntityInWorldCoords(pedInFront, 0.0, SyncOffsetFront, 0.0)
		end
		if cc == "ja" then
			SetEntityHeading(PlayerPedId(), heading -180.1)
			SetEntityCoordsNoOffset(PlayerPedId(), tablica[1].x+tablica[1].xx*0.1, tablica[1].y+tablica[1].yy*0.1, coords.z, 0)
			w_loop = true
			wloop("random@getawaydriver", "idle_a")
		else
			w_loop = true
			wloop("anim@mp_player_intupperair_shagging", "idle_a")
		end
	elseif anim == "taniec1" then
	  local pedInFront = GetPlayerPed(GetClosestPlayer())
	  --printGetPlayerServerId(GetClosestPlayer()))
	  local heading = GetEntityHeading(pedInFront)
	  local coords = GetOffsetFromEntityInWorldCoords(pedInFront, 0.0, 1.0, 0.0)
	  local SyncOffsetFront = 1.34
	  if SyncOffsetFront then
		coords = GetOffsetFromEntityInWorldCoords(pedInFront, 0.0, SyncOffsetFront, 0.0)
	  end
	  if cc == "ja" then
		SetEntityHeading(PlayerPedId(), heading -180.1)
		SetEntityCoordsNoOffset(PlayerPedId(), tablica[1].x+tablica[1].xx*0.8, tablica[1].y+tablica[1].yy*0.8, coords.z, 0)
	  end
	  w_loop = true
	  wloop("anim@amb@nightclub@mini@dance@dance_solo@female@var_a@", "high_center", 5000)
	elseif anim == "taniec2" then
	  local pedInFront = GetPlayerPed(GetClosestPlayer())
	  --printGetPlayerServerId(GetClosestPlayer()))
	  local heading = GetEntityHeading(pedInFront)
	  local coords = GetOffsetFromEntityInWorldCoords(pedInFront, 0.0, 1.0, 0.0)
	  local SyncOffsetFront = 1.34
	  if SyncOffsetFront then
		coords = GetOffsetFromEntityInWorldCoords(pedInFront, 0.0, SyncOffsetFront, 0.0)
	  end
	  if cc == "ja" then
		SetEntityHeading(PlayerPedId(), heading -180.1)
		SetEntityCoordsNoOffset(PlayerPedId(), tablica[1].x+tablica[1].xx*1.2, tablica[1].y+tablica[1].yy*1.2, coords.z, 0)
	  end
	  w_loop = true
	  wloop("misschinese2_crystalmazemcs1_cs", "dance_loop_tao", 18000)
	elseif anim == "taniec3" then
	  local pedInFront = GetPlayerPed(GetClosestPlayer())
	  --printGetPlayerServerId(GetClosestPlayer()))
	  local heading = GetEntityHeading(pedInFront)
	  local coords = GetOffsetFromEntityInWorldCoords(pedInFront, 0.0, 1.0, 0.0)
	  local SyncOffsetFront = 1.34
	  if SyncOffsetFront then
		coords = GetOffsetFromEntityInWorldCoords(pedInFront, 0.0, SyncOffsetFront, 0.0)
	  end
	  if cc == "ja" then
		SetEntityHeading(PlayerPedId(), heading -180.1)
		SetEntityCoordsNoOffset(PlayerPedId(), tablica[1].x+tablica[1].xx*1, tablica[1].y+tablica[1].yy*1, coords.z, 0)
	  end
	  w_loop = true
	  wloop("special_ped@mountain_dancer@monologue_3@monologue_3a", "mnt_dnc_buttwag", 15100)
	elseif anim == "taniec4" then
	  local pedInFront = GetPlayerPed(GetClosestPlayer())
	  --printGetPlayerServerId(GetClosestPlayer()))
	  local heading = GetEntityHeading(pedInFront)
	  local coords = GetOffsetFromEntityInWorldCoords(pedInFront, 0.0, 1.0, 0.0)
	  local SyncOffsetFront = 1.34
	  if SyncOffsetFront then
		coords = GetOffsetFromEntityInWorldCoords(pedInFront, 0.0, SyncOffsetFront, 0.0)
	  end
	  if cc == "ja" then
		SetEntityHeading(PlayerPedId(), heading -180.1)
		SetEntityCoordsNoOffset(PlayerPedId(), tablica[1].x+tablica[1].xx*0.7, tablica[1].y+tablica[1].yy*0.7, coords.z, 0)
	  end
	  w_loop = true
	  wloop("anim@amb@nightclub@dancers@solomun_entourage@", "mi_dance_facedj_17_v1_female^1", 15100)
	elseif anim == "taniec5" then
	  local pedInFront = GetPlayerPed(GetClosestPlayer())
	  --printGetPlayerServerId(GetClosestPlayer()))
	  local heading = GetEntityHeading(pedInFront)
	  local coords = GetOffsetFromEntityInWorldCoords(pedInFront, 0.0, 1.0, 0.0)
	  local SyncOffsetFront = 1.34
	  if SyncOffsetFront then
		coords = GetOffsetFromEntityInWorldCoords(pedInFront, 0.0, SyncOffsetFront, 0.0)
	  end
	  if cc == "ja" then
		SetEntityHeading(PlayerPedId(), heading -180.1)
		SetEntityCoordsNoOffset(PlayerPedId(), tablica[1].x+tablica[1].xx*1, tablica[1].y+tablica[1].yy*1, coords.z, 0)
	  end
	  w_loop = true
	  wloop("anim@amb@nightclub@mini@dance@dance_solo@male@var_b@", "high_center_down", 5250)
	elseif anim == "taniec6" then
	  local pedInFront = GetPlayerPed(GetClosestPlayer())
	  --printGetPlayerServerId(GetClosestPlayer()))
	  local heading = GetEntityHeading(pedInFront)
	  local coords = GetOffsetFromEntityInWorldCoords(pedInFront, 0.0, 1.0, 0.0)
	  local SyncOffsetFront = 1.34
	  if SyncOffsetFront then
		coords = GetOffsetFromEntityInWorldCoords(pedInFront, 0.0, SyncOffsetFront, 0.0)
	  end
	  if cc == "ja" then
		SetEntityHeading(PlayerPedId(), heading -180.1)
		SetEntityCoordsNoOffset(PlayerPedId(), tablica[1].x+tablica[1].xx*1, tablica[1].y+tablica[1].yy*1, coords.z, 0)
	  end
	  w_loop = true
	  wloop("anim@amb@nightclub@mini@dance@dance_solo@female@var_b@", "high_center", 5250)
	elseif anim == "taniec7" then
	  local pedInFront = GetPlayerPed(GetClosestPlayer())
	  --printGetPlayerServerId(GetClosestPlayer()))
	  local heading = GetEntityHeading(pedInFront)
	  local coords = GetOffsetFromEntityInWorldCoords(pedInFront, 0.0, 1.0, 0.0)
	  local SyncOffsetFront = 1.34
	  if SyncOffsetFront then
		coords = GetOffsetFromEntityInWorldCoords(pedInFront, 0.0, SyncOffsetFront, 0.0)
	  end
	  if cc == "ja" then
		SetEntityHeading(PlayerPedId(), heading -180.1)
		SetEntityCoordsNoOffset(PlayerPedId(), tablica[1].x+tablica[1].xx*0.8, tablica[1].y+tablica[1].yy*0.8, coords.z, 0)
	  end
	  w_loop = true
	  wloop("anim@amb@nightclub@mini@dance@dance_solo@female@var_a@", "high_center_up", 5500)
	elseif anim == "taniec8" then
	  local pedInFront = GetPlayerPed(GetClosestPlayer())
	  --printGetPlayerServerId(GetClosestPlayer()))
	  local heading = GetEntityHeading(pedInFront)
	  local coords = GetOffsetFromEntityInWorldCoords(pedInFront, 0.0, 1.0, 0.0)
	  local SyncOffsetFront = 1.34
	  if SyncOffsetFront then
		coords = GetOffsetFromEntityInWorldCoords(pedInFront, 0.0, SyncOffsetFront, 0.0)
	  end
	  if cc == "ja" then
		SetEntityHeading(PlayerPedId(), heading )
		SetEntityCoordsNoOffset(PlayerPedId(), tablica[1].x+tablica[1].xx*0.3, tablica[1].y+tablica[1].yy*0.3, coords.z, 0)
		w_loop = true
		wloop("anim@amb@nightclub@mini@dance@dance_solo@female@var_a@", "low_center_down", 5000)
	  else
		w_loop = true
		wloop("anim@amb@nightclub@dancers@crowddance_facedj@hi_intensity", "hi_dance_facedj_09_v2_female^1", 7000)
	  end
	elseif anim == "taniec9" then
	  local pedInFront = GetPlayerPed(GetClosestPlayer())
	  --printGetPlayerServerId(GetClosestPlayer()))
	  local heading = GetEntityHeading(pedInFront)
	  local coords = GetOffsetFromEntityInWorldCoords(pedInFront, 0.0, 1.0, 0.0)
	  local SyncOffsetFront = 1.34
	  if SyncOffsetFront then
		coords = GetOffsetFromEntityInWorldCoords(pedInFront, 0.0, SyncOffsetFront, 0.0)
	  end
	  if cc == "ja" then
		SetEntityHeading(PlayerPedId(), heading - 180.1)
		SetEntityCoordsNoOffset(PlayerPedId(), tablica[1].x+tablica[1].xx*0.3, tablica[1].y+tablica[1].yy*0.3, coords.z, 0)
	  end
	  w_loop = true
	  wloop("anim@amb@nightclub@lazlow@hi_podium@", "danceidle_hi_11_buttwiggle_b_laz", 11000)
	elseif anim == "taniec10" then
	  local pedInFront = GetPlayerPed(GetClosestPlayer())
	  --printGetPlayerServerId(GetClosestPlayer()))
	  local heading = GetEntityHeading(pedInFront)
	  local coords = GetOffsetFromEntityInWorldCoords(pedInFront, 0.0, 1.0, 0.0)
	  local SyncOffsetFront = 1.34
	  if SyncOffsetFront then
		coords = GetOffsetFromEntityInWorldCoords(pedInFront, 0.0, SyncOffsetFront, 0.0)
	  end
	  if cc == "ja" then
		SetEntityHeading(PlayerPedId(), heading )
		SetEntityCoordsNoOffset(PlayerPedId(), tablica[1].x+tablica[1].xx*0.4, tablica[1].y+tablica[1].yy*0.4, coords.z, 0)
		w_loop = true
		wloop("mini@strip_club@lap_dance@ld_girl_a_song_a_p1", "ld_girl_a_song_a_p1_f", 9000)
	  else
		w_loop = true
		wloop("anim@amb@nightclub@lazlow@hi_podium@", "danceidle_hi_17_smackthat_laz", 17000)
	  end
	elseif anim == "taniec11" then
	  local pedInFront = GetPlayerPed(GetClosestPlayer())
	  --printGetPlayerServerId(GetClosestPlayer()))
	  local heading = GetEntityHeading(pedInFront)
	  local coords = GetOffsetFromEntityInWorldCoords(pedInFront, 0.0, 1.0, 0.0)
	  local SyncOffsetFront = 1.34
	  if SyncOffsetFront then
		coords = GetOffsetFromEntityInWorldCoords(pedInFront, 0.0, SyncOffsetFront, 0.0)
	  end
	  if cc == "ja" then
		SetEntityHeading(PlayerPedId(), heading - 180.1)
		SetEntityCoordsNoOffset(PlayerPedId(), tablica[1].x+tablica[1].xx*1, tablica[1].y+tablica[1].yy*1, coords.z, 0)
	  end
	  startAnim("anim@amb@nightclub@lazlow@hi_dancefloor@", "crowddance_hi_11_handup_laz", 1, {bone = 28422,
	  object = "ba_prop_battle_hobby_horse",
	  offset = {x = 0.0, y = 0.0, z = 0.0},
	  rotation = {x = 0.0, y = 0.0, z = 0.0}})
	elseif anim == "taniec12" then
	  local pedInFront = GetPlayerPed(GetClosestPlayer())
	  --printGetPlayerServerId(GetClosestPlayer()))
	  local heading = GetEntityHeading(pedInFront)
	  local coords = GetOffsetFromEntityInWorldCoords(pedInFront, 0.0, 1.0, 0.0)
	  local SyncOffsetFront = 1.34
	  if SyncOffsetFront then
		coords = GetOffsetFromEntityInWorldCoords(pedInFront, 0.0, SyncOffsetFront, 0.0)
	  end
	  if cc == "ja" then
		SetEntityHeading(PlayerPedId(), heading -180.1 )
		SetEntityCoordsNoOffset(PlayerPedId(), tablica[1].x+tablica[1].xx*1.3, tablica[1].y+tablica[1].yy*1.3, coords.z, 0)
	  end
	  w_loop = true
	  wloop("timetable@tracy@ig_5@idle_a", "idle_a", 7000)
	end
	FreezeEntityPosition(PlayerPedId(), false)
end)

function wloop(aa,bb, cc)
	if cc == nil then
		while w_loop do
			Citizen.Wait(1)
			startAnim(aa, bb)
			Citizen.Wait(1000)
		end
	else
		while w_loop do
			Citizen.Wait(1)
			startAnim(aa, bb)
			Citizen.Wait(cc)
		end
	end
end
-- 77RP

local bindsadasda = nil

function OpenAnimationsMenu()

	local elements = {}
	if not binding then
		if binds then
			table.insert(elements, {label = '⭐ <span style="color: yellow;">Zbinduj Animacje (SHIFT+#)</span>', value = "binds"})
		end

		table.insert(elements, {label = '❌ <span style="color: #fa8282;">PRZERWIJ</span>', value = "cancel"})
	end
	
	local texxaxs = nil
	if not binding then
		texxaxs = 'Animacje'
	else
		texxaxs = 'Bindowanie (SHIFT+'..bindsadasda..')'
	end
	
	for _, group in ipairs(Config.Animations) do
		if not group.resource or GetResourceState(group.resource) == 'started' then
			if group.hide ~= true and group.jddd ~= true then
				table.insert(elements, {label = group.label, value = group.name})
			end
		end
	end
	  
	if isDog() then
		table.insert(elements, {label = '🐕 Pies', value = 'piess'})
	end

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'animations', {
		title    = texxaxs,
		align    = 'bottom-right',
		elements = elements
	}, function(data, menu)
		if data.current.value == 'binds' then
			menu.close()
			OpenBindsSubMenu()
		elseif data.current.value ~= 'cancel' then
			menu.close()
			if data.current.value == 'tancee' or data.current.value == "siedzenie" or data.current.value == "praca" or data.current.value == "sytuacyjne" or data.current.value == "wspolne"  then
				podkategoria(data.current.value)
			else
				OpenAnimationsSubMenu(data.current.value)
			end
		elseif not exports['esx_policejob']:isHandcuffed() then
			clearTask()
		end
	end, function(data, menu)
		if not binding then
			menu.close()
		else
			print('binduj')
		end
	end)
end

function OpenBindsSubMenu()
	local elements = {}
	for i = 1, 9 do
		local bind = binds[i]
		if bind then
			table.insert(elements, {label = i .. ' - ' .. bind.label, value = i, assigned = true})
		else
			table.insert(elements, {label = i .. ' - PRZYPISZ', value = i, assigned = false})
		end
	end
	
	local diasdsa = nil
	
	window = ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'animations_binds', {
		title    = 'Animacje - ulubione',
		align    = 'bottom-right',
		elements = elements
	}, function(data, menu)
		menu.close()
		window = nil

		local index = tonumber(data.current.value)
		diasdsa = tonumber(data.current.value)
		if data.current.assigned then
			binds[index] = nil
			TriggerEvent('esx_animations:save', binds)
			OpenBindsSubMenu()
		else
			binding = tonumber(data.current.value)
			bindsadasda = data.current.value
			OpenAnimationsMenu()
		end
	end, function(data, menu)
		menu.close()
		window = nil
		OpenAnimationsMenu()
	end)
end

function OpenAnimationsSubMenu(menu, menu2, menu3)
	local title, elements = nil, {}
	for _, group in ipairs(Config.Animations) do
		if group.name == menu then
			for _, item in ipairs(group.items) do
				table.insert(elements, {label = item.label .. (item.keyword and ' <span style="font-size: 11px; color: rgb(106, 0, 255);">/e ' .. item.keyword .. '</span>' or ''), short = item.label, type = item.type, data = item.data})
			end

			title = group.label
			break
		end
	end

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'animations_' .. menu, {
		title    = title,
		align    = 'bottom-right',
		elements = elements
	}, function(data, menu)
		if binding then
			menu.close()

			window = nil
			if not binds then
				binds = {}
			end

			binds[binding] = {
				label = '[' .. title .. '] ' .. data.current.short,
				type = data.current.type,
				data = data.current.data
			}
			TriggerEvent('esx_animations:save', binds)

			binding = nil
			OpenBindsSubMenu()
		else
			TriggerEvent('esx_animations:trigger', data.current)
		end
	end, function(data, menu)
		if not binding then
			menu.close()
			if menu3 then
				podkategoria(menu2)
			else
				OpenAnimationsMenu()
			end
		else
			print('binduj')
		end
	end)
end

RegisterNetEvent('esx_animations:save')
AddEventHandler('esx_animations:save', function(binds)
	SetResourceKvp('AnimBinds', json.encode(binds))
end)

local crouched = false
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1)
        local ped = PlayerPedId()
        if DoesEntityExist(ped) and not isDead then
            DisableControlAction(0, 36, true)
            if not IsPauseMenuActive() then
                if IsDisabledControlJustPressed(0, 36) then
                    RequestAnimSet("move_ped_crouched")
                    while not HasAnimSetLoaded("move_ped_crouched") do
                        Citizen.Wait(100)
                    end
                    if crouched then
                        ResetPedMovementClipset(ped, 0)
                        crouched = false
                    elseif not crouched then
                        SetPedMovementClipset(ped, "move_ped_crouched", 0.25)
                        crouched = true
                    end
                end
            end
        end
    end
end)

RegisterCommand("e",function(source, args)
	if not isDead then
		local player = PlayerPedId()
		if tostring(args[1]) == nil then
			return
		else
			if tostring(args[1]) ~= nil then
				local argh = tostring(args[1])
				for _, group in ipairs(Config.Animations) do
					for _, anim in ipairs(group.items) do
						if argh == anim.keyword then
							if anim.type == 'ragdoll' then
								ragdoll = true
							elseif anim.type == 'attitude' then
								if anim.data.car == true then
									if IsPedInAnyVehicle(PlayerPedId(), false) then
										startAttitude(anim.data.lib, anim.data.anim)
									end
								else
									if not IsPedInAnyVehicle(PlayerPedId(), false) then
										startAttitude(anim.data.lib, anim.data.anim)
									end
								end
							elseif anim.type == 'scenario' then
								if anim.data.car == true then
									if IsPedInAnyVehicle(PlayerPedId(), false) then
										startScenario(anim.data.anim, anim.data.offset)
									end
								else
									if not IsPedInAnyVehicle(PlayerPedId(), false) then
										startScenario(anim.data.anim, anim.data.offset)
									end
								end
							elseif anim.type == 'anim' then
								if anim.data.car == true then
									if IsPedInAnyVehicle(PlayerPedId(), false) then
										startAnim(anim.data.lib, anim.data.anim, anim.data.mode, anim.data.prop)
									end
								else
									if not IsPedInAnyVehicle(PlayerPedId(), false) then
										startAnim(anim.data.lib, anim.data.anim, anim.data.mode, anim.data.prop)
									end
								end
							elseif anim.type == 'pies' then
								if isDog() and not IsPedInAnyVehicle(PlayerPedId(), false) then
									startAnim(anim.data.lib, anim.data.anim, anim.data.mode, anim.data.prop)
								end
							else
								if not IsPedInAnyVehicle(PlayerPedId(), false) then
									startAnimLoop(anim.data)
								end
							end
						end
					end
				end
			end
		end
	end
end)

-- Key Controls
CreateThread(function()
	while true do
		Citizen.Wait(1)

		local ped = PlayerPedId()
		
		if ragdoll then
			SetPedToRagdoll(ped, 1000, 1000, 0, 0, 0, 0)
		end
		
		if loop.status and loop.current and loop.delay < GetGameTimer() and (not IsEntityPlayingAnim(ped, loop.current.lib, loop.current.anim, 3)) then
			loop.status = nil
			if prop and type(prop) ~= 'table' then
				if loop.dettach then
					DetachEntity(prop, true, false)
				else
					DeleteObject(prop)
					if prop2 ~= nil then
						DeleteObject(prop2)
						prop2 = nil
					end
					for _, item in ipairs(prop3) do
						DeleteObject(item.obj)
					end
				end
				prop = nil
			end
		end
		
		if type(prop) == 'table' and (not IsEntityPlayingAnim(ped, prop.lib, prop.anim, 3)) then
			DeleteObject(prop.obj)
			prop = nil
			if prop2 ~= nil then
				DeleteObject(prop2)
				prop2 = nil
			end
			for _, item in ipairs(prop3) do
				DeleteObject(item.obj)
			end
		end
		
		if IsControlPressed(0, Keys['LEFTSHIFT']) and not IsPedSprinting(ped) and not IsPedRunning(ped) then
			local bind = nil
			for i, key in ipairs({157, 158, 160, 164, 165, 159, 161, 162, 163}) do
				DisableControlAction(0, key, true)
				--[[if binds[i] == nil then
					print(binds[i])
				end]]
				if IsDisabledControlJustPressed(0, key) and binds[i] then
					bind = i
				end
			end

			if bind or exports['esx_policejob']:isHandcuffed() and not getCarry() then
				TriggerEvent('esx_animations:trigger', binds[bind])
			end
		end
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		if not isDead then
			if IsControlJustPressed(0, 170) then
				OpenAnimationsMenu(PlayerPedId())
			end
			
			if IsControlJustPressed(0, 73) then
				clearTask()
			end
		else
			Citizen.Wait(500)
		end
	end
end)

RegisterNetEvent('animacje')
AddEventHandler('animacje', function()
	OpenAnimationsMenu(PlayerPedId())
end)

function clearTask()
	w_loop = false
	if loop.status == true then
		finishLoop()
	elseif ragdoll then
		ragdoll = false
	else
		ClearPedTasks(PlayerPedId())
		if loop.status ~= nil then
			loop.status = nil
			if prop and type(prop) ~= 'table' then
				if loop.dettach then
					DetachEntity(prop, true, false)
				else
					DeleteObject(prop)
				end
				prop = nil
			end
		elseif type(prop) == 'table' then
			DeleteObject(prop.obj)
			prop = nil
			if prop2 ~= nil then
				DeleteObject(prop2)
				prop2 = nil
			end
			for _, item in ipairs(prop3) do
				DeleteObject(item.obj)
			end
		end
	end
end

--Noszenie

local Oczekuje4 = false
local Czas4 = 7
local wysylajacy4 = nil

RegisterNetEvent('w_animki:przytulSynchroC2')
AddEventHandler('w_animki:przytulSynchroC2', function(target)
	Oczekuje4 = true
	wysylajacy4 = target
end)

CreateThread(function()
    while true do
		Citizen.Wait(1000)
		if Oczekuje4 then
			Czas4 = Czas4 - 1
		end
    end
end)

CreateThread(function()
    while true do
		Citizen.Wait(250)
		if Czas4 < 1 then
			Oczekuje4 = false
			Czas4 = 7
			wysylajacy4 = nil
			ESX.ShowNotification('~r~Anulowano propozycję animacji')
		end
    end
end)

CreateThread(function()
    while true do
		Citizen.Wait(0)
		if Oczekuje4 then
			if IsControlJustReleased(0, Keys['E']) then
				Oczekuje4 = false
				Czas4 = 7
				TriggerServerEvent('w_animki:OdpalAnimacje5', wysylajacy4)
			end
		else
			Citizen.Wait(200)
		end
    end
end)

local carryingBackInProgress = false
local niesie = false

function getCarry()
	return carryingBackInProgress
end

CreateThread(function()
	while true do
		Citizen.Wait(0)
		if niesie then
			local coords = GetEntityCoords(Citizen.InvokeNative(0x43A66C31C68491C0, -1))
			ESX.Game.Utils.DrawText3D(coords, "NACIŚNIJ [~g~L~s~] ABY PUŚCIĆ", 0.45)
			if IsControlJustPressed(0, Keys['L']) then
				local closestPlayer, distance = ESX.Game.GetClosestPlayer()
				local target = GetPlayerServerId(closestPlayer)
				carryingBackInProgress = false
				niesie = false
				ClearPedSecondaryTask(Citizen.InvokeNative(0x43A66C31C68491C0, -1))
				DetachEntity(Citizen.InvokeNative(0x43A66C31C68491C0, -1), true, false)
				TriggerServerEvent("cmg2_animations:stop", target)
			end
		else
			Citizen.Wait(200)
		end
	end
end)

RegisterNetEvent('cmg2_animations:startMenu2')
AddEventHandler('cmg2_animations:startMenu2', function()  
  local Gracz = Citizen.InvokeNative(0x43A66C31C68491C0, -1)
	if not IsPedInAnyVehicle(Gracz, false) then
		local closestPlayer, distance = ESX.Game.GetClosestPlayer()
		if closestPlayer ~= nil and distance <= 4 then
			TriggerEvent('cmg2_animations:startMenu', GetPlayerServerId(closestPlayer))
		end
	end
end)

RegisterNetEvent('cmg2_animations:startMenu')
AddEventHandler('cmg2_animations:startMenu', function(obiekt)
	if not carryingBackInProgress then
		niesie = true
		carryingBackInProgress = true
		local player = PlayerPedId()	
		lib = 'missfinale_c2mcs_1'
		anim1 = 'fin_c2_mcs_1_camman'
		lib2 = 'nm'
		anim2 = 'firemans_carry'
		distans = 0.15
		distans2 = 0.27
		height = 0.63
		spin = 0.0		
		length = 100000
		controlFlagMe = 49
		controlFlagTarget = 33
		animFlagTarget = 1
		local closestPlayer = Citizen.InvokeNative(0x43A66C31C68491C0, obiekt)
		target = obiekt
		if closestPlayer ~= nil then
			TriggerServerEvent('cmg2_animations:sync', closestPlayer, lib,lib2, anim1, anim2, distans, distans2, height,target,length,spin,controlFlagMe,controlFlagTarget,animFlagTarget)
		end
	else
		carryingBackInProgress = false
		ClearPedSecondaryTask(Citizen.InvokeNative(0x43A66C31C68491C0, -1))
		DetachEntity(Citizen.InvokeNative(0x43A66C31C68491C0, -1), true, false)
		local closestPlayer = obiekt
		target = GetPlayerServerId(closestPlayer)
		TriggerServerEvent("cmg2_animations:stop",target)
	end
end)

RegisterNetEvent('cmg2_animations:syncTarget')
AddEventHandler('cmg2_animations:syncTarget', function(target, animationLib, animation2, distans, distans2, height, length,spin,controlFlag)
	local playerPed = Citizen.InvokeNative(0x43A66C31C68491C0, -1)
	local targetPed = Citizen.InvokeNative(0x43A66C31C68491C0, GetPlayerFromServerId(target))
	carryingBackInProgress = true
	RequestAnimDict(animationLib)

	while not HasAnimDictLoaded(animationLib) do
		Citizen.Wait(10)
	end
	if spin == nil then spin = 180.0 end
	AttachEntityToEntity(Citizen.InvokeNative(0x43A66C31C68491C0, -1), targetPed, 0, distans2, distans, height, 0.5, 0.5, spin, false, false, false, false, 2, false)
	if controlFlag == nil then controlFlag = 0 end
	TaskPlayAnim(playerPed, animationLib, animation2, 8.0, -8.0, length, controlFlag, 0, false, false, false)
end)

RegisterNetEvent('cmg2_animations:syncMe')
AddEventHandler('cmg2_animations:syncMe', function(animationLib, animation,length,controlFlag,animFlag)
	local playerPed = Citizen.InvokeNative(0x43A66C31C68491C0, -1)
	RequestAnimDict(animationLib)

	while not HasAnimDictLoaded(animationLib) do
		Citizen.Wait(10)
	end
	Wait(500)
	if controlFlag == nil then controlFlag = 0 end
	TaskPlayAnim(playerPed, animationLib, animation, 8.0, -8.0, length, controlFlag, 0, false, false, false)

	Citizen.Wait(length)
end)

RegisterNetEvent('cmg2_animations:cl_stop')
AddEventHandler('cmg2_animations:cl_stop', function()
	carryingBackInProgress = false
	niesie = false
	ClearPedSecondaryTask(Citizen.InvokeNative(0x43A66C31C68491C0, -1))
	DetachEntity(Citizen.InvokeNative(0x43A66C31C68491C0, -1), true, false)
end)


local lockpick = false

RegisterNetEvent('animki:lockpick')
AddEventHandler('animki:lockpick', function(rodzaj)
	if rodzaj == true then
		lockpick = true
	elseif rodzaj == false then
		lockpick = false
	end
end)




-- FIXED BY NIEZNAJOMY
-- FIXED BY NIEZNAJOMY
-- FIXED BY NIEZNAJOMY
-- FIXED BY NIEZNAJOMY
-- FIXED BY NIEZNAJOMY
-- FIXED BY NIEZNAJOMY
-- FIXED BY NIEZNAJOMY
-- FIXED BY NIEZNAJOMY
-- FIXED BY NIEZNAJOMY
-- FIXED BY NIEZNAJOMY
-- FIXED BY NIEZNAJOMY