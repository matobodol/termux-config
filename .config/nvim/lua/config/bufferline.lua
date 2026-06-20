local ok, bufferline = pcall(require, "bufferline")
if not ok then
	return
end

bufferline.setup({
	options = {
		mode = 'buffers',
		offsets = {
			{
				filetype = 'NvimTree',
				text = "File Explorer",
				text_align = "center", --"left", | "center" | "right"
				separator = true,
			}
		},
		numbers = 'none',
		indicator = {
			icon = '▎', --'▎', -- this should be omitted if indicator style is not 'icon'
			style = 'icon' -- 'icon' | 'underline' | 'none',
		},
		diagnostics = 'nvim_lsp',
		diagnostics_indicator = function(count, level)
			local icon = level:match("error") and " " or " "
			return " " .. icon .. count
		end,
		separator_style = 'thin', --"slant" | "slope" | "thick" | "thin" | { 'any', 'any' },
		show_tab_indicators = true,
		show_buffer_close_icons = false,
		show_close_icon = false,
		sort_by = 'insert_at_end',
		pick = {
			alphabet = "abcdefghijklmopqrstuvwxyzabcdefghijklmopqrstuvwxyz1234567890",
		},
	}
})
