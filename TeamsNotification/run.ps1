param($eventGridEvent, $TriggerMetadata)

write-output "## Function trigger ##"
# Declarations
# Set the default error action
$errorActionDefault = $ErrorActionPreference

# Channel Webhook.
$ChannelURL = "https://outlook.office.com/webhook/1a02cda8-4623-4a19-8a5b-bbc930a33a28@72f988bf-86f1-41af-91ab-2d7cd011db47/IncomingWebhook/861fa18b03d246828a304e061de07720/25c740e6-f16e-48cf-92c5-e066699fce01"

# Get the subscription
try {
    $ErrorActionPreference = 'stop'
    $SubscriptionId = $eventGridEvent.data.subscriptionId
}
catch {
    $ErrorMessage = $_.Exception.message
    write-error ('Error getting Subscription ID ' + $ErrorMessage)
    Break
}
Finally {
    $ErrorActionPreference = $errorActionDefault
}

if ($eventGridEvent.data.authorization.action -like "Microsoft.Resources/subscriptions/resourceGroups/write" ) {
    $ActivityType = "Resource Group"
    write-output "## New Resource Group ##"
    $image = "https://msftplayground.com/wp-content/uploads/2016/08/arm.png"

    # Get Resource Group
    try {
        $ErrorActionPreference = 'stop'
        $subjectSplit = $eventGridEvent.subject -split '/'
        $typeName = $subjectSplit[4]
    }
    catch {
        $ErrorMessage = $_.Exception.message
        write-error ('Error getting Resource Group name ' + $ErrorMessage)
        Break
    }
    Finally {
        $ErrorActionPreference = $errorActionDefault
    }
}
else {
    write-error 'No activity type defined in script.  Verfiy Event Grid Filter matches IF statement'
    Break
}

# Send Data to Teams
# Build the message body
$TargetURL = "https://portal.azure.com/#resource" + $eventGridEvent.data.resourceUri + "/overview"   
try {    
    $Body = ConvertTo-Json -ErrorAction Stop -Depth 4 @{
        title           = 'Azure Resource Creation Notification From Azure Functions' 
        text            = 'A new Azure ' + $activityType + ' has been created'
        sections        = @(
            @{
                activityTitle    = 'New Azure ' + $ActivityType
                activitySubtitle = 'Azure ' + $ActivityType + ' named ' + $typeName + ' has been created.'
                activityText     = 'An Azure ' + $ActivityType + ' was created in the subscription ' + $SubscriptionId + ' by ' + $eventGridEvent.data.claims.name
                activityImage    = $image
            }
        )
        potentialAction = @(@{
                '@context' = 'http://schema.org'
                '@type'    = 'ViewAction'
                name       = 'Click here to manage the Resource Group'
                target     = @($TargetURL)
            })
    }
}
catch {
    $ErrorMessage = $_.Exception.message
    write-error ('Error converting body to JSON ' + $ErrorMessage)
    Break
}
           
# call Teams webhook
try {
    write-output '## Calls to teams ##'
    Invoke-RestMethod -Method "Post" -Uri $ChannelURL -Body $Body | Write-output
}
catch {
    $ErrorMessage = $_.Exception.message
    write-error ('Error with invoke-restmethod ' + $ErrorMessage)
    Break
}
