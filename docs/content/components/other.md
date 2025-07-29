---
title: Other
titleTemplate: ":title · Noora · Tuist"
description: Other components.
---

# Other components

This section contains utility components that don't fit into other categories.

## Passthrough

The passthrough component allows you to write text directly to standard output or standard error pipelines with Noora's formatting and styling applied.

| Property | Value |
| --- | --- |
| Interactivity | Non-required |

### API

#### Example

```swift
// Write to standard output
Noora().passthrough("Building project...", pipeline: .output)

// Write to standard error
Noora().passthrough("Error: File not found", pipeline: .error)

// Using TerminalText for styled output
let styledText: TerminalText = "Processing \(path: "/path/to/file")..."
Noora().passthrough(styledText, pipeline: .output)
```

#### Options

| Attribute | Description | Required | Default value |
| --- | --- | --- | --- |
| `text` | The text to output (can be plain string or TerminalText) | Yes | |
| `pipeline` | The standard pipeline to write to (.output or .error) | Yes | |

### Use Cases

The passthrough component is designed for cases where you want to output text directly to stdout or stderr without wrapping it in any Noora UI components. While it preserves any styling from `TerminalText`, it doesn't add any additional formatting or structure that other Noora components would provide. This is particularly useful when writing tests, as you can use `NooraMock` to capture the output and then run assertions against it, ensuring your text appears correctly.

## JSON

The JSON component allows you to pretty print any Codable object as formatted JSON to the standard output.

| Property | Value |
| --- | --- |
| Interactivity | Non-required |

### API

#### Example

```swift
// Simple struct
struct Person: Codable {
    let name: String
    let age: Int
}

let person = Person(name: "John", age: 30)
try Noora().json(person)
// Output:
// {
//   "age" : 30,
//   "name" : "John"
// }

// Arrays and dictionaries
let items = ["apple", "banana", "cherry"]
try Noora().json(items)
// Output:
// [
//   "apple",
//   "banana",
//   "cherry"
// ]

// Complex nested structures
struct Address: Codable {
    let street: String
    let city: String
}
struct Employee: Codable {
    let name: String
    let address: Address
    let skills: [String]
}

let employee = Employee(
    name: "Jane",
    address: Address(street: "123 Main St", city: "Springfield"),
    skills: ["Swift", "iOS", "Architecture"]
)
try Noora().json(employee)
// Output:
// {
//   "address" : {
//     "city" : "Springfield",
//     "street" : "123 Main St"
//   },
//   "name" : "Jane",
//   "skills" : [
//     "Swift",
//     "iOS",
//     "Architecture"
//   ]
// }
```

#### Options

| Attribute | Description | Required | Default value |
| --- | --- | --- | --- |
| `item` | Any Codable object to be printed as JSON | Yes | |

### Use Cases

The JSON component is useful for debugging and displaying structured data in a human-readable format. It automatically formats the JSON with proper indentation and sorted keys for consistency. If encoding fails, the error is thrown and should be handled by the caller. This component is particularly helpful when you need to:

- Debug API responses or data models
- Display configuration or settings in a readable format
- Log structured data during development
- Present JSON data to users in CLI tools
