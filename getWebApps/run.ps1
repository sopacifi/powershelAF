using namespace System.Net

# Input bindings are passed in via param block.
param($Request)

Function webApps {
    Get-AzWebApp -Location "West Europe"
}

Function Get-webAppHTML {
    # HTML header for a nice look
    $Header = @"
<style>
BODY {font-family:verdana;}
TABLE {border-width: 1px; border-style: solid; border-color: black; border-collapse: collapse;}
TH {border-width: 1px; padding: 3px; border-style: solid; border-color: black; padding: 5px; background-color: #d1c3cd;}
TD {border-width: 1px; padding: 3px; border-style: solid; border-color: black; padding: 5px}
</style>
"@

    # Get Web Apps
    $WebApp = webApps
    $webAppHTML = $WebApp | ConvertTo-Html -property "ResourceGroup", "Name", "State"


    # Combine HTML elements for output
    $Header + "The Following Web Apps and their state <p>" + $webAppHTML

}
$HTML = Get-webAppHTML

Push-OutputBinding -Name Response -Value (@{
        StatusCode  = "ok"
        ContentType = "text/html"
        Body        = $HTML
    })


