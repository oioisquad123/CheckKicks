//
//  EmailSignInView.swift
//  Auntentic_AI
//
//  Created by Claude AI on 12/26/25.
//  Task 6: Email Sign-In View
//  Updated: OTP verification flow - Jan 3, 2026
//

import SwiftUI

/// Authentication flow state
enum AuthFlowState {
    case signIn
    case signUp
    case verifySignUp
    case forgotPassword
    case verifyPasswordReset
}

/// Email/Password authentication view with OTP verification
struct EmailSignInView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.navigationCoordinator) private var coordinator
    @Environment(\.authenticationService) private var authService

    @State private var email = ""
    @State private var password = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var otpCode = ""
    @State private var flowState: AuthFlowState = .signIn
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var isProcessing = false

    // MARK: - Email Validation

    /// Check if email format is valid using regex
    private var isValidEmail: Bool {
        guard !email.isEmpty else { return false }
        let emailPattern = "[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let predicate = NSPredicate(format: "SELF MATCHES %@", emailPattern)
        return predicate.evaluate(with: email)
    }

    /// Error message for invalid email (nil if valid or empty)
    private var emailError: String? {
        if email.isEmpty { return nil }
        return isValidEmail ? nil : "Please enter a valid email address"
    }

    var body: some View {
        NavigationStack {
            Form {
                switch flowState {
                case .signIn:
                    signInSection
                case .signUp:
                    signUpSection
                case .verifySignUp:
                    verifySignUpSection
                case .forgotPassword:
                    forgotPasswordSection
                case .verifyPasswordReset:
                    verifyPasswordResetSection
                }
            }
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }

    // MARK: - Navigation Title

    private var navigationTitle: String {
        switch flowState {
        case .signIn: return "Sign In"
        case .signUp: return "Sign Up"
        case .verifySignUp: return "Verify Email"
        case .forgotPassword: return "Reset Password"
        case .verifyPasswordReset: return "New Password"
        }
    }

    // MARK: - Sign In Section

    private var signInSection: some View {
        Group {
            Section {
                TextField("Email", text: $email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .autocorrectionDisabled()

                if let error = emailError {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                }

                SecureField("Password", text: $password)
                    .textContentType(.password)
            }

            Section {
                Button(action: handleSignIn) {
                    HStack {
                        Spacer()
                        if isProcessing {
                            ProgressView()
                        } else {
                            Text("Sign In")
                                .fontWeight(.semibold)
                        }
                        Spacer()
                    }
                }
                .disabled(!isValidEmail || password.isEmpty || isProcessing)
            }

            Section {
                Button(action: { flowState = .signUp }) {
                    Text("Don't have an account? Sign Up")
                        .font(.footnote)
                }

                Button(action: { flowState = .forgotPassword }) {
                    Text("Forgot Password?")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
            }
        }
    }

    // MARK: - Sign Up Section

    private var signUpSection: some View {
        Group {
            Section {
                TextField("Email", text: $email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .autocorrectionDisabled()

                if let error = emailError {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                }

                SecureField("Password (min 12 characters)", text: $password)
                    .textContentType(.newPassword)
            }

            Section {
                Button(action: handleSignUp) {
                    HStack {
                        Spacer()
                        if isProcessing {
                            ProgressView()
                        } else {
                            Text("Sign Up")
                                .fontWeight(.semibold)
                        }
                        Spacer()
                    }
                }
                .disabled(!isValidEmail || password.count < 12 || isProcessing)
            }

            Section {
                Button(action: { flowState = .signIn }) {
                    Text("Already have an account? Sign In")
                        .font(.footnote)
                }
            }
        }
    }

    // MARK: - Verify Sign Up Section

    private var verifySignUpSection: some View {
        Group {
            Section {
                Text("We sent a 6-digit code to:")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(email)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }

            Section(header: Text("Enter Verification Code")) {
                TextField("000000", text: $otpCode)
                    .keyboardType(.numberPad)
                    .font(.system(size: 24, weight: .bold, design: .monospaced))
                    .multilineTextAlignment(.center)
                    .onChange(of: otpCode) { _, newValue in
                        // Limit to 6 digits
                        otpCode = String(newValue.prefix(6)).filter { $0.isNumber }
                    }
            }

            Section {
                Button(action: handleVerifySignUp) {
                    HStack {
                        Spacer()
                        if isProcessing {
                            ProgressView()
                        } else {
                            Text("Verify Email")
                                .fontWeight(.semibold)
                        }
                        Spacer()
                    }
                }
                .disabled(otpCode.count != 6 || isProcessing)
            }

            Section {
                Button(action: handleResendOTP) {
                    Text("Didn't receive code? Resend")
                        .font(.footnote)
                }
                .disabled(isProcessing)

                Button(action: {
                    flowState = .signUp
                    otpCode = ""
                }) {
                    Text("Back to Sign Up")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
            }
        }
    }

    // MARK: - Forgot Password Section

    private var forgotPasswordSection: some View {
        Group {
            Section(footer: Text("Enter your email and we'll send you a code to reset your password.")) {
                TextField("Email", text: $email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .autocorrectionDisabled()

                if let error = emailError {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }

            Section {
                Button(action: handleForgotPassword) {
                    HStack {
                        Spacer()
                        if isProcessing {
                            ProgressView()
                        } else {
                            Text("Send Reset Code")
                                .fontWeight(.semibold)
                        }
                        Spacer()
                    }
                }
                .disabled(!isValidEmail || isProcessing)
            }

            Section {
                Button(action: { flowState = .signIn }) {
                    Text("Back to Sign In")
                        .font(.footnote)
                }
            }
        }
    }

    // MARK: - Verify Password Reset Section

    private var verifyPasswordResetSection: some View {
        Group {
            Section {
                Text("We sent a 6-digit code to:")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(email)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }

            Section(header: Text("Enter Reset Code")) {
                TextField("000000", text: $otpCode)
                    .keyboardType(.numberPad)
                    .font(.system(size: 24, weight: .bold, design: .monospaced))
                    .multilineTextAlignment(.center)
                    .onChange(of: otpCode) { _, newValue in
                        otpCode = String(newValue.prefix(6)).filter { $0.isNumber }
                    }
            }

            Section(header: Text("New Password")) {
                SecureField("New Password (min 12 characters)", text: $newPassword)
                    .textContentType(.newPassword)

                SecureField("Confirm Password", text: $confirmPassword)
                    .textContentType(.newPassword)
            }

            Section {
                Button(action: handleVerifyPasswordReset) {
                    HStack {
                        Spacer()
                        if isProcessing {
                            ProgressView()
                        } else {
                            Text("Reset Password")
                                .fontWeight(.semibold)
                        }
                        Spacer()
                    }
                }
                .disabled(otpCode.count != 6 || newPassword.count < 12 || newPassword != confirmPassword || isProcessing)

                if newPassword != confirmPassword && !confirmPassword.isEmpty {
                    Text("Passwords don't match")
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }

            Section {
                Button(action: {
                    flowState = .forgotPassword
                    otpCode = ""
                    newPassword = ""
                    confirmPassword = ""
                }) {
                    Text("Back")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
            }
        }
    }

    // MARK: - Actions

    private func handleSignIn() {
        Task {
            isProcessing = true
            do {
                try await authService.signInWithEmail(email: email, password: password)
                try? await Task.sleep(nanoseconds: 300_000_000)
                dismiss()
                await MainActor.run {
                    coordinator.navigateToHome()
                }
            } catch {
                errorMessage = error.localizedDescription
                showError = true
            }
            isProcessing = false
        }
    }

    private func handleSignUp() {
        Task {
            isProcessing = true
            do {
                try await authService.signUpWithEmail(email: email, password: password)
                // Move to OTP verification
                flowState = .verifySignUp
            } catch {
                errorMessage = error.localizedDescription
                showError = true
            }
            isProcessing = false
        }
    }

    private func handleVerifySignUp() {
        Task {
            isProcessing = true
            do {
                try await authService.verifySignUpOTP(email: email, token: otpCode)
                try? await Task.sleep(nanoseconds: 300_000_000)
                dismiss()
                await MainActor.run {
                    coordinator.navigateToHome()
                }
            } catch {
                errorMessage = "Invalid or expired code. Please try again."
                showError = true
            }
            isProcessing = false
        }
    }

    private func handleResendOTP() {
        Task {
            isProcessing = true
            do {
                try await authService.resendSignUpOTP(email: email)
                errorMessage = "A new code has been sent to your email."
                showError = true
            } catch {
                errorMessage = "Failed to resend code. Please wait a moment and try again."
                showError = true
            }
            isProcessing = false
        }
    }

    private func handleForgotPassword() {
        Task {
            isProcessing = true
            do {
                try await authService.resetPassword(email: email)
                flowState = .verifyPasswordReset
            } catch {
                errorMessage = error.localizedDescription
                showError = true
            }
            isProcessing = false
        }
    }

    private func handleVerifyPasswordReset() {
        Task {
            isProcessing = true
            do {
                try await authService.verifyPasswordResetOTP(email: email, token: otpCode, newPassword: newPassword)
                try? await Task.sleep(nanoseconds: 300_000_000)
                dismiss()
                await MainActor.run {
                    coordinator.navigateToHome()
                }
            } catch {
                errorMessage = "Invalid or expired code. Please try again."
                showError = true
            }
            isProcessing = false
        }
    }
}

// MARK: - Preview
#Preview {
    EmailSignInView()
        .environment(\.navigationCoordinator, NavigationCoordinator())
        .environment(\.authenticationService, AuthenticationService())
}
