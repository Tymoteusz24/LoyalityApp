//
//  ErrorToastView.swift
//  DashboardFeature
//
//  Created by Tymoteusz Pasieka on 10/19/25.
//

import SwiftUI

public struct ErrorToastView: View {
    let message: String
    let onDismiss: () -> Void
    
    public init(
        message: String,
        onDismiss: @escaping () -> Void) {
        self.message = message
        self.onDismiss = onDismiss
    }
    
    public var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.white)
                .font(.system(size: 16, weight: .semibold))
            
            Text(message)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.white)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .foregroundStyle(.white.opacity(0.8))
                    .font(.system(size: 12, weight: .bold))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background {
            RoundedRectangle(cornerRadius: 12)
                .fill(.red)
                .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
        }
        .padding(.horizontal, 16)
        .onAppear {
            // Auto-dismiss after 5 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                onDismiss()
            }
        }
    }
}

#Preview {
    ZStack {
        Color.gray.opacity(0.2)
        
        VStack(spacing: 20) {
            ErrorToastView(message: "Failed to activate reward: Network connection lost") {
                print("Dismissed")
            }
            
            ErrorToastView(message: "Short error") {
                print("Dismissed")
            }
            
            ErrorToastView(message: "This is a very long error message that should wrap to multiple lines to demonstrate how the toast handles longer text content gracefully.") {
                print("Dismissed")
            }
        }
    }
}

