//
//  CustomHeadersLoginVC.swift
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

import Amperfy
import AmperfyKit
import SwiftUI
import UIKit

// MARK: - CustomHeadersLoginVC

class CustomHeadersLoginVC: UIViewController {
  var customHeaders: [CustomHeader] = []
  var onHeadersSaved: (([CustomHeader]) -> ())?

  private var hostingController: UIHostingController<CustomHeadersLoginView>?
  private let headersModel = HeadersModel()

  override func viewDidLoad() {
    super.viewDidLoad()

    title = "Custom Headers"
    view.backgroundColor = .systemBackground

    // Initialize model with existing headers
    headersModel.headers = customHeaders

    // Add cancel button
    navigationItem.leftBarButtonItem = UIBarButtonItem(
      barButtonSystemItem: .cancel,
      target: self,
      action: #selector(cancelPressed)
    )

    // Add add button
    navigationItem.rightBarButtonItem = UIBarButtonItem(
      barButtonSystemItem: .add,
      target: self,
      action: #selector(addPressed)
    )

    let swiftUIView = CustomHeadersLoginView(
      model: headersModel,
      onAddRequested: { [weak self] in
        self?.showAddHeaderDialog()
      }
    )

    hostingController = UIHostingController(rootView: swiftUIView)
    guard let hostingController else { return }

    addChild(hostingController)
    view.addSubview(hostingController.view)
    hostingController.view.translatesAutoresizingMaskIntoConstraints = false

    NSLayoutConstraint.activate([
      hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
      hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
    ])

    hostingController.didMove(toParent: self)
  }

  @objc
  func cancelPressed() {
    dismiss(animated: true)
  }

  @objc
  func addPressed() {
    showAddHeaderDialog()
  }

  private func showAddHeaderDialog() {
    let alert = UIAlertController(
      title: "Add Custom Header",
      message: "Enter the header key and value. The key will be sent as-is in the HTTP request.",
      preferredStyle: .alert
    )

    alert.addTextField { textField in
      textField.placeholder = "Header Key (e.g., X-Api-Key)"
    }

    alert.addTextField { textField in
      textField.placeholder = "Header Value"
      textField.isSecureTextEntry = false
    }

    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
    alert.addAction(UIAlertAction(title: "Add", style: .default) { [weak self] _ in
      guard let key = alert.textFields?[0].text?.trimmingCharacters(in: .whitespaces),
            let value = alert.textFields?[1].text?.trimmingCharacters(in: .whitespaces),
            !key.isEmpty, !value.isEmpty else { return }

      let newHeader = CustomHeader(key: key, value: value)
      self?.headersModel.headers.append(newHeader)
    })

    present(alert, animated: true)
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    onHeadersSaved?(headersModel.headers)
    // Update API with new credentials including custom headers
    if let credentials = appDelegate.storage.loginCredentials {
      appDelegate.backendApi.provideCredentials(credentials: credentials)
    }
  }
}

// MARK: - CustomHeadersLoginView

struct CustomHeadersLoginView: View {
  @ObservedObject
  var model: HeadersModel
  var onAddRequested: () -> ()

  var body: some View {
    ZStack {
      if model.headers.isEmpty {
        VStack(spacing: 20) {
          Image(systemName: "text.badge.plus")
            .font(.system(size: 50))
            .foregroundColor(.secondary)

          Text("No Custom Headers")
            .font(.headline)
            .foregroundColor(.secondary)

          Text(
            "Some servers require custom HTTP headers for authentication.\n\nTap + to add headers like X-Api-Key or Authorization."
          )
          .font(.subheadline)
          .foregroundColor(.secondary)
          .multilineTextAlignment(.center)
          .padding(.horizontal, 40)

          Spacer()
        }
      } else {
        List {
          ForEach(model.headers) { header in
            HStack {
              VStack(alignment: .leading, spacing: 4) {
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
              }
            }
            .padding(.vertical, 4)
          }
        }
        .listStyle(.insetGrouped)
      }
    }
    .navigationTitle("Custom Headers")
    .navigationBarTitleDisplayMode(.inline)
  }

  private func deleteHeader(_ header: CustomHeader) {
    model.headers.removeAll { $0.id == header.id }
  }
}

#Preview {
  CustomHeadersLoginView(model: HeadersModel(), onAddRequested: {})
}
