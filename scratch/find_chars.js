const fs = require('fs');

const path = 'C:/Users/Serquin/.gemini/antigravity/brain/50e98ced-f22b-4126-82a5-be745c50e460/.system_generated/steps/1218/output.txt';
const content = fs.readFileSync(path, 'utf8');
const workflow = JSON.parse(content);

const codeNode = workflow.data.nodes.find(n => n.name === 'Build step content');
const code = codeNode.parameters.jsCode;

for (let i = 0; i < code.length; i++) {
  const charCode = code.charCodeAt(i);
  if (charCode > 127) {
    console.log(`Char at ${i}: ${code[i]} (code: ${charCode})`);
  }
}
