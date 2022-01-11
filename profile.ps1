#--------------------------Import Modules--------------------------#
# Import-Module Get-Weather
# Import-Module posh-git
Import-Module oh-my-posh

#--------------------------Configuration--------------------------#

# Set-PoshPrompt -Theme craver
Set-PoshPrompt -Theme C:\Users\KennyWhite\Documents\PowerShell\.mycarvertheme.omp.json

#--------------------------Functions--------------------------#

# Launch explorer in path or in current folder default
function e ([string] $directory = ".") { Invoke-Item $directory }

# Requests domain registration info on the specified website
Function WhoIs([string]$website){
    C:\UserPrograms\SysinternalsSuite\whois.exe $website
}

# Walks through each child directory and execute the scriptBlock in each
function Walk-ChildDirectory
{
    Param
    (
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)][ScriptBlock]$Task
    )
    Get-ChildItem -Directory | ForEach-Object{
        Push-Location $_
        & $Task
        Pop-Location
    }
}

function Get-AllHashesInDirectory($path)
{
    Get-ChildItem -Path $path| ForEach-Object{
        Get-FileHash -Path $_.FullName
    }
}

function Compare-StoredHashes
{
    Param
    (
        [Parameter(Mandatory=$true, ValueFromPipeline = $true)]$ReferenceObject,
        [Parameter(Mandatory=$true, ValueFromPipeline = $true)]$DifferenceObject
    )
    (Compare-Object -ReferenceObject $ReferenceObject -DifferenceObject $DifferenceObject  -Property hash -PassThru).Path
}

function Dashboard{
    Get-Weather -City Spokane
}

function Show-CPU {
    $iteration = 0
    while ($iteration -le 10) {
        Get-WmiObject win32_processor | Measure-Object -property LoadPercentage -Average | Select-Object Average
        Start-Sleep -Milliseconds 100   
    }
}

#------------------------------- GIT ---------------------------#

function gwc {
    git log --raw --no-merges -2
}

function gs {
    git status
    
}

function glp {
    git log --pretty='%C(yellow)%h %C(blue)<%an>%C(red)%d%C(reset) %C(bold)%s%C(reset) %C(green)(%cr)' --stat -n3    
}


#---------------------------- NETWORKING ---------------------------------#
function Get-Network-Devices($Subnet, $FileOut, [bool]$GridView ) {
    ## Ping subnet
    if (!($Subnet)) {
        $Subnet = "10.10.42."
    }

    1..254 | ForEach-Object {
        Start-Process -WindowStyle Hidden ping.exe -Argumentlist "-n 1 -l 0 -f -i 2 -w 1 -4 $SubNet$_"
    }
    $Computers = (arp.exe -a | Select-String "$SubNet.*dynam") -replace ' +', ',' |
        ConvertFrom-Csv -Header Computername, IPv4, MAC, x, Vendor |
        Select-Object Computername, IPv4, MAC

    ForEach ($Computer in $Computers) {
        nslookup $Computer.IPv4 | Select-String -Pattern "^Name:\s+([^\.]+).*$" |
        ForEach-Object {
            $Computer.Computername = $_.Matches.Groups[1].Value
        }
}
$Computers
if ($GridView) {
    $Computers | Out-Gridview
}
if ($FileOut) {
    $Computers | Export-Csv $FileOut -NotypeInformation
}
}

function Get-Network-Adapters-Speed {
    Get-WmiObject -Class Win32_NetworkAdapter | `
            Where-Object { $_.Speed -ne $null -and $_.MACAddress -ne $null -and $_.NetConnectionID -ne $null} | `
            Format-Table -Property SystemName, Name, NetConnectionID, @{Label = 'Speed(MB)'; Expression = { $_.Speed / 1MB } }   
}

function Get-Applications-With-Active-Internet-Connections {
    try 
        {
            Get-NetTCPConnection -AppliedSetting Internet | Select-Object -Property OwningProcess | Get-Process -ID { $_.OwningProcess } -IncludeUserName

            #Get-NetTCPConnection -AppliedSetting Internet | Select-Object -Property CreationTime, OwningProcess | Get-Process -ID {$_.OwningProcess} -IncludeUserName | New-TimeSpan -End {$_.CreationTime}
        
        }
        catch [InvalidOperationException] 
        {
            Write-Host "This command needs to be run from an elevated shell" -ForegroundColor DarkYellow
        }
}

#--------------------------Aliases--------------------------#
Set-Alias walk Walk-ChildDirectory
$ACE = "C:\Users\KennyWhite\source\repos\-iNPUT"

#--------------------------Posh git setup--------------------------#
# $GitPromptSettings.EnableWindowTitle = '~'
# $GitPromptSettings.DefaultPromptAbbreviateHomeDirectory = $true
# $GitPromptSettings.DefaultPromptSuffix = "$(">" * ($nestedPromptLevel + 1)) "
# #$GitPromptSettings.AfterText += "`n $([DateTime]::now.ToString("MM-dd HH:mm:ss"))"
# $GitPromptSettings.AfterForegroundColor = "Blue"
# $GitPromptSettings.BeforeForegroundColor = "Blue"
# $GitPromptSettings.DefaultForegroundColor = "Green"

function Test-Administrator {
    $user = [Security.Principal.WindowsIdentity]::GetCurrent();
    (New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}


# function prompt {
#     $realLASTEXITCODE = $LASTEXITCODE

#     Write-Host

#     if (Test-Administrator) {
#         # Use different username if elevated
#         Write-Host "(Elevated) " -NoNewline -ForegroundColor White
#     }

#     if ($s -ne $null) {
#         # color for PSSessions
#         Write-Host " (`$s: " -NoNewline -ForegroundColor DarkGray
#         Write-Host "$($s.Name)" -NoNewline -ForegroundColor Yellow
#         Write-Host ") " -NoNewline -ForegroundColor DarkGray
#     }

#     Write-Host $($(Get-Location) -replace ($env:USERPROFILE).Replace('\', '\\'), "~") -NoNewline -ForegroundColor Blue
#     Write-Host " : " -NoNewline -ForegroundColor DarkGray
#     Write-Host (Get-Date -Format G) -NoNewline -ForegroundColor Magenta
#     Write-Host " :" -NoNewline -ForegroundColor DarkGray

#     $global:LASTEXITCODE = $realLASTEXITCODE

#     Write-VcsStatus

#     Write-Host ""

#     return "> "
# }



### Modules
# posh-git
# Z (rupa)
### optional
# get-weather