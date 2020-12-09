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

shop_configurations =
{
	cluckinbell =
	{
		name = "Cluckin' Bell",
		skin = 167,
		{ itemID = 3, itemValue = 10, name = "Cluckin' Little Meal", description = "Contiene papas fritas, una comida para niños Little Clucker y una lata de Sprunk.", price = 2 },
		{ itemID = 3, itemValue = 30, name = "Cluckin' Big Meal", description = "Contiene papas fritas, una hamburguesa de filete y una lata de Sprunk.", price = 5 },
		{ itemID = 3, itemValue = 55, name = "Cluckin' Huge Meal", description = "Contiene las patatas fritas, doble hamburguesa, a Wing Pieces y una lata de bebida sprunk.", price = 10 },
		{ itemID = 3, itemValue = 40, name = "Salad Meal", description = "Contiene un plato de ensalada, Wraps de ave, un dip y una lata de Sprunk.", price = 10 },
		{ itemID = 4, itemValue = 30, name = "Sprunk", description = "Una lata de una deliciosa bebida sprunk.", price = 5 },
		{ itemID = 4, itemValue = 20, name = "Water", description = "Una botella de agua cristalina de montaña.", price = 3 },
	},
	burgershot =
	{
		name = "Burger-Shot",
		skin = 205,
		{ itemID = 3, itemValue = 15, name = "Moo Kids Meal", description = "Comida para niños de A Little Moo con una lata de Sprunk.", price = 2 },
		{ itemID = 3, itemValue = 30, name = "Beef Tower Meal", description = "Contiene papas fritas, una hamburguesa Beef Tower, un Fowl Wrap y una lata de Sprunk.", price = 5 },
		{ itemID = 3, itemValue = 50, name = "Meat Stack Meal", description = "Contiene papas fritas, una hamburguesa de carne y una lata de Sprunk.", price = 10 },
		{ itemID = 3, itemValue = 40, name = "Salad Meal", description = "Contiene un plato de ensalada y una lata de Sprunk.", price = 10 },
		{ itemID = 4, itemValue = 30, name = "Sprunk", description = "Una lata de una deliciosa bebida sprunk.", price = 5 },
		{ itemID = 4, itemValue = 20, name = "Water", description = "Una botella de agua cristalina de montaña.", price = 3 },
	},
	pizza =
	{
		name = "The Well\nStacked Pizza Co.",
		skin = 155,
		{ itemID = 3, itemValue = 10, name = "Buster", description = "Contiene papas fritas, una rebanada de pizza y una lata de Sprunk.", price = 3 },
		{ itemID = 3, itemValue = 30, name = "Double D-Luxe", description = "Contiene papas fritas, una rebanada de pizza, una ensalada con pechuga de pollo y una lata de Sprunk..", price = 5 },
		{ itemID = 3, itemValue = 50, name = "Full Rack", description = "Contiene papas fritas, una pizza y una lata de Sprunk..", price = 10 },
		{ itemID = 3, itemValue = 70, name = "Large Salad Meal", description = "Contiene un plato grande de ensalada y una lata de Sprunk..", price = 10 },
		{ itemID = 4, itemValue = 30, name = "Sprunk", description = "Una lata de una deliciosa bebida sprunk.", price = 5 },
		{ itemID = 4, itemValue = 20, name = "Water", description = "Una botella de agua cristalina de montaña.", price = 3 },
	},
	hotdogs =
	{
		name = "Chilli Dogs",
		skin = 168,
		{ itemID = 3, itemValue = 15, name = "Hotdog", description = "Delicioso hotdog.", price = 4 },
	},
	noodles =
	{
		name = "Noodle Exchange",
		skin = 168,
		{ itemID = 3, itemValue = 20, name = "Ramen", description = "Una sopa japonesa de noodle.", price = 2 },
	},
	icecream =
	{
		name = "Ice Cream Vendor",
		skin = 168,
		{ itemID = 3, itemValue = 10, name = "Ice cream stick", description = "Delicioso, helado de chocolate.", price = 1 },
	},
	electronics =
	{
		name = "San Fierro\nElectronics",
		skin = 217,
		{ itemID = 7, description = "Un moderno telefono.", price = 50 },
	},
	books =
	{
		name = "Book Store",
		skin = 211,
	}
}

local function loadBookStore( )
	for key, value in ipairs( shop_configurations.books ) do
		shop_configurations.books[ key ] = nil
	end
	
	local languages = exports.players:getLanguages( )
	if languages then
		for key, value in ipairs( languages ) do
			table.insert( shop_configurations.books, { itemID = 8, itemValue = value[2], name = value[1] .. " Diccionario", description = "Un diccionario para aprender los conceptos básicos del idioma " .. value[1] .. ".", price = 100 } )
		end
	end
end

addEventHandler( getResources and "onResourceStart" or "onClientResourceStart", root,
	function( res )
		if res == resource then
			if getResourceFromName( "players" ) and ( not getResourceState or getResourceState( getResourceFromName( "players" ) ) == "running" ) then
				loadBookStore( )
			end
		elseif res == getResourceFromName( "players" ) then
			loadBookStore( )
		end
	end
)
