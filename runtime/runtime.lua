-- runtime.lua

local Runtime = {}

-- Signal queue (for testing/event logs)
local signal_log = {}

-- Used by contracts to emit signals
function Runtime.signal(event_name, ...)
  table.insert(signal_log, {
    name = event_name,
    args = { ... }
  })
  Runtime.print_signals() -- Optional: print signals immediately for debugging
end

-- Used to simulate calldata inputs
function Runtime.call(contract, clause_name, calldata)
  local clause = contract.clauses[clause_name]
  if not clause then
    error("Clause '" .. clause_name .. "' not found")
  end
  return clause(calldata or {})
end

-- Clears all transient storage and signals after a call
function Runtime.reset(contract)
  for k, _ in pairs(contract.transient or {}) do
    contract.transient[k] = nil
  end
  signal_log = {}
end

-- Debug/Inspect the signal log
function Runtime.get_signal_log()
  return signal_log
end

-- Optional: pretty print
function Runtime.print_signals()
  for i, signal in ipairs(Runtime.get_signal_log()) do
    print("[" .. i .. "] " .. signal.name .. "(", table.concat(signal.args, ", "), ")")
  end
end

-- New: Simulate EVM bytecode execution
function Runtime.execute_bytecode(bytecode)
  local pc = 1 -- Program counter
  local stack = {}
  local storage = {}

  local function push(value)
    table.insert(stack, value)
  end

  local function pop()
    if #stack == 0 then
      error("Stack underflow")
    end
    return table.remove(stack)
  end

  -- Convert bytecode string to a table of bytes
  local function parse_bytecode(bytecode)
    local bytes = {}
    for i = 1, #bytecode, 2 do
      local byte = bytecode:sub(i, i + 1)
      if not byte:match("^[0-9a-fA-F]+$") then
        error("Invalid byte in bytecode: " .. byte)
      end
      table.insert(bytes, byte)
    end
    return bytes
  end

  -- Ensure the bytecode starts with '0x' and remove it
  if bytecode:sub(1, 2) == "0x" then
    bytecode = bytecode:sub(3)
  end

  local bytecode_bytes = parse_bytecode(bytecode)
  print("[DEBUG] Parsed Bytecode:", table.concat(bytecode_bytes, " "))

  while pc <= #bytecode_bytes do
    local opcode = bytecode_bytes[pc]
    pc = pc + 1

    print("[DEBUG] Executing opcode:", opcode, "at PC:", pc - 1)

    if opcode == "60" then -- PUSH1
      local value = tonumber(bytecode_bytes[pc], 16)
      pc = pc + 1
      push(value)
    elseif opcode == "7f" then -- PUSH32
      local value = ""
      for i = 1, 32 do
        value = value .. bytecode_bytes[pc]
        pc = pc + 1
      end
      push(tonumber(value, 16))
    elseif opcode == "54" then -- SLOAD
      local key = pop()
      push(storage[key] or 0)
    elseif opcode == "55" then -- SSTORE
      local value = pop()
      local key = pop()
      storage[key] = value
    elseif opcode == "01" then -- ADD
      local a = pop()
      local b = pop()
      push(a + b)
    elseif opcode == "a1" then -- LOG1
      local value = pop()
      Runtime.signal("LOG1", value)
    elseif opcode == "a0" then -- LOG0
      local value = pop()
      Runtime.signal("LOG0", value)
    else
      error("Unknown opcode: " .. opcode)
    end
  end

  return storage
end

return Runtime