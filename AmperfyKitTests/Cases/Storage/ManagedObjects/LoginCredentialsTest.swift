//
//  LoginCredentialsTest.swift
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
final class LoginCredentialsTest: XCTestCase {
  func testLoginCredentialsInitialization() {
    let credentials = LoginCredentials()

    XCTAssertEqual(credentials.serverUrl, "")
    XCTAssertEqual(credentials.username, "")
    XCTAssertEqual(credentials.password, "")
    XCTAssertEqual(credentials.passwordHash, "")
    XCTAssertEqual(credentials.backendApi, .notDetected)
    XCTAssertEqual(credentials.customHeaders.count, 0)
  }

  func testLoginCredentialsWithServerUrlUsernamePassword() {
    let credentials = LoginCredentials(
      serverUrl: "https://example.com",
      username: "testuser",
      password: "testpass"
    )

    XCTAssertEqual(credentials.serverUrl, "https://example.com")
    XCTAssertEqual(credentials.username, "testuser")
    XCTAssertEqual(credentials.password, "testpass")
    XCTAssertFalse(credentials.passwordHash.isEmpty)
    XCTAssertEqual(credentials.backendApi, .notDetected)
    XCTAssertEqual(credentials.customHeaders.count, 0)
  }

  func testLoginCredentialsWithBackendApi() {
    let credentials = LoginCredentials(
      serverUrl: "https://example.com",
      username: "testuser",
      password: "testpass",
      backendApi: .subsonic
    )

    XCTAssertEqual(credentials.serverUrl, "https://example.com")
    XCTAssertEqual(credentials.username, "testuser")
    XCTAssertEqual(credentials.backendApi, .subsonic)
    XCTAssertEqual(credentials.customHeaders.count, 0)
  }

  func testLoginCredentialsWithCustomHeaders() {
    let headers = [
      CustomHeader(key: "X-Api-Key", value: "key123"),
      CustomHeader(key: "Authorization", value: "Bearer token"),
    ]

    let credentials = LoginCredentials(
      serverUrl: "https://example.com",
      username: "testuser",
      password: "testpass",
      backendApi: .ampache,
      customHeaders: headers
    )

    XCTAssertEqual(credentials.customHeaders.count, 2)
    XCTAssertEqual(credentials.customHeaders[0].key, "X-Api-Key")
    XCTAssertEqual(credentials.customHeaders[1].key, "Authorization")
  }

  func testLoginCredentialsChangePassword() {
    var credentials = LoginCredentials(
      serverUrl: "https://example.com",
      username: "testuser",
      password: "oldpass"
    )

    let oldHash = credentials.passwordHash

    credentials.changePasswordAndHash(password: "newpass")

    XCTAssertEqual(credentials.password, "newpass")
    XCTAssertNotEqual(credentials.passwordHash, oldHash)
  }

  func testLoginCredentialsCustomHeadersMutable() {
    var credentials = LoginCredentials(
      serverUrl: "https://example.com",
      username: "testuser",
      password: "testpass"
    )

    XCTAssertEqual(credentials.customHeaders.count, 0)

    credentials.customHeaders.append(CustomHeader(key: "X-Custom", value: "value"))

    XCTAssertEqual(credentials.customHeaders.count, 1)
    XCTAssertEqual(credentials.customHeaders[0].key, "X-Custom")
    XCTAssertEqual(credentials.customHeaders[0].value, "value")
  }
}
