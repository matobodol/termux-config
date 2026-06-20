-- Format Fungsi Baru (keymap.set)
--
-- vim.keymap.set(mode, key, command, options)
--
-- Format ini lebih fleksibel dan direkomendasikan untuk konfigurasi modern.
--
-- Mode Neovim untuk Keymap
-- n: Normal mode
-- i: Insert mode
-- v: Visual mode
-- x: Visual block mode
-- t: Terminal mode
-- c: Command mode
-- nvidol/core/keymaps.lua
vim.g.mapleader = " "

-- Window navigation
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Move to left window", noremap = true, silent = true })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Move to right window", noremap = true, silent = true })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Move to lower window", noremap = true, silent = true })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Move to upper window", noremap = true, silent = true })

-- Save / quit
vim.keymap.set("n", "<C-s>", ":w<CR>", { desc = "Save file", noremap = true, silent = true })
vim.keymap.set("n", "<C-q>", ":q<CR>", { desc = "Quit file", noremap = true, silent = true })
vim.keymap.set("n", "<C-a>", ":wa<CR>", { desc = "Save all files", noremap = true, silent = true })

-- Buffer navigation
vim.keymap.set("n", "<leader>bn", ":bnext<CR>", { desc = "Next buffer", noremap = true, silent = true })
vim.keymap.set("n", "<leader>bp", ":bprevious<CR>", { desc = "Previous buffer", noremap = true, silent = true })
vim.keymap.set("n", "<leader>bc", ":bdelete<CR>", { desc = "Close buffer", noremap = true, silent = true })

-- Visual indent & move
vim.keymap.set("v", "<", "<gv", { desc = "Indent left and stay in visual", noremap = true, silent = true })
vim.keymap.set("v", ">", ">gv", { desc = "Indent right and stay in visual", noremap = true, silent = true })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up", noremap = true, silent = true })
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down", noremap = true, silent = true })

-- Normal mode: join without moving cursor
vim.keymap.set("n", "J", "mzJ`z", { desc = "Join line below without moving cursor", noremap = true, silent = true })

-- Insert mode: escape quickly
vim.keymap.set("i", "jk", "<Esc>", { desc = "Exit insert mode", noremap = true, silent = true })

-- Scroll without moving cursor
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Scroll half page down", noremap = true, silent = true })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Scroll half page up", noremap = true, silent = true })

-- Search centering
vim.keymap.set("n", "n", "nzzzv", { desc = "Next search result centered", noremap = true, silent = true })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Previous search result centered", noremap = true, silent = true })
vim.keymap.set("n", "<leader>nh", ":nohlsearch<CR>", { desc = "Clear search highlight", noremap = true, silent = true })

-- Terminal
vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], { desc = "Exit terminal mode", noremap = true, silent = true })

-- Select all & reindent
vim.keymap.set("n", "<leader>in", "ggVG=<CR>", { desc = "Reindent entire buffer", noremap = true, silent = true })
vim.keymap.set("n", "<leader>a", ":keepjumps normal! ggVG<CR>",
	{ desc = "Select all text in buffer", noremap = true, silent = true })

-- Home / End line
vim.keymap.set({ "n", "x", "o" }, "<leader>h", "^", { desc = "Go to beginning of line" })
vim.keymap.set({ "n", "x", "o" }, "<leader>l", "g_", { desc = "Go to end of line" })

-- Clipboard
vim.keymap.set({ "n", "x" }, "cp", '"+y', { desc = "Copy to system clipboard" })
vim.keymap.set({ "n", "x" }, "cv", '"+p', { desc = "Paste from system clipboard" })

-- Delete without affecting registers
vim.keymap.set({ "n", "x" }, "x", '"_x', { desc = "Delete character without affecting register" })

-- Run Rust file
vim.keymap.set("n", "<Leader>c,", ':term cd %:h && RUSTFLAGS="-Awarnings" cargo run',
	{ desc = "Run Rust file in terminal", noremap = true, silent = false })

-- coder
vim.keymap.set({ "n", "t" }, "<M-0>", function()
	require("config.moduls.coder").run()
end, { desc = "Run current file" })

vim.keymap.set({ "n", "t" }, "<M-9>", function()
	require("config.moduls.coder").stop()
end, { desc = "Stop runner" })

vim.keymap.set({ "n", "t" }, "<M-8>", function()
	require("config.moduls.coder").toggle()
end, { desc = "Toggle runner" })


-- toggleterm
vim.keymap.set({ "n", "t" }, "<M-1>", function()
	require("config.toggleterm").horizontal()
end)

vim.keymap.set({ "n", "t" }, "<M-2>", function()
	require("config.toggleterm").vertical()
end)

vim.keymap.set({ "n", "t" }, "<M-3>", function()
	require("config.toggleterm").float()
end)
