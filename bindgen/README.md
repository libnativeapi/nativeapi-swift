# Bindgen Swift Wrapper

Swift wrapper generation from C++ API headers.

- Input: `Sources/CNativeAPI/src/**/*.h` (excluding `capi` and `platform`)
- Output: `bindgen/out/**/*.swift`
- FFI policy: generated wrappers call existing C API symbols from `CNativeAPI`

## Run

```bash
cd nativeapi-swift
PYTHONPATH=Sources/CNativeAPI/tools python3 -m bindgen \
  --config bindgen/config.yaml \
  --dump-ir bindgen/out/ir.json \
  --out bindgen/out
```

## Symbol Mapping

Default mapping:
- Free function: `FooBar` -> `native_foo_bar`
- Method: `Class::Method` -> `native_class_method`

Override mapping in `mapping.options.symbol_overrides` when needed.
