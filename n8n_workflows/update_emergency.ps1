$apiKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI0NTgwOWM2OC1lN2M3LTQ4ZjItYTU0OC04ZGU4MzZhNDAxY2IiLCJpc3MiOiJuOG4iLCJhdWQiOiJwdWJsaWMtYXBpIiwianRpIjoiY2IzNWZhYmYtNmY0MC00ZjJmLWJlN2QtYTUxMGU4M2U5MjAzIiwiaWF0IjoxNzcxNjY5OTAxfQ.4lLLR4DqyzCxA9ncPcShhb6BKBzgQd1kwtU4TbDPKlg"
$baseUrl = "https://n8n.cheosdesign.info/api/v1"
$workflowId = "JpKrZXoGCYaPlKGL"
$headers = @{ "X-N8N-API-KEY" = $apiKey }

# Step 1: Get current workflow
Write-Host ">> Fetching workflow $workflowId..." -ForegroundColor Cyan
$workflow = Invoke-RestMethod -Uri "$baseUrl/workflows/$workflowId" -Headers $headers

# Step 2: Update the Extract Request Data node code
$newJsCode = @'
// ═══════════════════════════════════════════════════════════════
// Extract Request Data - Robust Webhook Extraction
// Handles both root level and nested body/query parameters
// ═══════════════════════════════════════════════════════════════

const headers = $json.headers ?? {};
const query = $json.query ?? {};
const body = $json.body ?? $json ?? {};

const vapiCallId = query.vapi_call_id ?? $json.vapi_call_id ?? headers['x-call-id'] ?? body.vapi_call_id ?? null;
const userId = query.user_id ?? $json.user_id ?? body.user_id ?? null;
const reason = body.reason ?? $json.reason ?? 'Unknown reason';

return [{
  json: {
    vapi_call_id: vapiCallId,
    reason: reason,
    user_id: userId
  }
}];
'@

$updated = $false
foreach ($node in $workflow.nodes) {
    if ($node.name -eq "Extract Request Data") {
        Write-Host ">> Found 'Extract Request Data' node - Updating jsCode..." -ForegroundColor Yellow
        Write-Host "   OLD code starts with: $($node.parameters.jsCode.Substring(0, [Math]::Min(50, $node.parameters.jsCode.Length)))..." -ForegroundColor DarkGray
        $node.parameters.jsCode = $newJsCode
        $updated = $true
        Write-Host "   NEW code starts with: $($newJsCode.Substring(0, 50))..." -ForegroundColor Green
    }
}

if (-not $updated) {
    Write-Host "ERROR: Node 'Extract Request Data' not found!" -ForegroundColor Red
    exit 1
}

# Step 3: Build PUT body with required fields
$cleanSettings = @{
    executionOrder = "v1"
}
$putBody = @{
    name = $workflow.name
    nodes = $workflow.nodes
    connections = $workflow.connections
    settings = $cleanSettings
} | ConvertTo-Json -Depth 15 -Compress

Write-Host ">> Sending PUT to update workflow..." -ForegroundColor Cyan
$result = Invoke-RestMethod -Uri "$baseUrl/workflows/$workflowId" -Method Put -Headers $headers -ContentType "application/json" -Body $putBody

Write-Host ""
Write-Host "=== UPDATE RESULT ===" -ForegroundColor Green
Write-Host "ID:        $($result.id)"
Write-Host "Name:      $($result.name)"
Write-Host "Active:    $($result.active)"
Write-Host "Updated:   $($result.updatedAt)"
Write-Host ""

# Verify the code was updated
foreach ($node in $result.nodes) {
    if ($node.name -eq "Extract Request Data") {
        Write-Host ">> Verified: Extract Request Data code updated successfully!" -ForegroundColor Green
        Write-Host "   Code preview: $($node.parameters.jsCode.Substring(0, [Math]::Min(80, $node.parameters.jsCode.Length)))..." -ForegroundColor DarkGray
    }
}
