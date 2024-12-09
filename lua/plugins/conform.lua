return {
	-- Conform for formatting
	{
		"stevearc/conform.nvim",
		optional = true,
		opts = {
			-- Define formatters for C files
			formatters_by_ft = {
				c = { "clang-format" },
				java = { "google-java-format" },
			},
			-- Format on save configuration
			format_on_save = {
				-- These options will be passed to conform.format()
				timeout_ms = 500,
				lsp_fallback = true,
			},
			-- Specific configuration for clang-format
			formatters = {
				clang_format = {
					-- You can specify a custom style file if needed
					prepend_args = { "-style=file" },
				},
			},
		},
	},
}
