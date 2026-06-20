-- install by mason
local ensure_installed = {
	"bashls",
	"pyright",
}

require("mason").setup()
require("mason-lspconfig").setup({
	ensure_installed = ensure_installed,
	automatic_installation = false,
})

-- load from os paket manager
local servers = {
	"lua_ls",
	"rust_analyzer",
}


local servers_mason = require("mason-lspconfig").get_installed_servers()
for _, lsp_installed in ipairs(servers_mason) do
	table.insert(servers, lsp_installed)
end

local capabilities = require("cmp_nvim_lsp").default_capabilities()
local status_navic_ok, nvim_navic = pcall(require, "nvim-navic")

for _, lsp in ipairs(servers) do
	local opts = {
		capabilities = capabilities,
		on_attach = function(client, bufnr)
			if status_navic_ok and client.server_capabilities["documentSymbolProvider"] then
				nvim_navic.attach(client, bufnr)
			end
		end,
	}

	-- LOAD LANGUAGE SETTINGS
	local ok, language_setting = pcall(require, "config.lsp.language." .. lsp)
	if ok and type(language_setting) == "table" then
		opts.settings = language_setting
	end

	-- integrasi nvim-navic
	vim.lsp.config(lsp, opts)
	vim.lsp.enable(lsp)
end
