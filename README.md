# 🔥 Lua-to-EVM Smart Contract Compiler (POC)

This project is a **proof-of-concept compiler** that allows developers to write Ethereum smart contracts using a subset of **native Lua**, and compile them into **EVM bytecode**. The goal is to make smart contract development more accessible by leveraging Lua's familiar syntax while preserving compatibility with the EVM.

## ✨ Features

- ✅ Write smart contracts in idiomatic Lua
- ✅ Compile to raw EVM bytecode
- ✅ ABI generation (Solidity-compatible)
- ✅ Support for `storage`, `transient`, `signals`, and `clauses` sections
- ✅ Simple IR (intermediate representation) for easy debugging and extension

## 📁 Project Structure

```
.
├── contracts/         # Lua smart contracts
│   └── Counter.lua
├── tests/             # For testing the sample contract written above
│   └── test.lua
├── compiler/          # Compiler logic
│   ├── abi.lua
│   ├── codegen.lua
│   └── compiler.lua
├── main.lua           # Entry point
├── output.json        # ABI and Bytecode output
└── README.md
```

## 🧪 Example Contract

**contracts/Counter.lua**
```lua
return {
  storage = {
    count = 0
  },
  signals = {
    Incremented = { "uint256" }
  },
  clauses = {
    increment = function(calldata)
      count = count + 1
      emit("Incremented", count)
    end
  }
}
```

## 🚀 How It Works

The contract file returns a table containing:
- `storage`: Persistent EVM storage (converted to slots)
- `signals`: Events to be emitted
- `clauses`: Callable entry points, compiled to EVM-compatible functions

The compiler performs:
1. **Storage resolution** (maps names like `count` to slot numbers)
2. **ABI extraction** (for Solidity compatibility)
3. **IR generation** (simple instruction list)
4. **Bytecode emission** (actual EVM opcodes)

## 🛠️ Usage

### 1. Install Lua 5.1 and `dkjson`

> Required dependencies: Lua 5.1 + [dkjson](https://dkolf.de/src/dkjson-lua.fsl/home)

```bash
luarocks install dkjson
```

### 2. Run the Compiler

```bash
lua main.lua contracts/Counter.lua
```

### 3. Output

The compiler will output:
- **ABI**: Contract interface (Solidity-style)
- **Bytecode**: Hex-encoded EVM bytecode

Example:

```json
{
  "abi": [...],
  "bytecode": "0x6001600055"
}
```

## 🧠 Future Plans

- [ ] Function dispatch (selector-based)
- [ ] Calldata decoding
- [ ] Event logging (`LOG` opcodes)
- [ ] Error handling and validation
- [ ] Deployment script
- [ ] Integration with Remix or Foundry

## 📜 License

MIT

---

🧪 *This is a POC. Not intended for production use (yet).*
