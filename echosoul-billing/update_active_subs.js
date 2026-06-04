const n8nUrl = 'https://n8n.cheosdesign.info/api/v1';
const apiKey = 'n8n_api_8dc72365942468cf5b2ff36bf09964b73b22abdafb85f62ed9b207df3cf090d81069f52f36fecf54dfcf8f0f48866579';

async function main() {
  const workflowId = 'i85kREsb3jPIAoHw';
  
  // 1. Fetch workflow
  console.log(`Fetching workflow ${workflowId}...`);
  const getResp = await fetch(`${n8nUrl}/workflows/${workflowId}`, {
    headers: { 'X-N8N-API-KEY': apiKey }
  });
  if (!getResp.ok) {
    throw new Error(`Failed to fetch workflow: ${getResp.status} ${await getResp.text()}`);
  }
  const wf = await getResp.json();
  
  // 2. Modify "Fetch Lemon Squeezy active subs" node
  const nodes = wf.nodes;
  const lsNode = nodes.find(n => n.name === 'Fetch Lemon Squeezy active subs' || n.id === '8865a3ac-1699-468b-8a71-5242b6150c45');
  if (!lsNode) {
    throw new Error('Could not find node Fetch Lemon Squeezy active subs');
  }
  
  console.log('Modifying node properties...');
  // Set authentication to none and delete credentials block
  lsNode.parameters.authentication = 'none';
  delete lsNode.credentials;
  if (lsNode.parameters.genericAuthType) {
    delete lsNode.parameters.genericAuthType;
  }
  
  // Ensure the header parameter for Authorization is Bearer YOUR_LEMONSQUEEZY_API_KEY
  if (!lsNode.parameters.headerParameters) {
    lsNode.parameters.headerParameters = { parameters: [] };
  }
  
  const headers = lsNode.parameters.headerParameters.parameters || [];
  const authHeader = headers.find(h => h.name.toLowerCase() === 'authorization');
  if (authHeader) {
    authHeader.value = 'Bearer YOUR_LEMONSQUEEZY_API_KEY';
  } else {
    headers.push({ name: 'Authorization', value: 'Bearer YOUR_LEMONSQUEEZY_API_KEY' });
  }
  
  // 3. Put workflow back
  console.log(`Updating workflow ${workflowId}...`);
  const putResp = await fetch(`${n8nUrl}/workflows/${workflowId}`, {
    method: 'PUT',
    headers: {
      'Content-Type': 'application/json',
      'X-N8N-API-KEY': apiKey
    },
    body: JSON.stringify({
      nodes: wf.nodes,
      connections: wf.connections,
      name: wf.name,
      settings: wf.settings
    })
  });
  
  const resultText = await putResp.text();
  if (putResp.ok) {
    console.log('✅ Workflow successfully updated!');
  } else {
    console.error(`❌ Failed to update workflow: ${putResp.status} ${resultText}`);
  }
}

main().catch(console.error);
