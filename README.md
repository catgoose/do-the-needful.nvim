# do-the-needful

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
    - [.tasks.json JSON schema](#tasksjson-json-schema)
      - [Alternate config format](#alternate-config-format)
  - [Todo](#todo)
  <!--toc:end-->

Neovim task runner that uses tmux windows to do the needful please. Task command,
cwd, and name can be defined containing `${tokens}` which can be replaced by
defined values or evaluated functions.

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
require("do-the-needful").please()
require("do-the-needful").edit_config("project")
require("do-the-needful").edit_config("global")
```

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

Tasks run in a new tmux window with the following options available:

```lua
window = {
  name = "name", -- name of tmux window
  close = false, -- close window after execution
  keep_current = false, -- keep focus on current window when running task
  open_relative = true, -- open window after/before current window
  relative = "after", -- relative direction if open_relative = true
  -- after or before
  hidden = false -- hiding tasks from picker makes sense if you are using them
  -- to compose jobs
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
`global_tokens` values or evaluated `ask_functions` upon task selection:

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
    {
        id = "list1", -- id is used to reference a task in a job
        name = "List directory",
        cwd = "${cwd}",
        tags = { "list", "dir", "open", "pwd" },
        close = false,
        keep_current = false,
        hidden = true
    },
    {
        id = "list2",
        name = "List directory",
        cwd = "~",
        tags = { "list", "dir", "close", "home" },
        close = true,
        keep_current = true,
        hidden = true
    }
  },
  jobs = {
      {
          name = "list directories",
          tags = {"job", "list", "directories", "ordered"},
          tasks = { -- task.id to run in order
              "list1",
              "list2"
          },
          close = true,
          keep_current = false,
          open_realtive = true,
          relative = "before"
      },
      { -- multiple jobs can be created from the same task ids
          name = "list directories",
          tags = {"job", "list", "directories", "reversed"},
          tasks = {
              "list2",
              "list1"
          },
          close = false,
          keep_current = true,
      }
  }
  config_file = ".tasks.json", -- name of json config file for project/global config
  config_order = {-- default: {project, global, opts}.  Order in which
  -- tasks are aggregated
    "opts", -- tasks defined in setup opts
    "global", -- .tasks.json in stdpath('data')
    "project", -- .task.json in project directory
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
  telescope = {
    action_picker = {
      layout_strategy = "center",
      layout_config = {
        width = 0.25,
        prompt_position = "bottom",
      },
    },
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

## Configuration

### Default setup opts

```lua
{
  log_level = "warn",
  tasks = {},
  jobs = {},
  config = ".tasks.json",
  config_order = {
   "global",
   "project",
   "opts",
  },
  tag_source = true,
  global_tokens = {
    ["${cwd}"] = vim.fn.getcwd,
    ["${do-the-needful}"] = "please",
  },
  ask_functions = {},
  telescope = {
    action_picker = {
      layout_strategy = "center",
      layout_config = {
        width = 0.25,
        prompt_position = "bottom",
      },
    },
  },
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

The value for the `default` can refer to a literal value or a defined `ask_function`.

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

### .tasks.json JSON schema

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
      relative: "before" | "after";
    };
  }>;
}
```

#### Alternate config format

Alternatively the root `tasks` key can be omitted:

```json
[
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
```

Schema:

```typescript
Array<{
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
    relative: "before" | "after";
  };
}>;
```

## Todo

- Tasks can execute other tasks
