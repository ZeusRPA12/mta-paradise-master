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

local texts =
{
	{"Bienvenido", "Bienvenido a MTA: Paradise. Permítanos presentarle el servidor, no tardará mucho", 1},
    {"Las Reglas", "Puedes acceder a las reglas en cualquier momento con solo presionar 'F1', te recomendamos que las consultes lo antes posible para evitar cualquier problema.", 2},
    {"The Setting", "Este servidor está ubicado en San Fierro rodeado por la bahía y un montón de pequeños pueblos. El año actual es" .. (getRealTime (). Year + 1900) .. "- present time.", 1},
    {"Vehículos", "Varios vehículos de libre acceso (civiles, ya que no tienen propietario) se colocan alrededor de la ciudad, puedes comprar tu propio vehículo en cualquier momento", 1},
    {"Trabajos legales", "Bien, todos quieren ganar algo de dinero. Una buena idea para comenzar es conseguir un trabajo en el Ayuntamiento. Presione 'F11', vea el marcador amarillo.", 1},
    {"Factions I", "Hay algunas facciones en la ciudad, la más importante es el Departamento de Policía, entre las que hay un puñado de legales e ilegales", 1},
    {"Factions II", "Si estás interesado en jugar con una facción y eventualmente en ella, echa un vistazo a su foro para obtener más detalles", 1},
    {"The End", "Aunque eso no fue mucho, ese es el final de nuestros pocos consejos. Si tiene alguna pregunta pendiente o desea comunicarse con un administrador, presione 'F2' o escriba / report.", 1},
    {"The actual End", "Para obtener más información, visite nuestros foros en http://forum.paradisegaming.net", 1},
}

function tutorial( )
	for key, value in ipairs( texts ) do
		setTimer( function( ... ) exports.gui:hint( ... ) end, 50 + 7000 * ( key - 1 ), 1, unpack( value ) )
	end
end
