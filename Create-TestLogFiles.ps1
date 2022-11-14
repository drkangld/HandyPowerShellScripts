$path = "c:\temp\junk"
$filePFX = "JunkFile"
$FileSFX = '.txt'
$MaxFiles = 100

for ($i = 1;$i -lt $MaxFiles;$i++)
  {  
   $newFile = $filePFX + "_$i" + $FileSFX
   $newFile
 
   $file = new-item -path $path -Name $newFile -ItemType "file"
   $file.LastWriteTime = $(Get-Date).AddDays(-$MaxFiles + $i +1)
   
   #$newFile.LastWriteTime = $(Get-date).AddDays(-$MaxFiles + $i)


  }
