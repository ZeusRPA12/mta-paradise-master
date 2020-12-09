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

addEventHandler( "onClientElementStreamIn", resourceRoot,
	function( )
		setPedAnimation( source, "ped", "seat_idle", -1, true, false, true )
		exports.gui:hint( "Ayuntamiento de las Venturas", "Si necesita un trabajo o quiere cambiar el que tiene ahora, hable con la señora de la recepción. ((Presione 'm' y haga clic en ella.))" )
	end
)

--

addEvent( getResourceName( resource ) .. ":open", true )
addEventHandler( getResourceName( resource ) .. ":open", resourceRoot,
	function( resources )
		exports.gui:hide( )
		exports.gui:updateJobs( resources )
		exports.gui:show( 'jobs' )
	end
)
