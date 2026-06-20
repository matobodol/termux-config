local ok, ufo = pcall(require, "ufo")

if not ok then
	return
end

-- foldopen=block,hor,mark,percent,quickfix,search,tag,undo
vim.opt.foldopen = "search,undo"
-- setting global folding
vim.o.foldcolumn = "0" -- kolom lipatan di kiri
vim.o.foldlevel = 99   -- buka semua fold saat file dibuka
vim.o.foldlevelstart = 99
vim.o.foldenable = true

ufo.setup({
	provider_selector = function(bufnr, filetype, buftype)
		return { "treesitter", "indent" }
	end
})

vim.keymap.set("n", "zR", ufo.openAllFolds)
vim.keymap.set("n", "zM", ufo.closeAllFolds)

vim.keymap.set("n", "zr", ufo.openFoldsExceptKinds)
vim.keymap.set("n", "zm", ufo.closeFoldsWith)

vim.keymap.set("n", "zp", function()
	ufo.peekFoldedLinesUnderCursor()
end, { desc = "Preview folded code" })
