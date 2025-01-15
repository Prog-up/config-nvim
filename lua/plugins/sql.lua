return {
	"nanotee/sqls.nvim",
	on_attach = function(client, bufnr)
		require("sqls").on_attach(client, bufnr)
	end,
}
