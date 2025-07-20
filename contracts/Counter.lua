local M = {}

M.storage = {
  count = 0
}

M.transient = {}

M.signals = {
  Incremented = { "uint256" }
}

M.clauses = {
  increment = function(calldata)
    M.storage.count = M.storage.count + 1
    M:emit("Incremented", M.storage.count)
  end
}

function M:emit(name, ...)
  print("🟢 Emitted:", name, ...)
end

return M
