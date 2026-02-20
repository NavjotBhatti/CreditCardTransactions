//
//  TransactionListView.swift
//  CreditCardTransactions
//
//  Created by Navjot Singh Bhatti on 2026-02-12.
//

import SwiftUI

struct TransactionListView: View {
	@State private var  viewModel: TransactionListViewModel
	init(service: TransactionServiceProtocol = TransactionService()) {
		_viewModel = .init(initialValue: TransactionListViewModel(service: service))
	}
	
	var body: some View {
		NavigationStack {
			TransactionListContent(viewModel: viewModel)
		}
	}
}

private struct TransactionListContent: View {
	@Bindable var viewModel: TransactionListViewModel

	var body: some View {
		content
			.navigationTitle("Transactions")
			.navigationBarTitleDisplayMode(.inline)
			.task { await viewModel.loadTransactions() }
			.refreshable { await viewModel.loadTransactions() }
			.navigationDestination(item: $viewModel.selectedTransaction) { transaction in
				TransactionDetailView(transaction: transaction, onClose: { viewModel.clearSelection() })
			}
	}

	@ViewBuilder
	private var content: some View {
		if viewModel.isLoading {
			VStack(spacing: 16) {
				ProgressView()
					.scaleEffect(1.2)
				Text("Loading transactions…")
					.font(.subheadline)
					.foregroundStyle(.secondary)
			}
			.frame(maxWidth: .infinity, maxHeight: .infinity)
		} else if let error = viewModel.errorMessage {
			VStack(spacing: 16) {
				Image(systemName: "exclamationmark.triangle.fill")
					.font(.system(size: 44))
					.foregroundStyle(.orange)
				Text("Something went wrong")
					.font(.headline)
				Text(error)
					.font(.subheadline)
					.foregroundStyle(.secondary)
					.multilineTextAlignment(.center)
			}
			.padding(32)
			.frame(maxWidth: .infinity, maxHeight: .infinity)
		} else if viewModel.transactions.isEmpty {
			emptyStateView
		} else {
			List(viewModel.transactions) { transaction in
				Button {
					viewModel.selectedTransaction = transaction
				} label: {
					TransactionRowView(transaction: transaction)
				}
				.buttonStyle(.plain)
				.listRowInsets(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 16))
				.listRowSeparatorTint(Color(.separator))
			}
			.listStyle(.insetGrouped)
			.scrollContentBackground(.hidden)
		}
	}

	private var emptyStateView: some View {
		VStack(spacing: 20) {
			Image(systemName: "tray")
				.font(.system(size: 56))
				.foregroundStyle(.tertiary)
			Text("No transactions yet")
				.font(.headline)
			Text("Your transactions will appear here.")
				.font(.subheadline)
				.foregroundStyle(.secondary)
				.multilineTextAlignment(.center)
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.padding(40)
	}
}

struct TransactionRowView: View {
	let transaction: Transaction

	private var isCredit: Bool { transaction.transactionType == .credit }
	private var displayAmount: String {
		isCredit ? transaction.formattedAmount : "- " + transaction.formattedAmount
	}
	private var amountColor: Color { isCredit ? .green : .primary }

	var body: some View {
		HStack(alignment: .center, spacing: 12) {
			Image(systemName: isCredit ? "arrow.down.circle.fill" : "arrow.up.circle.fill")
				.font(.title2)
				.foregroundStyle(isCredit ? .green : .secondary)

			VStack(alignment: .leading, spacing: 4) {
				Text(transaction.merchantName)
					.font(.subheadline)
					.fontWeight(.semibold)
					.foregroundStyle(.primary)
					.lineLimit(2)
				if let desc = transaction.description, !desc.isEmpty {
					Text(desc)
						.font(.caption)
						.foregroundStyle(.secondary)
						.lineLimit(1)
				}
			}
			.frame(maxWidth: .infinity, alignment: .leading)

			VStack(alignment: .trailing, spacing: 2) {
				Text(displayAmount)
					.font(.subheadline)
					.fontWeight(.semibold)
					.foregroundStyle(amountColor)
			}
			Image(systemName: "chevron.right")
				.font(.caption.weight(.semibold))
				.foregroundStyle(.secondary)
		}
		.padding(.vertical, 2)
	}
}

// MARK: - Previews
struct PreviewTransactionService: TransactionServiceProtocol {
	func fetchTransactions() async throws -> [Transaction] {
		[
			Transaction(
				key: "p1",
				transactionType: .debit,
				merchantName: "Cash Advance",
				description: "Bill payment",
				amount: Amount(value: 200.20, currency: "CAD"),
				postedDate: "2021-05-31",
				fromAccount: "Momentum Regular Visa",
				fromCardNumber: "4537350001688012"
			),
			Transaction(
				key: "p2",
				transactionType: .credit,
				merchantName: "Payment Scotiabank",
				description: "Payment (Scotiabank)",
				amount: Amount(value: 5, currency: "CAD"),
				postedDate: "2021-03-30",
				fromAccount: "Momentum Regular Visa",
				fromCardNumber: "4537350001688004"
			),
		]
	}
}

#Preview {
	TransactionListView(service: PreviewTransactionService())
}
