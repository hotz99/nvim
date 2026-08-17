local function find_setup_policy()
  local filename = vim.api.nvim_buf_get_name(0)
  local directory = filename ~= "" and vim.fs.dirname(filename) or vim.fn.getcwd()

  local function policy_in(path)
    local policy = vim.fs.joinpath(path, ".omp", "oxlint.config.json")
    return vim.uv.fs_stat(policy) and policy or nil
  end

  local policy = policy_in(directory)
  if policy then
    return policy
  end

  for parent in vim.fs.parents(directory) do
    policy = policy_in(parent)
    if policy then
      return policy
    end
  end
end

local function oxlint()
  local linter = vim.deepcopy(require("lint.linters.oxlint"))
  linter.args = { "--format", "github", "--type-aware" }

  local policy = find_setup_policy()
  if policy then
    vim.list_extend(linter.args, { "--config", policy })
  end

  return linter
end

return {
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters = {
        oxlint = oxlint,
      },
      linters_by_ft = {
        javascript = { "oxlint" },
        javascriptreact = { "oxlint" },
        typescript = { "oxlint" },
        typescriptreact = { "oxlint" },
      },
    },
  },
}
