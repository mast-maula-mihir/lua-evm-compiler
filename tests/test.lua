local runtime = require("../runtime.runtime")
local bytecode = "6000546001016000556001600054a1" -- Example bytecode

print("[DEBUG] Bytecode to Execute:", bytecode) -- Debug output to inspect the bytecode

local storage = runtime.execute_bytecode(bytecode)
print("Final Storage:", storage)