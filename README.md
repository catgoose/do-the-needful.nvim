# do-the-needful

Task runner that uses tmux windows to do the needful please. Tasks can be configured
using `${tokens}` which can be replaced by a defined value or user input

![do-the-needful](https://tinyurl.com/mrxj4483 "do-the-needful")

<!--toc:start-->
- [do-the-needful](#do-the-needful)
  - [Please](#please)
  - [Screenshots](#screenshots)
  - [Usage](#usage)
    - [API](#api)
    - [Telescope pickers](#telescope-pickers)
  - [Features](#features)
    - [Tmux windows](#tmux-windows)
    - [Task metadata](#task-metadata)
    - [Global token replacement](#global-token-replacement)
    - [Prompting for input](#prompting-for-input)
  - [Setup](#setup)
    - [Example Lazy.nvim config](#example-lazynvim-config)
    - [Telescope setup](#telescope-setup)
  - [Configuration](#configuration)
    - [Default setup opts](#default-setup-opts)
    - [Ask functions](#ask-functions)
      - [Ask tokens](#ask-tokens)
    - [Global tokens defaults](#global-tokens-defaults)
  - [Editing project and global configs](#editing-project-and-global-configs)
    - [Project config](#project-config)
    - [Global config](#global-config)
    - [New configs](#new-configs)
    - [tasks JSON schema](#tasks-json-schema)
  - [Extra](#extra)
    - [Neovim](#neovim)
    - [Tmux](#tmux)
<!--toc:end-->

## Please

Tasks can be defined in 3 places:

- Setup opts
- Global config: `.tasks.json` located in `vim.fn.stdpath("data")`
- Project config: `.tasks.json` in the project directory

Tasks are selected using a Telescope picker

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

## Usage

### API

```lua
require("do-the-needful").please() -- Opens task picker
require("do-the-needful").actions() -- Opens picker to do the needful or edit configs
require("do-the-needful").edit_config("project")
require("do-the-needful").edit_config("global")
```

Telescope opts can be passed into `.please()` and `.actions()` functions

### Telescope pickers

```lua
:Telescope do-the-needful
-- Displays picker to select the needful or config editing actions

:Telescope do-the-needful please
-- Do the needful please

:Telescope do-the-needful project
-- Edit project config

:Telescope do-the-needful global
-- Edit global config
```

## Features

### Tmux windows

Tasks run in a new tmux window with the following default options:

```lua
window = {
  name = "name", -- name of tmux window
  close = false, -- close window after execution
  keep_current = false, -- keep focus on current window when running task
  open_relative = true, -- open window after/before current window
  relative = "after", -- relative direction if open_relative = true
  -- after or before
}
```

### Task metadata

Tasks metadata can be defined to make it easier to do the needful

```lua
tags = { "eza", "home", "files" }, -- task metadata used for searching
```

### Global token replacement

The following task fields are parsed for tokens

- cmd
- name
- cwd

`${tokens}` can be defined to be replaced in task the configuration:

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

Tasks can be configured to prompt for input. Token values are replaced by
`global_tokens` values or evaluated `ask_functions`:

Ask tokens are defined in each task's `ask` table (opt) or json object (project
and global)

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

## Setup

### Example Lazy.nvim config

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
  edit_mode = "buffer", -- buffer, tab, split, vsplit
  config_file = ".tasks.json", -- name of json config file for project/global config
  config_order = {-- default: { project, global, opts }.  Order in which
  -- tasks are aggregated
    "project", -- .task.json in project directory
    "global", -- .tasks.json in stdpath('data')
    "opts", -- tasks defined in setup opts
  },
  tag_source = true, -- display #project, #global, or #opt after tags
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
  },
}

return {
  "catgoose/do-the-needful.nvim",
  event = "BufReadPre",
  keys = {
    { "<leader>;", [[<cmd>Telescope do-the-needful please<cr>]], "n" },
    { "<leader>:", [[<cmd>Telescope do-the-needful<cr>]], "n" },
  },
  dependencies = "nvim-lua/plenary.nvim",
  opts = opts,
}
```

### Telescope setup

In your Telescope setup load the `do-the-needful` extension

```lua

telescope.load_extension("do-the-needful")
```

Telescope defaults can be set in Telescope setup:

```lua
require("telescope").setup({
  ...
  extensions = {
    ["do-the-needful"] = {
      winblend = 10,
    },
  }
})
```

Telescope options can also be passed into `please` to override the above set defaults:

```lua
require("do-the-needful").please({winblend = 5})
```

## Configuration

### Default setup opts

```lua
{
  log_level = "warn",
  tasks = {},
  edit_mode = "buffer",
  config = ".tasks.json",
  config_order = {
   "project",
   "global",
   "opts",
  },
  tag_source = true,
  global_tokens = {
    ["${cwd}"] = vim.fn.getcwd,
    ["${do-the-needful}"] = "please",
  },
  ask_functions = {},
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

#### Ask tokens

The value for `default` can refer to a literal value or a defined `ask_function`.

If the value of `ask.type` is "`function`" the corresponding `ask_function`
defined in setup opts will be evaluated upon task selection. This value will
be used for the default value in the token prompt dialog.

In the following example the `ask_function` `dir` will be evaluated and replace
the token `${dir}` in the task command.

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

```lua
...
  ask_functions = {
    dir = vim.fn.getcwd
  }
...
```

### Global tokens defaults

| Token             | Description    | Type     | Value         |
| ----------------- | -------------- | -------- | ------------- |
| ${cwd}            | CWD for task   | function | vim.fn.getcwd |
| ${do-the-needful} | Do the needful | string   | "please"      |

## Editing project and global configs

The Telescope picker will easily let you choose which config to edit

```lua
:Telescope do-the-needful
```

### Project config

```lua
require("do-the-needful").edit_config("project")
:Telescope do-the-needful project
```

### Global config

```lua
require("do-the-needful").edit_config("global")
:Telescope do-the-needful global
```

### New configs

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

### tasks JSON schema

```typescript
{
  tasks: Array<{
    name: string;
    cmd: string;
    tags: string[];
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
      relative: "before" | "after";
    };
  }>;
}
```

## Extra

### Neovim

My other neovim projects

- [neovim config](https://github.com/catgoose/nvim)
- [telescope-helpgrep.nvim](https://github.com/catgoose/telescope-helpgrep.nvim)

### Tmux

Tmux theme:

[kanagawa-tmux](https://github.com/catgoose/kanagawa-tmux)
