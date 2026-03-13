//
//  CustomHeaderTest.swift
//  AmperfyKitTests
//
//  Created on 09.03.26.
//  Copyright (c) 2026 Maximilian Bauer. All rights reserved.
//  Custom HTTP headers feature contributed by the Amperfy community.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

@testable import AmperfyKit
import XCTest

@MainActor
final class CustomHeaderTest: XCTestCase {
  func testCustomHeaderInitialization() {
    let header = CustomHeader(key: "X-Api-Key", value: "test-key-123")

    XCTAssertNotNil(header.id)
    XCTAssertEqual(header.key, "X-Api-Key")
    XCTAssertEqual(header.value, "test-key-123")
  }

  func testCustomHeaderWithCustomID() {
    let customID = UUID()
    let header = CustomHeader(id: customID, key: "Authorization", value: "Bearer token")

    XCTAssertEqual(header.id, customID)
    XCTAssertEqual(header.key, "Authorization")
    XCTAssertEqual(header.value, "Bearer token")
  }

  func testCustomHeaderEquatable() {
    let id = UUID()
    let header1 = CustomHeader(id: id, key: "X-Custom", value: "value1")
    let header2 = CustomHeader(id: id, key: "X-Custom", value: "value1")
    let header3 = CustomHeader(id: UUID(), key: "X-Custom", value: "value1")

    XCTAssertEqual(header1, header2)
    XCTAssertNotEqual(header1, header3)
  }

  func testCustomHeaderCodable() throws {
    let header = CustomHeader(key: "X-Test-Header", value: "test-value")

    let encoder = JSONEncoder()
    let data = try encoder.encode(header)

    let decoder = JSONDecoder()
    let decodedHeader = try decoder.decode(CustomHeader.self, from: data)

    XCTAssertEqual(decodedHeader.key, header.key)
    XCTAssertEqual(decodedHeader.value, header.value)
    XCTAssertEqual(decodedHeader.id, header.id)
  }

  func testCustomHeaderIdentifiable() {
    let header1 = CustomHeader(key: "Key1", value: "Value1")
    let header2 = CustomHeader(key: "Key2", value: "Value2")

    XCTAssertNotEqual(header1.id, header2.id)
  }

  func testCustomHeaderWithEmptyKeyAndValue() {
    let header = CustomHeader(key: "", value: "")

    XCTAssertEqual(header.key, "")
    XCTAssertEqual(header.value, "")
    XCTAssertNotNil(header.id)
  }

  func testCustomHeaderWithEmptyValue() {
    let header = CustomHeader(key: "X-Api-Key", value: "")

    XCTAssertEqual(header.key, "X-Api-Key")
    XCTAssertEqual(header.value, "")
  }

  func testCustomHeadersToDictionaryWithDuplicateKeys() {
    let headers = [
      CustomHeader(key: "Authorization", value: "Bearer first"),
      CustomHeader(key: "Authorization", value: "Bearer second"),
      CustomHeader(key: "X-Unique", value: "unique"),
    ]

    // Mirrors BackendAudioPlayer.insert() which uses
    // Dictionary(_:uniquingKeysWith:) — last value wins for duplicate keys.
    let dict = Dictionary(
      headers.map { ($0.key, $0.value) },
      uniquingKeysWith: { _, last in last }
    )

    XCTAssertEqual(dict.count, 2)
    XCTAssertEqual(dict["Authorization"], "Bearer second")
    XCTAssertEqual(dict["X-Unique"], "unique")
  }

  func testCustomHeaderCodableRoundTripArray() throws {
    let headers = [
      CustomHeader(key: "X-First", value: "value1"),
      CustomHeader(key: "Authorization", value: "Bearer DUMMY_TOKEN_12345"),
    ]

    let data = try JSONEncoder().encode(headers)
    let decoded = try JSONDecoder().decode([CustomHeader].self, from: data)

    XCTAssertEqual(decoded.count, 2)
    XCTAssertEqual(decoded[0].id, headers[0].id)
    XCTAssertEqual(decoded[0].key, "X-First")
    XCTAssertEqual(decoded[0].value, "value1")
    XCTAssertEqual(decoded[1].key, "Authorization")
    XCTAssertEqual(decoded[1].value, "Bearer DUMMY_TOKEN_12345")
  }
}
