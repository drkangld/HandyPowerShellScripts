Set-ExecutionPolicy Bypass
Add-Type -AssemblyName PresentationFramework
$timestamp = Get-Date
$RefreshStatus = $($(Get-ScheduledTask -TaskName "Refresh AXGOLDBLD" -CimSession BRKAXGOLDBLD).state).tostring()
$AOSStatus = $($(Get-Service -ComputerName brkaxgoldbld -name 'AOS60$01').Status).tostring()

switch ($RefreshStatus)
{
  "Ready"     { $RefreshStatus = "Job is ready for next run at 6:30pm CT" }
  "Disabled"  { $RefreshStatus = "Refresh job is DISABLED for maintenance" }
  "Running"   { $RefreshStatus = "REFRESH IN PROGRES...AXGOLDBLD is not available at this time" }


}

[void] [System.Windows.MessageBox]::Show( "As of $timestamp`nCurrent Status of AXGOLD is: `n$RefreshStatus`nand the AOS is $AOSStatus", "Status of Nightly AXGOLDBLD Refresh", "OK", "Information" )
