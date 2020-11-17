$source = "C:\Temp\A"
$target = "C:\Temp\B"

$sourceFiles = Get-ChildItem -Path $source -Recurse
$targetFiles = Get-ChildItem -Path $target -Recurse

$syncMode = 1

try {
    $diff = Compare-Object -ReferenceObject $sourceFiles -DifferenceObject $targetFiles

    foreach ($f in $diff) {
        if ($f.SideIndicator -eq "<=") {
            $fullSourceObject = $f.InputObject.FullName
            $fullTargetObject = $f.InputObject.FullName.Replace($source, $target)

            Write-Host "Attemp to copy the following: " $fullSourceObject
            Copy-Item -Path $fullSourceObject -Destination $fullTargetObject
        }


        if ($f.SideIndicator -eq "=>" -and $syncMode -eq 2) {
            $fullSourceObject = $f.InputObject.FullName
            $fullTargetObject = $f.InputObject.FullName.Replace($target, $source)

            Write-Host "Attemp to copy the following: " $fullSourceObject
            Copy-Item -Path $fullSourceObject -Destination $fullTargetObject
        }

    }
}
catch {
    Write-Error -Message "something bad happened!" -ErrorAction Stop
}
