#By: @dirkanSYN -> https://twitter.com/dirkanSYN
 
#Cifrados/Descifrados con DPAPI

#-------------------------------------------------------------------------------------------------------------------------

#Cifrado con cuenta de Maquina

Function Cifrado-ConMachineKey($texto) {
    
    Add-Type -AssemblyName System.Security
    $bytes = [System.Text.Encoding]::Unicode.GetBytes($texto)
    $scope = [Security.Cryptography.DataProtectionScope]::LocalMachine
    $secureStr = [Security.Cryptography.ProtectedData]::Protect($bytes, $null, $scope)
    $textoCifrado = [System.Convert]::ToBase64String($secureStr)
    return $textoCifrado 
}

#Descifrado con cuenta de Maquina 

Function Descifrado-ConMachineKey($texto) {
    
    Add-Type -AssemblyName System.Security
    $secureStr = [System.Convert]::FromBase64String($texto)
    $scope = [Security.Cryptography.DataProtectionScope]::LocalMachine
    $bytes = [Security.Cryptography.ProtectedData]::Unprotect($secureStr, $null, $scope)
    $textoDescifrado = [System.Text.Encoding]::Unicode.GetString($bytes)
    return $textoDescifrado
}


#-------------------------------------------------------------------------------------------------------------------------

#Cifrado con cuenta de User

Function Cifrado-ConUserKey($texto) {
    
    Add-Type -AssemblyName System.Security
    $bytes = [System.Text.Encoding]::Unicode.GetBytes($texto)
    $scope = [Security.Cryptography.DataProtectionScope]::CurrentUser
    $secureStr = [Security.Cryptography.ProtectedData]::Protect($bytes, $null, $scope)
    $textoCifrado = [System.Convert]::ToBase64String($secureStr)
    return $textoCifrado 
}

#Descifrado con cuenta de User 

Function Descifrado-ConUserKey($texto) {
    
    Add-Type -AssemblyName System.Security
    $secureStr = [System.Convert]::FromBase64String($texto)
    $scope = [Security.Cryptography.DataProtectionScope]::CurrentUser
    $bytes = [Security.Cryptography.ProtectedData]::Unprotect($secureStr, $null, $scope)
    $textoDescifrado = [System.Text.Encoding]::Unicode.GetString($bytes)
    return $textoDescifrado
}

#-------------------------------------------------------------------------------------------------------------------------

#Cifrado con cuenta de Maquina y User

Function Cifrado-ConMachineUserKey($texto) {
    
    $secureString = ConvertTo-SecureString -String $texto -AsPlainText -Force
    $textoCifrado = ConvertFrom-SecureString -SecureString $SecureString
    return $textoCifrado 
}

#Descifrado con cuenta de Maquina y User 

Function Descifrado-ConMachineUserKey($texto) {
    
    $secureString = ConvertTo-SecureString -String $texto
    $textoDescifrado=[Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR((($secureString))))
    return $textoDescifrado
}

