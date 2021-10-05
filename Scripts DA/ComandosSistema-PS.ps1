#By: dirkan (@dirkanNEWS) -> https://twitter.com/dirkanNEWS

### Funciónpara Obtener Tamaño de Carpetas que acepta encadenamiento "pipe" 

Function Get-FolderSize
{
     BEGIN
     {
        $fso = New-Object -comobject Scripting.FileSystemObject
     }
     PROCESS
     {
        $path = $input.fullname
        $folder = $fso.GetFolder($path)
        $size = $folder.size
        [PSCustomObject]@{‘Name’ = $path;’Size’ = ($size / 1gb) } 
     } 
}

Get-ChildItem -Path c:\temp -Directory -Recurse -EA 0 | Get-FolderSize | sort size -Descending
