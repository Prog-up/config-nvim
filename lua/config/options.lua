-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- The setup below will automatically configure connections without the need for manual input each time.

-- Example configuration using dictionary with keys:
vim.g.dbs = {
  dev = "jdbc:postgresql://localhost:5432/roger_roger",
  staging = "jdbc:postgresql://localhost:5432/roger_roger",
}
-- or
-- Example configuration using a list of dictionaries:
--    vim.g.dbs = {
--      { name = "dev", url = "Replace with your database connection URL." },
--      { name = "staging", url = "Replace with your database connection URL." },
--    }

-- or
-- Create a `.lazy.lua` file in your project and set your connections like this:
-- ```lua
--    vim.g.dbs = {...}
--
--    return {}
-- ```

-- Alternatively, you can also use other methods to inject your environment variables.

-- Finally, please make sure to add `.lazy.lua` to your `.gitignore` file to protect your secrets.
