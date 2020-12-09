--[[
Copyright (c) 2010 MTA: Paradise

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

local vehicles = get( "vehicles" ) or { "Taxi" } -- load the civilian vehicles that'll automatically trigger the delivery mission if being entered
local max_earnings = tonumber( get( "earnings" ) ) or 7
local delay = tonumber( get( "delay" ) ) or 5

-- put it in a for us better format
local vehicles2 = { }
for key, value in ipairs( vehicles ) do
	local model = getVehicleModelFromName( value )
	if model then
		vehicles2[ model ] = true
	else
		outputDebugString( "Vehiculo '" .. tostring( value ) .. " No Existe." )
	end
end
vehicles = vehicles2
vehicles2 = nil

local function isJobVehicle( vehicle )
	return vehicle and vehicles[ getElementModel( vehicle ) ] and not exports.vehicles:getOwner( vehicle ) or false
end

--

local function hasPassengers( vehicle, ignoreSeat )
	if vehicle then
		for i = 1, getVehicleMaxPassengers( vehicle ) do
			if i ~= ignoreSeat and getVehicleOccupant( vehicle, i ) then
				return true
			end
		end
	end
	return false
end

addEventHandler( "onVehicleEnter", root,
	function( player, seat )
		if isJobVehicle( source ) then
			if seat == 0 then
				if not hasPassengers( source ) then
					outputChatBox( "(( Espere hasta que alguien llame a un taxi a través de /call taxi. ))", player, 255, 204, 0 )
					if not isVehicleTaxiLightOn( source ) then
						setVehicleTaxiLightOn( source, true )
					end
				end
			else
				-- passenger
				if isVehicleTaxiLightOn( source ) then
					setVehicleTaxiLightOn( source, false )
				end
			end
			triggerClientEvent( player, getResourceName( resource ) .. ":show", source )
		end
	end
)

addEventHandler( "onVehicleExit", root,
	function( player, seat )
		if isJobVehicle( source ) then
			if seat == 0 then
				if isVehicleTaxiLightOn( source ) then
					setVehicleTaxiLightOn( source, false )
				end
			else
				-- passenger
				if getVehicleOccupant( source ) and not hasPassengers( source, seat ) then
					setVehicleTaxiLightOn( source, true )
				end
			end
			triggerClientEvent( player, getResourceName( resource ) .. ":hide", source )
		end
	end
)

addEvent( getResourceName( resource ) .. ":ready", true )
addEventHandler( getResourceName( resource ) .. ":ready", root,
	function( )
		if source == client then
			if isJobVehicle( getPedOccupiedVehicle( source ) ) then
				if getPedOccupiedVehicleSeat( source ) == 0 then
					if not hasPassengers( getPedOccupiedVehicle( source ) ) then
						outputChatBox( "(( Espere hasta que alguien llame a un taxi a través de / call taxi. ))", source, 255, 204, 0 )
						setVehicleTaxiLightOn( getPedOccupiedVehicle( source ), true )
					else
						-- continue the fare
					end
				else
					-- passenger
				end
				triggerClientEvent( source, getResourceName( resource ) .. ":show", getPedOccupiedVehicle( source ) )
			end
		end
	end
)

--

function getDrivers( )
	local t = { }
	for key, value in ipairs( getElementsByType( "player" ) ) do
		if isJobVehicle( getPedOccupiedVehicle( value ) ) then
			if getPedOccupiedVehicleSeat( value ) == 0 then
				table.insert( t, value )
			end
		end
	end
	return t
end

--

addEvent( getResourceName( resource ) .. ":toggleLights", true )
addEventHandler( getResourceName( resource ) .. ":toggleLights", root,
	function( )
		if source == getPedOccupiedVehicle( client ) and getVehicleOccupant( source ) == client then
			setVehicleTaxiLightOn( source, not isVehicleTaxiLightOn( source ) )
		end
	end
)

--

addCommandHandler( "taximeter",
	function( player, commandName )
		local vehicle = getPedOccupiedVehicle( player )
		if vehicle and getVehicleOccupant( vehicle ) == player then
			setElementData( vehicle, "taxi:distance", type( getElementData( vehicle, "taxi:distance" ) ) ~= "number" and 0 or false )
		end
	end
)

addCommandHandler( "resettaxi",
	function( player, commandName )
		local vehicle = getPedOccupiedVehicle( player )
		if vehicle and getVehicleOccupant( vehicle ) == player then
			setElementData( vehicle, "taxi:distance", type( getElementData( vehicle, "taxi:distance" ) ) == "number" and 0 or false )
		end
	end
)

addEvent( getResourceName( resource ) .. ":update", true )
addEventHandler( getResourceName( resource ) .. ":update", root,
	function( distance )
		if source == getPedOccupiedVehicle( client ) and getVehicleOccupant( source ) == client and getElementData( source, "taxi:distance" ) and type( distance ) == "number" and distance > 0.001 and distance < 40 then
			setElementData( source, "taxi:distance", getElementData( source, "taxi:distance" ) + distance )
		end
	end
)

--

addEventHandler( "onVehicleStartEnter", root,
	function( player, seat )
		if seat == 0 and isJobVehicle( source ) and "job-" .. tostring( exports.players:getJob( player ) ) ~= getResourceName( resource ) then
			outputChatBox( "(( Este Trabajo lo puedes tomar en el Ayuntamiento. ))", player, 255, 0, 0 )
			cancelEvent( )
		end
	end
)

--

function introduce( player )
	triggerClientEvent( player, getResourceName( resource ) .. ":introduce", player )
end
