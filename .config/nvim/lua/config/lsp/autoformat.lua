local M = {}

M.lsp_formatting = function(bufnr)
	vim.lsp.buf.format({
		filter = function(client)
			return client.name == "null-ls"
		end,
		bufnr = bufnr,
	})
end

local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

M.on_attach = function(client, bufnr)
	if client.supports_method("textDocument/formatting") then
		vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
		vim.api.nvim_create_autocmd("BufWritePre", {
			group = augroup,
			buffer = bufnr,
			callback = function()
				M.lsp_formatting(bufnr)
			end,
		})
	end
end

function M.enable_format_on_save()
	vim.cmd [[
		augroup format_on_save
		autocmd!
		autocmd BufWritePre * lua vim.lsp.buf.format({ async = false })
		augroup end
		]]
	vim.notify "Format on save is enable"
end

function M.disable_format_on_save()
	M.remove_augroup "format_on_save"
	vim.notify "Format on save is disable"
end

function M.toggle_format_on_save()
	if vim.fn.exists "#format_on_save#BufWritePre" == 0 then
		M.enable_format_on_save()
	else
		M.disable_format_on_save()
	end
end

function M.remove_augroup(name)
	if vim.fn.exists("#" .. name) == 1 then
		vim.cmd("au! " .. name)
	end
end

-- vim.cmd [[ command! LspToggleAutoFormat execute 'lua ]]

M.enable_format_on_save()
vim.keymap.set('n', '<leader>tf', M.toggle_format_on_save, { desc = "Toggle Autoformat", noremap = true, silent = true })
