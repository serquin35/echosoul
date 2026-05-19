import json
import glob
import os

def migrate_anthropic_to_openai(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    modified = False
    for node in data.get('nodes', []):
        if node['type'] == 'n8n-nodes-base.httpRequest':
            params = node.get('parameters', {})
            url = params.get('url', '')
            if 'api.anthropic.com' in str(url):
                # Update URL
                params['url'] = 'https://api.openai.com/v1/chat/completions'
                
                # Update Headers
                if 'headerParameters' in params and 'parameters' in params['headerParameters']:
                    params['headerParameters']['parameters'] = [
                        {
                            "name": "Authorization",
                            "value": "Bearer {{ $credentials.EchoSoulOpenAI.value }}"
                        },
                        {
                            "name": "Content-Type",
                            "value": "application/json"
                        }
                    ]
                
                # Update Body
                body = params.get('body', '')
                if 'claude-sonnet' in body or 'model' in body:
                    # Very simple string replace or regex
                    # The body is something like:
                    # ={{ JSON.stringify({model:'claude-sonnet-4-20250514',max_tokens:300,system:$json.systemPrompt,messages:[{role:'user',content:'Genera el mensaje de apoyo ahora.'}]}) }}
                    import re
                    # Extract system prompt variable
                    m = re.search(r"system:([^,]+),", body)
                    sys_prompt = m.group(1) if m else "'Eres un asistente'"
                    body = re.sub(r"system:[^,]+,", r"", body)
                    # We need to prepend the system message to messages array
                    # Find messages:[
                    body = re.sub(r"messages:\[", f"messages:[{{role:'system',content:{sys_prompt}}},", body)
                    body = re.sub(r"model:'[^']+'", "model:'gpt-4o-mini'", body)
                    params['body'] = body
                    
                node['parameters'] = params
                modified = True
                print(f"Updated HTTP Request node '{node['name']}' in {filepath}")
                
        if node['type'] == 'n8n-nodes-base.code':
            code = node.get('parameters', {}).get('jsCode', '')
            if 'prev.content?.[0]?.text' in code:
                code = code.replace('prev.content?.[0]?.text', 'prev.choices?.[0]?.message?.content')
                node['parameters']['jsCode'] = code
                modified = True
                print(f"Updated Code node '{node['name']}' in {filepath}")

    if modified:
        with open(filepath, 'w', encoding='utf-8') as f:
            json.dump(data, f, indent=2, ensure_ascii=False)
        print(f"Saved {filepath}")

# Process files
files = glob.glob(r'C:\Users\Serquin\Documents\No More Alone\ProactividadN8N\*.json')
for f in files:
    migrate_anthropic_to_openai(f)
