$connectionInfo = Get-NetTCPConnection -AppliedSetting Internet | 
    Select-Object -Property CreationTime, OwningProcess  
$processInfo = Get-Process -ID $_.OwningProcess -IncludeUserName 


foreach ($info in $connectionInfo) {
    $time = New-TimeSpan -Start $connectionInfo.CreationTime
$info.OwningProcess 
$info.CreationTime
}