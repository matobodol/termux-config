local ok, lualine = pcall(require, "lualine")
if not ok then
	return
end
local icons = require("var.icons")

lualine.setup({
	options = {
		icons_enabled = true,
		theme = "auto",
		component_separators = icons.separators.component,
		section_separators = icons.separators.section,
		disabled_filetypes = {},
		always_divide_middle = true,
	},

	sections = {
		lualine_a = {
			{
				"mode",
				fmt = function(str)
					return str
				end,
			},
		},

		lualine_b = { "branch", "diff", "diagnostics" },

		lualine_c = {
			{
				"filename",
				icon = icons.kinds.File,
				file_status = true,
				path = 1, -- Path relatif
				symbols = {
					modified = '  ',
					readonly = '  ',
					unnamed = ' [No Name] ',
					newfile = '  ',
				}
			},
		},

		lualine_x = { "encoding", "fileformat", "filetype" },
		lualine_y = { "progress" },
		lualine_z = { "location" },
	},

	inactive_sections = {
		lualine_a = {},
		lualine_b = {},
		lualine_c = { "filename" },
		lualine_x = { "location" },
		lualine_y = {},
		lualine_z = {},
	},

	tabline = {},
	extensions = { "nvim-tree" },
})
