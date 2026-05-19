const fs = require('fs');

try {
  const fileContent = fs.readFileSync('C:\\Users\\Serquin\\.gemini\\antigravity\\brain\\50e98ced-f22b-4126-82a5-be745c50e460\\.system_generated\\steps\\837\\output.txt', 'utf8');
  const data = JSON.parse(fileContent);
  const nodes = data.data.nodes;
  const buildStepNode = nodes.find(n => n.name === 'Build step content');
  const jsCode = buildStepNode.parameters.jsCode;
  
  console.log("Extracted jsCode successfully! Length:", jsCode.length);
  
  // Save it to a scratch file to check syntax
  fs.writeFileSync('scratch/extracted_code.js', jsCode, 'utf8');
  
  // Try to parse/run syntax check using Function constructor
  // We need to define $input and $ methods to avoid ReferenceError, but Function only compiles, doesn't execute immediately unless called.
  // Actually, new Function() will parse the code for syntax errors.
  new Function('$input', '$', jsCode);
  console.log("No syntax error in the extracted code!");
} catch (e) {
  console.error("Syntax Error found in extracted code:", e);
  if (e.stack) console.error(e.stack);
}
