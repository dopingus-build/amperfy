//
//  PersistentStorageCustomHeadersTest.swift
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
final class PersistentStorageCustomHeadersTest: XCTestCase {
  var storage: PersistentStorage!
  var cdHelper: CoreDataHelper!
  var mockCoreDataManager: MOCK_CoreDataManager!

  override func setUp() async throws {
    try await super.setUp()
    cdHelper = CoreDataHelper()
    _ = cdHelper.createInMemoryManagedObjectContext()
    mockCoreDataManager = MOCK_CoreDataManager(persistentContainer: cdHelper.persistentContainer)
    storage = PersistentStorage(coreDataManager: mockCoreDataManager)

    UserDefaults.standard.removeObject(forKey: "serverUrl")
    UserDefaults.standard.removeObject(forKey: "username")
    UserDefaults.standard.removeObject(forKey: "password")
    UserDefaults.standard.removeObject(forKey: "backendApi")
    UserDefaults.standard.removeObject(forKey: "customHeaders")
  }

  override func tearDown() async throws {
    UserDefaults.standard.removeObject(forKey: "serverUrl")
    UserDefaults.standard.removeObject(forKey: "username")
    UserDefaults.standard.removeObject(forKey: "password")
    UserDefaults.standard.removeObject(forKey: "backendApi")
    UserDefaults.standard.removeObject(forKey: "customHeaders")

    storage = nil
    mockCoreDataManager = nil
    cdHelper = nil
    try await super.tearDown()
  }

  func testSaveAndLoadCustomHeaders() {
    let headers = [
      CustomHeader(key: "X-Api-Key", value: "test-key-123"),
      CustomHeader(key: "Authorization", value: "Bearer token456"),
    ]

    let credentials = LoginCredentials(
      serverUrl: "https://example.com",
      username: "testuser",
      password: "testpass",
      backendApi: .ampache,
      customHeaders: headers
    )

    storage.loginCredentials = credentials

    let loadedCredentials = storage.loginCredentials

    XCTAssertNotNil(loadedCredentials)
    XCTAssertEqual(loadedCredentials?.customHeaders.count, 2)
    XCTAssertEqual(loadedCredentials?.customHeaders[0].key, "X-Api-Key")
    XCTAssertEqual(loadedCredentials?.customHeaders[0].value, "test-key-123")
    XCTAssertEqual(loadedCredentials?.customHeaders[1].key, "Authorization")
    XCTAssertEqual(loadedCredentials?.customHeaders[1].value, "Bearer token456")
  }

  func testSaveAndLoadEmptyCustomHeaders() {
    let credentials = LoginCredentials(
      serverUrl: "https://example.com",
      username: "testuser",
      password: "testpass",
      backendApi: .ampache
    )

    storage.loginCredentials = credentials

    let loadedCredentials = storage.loginCredentials

    XCTAssertNotNil(loadedCredentials)
    XCTAssertEqual(loadedCredentials?.customHeaders.count, 0)
  }

  func testUpdateCustomHeaders() {
    let initialHeaders = [CustomHeader(key: "X-Initial", value: "initial")]

    var credentials = LoginCredentials(
      serverUrl: "https://example.com",
      username: "testuser",
      password: "testpass",
      backendApi: .ampache,
      customHeaders: initialHeaders
    )

    storage.loginCredentials = credentials

    credentials.customHeaders.append(CustomHeader(key: "X-Added", value: "added"))
    storage.loginCredentials = credentials

    let loadedCredentials = storage.loginCredentials

    XCTAssertEqual(loadedCredentials?.customHeaders.count, 2)
    XCTAssertEqual(loadedCredentials?.customHeaders[0].key, "X-Initial")
    XCTAssertEqual(loadedCredentials?.customHeaders[1].key, "X-Added")
  }

  func testDeleteCustomHeaders() {
    let headers = [
      CustomHeader(key: "X-First", value: "first"),
      CustomHeader(key: "X-Second", value: "second"),
    ]

    var credentials = LoginCredentials(
      serverUrl: "https://example.com",
      username: "testuser",
      password: "testpass",
      backendApi: .ampache,
      customHeaders: headers
    )

    storage.loginCredentials = credentials

    credentials.customHeaders.removeAll { $0.key == "X-First" }
    storage.loginCredentials = credentials

    let loadedCredentials = storage.loginCredentials

    XCTAssertEqual(loadedCredentials?.customHeaders.count, 1)
    XCTAssertEqual(loadedCredentials?.customHeaders[0].key, "X-Second")
  }

  func testClearLoginCredentialsRemovesCustomHeaders() {
    let headers = [CustomHeader(key: "X-Test", value: "test")]

    let credentials = LoginCredentials(
      serverUrl: "https://example.com",
      username: "testuser",
      password: "testpass",
      backendApi: .ampache,
      customHeaders: headers
    )

    storage.loginCredentials = credentials
    storage.loginCredentials = nil

    let loadedCredentials = storage.loginCredentials

    XCTAssertNil(loadedCredentials)
  }

  func testCustomHeadersPersistenceAcrossInstances() {
    let headers = [
      CustomHeader(key: "X-Persistent", value: "persistent-value"),
    ]

    let credentials = LoginCredentials(
      serverUrl: "https://example.com",
      username: "testuser",
      password: "testpass",
      backendApi: .ampache,
      customHeaders: headers
    )

    storage.loginCredentials = credentials

    let newStorage = PersistentStorage(coreDataManager: mockCoreDataManager)
    let loadedCredentials = newStorage.loginCredentials

    XCTAssertEqual(loadedCredentials?.customHeaders.count, 1)
    XCTAssertEqual(loadedCredentials?.customHeaders[0].key, "X-Persistent")
    XCTAssertEqual(loadedCredentials?.customHeaders[0].value, "persistent-value")
  }

  func testCustomHeadersWithSpecialCharacters() {
    let headers = [
      CustomHeader(key: "X-Special", value: "value with spaces & symbols!@#"),
      CustomHeader(key: "Authorization", value: "Bearer DUMMY_TOKEN_VALUE_12345"),
    ]

    let credentials = LoginCredentials(
      serverUrl: "https://example.com",
      username: "testuser",
      password: "testpass",
      backendApi: .ampache,
      customHeaders: headers
    )

    storage.loginCredentials = credentials

    let loadedCredentials = storage.loginCredentials

    XCTAssertEqual(loadedCredentials?.customHeaders.count, 2)
    XCTAssertEqual(
      loadedCredentials?.customHeaders[0].value,
      "value with spaces & symbols!@#"
    )
    XCTAssertEqual(
      loadedCredentials?.customHeaders[1].value,
      "Bearer DUMMY_TOKEN_VALUE_12345"
    )
  }

  func testLoadCredentialsWithNoCustomHeadersKey() {
    UserDefaults.standard.set("https://example.com", forKey: "serverUrl")
    UserDefaults.standard.set("testuser", forKey: "username")
    UserDefaults.standard.set("hashedpass", forKey: "password")
    UserDefaults.standard.set(BackenApiType.subsonic.rawValue, forKey: "backendApi")
    UserDefaults.standard.removeObject(forKey: "customHeaders")

    let loadedCredentials = storage.loginCredentials

    XCTAssertNotNil(loadedCredentials)
    XCTAssertEqual(loadedCredentials?.customHeaders.count, 0)
  }

  func testLoadCredentialsWithCorruptedCustomHeadersData() {
    UserDefaults.standard.set("https://example.com", forKey: "serverUrl")
    UserDefaults.standard.set("testuser", forKey: "username")
    UserDefaults.standard.set("hashedpass", forKey: "password")
    UserDefaults.standard.set(BackenApiType.subsonic.rawValue, forKey: "backendApi")
    UserDefaults.standard.set("not valid json".data(using: .utf8)!, forKey: "customHeaders")

    let loadedCredentials = storage.loginCredentials

    XCTAssertNotNil(loadedCredentials)
    XCTAssertEqual(loadedCredentials?.customHeaders.count, 0)
  }

  func testCustomHeadersUserDefaultsDirectRoundTrip() {
    let headers = [
      CustomHeader(key: "X-Api-Key", value: "key123"),
      CustomHeader(key: "Authorization", value: "Bearer DUMMY_TOKEN_67890"),
    ]

    let encodedData = try! JSONEncoder().encode(headers)
    UserDefaults.standard.set(encodedData, forKey: "customHeaders")

    guard let readData = UserDefaults.standard
      .object(forKey: "customHeaders") as? Data,
      let decoded = try? JSONDecoder().decode([CustomHeader].self, from: readData) else {
      XCTFail("Failed to read back custom headers from UserDefaults")
      return
    }

    XCTAssertEqual(decoded.count, 2)
    XCTAssertEqual(decoded[0].key, "X-Api-Key")
    XCTAssertEqual(decoded[0].value, "key123")
    XCTAssertEqual(decoded[1].key, "Authorization")
    XCTAssertEqual(decoded[1].value, "Bearer DUMMY_TOKEN_67890")
  }

  func testCustomHeadersPreserveUUIDsAcrossPersistence() {
    let header = CustomHeader(key: "X-Track-Id", value: "track-123")
    let originalId = header.id

    let credentials = LoginCredentials(
      serverUrl: "https://example.com",
      username: "testuser",
      password: "testpass",
      backendApi: .subsonic,
      customHeaders: [header]
    )

    storage.loginCredentials = credentials

    let loadedCredentials = storage.loginCredentials

    XCTAssertEqual(loadedCredentials?.customHeaders[0].id, originalId)
  }
}
