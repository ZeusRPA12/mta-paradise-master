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

local maxAccountsPerCharacter = get( 'max_accounts_per_character' ) or 3

--

local p = { }
local banks = { }
local blips = { }

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
end

--

local function loadBank( id, x, y, z, rotation, interior, dimension, skin )
	local bank = nil
	if skin == -1 then
		bank = createObject( 2942, x, y, z, 0, 0, rotation )
	else
		bank = createPed( skin, x, y, z )
		setPedRotation( bank, rotation )
		setPedFrozen( bank, true )
		
		if dimension > 0 and not blips[ dimension ] then
			if getResourceState( getResourceFromName( "interiors" ) ) == "running" then
				local int = exports.interiors:getInterior( dimension )
				if int then
					if getElementDimension( int.outside ) == 0 then
						local x, y, z = getElementPosition( int.outside )
						blips[ dimension ] = createBlip( x, y, z, 52, 2, 255, 255, 255, 255, 0, 50 )
					end
				end
			end
		end
	end
	
	setElementInterior( bank, interior )
	setElementDimension( bank, dimension )
	
	banks[ id ] = { bank = bank, canDeposit = skin ~= -1, withdrawFee = skin == -1 and 2 or 0 }
	banks[ bank ] = id
end

addEventHandler( "onPedWasted", resourceRoot,
	function( )
		local bankID = banks[ source ]
		if bankID then
			bank = createPed( skin, getElementPosition( source ) )
			setPedRotation( bank, getPedRotation( source ) )
			setPedFrozen( bank, true )
			
			setElementInterior( bank, getElementInterior( source ) )
			setElementDimension( bank, getElementDimension( source ) )
			
			banks[ bank ] = bankID
			banks[ bankID ].bank = bank
			
			banks[ source ] = nil
			destroyElement( source )
		end
	end
)

--

addEventHandler( "onResourceStart", resourceRoot,
	function( )
		if not exports.sql:create_table( 'banks',
			{
				{ name = 'bankID', type = 'int(10) unsigned', primary_key = true, auto_increment = true },
				{ name = 'x', type = 'float' },
				{ name = 'y', type = 'float' },
				{ name = 'z', type = 'float' },
				{ name = 'rotation', type = 'float' },
				{ name = 'interior', type = 'tinyint(3) unsigned' },
				{ name = 'dimension', type = 'int(10) unsigned' },
				{ name = 'skin', type = 'int(10)', default = -1 },
			} ) then cancelEvent( ) return end
		
		if not exports.sql:create_table( 'bank_accounts',
			{
				{ name = 'accountID', type = 'int(10) unsigned', primary_key = true, auto_increment = 400000 },
				{ name = 'characterID', type = 'int(10) unsigned' },
				{ name = 'balance', type = 'bigint(20) unsigned', default = 0 },
			} ) then cancelEvent( ) return end
		
		if not exports.sql:create_table( 'bank_cards',
			{
				{ name = 'cardID', type = 'int(10) unsigned', primary_key = true, auto_increment = 200000 },
				{ name = 'bankAccountID', type = 'int(10) unsigned' },
				{ name = 'pin', type = 'int(10) unsigned' },
			} ) then cancelEvent( ) return end
		
		--
		
		local result = exports.sql:query_assoc( "SELECT * FROM banks ORDER BY bankID ASC" )
		if result then
			for key, value in ipairs( result ) do
				loadBank( value.bankID, value.x, value.y, value.z, value.rotation, value.interior, value.dimension, value.skin )
			end
		end
	end
)

--

addCommandHandler( "createatm",
	function( player )
		local x, y, z = getElementPosition( player )
		z = z - 0.35
		local rotation = ( getPedRotation( player ) + 180 ) % 360
		local interior = getElementInterior( player )
		local dimension = getElementDimension( player )
		
		local bankID = exports.sql:query_insertid( "INSERT INTO banks (x, y, z, rotation, interior, dimension) VALUES (" .. table.concat( { x, y, z, rotation, interior, dimension }, ", " ) .. ")" )
		if bankID then
			loadBank( bankID, x, y, z, rotation, interior, dimension, -1 )
			setElementPosition( player, x, y, z + 1 )
			
			outputChatBox( "Creaste el cajero (ID " .. bankID .. ").", player, 0, 255, 153 )
		else
			outputChatBox( "Error MySQL.", player, 255, 0, 0 )
		end
	end,
	true
)

addCommandHandler( "createbank",
	function( player )
		local x, y, z = getElementPosition( player )
		local rotation = getPedRotation( player )
		local interior = getElementInterior( player )
		local dimension = getElementDimension( player )
		
		local bankID = exports.sql:query_insertid( "INSERT INTO banks (x, y, z, rotation, interior, dimension, skin) VALUES (" .. table.concat( { x, y, z, rotation, interior, dimension, 211 }, ", " ) .. ")" )
		if bankID then
			loadBank( bankID, x, y, z, rotation, interior, dimension, 211 )
			setElementPosition( player, x + 0.3, y, z )
			
			outputChatBox( "Creaste el banco (ID " .. bankID .. ").", player, 0, 255, 153 )
		else
			outputChatBox( "Error MySQL.", player, 255, 0, 0 )
		end
	end,
	true
)

addCommandHandler( { "nearbyatms", "nearbybanks" },
	function( player, commandName )
		if hasObjectPermissionTo( player, "command.createbank", false ) or hasObjectPermissionTo( player, "command.createatm", false ) then
			local x, y, z = getElementPosition( player )
			local dimension = getElementDimension( player )
			local interior = getElementInterior( player )
			
			outputChatBox( "Bancos/Cajeros Cercanos:", player, 255, 255, 0 )
			for key, value in pairs( banks ) do
				if isElement( key ) and getElementDimension( key ) == dimension and getElementInterior( key ) == interior then
					local distance = getDistanceBetweenPoints3D( x, y, z, getElementPosition( key ) )
					if distance < 5 then
						outputChatBox( "  " .. ( getElementType( key ) == "ped" and "Banco" or "Cajero" ) .. " " .. value .. ".", player, 255, 255, 0 )
					end
				end
			end
		end
	end
)

addCommandHandler( { "deletebank", "delbank" },
	function( player, commandName, bankID )
		bankID = tonumber( bankID )
		if bankID then
			local bank = banks[ bankID ]
			if bank then
				if getElementType( bank.bank ) == "ped" then
					if exports.sql:query_free( "DELETE FROM banks WHERE bankID = " .. bankID ) then
						outputChatBox( "Borraste el banco (ID " .. bankID .. ").", player, 0, 255, 153 )
						
						local dimension = getElementDimension( bank.bank )
						
						destroyElement( bank.bank )
						banks[ bankID ] = nil
						banks[ bank.bank ] = nil
						
						-- check for other banks in that dimension and destroy a blip if neccessary
						local found = false
						if blips[ dimension ] then
							for key, value in pairs( banks ) do
								if isElement( key ) and getElementType( key ) == "ped" and getElementDimension( key ) == dimension then
									found = true
									break
								end
							end
						end
						
						if not found then
							destroyElement( blips[ dimension ] )
							blips[ dimension ] = nil
						end
					else
						outputChatBox( "Error MySQL.", player, 255, 0, 0 )
					end
				else
					outputChatBox( "Banco no encontrado.", player, 255, 0, 0 )
				end
			else
				outputChatBox( "Banco no encontrado.", player, 255, 0, 0 )
			end
		else
			outputChatBox( "Syntax: /" .. commandName .. " [id]", player, 255, 255, 255 )
		end
	end,
	true
)

addCommandHandler( { "deleteatm", "delatm" },
	function( player, commandName, bankID )
		bankID = tonumber( bankID )
		if bankID then
			local bank = banks[ bankID ]
			if bank then
				if getElementType( bank.bank ) == "object" then
					if exports.sql:query_free( "DELETE FROM banks WHERE bankID = " .. bankID ) then
						outputChatBox( "Borraste el cajero (ID " .. bankID .. ").", player, 0, 255, 153 )
						
						destroyElement( bank.bank )
						banks[ bankID ] = nil
						banks[ bank.bank ] = nil
					else
						outputChatBox( "Error MySQL", player, 255, 0, 0 )
					end
				else
					outputChatBox( "Cajero no encontrado.", player, 255, 0, 0 )
				end
			else
				outputChatBox( "Cajero no encontrado.", player, 255, 0, 0 )
			end
		else
			outputChatBox( "Syntax: /" .. commandName .. " [id]", player, 255, 255, 255 )
		end
	end,
	true
)

--

local cardCache = { }

local function getAccountFromCard( cardID )
	if not cardCache[ cardID ] then
		local result = exports.sql:query_assoc_single( "SELECT bankAccountID, pin FROM bank_cards WHERE cardID = " .. cardID )
		if result then
			cardCache[ cardID ] = { tick = getTickCount( ), account = result.bankAccountID, pin = result.pin }
		else
			return false
		end
	else
		cardCache[ cardID ].tick = getTickCount( )
	end
	return cardCache[ cardID ].account
end

local function getCardPIN( cardID )
	return getAccountFromCard( cardID ) and cardCache[ cardID ].pin or false
end

--

local accountCache = { }

local function getAccountBalance( accountID )
	if not accountCache[ accountID ] then
		local result = exports.sql:query_assoc_single( "SELECT balance FROM bank_accounts WHERE accountID = " .. accountID )
		if result then
			accountCache[ accountID ] = { tick = getTickCount( ), balance = result.balance }
		else
			return false
		end
	else
		accountCache[ accountID ].tick = getTickCount( )
	end
	return accountCache[ accountID ].balance
end

local function modifyAccountBalance( accountID, amount )
	local old = getAccountBalance( accountID )
	if accountCache[ accountID ] then
		local balance = old + amount
		if balance >= 0 and exports.sql:query_free( "UPDATE bank_accounts SET balance = " .. balance .. " WHERE accountID = " .. accountID ) then
			accountCache[ accountID ].balance = balance
			return true
		end
	end
	return false
end

--

setTimer(
	function( )
		-- remove expired data
		local tick = getTickCount( )
		for key, value in pairs( cardCache ) do
			if tick - value.tick > 1800000 then
				cardCache[ key ] = nil
			end
		end
		for key, value in pairs( accountCache ) do
			if tick - value.tick > 1800000 then
				accountCache[ key ] = nil
			end
		end
	end,
	1800000,
	0
)

--

addEventHandler( "onElementClicked", resourceRoot,
	function( button, state, player )
		if ( not p[ player ] or not p[ player ].bankID ) and button == "left" and state == "up" then
			local bankID = banks[ source ]
			if bankID then
				local bank = banks[ bankID ]
				if bank then
					local x, y, z = getElementPosition( player )
					if getDistanceBetweenPoints3D( x, y, z, getElementPosition( source ) ) < ( getElementType( bank.bank ) == "object" and 1 or 5 ) and getElementDimension( player ) == getElementDimension( source ) then
						-- no data set yet
						if not p[ player ] then
							p[ player ] = { }
							
							-- check how many accounts a player has
							local result = exports.sql:query_assoc_single( "SELECT COUNT(*) AS number FROM bank_accounts WHERE characterID = " .. exports.players:getCharacterID( player ) )
							if result then
								p[ player ].accounts = result.number
							end
						end
						
						p[ player ].bankID = bankID
						
						local cards = { }
						for key, value in ipairs( exports.items:get( player ) ) do
							if value.item == 6 then
								local account = getAccountFromCard( value.value )
								if account then
									-- check for double
									local found = false
									for k, v in ipairs( cards ) do
										if v[1] == value.value and v[2] == account then
											found = true
											break
										end
									end
									
									if not found then
										table.insert( cards, { value.value, account } )
									end
								end
							end
						end
						p[ player ].cards = cards
						
						if getElementType( bank.bank ) == "object" then
							-- for an ATM: show all of the accounts a player has a credit card for.
							triggerClientEvent( player, "bank:open", source, cards, nil, bank.canDeposit )
						else
							-- show all accounts a player has a credit card for or which belongs to him.
							triggerClientEvent( player, "bank:open", source, cards, p[ player ].accounts < maxAccountsPerCharacter, bank.canDeposit )
						end
					end
				end
			end
		end
	end
)

addEvent( "bank:close", true )
addEventHandler( "bank:close", root,
	function( )
		if source == client then
			if p[ source ] then
				if p[ source ].ignoreUpdate then
					p[ source ].ignoreUpdate = nil
				else
					p[ source ].bankID = nil
					p[ source ].cards = nil
					p[ source ].card = nil
					p[ source ].enteredPin = nil
				end
			end
		end
	end
)

addEvent( "bank:select", true )
addEventHandler( "bank:select", root,
	function( selected, pin )
		if source == client then
			local bank = p[ source ] and p[ source ].bankID and banks[ p[ source ].bankID ]
			if bank then
				if pin and p[ source ].card then
					local cardPin = getCardPIN( p[ source ].card[ 1 ] )
					if cardPin then
						if cardPin == pin then
							local balance = getAccountBalance( p[ source ].card[ 2 ] )
							if balance then
								p[ source ].enteredPin = true
								p[ source ].ignoreUpdate = true
								triggerClientEvent( source, "bank:single", bank.bank, balance, bank.canDeposit, bank.withdrawFee )
							else
								outputChatBox( "Este servicio actualmente no esta disponible.", source, 255, 0, 0 )
							end
						else
							outputChatBox( "El PIN ingresado no es correcto.", source, 255, 0, 0 )
						end
					else
						outputChatBox( "Este servicio actualmente no esta disponible.", source, 255, 0, 0 )
					end
				elseif selected == -1 then
					-- create a new account, does only work on actual banks
					if getElementType( bank.bank ) == "ped" then
						-- check if the player does even need more accounts
						if p[ source ].accounts < maxAccountsPerCharacter then
							local bankAccount = exports.sql:query_insertid( "INSERT INTO bank_accounts (characterID) VALUES (" .. exports.players:getCharacterID( source ) .. ")" )
							if bankAccount then
								-- generate a PIN needed at ATMs and bank accs.
								local function generatePIN( )
									local digits = { }
									while #digits < 4 do
										local digit = math.random( #digits == 0 and 1 or 0, 9 )
										local found = false
										for k, v in ipairs( digits ) do
											if v == digit then
												found = true
												break
											end
										end
										
										if not found then
											table.insert( digits, digit )
										end
									end
									return table.concat( digits, "" )
								end
								local pin = generatePIN( )
								
								local cardID = exports.sql:query_insertid( "INSERT INTO bank_cards (bankAccountID, pin) VALUES (" .. bankAccount .. ", " .. pin .. ")" )
								if cardID then
									-- give him the card
									exports.items:give( source, 6, cardID )
									
									-- increase the number since we can only give a player a limited number of accounts
									p[ source ].accounts = ( p[ source ].accounts or 0 ) + 1
									
									-- tell him we're successful
									outputChatBox( "Tu cuenta #" .. bankAccount .. " fue creada correctamente.", source, 0, 255, 0 )
									outputChatBox( "El PIN de tu tarjeta de debito: " .. pin .. ". Guardalo, lo nesecitaras para retirar dinero", source, 0, 255, 0 )
									
									-- refresh the gui
									p[ source ].bankID = nil
									p[ source ].ignoreUpdate = true
									
									triggerEvent( "onElementClicked", bank.bank, "left", "up", source )
								else
									outputChatBox( "Debido a un error tecnico, no es posible abrir tu tarjeta de debito", source, 255, 0, 0 )
									
									-- delete the account again
									exports.sql:query_free( "DELETE FROM bank_accounts WHERE accountID = " .. bankAccount )
								end
							else
								outputChatBox( "Debido a un error tecnico, no es posible abrir tu cuenta bancaria", source, 255, 0, 0 )
							end
						end
					end
				elseif type( selected ) == "number" and p[ source ].cards[ selected ] then
					p[ source ].ignoreUpdate = true
					p[ source ].card = p[ source ].cards[ selected ]
						
					triggerClientEvent( source, "bank:promptPIN", bank.bank )
				end
			end
		end
	end
)

addEventHandler( "onCharacterLogout", root,
	function( )
		p[ source ] = nil
	end
)

addEventHandler( "onPlayerQuit", root,
	function( )
		p[ source ] = nil
	end
)

--

addEvent( "bank:updateaccount", true )
addEventHandler( "bank:updateaccount", root,
	function( amount )
		if source == client and type( amount ) == "number" then
			local bank = p[ source ] and p[ source ].bankID and banks[ p[ source ].bankID ]
			if bank then
				amount = math.ceil( amount )
				
				-- we assume the player entered the correct pin before
				if p[ source ].enteredPin then
					local card = p[ source ].card
					
					if amount == 0 then
						return
					elseif amount > 0 then -- we want to deposit money.
						-- we check if it's depositable; if it is then check for whetever the player has so much money. This should never happen.
						if not bank.canDeposit or not exports.players:takeMoney( source, amount ) then
							return
						end
					else
						-- ignore if the amount is too large to be withdrawn
						if -amount > getAccountBalance( card[2] ) then
							return
						elseif -amount + bank.withdrawFee > getAccountBalance( card[2] ) then
							return
						end
					end
					
					if modifyAccountBalance( card[2] , amount - ( amount < 0 and bank.withdrawFee or 0 ) ) then
						if amount < 0 then
							exports.players:giveMoney( source, -amount )
						end
						outputChatBox( "Tu " .. ( amount > 0 and ( "depositaste $" .. amount .. " hacia" ) or ( "retiraste $" .. -amount .. " desde" ) ) .. " tu cuenta. Tu nuevo balance es: $" .. getAccountBalance( card[2] ) .. ".", source, 0, 255, 0 )
					else
						outputChatBox( "Your request could not be processed at this time.", source, 255, 0, 0 )
					end
				end
			end
		end
	end
)

