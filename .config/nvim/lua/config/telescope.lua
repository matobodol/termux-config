local ok, telescope = pcall(require, "telescope")
if not ok then
	return
end

telescope.setup({
	defaults = {
		layout_strategy = "vertical",
		layout_config = {
			height = 0.8,
			width = 0.8,
		},
	},
})
