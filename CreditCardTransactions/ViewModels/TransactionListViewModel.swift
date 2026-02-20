//
//  TransactionListViewModel.swift
//  CreditCardTransactions
//
//  Created by Navjot Singh Bhatti on 2026-02-12.
//

import Foundation

@Observable
final class TransactionListViewModel {
	var transactions: [Transaction] = []
	var isLoading = true
	var errorMessage: String?
	var selectedTransaction: Transaction?
	
	private let service: TransactionServiceProtocol
	
	init(service: TransactionServiceProtocol = TransactionService()) {
		self.service = service
	}
	
	func loadTransactions() async {
		isLoading = true
		errorMessage = nil
		do {
			let fetched = try await service.fetchTransactions()
			transactions = fetched.sorted { t1, t2 in
				let d1 = t1.postedDateAsDate ?? .distantPast
				let d2 = t2.postedDateAsDate ?? .distantPast
				return d1 > d2
			}
		} catch {
			errorMessage = error.localizedDescription
		}
		isLoading = false
	}
	
	func clearSelection() {
		selectedTransaction = nil
	}
}
