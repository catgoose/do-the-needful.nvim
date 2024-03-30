# do-the-needful

Task runner that uses tmux windows to do the needful please. A Telescope
picker makes selecting tasks simple. Task commands can use tokens that
are parsed at execution time.

![do-the-needful](https://tinyurl.com/mrxj4483 "do-the-needful")

<!--toc:start-->
- [do-the-needful](#do-the-needful)
  - [About](#about)
  - [Screenshots](#screenshots)
  - [Usage](#usage)
    - [API](#api)
    - [Telescope pickers](#telescope-pickers)
  - [Features](#features)
    - [Tasks](#tasks)
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

## About

- Tasks can be defined in in setup opts, project or global config
- Tasks run in tmux windows with configurable options such as to close
  automatically or to keep current window's focus
- Task tags make it easy to filter with Telescope picker
- Tokens can be defined globally or scoped to a task and are parsed by an evaluated
  function or user input
- When editing a new project or global tasks, a default config will be created
  if one doesn't exist

## Screenshots

| ![Actions picker](https://github.com/catgoose/do-the-needful.nvim/blob/screenshots/action-picker.png "Actions picker") |
| :--------------------------------------------------------------------------------------------------------------------: |
|                                     _Actions picker_ (`:Telescope do-the-needful`)                                     |

| ![Task selection picker](https://github.com/catgoose/do-the-needful.nvim/blob/screenshots/task-selection.png "Task picker") |
| :-------------------------------------------------------------------------------------------------------------------------: |
|                                _Task selection picker_ (`:Telescope do-the-needful please`)                                 |

| ![Prompting for input](https://github.com/catgoose/do-the-needful.nvim/blob/screenshots/ask-input.png "Prompting for input") |
| :--------------------------------------------------------------------------------------------------------------------------: |
|                                          _Prompting for input using `ask` function_                                          |

| ![Task spawned](https://tinyurl.com/3sftpu67 "Task spawned") |
| :----------------------------------------------------------: |
|        _Spawned task will close upon completion_         |

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
-- Displays picker to do the needful please or to edit task configs

:Telescope do-the-needful please
-- Displays task picker

:Telescope do-the-needful project
-- Edit project config

:Telescope do-the-needful global
-- Edit global config
```

## Features

### Tasks

Tasks can be defined in 3 places:

- Setup opts
- Global config: `.tasks.json` located in `vim.fn.stdpath("data")`
- Project config: `.tasks.json` in the project directory

Tasks are selected using a Telescope picker

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

Tasks metadata can be defined to make it easier to filter with Telescope picker

```lua
tags = { "eza", "home", "files" },
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

Telescope options can also be passed into `please` or `actions` to override the
above set defaults:

```lua
require("do-the-needful").please({winblend = 5})
require("do-the-needful").actions({prompt_title = "Actions"})
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
