# pluginbuf.nvim

WIP

Inspired by [vim-metarw](https://github.com/kana/vim-metarw).

## Example

```lua
local util = require("pluginbuf.util")
require("pluginbuf").register("gh-repo-description", {
  read = util.cmd_output({ "gh", "repo", "view", "--json=description", "--jq=.description" }),
  write = util.cmd_input({ "gh", "repo", "edit", "--description", "-" }),
})
vim.cmd.tabedit("gh-repo-description://[Scratch]")

```