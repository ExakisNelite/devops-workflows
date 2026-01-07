param(
    [Parameter(Mandatory = $true)]
    [string]$GitHubWorkspace,

    [Parameter(Mandatory = $true)]
    [string]$ReleaseNoteFilePath,

    [Parameter(Mandatory = $true)]
    [string]$ReleaseNumber,

    [Parameter(Mandatory = $true)]
    [string]$ConfluenceParentPageId,

    [Parameter(Mandatory = $false)]
    [string]$ConfluenceMapPath = "confluence-map.yml"
)

function Add-ReleaseNoteToConfluenceMap {
    param(
        [string]$confluenceMapFullPath,
        [string]$releaseNoteRelativePath,
        [string]$releaseNumber,
        [string]$confluenceParentPageId
    )

    try {
        # Check if confluence-map.yml exists
        if (-not (Test-Path $confluenceMapFullPath)) {
            Write-Error "❌ confluence-map.yml file not found at: $confluenceMapFullPath"
            return $false
        }

        # Read the current content
        $content = Get-Content $confluenceMapFullPath -Raw
        Write-Host "✅ confluence-map.yml found and loaded"

        # Convert relative path to use forward slashes for YAML
        $releaseNoteRelativePath = $releaseNoteRelativePath -replace '\\', '/'

        # Create the new entry
        $newEntry = @"
  - source: $releaseNoteRelativePath
    title: "Release Note - $releaseNumber"
    parent:
      # Use one of the following parent selectors
      id: $confluenceParentPageId
    labels: ["release-note", "auto-generated"]
    # If true, will create or update idempotently
    upsert: true
"@

        # Check if this release note entry already exists
        $entryPattern = "source:\s*$([regex]::Escape($releaseNoteRelativePath))"
        if ($content -match $entryPattern) {
            Write-Host "⚠️ Release note entry for $releaseNoteRelativePath already exists in confluence-map.yml"
            return $confluenceMapFullPath
        }

        # Find the pages: section and add the new entry
        if ($content -match "pages:\s*\r?\n") {
            # Look for existing entries or add after pages:
            if ($content -match "pages:\s*\r?\n(\s*#.*\r?\n)*(\s*-\s)") {
                # There are existing entries, add before the first one
                $content = $content -replace "(pages:\s*\r?\n)", "`$1$newEntry`r`n"
            }
            else {
                # No existing entries, add after pages:
                $content = $content -replace "(pages:\s*\r?\n)", "`$1$newEntry`r`n"
            }
        }
        else {
            Write-Error "❌ Could not find 'pages:' section in confluence-map.yml"
            return $false
        }

        # Write the updated content back to the file
        Set-Content -Path $confluenceMapFullPath -Value $content -NoNewline
        Write-Host "✅ Release note entry added to confluence-map.yml"
        
        return $confluenceMapFullPath
    }
    catch {
        Write-Error "❌ Error updating confluence-map.yml: $($_.Exception.Message)"
        return $false
    }
}

try {
    # Build the full path to confluence-map.yml
    $confluenceMapFullPath = Join-Path $GitHubWorkspace $ConfluenceMapPath
    
    # Convert the absolute release note path to relative path from workspace
    $releaseNoteRelativePath = $ReleaseNoteFilePath -replace [regex]::Escape("$GitHubWorkspace/"), ""
    $releaseNoteRelativePath = $releaseNoteRelativePath -replace [regex]::Escape("$GitHubWorkspace\"), ""
    
    Write-Host "📝 Adding release note to confluence-map.yml"
    Write-Host "   Workspace: $GitHubWorkspace"
    Write-Host "   Confluence Map: $confluenceMapFullPath"
    Write-Host "   Release Note File: $releaseNoteRelativePath"
    Write-Host "   Release Number: $ReleaseNumber"

    # Add the release note entry
    $result = Add-ReleaseNoteToConfluenceMap -confluenceMapFullPath $confluenceMapFullPath -releaseNoteRelativePath $releaseNoteRelativePath -releaseNumber $ReleaseNumber -confluenceParentPageId $ConfluenceParentPageId

    if ($result) {
        Write-Host "✅ confluence-map.yml updated successfully"
        Write-Output $result
    }
    else {
        Write-Error "❌ Failed to update confluence-map.yml"
        exit 1
    }
}
catch {
    Write-Error "❌ Error in script execution: $($_.Exception.Message)"
    exit 1
}