-------------
-- OPTIONS -- 
-------------

do
    local opt       = vim.opt

    opt.background  = "light"
    opt.breakindent = true
    opt.clipboard   = "unnamedplus"
    opt.cursorline  = false
    opt.gdefault    = true
    opt.ignorecase  = true
    opt.laststatus  = 3
    opt.mouse       = "a"
    opt.number      = false
    opt.scrolloff   = 15
    opt.shortmess   = "Ita"
    opt.showcmd     = false
    opt.showmode    = false
    opt.signcolumn  = "yes:1"
    opt.smartcase   = true
    opt.statusline  = " %f %m%r %= %{&filetype} | %n | %{&fenc} | %3l : %2c  "
    opt.swapfile    = false
    opt.timeoutlen  = 300
    opt.updatetime  = 250
    opt.winborder   = "rounded"

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

    local keymap = vim.keymap

    keymap.set("i", "jk", "<esc>")
    keymap.set("n", "*", "g*")
    keymap.set("n", "<bs>", ":nohl<cr>")
    keymap.set("n", "-", ":Ex<cr>")
    keymap.set("n", "<c-h>", "<c-w><c-h>")
    keymap.set("n", "<c-l>", "<c-w><c-l>")
    keymap.set("n", "<c-j>", "<c-w><c-j>")
    keymap.set("n", "<c-k>", "<c-w><c-k>")
    keymap.set("n", "[b", ":bprevious<cr>")
    keymap.set("n", "]b", ":bnext<cr>")
    keymap.set("n", "s", "<Plug>(leap)")
    keymap.set("n", "S", "<Plug>(leap-from-window)")

    keymap.set("n", "]d", function()
        vim.diagnostic.jump({ count = -1, float = false })
    end)

    keymap.set("n", "[d", function()
        vim.diagnostic.jump({ count = 1, float = false })
    end)

    vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "LSP: Go to definition" })

    -- vim.keymap.set("n", "grt", vim.lsp.buf.type_definition, { desc = "LSP: Type Definition" })
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
    local keymap = vim.keymap

    api.nvim_create_autocmd("FileType", {
        pattern = { 'netrw' },
        group = api.nvim_create_augroup("NETRW", { clear = true }),
        callback = function()
            local o = { silent = true, buffer = true, remap = true }

            keymap.set("n", "<esc>", ":Sayonara!<cr>", o)
            keymap.set("n", "h", "-", o)
            keymap.set("n", "l", "<cr>", o)
            keymap.set("n", ".", "gh", o)
            keymap.set("n", "H", "h", o)
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

-----------
-- GUILE --
-----------

do
    local g = vim.g

    g["conjure#filetype#scheme"] = "conjure.client.guile.socket"
    g["conjure#client#guile#socket#pipename"] = ".guile-repl.socket"
end

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
        pattern = { "go", "lua" },
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
    local pal = {
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

    require("koda").setup({
        colors = {
            -- bg 	= pal.white,
            fg 	= pal.black,
            comment = pal.gray,
            const   = pal.orange,
            info    = pal.blue,
            cyan    = pal.cyan,
            green   = pal.green,
            pink    = pal.purple,
            red     = pal.red,
        },
        on_highlights = function(hl, c)
            hl.Boolean = { fg = c.pink }
            hl.Float = { fg = c.info }
            hl.Keyword = { fg = c.red, bold=false }
            hl.Function = { bold=false }
            hl.Statement = { fg = c.red }
            hl.DiagnosticError = { fg = c.red }
            hl.Search = { bg = pal.yellow }
            hl.IncSearch = { bg = pal.yellow }
            hl.CurSearch = { bg = pal.yellow }

            hl.Number = { fg = c.info, bold = false }
            hl.String = { fg = pal.green, italic = false }

            hl.Type = { fg = c.const, italic = false, bold = false }
            hl['@type.go'] = { fg = c.fg }
            -- hl['@type.definition.go'] = { fg = c.const }
            -- hl['@type.definition.go'] = { fg = c.const }

            hl.LeapLabel = { bg = pal.yellow }


            hl['@keyword.vim'] = { fg = c.string }
            hl['@variable.builtin.vim'] = { fg = c.string }
            hl['@constant.vim'] = { fg = c.string }

            hl['@function.builtin.lua'] = { bold = false }
            hl['@function.call.lua'] = { bold = false }
            hl['@function.lua'] = { bold = false }
            hl['@lsp.type.function.lua'] = { bold = false }
            hl['@lsp.type.method.lua'] = { bold = false }
            hl['@string.escape.lua'] = { fg = c.string }

            hl['@function.call.go'] = { bold = false }
            hl['@function.go'] = { bold = false }
            hl['@function.builtin.go'] = { bold = true, fg = c.red }
            hl['@constant.go'] = { fg = c.fg }
            hl['@constant.builtin.go'] = { fg = c.cyan }
            hl['@function.method.call.go'] = { bold = false }
            hl['@function.method.go'] = { bold = false }
            hl['@keyword.return.go'] = { fg = c.red, bold = false }
            hl['@keyword.import.go'] = { fg = c.red, bold = false }
            hl['@lsp.type.function.go'] = { bold = false }
            hl['@string.escape.go'] = { fg = c.green }

            -- hl['@type.definition.go'] = { fg = c.const }

            hl['goFormatSpecifier'] = { fg = c.string }
            hl['goBuiltins'] = { fg = c.red }

            hl['cStorageClass'] = { fg = c.fg }
            hl['cInclude'] = { fg = c.fg }
            hl['cFormat'] = { fg = c.string }
            hl['cSpecial'] = { fg = c.string }
            hl['cStructure'] = { fg = c.red }
            hl['cOperator'] = { fg = c.fg }
            hl['cBlock'] = { fg = c.fg }
            hl['cConstant'] = { fg = c.cyan }
        end
    })

    vim.cmd("colorscheme koda")
end

