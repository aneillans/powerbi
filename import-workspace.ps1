# This script relies on the PowerBI Commandlets being installed: https://learn.microsoft.com/en-us/powershell/power-bi/overview?view=powerbi-ps
# You also need to install a copy of azcopy.exe to use this script! https://learn.microsoft.com/en-us/azure/storage/common/storage-use-azcopy-v10#download-azcopy

# Start of variables

$tenantId = ""
$sourcePath = ""
$workspaceId = ""

$clientId = ""
$clientSecret = ""

$azCopyPath = "" # Must include azcopy.exe in the path!

# End of variables

$clientSecretPlain = ConvertTo-SecureString $clientSecret -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential -ArgumentList ($clientId, $clientSecretPlain)

Connect-PowerBIServiceAccount -ServicePrincipal -TenantId $tenantId -Credential $credential

# Note: This will fail on importing where a dataset / report / dataflow already exists with the same name!
# It's really crude, and there's no checking completed here.

$token = Get-PowerBIAccessToken

$tempUploadLocation = "https://api.powerbi.com/v1.0/groups/$workspaceId/imports/createTemporaryUploadLocation"

foreach ($report in Get-ChildItem -Path $sourcePath -Filter "*.pbix" -File) {
    $uploadUri = Invoke-RestMethod -Uri $tempUploadLocation -Method Post -Headers $token
    $tempUploadUrl = $uploadUri.url

    $fileFullPath = $sourcePath + "\" + $report
    $importUri = "https://api.powerbi.com/v1.0/myorg/groups/$workspaceId/imports?datasetDisplayName&nameConflict=Overwrite"

    & $azCopyPath copy "$fileFullPath" "$tempUploadUrl" --recursive=true --check-length=false

    $bodyPost = @{ 
        "fileUrl" = "$tempUploadUrl"
    }

    $bodyJson = ConvertTo-Json -InputObject $bodyPost

    Invoke-PowerBIRestMethod -Method Post -Url $importUri -Body $bodyJson -ContentType "application/json"
} 

foreach ($dataFlow in Get-ChildItem -Path $sourcePath -Filter "*.json" -File) {
    $uploadUri = Invoke-RestMethod -Uri $tempUploadLocation -Method Post -Headers $token
    $tempUploadUrl = $uploadUri.url

    # To be written
} 