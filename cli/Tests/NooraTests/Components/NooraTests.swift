import Testing
@testable import Noora

enum NooraTests {
    // MARK: - JSON Function Tests

    struct JSONTests {
        let subject = NooraMock()

        @Test func printsSimpleObject() throws {
            // Given
            struct Person: Codable {
                let name: String
                let age: Int
            }
            let person = Person(name: "John", age: 30)

            // When
            try subject.json(person)

            // Then
            #expect(subject.description == """
            {
              "age" : 30,
              "name" : "John"
            }
            """)
        }

        @Test func printsComplexObject() throws {
            // Given
            struct Address: Codable {
                let street: String
                let city: String
            }
            struct Person: Codable {
                let name: String
                let age: Int
                let address: Address
            }
            let person = Person(
                name: "Jane",
                age: 25,
                address: Address(street: "123 Main St", city: "Springfield")
            )

            // When
            try subject.json(person)

            // Then
            #expect(subject.description == """
            {
              "address" : {
                "city" : "Springfield",
                "street" : "123 Main St"
              },
              "age" : 25,
              "name" : "Jane"
            }
            """)
        }

        @Test func printsArray() throws {
            // Given
            let items = ["apple", "banana", "cherry"]

            // When
            try subject.json(items)

            // Then
            #expect(subject.description == """
            [
              "apple",
              "banana",
              "cherry"
            ]
            """)
        }

        @Test func printsDictionary() throws {
            // Given
            let dict = ["key1": "value1", "key2": "value2"]

            // When
            try subject.json(dict)

            // Then
            #expect(subject.description == """
            {
              "key1" : "value1",
              "key2" : "value2"
            }
            """)
        }

        @Test func printsNestedArraysAndDictionaries() throws {
            // Given
            struct SimpleData: Codable {
                let items: [[String: String]]
            }

            let data = SimpleData(items: [
                ["name": "item1", "type": "A"],
                ["name": "item2", "type": "B"],
            ])

            // When
            try subject.json(data)

            // Then
            #expect(subject.description == """
            {
              "items" : [
                {
                  "name" : "item1",
                  "type" : "A"
                },
                {
                  "name" : "item2",
                  "type" : "B"
                }
              ]
            }
            """)
        }

        @Test func handlesEmptyObject() throws {
            // Given
            struct Empty: Codable {}
            let empty = Empty()

            // When
            try subject.json(empty)

            // Then
            #expect(subject.description == """
            {

            }
            """)
        }

        @Test func handlesOptionalValues() throws {
            // Given
            struct OptionalData: Codable {
                let required: String
                let optional: String?
            }
            let data = OptionalData(required: "value", optional: nil)

            // When
            try subject.json(data)

            // Then
            #expect(subject.description == """
            {
              "required" : "value"
            }
            """)
        }
    }
}
