//
//  TransactionDetailViewModel.swift
//  CreditCardTransactions
//
//  Created by Navjot Singh Bhatti on 2026-02-12.
//

import Foundation

@Observable
final class TransactionDetailViewModel {
	let transaction: Transaction
	var isCredit: Bool { Self.isCredit(for: transaction) }

	nonisolated static func isCredit(for transaction: Transaction) -> Bool {
		transaction.transactionType == .credit
	}

	private let onClose: () -> Void
	
	init(transaction: Transaction, onClose: @escaping () -> Void) {
		self.transaction = transaction
		self.onClose = onClose
	}
	
	func close() {
		onClose()
	}
	
}
