# do-the-needful

Task runner with multiple picker and runner backends. Pick a task, run it
anywhere. Task commands can use tokens that are parsed at execution time.

![do-the-needful](https://tinyurl.com/mrxj4483 "do-the-needful")

<!--toc:start-->
- [do-the-needful](#do-the-needful)
  - [About](#about)
  - [Screenshots](#screenshots)
  - [Requirements](#requirements)
  - [Usage](#usage)
    - [Commands](#commands)
    - [API](#api)
    - [Telescope pickers](#telescope-pickers)
  - [Pickers](#pickers)
  - [Runners](#runners)
  - [Features](#features)
    - [Tasks](#tasks)
    - [Window options](#window-options)
    - [Per-task runner override](#per-task-runner-override)
    - [Tag filtering](#tag-filtering)
    - [Re-run last task](#re-run-last-task)
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

- Tasks can be defined in setup opts, project or global config
- Tasks run via auto-detected backends: tmux, zellij, toggleterm, or a
  built-in neovim terminal
- Pick tasks with telescope, fzf-lua, snacks.nvim, or `vim.ui.select`
- Task tags make it easy to filter in any picker
- Tokens can be defined globally or scoped to a task and are parsed by an
  evaluated function or user input
- Per-task runner override lets you mix backends (e.g. most tasks in tmux,
  tests in a neovim terminal)
- Re-run the last executed task with `:NeedfulRerun`
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
|          _Spawned task will close upon completion_           |

## Requirements

- Neovim >= 0.10
- [plenary.nvim](https://github.com/nvim-lua/plenary.nvim)
- One of the following pickers (optional, falls back to `vim.ui.select`):
  [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim),
  [fzf-lua](https://github.com/ibhagwan/fzf-lua),
  [snacks.nvim](https://github.com/folke/snacks.nvim)
- One of the following runners (optional, falls back to neovim terminal):
  [tmux](https://github.com/tmux/tmux),
  [zellij](https://github.com/zellij-org/zellij),
  [toggleterm.nvim](https://github.com/akinsho/toggleterm.nvim)

## Usage

### Commands

```vim
:Needful [tags...]          " Open task picker, optionally filter by tags
:NeedfulRerun               " Re-run the last executed task
:NeedfulRun <name>          " Run a task by name (tab completion supported)
:NeedfulEdit [project|global] " Edit config files
```

All commands support tab completion.

### API

```lua
require("do-the-needful").please() -- Open task picker
require("do-the-needful").please({ tags = { "build" } }) -- Filter by tags
require("do-the-needful").actions() -- Open actions picker
require("do-the-needful").rerun() -- Re-run last task
require("do-the-needful").run_by_name("tests") -- Run task by name
require("do-the-needful").edit_config("project") -- Edit project config
require("do-the-needful").edit_config("global") -- Edit global config
```

### Telescope pickers

The `:Telescope` extension continues to work for backward compatibility:

```vim
:Telescope do-the-needful         " Actions picker
:Telescope do-the-needful please  " Task picker
:Telescope do-the-needful project " Edit project config
:Telescope do-the-needful global  " Edit global config
```

## Pickers

Pickers are auto-detected in priority order. The first available picker is
used. Set `picker` to use a specific backend or `picker_priority` to change
the order.

| Picker       | Key           | Requires                    |
| ------------ | ------------- | --------------------------- |
| Telescope    | `telescope`   | `telescope.nvim`            |
| fzf-lua      | `fzf_lua`     | `fzf-lua`                   |
| snacks       | `snacks`      | `snacks.nvim` with picker   |
| vim.ui.select| `ui_select`   | Nothing (always available)  |

```lua
-- Use a specific picker
require("do-the-needful").setup({
  picker = "fzf_lua",
})

-- Or change the auto-detection order
require("do-the-needful").setup({
  picker_priority = { "fzf_lua", "telescope", "snacks", "ui_select" },
})
```

## Runners

Runners are auto-detected in priority order. The first available runner is
used. Set `runner` to use a specific backend or `runner_priority` to change
the order.

| Runner      | Key          | Available when              |
| ----------- | ------------ | --------------------------- |
| tmux        | `tmux`       | `$TMUX` is set              |
| zellij      | `zellij`     | `$ZELLIJ` is set            |
| toggleterm  | `toggleterm` | `toggleterm.nvim` installed |
| neovim      | `neovim`     | Always available            |

```lua
-- Use a specific runner
require("do-the-needful").setup({
  runner = "neovim",
})

-- Or change the auto-detection order
require("do-the-needful").setup({
  runner_priority = { "tmux", "zellij", "toggleterm", "neovim" },
})
```

## Features

### Tasks

Tasks can be defined in 3 places:

- Setup opts
- Global config: `.tasks.json` located in `vim.fn.stdpath("data")`
- Project config: `.tasks.json` in the project directory

### Window options

Runner backends read the `window` table from each task:

```lua
window = {
  name = "name", -- window/pane name
  close = false, -- close after execution
  keep_current = false, -- keep focus on current window
  open_relative = true, -- open after/before current window (tmux)
  relative = "after", -- "after" or "before" (tmux)
}
```

### Provider-specific options

Each runner backend supports its own options via a provider key on the task.
These are optional and complement the shared `window` table.

#### tmux

```lua
tmux = {
  split = true,            -- use split-window instead of new-window
  direction = "horizontal", -- "horizontal" or "vertical" (split only)
  size = "30%",            -- pane size, e.g. "30%" or 20 (split only)
  full_span = true,        -- full-width/height split (split only)
  reuse = true,            -- reuse window with same name (new-window only)
  environment = {          -- environment variables passed with -e
    MY_VAR = "value",
  },
}
```

#### zellij

```lua
zellij = {
  direction = "down",      -- "up", "down", "left", "right"
  floating = true,         -- open as floating pane
  in_place = true,         -- open in place of current pane
  start_suspended = true,  -- start pane suspended
  width = "80%",           -- pane width
  height = "50%",          -- pane height
  x = 10,                  -- pane x position
  y = 5,                   -- pane y position
}
```

> **Note:** `window.keep_current` no longer maps to `--floating` in zellij.
> Use `zellij = { floating = true }` instead.

#### neovim

```lua
neovim = {
  split = "vsplit",        -- vim split command (default: "botright split")
  size = 40,               -- size prefix for split command (e.g. 40vsplit)
}
```

#### toggleterm

```lua
toggleterm = {
  direction = "float",     -- "horizontal", "vertical", "float", "tab"
  size = 20,               -- terminal size
}
```

JSON example:

```json
{
  "name": "tests",
  "cmd": "make test",
  "tmux": {
    "split": true,
    "direction": "vertical",
    "size": "40%"
  }
}
```

### Per-task runner override

Individual tasks can specify which runner to use regardless of the global
setting:

```json
{
  "name": "tests",
  "cmd": "make test",
  "runner": "neovim"
}
```

```lua
{
  name = "tests",
  cmd = "make test",
  runner = "neovim",
}
```

### Tag filtering

Filter tasks by tag using the `:Needful` command or the API:

```vim
:Needful build
```

```lua
require("do-the-needful").please({ tags = { "build" } })
```

### Re-run last task

Re-run the most recently executed task without opening a picker:

```vim
:NeedfulRerun
```

```lua
require("do-the-needful").rerun()
```

### Task metadata

Tasks metadata can be defined to make it easier to filter in pickers:

```lua
tags = { "eza", "home", "files" },
```

### Global token replacement

The following task fields are parsed for tokens:

- cmd
- name
- cwd

`${tokens}` can be defined to be replaced in the task configuration:

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
  },
}
```

## Setup

### Example Lazy.nvim config

```lua
local opts = {
  picker = "auto", -- "auto", "telescope", "fzf_lua", "snacks", "ui_select"
  runner = "auto", -- "auto", "tmux", "zellij", "neovim", "toggleterm"
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
        },
      },
      window = { -- all window options are optional
        name = "Eza ~", -- window name
        close = false, -- close after execution
        keep_current = false, -- keep focus on current window
        open_relative = true, -- open after/before current window (tmux)
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
  config_order = { -- default: { project, global, opts }.  Order in which
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
    end,
  },
  ask_functions = {
    get_cwd = function()
      return vim.fn.getcwd()
    end,
    current_file = function()
      return vim.fn.expand("%")
    end,
  },
}

return {
  "catgoose/do-the-needful.nvim",
  event = "BufReadPre",
  keys = {
    { "<leader>;", [[<cmd>Needful<cr>]], "n" },
    { "<leader>:", [[<cmd>NeedfulRerun<cr>]], "n" },
  },
  dependencies = "nvim-lua/plenary.nvim",
  opts = opts,
}
```

### Telescope setup

If using Telescope as your picker, load the extension in your Telescope setup:

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
require("do-the-needful").please({ winblend = 5 })
require("do-the-needful").actions({ prompt_title = "Actions" })
```

## Configuration

### Default setup opts

```lua
{
  log_level = "warn",
  tasks = {},
  edit_mode = "buffer",
  config_file = ".tasks.json",
  config_order = {
   "project",
   "global",
   "opts",
  },
  tag_source = true,
  picker = "auto",
  runner = "auto",
  picker_priority = { "telescope", "fzf_lua", "snacks", "ui_select" },
  runner_priority = { "tmux", "zellij", "toggleterm", "neovim" },
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
  end,
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

Use the `:NeedfulEdit` command or the actions picker to choose which config
to edit:

```vim
:NeedfulEdit project
:NeedfulEdit global
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
    runner: "tmux" | "zellij" | "neovim" | "toggleterm"; // optional override
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
    tmux?: {
      split: boolean;
      direction: "horizontal" | "vertical";
      size: string | number;
      full_span: boolean;
      reuse: boolean;
      environment: Record<string, string>;
    };
    zellij?: {
      direction: "up" | "down" | "left" | "right";
      floating: boolean;
      in_place: boolean;
      start_suspended: boolean;
      width: string | number;
      height: string | number;
      x: string | number;
      y: string | number;
    };
    neovim?: {
      split: string;
      size: number;
    };
    toggleterm?: {
      direction: "horizontal" | "vertical" | "float" | "tab";
      size: number;
    };
  }>;
}
```

## Extra

### Neovim

My other neovim projects

- [neovim config](https://github.com/catgoose/nvim)
- [telescope-helpgrep.nvim](https://github.com/catgoose/telescope-helpgrep.nvim)
- [vue-goto-definition](https://github.com/catgoose/vue-goto-definition.nvim)

### Tmux

Tmux theme:

[kanagawa-tmux](https://github.com/catgoose/kanagawa-tmux)
