#By: dirkan (@dirkanNEWS) -> https://twitter.com/dirkanNEWS

### Obtener usuarios logados en los últimos 30 Días

Get-ADUser -Filter * -Properties LastLogonDate | where {$_.LastLogonDate -le (Get-Date).AddDays(-30)} | sort-object -property lastlogondate -descending | Format-Table -property name, lastlogondate -AutoSize

### Buscar Objetos Modificados desde dia anterior. 

$date = (Get-Date).AddDays(-1)
get-adobject -Filter {whenchanged -ge $date} -SearchBase '<Base DN>' -searchscope Subtree -Properties samaccountname, whenchanged

### Buscar Objetos Modificados en DA entre dos Fechas-Horas.  Analiza OU por OU para que las queries sean más ligeras.

$changeDateStart = New-Object DateTime(2021, 03, 26, 10, 00, 00)
$changeDateEnd = New-Object DateTime(2021, 03, 26, 16, 00, 00)
$OUs=Get-ADOrganizationalUnit -Filter 'Name -like "*"' -server <DC> -SearchBase '<Base DN>' -SearchScope SubTree | select DistinguishedName
$totalOUs=$Ous.Count
$j=0
foreach ($ou in $OUs)
{
    $j++
    write-host ("OU $j/$totalOUs - "+$ou.DistinguishedName) -f green
    
    Get-ADObject -Filter {(whenchanged -ge $changeDateStart) -and (whenchanged -le $changeDateEnd)} -SearchBase $ou.DistinguishedName `
    -Properties distinguishedname,whenchanged -server <DC> -SearchScope Onelevel | select distinguishedname,whenchanged

}

### Chequear Resolucion DNS con bucle de intentos de resolución secuenciales.

$ErrorActionPreference="SilentlyContinue"

#Establecer el numero de intentos de resolución en la variable $dnsRequests

$dnsRequests=5

$dnsServers=@("<IP1>","<IP2>","<IP3>","<IP4>")
$dnsRecord="<DnsRecordToCheck>"

foreach ($dnsServer in $dnsServers)
{
    write-host "Dns Server: $dnsServer" -f yellow
    for ($i=1;$i -le $dnsRequests;$i++)
    {
        $mError=$null
        $a=iex("nslookup $dnsRecord $dnsServer") -errorvariable mError
        $auxError=[string]$mError.Exception.Message
        if ((-not ($mError)) -or  ($auxError.contains("Non-authoritative")))
        {
            write-host "$i - Sin errores" -f green
        }
        else
        {
            write-host ("$i - "+$mError.Exception.Message) -f red
        }
    }
}

###  Obtener fecha de Expiración Password:  PwdLastSet+Maximum Password Age (in domain GPO)

Get-ADUser –Identity <Usuario> –Properties msDS-UserPasswordExpiryTimeComputed | Select-Object -Property Name, @{Name="FechaExpiracion";Expression={[datetime]::FromFileTime($_."msDS-UserPasswordExpiryTimeComputed")}}

### Obtener Relaciones de Confianza Entre Bosques:

$dominios = get-adtrust -filter * -server <DC> | ?{$_.IntraForest -ne 'True' } | Select Name,IntraForest
foreach ($d in $dominios)
{
    $server=$d.name
    write-host $server -f Yellow
    $sub=get-adtrust -filter * -server $server | where-object {$_.IntraForest -eq "True" } | select name
    $sub.name
}

### Detectar Delegaciones Kerberos

$Cuentas=Get-ADObject -fi {(msDS-AllowedToDelegateTo -like '*') -or (UserAccountControl -band 0x0080000) -or (UserAccountControl -band 0x1000000)} -properties samAccountName,msDS-AllowedToDelegateTo,servicePrincipalName,userAccountControl -server <DC> | select DistinguishedName,ObjectClass,samAccountName,servicePrincipalName,`
 @{name='DelegationStatus';expression={if($_.UserAccountControl -band 0x80000){'AllServices'}else{'SpecificServices'}}},
 @{name='AllowedProtocols';expression={if($_.UserAccountControl -band 0x1000000){'Any'}else{'Kerberos'}}},
@{name='DestinationServices';expression={$_.'msDS-AllowedToDelegateTo'}}

"DN;ObjectClass;SamAccountNAme;SPN;DelegationStatus;AllowedProtocols;DestionationServices"  | out-file "C:\temp\Cuentas.csv"

Foreach ($a in $Cuentas)
{
    write-host "$($a.distinguishedName);$($a.ObjectClass);$($a.samAccountName);$($a.servicePrincipalName);$($a.DelegationStatus);$($a.AllowedProtocols);$($a.DestinationServices)"
    write-Output "$($a.distinguishedName);$($a.ObjectClass);$($a.samAccountName);$($a.servicePrincipalName);$($a.DelegationStatus);$($a.AllowedProtocols);$($a.DestinationServices)" | out-file "C:\temp\Cuentas.csv" -append

}
