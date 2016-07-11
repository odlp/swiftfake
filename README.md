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
- (SourceKitten)[https://github.com/jpsim/SourceKitten] (`brew install sourcekitten`)

## Notes

This gem is still in an alpha state.

Roadmap:

- Copy across @import statements from source
- Fake Protocol implementations
- Implement Bright Futures support
- Handling multiple classes/protocols in the Swift source file
