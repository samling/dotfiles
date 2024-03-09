return {
  'echasnovski/mini.bufremove',
    -- stylua: ignore
    keys = {
      { "<leader>bd", function() require("mini.bufremove").delete(0, false) end, desc = "[d] Delete Buffer" },
      { "<leader>bD", function() require("mini.bufremove").delete(0, true) end, desc = "[D] Delete Buffer (Force)" },
    },
}
