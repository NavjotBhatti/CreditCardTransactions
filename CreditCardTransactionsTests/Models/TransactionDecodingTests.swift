//
//  TransactionDecodingTests.swift
//  CreditCardTransactionsTests
//
//  Created by Navjot Singh Bhatti on 2026-02-12.
//

import XCTest
@testable import CreditCardTransactions

@MainActor
final class TransactionDecodingTests: XCTestCase {

	func test_decodeTransaction_fromValidJSON() throws {
		let json = """
		{
		"key": "test-key",
		"transaction_type": "DEBIT",
		"merchant_name": "Test Merchant",
		"description": "Test description",
		"amount": { "value": 99.99, "currency": "CAD" },
		"posted_date": "2021-05-31",
		"from_account": "My Account",
		"from_card_number": "4537350001688012"
		}
		"""
		let data = json.data(using: .utf8)!
		let decoder = JSONDecoder()
		let transaction = try decoder.decode(Transaction.self, from: data)

		XCTAssertEqual(transaction.key, "test-key")
		XCTAssertEqual(transaction.merchantName, "Test Merchant")
		XCTAssertEqual(transaction.description, "Test description")
		XCTAssertEqual(transaction.transactionType, .debit)
		XCTAssertEqual(transaction.amount.value, 99.99)
		XCTAssertEqual(transaction.amount.currency, "CAD")
		XCTAssertEqual(transaction.postedDate, "2021-05-31")
		XCTAssertEqual(transaction.fromAccount, "My Account")
		XCTAssertEqual(transaction.fromCardNumber, "4537350001688012")
	}

	func test_decodeTransaction_withNilDescription() throws {
		let json = """
		{
		"key": "k2",
		"transaction_type": "CREDIT",
		"merchant_name": "Payment",
		"amount": { "value": 5, "currency": "CAD" },
		"posted_date": "2021-03-30",
		"from_account": "Account",
		"from_card_number": "1234"
		}
		"""
		let data = json.data(using: .utf8)!
		let transaction = try JSONDecoder().decode(Transaction.self, from: data)

		XCTAssertNil(transaction.description)
		XCTAssertEqual(transaction.transactionType, .credit)
		XCTAssertEqual(transaction.amount.value, 5)
	}

	func test_decodeTransactionsListResponse() throws {
		let json = """
		{
		"transactions": [
		{
		"key": "one",
		"transaction_type": "DEBIT",
		"merchant_name": "Merchant One",
		"amount": { "value": 10.5, "currency": "CAD" },
		"posted_date": "2021-01-01",
		"from_account": "A",
		"from_card_number": "1111"
		}
		]
		}
		"""
		let data = json.data(using: .utf8)!
		let response = try JSONDecoder().decode(TransactionsListResponse.self, from: data)

		XCTAssertEqual(response.transactions.count, 1)
		XCTAssertEqual(response.transactions[0].merchantName, "Merchant One")
		XCTAssertEqual(response.transactions[0].transactionType, .debit)
	}

	func test_postedDateAsDate_parsesISO8601DateString() throws {
		let json = """
		{
		"key": "k",
		"transaction_type": "DEBIT",
		"merchant_name": "M",
		"amount": { "value": 1, "currency": "CAD" },
		"posted_date": "2021-05-31",
		"from_account": "A",
		"from_card_number": "1234"
		}
		"""
		let data = json.data(using: .utf8)!
		let transaction = try JSONDecoder().decode(Transaction.self, from: data)
		let date = transaction.postedDateAsDate
		XCTAssertNotNil(date)
		var calendar = Calendar(identifier: .gregorian)
		calendar.timeZone = TimeZone(identifier: "UTC")!
		XCTAssertEqual(calendar.component(.year, from: date!), 2021)
		XCTAssertEqual(calendar.component(.month, from: date!), 5)
		XCTAssertEqual(calendar.component(.day, from: date!), 31)
	}
}
