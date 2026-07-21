vim.cmd("packadd nvim.undotree")
vim.cmd("packadd nvim.difftool")


vim.api.nvim_create_user_command("PackAdd", function(opts)
  vim.pack.add(opts.fargs)
end, {nargs = "+", desc = "Add plugins (PackAdd user/repo)"}
)

vim.api.nvim_create_user_command("PackUpdate", function()
  vim.pack.update(nil, {force=true})
end, { desc = "Add plugins (PackAdd user/repo)"}
)

vim.api.nvim_create_user_command("PackCheck", function()
  local non_active = vim.iter(vim.pack.get())
  :filter(function(x) return not x.active end)
  :map(function(x) return x.spec.name end)
  :totable()

  if #non_active == 0 then
    vim.notify("No inactive plugins found!", vim.log.levels.INFO)
    return
  end

  vim.print("Inactive Plugins: ")
  print(" ")

  for _, name in ipairs(non_active) do
    print(name)
  end

  print(" ")

  local choice = vim.fn.confirm(
    "Delete ALL Inactive Plugins from disk?",
    "&Yes\n&No",
    2)

  if choice ==1 then
    vim.pack.del(non_active)
    vim.notify("Deleted " .. #non_active .. " non-active plugin(s)", vim.log.levels.INFO)
    print("Non active plugins deleted")
    vim.api.nvim_exec_autocmds("User", {pattern = "PackChanged"})
  else
    vim.notify("Cancelled. No Plugins were deleted", vim.log.levels.INFO)
  end

end, {desc = "Check for Downloaded packages"})
