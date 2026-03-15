--| OPTION |

local opt         = vim.opt

opt.background    = "light"
opt.breakindent   = true
opt.clipboard     = "unnamedplus"
opt.cursorline    = false
opt.gdefault      = true
opt.ignorecase    = true
opt.laststatus    = 3
opt.mouse         = "a"
opt.number        = false
opt.scrolloff     = 15
opt.shortmess     = "Itas"
opt.showcmd       = false
opt.showmode      = false
opt.signcolumn    = "yes:1"
opt.smartcase     = true
opt.statusline    = " %f %m%r %= %{&filetype} | %n | %{&fenc} | %3l : %2c  "
opt.swapfile      = false
opt.timeoutlen    = 300
opt.updatetime    = 250
opt.winborder     = "single"
opt.conceallevel  = 2
opt.concealcursor = "nc"

--| KEY |

vim.g.mapleader      = " "
vim.g.maplocalleader = ","

do
  local key = {
    {'i',   'jk',       '<esc>'},
    {'n',   '<c-h>',    '<c-w><c-h>'},
    {'n',   '<c-l>',    '<c-w><c-l>'},
    {'n',   '<c-j>',    '<c-w><c-j>'},
    {'n',   '<c-k>',    '<c-w><c-k>'},
    {'n',   '*',        'g*'},
    {'n',   '<bs>',     ':nohl<cr>'},
    {'n',   '-',        ':Ex<cr>'},
    {'n',   '[b',       ':bprevious<cr>'},
    {'n',   ']b',       ':bnext<cr>'},
    {'n',   's',        '<Plug>(leap)'},
    {'n',   'S',        '<Plug>(leap-from-window)'},
    {'n',   '<F8>',     ':e $HOME/.config/nvim/init.lua<cr>'},
    {'n',   '<F2>',     ':so %<cr>'},
    {'n',   'gd',       vim.lsp.buf.definition},
  }

  for _, t in ipairs(key) do vim.keymap.set(unpack(t)) end
end

--| PACK |

vim.pack.add({
  { src = "https://codeberg.org/andyg/leap.nvim.git" },
  { src = "https://github.com/eraserhd/parinfer-rust.git" },
  { src = "https://github.com/mason-org/mason-lspconfig.nvim.git" },
  { src = "https://github.com/mason-org/mason.nvim.git" },
  { src = "https://github.com/mhinz/vim-sayonara" },
  { src = "https://github.com/neovim/nvim-lspconfig" },
  { src = "https://github.com/nvim-treesitter/nvim-treesitter.git" },
  { src = "https://github.com/andrtell/zero.git" },
  { src = "https://github.com/saghen/blink.cmp.git" },
})

do
  local function delete_packages()
    local pkgs = vim.iter(vim.pack.get())
      :filter(function(x) return not x.active end)
      :map(function(x) return x.spec.name end)
      :totable()

    if next(pkgs) then
      vim.pack.del(pkgs)
    end
  end

  delete_packages()
end

--| LSP |

vim.lsp.config('lua_ls', {
  settings = {
    Lua = {
      runtime = {
        version = _VERSION,
      },
      diagnostics = {
        globals = { 'vim', 'require' }
      }
    }
  }
})

vim.lsp.config('gopls', {})

require("mason").setup()
require("mason-lspconfig").setup()

--| DIAGNOSTIC |

vim.diagnostic.enable = true

vim.diagnostic.config({
  signs = false,
  virtual_text = {
    prefix = "←"
  }
})

--| TREESITTER |

do
  local group    = vim.api.nvim_create_augroup("treesitter", { clear = true })

  local pattern  = {
    "c",
    "fennel",
    "go",
    "lua",
    "odin",
    "scheme",
    "pony",
  }

  local callback = function() vim.treesitter.start() end

  vim.api.nvim_create_autocmd("FileType", {
    group    = group,
    pattern  = pattern,
    callback = callback,
  })
end

--| NETRW |

vim.g.netrw_banner    = 0
vim.g.netrw_keepdir   = 0
vim.g.netrw_list_hide = "\\(^\\|\\s\\s\\)\\zs\\.\\S\\+"

do
  local group    = vim.api.nvim_create_augroup("netrw", { clear = true })

  local pattern  = { 'netrw' }

  local callback = function()
    local o = { silent = true, buffer = true, remap = true }
    local k = {
      {'n', '<esc>', ':Sayonara!<cr>', o},
      {'n', 'h',     '-',              o},
      {'n', 'l',     '<cr>',           o},
      {'n', '.',     'gh',             o},
      {'n', 'H',     'h',              o},
    }
    for _, t in ipairs(k) do vim.keymap.set(unpack(t)) end
  end

  vim.api.nvim_create_autocmd("FileType", {
    group     = group,
    pattern   = pattern,
    callback  = callback,
  })
end

--| GO |

do
  local group     = vim.api.nvim_create_augroup('golang', { clear = true })

  local pattern   = { '*.go' }

  local callback  = function()
    local params = vim.lsp.util.make_range_params(nil, "utf-16")

    params.context = {
      only = { 'source.organizeImports' }
    }

    local timeout = 1000

    local result = vim.lsp.buf_request_sync(0, 'textDocument/codeAction', params, timeout)

    for cid, res in pairs(result or {}) do
      for _, r in pairs(res.result or {}) do
        if r.edit then
          local enc = (vim.lsp.get_client_by_id(cid) or {}).offset_encoding or "utf-16"
          vim.lsp.util.apply_workspace_edit(r.edit, enc)
        end
      end
    end

    vim.lsp.buf.format({async = false})
  end

  vim.api.nvim_create_autocmd("BufWritePre", {
    group    = group,
    pattern  = pattern,
    callback = callback
  })
end

--| BLINK |

require("blink.cmp").setup()

--| COLOR |

vim.cmd("colorscheme zero-light")
