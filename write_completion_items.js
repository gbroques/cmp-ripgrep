#!/usr/bin/env node
/**
 * Writes completion items as JSON to disk using the following steps:
 * 1. Generate ripgrep's man page via `rg --generate man` command.
 * 2. Convert ripgrep's man page to Markdown via `pandoc`.
 * 3. Parse the Markdown output.
 */
const { execSync } = require('node:child_process');
const { writeFileSync } = require('node:fs');
const path = require('node:path');

const COMMAND = 'rg --generate man | pandoc --from man --to markdown';
// include the . for rg's -. flag.
const FLAG_PATTERN = '--?[.a-zA-Z0-9-]+';
const OUTPUT_FILEPATH = './lua/cmp_ripgrep_flags/completion_items.json';

function isExecutableAvailable(name) {
    try {
        execSync(`which ${name}`);
        return true;
    } catch (error) {
        return false;
    }
}
const requiredExecutables = ['rg', 'pandoc'];
requiredExecutables.forEach((executable) => {
    if (!isExecutableAvailable(executable)) {
        console.error(executable + ' is required on PATH.');
        process.exit(1);
    }
});
const versionCommands = ['rg -V', 'pandoc -v'];
const versions = versionCommands.map(cmd => execSync(cmd).toString().split('\n')[0]);

const lines = execSync(COMMAND).toString().split('\n');
const completionItems = extractCompletionItems(lines);

const filename = path.basename(__filename);
try {
    const json = JSON.stringify({
        generated: {
            from: filename,
            at: new Date().toISOString()
        },
        versions,
        completion_items: completionItems,
    }, null, 2); 
    writeFileSync(OUTPUT_FILEPATH, json);
    console.log('JSON data successfully written to ' + OUTPUT_FILEPATH);
} catch (error) {
  console.error('Error writing JSON to file:', error);
}

/**
 * @param {Array.<String>} lines 
 */
function extractCompletionItems(lines) {
    const completionItems = [];

    // Track some mutable state during the loop.
    let insideOptionsSection = false;
    let flags = null;
    let documentation = '';
    for (const line of lines) {
        // Quit after the next level 1 section after OPTIONS
        if (insideOptionsSection && line.substring(0, 2) === '# ') {
            break;
        }
        if (line === '# OPTIONS') {
            insideOptionsSection = true;
        }
        if (insideOptionsSection) {
            // Lines with options start with * for strong emphasis.
            if (line[0] === '*') {
                if (documentation) { // true on every subsequent option besides the first
                    flags.forEach(flag => {
                        const completionItem = createCompletionItem(flag, documentation);
                        completionItems.push(completionItem);
                    });
                    documentation = '';
                }
                // Track the flags while we concatenate the documentation.
                flags = extractFlags(line);
                
                // Add flags as first line of documentation.
                documentation += line + '\n\n'
            }
            // Documentation for flags are in block quotes.
            if (line[0] === '>') {
                // Trim block quotes from line '> '.
                documentation += line.substring(2) + '\n';
            }
        }
    }
    return completionItems;
}

/**
 * @param {String} line
 */
function extractFlags(line) {
    const regexp = new RegExp(FLAG_PATTERN, 'g');
    const matches = [...line.matchAll(regexp)];
    return matches.map(m => m[0]);
}

// this is in the format nvim-cmp expects for completion items.
function createCompletionItem(flag, documentation) {
    return {
        label: flag,
        documentation: {
            kind: 'markdown',
            value: documentation
        }
    };
}
