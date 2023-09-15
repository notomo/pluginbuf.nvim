# pluginbuf.nvim

WIP

Inspired by [vim-metarw](https://github.com/kana/vim-metarw).

## Example

```lua
local util = require("pluginbuf.util")
require("pluginbuf").register("gh-repo-description", {
  {
    path = "/{owner}/{repo}",
    read = function(ctx)
      local onwer_repo = ctx.path_params.owner .. "/" .. ctx.path_params.repo
      return util.cmd_output({ "gh", "repo", "view", onwer_repo, "--json=description", "--jq=.description" })(ctx)
    end,
    write = function(ctx)
      local onwer_repo = ctx.path_params.owner .. "/" .. ctx.path_params.repo
      return util.cmd_input({ "gh", "repo", "edit", onwer_repo, "--description", "-" })(ctx)
    end,
  },
})
vim.cmd.tabedit("gh-repo-description://notomo/pluginbuf.nvim")
```