-- compiler/abi.lua

-- Define a utility function for mapping over a table
local function map(tbl, func)
  local result = {}
  for i, v in ipairs(tbl) do
    result[i] = func(v)
  end
  return result
end

local function extract(contract)
  local abi = {}

  for name, clause in pairs(contract.clauses or {}) do
    table.insert(abi, {
      type = "function",
      name = name,
      inputs = {}, -- infer later from calldata
      outputs = {} -- empty for now
    })
  end

  for signal, args in pairs(contract.signals or {}) do
    table.insert(abi, {
      type = "event",
      name = signal,
      inputs = map(args, function(t)
        return { type = t }
      end)
    })
  end

  return abi
end

return {
  extract = extract
}
