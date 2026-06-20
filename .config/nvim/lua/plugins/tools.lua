return {
	-- Telescope
	{
		"nvim-telescope/telescope.nvim",
		cmd = "Telescope", -- Load saat command dipanggil
		keys = {
			{ "<leader>ff", "<cmd>Telescope find_files<cr>" },
			{ "<leader>fg", "<cmd>Telescope live_grep<cr>" },
			{ "<leader>fb", "<cmd>Telescope buffers<cr>" },
			{ "<leader>fo", "<cmd>Telescope oldfiles<cr>" },
			{ "<leader>fn", "<cmd>Telescope notify<cr>" },
			{ "<leader>fk", "<cmd>Telescope keymaps<cr>" },
		},
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-telescope/telescope-fzf-native.nvim",
		},
		config = function()
			require("config.telescope")
		end,
	},

	{
		"nvim-telescope/telescope-fzf-native.nvim",
		build = "make",                    -- Compile saat install
		cond = vim.fn.executable("make") == 1, -- Conditional install
	},

	--toggleterm
	{
		"akinsho/toggleterm.nvim",
		version = "*",
		config = function()
			local toggleterm = require("toggleterm")

			toggleterm.setup({
				size = function(term)
					if term.direction == "horizontal" then
						return 20
					elseif term.direction == "vertical" then
						return math.floor(vim.o.columns * 0.50)
					end
				end,

				-- open_mapping = nil,
				open_mapping = [[<M-i>]],

				hide_numbers = true,
				shade_terminals = true,
				shading_factor = 2,

				start_in_insert = true,
				insert_mappings = true,
				terminal_mappings = true,

				persist_size = true,
				persist_mode = true,
				persist_session = true,

				direction = "float",

				float_opts = {
					border = "rounded",
					width = math.floor(vim.o.columns * 0.85),
					height = math.floor(vim.o.lines * 0.65),
					winblend = 0,
				},
			})
			require("config.toggleterm")
		end,
	},

	{
		"NvChad/nvim-colorizer.lua",
		config = function()
			require("colorizer").setup({
				"*",
			}, {
				mode = "background",
				names = false,
			})
		end,
	},
}
