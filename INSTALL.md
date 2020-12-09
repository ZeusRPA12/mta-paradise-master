# MTA: Paradise Instalacion

## Configuracion del MySQL

### Creando una nueva Base de datos
Cree una nueva base de datos, el servidor debería crear automáticamente todas las tablas requeridas si puede iniciar sesión y se otorgan los privilegios necesarios.

### Configurando tu Servidor
Para hacer que su servidor use su base de datos MySQL, edite su * settings.xml * para que al menos contenga las siguientes configuraciones; por supuesto, reemplace los valores de ejemplo con los datos MySQL para conectarse al servidor.

    <settings>
        <!-- MySQL Configuracion -->
        <setting name="@sql.user" value="username"/>
        <setting name="@sql.password" value="password"/>
        <setting name="@sql.database" value="database"/>
        <setting name="@sql.hostname" value="localhost"/>
        <setting name="@sql.port" value="3306"/>
        <!-- Solo use esto en Linux si la conexión normal falla a pesar de usar el nombre de usuario y la contraseña correctos. -->
        <setting name="@sql.socket" value="/var/run/mysqld/mysqld.sock"/>
        
        <!-- Registracion -->
        <setting name="@players.allow_registration" value="1"/><!-- Change to 0 to disable registration and show an error message -->
        <setting name="@players.registration_error_message" value="Edit this to show the user a message when registration is disabled"/>
    </settings>

## MTA Server Configuracion

### Obteniendo los Recursos
Para comenzar, clona el [repositorio principal] (git: //github.com/marcusbauer/mta-paradise.git) o ​​tu bifurcación en * mods / deathmatch *. Ya debería venir con todos los archivos de configuración necesarios.

### Linux
Si está utilizando un servidor linux, edite * mods/deathmatch/mtaserver.conf * y reemplace

        <module src="mta_mysql.dll"/>

*Por*

        <module src="mta_mysql.so"/>

### Windows
Necesita copiar el archivo * mods / deathmatch / modules / libmysql.dll * a su directorio * MTA Server * (el que tiene MTA Server.exe en él)

### Listo Para Ir!

Suponiendo que los detalles de su conexión MySQL estén configurados correctamente, todo lo que queda por hacer es iniciar el servidor MTA. De lo contrario, el servidor seguirá apagándose al iniciarse, consulte * mods / deathmatch / logs / server.log * para ver un mensaje de error detallado.
