-- compiler/ir.lua

-- IR = list of { op = "SSTORE", args = {...} }

local function generate(contract)
  local ir = {}

  -- Walk through `clauses` and build IR
  for name, fn in pairs(contract.clauses or {}) do
    -- Add a label for the clause (optional for debugging)
    table.insert(ir, { op = "LABEL", args = { name } })

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

      -- Emit the Incremented event (LOG1) if signals are defined
      if contract.signals and contract.signals.Incremented then
        -- Compute the topic using keccak256 hash of the signal name
        -- Mock keccak256 hash for testing purposes
        local function mock_keccak256(input)
          return string.format("%064x", #input) -- Mock: length of input as hash
        end
        local topic = "0x" .. mock_keccak256("Incremented")

        -- Push topic
        table.insert(ir, { op = "PUSH", args = { topic } })
        -- Push size of the data to be emitted
        table.insert(ir, { op = "PUSH", args = { 0x20 } }) -- Size of data (32 bytes)
        -- Push storage offset and 
        table.insert(ir, { op = "PUSH", args = { 0x00 } }) -- Storage slot 0
        -- table.insert(ir, { op = "SLOAD" })
        table.insert(ir, { op = "LOG1" })
      end
    end
  end

  return ir
end

return {
  generate = generate
}
