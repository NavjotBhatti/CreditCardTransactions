//
//  TransactionDetailView.swift
//  CreditCardTransactions
//
//  Created by Navjot Singh Bhatti on 2026-02-12.
//
import SwiftUI

struct TransactionDetailView: View {
	@State private var viewModel: TransactionDetailViewModel
	
	init(transaction: Transaction, onClose: @escaping () -> Void) {
		_viewModel = State(initialValue: TransactionDetailViewModel(transaction: transaction, onClose: onClose))
	}
	
	var body: some View {
		ScrollView {
			VStack(spacing:0) {
				cardContent
			}
			.padding(.horizontal, 16)
			.padding(.top, 16)
			.padding(.bottom, 16)
			
		}
		.background(Color(.systemBackground))
		.navigationTitle(Text("Transaction Details"))
		.navigationBarTitleDisplayMode(.inline)
		.navigationBarBackButtonHidden()
		
	}
	
	private var cardContent: some View {
		VStack(alignment: .leading, spacing: 0) {
			VStack(spacing: 14) {
				Image("success-icon")
					.renderingMode(.template)
					.resizable()
					.frame(width: 60, height: 60)
					.foregroundColor(viewModel.isCredit ? .green : .red)
				Text(viewModel.isCredit ? "Credit Transaction" : "Debit Transaction")
					.font(.title)
					.bold()
					.foregroundStyle(.primary)
			}
			.frame(maxWidth: .infinity)
			.padding(.top, 28)
			.padding(.bottom, 24)

			detailRow(label: "From", value: viewModel.transaction.fromAccount)
			detailRow(label: "Amount", value: viewModel.transaction.formattedAmount)

			ToolTipView()
				.padding(.top, 20)
				.padding(.horizontal, 0)

			CloseButton(action: viewModel.close)
				.padding(.top, 28)
				.padding(.bottom, 20)
		}
		.padding(24)
		.background(Color(.systemBackground))
		.clipShape(RoundedRectangle(cornerRadius: 16))
		.shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
	}
	
	private func detailRow(label: String, value: String) -> some View {
		VStack(alignment: .leading, spacing: 8) {
			Text(label)
				.font(.subheadline)
				.foregroundStyle(.secondary)
			Text(value)
				.font(.body)
				.foregroundStyle(.primary)
		}
		.frame(maxWidth: .infinity, alignment: .leading)
		.padding(.vertical, 14)
		.overlay(alignment: .bottom) {
			Rectangle()
				.fill(.separator)
				.frame(height: 1)
		}
	}
	private struct CloseButton: View {
		let action: () -> Void
		
		var body: some View {
			Button(action: action) {
				Text("Close")
					.font(.headline)
					.fontWeight(.semibold)
					.foregroundStyle(.white)
					.frame(maxWidth: .infinity)
					.padding(.vertical, 16)
			}
			.background(.red)
			.clipShape(RoundedRectangle(cornerRadius: 12))
		}
	}
}
// MARK: - Previews
#Preview("Debit") {
	let t = Transaction(
		key: "preview",
		transactionType: .debit,
		merchantName: "Cash Advance",
		description: nil,
		amount: Amount(value: 50, currency: "CAD"),
		postedDate: "2021-05-31",
		fromAccount: "Passport Visa Infinite",
		fromCardNumber: "4537350001688012"
	)
	return TransactionDetailView(transaction: t, onClose: {})
}

#Preview("Credit") {
	let t = Transaction(
		key: "preview2",
		transactionType: .credit,
		merchantName: "Payment",
		description: "Payment (Scotiabank)",
		amount: Amount(value: 200.20, currency: "CAD"),
		postedDate: "2021-05-31",
		fromAccount: "Momentum Regular Visa",
		fromCardNumber: "4537350001688012"
	)
	return TransactionDetailView(transaction: t, onClose: {})
}
