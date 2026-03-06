-------------
-- OPTIONS -- 
-------------

do
  local vo         = vim.opt

  vo.background    = "light"
  vo.breakindent   = true
  vo.clipboard     = "unnamedplus"
  vo.cursorline    = false
  vo.gdefault      = true
  vo.ignorecase    = true
  vo.laststatus    = 3
  vo.mouse         = "a"
  vo.number        = false
  vo.scrolloff     = 15
  vo.shortmess     = "Itas"
  vo.showcmd       = false
  vo.showmode      = false
  vo.signcolumn    = "yes:1"
  vo.smartcase     = true
  vo.statusline    = " %f %m%r %= %{&filetype} | %n | %{&fenc} | %3l : %2c  "
  vo.swapfile      = false
  vo.timeoutlen    = 300
  vo.updatetime    = 250
  vo.winborder     = "single"
  vo.conceallevel  = 2
  vo.concealcursor = "nc"

  vim.cmd("set noerrorbells visualbell t_vb=")
  vim.cmd("autocmd GUIEnter * set visualbell t_vb=")
end

----------
-- KEYS --
----------

do
  local g = vim.g

  g.mapleader       = " "
  g.maplocalleader  = ","

  local vks = vim.keymap.set

  vks("i", "jk", "<esc>")
  vks("n", "*", "g*")
  vks("n", "<bs>", ":nohl<cr>")
  vks("n", "-", ":Ex<cr>")
  vks("n", "<c-h>", "<c-w><c-h>")
  vks("n", "<c-l>", "<c-w><c-l>")
  vks("n", "<c-j>", "<c-w><c-j>")
  vks("n", "<c-k>", "<c-w><c-k>")
  vks("n", "[b", ":bprevious<cr>")
  vks("n", "]b", ":bnext<cr>")
  vks("n", "s", "<Plug>(leap)")
  vks("n", "S", "<Plug>(leap-from-window)")
  vks("n", "<F5>", ":e $HOME/.config/nvim/init.lua<cr>")
  vks("n", "<F2>", ":so %<cr>")

  vks("n", "]d", function()
    vim.diagnostic.jump({ count = -1, float = false })
  end)

  vks("n", "[d", function()
    vim.diagnostic.jump({ count = 1, float = false })
  end)

  vks("n", "gd", vim.lsp.buf.definition, { desc = "LSP: Go to definition" })
end

-----------
-- NETRW --
-----------

do
  local g = vim.g

  g.netrw_banner    = 0
  g.netrw_keepdir   = 0
  g.netrw_list_hide = "\\(^\\|\\s\\s\\)\\zs\\.\\S\\+"

  local au_group     = vim.api.nvim_create_augroup("netrw-group", { clear = true })

  local au_pattern   = { 'netrw' }

  local au_callback  = function()
    local opt = { silent = true, buffer = true, remap = true }
    local vks = vim.keymap.set
    vks("n", "<esc>", ":Sayonara!<cr>", opt)
    vks("n", "h",     "-",              opt)
    vks("n", "l",     "<cr>",           opt)
    vks("n", ".",     "gh",             opt)
    vks("n", "H",     "h",              opt)
  end

  vim.api.nvim_create_autocmd("FileType", {
    group     = au_group,
    pattern   = au_pattern,
    callback  = au_callback,
  })
end

--------------
-- PACKAGES --
--------------

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

  local delpkg

  delpkg = vim.iter(vim.pack.get())
  delpkg = delpkg:filter(function(x) return not x.active end)
  delpkg = delpkg:map(function(x) return x.spec.name end)
  delpkg = delpkg:totable()

  if next(delpkg) then
    vim.pack.del(delpkg)
  end
end

-----------------
-- DIAGNOSTICS --
-----------------

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

----------------
-- TREESITTER --
----------------

do
  local au_group    = vim.api.nvim_create_augroup("ts-group", { clear = true })

  local au_pattern  = { "go", "lua", "scheme", "fennel" }

  local au_callback = function()
    vim.treesitter.start()
  end

  vim.api.nvim_create_autocmd("FileType", {
    group     = au_group,
    pattern   = au_pattern,
    callback  = au_callback,
  })
end

---------
-- LSP --
---------

do
  vim.lsp.config('lua_ls', {
    settings = { Lua = { diagnostics = { globals = { 'vim', 'require' } } } }
  })

  vim.lsp.config('gopls', {})

  require("mason").setup()
  require("mason-lspconfig").setup()
end

--------
-- GO --
--------

do
  local au_group     = vim.api.nvim_create_augroup('go-group', { clear = true })

  local au_pattern   = { '*.go' }

  local au_callback  = function()
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
    group     = au_group,
    pattern   = au_pattern,
    callback  = au_callback
  })
end

-----------
-- BLINK --
-----------

do
  require("blink.cmp").setup()
end

-----------------
-- COLORSCHEME --
-----------------

do
  local fg = {
    black  = "#070707",
    gray   = "#9197a2",
    blue   = "#0047a7",
    cyan   = "#007a7a",
    green  = "#077700",
    orange = "#9f6e00",
    brown  = "#a06c12",
    red    = "#982717",
    purple = "#8120a6",
  }

  local bg = {
    white  = "#faf9f8",
    yellow = "#f0f0d1",
    gray   = "#e7e7e7",
  }

  local hi = {
    -- VIM
    DiagnosticError               = { fg = fg.red },
    Visual                        = { bg = bg.yellow },
    Search                        = { bg = bg.yellow },
    IncSearch                     = { bg = bg.yellow },
    CurSearch                     = { bg = bg.yellow },
    StatusLine                    = { bg = bg.gray },
    Directory                     = { fg = fg.blue   },
    ['@keyword.vim']              = { fg = fg.string },
    ['@variable.builtin.vim']     = { fg = fg.string },
    ['@constant.vim']             = { fg = fg.string },

    -- CODE
    Boolean                       = { fg = fg.pink },
    Float                         = { fg = fg.blue },
    Function                      = { bold = false },
    Keyword                       = { fg = fg.red, bold = false },
    Number                        = { fg = fg.blue, bold = false },
    Statement                     = { fg = fg.red },
    String                        = { fg = fg.green, italic = false },
    Type                          = { fg = fg.const, italic = false, bold = false },

    -- LEAP (PLUGIN)
    LeapLabel                     = { bg = bg.yellow },

    -- LUA
    ['@function.builtin.lua']     = { bold = false },
    ['@function.call.lua']        = { bold = false },
    ['@function.lua']             = { bold = false },
    ['@lsp.type.function.lua']    = { bold = false },
    ['@lsp.type.method.lua']      = { bold = false },
    ['@string.escape.lua']        = { fg = fg.green },
    ['@boolean.lua']              = { fg = fg.purple },

    -- SCHEME
    ['@operator.scheme']          = { fg = fg.brown },
    ['@keyword.scheme']           = { fg = fg.red },
    ['@number.scheme']            = { fg = fg.blue },
    ['@conceal.scheme']           = { fg = fg.red },
    ['@variable.scheme']          = { fg = "none" },
    ['@string.special.symbol.scheme'] = { fg = fg.blue },

    -- GO
    ['goFormatSpecifier']         = { fg = fg.green },
    ['goBuiltins']                = { fg = fg.red },

    ['@type.go']                  = { fg = fg.black },
    ['@function.call.go']         = { bold = false },
    ['@function.go']              = { bold = false },
    ['@function.builtin.go']      = { fg = fg.red, bold = true },
    ['@constant.go']              = { fg = fg.black },
    ['@constant.builtin.go']      = { fg = fg.cyan },
    ['@function.method.call.go']  = { bold = false },
    ['@function.method.go']       = { bold = false },
    ['@keyword.return.go']        = { fg = fg.red, bold = false },
    ['@keyword.import.go']        = { fg = fg.red, bold = false },
    ['@lsp.type.function.go']     = { bold = false },
    ['@string.escape.go']         = { fg = fg.green },

    -- C
    ['cStorageClass']             = { fg = fg.black },
    ['cInclude']                  = { fg = fg.black },
    ['cFormat']                   = { fg = fg.green },
    ['cSpecial']                  = { fg = fg.green },
    ['cStructure']                = { fg = fg.red },
    ['cOperator']                 = { fg = fg.black },
    ['cBlock']                    = { fg = fg.black },
    ['cConstant']                 = { fg = fg.cyan },
  }

  require("koda").setup({
    colors = {
      bg    = bg.white,
      fg    = fg.black,
      info  = fg.blue,
    },
    on_highlights = function(hl, _colors)
      for k, v in pairs(hi) do
        hl[k] = v
      end
    end
  })

  vim.cmd("colorscheme koda")
end

