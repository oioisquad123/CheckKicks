//
//  ErrorView.swift
//  Auntentic_AI
//
//  Created by Claude AI on 01/01/26.
//  Task 18: Reusable error display component
//

import SwiftUI

/// Reusable error view with icon, message, and retry button
struct ErrorView: View {
    let error: AppError
    let retryAction: (() -> Void)?

    init(error: AppError, retryAction: (() -> Void)? = nil) {
        self.error = error
        self.retryAction = retryAction
    }

    /// Convenience initializer from any Error
    init(error: Error, retryAction: (() -> Void)? = nil) {
        self.error = AppError.from(error)
        self.retryAction = retryAction
    }

    var body: some View {
        VStack(spacing: 20) {
            // Error icon
            Image(systemName: error.icon)
                .font(.system(size: 50))
                .foregroundColor(error.color)

            // Error title
            Text(error.errorDescription ?? "Error")
                .font(.headline)
                .multilineTextAlignment(.center)

            // Recovery suggestion
            if let suggestion = error.recoverySuggestion {
                Text(suggestion)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            // Retry button (if retryable and handler provided)
            if error.isRetryable, let retryAction = retryAction {
                Button(action: retryAction) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("Try Again")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .cornerRadius(10)
                }
                .padding(.top, 8)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

/// Compact inline error message
struct InlineErrorView: View {
    let error: AppError
    let retryAction: (() -> Void)?

    init(error: AppError, retryAction: (() -> Void)? = nil) {
        self.error = error
        self.retryAction = retryAction
    }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: error.icon)
                .foregroundColor(error.color)

            VStack(alignment: .leading, spacing: 2) {
                Text(error.errorDescription ?? "Error")
                    .font(.subheadline)
                    .fontWeight(.medium)

                if let suggestion = error.recoverySuggestion {
                    Text(suggestion)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            if error.isRetryable, let retryAction = retryAction {
                Button(action: retryAction) {
                    Image(systemName: "arrow.clockwise")
                        .foregroundColor(.blue)
                }
            }
        }
        .padding()
        .background(error.color.opacity(0.1))
        .cornerRadius(12)
    }
}

/// Offline banner that shows when device is offline
struct OfflineBanner: View {
    @Environment(\.networkMonitor) private var networkMonitor

    var body: some View {
        if !networkMonitor.isConnected {
            HStack(spacing: 8) {
                Image(systemName: "wifi.slash")
                    .font(.subheadline)

                Text("No Internet Connection")
                    .font(.subheadline)
                    .fontWeight(.medium)

                Spacer()

                // Connection type indicator (shows last known)
                if networkMonitor.connectionType != .unknown {
                    Text("Last: \(networkMonitor.connectionType.rawValue)")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color.orange)
            .transition(.move(edge: .top).combined(with: .opacity))
        }
    }
}

/// View modifier for displaying offline banner
struct OfflineBannerModifier: ViewModifier {
    func body(content: Content) -> some View {
        VStack(spacing: 0) {
            OfflineBanner()
            content
        }
        .animation(.easeInOut(duration: 0.3), value: NetworkMonitor.shared.isConnected)
    }
}

extension View {
    /// Add offline banner to the top of the view
    func withOfflineBanner() -> some View {
        modifier(OfflineBannerModifier())
    }
}

/// Toast-style error notification
struct ErrorToast: View {
    let error: AppError
    @Binding var isPresented: Bool
    let retryAction: (() -> Void)?

    var body: some View {
        if isPresented {
            VStack {
                Spacer()

                HStack(spacing: 12) {
                    Image(systemName: error.icon)
                        .foregroundColor(.white)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(error.errorDescription ?? "Error")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                    }

                    Spacer()

                    if error.isRetryable, let retryAction = retryAction {
                        Button(action: {
                            retryAction()
                            isPresented = false
                        }) {
                            Text("Retry")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                        }
                    }

                    Button(action: { isPresented = false }) {
                        Image(systemName: "xmark")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                .padding()
                .background(error.color)
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.2), radius: 8)
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
            .transition(.move(edge: .bottom).combined(with: .opacity))
            .onAppear {
                // Auto-dismiss after 5 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    withAnimation {
                        isPresented = false
                    }
                }
            }
        }
    }
}

// MARK: - Previews

#Preview("Full Error View") {
    ErrorView(error: .noInternet) {
        // Retry action handled by parent view
    }
}

#Preview("Inline Error") {
    VStack(spacing: 16) {
        InlineErrorView(error: .noInternet) {
            // Retry action handled by parent view
        }

        InlineErrorView(error: .aiTimeout) {
            // Retry action handled by parent view
        }

        InlineErrorView(error: .sessionExpired)
    }
    .padding()
}

#Preview("Offline Banner") {
    VStack {
        OfflineBanner()
        Spacer()
        Text("Content goes here")
        Spacer()
    }
}
