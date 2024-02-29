# do-the-needful

![do-the-needful](https://tinyurl.com/mrxj4483 "do-the-needful")

<!--toc:start-->

- [do-the-needful](#do-the-needful)
  - [Please](#please)
    - [Tmux windows](#tmux-windows)
    - [Task metadata](#task-metadata)
    - [Global token replacement](#global-token-replacement)
    - [Prompting for input](#prompting-for-input)
    - [Ask functions](#ask-functions)
  - [Screenshots](#screenshots)
  - [Lazy.nvim setup](#lazynvim-setup)
    - [Example config](#example-config)
    - [Default setup opts](#default-setup-opts)
  - [Asking for input](#asking-for-input)
  - [Global tokens defaults](#global-tokens-defaults)
  - [Editing project and global configs](#editing-project-and-global-configs)
    - [JSON schema](#json-schema)
    - [Ask tokens](#ask-tokens)
    - [Project config](#project-config)
    - [Global config](#global-config)
  - [Telescope pickers](#telescope-pickers)
  - [API](#api)
  - [Todo](#todo)
  <!--toc:end-->

Neovim task runner that uses tmux windows to do the needful please.

## Please

Tasks are configurable in plugin setup, project directory, or in
`vim.fn.stdpath("data")`. Project and global configs can be opened through
the telescope picker (`:Telescope do-the-needful`).

### Tmux windows

Tasks run in a new tmux window with the following options available:

```lua
window = {
  name = "name", -- name of tmux window
  close = false, -- close window after execution
  keep_current = false, -- keep focus on current window when running task
  open_relative = true, -- open window after/before current window
  relative = "after", -- relative direction if open_relative = true
}
```

### Task metadata

Tasks metadata can be defined to make it easier to do the needful

```lua
tags = { "eza", "home", "files" }, -- task metadata used for searching
```

### Global token replacement

Tokens can be defined to be replaced in task commands:

```lua
global_tokens = {
  ["${cwd}"] = vim.fn.cwd,
  ["${do-the-needful}"] = "please",
  ["${projectname}"] = function()
    return vim.fn.system("basename $(git rev-parse --show-toplevel)")
  end
},
```

### Prompting for input

Tasks can be configured to prompt for input to replace token values or functions
defined to be evaluated upon task selection:

```lua
ask = { -- Used to prompt for input to be passed into task
  ["${dir}"] = {
    title = "Which directory to search", -- defaults to the name of token
    type = "function", -- function or string
    default = "get_cwd", --[[ defaults to "" if omitted.  If ask.type is a value
    other than "function", the literal value of default will be used.  If
    ask.type is "function", the named function in the ask_functions table will
    be evaluated for the default value passed into vim.ui.input ]]
  }
}
```

### Ask functions

Ask functions can be defined to evaluate default values for the token prompt:

```lua
ask_functions = {
  ["get_cwd"] = vim.fn.getcwd,
  ["current_file"] = function()
    return vim.fn.expand("%")
  end
}
```

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

## Lazy.nvim setup

### Example config

```lua
local opts = {
  tasks = {
    {
      name = "eza", -- name of task
      cmd = "eza ${dir}", -- command to run
      cwd = "~", -- working directory to run task
      tags = { "eza", "home", "files" }, -- task metadata used for searching
      ask = { -- Used to prompt for input to be passed into task
        ["${dir}"] = {
          title = "Which directory to search", -- defaults to the name of token
          type = "function", -- function or string
          default = "get_cwd", -- defaults to "".  If ask.type is string, the literal
          -- value of default will be used.  If ask.type is function the named
          -- function in the ask_functions section will be evaluated for the default
        }
      },
      window = { -- all window options are optional
        name = "Eza ~", -- name of tmux window
        close = false, -- close window after execution
        keep_current = false, -- switch to window when running task
        open_relative = true, -- open window after/before current window
        relative = "after", -- relative direction if open_relative = true
      },
    },
    {
      name = "ripgrep current directory",
      cmd = "rg ${pattern} ${cwd}",
      tags = { "ripgrep", "cwd", "search", "pattern" },
      ask = {
        ["${pattern}"] = {
          title = "Pattern to use",
          default = "error",
        },
      },
      window = {
        name = "Ripgrep",
        close = false,
        keep_current = true,
      },
    },
  },
  config_file = ".tasks.json", -- name of json config file for project/global config
  config_order = {-- default: {project, global, opts}.  Order in which
  -- tasks are aggregated
    "project", -- .task.json in project directory
    "global", -- .tasks.json in stdpath('data')
    "opts", -- tasks defined in setup opts
  },
  global_tokens = {
    ["${cwd}"] = vim.fn.getcwd,
    ["${do-the-needful}"] = "please",
    ["${projectname}"] = function()
      return vim.fn.system("basename $(git rev-parse --show-toplevel)")
    end
  },
  ask_functions = {
    get_cwd = function()
      return vim.fn.getcwd()
    end,
    current_file = function()
      return vim.fn.expand("%")
    end
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

### Default setup opts

```lua
{
  log_level = "warn",
  tasks = {},
  config = ".tasks.json",
  config_order = {
   "global",
   "project",
   "opts",
  },
  global_tokens = {
    ["${cwd}"] = vim.fn.getcwd,
    ["${do-the-needful}"] = "please",
  },
  ask_functions = {}
}
```

## Asking for input

Tokens can be used in the `cmd` definition to prompt for input. Any number of
tokens can be used and are defined in each task's token table. Gloal tokens
can be defined in the setup opts

## Global tokens defaults

| Token             | Description    | Type     | Value         |
| ----------------- | -------------- | -------- | ------------- |
| ${cwd}            | CWD for task   | function | vim.fn.getcwd |
| ${do-the-needful} | Do the needful | string   | "please"      |

The value for the `default` can be a string or a function to be evaluated.

## Editing project and global configs

When calling the task config editing functions if the respective
`.tasks.json` does not exist, an example task will be created

```JSON
{
 "tasks": [
  {
   "name": "",
   "cmd": "",
   "tags": [""],
   "window": {
    "name": "",
    "close": false,
    "keep_current": false,
    "open_relative": true,
    "relative": "after"
   }
  }
 ]
}
```

### JSON schema

```typescript
{
  tasks: Array<{
    name: string;
    cmd: string;
    tags: Array<string>;
    ask: {
      "${token}": {
        title: string;
        type: "string" | "function";
        default: string;
      };
    };
    window: {
      name: string;
      close: boolean;
      keep_current: boolean;
      open_relative: boolean;
      relative: "before" | "after;
    };
  }>;
}
```

### Ask tokens

If the value of `ask.type` is `function` the corresponding `ask_function`
defined in setup opts will be evaluated upon task selection for the default
value in the token prompt dialog.

```json
{
  "ask": {
    "${dir}": {
      "title": "Which directory?",
      "type": "function",
      "default": "dir"
    }
  }
}
```

In this example the function `dir` defined in the setup opts will be evaluated

```lua
...
  ask_functions = {
    dir = function()
      return vim.fn.getcwd()
    end,
  }
...
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
