$EXIT_SUCCESS = 0
$EXIT_FAILURE = 1

#Generic function to gracefully exit dRMM PowerShell script
#@param exitcode: mandatory, code to exit with; 0=success, 1=failure
#@param results: string or integer to pass back to dRMM for results of script
#@param diagnostics: additional information to pass back to dRMM for results of script
function Exit-dRMMScript {
    [cmdletbinding()]
    Param([Parameter(Mandatory=$true)]$exitcode, $results, $diagnostics)

    #Output results
    Write-Output "<-Start Result->"
    Write-Output "Result=$results"
    Write-Output "<-End Result->"

    #Output diagnostics, if they exist
    if (!($null -eq $diagnostics)) {
        Write-Output "<-Start Diagnostics->"
        Write-Output "Result=$diagnostics"
        Write-Output "<-End Result->"
    }

    exit $exitcode

} #End function

$exit = $EXIT_SUCCESS
$results = ""
$ERRORS = @()

# We need to do error checking in case we don't have access to a user directory

(Get-ChildItem -Path "C:\Users\"  -ErrorAction SilentlyContinue -ErrorVariable +ERRORS ) | foreach {

    $folder = $_
    $file = "C:\Users\$folder\Appdata\Local\CentraStage\rdp_cred_store.xml"
    Write-Host "Looking for $file"

    If (test-path -path "C:\Users\$folder\Appdata\Local\CentraStage\rdp_cred_store.xml" -PathType leaf -ErrorAction SilentlyContinue -ErrorVariable +ERRORS) {
        
        # Try to remove it
        try {
            Remove-Item $file -ErrorVariable +ERRORS
            $results = $results + "We deleted $file"
        } catch {
            # If we can't delete the file throw an error
            $ERRORS[$ERRORS.length+1] = "Unable to remove file $file"
            $exit = $EXIT_FAILURE
        }
    }
}

foreach ($error in $ERRORS) {
    $results = $results + "We ran into some errors "
    $results = $results + " $ERROR"
    $exit = $EXIT_FAILURE
}

write-host $ERRORS|format-table

Exit-dRMMScript -exitcode $exit -results $results