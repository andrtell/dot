--/ OPTS /--

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

--/ KEYS /--

vim.g.mapleader      = " "
vim.g.maplocalleader = ","

do
  local keys = {
    {'i',   'jk',     '<esc>'},
    {'n',   '<c-h>',  '<c-w><c-h>'},
    {'n',   '<c-l>',  '<c-w><c-l>'},
    {'n',   '<c-j>',  '<c-w><c-j>'},
    {'n',   '<c-k>',  '<c-w><c-k>'},
    {'n',   '*',      'g*'},
    {'n',   '<bs>',   ':nohl<cr>'},
    {'n',   '-',      ':Ex<cr>'},
    {'n',   '[b',     ':bprevious<cr>'},
    {'n',   ']b',     ':bnext<cr>'},
    {'n',   's',      '<Plug>(leap)'},
    {'n',   'S',      '<Plug>(leap-from-window)'},
    {'n',   '<F8>',   ':e $HOME/.config/nvim/init.lua<cr>'},
    {'n',   '<F2>',   ':so %<cr>'},
    {'n',   'gd',     vim.lsp.buf.definition},
  }

  for _, t in ipairs(keys) do vim.keymap.set(unpack(t)) end
end

--/ PACK /--

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
  local pkgs = vim.iter(vim.pack.get())
    :filter(function(x) return not x.active end)
    :map(function(x) return x.spec.name end)
    :totable()

  if next(pkgs) then
    vim.pack.del(pkgs)
  end
end

--/ LSP /--

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

--/ DIAGNOSTIC /--

vim.diagnostic.enable = true

vim.diagnostic.config({
  signs = false,
  virtual_text = {
    prefix = "←"
  }
})

--/ TREESITTER /--

do
  local e = 'FileType'

  local p = { 'c', 'lua', 'go', 'scheme' }

  local g = vim.api.nvim_create_augroup("treesitter", { clear = true })

  local f = function()
    vim.treesitter.start()
  end

  vim.api.nvim_create_autocmd(e, { pattern = p, group = g, callback = f })
end

--/ NETRW /--

vim.g.netrw_banner    = 0
vim.g.netrw_keepdir   = 0
vim.g.netrw_list_hide = "\\(^\\|\\s\\s\\)\\zs\\.\\S\\+"

do
  local e = 'Filetype'

  local p = { 'netrw' }

  local g = vim.api.nvim_create_augroup("netrw", { clear = true })

  local f = function()
    local opts = { silent = true, buffer = true, remap = true }
    local keys = {
      {'n', '<esc>', ':Sayonara!<cr>', opts},
      {'n', 'h',     '-',              opts},
      {'n', 'l',     '<cr>',           opts},
      {'n', '.',     'gh',             opts},
      {'n', 'H',     'h',              opts},
    }
    for _, t in ipairs(keys) do vim.keymap.set(unpack(t)) end
  end

  vim.api.nvim_create_autocmd(e, { pattern = p, group = g, callback = f })
end

--/ GO /--

do
  local e = 'BufWritePre'

  local p = { '*.go' }

  local g = vim.api.nvim_create_augroup('golang', { clear = true })

  local f = function()
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

    vim.lsp.buf.format({ async = false })
  end

  vim.api.nvim_create_autocmd(e, { pattern = p, group = g, callback = f })
end

--/ BLINK /--

require("blink.cmp").setup()

--/ COLORSCHEME /--

vim.cmd("colorscheme zero-light")
