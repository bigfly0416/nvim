local opts = { noremap = true, silent = true }

-- Shorten function name
local mp = vim.api.nvim_set_keymap

--Remap space as leader key
mp("", "<Space>", "<Nop>", opts)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- always display file full path
mp("n", "<C-g>", "1<C-g>", opts)

mp("n", "j", "gj", opts)
mp("n", "k", "gk", opts)

-- move between wrapped lines smooth
mp("n", "gj", "j", opts)
mp("n", "gk", "k", opts)
mp("n", "gh", "<nop>", opts)


-- Better window navigation
mp("n", "<C-h>", "<cmd>:TmuxNavigateLeft<cr>", opts)
mp("n", "<C-j>", "<cmd>:TmuxNavigateDown<cr>", opts)
mp("n", "<C-k>", "<cmd>:TmuxNavigateUp<cr>", opts)
mp("n", "<C-l>", "<cmd>:TmuxNavigateRight<cr>", opts)
mp("n", "<C-c>", "<C-w>c", opts)
mp("n", "<S-l>", ":bnext<CR>", opts)
mp("n", "<S-h>", ":bprevious<CR>", opts)

-- Resize with arrows
mp("n", "<C-Up>", ":resize -2<cr>", opts)
mp("n", "<C-Down>", ":resize +2<cr>", opts)
mp("n", "<C-Left>", ":vertical resize -2<cr>", opts)
mp("n", "<C-Right>", ":vertical resize +2<cr>", opts)

-- Visual --
-- Stay in indent mode
mp("n", ">", ">>", opts)
mp("n", "<", "<<", opts)
mp("v", "<", "<gv", opts)
mp("v", ">", ">gv", opts)

-- avoid overriding of register
-- use leader + d to override register
mp("v", "p", '"_dp', opts)
mp("v", "P", '"_dP', opts)


mp("n", "<F7>", ":DapStepInto<cr>", opts)
mp("n", "<F8>", ":DapStepOver<cr>", opts)
mp("n", "<F9>", ":DapContinue<cr>", opts)
mp("n", "mm", ":DapToggleBreakpoint<cr>", opts)
