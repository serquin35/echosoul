const fs = require('fs');

const moodInsightsStr = fs.readFileSync('C:/Users/Serquin/.gemini/antigravity/brain/c0bf7261-2251-4799-88c9-24bbd90c53d0/.system_generated/steps/204/output.txt', 'utf8');
const dailyCheckinStr = fs.readFileSync('C:/Users/Serquin/.gemini/antigravity/brain/c0bf7261-2251-4799-88c9-24bbd90c53d0/.system_generated/steps/217/output.txt', 'utf8');
const smartNudgeStr = fs.readFileSync('C:/Users/Serquin/.gemini/antigravity/brain/c0bf7261-2251-4799-88c9-24bbd90c53d0/.system_generated/steps/220/output.txt', 'utf8');

function extractWorkflow(outputStr) {
  const jsonStr = outputStr.replace(/^.*?{/s, '{');
  return JSON.parse(jsonStr).data;
}

const mood = extractWorkflow(moodInsightsStr);
const daily = extractWorkflow(dailyCheckinStr);
const nudge = extractWorkflow(smartNudgeStr);

function patchWorkflow(workflow) {
  workflow.active = true;
  for (const node of workflow.nodes) {
    // Supabase
    if (node.name.startsWith('Fetch ') || node.name.startsWith('Log ') || node.name === 'Fetch active users' || node.name === 'Fetch checkins for today' || node.name === 'Fetch all users' || node.name === 'Fetch recent history' || node.name === 'Log nudge checkin') {
      if (node.parameters && node.parameters.headerParameters && node.parameters.headerParameters.parameters) {
        node.parameters.headerParameters.parameters.forEach(p => {
          if (p.name === 'apikey' || p.name === 'Authorization') {
            p.value = p.value.replace('EchoSoulSupabase', 'EchoSoul-supabase');
          }
        });
      }
    }
    
    // Anthropic to OpenAI
    if (node.name.startsWith('Generate ')) {
      if (node.parameters.url && node.parameters.url.includes('anthropic')) {
        node.parameters.url = 'https://api.openai.com/v1/chat/completions';
        node.parameters.authentication = 'predefinedCredentialType';
        node.parameters.nodeCredentialType = 'openAiApi';
        node.credentials = {
          openAiApi: {
            id: 'KzFxOuQEjV23LyRC',
            name: 'OpenAi account'
          }
        };
        // Remove Anthropic headers
        node.parameters.headerParameters = { parameters: [] };
        // Change body
        node.parameters.body = "={{ JSON.stringify({model:'gpt-4o-mini',messages:[{role:'system',content:$json.systemPrompt},{role:'user',content:'Genera el mensaje de apoyo ahora.'}]}) }}";
      }
    }

    // FCM
    if (node.name.startsWith('Send FCM ')) {
      // Use Firebase EchoSoul Admin (googleApi)
      node.parameters.authentication = 'predefinedCredentialType';
      node.parameters.nodeCredentialType = 'googleApi';
      node.credentials = {
        googleApi: {
          id: '0o4FmPorago01fiu',
          name: 'Firebase EchoSoul Admin'
        }
      };
      node.parameters.url = 'https://fcm.googleapis.com/v1/projects/echosoul-one/messages:send';
      node.parameters.headerParameters = { parameters: [] };
      
      // Update body format for v1
      if (node.parameters.body.includes('body:$json.generated_message')) {
        const type = node.name.includes('insight') ? 'mood_insight' : (node.name.includes('nudge') ? 'smart_nudge' : 'daily_checkin');
        node.parameters.body = "={{ JSON.stringify({message:{token:$json.fcm_token,notification:{title:'EchoSoul 💙',body:$json.generated_message},data:{type:'"+type+"'}}}) }}";
      }
    }
    
    // Gmail
    if (node.type === 'n8n-nodes-base.gmail') {
      node.credentials = {
        gmailOAuth2: {
          id: 'XI4mlfkFZGAD9dyL',
          name: 'Gmail account'
        }
      };
    }
  }
  return workflow;
}

fs.writeFileSync('mood-insights-patched.json', JSON.stringify(patchWorkflow(mood), null, 2));
fs.writeFileSync('daily-checkin-patched.json', JSON.stringify(patchWorkflow(daily), null, 2));
fs.writeFileSync('smart-nudge-patched.json', JSON.stringify(patchWorkflow(nudge), null, 2));
console.log('Workflows patched locally.');
