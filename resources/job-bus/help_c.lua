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

local blip, sphere

addEvent( getResourceName( resource ) .. ":introduce", true )
addEventHandler( getResourceName( resource ) .. ":introduce", root,
	function( )
		exports.gui:hint( "Tu Trabajo: Conductor De Bus", "Es fácil, solo sigue la ruta hasta llegar a tu último destino. Para comenzar, tome un autobús en la estación Linden, hay un marcador en su radar.", 1 )
		
		if not blip and not sphere then
			sphere = createColSphere( 2819, 1317, 10, 50 )
			blip = createBlipAttachedTo( sphere, 0, 3, 0, 255, 0, 127 )
			
			addEventHandler( "onClientColShapeHit", sphere,
				function( element )
					if element == getLocalPlayer( ) then
						destroyElement( blip )
						destroyElement( sphere )
						
						sphere = nil
						blip = nil
						
						exports.gui:hint( "Tu Trabajo: Conductor de Bus", "Ingrese a cualquier autobús que desee y se le asignará automáticamente una ruta. Si no hay un autobús disponible, es posible que desee esperar un poco o volver a consultar más tarde." )
					end
				end
			)
		end
	end
)
