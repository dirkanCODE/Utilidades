# Funciones para Cifrar y Descifrar cadenas de texto

Puede ser util para acceso a sistemas remotos mediante ejecución de scripts con credenciales.  Las passwords de los usuarios a utilizar, para el acceso a esos sistemas remotos, previamente se almacenan en ficheros que solo son accesibles por un usuario determinado, en una máquina determinada o combinando las dos.  

Estos serían los pasos de un ejemplo sencillo de como almacenar passwords en ficheros solo accesibles por un usuario determinado, y como crear las credenciales y ejecutar remotamente el código con esas credenciales:

1.- Ejecutar Powershell ISE con runas del Usuario que luego vaya a ejecutar el script.

2.- Cifrar las Passwords de las credenciales que el script vaya a usar: usuarios de Entornos Previos, PRE, DESA, Usuarios Locales, etc., y guardar cada password en un fichero:

```powershell
Cifrado-ConUserKey "<password>" | Set-content C:\temp\<UserPwdCifrada>.txt
```  

3.- Iniciar el Script que se quiera programar obteniendo las passwords de los ficheros guardados y montar las credenciales:

```powershell  
$PwdCifrada=get-content C:\temp\<UserPwdCifrada>.txt
$PwdTextoPlano=Decrypt-ConUserKey $PwdCifrada
$password = ConvertTo-SecureString $PwdTextoPlano -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential ("<username>", $password)
``` 
4.- Lanzar los comandos al equipo remoto con las credenciales montadas:

```powershell  
Invoke-Command -ComputerName COMPUTER -ScriptBlock { <Codigo a ejecutar en equipo remoto> } -Credential $credential
``` 
