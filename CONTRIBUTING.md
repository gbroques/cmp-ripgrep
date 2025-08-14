# Contributing Guidelines

Contributions and pull-requests are welcomed.

Please submit an issue or open a discussion before doing any complex or major changes.

## Generating Completion Items

The completions in [completion_items.json](./lua/cmp_ripgrep/completion_items.json) are generated from a script, [print_completion_items.js](./print_completion_items.lua).

It requires installing [ripgrep](https://github.com/BurntSushi/ripgrep) and [pandoc](https://pandoc.org/installing.html).

[jq](https://jqlang.org/) is also recommended to format the JSON output.

Run the following command from the root of the repository to generate `completion_items.json`:

    nvim --headless --clean -l print_completion_items.lua | jq > lua/cmp_ripgrep_flags/completion_items.json

