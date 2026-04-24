param(
  [switch]$DryRun
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Read-JsonFile {
  param(
    [Parameter(Mandatory = $true)]
    [string]$Path
  )

  if (-not (Test-Path -LiteralPath $Path)) {
    throw "Config file not found: $Path"
  }

  try {
    return (Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json)
  }
  catch {
    throw "Failed to parse JSON: $Path`n$($_.Exception.Message)"
  }
}

function Backup-And-WriteJsonFile {
  param(
    [Parameter(Mandatory = $true)]
    [string]$Path,

    [Parameter(Mandatory = $true)]
    [object]$Data,

    [Parameter(Mandatory = $true)]
    [bool]$ShouldWrite
  )

  $backupPath = "$Path.bak"
  if ($ShouldWrite) {
    Copy-Item -LiteralPath $Path -Destination $backupPath -Force
    $json = $Data | ConvertTo-Json -Depth 100
    Set-Content -LiteralPath $Path -Value $json -Encoding utf8
  }

  return $backupPath
}

function Ensure-NoteProperty {
  param(
    [Parameter(Mandatory = $true)]
    [object]$Object,

    [Parameter(Mandatory = $true)]
    [string]$Name,

    [Parameter(Mandatory = $true)]
    [object]$Value
  )

  if (-not ($Object.PSObject.Properties.Name -contains $Name)) {
    $Object | Add-Member -NotePropertyName $Name -NotePropertyValue $Value
  }
}

function Ensure-ObjectProperty {
  param(
    [Parameter(Mandatory = $true)]
    [object]$Object,

    [Parameter(Mandatory = $true)]
    [string]$Name
  )

  if (-not ($Object.PSObject.Properties.Name -contains $Name) -or $null -eq $Object.$Name) {
    $Object | Add-Member -NotePropertyName $Name -NotePropertyValue ([pscustomobject]@{}) -Force
  }

  return $Object.$Name
}

function Ensure-ArrayListProperty {
  param(
    [Parameter(Mandatory = $true)]
    [object]$Object,

    [Parameter(Mandatory = $true)]
    [string]$Name
  )

  $list = [System.Collections.ArrayList]@()

  if ($Object.PSObject.Properties.Name -contains $Name -and $null -ne $Object.$Name) {
    foreach ($item in $Object.$Name) {
      [void]$list.Add($item)
    }
  }

  $Object | Add-Member -NotePropertyName $Name -NotePropertyValue $list -Force
  return $Object.$Name
}

function Ensure-StringArrayContains {
  param(
    [Parameter(Mandatory = $true)]
    [System.Collections.ArrayList]$List,

    [Parameter(Mandatory = $true)]
    [string]$Value
  )

  if (-not ($List -contains $Value)) {
    [void]$List.Add($Value)
    return $true
  }

  return $false
}

function Add-ReportLine {
  param(
    [Parameter(Mandatory = $true)]
    [AllowEmptyCollection()]
    [System.Collections.ArrayList]$Report,

    [Parameter(Mandatory = $true)]
    [string]$Text
  )

  [void]$Report.Add($Text)
}

$report = [System.Collections.ArrayList]@()
$configRoot = Join-Path $HOME '.config\opencode'
$opencodePath = Join-Path $configRoot 'opencode.json'
$omoPath = Join-Path $configRoot 'oh-my-openagent.json'

Write-Output ('frontend-image-composition setup starting' + $(if ($DryRun) { ' (dry-run)' } else { '' }))

$opencode = Read-JsonFile -Path $opencodePath
$pluginList = Ensure-ArrayListProperty -Object $opencode -Name 'plugin'

if (Ensure-StringArrayContains -List $pluginList -Value 'oh-my-openagent') {
  Add-ReportLine -Report $report -Text 'Added plugin: oh-my-openagent'
}

if (Ensure-StringArrayContains -List $pluginList -Value './plugins/image-generator/index.js') {
  Add-ReportLine -Report $report -Text 'Added plugin: ./plugins/image-generator/index.js'
}

$opencodeBackup = Backup-And-WriteJsonFile -Path $opencodePath -Data $opencode -ShouldWrite (-not $DryRun)

$omo = Read-JsonFile -Path $omoPath
$agents = Ensure-ObjectProperty -Object $omo -Name 'agents'
$categories = Ensure-ObjectProperty -Object $omo -Name 'categories'

$imageGeneratorAgent = Ensure-ObjectProperty -Object $agents -Name 'image-generator'
$imageGenerationCategory = Ensure-ObjectProperty -Object $categories -Name 'image-generation'
$generalAgent = Ensure-ObjectProperty -Object $agents -Name 'general'

if ($imageGeneratorAgent.model -ne 'skills/gpt-image-2') {
  $imageGeneratorAgent | Add-Member -NotePropertyName model -NotePropertyValue 'skills/gpt-image-2' -Force
  Add-ReportLine -Report $report -Text 'Set agents.image-generator.model = skills/gpt-image-2'
}

if ($imageGeneratorAgent.variant -ne 'instant') {
  $imageGeneratorAgent | Add-Member -NotePropertyName variant -NotePropertyValue 'instant' -Force
  Add-ReportLine -Report $report -Text 'Set agents.image-generator.variant = instant'
}

if ($imageGenerationCategory.model -ne 'skills/gpt-image-2') {
  $imageGenerationCategory | Add-Member -NotePropertyName model -NotePropertyValue 'skills/gpt-image-2' -Force
  Add-ReportLine -Report $report -Text 'Set categories.image-generation.model = skills/gpt-image-2'
}

if ($imageGenerationCategory.variant -ne 'instant') {
  $imageGenerationCategory | Add-Member -NotePropertyName variant -NotePropertyValue 'instant' -Force
  Add-ReportLine -Report $report -Text 'Set categories.image-generation.variant = instant'
}

if ($generalAgent.PSObject.Properties.Name -contains 'fallback_models') {
  $generalAgent.PSObject.Properties.Remove('fallback_models')
  Add-ReportLine -Report $report -Text 'Removed agents.general.fallback_models to avoid routing gpt-image-2 through chat flow'
}

$omoBackup = Backup-And-WriteJsonFile -Path $omoPath -Data $omo -ShouldWrite (-not $DryRun)

if ($report.Count -eq 0) {
  Add-ReportLine -Report $report -Text 'No changes were needed. Configuration already matched the expected setup.'
}

Write-Output ''
Write-Output 'Repair summary:'
foreach ($line in $report) {
  Write-Output ("- $line")
}

Write-Output ''
if ($DryRun) {
  Write-Output 'Dry-run mode: no files were written.'
} else {
  Write-Output "Updated: $opencodePath"
  Write-Output "Backup:  $opencodeBackup"
  Write-Output "Updated: $omoPath"
  Write-Output "Backup:  $omoBackup"
}

Write-Output ''
Write-Output 'Expected image generation path:'
Write-Output '- Read current provider baseURL + apiKey'
Write-Output '- POST {baseURL}/images/generations'
Write-Output '- model = gpt-image-2'
Write-Output '- Do not route image generation through chat/completions'
