//
//  TransactionListViewModelTests.swift
//  CreditCardTransactionsTests
//
//  Created by Navjot Singh Bhatti on 2026-02-12.
//

import XCTest
@testable import CreditCardTransactions

@MainActor
final class TransactionListViewModelTests: XCTestCase {

	// MARK: - Load success

	func test_loadTransactions_setsTransactionsAndClearsError_whenServiceSucceeds() async {
		let expected = [
			Transaction(
				key: "k1",
				transactionType: .debit,
				merchantName: "Merchant",
				description: nil,
				amount: Amount(value: 10, currency: "CAD"),
				postedDate: "2021-01-01",
				fromAccount: "Account",
				fromCardNumber: "1234"
			),
		]
		let mock = MockTransactionService(transactions: expected)
		let viewModel = TransactionListViewModel(service: mock)

		await viewModel.loadTransactions()

		XCTAssertEqual(viewModel.transactions.count, 1)
		XCTAssertEqual(viewModel.transactions[0].key, "k1")
		XCTAssertEqual(viewModel.transactions[0].merchantName, "Merchant")
		XCTAssertFalse(viewModel.isLoading)
		XCTAssertNil(viewModel.errorMessage)
	}

	func test_loadTransactions_setsLoadingState_duringAndAfterLoad() async {
		let mock = MockTransactionService(transactions: [], delay: 0.01)
		let viewModel = TransactionListViewModel(service: mock)

		XCTAssertTrue(viewModel.isLoading)
		await viewModel.loadTransactions()
		XCTAssertFalse(viewModel.isLoading)
	}

	// MARK: - Load error

	func test_loadTransactions_setsErrorMessage_whenServiceThrows() async {
		struct FailingService: TransactionServiceProtocol {
			func fetchTransactions() async throws -> [Transaction] {
				throw TransactionServiceError.fileNotFound
			}
		}
		let viewModel = TransactionListViewModel(service: FailingService())

		await viewModel.loadTransactions()

		XCTAssertNotNil(viewModel.errorMessage)
		XCTAssertTrue(viewModel.transactions.isEmpty)
		XCTAssertFalse(viewModel.isLoading)
	}

	func test_loadTransactions_clearsPreviousError_onRetry() async {
		let successTransactions = [
			Transaction(
				key: "retry",
				transactionType: .credit,
				merchantName: "Retry Merchant",
				description: nil,
				amount: Amount(value: 1, currency: "CAD"),
				postedDate: "2021-01-01",
				fromAccount: "A",
				fromCardNumber: "1111"
			),
		]
		let mock = MockTransactionService(transactions: successTransactions, failFirst: true)
		let viewModel = TransactionListViewModel(service: mock)

		await viewModel.loadTransactions()
		XCTAssertNotNil(viewModel.errorMessage)

		await viewModel.loadTransactions()
		XCTAssertNil(viewModel.errorMessage)
		XCTAssertEqual(viewModel.transactions.count, 1)
		XCTAssertEqual(viewModel.transactions[0].key, "retry")
	}

	// MARK: - Selection

	func test_loadTransactions_sortsByDateNewestFirst() async {
		let older = Transaction(
			key: "old",
			transactionType: .debit,
			merchantName: "Older",
			description: nil,
			amount: Amount(value: 1, currency: "CAD"),
			postedDate: "2021-01-01",
			fromAccount: "A",
			fromCardNumber: "1"
		)
		let newer = Transaction(
			key: "new",
			transactionType: .credit,
			merchantName: "Newer",
			description: nil,
			amount: Amount(value: 2, currency: "CAD"),
			postedDate: "2021-06-15",
			fromAccount: "A",
			fromCardNumber: "2"
		)
		let mock = MockTransactionService(transactions: [older, newer])
		let viewModel = TransactionListViewModel(service: mock)

		await viewModel.loadTransactions()

		XCTAssertEqual(viewModel.transactions.count, 2)
		XCTAssertEqual(viewModel.transactions[0].key, "new")
		XCTAssertEqual(viewModel.transactions[1].key, "old")
	}

	func test_clearSelection_setsSelectedTransactionToNil() {
		let transaction = Transaction(
			key: "sel",
			transactionType: .credit,
			merchantName: "Pay",
			description: nil,
			amount: Amount(value: 5, currency: "CAD"),
			postedDate: "2021-02-01",
			fromAccount: "A",
			fromCardNumber: "9999"
		)
		let viewModel = TransactionListViewModel(service: MockTransactionService(transactions: []))
		viewModel.selectedTransaction = transaction

		viewModel.clearSelection()

		XCTAssertNil(viewModel.selectedTransaction)
	}
}

// MARK: - Mock service

private final class MockTransactionService: TransactionServiceProtocol, @unchecked Sendable {
	private let transactions: [Transaction]
	private let delay: TimeInterval
	private var failFirst: Bool
	private var callCount = 0

	init(transactions: [Transaction], delay: TimeInterval = 0, failFirst: Bool = false) {
		self.transactions = transactions
		self.delay = delay
		self.failFirst = failFirst
	}

	func fetchTransactions() async throws -> [Transaction] {
		if delay > 0 {
			try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
		}
		callCount += 1
		if failFirst && callCount == 1 {
			throw TransactionServiceError.fileNotFound
		}
		return transactions
	}
}
