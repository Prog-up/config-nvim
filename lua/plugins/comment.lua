-- Additional plugins for C development
  -- Comment.nvim to quickly comment/uncomment code
return{
  {
    "numToStr/Comment.nvim",
    config = function()
      require('Comment').setup()
    end
  },
}
