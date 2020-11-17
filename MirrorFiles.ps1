[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true)] [string] $Source,
    [Parameter(Mandatory = $true)] [string] $Target
)

# Check input
if (-not (Test-Path $Source -PathType Container) -or -not (Test-Path $Target -PathType Container)) {
    Write-Error -Message "Source and Target need to be existing folders" -ErrorAction Stop
}
if ($Source -like "$Target*" -or $Target -like "$Source*") {
    Write-Error -Message "Source and Target can't be nested paths" -ErrorAction Stop
}

# Copy/Create new/modified files/folders
Get-ChildItem -Path $Source -Recurse | ForEach-Object {
    $sourceFileName = $_.FullName
    $targetFileName = $_.FullName.Replace($Source, $Target)
    if ($_.PSIsContainer) {
        if (-not (Test-Path $targetFileName)) {
            "New folder {0}" -f $targetFileName
            New-Item -Path $targetFileName -ItemType "directory" | Out-Null
        }
    }
    else {
        if (Test-Path $targetFileName) {
            $targetFile = Get-Item -Path $targetFileName
            if ($_.LastWriteTime -ne $targetFile.LastWriteTime -or $_.Length -ne $targetFile.Length) {
                "Modified file {0}" -f $sourceFileName
                Copy-Item -Path $sourceFileName -Destination $targetFileName
            }
        }
        else {
            "New file {0}" -f $sourceFileName
            Copy-Item -Path $sourceFileName -Destination $targetFileName
        }
    }
}

# Remove extra files/folders
Get-ChildItem -Path $Target -Recurse | ForEach-Object {
    if (-not (Test-Path $_.FullName.Replace($Target, $Source))) {
        $type = if ($_.PSIsContainer) { "folder" } else { "file" }
        "Extra {0} {1}" -f $type, $_.FullName
        Remove-Item -Path $_.FullName -Recurse
    }
}
