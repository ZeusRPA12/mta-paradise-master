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

addCommandHandler( "pay",
	function( player, commandName, otherPlayer, amount )
		local amount = tonumber( amount )
		if otherPlayer and amount and math.ceil( amount ) == amount and amount > 0 then
			local other, name = exports.players:getFromName( player, otherPlayer )
			if other then
				if player ~= other then
					local x, y, z = getElementPosition( player )
					if getDistanceBetweenPoints3D( x, y, z, getElementPosition( other ) ) < 5 then
						if exports.players:takeMoney( player, amount ) then
							exports.players:giveMoney( other, amount )
							outputChatBox( "Acabas de pagarle a: " .. name .. " $" .. amount .. ".", player, 0, 255, 0 )
							outputChatBox( getPlayerName( player ):gsub( "_", " " ) .. " te acaba de pagar: $" .. amount .. ".", other, 0, 255, 0 )
						end
					else
						outputChatBox( "Estás demasiado lejos de " .. name .. ".", player, 255, 0, 0 )
					end
				else
					outputChatBox( "No puedes darte dinero a ti mismo.", player, 255, 0, 0 )
				end
			end
		else
			outputChatBox( "Syntax: /" .. commandName .. " [player] [amount]", player, 255, 255, 255 )
		end
	end
)
