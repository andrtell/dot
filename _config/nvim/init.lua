--| OPTIONS

do
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
end

--| KEYS

do
  vim.g.mapleader      = " "
  vim.g.maplocalleader = ","
  local k = {
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
    {'n',   '<F5>',     ':e $HOME/.config/nvim/init.lua<cr>'},
    {'n',   '<F2>',     ':so %<cr>'},
    {'n',   'gd',       vim.lsp.buf.definition},
  }
  for _, t in ipairs(k) do vim.keymap.set(unpack(t)) end
end

--| PACKAGES

do
  vim.pack.add({
    { src = "https://codeberg.org/andyg/leap.nvim.git" },
    { src = "https://github.com/eraserhd/parinfer-rust.git" },
    { src = "https://github.com/mason-org/mason-lspconfig.nvim.git" },
    { src = "https://github.com/mason-org/mason.nvim.git" },
    { src = "https://github.com/mhinz/vim-sayonara" },
    { src = "https://github.com/neovim/nvim-lspconfig" },
    { src = "https://github.com/nvim-treesitter/nvim-treesitter.git" },
    { src = "https://github.com/oskarnurm/koda.nvim" },
    { src = "https://github.com/saghen/blink.cmp.git" },
  })

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

--| LSP

do
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
end

--| DIAGNOSTICS

do
  local d = vim.diagnostic

  d.enable = true

  d.config({
    signs = false,
    virtual_text = {
      prefix = "~"
    }
  })
end

--| TREESITTER

do
  local group    = vim.api.nvim_create_augroup("treesitter", { clear = true })
  local pattern  = {
    "c",
    "fennel",
    "go",
    "lua",
    "odin",
    "scheme",
  }
  local callback = function() vim.treesitter.start() end

  vim.api.nvim_create_autocmd("FileType", {
    group    = group,
    pattern  = pattern,
    callback = callback,
  })
end

--| NETRW

do
  vim.g.netrw_banner    = 0
  vim.g.netrw_keepdir   = 0
  vim.g.netrw_list_hide = "\\(^\\|\\s\\s\\)\\zs\\.\\S\\+"

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

--| GO

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

--| BLINK

do
  require("blink.cmp").setup()
end

--| COLORSCHEME

function Colors()
  local fg = {
    black  = '#000000',
    red    = '#861616',
    green  = '#085800',
    blue   = '#00369d',
    purple = '#7e0e7c',
    gray   = '#999999',
  }

  local bg = {
    white  = "#fbfbfb",
    gray   = "#ededec",
  }

  local pa = {
    fg        = fg.black,
    bg        = bg.white,

    visual    = bg.gray,
    error     = fg.red,
    directory = fg.blue,
    status    = bg.gray,

    keyword   = fg.red,
    string    = fg.green,
    constant  = fg.purple,
    number    = fg.blue,
    comment   = fg.gray,
    type      = fg.black,
  }

  local hi = {
    -- VIM
    DiagnosticError               = { fg = pa.error     },
    Visual                        = { bg = pa.visual    },
    Search                        = { bg = pa.visual    },
    IncSearch                     = { bg = pa.visual    },
    CurSearch                     = { bg = pa.visual    },
    StatusLine                    = { bg = pa.status    },
    Directory                     = { fg = pa.directory },
    Include                       = { fg = pa.keyword   },
    Constant                      = { fg = pa.fg        },
    ['@keyword.vim']              = { fg = pa.string    },
    ['@variable.builtin.vim']     = { fg = pa.string    },
    ['@constant.vim']             = { fg = pa.string    },

    -- MARKUP
    ['@markup.raw']               = { fg = pa.type },

    -- CODE
    Comment                       = { fg = pa.comment },
    Boolean                       = { fg = pa.constant },
    Float                         = { fg = pa.number },
    Function                      = { },
    Keyword                       = { fg = fg.red },
    Number                        = { fg = fg.blue },
    Statement                     = { fg = pa.keyword },
    String                        = { fg = pa.string },
    Type                          = { fg = pa.fg },

    -- TOML
    TomlInteger                   = { fg = pa.number },

    -- LEAP (PLUGIN)
    LeapLabel                     = { bg = pa.visual },

    -- LUA
    ['@function.builtin.lua']     = { },
    ['@function.call.lua']        = { fg = pa.fg },
    ['@function.lua']             = { },
    ['@number.lua']               = { fg = pa.number },
    ['@lsp.type.function.lua']    = { },
    ['@lsp.type.method.lua']      = { },
    ['@string.escape.lua']        = { fg = pa.string },
    ['@boolean.lua']              = { fg = pa.constant },
    ['@operator.lua']             = { fg = pa.fg },
    ['@keyword.operator.lua']     = { fg = pa.keyword },
    ['@keyword.return.lua']       = { fg = pa.keyword },

    -- SCHEME
    ['@operator.scheme']          = { fg = pa.keyword },
    ['@keyword.scheme']           = { fg = pa.keyword },
    ['@number.scheme']            = { fg = pa.number },
    ['@conceal.scheme']           = { fg = pa.keyword },
    ['@variable.scheme']          = { fg = "none" },
    ['@string.special.symbol.scheme'] = { fg = pa.number },

    -- GO
    ['goFormatSpecifier']         = { fg = pa.string },
    ['goBuiltins']                = { fg = pa.keyword },

    ['@function.call.go']         = { },
    ['@function.go']              = { },
    ['@function.builtin.go']      = { fg = pa.keyword },
    ['@constant.go']              = { fg = pa.fg },
    ['@constant.builtin.go']      = { fg = pa.fg },
    ['@function.method.call.go']  = { },
    ['@function.method.go']       = {  },
    ['@lsp.type.function.go']     = {  },
    ['@string.escape.go']         = { fg = pa.string },

    ['@type.go']                  = { fg = fg.black },
    ['@type.builtin.go']          = { fg = fg.black },
    ['@keyword.return.go']        = { fg = pa.keyword },
    ['@keyword.import.go']        = { fg = pa.keyword },
    ['@keyword.function.go']      = { fg = pa.keyword },
    -- C
    ['cStorageClass']             = { fg = pa.fg },
    ['cInclude']                  = { fg = pa.fg },
    ['cFormat']                   = { fg = pa.string },
    ['cSpecial']                  = { fg = pa.string },
    ['cStructure']                = { fg = pa.keyword },
    ['cOperator']                 = { fg = pa.fg },
    ['cBlock']                    = { fg = pa.fg },
    ['cConstant']                 = { fg = pa.fg },

    ['@type.builtin.c']           = { fg = pa.keyword },
    ['@keyword.operator.c']       = { fg = pa.keyword },
    ['@keyword.import.c']         = { fg = pa.fg },
    ['@operator.c']               = { fg = pa.fg },
    ['@constant.c']               = { fg = pa.fg },
    ['@constant.builtin.c']       = { fg = pa.fg },

    -- ODIN
    ['@punctuation.bracket.odin']   = { },
    ['@punctuation.special.odin']   = { fg = pa.fg },
    ['@punctuation.delimiter.odin'] = { fg = pa.fg },
    ['@operator.odin']            = { fg = pa.fg },
    ['@keyword.operator.odin']    = { fg = pa.keyword },
    ['@keyword.type.odin']        = { fg = pa.keyword },
    ['@keyword.directive.odin']   = { fg = pa.fg },
    ['@keyword.function.odin']    = { fg = pa.keyword },
    ['@keyword.import.odin']      = { fg = pa.fg },
    ['@keyword.return.odin']      = { fg = pa.keyword },
    ['@string.odin']              = { fg = pa.string },
    ['@string.escape.odin']       = { fg = pa.string },
    ['@boolean.odin']             = { fg = pa.constant },
    ['@character.odin']           = { fg = pa.fg },
    ['@number.odin']              = { fg = pa.number },
    ['@constant.builtin.odin']    = { fg = pa.constant },

    ['@function.macro.odin']      = { fg = pa.constant },
    ['@function.call.odin']       = { fg = pa.fg },
    ['@function.odin']            = { fg = pa.fg },
    ['@variable.odin']            = { fg = pa.fg },

    -- ['@type.odin']                = { fg = pa.type },
  }

  require("koda").setup({
    colors = {
      bg    = pa.bg,
      fg    = pa.fg,
      info  = pa.number,
    },
    on_highlights = function(hl, _colors)
      for k, v in pairs(hi) do
        hl[k] = v
      end
    end
  })

  vim.cmd("colorscheme koda")

end

Colors()
