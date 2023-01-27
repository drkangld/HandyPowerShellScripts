Get-ADGroupMember -Identity "Dynamics AX Developers" | Select-Object name,objectClass | export-csv -path c:\temp\DAXDevUsers.csv
