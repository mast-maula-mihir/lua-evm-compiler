-- main.lua
local compiler = require("compiler.compiler")

local contract_path = arg[1]
if not contract_path then
  error("Usage: lua main.lua <contract_file.lua>")
end

local bytecode, abi = compiler.compile_contract(contract_path)

-- Write to disk
local name = contract_path:match("([^/\\]+)%.lua$")
local out_prefix = "output/" .. name
local json = require("dkjson")  -- You may use dkjson or cjson

local f_bin = assert(io.open(out_prefix .. ".bin", "w"))
f_bin:write(bytecode)
f_bin:close()

local f_abi = assert(io.open(out_prefix .. ".abi.json", "w"))
f_abi:write(json.encode(abi, { indent = true }))
f_abi:close()

print("✅ Compiled:", name)