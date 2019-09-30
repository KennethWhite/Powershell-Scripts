# update help
Update-Help -Force -ErrorAction SilentlyContinue

# install choco
if (!(Get-Command choco.exe -ErrorAction SilentlyContinue)) {
    Set-ExecutionPolicy Bypass -Scope Process -Force; 
    iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
}

# install programs
#choco install vivaldi -n
choco install everything -y
choco install git -y
choco install tortoisegit -y
choco install nodejs-lts -y # this is version 10.15.3 not 12.* because it works much better with Coalesce
choco install notepadplusplus -y
choco install 7zip -y
choco install googlechrome -y
choco install spotify -y
#choco install vscode -y
choco install sql-server-management-studio -y
choco install python -y


# Determine install directory and add notepad++ alias. Saves to temp file
gc .\MyPSProfile.ps1 | %{
	$_
    if($_ -match "ALIASES")
    {
		if ( $ENV:PROCESSOR_ARCHITECTURE -eq 'AMD64' ){
		$npp = "C:\Program Files (x86)\Notepad++\notepad++.exe"
		} else {
			$npp = "C:\Program Files\Notepad++\notepad++.exe"
		}
		"set-alias npp `"$npp`""
	}
} | set-content tempProfile.ps1

# copy profile data
if (!(Test-Path -Path $profile))
{
	New-Item -ItemType File -Path $profile -Force
}
else 
{
	Clear-Content $profile.CurrentUserAllHosts
	echo "Previous profile cleared"
}
# Copy Profile
Get-Content .\tempProfile.ps1 | Add-Content $profile.CurrentUserAllHosts

rm ./tempProfile.ps1



# create PSDrive for registry keys
New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT

# right click directory open PS
new-item -Path HKCR:\Directory\shell\PowerShellHere
new-item -Path HKCR:\Directory\shell\PowerShellHere\command
Set-ItemProperty -Path HKCR:\Directory\shell\PowerShellHere -Name "(Default)" -Value "Open PowerShell Here"
Set-ItemProperty -Path HKCR:\Directory\shell\PowerShellHere -Name "Icon" -Value "powershell.exe,0"
Set-ItemProperty -Path HKCR:\Directory\shell\PowerShellHere\command -Name "(Default)" -Value "powershell.exe -noexit -command Set-Location '%V'"

# right click directory background open PS
new-item -Path HKCR:\Directory\Background\shell\PowerShellHere
new-item -Path HKCR:\Directory\Background\shell\PowerShellHere\command
Set-ItemProperty -Path HKCR:\Directory\Background\shell\PowerShellHere -Name "(Default)" -Value "Open PowerShell Here"
Set-ItemProperty -Path HKCR:\Directory\Background\shell\PowerShellHere -Name "Icon" -Value "powershell.exe,0"
Set-ItemProperty -Path HKCR:\Directory\Background\shell\PowerShellHere\command -Name "(Default)" -Value "powershell.exe -noexit -command Set-Location '%V'"

# Powershell modules
Install-Module posh-git -Scope CurrentUser
Install-Module oh-my-posh -Scope CurrentUser
