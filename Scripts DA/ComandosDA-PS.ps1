#By: @dirkanSYN -> https://twitter.com/dirkanSYN

# Obtener usuarios logados en los últimos 30 Días

Get-ADUser -Filter * -Properties LastLogonDate | where {$_.LastLogonDate -le (Get-Date).AddDays(-30)} | sort-object -property lastlogondate -descending | Format-Table -property name, lastlogondate -AutoSize


