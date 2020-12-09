--[[
Copyright (c) 2010-2020 MTA: Paradise

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program. If not, see <http://www.gnu.org/licenses/>.
]]

local vehiclesIgnoringLocked =
{
	[448] = true, [461] = true, [462] = true, [463] = true, [481] = true, [509] = true, [510] = true, [521] = true, [522] = true, [581] = true, [586] = true, -- bikes
	[430] = true, [446] = true, [452] = true, [453] = true, [454] = true, [472] = true, [473] = true, [484] = true, [493] = true, [595] = true, -- boats
	[424] = true, [457] = true, [471] = true, [539] = true, [568] = true, [571] = true -- recreational vehicles
}

--

local addCommandHandler_ = addCommandHandler
      addCommandHandler  = function( commandName, fn, restricted, caseSensitive )
	-- add the default command handlers
	if type( commandName ) ~= "table" then
		commandName = { commandName }
	end
	for key, value in ipairs( commandName ) do
		if key == 1 then
			addCommandHandler_( value, fn, restricted, caseSensitive )
		else
			addCommandHandler_( value,
				function( player, ... )
					-- check if he has permissions to execute the command, default is not restricted (aka if the command is restricted - will default to no permission; otherwise okay)
					if hasObjectPermissionTo( player, "command." .. commandName[ 1 ], not restricted ) then
						fn( player, ... )
					end
				end
			)
		end
	end
	
	-- check for alternative handlers, such as gotovehicle = gotoveh, gotocar
	for k, v in ipairs( commandName ) do
		if v:find( "vehicle" ) then
			for key, value in pairs( { "veh", "car" } ) do
				local newCommand = v:gsub( "vehicle", value )
				if newCommand ~= v then
					-- add a second (replaced) command handler
					addCommandHandler_( newCommand,
						function( player, ... )
							-- check if he has permissions to execute the command, default is not restricted (aka if the command is restricted - will default to no permission; otherwise okay)
							if hasObjectPermissionTo( player, "command." .. commandName[ 1 ], not restricted ) then
								fn( player, ... )
							end
						end
					)
				end
			end
		end
	end
end

--

local p = { }

local getPedOccupiedVehicle_ = getPedOccupiedVehicle
      getPedOccupiedVehicle = function( ped )
	local vehicle = isPedInVehicle( ped ) and getPedOccupiedVehicle_( ped )
	if vehicle and ( p[ ped ] and p[ ped ].vehicle == vehicle or getElementParent( vehicle ) ~= getResourceDynamicElementRoot( resource ) ) then
		return vehicle
	end
	return false
end

local function isPedEnteringVehicle( ped )
	return getPedOccupiedVehicle_( ped ) and not getPedOccupiedVehicle( ped )
end

--

local vehicleIDs = { }
local vehicles = { }

addEventHandler( "onResourceStart", resourceRoot,
	function( )
		-- Looking at it from a technical point of view, loading vehicles on a non-existant table makes only limited sense
		if not exports.sql:create_table( 'vehicles', 
			{
				{ name = 'vehicleID', type = 'int(10) unsigned', auto_increment = true, primary_key = true },
				{ name = 'model', type = 'int(10) unsigned' },
				{ name = 'posX', type = 'float' },
				{ name = 'posY', type = 'float' },
				{ name = 'posZ', type = 'float' },
				{ name = 'rotX', type = 'float' },
				{ name = 'rotY', type = 'float' },
				{ name = 'rotZ', type = 'float' },
				{ name = 'interior', type = 'tinyint(3) unsigned', default = 0 },
				{ name = 'dimension', type = 'int(10) unsigned', default = 0 },
				{ name = 'respawnPosX', type = 'float' },
				{ name = 'respawnPosY', type = 'float' },
				{ name = 'respawnPosZ', type = 'float' },
				{ name = 'respawnRotX', type = 'float' },
				{ name = 'respawnRotY', type = 'float' },
				{ name = 'respawnRotZ', type = 'float' },
				{ name = 'respawnInterior', type = 'int(10) unsigned', default = 0 },
				{ name = 'respawnDimension', type = 'int(10) unsigned', default = 0 },
				{ name = 'numberplate', type = 'varchar(8)' },
				{ name = 'health', type = 'int(10) unsigned', default = 1000 },
				{ name = 'color1', type = 'tinyint(3) unsigned', default = 0 },
				{ name = 'color2', type = 'tinyint(3) unsigned', default = 0 },
				{ name = 'characterID', type = 'int(11)', default = 0 },
				{ name = 'locked', type = 'tinyint(3) unsigned', default = 0 },
				{ name = 'engineState', type = 'tinyint(3) unsigned', default = 0 },
				{ name = 'lightsState', type = 'tinyint(3) unsigned', default = 0 },
				{ name = 'tintedWindows', type = 'tinyint(3) unsigned', default = 0 },
				{ name = 'fuel', type = 'float unsigned', default = 100 },
			} ) then cancelEvent( ) return end
		
		-- load all vehicles
		local result = exports.sql:query_assoc( "SELECT * FROM vehicles ORDER BY vehicleID ASC" )
		if result then
			for key, data in ipairs( result ) do
				local vehicle = createVehicle( data.model, data.posX, data.posY, data.posZ, data.rotX, data.rotY, data.rotZ, numberplate )
				
				-- tables for ID -> vehicle and vehicle -> data
				vehicleIDs[ data.vehicleID ] = vehicle
				vehicles[ vehicle ] = { vehicleID = data.vehicleID, respawnInterior = data.respawnInterior, respawnDimension = data.respawnDimension, characterID = data.characterID, engineState = not doesVehicleHaveEngine( vehicle ) or data.engineState == 1, tintedWindows = data.tintedWindows == 1, fuel = data.fuel }
				
				-- some properties
				setElementHealth( vehicle, data.health )
				if data.health <= 300 then
					setVehicleDamageProof( vehicle, true )
					vehicles[ vehicle ].engineState = false
				end
				setVehicleColor( vehicle, data.color1, data.color2, data.color1, data.color2 ) -- most vehicles don't use second/third color anyway
				setVehicleRespawnPosition( vehicle, data.respawnPosX, data.respawnPosY, data.respawnPosZ, data.respawnRotX, data.respawnRotY, data.respawnRotZ )
				setElementInterior( vehicle, data.interior )
				setElementDimension( vehicle, data.dimension )
				setVehicleLocked( vehicle, data.locked == 1 )
				setVehicleEngineState( vehicle, data.engineState == 1 )
				setVehicleOverrideLights( vehicle, data.lightsState + 1 )
				setElementData( vehicle, "fuel", data.fuel )
			end
		end
		
		-- bind a key for everyone
		for key, value in ipairs( getElementsByType( "player" ) ) do
			bindKey( value, "k", "down", "lockvehicle" )
			bindKey( value, "j", "down", "toggleengine" )
			bindKey( value, "l", "down", "togglelights" )
		end
		
		--
		
		-- Fuel update
		setTimer(
			function( )
				for vehicle, data in pairs( vehicles ) do
					if not isElement( vehicle ) or getElementType( vehicle ) ~= "vehicle" then
						vehicles[ vehicle ] = nil
					elseif data.engineState and data.fuel and not isVehicleEmpty( vehicle ) and doesVehicleHaveEngine( vehicle ) and doesVehicleHaveFuel( vehicle ) then
						local vx, vy, vz = getElementVelocity( vehicle )
						local speed = math.sqrt( vx * vx + vy * vy )
						local loss = ( speed > 0.65 and 2 * speed or speed ) * 0.1 + 0.005
						
						data.fuel = math.max( data.fuel - loss, 0 )
						if math.floor( data.fuel + 0.5 ) ~= getElementData( vehicle, "fuel" ) then
							setElementData( vehicle, "fuel", math.floor( data.fuel + 0.5 ) )
						end
						
						if data.fuel == 0 then
							setVehicleEngineState( vehicle, false )
							for seat = 0, getVehicleMaxPassengers( vehicle ) do
								local player = getVehicleOccupant( vehicle, seat )
								if player then
									triggerClientEvent( player, "gui:hint", player, "Sin Gasolina", "Tu vehiculo " .. getVehicleName( vehicle ) .. " esta sin gasolina!\nPara prevenir esto carga el vehiculo de gasolina con regularidad.", 3 )
								end
							end
						end
					end
				end
			end,
			2000,
			0
		)
	end
)

addCommandHandler( { "createvehicle", "makevehicle" },
	function( player, commandName, ... )
		model = table.concat( { ... }, " " )
		model = getVehicleModelFromName( model ) or tonumber( model )
		if model then
			local x, y, z, rz = getPositionInFrontOf( player )
			
			local vehicle = createVehicle( model, x, y, z, 0, 0, rz )
			if vehicle then
				local color1, color2 = getVehicleColor( vehicle )
				local vehicleID, error = exports.sql:query_insertid( "INSERT INTO vehicles (model, posX, posY, posZ, rotX, rotY, rotZ, numberplate, color1, color2, respawnPosX, respawnPosY, respawnPosZ, respawnRotX, respawnRotY, respawnRotZ, interior, dimension, respawnInterior, respawnDimension) VALUES (" .. table.concat( { model, x, y, z, 0, 0, rz, '"%s"', color1, color2, x, y, z, 0, 0, rz, getElementInterior( player ), getElementDimension( player ), getElementInterior( player ), getElementDimension( player ) }, ", " ) .. ")", getVehiclePlateText( vehicle ) )
				if vehicleID then
					-- tables for ID -> vehicle and vehicle -> data
					vehicleIDs[ vehicleID ] = vehicle
					vehicles[ vehicle ] = { vehicleID = vehicleID, respawnInterior = getElementInterior( player ), respawnDimension = getElementDimension( player ), characterID = 0, engineState = false, tintedWindows = false, fuel = 100 }
					
					-- some properties
					setElementInterior( vehicle, getElementInterior( player ) )
					setElementDimension( vehicle, getElementDimension( player ) )
					setVehicleEngineState( vehicle, false )
					setVehicleOverrideLights( vehicle, 1 )
					setElementData( vehicle, "fuel", 100 )
					
					-- success message
					outputChatBox( "Creado " .. getVehicleName( vehicle ) .. " (ID " .. vehicleID .. ")", player, 0, 255, 0 )
				else
					destroyElement( vehicle )
					outputChatBox( "Error MySQL.", player, 255, 0, 0 )
				end
			else
				outputChatBox( "Model de vehiculo invalido.", player, 255, 0, 0 )
			end
		else
			outputChatBox( "Syntax: /" .. commandName .. " [modelo]", player, 255, 255, 255 )
		end
	end,
	true
)

function create( player, vehicle )
	if isElement( player ) and isElement( vehicle ) then
		local characterID = exports.players:getCharacterID( player )
		if characterID then
			local model = getElementModel( vehicle )
			local x, y, z = getElementPosition( vehicle )
			local rx, ry, rz = getVehicleRotation( vehicle )
			local interior = getElementInterior( vehicle )
			local dimension = getElementDimension( vehicle )
			local color1, color2 = getVehicleColor( vehicle )
			
			local vehicleID, error = exports.sql:query_insertid( "INSERT INTO vehicles (model, posX, posY, posZ, rotX, rotY, rotZ, numberplate, color1, color2, respawnPosX, respawnPosY, respawnPosZ, respawnRotX, respawnRotY, respawnRotZ, interior, dimension, respawnInterior, respawnDimension, characterID) VALUES (" .. table.concat( { model, x, y, z, rx, ry, rz, '"%s"', color1, color2, x, y, z, rx, ry, rz, interior, dimension, interior, dimension, characterID }, ", " ) .. ")", getVehiclePlateText( vehicle ) )
			if vehicleID then
				local newVehicle = createVehicle( model, x, y, z, rx, ry, rz, getVehiclePlateText( vehicle ) )
				
				-- tables for ID -> vehicle and vehicle -> data
				vehicleIDs[ vehicleID ] = newVehicle
				vehicles[ newVehicle ] = { vehicleID = vehicleID, respawnInterior = interior, respawnDimension = dimension, characterID = characterID, engineState = false, tintedWindows = false, fuel = 100 }
				
				-- some properties
				setVehicleColor( newVehicle, color1, color2, color1, color2 ) -- most vehicles don't use second/third color anyway
				setVehicleRespawnPosition( newVehicle, x, y, z, rx, ry, rz )
				setElementInterior( newVehicle, interior )
				setElementDimension( newVehicle, dimension )
				setVehicleEngineState( newVehicle, false )
				setVehicleOverrideLights( newVehicle, 1 )
				setElementData( newVehicle, "fuel", 100 )
				
				return newVehicle, vehicleID
			end
		end
	end
end

addCommandHandler( { "deletevehicle", "delvehicle" },
	function( player, commandName, vehicleID )
		if hasObjectPermissionTo( player, "command.createvehicle", false ) or hasObjectPermissionTo( player, "command.temporaryvehicle", false ) then
			vehicleID = tonumber( vehicleID )
			if vehicleID and vehicleID ~= 0 then
				if ( vehicleID >= 0 and not hasObjectPermissionTo( player, "command.createvehicle", false ) ) or ( vehicleID < 0 and not hasObjectPermissionTo( player, "command.temporaryvehicle", false ) ) then
					outputChatBox( "No puedes borrar este vehiculo.", player, 255, 0, 0 )
				else
					local vehicle = vehicleIDs[ vehicleID ]
					if vehicle then
						if vehicleID < 0 or exports.sql:query_free( "DELETE FROM vehicles WHERE vehicleID = " .. vehicleID ) then
							outputChatBox( "Borraste el vehiculo " .. vehicleID .. " (" .. getVehicleName( vehicle ) .. ").", player, 0, 255, 153 )
							
							-- remove from vehicles list
							vehicleIDs[ vehicleID ] = nil
							vehicles[ vehicle ] = nil
							
							destroyElement( vehicle )
						else
							outputChatBox( "Error MySQL.", player, 255, 0, 0 )
						end
					else
						outputChatBox( "Vehiculo no encontrado.", player, 255, 0, 0 )
					end
				end
			else
				outputChatBox( "Syntax: /" .. commandName .. " [id]", player, 255, 255, 255 )
			end
		end
	end
)

addCommandHandler( { "repairvehicle", "fixvehicle" },
	function( player, commandName, otherPlayer )
		if otherPlayer then
			target, targetName = exports.players:getFromName( player, otherPlayer )
		else
			target = player
			targetName = getPlayerName( player ):gsub( "_", " " )
		end
		
		if target then
			local vehicle = getPedOccupiedVehicle( target )
			if vehicle then
				fixVehicle( vehicle )
				if isVehicleDamageProof( vehicle ) then
					setVehicleDamageProof( vehicle, false )
				end
				outputChatBox( "Tu vehiculo fue reparado por " .. getPlayerName( player ):gsub( "_", " " ) .. ".", target, 0, 255, 153 )
				if player ~= target then
					outputChatBox( "Reparaste el vehiculo de " .. targetName .. ".", player, 0, 255, 153 )
				end
			else
				outputChatBox( targetName .. " no esta en un vehiculo.", player, 255, 0, 0 )
			end
		end
	end,
	true
)

addCommandHandler( { "repairvehicles", "fixvehicles" },
	function( player, commandName )
		for vehicle in pairs( vehicles ) do
			fixVehicle( vehicle )
			if isVehicleDamageProof( vehicle ) then
				setVehicleDamageProof( vehicle, false )
			end
		end
		outputChatBox( "*** " .. getPlayerName( player ):gsub( "_", " " ) .. " reparo todos los vehiculos. ***", root, 0, 255, 153 )
	end,
	true
)

addCommandHandler( { "fillvehicle", "fuelvehicle", "refillvehicle" },
	function( player, commandName, otherPlayer )
		if otherPlayer then
			target, targetName = exports.players:getFromName( player, otherPlayer )
		else
			target = player
			targetName = getPlayerName( player ):gsub( "_", " " )
		end
		
		if target then
			local vehicle = getPedOccupiedVehicle( target )
			if vehicle then
				local data = vehicles[ vehicle ]
				if doesVehicleHaveFuel( vehicle ) and data then
					data.fuel = 100
					setElementData( vehicle, "fuel", data.fuel )
					
					outputChatBox( "Tu vehiculo fue llenado de gasolina por " .. getPlayerName( player ):gsub( "_", " " ) .. ".", target, 0, 255, 153 )
					if player ~= target then
						outputChatBox( "Llenaste de gasolina el vehiculo de " .. targetName .. ".", player, 0, 255, 153 )
					end
				else
					outputChatBox( targetName .. " este vehiculo no necesita gasolina.", player, 255, 0, 0 )
				end
			else
				outputChatBox( targetName .. " no esta en un vehiculo.", player, 255, 0, 0 )
			end
		end
	end,
	true
)

addCommandHandler( { "fillvehicles", "fuelvehicles", "refillvehicles" },
	function( player, commandName )
		for vehicle, data in pairs( vehicles ) do
			if doesVehicleHaveFuel( vehicle ) and getElementData( vehicle, "fuel" ) < 100 then
				data.fuel = 100
				setElementData( vehicle, "fuel", data.fuel )
			end
		end
		outputChatBox( "*** " .. getPlayerName( player ):gsub( "_", " " ) .. " relleno todos los vehiculos con gasolina. ***", root, 0, 255, 153 )
	end,
	true
)

addCommandHandler( "respawnvehicle",
	function( player, commandName, vehicleID )
		vehicleID = tonumber( vehicleID )
		if vehicleID then
			local vehicle = vehicleIDs[ vehicleID ]
			if vehicle then
				if vehicleID < 0 then
					fixVehicle( vehicle )
					if isVehicleDamageProof( vehicle ) then
						setVehicleDamageProof( vehicle, false )
					end
				else
					respawnVehicle( vehicle )
					saveVehicle( vehicle )
				end
				outputChatBox( "Respawneaste el vehiculo " .. vehicleID .. " (" .. getVehicleName( vehicle ) .. ").", player, 0, 255, 153 )
			else
				outputChatBox( "Vehiculo no encontrado.", player, 255, 0, 0 )
			end
		else
			outputChatBox( "Syntax: /" .. commandName .. " [id]", player, 255, 255, 255 )
		end
	end,
	true
)

addCommandHandler( "respawnvehicles",
	function( player, commandName )
		for vehicle, data in pairs( vehicles ) do
			if isVehicleEmpty( vehicle ) then
				if data.vehicleID < 0 then
					-- delete empty temp. vehicles
					vehicleIDs[ data.vehicleID ] = nil
					vehicles[ vehicle ] = nil
					
					destroyElement( vehicle )
				else
					respawnVehicle( vehicle )
				end
			end
		end
		if getResourceState( getResourceFromName( "vehicle-shop" ) ) == "running" then
			for key, value in ipairs( getElementsByType( "vehicle", getResourceRootElement( getResourceFromName( "vehicle-shop" ) ) ) ) do
				respawnVehicle( value )
			end
		end
		outputChatBox( "*** " .. getPlayerName( player ):gsub( "_", " " ) .. " respawneo todos los vehiculos. ***", root, 0, 255, 153 )
		exports.server:message( "%C03[" .. exports.players:getID( player ) .. "] " .. getPlayerName( player ):gsub( "_", " " ) .. " respawneo todos los vehiculos.%C" )
	end,
	true
)

addCommandHandler( "park",
	function( player, commandName )
		local vehicle = getPedOccupiedVehicle( player )
		if vehicle then
			local data = vehicles[ vehicle ]
			if data then
				if data.vehicleID < 0 then
					outputChatBox( "Los vehiculos temporales " .. data.vehicleID .. " (" .. getVehicleName( vehicle ) .. ") no pueden ser estacionados.", player, 255, 0, 0 )
				elseif ( data.characterID > 0 and exports.players:getCharacterID( player ) == data.characterID or exports.factions:isPlayerInFaction( player, -data.characterID, 1 ) ) or hasObjectPermissionTo( player, "command.createvehicle", false ) then
					local x, y, z = getElementPosition( vehicle )
					local rx, ry, rz = getVehicleRotation( vehicle )
					local success, error = exports.sql:query_free( "UPDATE vehicles SET respawnPosX = " .. x .. ", respawnPosY = " .. y .. ", respawnPosZ = " .. z .. ", respawnRotX = " .. rx .. ", respawnRotY = " .. ry .. ", respawnRotZ = " .. rz .. ", respawnInterior = " .. getElementInterior( vehicle ) .. ", respawnDimension = " .. getElementDimension( vehicle ) .. " WHERE vehicleID = " .. data.vehicleID )
					if success then
						setVehicleRespawnPosition( vehicle, x, y, z, rx, ry, rz )
						data.respawnInterior = getElementInterior( vehicle )
						data.respawnDimension = getElementDimension( vehicle )
						saveVehicle( vehicle )
						outputChatBox( "Vehiculo " .. data.vehicleID .. " (" .. getVehicleName( vehicle ) .. ") fue estacionado.", player, 0, 255, 0 )
					else
						outputChatBox( "Error al estacionar el vehiculo.", player, 255, 0, 0 )
					end
				else
					outputChatBox( "Tu no puedes estacionar este vehiculo.", player, 255, 0, 0 )
				end
			end
		else
			outputChatBox( "Tu no estas conduciendo ningun vehiculo.", player, 255, 0, 0 )
		end
	end
)

addCommandHandler( "getvehicle",
	function( player, commandName, vehicleID )
		vehicleID = tonumber( vehicleID )
		if vehicleID then
			local vehicle = vehicleIDs[ vehicleID ]
			if vehicle then
				local x, y, z, rz = getPositionInFrontOf( player )
				setElementPosition( vehicle, x, y, z )
				setElementDimension( vehicle, getElementDimension( player ) )
				setElementInterior( vehicle, getElementInterior( player ) )
				setVehicleRotation( vehicle, 0, 0, rz )
				outputChatBox( "Transportaste el vehiculo " .. vehicleID .. " (" .. getVehicleName( vehicle ) .. ") hacia tu posicion.", player, 0, 255, 153 )
				
				-- save the vehicle delayed since it might fall down/position might be adjusted to ground position
				if vehicleID > 0 then
					setTimer( saveVehicle, 2000, 1, vehicle )
				end
			else
				outputChatBox( "Vehiculo no encontrado.", player, 255, 0, 0 )
			end
		else
			outputChatBox( "Syntax: /" .. commandName .. " [id]", player, 255, 255, 255 )
		end
	end,
	true
)

addCommandHandler( "gotovehicle",
	function( player, commandName, vehicleID )
		vehicleID = tonumber( vehicleID )
		if vehicleID then
			local vehicle = vehicleIDs[ vehicleID ]
			if vehicle then
				setElementPosition( player, getPositionInFrontOf( vehicle, nil, 180 ) )
				setElementDimension( player, getElementDimension( vehicle ) )
				setElementInterior( player, getElementInterior( vehicle ) )
				outputChatBox( "Te transportaste hacia el vehiculo " .. vehicleID .. " (" .. getVehicleName( vehicle ) .. ").", player, 0, 255, 153 )
				
				-- save the vehicle delayed since it might fall down/position might be adjusted to ground position
				if vehicleID > 0 then
					setTimer( saveVehicle, 2000, 1, vehicle )
				end
			else
				outputChatBox( "Vehiculo no encontrado.", player, 255, 0, 0 )
			end
		else
			outputChatBox( "Syntax: /" .. commandName .. " [id]", player, 255, 255, 255 )
		end
	end,
	true
)

addCommandHandler( { "vehicleid", "thisvehicle" },
	function( player, commandName )
		local vehicle = getPedOccupiedVehicle( player )
		if vehicle then
			local vehicleID = vehicles[ vehicle ] and vehicles[ vehicle ].vehicleID
			if vehicleID then
				outputChatBox( "La id de este " .. getVehicleName( vehicle ) .. " es " .. vehicleID .. ".", player, 0, 255, 0 )
			else
				outputChatBox( "Este " .. getVehicleName( vehicle ) .. " no tiene ID.", player, 255, 0, 0 )
			end
		else
			outputChatBox( "No estas en ningun vehiculo.", player, 255, 0, 0 )
		end
	end
)

addCommandHandler( { "oldvehicleid", "oldvehicle" },
	function( player, commandName )
		local vehicle = p[ player ] and p[ player ].oldVehicle
		if vehicle and isElement( vehicle ) then
			local vehicleID = vehicles[ vehicle ] and vehicles[ vehicle ].vehicleID
			if vehicleID then
				outputChatBox( "La id de tu anterior " .. getVehicleName( vehicle ) .. " es " .. vehicleID .. ".", player, 0, 255, 0 )
			else
				outputChatBox( "Este " .. getVehicleName( vehicle ) .. " no tiene ID.", player, 255, 0, 0 )
			end
		else
			outputChatBox( "No estas en ningun vehiculo.", player, 255, 0, 0 )
		end
	end
)

addCommandHandler( "setwindowstinted",
	function( player, commandName, other, state )
		local state = tonumber( state )
		if other and state then
			local other, name = exports.players:getFromName( player, other )
			if other then
				local vehicle = getPedOccupiedVehicle( other )
				if vehicle then
					local data = vehicles[ vehicle ]
					if data then
						if state ~= 1 then
							state = 0
						end
						
						if data.vehicleID < 0 or exports.sql:query_free( "UPDATE vehicles SET tintedWindows = " .. state .. " WHERE vehicleID = " .. data.vehicleID ) then
							data.tintedWindows = state == 1
							outputChatBox( "Las ventanas tintadas ahora estan " .. ( data.tintedWindows and "activadas" or "desactivadas" ) .. ".", player, 0, 255, 153 )
							
							for i = 0, getVehicleMaxPassengers( vehicle ) do
								local p = getVehicleOccupant( vehicle, i )
								if p then
									exports.players:updateNametag( p )
								end
							end
						else
							outputChatBox( "Error MySQL.", player, 255, 0, 0 )
						end
					else
						outputChatBox( "Error del vehiculo.", player, 255, 0, 0 )
					end
				else
					outputChatBox( name .. " no esta conduciendo ningun vehiculo.", player, 255, 0, 0 )
				end
			end
		else
			outputChatBox( "Syntax: /" .. commandName .. " [jugador] [1 = activado, 0 = desactivado]", player, 255, 255, 255 )
		end
	end,
	true
)

addCommandHandler( { "setvehiclecolor", "setcolor" },
	function( player, commandName, other, color1, color2 )
		local color1 = tonumber( color1 )
		local color2 = tonumber( color2 ) or color1
		if other and color1 and color2 and color1 >= 0 and color1 <= 255 and color2 >= 0 and color2 <= 255 then
			local other, name = exports.players:getFromName( player, other )
			if other then
				local vehicle = getPedOccupiedVehicle( other )
				if vehicle then
					local data = vehicles[ vehicle ]
					if data then
						if data.vehicleID < 0 or exports.sql:query_free( "UPDATE vehicles SET color1 = " .. color1 .. ", color2 = " .. color2 .. " WHERE vehicleID = " .. data.vehicleID ) then
							setVehicleColor( vehicle, color1, color2, color1, color2 )
							outputChatBox( "Cambio el color del vehiculo de " .. name .. ", " .. getVehicleName( vehicle ) .. ".", player, 0, 255, 153 )
						else
							outputChatBox( "Error MySQL.", player, 255, 0, 0 )
						end
					else
						outputChatBox( "Error del vehiculo.", player, 255, 0, 0 )
					end
				else
					outputChatBox( name .. " no esta conduciendo ningun vehiculo.", player, 255, 0, 0 )
				end
			end
		else
			outputChatBox( "Syntax: /" .. commandName .. " [jugador] [color 1] [color 2]", player, 255, 255, 255 )
		end
	end,
	true
)

addCommandHandler( "setvehiclefaction",
	function( player, commandName, other, faction )
		local faction = tonumber( faction )
		if other and faction and ( faction == 0 or exports.factions:getFactionName( faction ) ) then
			local other, name = exports.players:getFromName( player, other )
			if other then
				local vehicle = getPedOccupiedVehicle( other )
				if vehicle then
					local data = vehicles[ vehicle ]
					if data then
						if data.vehicleID > 0 then
							if data.characterID <= 0 then
								if exports.sql:query_free( "UPDATE vehicles SET characterID = " .. -faction .. " WHERE vehicleID = " .. data.vehicleID ) then
									data.characterID = -faction
									outputChatBox( name .. " " .. getVehicleName( vehicle ) .. " ahora pertenece a " .. ( faction == 0 and "Sin Faccion" or exports.factions:getFactionName( faction ) ) .. ".", player, 0, 255, 153 )
								else
									outputChatBox( "Error MySQL.", player, 255, 0, 0 )
								end
							else
								outputChatBox( "Este no es un vehiculo civil/faccion.", player, 255, 0, 0 )
							end
						end
					else
						outputChatBox( "Error del vehiculo.", player, 255, 0, 0 )
					end
				else
					outputChatBox( name .. " no esta conduciendo ningun vehiculo.", player, 255, 0, 0 )
				end
			end
		else
			outputChatBox( "Syntax: /" .. commandName .. " [jugador] [faccion o 0 para ninguna faccion]", player, 255, 255, 255 )
		end
	end,
	true
)

--

function saveVehicle( vehicle )
	if vehicle then
		local data = vehicles[ vehicle ]
		if data and data.vehicleID > 0 then
			local x, y, z = getElementPosition( vehicle )
			local rx, ry, rz = getVehicleRotation( vehicle )
			local success, error = exports.sql:query_free( "UPDATE vehicles SET posX = " .. x .. ", posY = " .. y .. ", posZ = " .. z .. ", rotX = " .. rx .. ", rotY = " .. ry .. ", rotZ = " .. rz .. ", health = " .. math.min( 1000, math.ceil( getElementHealth( vehicle ) ) ) .. ", interior = " .. getElementInterior( vehicle ) .. ", dimension = " .. getElementDimension( vehicle ) .. ", fuel = " .. data.fuel .. " WHERE vehicleID = " .. data.vehicleID )			
			if error then
				outputDebugString( error )
			end
		end
	end
end

addEventHandler( "onVehicleExit", root,
	function( player )
		saveVehicle( source )
		
		if hasTintedWindows( source ) then
			exports.players:updateNametag( player )
		end
	end
)

setTimer(
	function( )
		-- save all vehicles
		for vehicle in pairs( vehicles ) do
			saveVehicle( vehicle )
		end
	end,
	60000,
	0
)

addEventHandler( "onResourceStop", resourceRoot,
	function( )
		-- save all occupied vehicles on resource start
		local occupiedVehicles = { }
		for _, value in ipairs( getElementsByType( "player" ) ) do
			local vehicle = getPedOccupiedVehicle( value )
			if vehicle then
				occupiedVehicles[ vehicle ] = true
			end
		end
		
		for vehicle in pairs( occupiedVehicles ) do
			saveVehicle( vehicle )
		end
		
		-- we won't have any vehicles left, but show no message in onElementDestroy
		vehicles = { }
		vehicleIDs = { }
	end
)

addEventHandler( "onVehicleRespawn", resourceRoot,
	function( )
		local data = vehicles[ source ]
		if data and data.vehicleID > 0 then
			setElementInterior( source, data.respawnInterior )
			setElementDimension( source, data.respawnDimension )
			saveVehicle( source )
		end
	end
)

addEventHandler( "onPlayerJoin", root,
	function( )
		bindKey( source, "k", "down", "lockvehicle" )
		bindKey( source, "j", "down", "toggleengine" )
		bindKey( source, "l", "down", "togglelights" )
	end
)

addEventHandler( "onPlayerQuit", root,
	function( )
		local vehicle = getPedOccupiedVehicle( source )
		if vehicle then
			saveVehicle( vehicle )
		end
		
		p[ source ] = nil
	end
)

addEventHandler( "onElementDestroy", resourceRoot,
	function( )
		if vehicles[ source ] then
			outputDebugString( "Borrado el vehiculo con la ID " .. vehicles[ source ].vehicleID .. " (" .. getVehicleName( source ) .. "), aunque todavía se hace referencia. Eliminando referencias...", 2 )
			vehicleIDs[ vehicles[ source ].vehicleID ] = nil
			vehicles[ source ] = nil
		end
	end
)

addEventHandler( "onVehicleStartEnter", resourceRoot,
	function( player )
		if isVehicleLocked( source ) and vehiclesIgnoringLocked[ getElementModel( source ) ] then
			cancelEvent( )
			outputChatBox( "(( Este " .. getVehicleName( source ) .. " esta cerrado. ))", player, 255, 0, 0 )
		end
	end
)

addEventHandler( "onVehicleEnter", resourceRoot,
	function( player )
		if isVehicleLocked( source ) then
			cancelEvent( )
			removePedFromVehicle( player )
			outputChatBox( "(( Este " .. getVehicleName( source ) .. " esta cerrado. ))", player, 255, 0, 0 )
		else
			local data = vehicles[ source ]
			if data then
				if data.characterID > 0 then
					local name = exports.players:getCharacterName( data.characterID )
					if name then
						outputChatBox( "(( Este " .. getVehicleName( source ) .. " pertenece a " .. name .. ". ))", player, 255, 204, 0 )
					else
						outputDebugString( "Vehiculo " .. data.vehicleID .. " (" .. getVehicleName( source ) .. ") tiene un dueño no valido.", 2 )
					end
				elseif data.characterID < 0 then
					outputChatBox( "(( Este " .. getVehicleName( source ) .. " pertenece a " .. tostring( exports.factions:getFactionName( -data.characterID ) ) .. ". ))", player, 255, 204, 0 )
				end
				
				if not p[ player ] then
					p[ player ] = { }
				end
				p[ player ].vehicle = source
				
				setVehicleEngineState( source, not doesVehicleHaveEngine( source ) or data.engineState )
				
				if hasTintedWindows( source ) then
					exports.players:updateNametag( player )
				end
			end
		end
	end
)

addEventHandler( "onVehicleStartExit", resourceRoot,
	function( player )
		if isVehicleLocked( source ) then
			cancelEvent( )
			outputChatBox( "(( Las puertas del vehiculo estan cerradas. ))", player, 255, 0, 0 )
		else
			p[ player ].oldVehicle = p[ player ].vehicle
			p[ player ].vehicle = nil
		end
	end
)

addEventHandler( "onVehicleExit", resourceRoot,
	function( player )
		if p[ source ] then
			p[ source ].vehicle = nil
		end
	end
)

addEventHandler( "onPlayerWasted", root,
	function( )
		if p[ source ] then
			p[ source ].vehicle = nil
		end
	end
)

--

local function lockVehicle( player, vehicle, driver )
	local vehicleID = vehicles[ vehicle ] and vehicles[ vehicle ].vehicleID
	if vehicleID and ( vehicleID < 0 or exports.sql:query_free( "UPDATE vehicles SET locked = 1 - locked WHERE vehicleID = " .. vehicleID ) ) then
		if driver then
			exports.chat:me( player, ( isVehicleLocked( vehicle ) and "abre" or "cierra" ) .. "las puertas del vehiculo." )
		else
			exports.chat:me( player, "presiona la tecla para " .. ( isVehicleLocked( vehicle ) and "abrir" or "cerrar" ) .. "las puertas del " .. getVehicleName( vehicle ) .. "." )
		end
		setVehicleLocked( vehicle, not isVehicleLocked( vehicle ) )
		return true
	end
	return false
end

addCommandHandler( "lockvehicle",
	function( player, commandName )
		if exports.players:isLoggedIn( player ) then
			if getElementData( player, "interiorMarker" ) then
				return
			end
			
			if isPedEnteringVehicle( player ) then
				return
			end
			
			local vehicle = getPedOccupiedVehicle( player )
			local vehicleID = vehicle and vehicles[ vehicle ] and vehicles[ vehicle ].vehicleID
			if vehicleID then
				local driver = getVehicleOccupant( vehicle ) == player
				if driver or exports.items:has( player, 1, vehicleID ) or driver then
					lockVehicle( player, vehicle, driver )
				end
			else
				local dimension = getElementDimension( player )
				local minDistance = 20
				local vehicle = nil
				local x, y, z = getElementPosition( player )
				for key, value in pairs( vehicles ) do
					if dimension == getElementDimension( key ) then
						local distance = getDistanceBetweenPoints3D( x, y, z, getElementPosition( key ) )
						if distance < minDistance then
							if exports.items:has( player, 1, value.vehicleID ) or ( value.characterID < 0 and exports.factions:isPlayerInFaction( player, -value.characterID ) ) then
								minDistance = distance
								vehicle = key
							end
						end
					end
				end
				
				if vehicle then
					lockVehicle( player, vehicle )
				end
			end
		end
	end
)

addCommandHandler( "toggleengine",
	function( player, commandName )
		if exports.players:isLoggedIn( player ) then
			local vehicle = getPedOccupiedVehicle( player )
			if vehicle and getVehicleOccupant( vehicle ) == player and doesVehicleHaveEngine( vehicle ) then
				local data = vehicles[ vehicle ]
				if data then
					if data.vehicleID < 0 or exports.sql:query_free( "UPDATE vehicles SET engineState = 1 - engineState WHERE vehicleID = " .. data.vehicleID ) then
						if math.floor( getElementHealth( vehicle ) + 0.5 ) > 301 then
							setVehicleEngineState( vehicle, not data.engineState )
							data.engineState = not data.engineState
						else
							outputChatBox( "(( El motor de este vehiculo esta roto. ))", player, 255, 0, 0 )
						end
					end
				end
			end
		end
	end
)

addCommandHandler( "togglelights",
	function( player, commandName )
		if exports.players:isLoggedIn( player ) then
			local vehicle = getPedOccupiedVehicle( player )
			if vehicle and getVehicleOccupant( vehicle ) == player then
				local data = vehicles[ vehicle ]
				if data then
					if data.vehicleID < 0 or exports.sql:query_free( "UPDATE vehicles SET lightsState = 1 - lightsState WHERE vehicleID = " .. data.vehicleID ) then
						setVehicleOverrideLights( vehicle, getVehicleOverrideLights( vehicle ) == 2 and 1 or 2 )
					end
				end
			end
		end
	end
)

function getVehicle( vehicleID )
	return vehicleIDs[ vehicleID ] or false
end

function getOwner( vehicle )
	if vehicles[ vehicle ] then
		local owner = vehicles[ vehicle ].characterID
		return owner ~= 0 and owner or false -- false is in that case civilian
	end
end

function hasTintedWindows( vehicle )
	return vehicles[ vehicle ] and vehicles[ vehicle ].tintedWindows or false
end

function toggleLock( player, vehicle )
	return getElementType( player ) == "player" and isElement( vehicle ) and lockVehicle( player, vehicle, false ) or false
end

--
local tempIDCounter = 0
addCommandHandler( { "temporaryvehicle", "tempvehicle", "vehicle" },
	function( player, commandName, ... )
		model = table.concat( { ... }, " " )
		model = getVehicleModelFromName( model ) or tonumber( model )
		if model then
			local x, y, z, rz = getPositionInFrontOf( player )
			
			local vehicle = createVehicle( model, x, y, z, 0, 0, rz )
			if vehicle then
				tempIDCounter = tempIDCounter - 1
				local vehicleID = tempIDCounter
				
				-- tables for ID -> vehicle and vehicle -> data
				vehicleIDs[ vehicleID ] = vehicle
				vehicles[ vehicle ] = { vehicleID = vehicleID, characterID = 0, engineState = true, tintedWindows = false, fuel = 100 }
				
				-- some properties
				setElementInterior( vehicle, getElementInterior( player ) )
				setElementDimension( vehicle, getElementDimension( player ) )
				setVehicleEngineState( vehicle, true )
				setVehicleOverrideLights( vehicle, 1 )
				setElementData( vehicle, "fuel", 100 )
				
				-- success message
				outputChatBox( "Vehiculo temporal creado:" .. getVehicleName( vehicle ) .. " (ID " .. vehicleID .. ")", player, 0, 255, 0 )
			else
				outputChatBox( "Modelo del vehiculo invalido.", player, 255, 0, 0 )
			end
		else
			outputChatBox( "Syntax: /" .. commandName .. " [model]", player, 255, 255, 255 )
		end
	end,
	true
)

--

function increaseFuel( vehicle, amount )
	local data = vehicles[ vehicle ]
	if data and doesVehicleHaveFuel( vehicle ) then
		if data.fuel + amount <= 100 then
			data.fuel = data.fuel + amount
			setElementData( vehicle, "fuel", math.floor( data.fuel + 0.5 ) )
		end
	end
end

--

addEventHandler( "onVehicleDamage", root,
	function( loss )
		if getElementHealth( source ) <= 301 then
			setElementHealth( source, 300 )
			setVehicleDamageProof( source, true )
			setVehicleEngineState( source, false )
			vehicles[ source ].engineState = false
			
			if getVehicleOccupant( source ) then
				outputChatBox( "(( Tu motor se averió. ))", getVehicleOccupant( source ), 255, 204, 0 )
			end
		end
	end
)

addEventHandler( "onVehicleRespawn", root,
	function( )
		setVehicleDamageProof( source, false )
	end
)

addEventHandler( "onVehicleEnter", root,
	function( )
		if isVehicleDamageProof( source ) and math.floor( getElementHealth( source ) + 0.5 ) > 301 then
			setVehicleDamageProof( source, false )
		end
	end
)
