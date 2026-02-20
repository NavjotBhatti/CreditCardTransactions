//
//  TransactionDetailViewModelTests.swift
//  CreditCardTransactionsTests
//
//  Created by Navjot Singh Bhatti on 2026-02-12.
//

import XCTest
@testable import CreditCardTransactions

final class TransactionDetailViewModelTests: XCTestCase {

	func test_isCredit_isTrue_forCreditTransaction() {
		let transaction = Self.makeTransaction(transactionType: .credit)
		XCTAssertTrue(TransactionDetailViewModel.isCredit(for: transaction))
	}

	func test_isCredit_isFalse_forDebitTransaction() {
		let transaction = Self.makeTransaction(transactionType: .debit)
		XCTAssertFalse(TransactionDetailViewModel.isCredit(for: transaction))
	}

	func test_titleIsCreditTransaction_whenCredit() {
		let transaction = Self.makeTransaction(transactionType: .credit)
		let isCredit = TransactionDetailViewModel.isCredit(for: transaction)
		let title = isCredit ? "Credit Transaction" : "Debit Transaction"
		XCTAssertEqual(title, "Credit Transaction")
	}

	func test_titleIsDebitTransaction_whenDebit() {
		let transaction = Self.makeTransaction(transactionType: .debit)
		let isCredit = TransactionDetailViewModel.isCredit(for: transaction)
		let title = isCredit ? "Credit Transaction" : "Debit Transaction"
		XCTAssertEqual(title, "Debit Transaction")
	}
	
	// MARK: - Helper
	private static func makeTransaction(transactionType: TransactionType) -> Transaction {
		Transaction(
			key: "test-key",
			transactionType: transactionType,
			merchantName: "Test",
			description: nil,
			amount: Amount(value: 100, currency: "CAD"),
			postedDate: "2021-01-01",
			fromAccount: "Account",
			fromCardNumber: "1234"
		)
	}
}
