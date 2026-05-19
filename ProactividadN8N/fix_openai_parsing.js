const fs = require('fs');

function fixParsing(filename) {
  const data = JSON.parse(fs.readFileSync(filename, 'utf8'));
  
  for (const node of data.nodes) {
    if (node.name.startsWith('Parse ') || node.name.startsWith('Build ') || node.name.startsWith('Check ')) {
      if (node.parameters && node.parameters.jsCode) {
        node.parameters.jsCode = node.parameters.jsCode.replace(
          /prev\.content\?\.\[0\]\?\.text/g, 
          "prev.choices?.[0]?.message?.content"
        );
      }
    }
  }
  
  fs.writeFileSync(filename, JSON.stringify(data, null, 2), 'utf8');
}

fixParsing('mood-insights-patched.json');
fixParsing('daily-checkin-patched.json');
fixParsing('smart-nudge-patched.json');
console.log('Fixed OpenAI parsing logic.');
