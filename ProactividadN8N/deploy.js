const fs = require('fs');

const n8nUrl = process.env.N8N_API_URL || 'https://n8n.cheosdesign.info/api/v1';
const apiKey = process.env.N8N_API_KEY || 'n8n_api_8dc72365942468cf5b2ff36bf09964b73b22abdafb85f62ed9b207df3cf090d81069f52f36fecf54dfcf8f0f48866579';

async function deploy(file) {
  try {
    const data = JSON.parse(fs.readFileSync(file, 'utf8'));
    const id = data.id;
    console.log(`Deploying ${file} (ID: ${id}) to ${n8nUrl}/workflows/${id}`);
    
    const resp = await fetch(`${n8nUrl}/workflows/${id}`, {
      method: 'PUT',
      headers: {
        'Content-Type': 'application/json',
        'X-N8N-API-KEY': apiKey
      },
      body: JSON.stringify({
        nodes: data.nodes,
        connections: data.connections,
        name: data.name,
        settings: data.settings
      })
    });
    
    const text = await resp.text();
    if (resp.ok) {
      console.log(`✅ Success for ${file}`);
    } else {
      console.error(`❌ Failed for ${file}:`, resp.status, text);
    }
  } catch (err) {
    console.error(`Error deploying ${file}:`, err.message);
  }
}

async function main() {
  await deploy('mood-insights-patched.json');
  await deploy('daily-checkin-patched.json');
  await deploy('smart-nudge-patched.json');
}

main().catch(console.error);
