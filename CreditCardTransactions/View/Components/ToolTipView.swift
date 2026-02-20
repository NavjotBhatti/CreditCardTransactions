//
//  ToolTipView.swift
//  CreditCardTransactions
//
//  Created by Navjot Singh Bhatti on 2026-02-12.
//

import SwiftUI

struct ToolTipView: View {
	static let shortMessage = "Transactions are processed Monday to Friday (excluding holidays)."
	static let expandedMessage = "Transactions made before 8:30 pm ET Monday to Friday (excluding holidays) will show up in your account the same day."

	@State private var isExpanded = false

	var body: some View {
		VStack(alignment: .leading, spacing: 0) {
			HStack(alignment: .top, spacing: 14) {
				Image("buddy-tip-icon")
					.resizable()
					.aspectRatio(contentMode: .fit)
					.frame(width: 28, height: 28)
				VStack(alignment: .leading, spacing: 6) {
					Text(Self.shortMessage)
						.font(.subheadline)
						.foregroundStyle(.primary)
					if isExpanded {
						Text(Self.expandedMessage)
							.font(.subheadline)
							.foregroundStyle(.primary)
							.transition(.opacity.combined(with: .move(edge: .top)))
					}
					Button(isExpanded ? "Show less" : "Show more") {
						isExpanded.toggle()
					}
					.font(.subheadline)
					.foregroundStyle(.blue)
				}
				Spacer(minLength: 0)
			}
			.padding(16)
		}
		.background(Color(.secondarySystemBackground))
		.clipShape(RoundedRectangle(cornerRadius: 12))
	}
}
// MARK: - Previews
#Preview {
	ToolTipView()
		.padding()
}
