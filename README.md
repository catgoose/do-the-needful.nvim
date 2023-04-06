# do-the-needful

<!--toc:start-->

- [do-the-needful](#do-the-needful)
  - [Tasks](#tasks)
  - [Screenshots](#screenshots)
  - [Lazy.nvim setup](#lazynvim-setup)
    - [Plugin config](#plugin-config)
  - [Editing project and global configs](#editing-project-and-global-configs)
    - [Project config](#project-config)
    - [Global config](#global-config)
  - [Telescope pickers](#telescope-pickers)
  - [API](#api)
  <!--toc:end-->

Neovim task runner that uses tmux windows to run configurable tasks.

<!--toc:start-->

## Tasks

Tasks are configurable at a plugin, project, and global level

## Screenshots

|           ![Task picker]("Task picker")           |
| :-----------------------------------------------: |
| _Task picker_ (`:Telescope do-the-needful tasks`) |

|      ![Task spawned]("Task spawned")      |
| :---------------------------------------: |
| _Spawned task_ relative to current window |

|       ![Action picker]("Action picker")       |
| :-------------------------------------------: |
| _Action picker_ (`:Telescope do-the-needful`) |

## Lazy.nvim setup

### Plugin config

example config

```lua
local opts = {
 needful = {
  {
   name = "exa", -- name of task
   -- required
   cmd = "exa", -- command to run
   -- required
   cwd = "~", -- working directory
   -- default current directory
   tags = {"exa", "home", "files"} -- task metadata used for searching
   -- default {}
   window = { -- all window options are optional
    name = "Exa ~", -- name of tmux window
    -- default: task name
    close = false, -- close window after execution
    -- default: true
    keep_current = false, -- switch to window when running task
    -- default: false
    open_relative = true, -- true: open window after/before current window
    -- default false
    relative = "after", -- before ore after when open_relative is true
    -- default "after"
   },
  },
 },
}

return {
 keys = {
  { "<leader>;", [[<cmd>Telescope do-the-needful please<cr>]], "n" },
  { "<leader>:", [[<cmd>Telescope do-the-needful<cr>]], "n" },
 },
 dependencies = "nvim-lua/plenary.nvim",
 opts = opts,
}
```

## Editing project and global configs

When calling the task config editing functions if the respective
`.do-the-needful.json` does not exist, a sample task will be created with the
expected JSON schema:

```JSON
{
 "needful": [
  {
   "name": "",
   "cmd": "",
   "tags": [""]
  }
 ]
}
```

### Project config

Use `require("do-the-needful).edit_config('project')` to edit `.do-the-needful.json`
in the current directory

### Global config

Use `require("do-the-needful).edit_config('global')` to edit `.do-the-needful.json`
in `vim.fn.stdpath("data)`

## Telescope pickers

The following telescope pickers are available

```lua
:Telescope do-the-needful
-- Displays picker to select task/config editing actions
```

```lua
:Telescope do-the-needful tasks
-- Displays task picker
```

```lua
:Telescope do-the-needful edit_project
-- Edits project config
```

```lua
:Telescope do-the-needful edit_global
-- Edits global config
```

## API

```lua
require("do-the-needful").needful()
require("do-the-needful").edit_config("project")
require("do-the-needful").edit_config("global")
```
