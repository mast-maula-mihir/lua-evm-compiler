-- compiler/ir.lua

-- IR = list of { op = "SSTORE", args = {...} }

local function generate(contract)
  local ir = {}

  -- Walk through `clauses` and build IR
  for name, fn in pairs(contract.clauses or {}) do
    if name == "increment" then
      -- Load the current value from storage (SLOAD)
      table.insert(ir, { op = "PUSH", args = { 0x00 } }) -- Storage slot 0
      table.insert(ir, { op = "SLOAD" })

      -- Increment the value (ADD)
      table.insert(ir, { op = "PUSH", args = { 1 } })
      table.insert(ir, { op = "ADD" })

      -- Store the new value back to storage (SSTORE)
      table.insert(ir, { op = "PUSH", args = { 0x00 } }) -- Storage slot 0
      table.insert(ir, { op = "SSTORE" })

      -- Emit the Incremented event (LOG1)
      table.insert(ir, { op = "PUSH", args = { 0x01 } }) -- Event signature hash (mocked)
      table.insert(ir, { op = "PUSH", args = { 0x00 } }) -- Storage slot 0
      table.insert(ir, { op = "SLOAD" })
      table.insert(ir, { op = "LOG1" })
    end
  end

  return ir
end

return {
  generate = generate
}
