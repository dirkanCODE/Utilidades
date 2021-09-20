#By: dirkan (@dirkanSYN) -> https://twitter.com/dirkanSYN

### Obtener usuarios logados en los últimos 30 Días

Get-ADUser -Filter * -Properties LastLogonDate | where {$_.LastLogonDate -le (Get-Date).AddDays(-30)} | sort-object -property lastlogondate -descending | Format-Table -property name, lastlogondate -AutoSize

### Buscar Objetos Modificados en DA entre dos Fechas-Horas.  Analiza OU por OU para que las queries sean más ligeras.

$changeDateStart = New-Object DateTime(2021, 03, 26, 10, 00, 00)
$changeDateEnd = New-Object DateTime(2021, 03, 26, 16, 00, 00)
$OUs=Get-ADOrganizationalUnit -Filter 'Name -like "*"' -server <DC> -SearchBase '<DN Domain>' -SearchScope SubTree | select DistinguishedName
$totalOUs=$Ous.Count
$j=0
foreach ($ou in $OUs)
{
    $j++
    write-host ("OU $j/$totalOUs - "+$ou.DistinguishedName) -f green
    
    Get-ADObject -Filter {(whenchanged -ge $changeDateStart) -and (whenchanged -le $changeDateEnd)} -SearchBase $ou.DistinguishedName `
    -Properties distinguishedname,whenchanged -server <DC> | select distinguishedname,whenchanged

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
