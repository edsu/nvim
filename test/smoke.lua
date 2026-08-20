-- Assertion half of test/smoke.sh. Run against an already-open buffer:
--
--   WANT=ruff,ty MIN_DIAGS=1 nvim --headless +'edit main.py' +'luafile smoke.lua' +qa
--
-- Prints a single line beginning with "SMOKE ok" or "SMOKE fail", which the
-- shell script greps for.

local want = vim.split(vim.env.WANT or '', ',')
local min_diags = tonumber(vim.env.MIN_DIAGS or '0')
local timeout = tonumber(vim.env.TIMEOUT_MS or '40000')

local function attached_names()
  local names = {}
  for _, c in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
    table.insert(names, c.name)
  end
  table.sort(names)
  return names
end

local function missing_servers()
  local seen = {}
  for _, name in ipairs(attached_names()) do
    seen[name] = true
  end
  local missing = {}
  for _, w in ipairs(want) do
    if not seen[w] then
      table.insert(missing, w)
    end
  end
  return missing
end

-- Poll rather than sleeping a fixed amount: fast when healthy, patient when
-- a server is slow to index.
vim.wait(timeout, function()
  return #missing_servers() == 0 and #vim.diagnostic.get(0) >= min_diags
end, 200)

local missing = missing_servers()
local attached = table.concat(attached_names(), ',')
local diags = #vim.diagnostic.get(0)

if #missing > 0 then
  print(('SMOKE fail missing=%s attached=[%s]'):format(table.concat(missing, ','), attached))
elseif diags < min_diags then
  print(('SMOKE fail attached=%s produced %d diagnostics, wanted >=%d'):format(
    attached, diags, min_diags))
else
  print(('SMOKE ok attached=%s diagnostics=%d'):format(attached, diags))
end
