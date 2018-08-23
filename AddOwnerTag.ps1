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
Write-Output "Found $($allRGs | Measure-Object | Select-Object -ExpandProperty Count) total RGs"

$notAliasedRGs = (Get-AzureRmResourceGroup -Tag @{ 'owner' = $null }).ResourceGroupName
Write-Output "Found $($aliasedRGs | Measure-Object | Select-Object -ExpandProperty Count) aliased RGs"
  
$aliasedRGs = $allRGs | Where-Object {-not ($aliasedRGs -contains $_)}
Write-Output "Found $($notAliasedRGs | Measure-Object | Select-Object -ExpandProperty Count) un-tagged RGs"

foreach ($rg in $notAliasedRGs)
{
    $currentTime = Get-Date

    $endTime = $currentTime.AddDays(-1 * $cnt)
    $startTime = $endTime.AddDays(-90)

    Write-Output "Start: $startTime  to End: $endTime"
        
    $callers = Get-AzureRmLog -ResourceGroup $rg -StartTime $startTime -EndTime $endTime |
        #Where {$_.Authorization.Action -eq "Microsoft.Resources/deployments/write"} |
        Where-Object {$_.Authorization.Action -eq "Microsoft.Resources/deployments/write"} |
        Select-Object -ExpandProperty Caller | 
        Group-Object | 
        Sort-Object  | 
        Select-Object -ExpandProperty Name

    if ($callers)
    {
        $owner = $callers | Select-Object -First 1
        $alias = $owner -replace "@microsoft.com",""
            
        $tags = (Get-AzureRmResourceGroup -Name $rg).Tags
        try {
            $tags += @{ "owner"=$alias }
        }
        catch {
            Write-Output $_.Exception.Message + " for user $alias or owner $owner"
        }

        $rg + ", " + $alias
        if (-not $dryRun) 
        {
            try {
                Set-AzureRmResourceGroup -Name $rg -Tag $tags -ErrorAction Continue
            }
            catch {
                Write-Output $_.Exception.Message + "NO TAG update for user $alias or owner $owner"
            }
        }
    } 
    else 
    {
        $rg + ", Unknown"
    }   
}