-- compiler/compiler.lua
local ir = require("compiler.ir")
local codegen = require("compiler.codegen")
local abi = require("compiler.abi")

local function compile_contract(path)
  local contract = dofile(path)
  local ir_tree = ir.generate(contract)
  local bytecode = codegen.emit(ir_tree)
  local abi_json = abi.extract(contract)
  return bytecode, abi_json
end

return {
  compile_contract = compile_contract
}