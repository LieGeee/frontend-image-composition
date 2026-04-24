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

  return (Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json)
}

function Write-JsonFile {
  param(
    [Parameter(Mandatory = $true)]
    [string]$Path,

    [Parameter(Mandatory = $true)]
    [object]$Data
  )

  $backupPath = "$Path.bak"
  Copy-Item -LiteralPath $Path -Destination $backupPath -Force
  $json = $Data | ConvertTo-Json -Depth 100
  Set-Content -LiteralPath $Path -Value $json -Encoding utf8
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
  }
}

$configRoot = Join-Path $HOME '.config\opencode'
$opencodePath = Join-Path $configRoot 'opencode.json'
$omoPath = Join-Path $configRoot 'oh-my-openagent.json'

$opencode = Read-JsonFile -Path $opencodePath

if ($null -eq $opencode.plugin) {
  $opencode | Add-Member -NotePropertyName plugin -NotePropertyValue ([System.Collections.ArrayList]@())
}

$pluginList = [System.Collections.ArrayList]@()
foreach ($item in $opencode.plugin) {
  [void]$pluginList.Add($item)
}

Ensure-StringArrayContains -List $pluginList -Value 'oh-my-openagent'
Ensure-StringArrayContains -List $pluginList -Value './plugins/image-generator/index.js'

$opencode.plugin = $pluginList
Write-JsonFile -Path $opencodePath -Data $opencode

$omo = Read-JsonFile -Path $omoPath

if ($null -eq $omo.agents.'image-generator') {
  throw 'Missing agents.image-generator in oh-my-openagent.json'
}

if ($null -eq $omo.categories.'image-generation') {
  throw 'Missing categories.image-generation in oh-my-openagent.json'
}

$omo.agents.'image-generator'.model = 'skills/gpt-image-2'
$omo.agents.'image-generator'.variant = 'instant'

$omo.categories.'image-generation'.model = 'skills/gpt-image-2'
$omo.categories.'image-generation'.variant = 'instant'

if ($null -ne $omo.agents.general -and $omo.agents.general.PSObject.Properties.Name -contains 'fallback_models') {
  $omo.agents.general.PSObject.Properties.Remove('fallback_models')
}

Write-JsonFile -Path $omoPath -Data $omo

Write-Output 'frontend-image-composition setup complete.'
Write-Output "Updated: $opencodePath"
Write-Output "Updated: $omoPath"
Write-Output 'Expected image generation path: POST {baseURL}/images/generations with model gpt-image-2'
