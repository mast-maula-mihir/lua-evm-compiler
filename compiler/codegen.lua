-- compiler/codegen.lua

local opcodes = {
  STOP = "00",
  ADD = "01",
  MUL = "02",
  SUB = "03",
  DIV = "04",
  SDIV = "05",
  MOD = "06",
  SMOD = "07",
  EXP = "0a",
  SIGNEXTEND = "0b",
  LT = "10",
  GT = "11",
  EQ = "14",
  ISZERO = "15",
  AND = "16",
  OR = "17",
  XOR = "18",
  NOT = "19",
  BYTE = "1a",
  SHA3 = "20",
  ADDRESS = "30",
  BALANCE = "31",
  ORIGIN = "32",
  CALLER = "33",
  CALLVALUE = "34",
  CALLDATALOAD = "35",
  CALLDATASIZE = "36",
  CALLDATACOPY = "37",
  CODESIZE = "38",
  CODECOPY = "39",
  GASPRICE = "3a",
  EXTCODESIZE = "3b",
  EXTCODECOPY = "3c",
  RETURNDATASIZE = "3d",
  RETURNDATACOPY = "3e",
  BLOCKHASH = "40",
  COINBASE = "41",
  TIMESTAMP = "42",
  NUMBER = "43",
  DIFFICULTY = "44",
  GASLIMIT = "45",
  POP = "50",
  MLOAD = "51",
  MSTORE = "52",
  MSTORE8 = "53",
  SLOAD = "54",
  SSTORE = "55",
  JUMP = "56",
  JUMPI = "57",
  PC = "58",
  MSIZE = "59",
  GAS = "5a",
  JUMPDEST = "5b",
  PUSH1 = "60",
  PUSH2 = "61",
  PUSH32 = "7f",
  DUP1 = "80",
  SWAP1 = "90",
  LOG0 = "a0",
  LOG1 = "a1",
  RETURN = "f3",
  REVERT = "fd",
  INVALID = "fe",
  SELFDESTRUCT = "ff"
}

local function to_hex(val)
  if type(val) == "number" then
    return string.format("%02x", val)
  elseif type(val) == "string" and val:match("^0x") then
    return val:sub(3)
  else
    return tostring(val)
  end
end

local function emit(ir)
  local bytecode = ""

  for i, instr in ipairs(ir) do
    if type(instr) ~= "table" then
      error("Expected instruction table at index " .. i .. ", got " .. type(instr))
    end

    if instr.op then
      local opcode

      -- Handle PUSH dynamically based on argument size
      if instr.op == "PUSH" then
        local arg = instr.args[1]
        local arg_hex = to_hex(arg)
        local arg_size = math.ceil(#arg_hex / 2) -- Calculate size in bytes

        if arg_size < 1 or arg_size > 32 then
          error("PUSH argument size must be between 1 and 32 bytes")
        end

        opcode = string.format("%02x", 0x5f + arg_size) -- PUSH1 = 0x60, PUSH32 = 0x7f
        bytecode = bytecode .. opcode .. arg_hex
      elseif instr.op == "LABEL" then
        -- Labels are metadata and do not generate bytecode
        print("[DEBUG] Skipping label:", instr.args[1])
      else
        opcode = opcodes[instr.op]
        if not opcode then
          error("Unknown op: " .. tostring(instr.op))
        end

        bytecode = bytecode .. opcode
        for _, arg in ipairs(instr.args or {}) do
          bytecode = bytecode .. to_hex(arg)
        end
      end
    else
      print("[WARN] Skipping non-op entry at index " .. i)
    end
  end

  return "0x" .. bytecode
end

return {
  emit = emit
}