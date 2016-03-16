# Swiftfake

Generate test fakes from Swift code. The fakes allow you to:

- Verify how many times a function was called
- Verify what arguments were received
- Return a canned value

## Usage

Pass a Swift file path and the fake will be printed to STDOUT:

```bash
swiftfake ./app/MySwiftClass.swift
```

You could then pipe the output:

```bash
# To clipboard
swiftfake ./app/MySwiftClass.swift | pbcopy

# To a file
swiftfake ./app/MySwiftClass.swift > ./test/FakeMySwiftClass.swift
```

## Requirements

- Ruby 2.1+ (run `ruby -v` to check)
- Swift compiler - ships with XCode (run `which swiftc` to check)

## Notes

This gem is still WIP.

Roadmap:

- Protocol support
- Futures support
- Handling multiple classes in the Swift source file
