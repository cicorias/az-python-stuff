<#
    .DESCRIPTION
        An example runbook which gets all the ARM resources using the Run As Account (Service Principal)

    .NOTES
        AUTHOR: Azure Automation Team
        LASTEDIT: Mar 14, 2016
#>

$connectionName = "AzureRunAsConnection"
try
{
    # Get the connection "AzureRunAsConnection "
    $servicePrincipalConnection=Get-AutomationConnection -Name $connectionName         

    "Logging in to Azure..."
    Add-AzureRmAccount `
        -ServicePrincipal `
        -TenantId $servicePrincipalConnection.TenantId `
        -ApplicationId $servicePrincipalConnection.ApplicationId `
        -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint 
}
catch {
    if (!$servicePrincipalConnection)
    {
        $ErrorMessage = "Connection $connectionName not found."
        throw $ErrorMessage
    } else{
        Write-Error -Message $_.Exception
        throw $_.Exception
    }
}

$allRGs = (Get-AzureRmResourceGroup).ResourceGroupName
Write-Warning "Found $($allRGs | measure | Select -ExpandProperty Count) total RGs"

$aliasedRGs = (Find-AzureRmResourceGroup -Tag @{ "CREATED-BY" = $null }).Name
Write-Warning "Found $($aliasedRGs | measure | Select -ExpandProperty Count) aliased RGs"
  
$notAliasedRGs = $allRGs | ?{-not ($aliasedRGs -contains $_)}
Write-Warning "Found $($notAliasedRGs | measure | Select -ExpandProperty Count) un-tagged RGs"

foreach ($rg in $notAliasedRGs)
{
    $currentTime = Get-Date

    $endTime = $currentTime.AddDays(-1 * $cnt)
    $startTime = $endTime.AddDays(-90)

    Write-Warning "Start: $startTime  to End: $endTime"
        
    $callers = Get-AzureRmLog -ResourceGroup $rg -StartTime $startTime -EndTime $endTime |
        Where {$_.Authorization.Action -eq "Microsoft.Resources/deployments/write"} | 
        Select -ExpandProperty Caller | 
        Group-Object | 
        Sort-Object  | 
        Select -ExpandProperty Name

    if ($callers)
    {
        $owner = $callers | Select-Object -First 1
        $alias = $owner -replace "@microsoft.com",""
            
        $tags = (Get-AzureRmResourceGroup -Name $rg).Tags
        $tags += @{ "CREATED-BY"=$alias }

        $rg + ", " + $alias
        if (-not $dryRun) 
        {
            Set-AzureRmResourceGroup -Name $rg -Tag $tags
        }
    } 
    else 
    {
        $rg + ", Unknown"
    }   
}