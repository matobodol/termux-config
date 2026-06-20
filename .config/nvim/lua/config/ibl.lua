local ok, ibl = pcall(require, "ibl")
if not ok then
	return
end


ibl.setup({
	enabled = true,
	debounce = 300,
	indent = {
		char = "│", --center
		smart_indent_cap = true,
	},
	scope = { enabled = false, },
})
vim.keymap.set('n', '<leader>ti', '<cmd>IBLToggle<cr>')

local mini_ok, mini = pcall(require, "mini.indentscope")
if not mini_ok then
	return
end

mini.setup({
	symbol = "│", --center
	options = {
		try_as_border = true
	},
	draw = {
		-- Delay (in ms) between event and start of drawing scope indicator
		delay = 300,
		-- Symbol priority. Increase to display on top of more symbols.
		priority = 2,
	},
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = {
		"lsp",
		"help",
		"alpha",
		"dashboard",
		"neo-tree",
		"Trouble",
		"lazy",
		"mason",
		"notify",
		"toggleterm",
		"lazyterm",
		"NvimTree",
		"File Explorer",
		"terminal",
	},
	callback = function()
		vim.b.miniindentscope_disable = true
	end,
})
