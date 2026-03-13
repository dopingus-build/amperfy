//
//  CustomHeadersView.swift
//  Amperfy
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

import AmperfyKit
import SwiftUI

struct CustomHeadersView: View {
  @StateObject
  private var headersModel: HeadersModel
  @State
  private var isAddHeaderDialogPresented = false
  @State
  private var newHeaderKey = ""
  @State
  private var newHeaderValue = ""

  @AppStorage("customHeaders")
  private var storedHeadersData: Data?

  init(headers: [CustomHeader]) {
    _headersModel = StateObject(wrappedValue: HeadersModel(headers: headers))
  }

  var body: some View {
    ZStack {
      SettingsList {
        if headersModel.headers.isEmpty {
          SettingsSection {
            SettingsRow(title: "No custom headers", orientation: .vertical) {
              SecondaryText("Tap the + button to add a custom HTTP header")
            }
          }
        } else {
          ForEach(headersModel.headers) { header in
            SettingsRow(title: "", orientation: .horizontal) {
              HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                  Text(header.key)
                    .font(.headline)
                  Text(header.value)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .truncationMode(.middle)
                }

                Spacer()

                Button(role: .destructive) {
                  deleteHeader(header)
                } label: {
                  Image(systemName: "trash")
                    .foregroundColor(.red)
                    .frame(width: 20, height: 20)
                }
                .buttonStyle(.plain)
                .padding(.trailing, 4)
              }
              .padding(.vertical, 4)
            }
          }
        }
      }
      .listStyle(.plain)
    }
    .navigationTitle("Custom Headers")
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItem(placement: .primaryAction) {
        Button {
          isAddHeaderDialogPresented = true
        } label: {
          Image(systemName: "plus")
        }
      }
    }
    .alert("Add Custom Header", isPresented: $isAddHeaderDialogPresented) {
      TextField("Header Key (e.g., X-Api-Key)", text: $newHeaderKey)
      TextField("Header Value", text: $newHeaderValue)
      Button("Cancel", role: .cancel) {
        newHeaderKey = ""
        newHeaderValue = ""
      }
      Button("Add") {
        addHeader()
      }
    } message: {
      Text("Enter the header key and value. The key will be sent as-is in the HTTP request.")
    }
    .onAppear {
      // Reload headers from storage when view appears
      if let credentials = appDelegate.storage.loginCredentials {
        headersModel.headers = credentials.customHeaders
      }
    }
  }

  private func addHeader() {
    guard !newHeaderKey.isEmpty, !newHeaderValue.isEmpty else { return }
    let newHeader = CustomHeader(
      key: newHeaderKey.trimmingCharacters(in: .whitespaces),
      value: newHeaderValue.trimmingCharacters(in: .whitespaces)
    )
    headersModel.headers.append(newHeader)
    saveHeaders()
    newHeaderKey = ""
    newHeaderValue = ""
  }

  private func deleteHeader(_ header: CustomHeader) {
    headersModel.headers.removeAll { $0.id == header.id }
    saveHeaders()
  }

  private func saveHeaders() {
    var credentials = appDelegate.storage.loginCredentials
    credentials?.customHeaders = headersModel.headers
    appDelegate.storage.loginCredentials = credentials
    // Update API with new credentials including custom headers
    if let credentials = credentials {
      appDelegate.backendApi.provideCredentials(credentials: credentials)
    }
  }
}

#Preview {
  CustomHeadersView(headers: [])
}
