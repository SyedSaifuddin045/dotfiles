return {
  {
    "kawre/leetcode.nvim",
    build = ":TSUpdate html",
    cmd = { "Leet" },
    dependencies = {
      "nvim-telescope/telescope.nvim",
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    opts = {
      lang = "cpp",
      plugins = {
        non_standalone = true,
      },
    },
  },
}
