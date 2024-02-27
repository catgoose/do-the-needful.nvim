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
            name = "eza", -- name of task
            cmd = "eza ${dir}", -- command to run
            cwd = "~", -- working directory to run task
            tags = { "eza", "home", "files" }, -- task metadata used for searching
            ask_tokens = { -- Used to prompt for input to be passed into task
              dir = {
                ask = "Which directory to search", -- defaults to name of token
                -- (dir in this case)
                type = "string", -- defaults to string if no type is passed in
                default = "", -- defaults to "".  A function can be supplied to
                -- evaluate the default
              }
            }
            window = { -- all window options are optional
                name = "Eza ~", -- name of tmux window
                close = false, -- close window after execution
                keep_current = false, -- switch to window when running task
                open_relative = true, -- open window after/before current window
                relative = "after", -- relative direction
            },
        },
    },
    config = ".tasks.json" -- name of config file for project/global config
    config_order = {-- default: {project, global, opts}.  Order in which
    -- tasks are aggregated
        "project", -- .task.json in project directory
        "global", -- .tasks.json in stdpath('data')
        "opts" -- tasks defined in setup opts
    },
    global_tokens = {
        cwd = {
            ["${cwd}"] = function()
                vim.fn.cwd()
            end
        }
    }
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

## Built-in tokens

| Token  | Description            |
| ------ | ---------------------- |
| ${cwd} | CWD for task to run in |

## Using ask tokens

Tokens can be used in the `cmd` to prompt for input. Any number of tokens can
be used and are defined in each task's token table.

The value for the `default` can be a string or a function to be evaluated.

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

## Todo

- [ ] Implement token logic to prompt for input to be passed
- [ ] Refactor telescope module
  - [ ] Allow for more configuration of telescope picker
- [ ] Add ordering or priority to task config
