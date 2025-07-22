local ir = require("compiler/ir")
local contract = require("contracts/Counter")

-- Generate IR for the Counter contract
local generated_ir = ir.generate(contract)

-- Print the generated IR for inspection
for _, instruction in ipairs(generated_ir) do
  print(string.format("Opcode: %s, Args: %s", instruction.op, table.concat(instruction.args or {}, ", ")))
end
