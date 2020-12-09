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

local data = { }

local function notify( element, to )
	-- is loaded
	if data[ element ] then
		-- support for both single and multiple users
		if to then
			to = { [ to ] = true }
		else
			to = data[ element ].subscribers
		end
		
		-- easier
		local items = data[ element ].items
		
		-- send it to every reciever
		for value in pairs( to ) do
			triggerClientEvent( value, "syncItems", value, items )
		end
	else
		-- not loaded, send no items
		triggerClientEvent( to, "syncItems", to )
	end
end

local function getID( element )
	if getElementType( element ) == "player" then
		return exports.players:getCharacterID( element )
	end
end

local function load( element, force )
	if isElement( element ) then
		local elementID = getID( element )
		if elementID then
			if force or not data[ element ] or data[ element ].id ~= elementID then
				-- initalize a table for it
				data[ element ] = {
					['items'] = { },
					['subscribers'] = { },
					id = elementID
				}
				
				-- load items
				local i = exports.sql:query_assoc( "SELECT `index`, item, value, name FROM items WHERE owner = " .. elementID .. " ORDER BY `index` ASC" )
				for key, value in ipairs( i ) do
					table.insert( data[ element ].items, value )
				end
				
				-- player should get notified of his items
				if getElementType( element ) == "player" then
					data[ element ].subscribers[ element ] = true
					notify( element, element )
				end
				
				return true
			end
			return true
		end
		return false, "Este elemento no tiene id unica."
	end
	return false, tostring( element ) .. " no es un elemento."
end

local function subscribe( element, to )
	-- Make sure we have an element to subscribe to
	if load( to ) then
		-- subscribe to the element
		data[ to ].subscribers[ element ] = true
		return true
	end
	return false, "No es posible cargar este elemento."
end

function get( element )
	if load( element ) then
		return data[ element ].items
	end
end

function give( element, item, value, name )
	-- we need a base to work on
	if load( element ) then
		-- we need at least item and value
		if type( item ) == 'number' and ( type( value ) == "number" or type( value ) == "string" ) then
			-- name can be optional, though if it's not, we need to escape it
			name2 = "NULL"
			if name then
				name2 = "'" .. exports.sql:escape_string( tostring( name ) ) .. "'"
			else
				name = nil
			end
			
			-- we need to know our item index
			local index, error = exports.sql:query_insertid( "INSERT INTO items (owner, item, value, name) VALUES (" .. getID( element ) .. ", " .. item .. ", '%s', " .. name2 .. ")", value )
			if index then
				-- add at the last position as a new item
				table.insert( data[ element ].items, { index = index, item = item, value = value, name = name } )
				
				-- tell everyone who wants to know
				notify( element )
				
				return true
			end
			return false, "Error MySQL."
		end
		return false, "Parametros invalidos."
	end
	return false, "No es posible cargar este elemento."
end

function take( element, slot )
	-- we need a base to work on
	if load( element ) then
		-- check for existance of the slot
		if data[ element ].items[ slot ] then
			-- only continue if we could delete it
			local success, error = exports.sql:query_free( "DELETE FROM items WHERE `index` = " .. data[ element ].items[ slot ].index )
			if success then
				-- remove it from the table, shift following items to pos=pos-1
				table.remove( data[ element ].items, slot )
				
				-- tell everyone who wants to know
				notify( element )
				
				-- we managed it
				return true
			end
			return false, "Error MySQL."
		end
		return false, "No existe ese slot."
	end
	return false, "No es posible cargar este elemento."
end

function has( element, item, value, name )
	-- we need a base to work on
	if load( element ) then
		-- at least the item is needed
		if type( item ) == 'number' then
			-- check if he has it
			for key, v in ipairs( data[ element ].items ) do
				if v.item == item and ( not value or v.value == value ) and ( not name or v.name == name ) then
					return true, key, v
				end
			end
			return false -- nope, no error either
		end
		return false, "Parametros invalidos."
	end
	return false, "No es posible cargar este elemento."
end

local function unload( element )
	-- clear old references
	if data[ element ] then
		-- don't have any items
		data[ element ].items = nil
		
		-- tell everyone who cares
		notify( element )
		
		-- delete
		data[ element ] = nil
		return true
	end
	return false, "Este elemento no tiene items cargados"
end

local function unsubscribe( element, from )
	if from then
		-- we need to have an actual item to unsubscribe from
		if load( from ) then
			-- remove our reference
			data[ from ].subscribers[ element ] = nil
		end
		return true
	else
		-- look through all saved items
		for key, value in pairs( data ) do
			-- remove subscriber reference if exists
			if value.subscribers[ element ] then
				value.subscribers[ element ] = nil
			end
		end
	end
end

addEventHandler( "onElementDestroy", root,
	function( )
		unload( source )
	end
)

addEventHandler( "onPlayerQuit", root,
	function( )
		unload( source )
		unsubscribe( source )
	end
)

addEventHandler( "onCharacterLogin", root,
	function( )
		load( source, true )
	end
)

addEventHandler( "onCharacterLogout", root,
	function( )
		unload( source )
		unsubscribe( source )
	end
)

addEvent( "loadItems", true )
addEventHandler( "loadItems", root,
	function( )
		if source == client then
			if exports.players:isLoggedIn( source ) then
				load( source, true )
			end
		end
	end
)

addEventHandler( "onResourceStart", resourceRoot,
	function( )
		if not exports.sql:create_table( 'items',
			{
				{ name = 'index', type = 'int(10) unsigned', primary_key = true, auto_increment = true },
				{ name = 'owner', type = 'int(10) unsigned' },
				{ name = 'item', type = 'int(10) unsigned' },
				{ name = 'value', type = 'text' },
				{ name = 'name', type = 'text', null = true },
			} ) then cancelEvent( ) return end
	end
)

--

addEvent( "items:use", true )
addEventHandler( "items:use", root,
	function( slot )
		if source == client then
			if exports.players:isLoggedIn( source ) then
				local item = get( source )[ slot ]
				if item then
					local id = item.item
					local value = item.value
					local name = item.name or getName( id )
					
					if id == 1 then -- vehicle key
						local vehicle = exports.vehicles:getVehicle( value )
						if vehicle then
							local x, y, z = getElementPosition( source )
							if getElementDimension( source ) == getElementDimension( vehicle ) and getDistanceBetweenPoints3D( x, y, z, getElementPosition( vehicle ) ) < 20 then
								exports.vehicles:toggleLock( source, vehicle )
							else
								outputChatBox( "(( Este vehiculo esta demasiado lejos. ))", source, 255, 0, 0 )
							end
						else
							outputChatBox( "(( Este vehiculo no existe. ))", source, 255, 0, 0 )
						end
					elseif id == 2 then -- house key
						local interior = exports.interiors:getInterior( value )
						if interior then
							local dimension = getElementDimension( source )
							local x, y, z = getElementPosition( source )
							-- close to the interior or exterior?
							if dimension == getElementDimension( interior.inside ) and getDistanceBetweenPoints3D( x, y, z, getElementPosition( interior.inside ) ) < 5 then
								exports.interiors:toggleLock( source, interior.inside )
							elseif dimension == getElementDimension( interior.outside ) and getDistanceBetweenPoints3D( x, y, z, getElementPosition( interior.outside ) ) < 5 then
								exports.interiors:toggleLock( source, interior.outside )
							else
								outputChatBox( "(( Estas muy lejos de este interior. ))", source, 255, 0, 0 )
							end
						else
							outputChatBox( "(( Este interior no existe. ))", source, 255, 0, 0 )
						end
					elseif id == 3 then
						take( source, slot )
						if type( value ) == "number" and value > 0 then -- we will only give health, not take it.
							setElementHealth( source, math.max( 100, getElementHealth( source ) + value ) )
						end
						exports.chat:me( source, "come " .. name .. "." )
					elseif id == 4 then
						take( source, slot )
						if type( value ) == "number" and value > 0 then -- we will only give health, not take it.
							setElementHealth( source, math.max( 100, getElementHealth( source ) + value ) )
						end
						exports.chat:me( source, "bebe " .. name .. "." )
					elseif id == 5 then
						if type( value ) == "number" and exports.players:isValidSkin( value ) then
							local new = exports.players:getSkinDetails( value )
							local current = exports.players:getSkinDetails( getElementModel( source ) )
							if current.gender == new.gender and current.color == new.color then
								if setElementModel( source, value ) then
									exports.chat:me( source, "cambia su ropa." )
								else
									outputChatBox( "(( Tu ya llevas esta ropa. ))", source, 255, 0, 0 )
								end
							else
								outputChatBox( "(( Esta ropa no te queda. ))", source, 255, 0, 0 )
							end
						end
					elseif id == 7 then
						outputChatBox( "Este telefono tiene el numero #" .. tostring( value ) .. ".", source, 255, 255, 255 )
					elseif id == 8 then
						if exports.players:isValidLanguage( value ) then
							local learned, error = exports.players:learnLanguage( source, value )
							if learned then
								take( source, slot )
								outputChatBox( "Aprendiste lo basico de " .. exports.players:getLanguageName( value ) .. ".", source, 0, 255, 0 )
							elseif error == 1 then
								outputChatBox( "Codigo de lenguaje incorrecto - " .. value .. ".", source, 255, 0, 0 )
							elseif error == 2 then
								outputChatBox( "Tu ya hablas " .. exports.players:getLanguageName( value ) .. ".", source, 255, 0, 0 )
							elseif error == 3 then
								outputChatBox( "No puedes aprender mas lenguajes.", source, 255, 0, 0 )
							else
								outputChatBox( "Error MySQL.", source, 255, 0, 0 )
							end
						else
							outputChatBox( "Codigo de lenguaje incorrecto - " .. value .. ".", source, 255, 0, 0 )
						end
					else
						-- the original idea was to have the items run ("The wild Vehicle key ran away.") away yet I could convince myself players would like it that much
						exports.chat:me( source, "mira hacia el " .. name .. ". No sucede nada..." )
					end
				end
			end
		end
	end
)

addEvent( "items:destroy", true )
addEventHandler( "items:destroy", root,
	function( slot )
		if source == client then
			if exports.players:isLoggedIn( source ) then
				local item = get( source )[ slot ]
				if item then
					local id = item.item
					local value = item.value
					local name = item.name or getName( id )
					
					take( source, slot )
					exports.chat:me( source, "Elimino un " .. name .. "." )
				end
			end
		end
	end
)

--

addCommandHandler( "giveitem",
	function( player, commandName, other, id, ... )
		local id = tonumber( id )
		if other and id and ( ... ) then
			local other, pname = exports.players:getFromName( player, other )
			if other then
				-- check if it's a valid item id
				if id >= 0 and id <= #item_list then
					-- we need to split our name and value apart
					local arguments = { ... }
					local value = { }
					local name
					for k, v in ipairs( arguments ) do
						if not name then
							if v == "--" then
								name = { }
							else
								table.insert( value, v )
							end
						else
							table.insert( name, v )
						end
					end
					
					-- get nicer values
					value = table.concat( value, " " )
					value = tonumber( value ) or value
					if name then
						name = table.concat( name, " " )
						if #name == 0 then
							name = nil
						end
					end
					
					-- phone workaround: we need at this point make sure we have a unique phone with a non-arbitrary number
					if id == 7 then
						if type( value ) == "number" then
							if value <= 0 then
								-- make it easy, just create a new phone
								value = createPhone( )
							else
								value = createPhone( value )
								if not value then
									outputChatBox( "Error al dar el telefono.", player, 255, 0, 0 )
									return
								end
							end
						else
							outputChatBox( "Error al dar el telefono -- invalido .", player, 255, 0, 0 )
							return
						end
					end
					
					-- give the item
					if give( other, id, value, name ) then
						outputChatBox( "Entregaste el item " .. pname .. " " .. id .. " con valor=" .. value .. ( name and ( " (nombre = " .. name .. ")" ) or "" ) .. ".", player, 0, 255, 153 )
					else
						outputChatBox( "Error al entregar el item.", player, 255, 0, 0 )
					end
				else
					outputChatBox( "Item invalido.", player, 255, 0, 0 )
				end
			end
		else
			outputChatBox( "Syntax: /" .. commandName .. " [player] [id] [cantidad]", player, 255, 255, 255 )
			outputChatBox( "       or /" .. commandName .. " [player] [id] [cantidad] -- [descripcion]", player, 255, 255, 255 )
		end
	end,
	true
)
