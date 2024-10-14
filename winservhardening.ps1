### Hardening and pre-reqs script
##
###
$path = 'c:\bin\'
$Version

Function InstallHardeningKitty() {
    $Version = (((Invoke-WebRequest "https://api.github.com/repos/scipag/HardeningKitty/releases/latest" -UseBasicParsing) | ConvertFrom-Json).Name).SubString(2)
    $HardeningKittyLatestVersionDownloadLink = ((Invoke-WebRequest "https://api.github.com/repos/scipag/HardeningKitty/releases/latest" -UseBasicParsing) | ConvertFrom-Json).zipball_url
    $ProgressPreference = 'SilentlyContinue'
    New-Item -ItemType Directory -Force -Path $path
    Set-Location -Path $path
    Invoke-WebRequest $HardeningKittyLatestVersionDownloadLink -Out HardeningKitty$Version.zip
    Expand-Archive -Path ".\HardeningKitty$Version.zip" -Destination ".\HardeningKitty$Version" -Force
    $Folder = Get-ChildItem .\HardeningKitty$Version | Select-Object Name -ExpandProperty Name
    Move-Item ".\HardeningKitty$Version\$Folder\*" ".\HardeningKitty$Version\"
    Remove-Item ".\HardeningKitty$Version\$Folder\"
    New-Item -Path $Env:ProgramFiles\WindowsPowerShell\Modules\HardeningKitty\$Version -ItemType Directory
    Set-Location .\HardeningKitty$Version
    Copy-Item -Path .\HardeningKitty.psd1,.\HardeningKitty.psm1,.\lists\ -Destination $Env:ProgramFiles\WindowsPowerShell\Modules\HardeningKitty\$Version\ -Recurse
    Import-Module "$Env:ProgramFiles\WindowsPowerShell\Modules\HardeningKitty\$Version\HardeningKitty.psm1"
}
InstallHardeningKitty

### Backing up initial config state prior to hardening
Invoke-HardeningKitty -Mode Config -Report -ReportFile C:\bin\$env:COMPUTERNAME-$(get-date -format ddmmyy)-initialstate-hardening_report.csv
## Running CIS Windows Server User Settings
Invoke-HardeningKitty -Mode HailMary -FileFindingList "$Env:ProgramFiles\WindowsPowerShell\Modules\HardeningKitty\$Version\lists\finding_list_cis_microsoft_windows_server_2022_22h2_2.0.0_machine.csv" -SkipRestorePoint
C:\Program Files\WindowsPowerShell\Modules\HardeningKitty\0.9.2\lists
## Running CIS Windows Server Computer Settings
Invoke-HardeningKitty -Mode HailMary -FileFindingList "$Env:ProgramFiles\WindowsPowerShell\Modules\HardeningKitty\$Version\lists\finding_list_cis_microsoft_windows_server_2022_22h2_2.0.0_user.csv" -SkipRestorePoint

restart-computer
