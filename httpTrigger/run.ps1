using namespace System.Net
param($Request, $TriggerMetadata)
$body = html -Content {
    head -Content {
        Title -Content "Microsoft App Service Employees"
        Link -href 'https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/css/bootstrap.min.css' -rel stylesheet
        script -src 'https://code.jquery.com/jquery-3.2.1.slim.min.js'
        script -src 'https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.12.9/umd/popper.min.js'
        script -src 'https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/js/bootstrap.min.js'
    }
    Body -Content {
        Div -Class 'container' -Content {
            Div -Class 'jumbotron' -Content {
                H1 -Class 'display-4' -Content "Microsoft App Service Employees"
            }
        }
        
        Div -Class 'container' -Content {
            $employees = Get-Content .\database\employees.json | ConvertFrom-Json
            Table -class 'table' -Content {
                Thead -Content {
                    Th -Content "First Name"
                    Th -Content "Last Name"
                    Th -Content "Team"
                }
                Tbody -Content {
                    foreach ($employee in $employees.employees)
                    {
                        tr -Content {
                            td -Content $employee.firstname
                            td -Content $employee.lastname
                            td -Content $employee.team
                        }
                    }
                }
            }
        }
    }
}
# Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
        headers    = @{'content-type' = 'text/html' }
        StatusCode = [httpstatuscode]::OK
        Body       = $body
    })