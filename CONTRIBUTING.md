# Contributing Guidelines

Contributions and pull-requests are welcomed.

Please submit an issue or open a discussion before doing any complex or major changes.

## Generating Completion Items

The completions in [completion_items.json](./lua/cmp_ripgrep/completion_items.json) are generated from a script, [write_completion_items.js](./write_completion_items.js).

It requires installing:
* [Node.js](https://nodejs.org/en)
* [ripgrep](https://github.com/BurntSushi/ripgrep)
* and [pandoc](https://pandoc.org/installing.html)

It'd be nice to rewrite the script in Lua to avoid the Node.js dependency.

