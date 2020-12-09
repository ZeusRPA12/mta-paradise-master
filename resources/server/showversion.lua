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

addEventHandler( "onClientResourceStart", resourceRoot,
	function( )
		local screenX, screenY = guiGetScreenSize( )
		local label = guiCreateLabel( 0, 0, screenX, 15, "MTA: Paradise " .. getVersion( ), false )
		guiSetSize( label, guiLabelGetTextExtent( label ) + 5, 14, false )
		guiSetPosition( label, screenX - guiLabelGetTextExtent( label ) - 5, screenY - 27, false )
		guiSetAlpha( label, 0.5 )
	end
)
