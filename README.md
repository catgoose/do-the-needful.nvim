# do-the-needful

![do-the-needful](https://tinyurl.com/mrxj4483 "do-the-needful")

<!--toc:start-->

- [do-the-needful](#do-the-needful)
  - [Please](#please)
  - [Screenshots](#screenshots)
  - [Task definition](#task-definition)
  - [Lazy.nvim setup](#lazynvim-setup)
  - [Editing project and global configs](#editing-project-and-global-configs)
    - [Project config](#project-config)
    - [Global config](#global-config)
  - [Telescope pickers](#telescope-pickers)
  - [API](#api)
  <!--toc:end-->

Neovim task runner that uses tmux windows to do the needful please.

## Please

Tasks are configurable in plugin setup, project directory, or in
`vim.fn.stdpath("data")`

## Screenshots

| ![Task picker](https://tinyurl.com/bdeerawy "Task picker") |
| :--------------------------------------------------------: |
|     _Task picker_ (`:Telescope do-the-needful please`)     |

| ![Task spawned](https://tinyurl.com/3sftpu67 "Task spawned") |
| :----------------------------------------------------------: |
|        _Spawned task_ and will close upon completion         |

| ![Action picker](https://tinyurl.com/23uh9hv3 "Action picker") |
| :------------------------------------------------------------: |
|         _Action picker_ (`:Telescope do-the-needful`)          |

## Task definition

The plugin config and json configs use the same definition:

## Lazy.nvim setup

Only `name` and `cmd` are required to do the needful

```lua
local opts = {
    tasks = {
        {
            name = "exa", -- name of task
            cmd = "exa", -- command to run
            cwd = "~", -- working directory
            tags = { "exa", "home", "files" }, -- task metadata used for searching
            window = { -- all window options are optional
                name = "Exa ~", -- name of tmux window
                close = false, -- close window after execution
                keep_current = false, -- switch to window when running task
                open_relative = true, -- open window after/before current window
                relative = "after", -- relative direction
            },
        },
    },
    config = ".tasks.json" -- name of config file for project/global config
}

return {
  "catgoose/do-the-needful",
  event = "BufReadPre",
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
`.tasks.json` does not exist, a sample task will be created with the
expected JSON schema:

```JSON
{
    "tasks": [
        {
            "name": "",
            "cmd": "",
            "tags": [""]
        }
    ]
}
```

### Project config

Use `require("do-the-needful).edit_config("project")` to edit `.tasks.json`
in the current directory

### Global config

Use `require("do-the-needful).edit_config("global")` to edit `.tasks.json`
in `vim.fn.stdpath("data")`

## Telescope pickers

Load telescope extension

```lua
  telescope.load_extension("do-the-needful")

```

The following telescope pickers are available

```lua
:Telescope do-the-needful
-- Displays picker to select the needful or config editing actions
```

```lua
:Telescope do-the-needful please
-- Do the needful please
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
require("do-the-needful").please()
require("do-the-needful").edit_config("project")
require("do-the-needful").edit_config("global")
```

## TODO

- Add ordering to config for task
- Add prompt configuration to allow for vim.select to ask for input that
  can be passed into the task
