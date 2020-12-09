# mta-paradise-master

+Arreglado todos los errores de MySQL
-Se ha Quitado los Modulso Sha.so , Sha.dll
+Se Ha Traducido toda la base para los que son de hablahispana
+se han Arreglado Bugs Tales como:

-Se Ha Arreglado  vehicles-nodes
-Se Ha Arreglado vehicles-shop
-Se Ha Arreglado Admin
-Se Ha Arreglado MySQL Data Base v.123
-Se Ha Añadido un Comando llamando /lua lo cual te abrira un gui con todo lo necesario para aprender a scriptear
-Añadido y Correjido los Chat's ya que daban errores
-Añadido el Comando /limpiarchat
-Se han quitado los runcode que hacia que podias setearte dinero si no eras admin o mod
-Se ha quitado Varios Comandos Ocultos

# MTA: Paradise
... es un modo de juego de roles para [Multi Theft Auto: San Andreas] (http://mtasa.com).

## Cosas Agregadas

### Personajes
Todos pueden crear varios personajes por cuenta, lo que le brinda la oportunidad de interpretar a diferentes personalidades dentro de múltiples grupos étnicos en el mismo servidor y con la misma cuenta.

### Chat's
Hay dos tipos de chats disponibles, en el chat de personajes (IC) por una vez basado en todo el personaje que estás jugando. Esto incluye todo lo que tu personaje dice o hace (/ yo), o lo que necesites para describir el entorno de tu personaje (/ do). Todo el chat dentro del personaje es a distancia, opuesto al chat fuera del personaje (OOC). En OOC, se trata de la persona detrás de la pantalla, no del personaje que estás interpretando. Hay disponibles tanto chat a distancia (/ b) como global (/ o), aunque tenga en cuenta que uno debe mantenerse fuera del chat de personajes durante un juego de rol cerca del mínimo absoluto.

### Vehiculos

Tan pronto como haya alcanzado una cierta cantidad de riqueza, podrá comprar vehículos. Estos permanecerán donde los dejó el último ocupante. Dado que su vehículo puede terminar en el agua / explotado, hay reapariciones globales de vehículos, teletransportándolos de regreso a la posición que usó / estacionó en un tiempo, según lo pareciera necesario por parte de la administración del servidor.

### Casas y Negocios
Por una pequeña cantidad de dinero, es posible alquilar o comprar sus propias casas y negocios desde una variedad de interiores, lo que le brinda un lugar para vivir o trabajar y hacer lo que quiera.

## Detras de las Escenas
*Lua*
El modo está completamente escrito en Lua, lo que brinda a todos la oportunidad de adoptar y modificar fácilmente partes del mismo. Por supuesto, todos son bienvenidos a mejorar MTA: Paradise, y un buen comienzo es [bifurcar el proyecto] (http://github.com/marcusbauer/mta-paradise/fork) en GitHub.

### MySQL
Todos los datos dinámicos se guardan en una base de datos MySQL, esto incluye personajes, vehículos, casas, etc. Esta base de datos está estrechamente vinculada con nuestros foros y, aunque es posible ejecutar el modo sin ella, ciertas funciones solo serán posibles en los foros en el estado actual de desarrollo. También se obtienen de la base de datos todos los derechos de administrador, lo que hace posible utilizar la Lista de control de acceso (ACL) de MTA junto con nuestras cuentas de la base de datos.
