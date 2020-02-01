# Input bindings are passed in via param block.
param($Timer)

# Specify the VMs that you want to stop. Modify or comment out below based on which VMs to check.
$VMResourceGroupName = "MSReady"
$VMName = "vmmsready"
#$TagName = "AutomaticallyStop"

# Stop on error
$ErrorActionPreference = 'stop'

Write-Information ("Getting VM in resource group " + $VMResourceGroupName + " and VMName " + $VMName)

$VM = Get-AzVM -ResourceGroupName $VMResourceGroupName -Name $VMName -Status

if ($VM.Statuses[1].Code -eq 'PowerState/running')
{
    Write-Information ("Stopping VM " + $VMName)
    Stop-AzVM -ResourceGroupName $VMResourceGroupName -Name $VMName -Force -AsJob
}
else
{
    Write-Information ("The VM name " + $VMName + "is already stopped")
}

# Sleep here a few seconds to make sure that the command gets processed before the script ends
Start-Sleep 60

 Write-Information ("Current status:" + $VM.Statuses[1].DisplayStatus)