$path = "c:\temp\junk"
$filePFX = "JunkFile"
$FileSFX = '.txt'
$MaxFiles = 200


for ($i = 1;$i -lt $MaxFiles;$i++)
  {  
   $newFile = $filePFX + "_$i" + $FileSFX
   $newFile
 
   $file = new-item -path $path -Name $newFile -ItemType "file"
   
   #setting timestame, either sequential or random
   $file.LastWriteTime = $(Get-Date).AddDays(-$MaxFiles + $i +1)
   #$file.LastWriteTime = $(Get-Date).AddDays(-(1+$(Get-Random -Minimum 1 -maximum $MaxFiles)))
   

   #$newFile.LastWriteTime = $(Get-date).AddDays(-$MaxFiles + $i)


  }
