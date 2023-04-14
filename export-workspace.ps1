# This script relies on the PowerBI Commandlets being installed: https://learn.microsoft.com/en-us/powershell/power-bi/overview?view=powerbi-ps
# If when exporting, you get an error "A task was cancelled", this will be a timeout condition encountered on the API due to the dataset size! 

# Start of variables

$tenantId = ""
$outputPath = ""
$workspaceId = ""

$clientId = ""
$clientSecret = ""

# End of variables

$clientSecretPlain = ConvertTo-SecureString $clientSecret -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential -ArgumentList ($clientId, $clientSecretPlain)

Connect-PowerBIServiceAccount -ServicePrincipal -TenantId $tenantId -Credential $credential

$reports = Get-PowerBIReport -WorkspaceId $workspaceId -Scope Organization
$dataflows = Get-PowerBIDataflow -WorkspaceId $workspaceId -Scope Organization

foreach ($report in $reports) {
    Write-Host "Exporting $($report.Name)"
    $outFile = $outputPath + "\" + $report.Name + ".pbix"
    # Note: You may find that you need to add -Scope Organization to the following if you get errors; this seems dependant on the version of cmdlets! 
    Export-PowerBIReport -WorkspaceId $workspaceId -Id $report.Id -OutFile $outFile 
}

foreach ($flow in $dataflows) {
    Write-Host "Exporting $($flow.Name)"
    $outFile = $outputPath + "\" + $flow.Name + ".json"
    # Note: You may find that you need to add -Scope Organization to the following if you get errors; this seems dependant on the version of cmdlets! 
    Export-PowerBIDataflow -WorkspaceId $workspaceId -Id $flow.Id -OutFile $outFile
}