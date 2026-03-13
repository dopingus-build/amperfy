//
//  HeadersModel.swift
//  AmperfyKit
//
//  Created on 10.03.26.
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

import Foundation

/// Observable model for managing custom HTTP headers in SwiftUI views
public class HeadersModel: ObservableObject {
  @Published
  public var headers: [CustomHeader] = []

  public init(headers: [CustomHeader] = []) {
    self.headers = headers
  }
}
