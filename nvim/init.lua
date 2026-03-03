-------------
-- OPTIONS -- 
-------------

do
  local vo       = vim.opt

  vo.background  = "light"
  vo.breakindent = true
  vo.clipboard   = "unnamedplus"
  vo.cursorline  = false
  vo.gdefault    = true
  vo.ignorecase  = true
  vo.laststatus  = 3
  vo.mouse       = "a"
  vo.number      = false
  vo.scrolloff   = 15
  vo.shortmess   = "Itas"
  vo.showcmd     = false
  vo.showmode    = false
  vo.signcolumn  = "yes:1"
  vo.smartcase   = true
  vo.statusline  = " %f %m%r %= %{&filetype} | %n | %{&fenc} | %3l : %2c  "
  vo.swapfile    = false
  vo.timeoutlen  = 300
  vo.updatetime  = 250
  vo.winborder   = "single"

  vim.cmd("set noerrorbells visualbell t_vb=")
  vim.cmd("autocmd GUIEnter * set visualbell t_vb=")
end

----------
-- KEYS --
----------

do
  local g = vim.g

  g.mapleader = " "
  g.maplocalleader = ","

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

  g.netrw_banner = 0
  g.netrw_keepdir = 0
  g.netrw_list_hide = "\\(^\\|\\s\\s\\)\\zs\\.\\S\\+"

  local api = vim.api
  local vks = vim.keymap.set

  api.nvim_create_autocmd("FileType", {
    pattern = { 'netrw' },
    group = api.nvim_create_augroup("NETRW", { clear = true }),
    callback = function()
      local o = { silent = true, buffer = true, remap = true }

      vks("n", "<esc>", ":Sayonara!<cr>", o)
      vks("n", "h", "-", o)
      vks("n", "l", "<cr>", o)
      vks("n", ".", "gh", o)
      vks("n", "H", "h", o)
    end,
  })
end

--------------
-- PACKAGES --
--------------

do
  vim.pack.add({
    { src = "https://codeberg.org/andyg/leap.nvim.git" },
    { src = "https://github.com/mhinz/vim-sayonara" },
    { src = "https://github.com/oskarnurm/koda.nvim" },
    { src = "https://github.com/saghen/blink.cmp.git" },
    { src = "https://github.com/nvim-treesitter/nvim-treesitter.git" },
    { src = "https://github.com/neovim/nvim-lspconfig" },
    { src = "https://github.com/mason-org/mason.nvim.git" },
    { src = "https://github.com/mason-org/mason-lspconfig.nvim.git" },
    { src = "https://github.com/Olical/conjure.git" },
    { src = "https://github.com/Olical/nfnl.git" },
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

-----------
-- GUILE --
-----------

-- do
--   local g = vim.g
--
--   g["conjure#filetype#scheme"] = "conjure.client.guile.socket"
--   g["conjure#client#guile#socket#pipename"] = ".guile-repl.socket"
-- end

--------
-- GO --
--------

do
  vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = "*.go",
    callback = function()
      local params = vim.lsp.util.make_range_params(nil, "utf-16")
      params.context = {only = {"source.organizeImports"}}
      local timeout = 1000
      local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, timeout)
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
  })
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
  local api = vim.api
  api.nvim_create_autocmd("FileType", {
    pattern = { "go", "lua", "scheme", "fennel" },
    group = api.nvim_create_augroup("TS", { clear = true }),
    callback = function()
      vim.treesitter.start()
    end,
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
  local co = {
    white  = "#faf9f8",
    black  = "#070707",
    gray   = "#9197a2",
    blue   = "#0048a8",
    cyan   = "#007a7a",
    green  = "#077700",
    orange = "#9e6c00",
    red    = "#972616",
    purple = "#8120a6",
    yellow = "#eeeecf",
  }

  local hi = {
    -- VIM
    DiagnosticError               = { fg = co.red },
    Search                        = { bg = co.yellow },
    IncSearch                     = { bg = co.yellow },
    CurSearch                     = { bg = co.yellow },
    ['@keyword.vim']              = { fg = co.string },
    ['@variable.builtin.vim']     = { fg = co.string },
    ['@constant.vim']             = { fg = co.string },

    -- CODE
    Boolean                       = { fg = co.pink },
    Float                         = { fg = co.blue },
    Function                      = { bold = false },
    Keyword                       = { fg = co.red, bold = false },
    Number                        = { fg = co.blue, bold = false },
    Statement                     = { fg = co.red },
    String                        = { fg = co.green, italic = false },
    Type                          = { fg = co.const, italic = false, bold = false },

    -- LEAP (PLUGIN)
    LeapLabel                     = { bg = co.yellow },

    -- LUA
    ['@function.builtin.lua']     = { bold = false },
    ['@function.call.lua']        = { bold = false },
    ['@function.lua']             = { bold = false },
    ['@lsp.type.function.lua']    = { bold = false },
    ['@lsp.type.method.lua']      = { bold = false },
    ['@string.escape.lua']        = { fg = co.green },
    ['@boolean.lua']              = { fg = co.purple },

    -- GO
    ['goFormatSpecifier']         = { fg = co.green },
    ['goBuiltins']                = { fg = co.red },

    ['@type.go']                  = { fg = co.black },
    ['@function.call.go']         = { bold = false },
    ['@function.go']              = { bold = false },
    ['@function.builtin.go']      = { fg = co.red, bold = true },
    ['@constant.go']              = { fg = co.black },
    ['@constant.builtin.go']      = { fg = co.cyan },
    ['@function.method.call.go']  = { bold = false },
    ['@function.method.go']       = { bold = false },
    ['@keyword.return.go']        = { fg = co.red, bold = false },
    ['@keyword.import.go']        = { fg = co.red, bold = false },
    ['@lsp.type.function.go']     = { bold = false },
    ['@string.escape.go']         = { fg = co.green },

    -- C
    ['cStorageClass']             = { fg = co.black },
    ['cInclude']                  = { fg = co.black },
    ['cFormat']                   = { fg = co.green },
    ['cSpecial']                  = { fg = co.green },
    ['cStructure']                = { fg = co.red },
    ['cOperator']                 = { fg = co.black },
    ['cBlock']                    = { fg = co.black },
    ['cConstant']                 = { fg = co.cyan },
  }

  require("koda").setup({
    on_highlights = function(hl, c)
      for k, v in pairs(hi) do
        hl[k] = v
      end
    end
  })

  vim.cmd("colorscheme koda")
end

