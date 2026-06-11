import json

with open(r"C:\Users\Serquin\.gemini\antigravity-ide\brain\6479b895-45df-432d-8cbd-b64c3552c7e0\.system_generated\steps\381\output.txt", 'r', encoding='utf-8') as f:
    data = json.load(f)

nodes = data['data']['nodes']
apply_corr = nodes.get('Apply correction')
if apply_corr:
    print(json.dumps(apply_corr, indent=2))
else:
    print("Apply correction node not found in nodes keys:", list(nodes.keys()))
