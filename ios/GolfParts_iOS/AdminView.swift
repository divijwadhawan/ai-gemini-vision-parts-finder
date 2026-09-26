//
//  AdminView.swift
//  GolfParts_iOS
//
//  Administrator screen for managing API access.
//

import SwiftUI


struct AdminView: View {

    let idToken: String


    @Environment(\.dismiss)
    private var dismiss


    @State private var requests:
        [AccessRequest] = []

    @State private var isLoading =
        false

    @State private var processingID:
        Int?

    @State private var errorMessage:
        String?


    private let adminAPIService =
        AdminAPIService()


    var body: some View {

        NavigationStack {

            Group {

                if isLoading &&
                    requests.isEmpty {

                    ProgressView(
                        "Loading requests…"
                    )


                } else if requests.isEmpty {

                    ContentUnavailableView(
                        "No Access Requests",
                        systemImage:
                            "person.badge.checkmark",
                        description:
                            Text(
                                "There are currently no access requests."
                            )
                    )


                } else {

                    List {

                        // =========================================
                        // Pending Requests
                        // =========================================

                        let pending =
                            requests.filter {
                                $0.status ==
                                    "PENDING"
                            }


                        if !pending.isEmpty {

                            Section(
                                "Pending"
                            ) {

                                ForEach(
                                    pending
                                ) { request in

                                    requestRow(
                                        request,
                                        showActions:
                                            true
                                    )
                                }
                            }
                        }


                        // =========================================
                        // Reviewed Requests
                        // =========================================

                        let reviewed =
                            requests.filter {
                                $0.status !=
                                    "PENDING"
                            }


                        if !reviewed.isEmpty {

                            Section(
                                "Reviewed"
                            ) {

                                ForEach(
                                    reviewed
                                ) { request in

                                    requestRow(
                                        request,
                                        showActions:
                                            false
                                    )
                                }
                            }
                        }
                    }
                    .refreshable {

                        await loadRequests()
                    }
                }
            }

            .navigationTitle(
                "Admin"
            )

            .navigationBarTitleDisplayMode(
                .inline
            )

            .toolbar {

                ToolbarItem(
                    placement:
                        .topBarLeading
                ) {

                    Button(
                        "Close"
                    ) {

                        dismiss()
                    }
                }


                ToolbarItem(
                    placement:
                        .topBarTrailing
                ) {

                    Button {

                        Task {

                            await loadRequests()
                        }

                    } label: {

                        Image(
                            systemName:
                                "arrow.clockwise"
                        )
                    }
                }
            }

            .task {

                await loadRequests()
            }

            .alert(
                "Admin Error",
                isPresented:
                    Binding(
                        get: {
                            errorMessage != nil
                        },
                        set: { newValue in

                            if !newValue {
                                errorMessage =
                                    nil
                            }
                        }
                    )
            ) {

                Button(
                    "OK",
                    role: .cancel
                ) {
                }

            } message: {

                Text(
                    errorMessage ?? ""
                )
            }
        }
    }


    // ============================================================
    // MARK: - Access Request Row
    // ============================================================

    @ViewBuilder
    private func requestRow(
        _ request: AccessRequest,
        showActions: Bool
    ) -> some View {

        VStack(
            alignment: .leading,
            spacing: 10
        ) {

            // Prefer showing the human-readable email.
            Text(
                request.email ??
                "Google User"
            )
            .font(.headline)


            Text(
                "Google ID: \(request.googleSub)"
            )
            .font(.caption)
            .foregroundStyle(
                .secondary
            )
            .textSelection(
                .enabled
            )


            HStack {

                Text(
                    request.status
                )
                .font(.caption)
                .bold()


                Spacer()


                if processingID ==
                    request.id {

                    ProgressView()
                        .controlSize(
                            .small
                        )
                }
            }


            // =============================================
            // Approve / Reject
            // =============================================

            if showActions {

                HStack {

                    Button {

                        Task {

                            await approve(
                                request
                            )
                        }

                    } label: {

                        Label(
                            "Approve",
                            systemImage:
                                "checkmark.circle"
                        )
                    }
                    .buttonStyle(
                        .borderedProminent
                    )
                    .disabled(
                        processingID != nil
                    )


                    Button(
                        role: .destructive
                    ) {

                        Task {

                            await reject(
                                request
                            )
                        }

                    } label: {

                        Label(
                            "Reject",
                            systemImage:
                                "xmark.circle"
                        )
                    }
                    .buttonStyle(
                        .bordered
                    )
                    .disabled(
                        processingID != nil
                    )
                }
            }
        }
        .padding(
            .vertical,
            6
        )
    }


    // ============================================================
    // MARK: - Load Requests
    // ============================================================

    @MainActor
    private func loadRequests() async {

        isLoading =
            true

        errorMessage =
            nil


        do {

            requests =
                try await adminAPIService
                    .getAccessRequests(
                        idToken:
                            idToken
                    )

        } catch {

            errorMessage =
                error.localizedDescription
        }


        isLoading =
            false
    }


    // ============================================================
    // MARK: - Approve
    // ============================================================

    @MainActor
    private func approve(
        _ request: AccessRequest
    ) async {

        processingID =
            request.id

        errorMessage =
            nil


        do {

            try await adminAPIService
                .approve(
                    requestID:
                        request.id,
                    idToken:
                        idToken
                )


            // Reload so the UI reflects PostgreSQL.
            await loadRequests()


        } catch {

            errorMessage =
                error.localizedDescription
        }


        processingID =
            nil
    }


    // ============================================================
    // MARK: - Reject
    // ============================================================

    @MainActor
    private func reject(
        _ request: AccessRequest
    ) async {

        processingID =
            request.id

        errorMessage =
            nil


        do {

            try await adminAPIService
                .reject(
                    requestID:
                        request.id,
                    idToken:
                        idToken
                )


            // Reload so the UI reflects PostgreSQL.
            await loadRequests()


        } catch {

            errorMessage =
                error.localizedDescription
        }


        processingID =
            nil
    }
}
