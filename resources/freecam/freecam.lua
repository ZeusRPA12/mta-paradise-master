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

addCommandHandler( "freecam",
	function( player, commandName )
		if not isPedInVehicle( player ) then
			if isPlayerFreecamEnabled( player ) then
				setPlayerFreecamDisabled( player )
			elseif isElementAttached( player ) then
				outputChatBox( "No puedes usar esta función en este momento.", player, 255, 0, 0 )
			else
				setPlayerFreecamEnabled( player )
			end
		else
			outputChatBox( "No puedes usar esto en un vehículo.", player, 255, 0, 0 )
		end
	end,
	true
)

addEventHandler( "onCharacterLogout", root,
	function( )
		if isPlayerFreecamEnabled( source ) then
			setPlayerFreecamDisabled( source )
		end
	end
)

addEventHandler( "onResourceStop", resourceRoot,
	function( )
		if isPlayerFreecamEnabled( source ) then
			setPlayerFreecamDisabled( source )
		end
	end
)
