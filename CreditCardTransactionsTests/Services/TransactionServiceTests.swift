//
//  TransactionServiceTests.swift
//  CreditCardTransactionsTests
//
//  Created by Navjot Singh Bhatti on 2026-02-12.
//

import XCTest
@testable import CreditCardTransactions

@MainActor
final class TransactionServiceTests: XCTestCase {

	// MARK: - Success

	func test_fetchTransactions_returnsTransactions_whenValidJSONInBundle() async throws {
		let validJSON = """
		{
		  "transactions": [
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
		  ]
		}
		"""
		let bundle = try makeTemporaryBundle(resourceName: "transaction-list", json: validJSON)
		let service = TransactionService(bundle: bundle, fileName: "transaction-list")

		let transactions = try await service.fetchTransactions()

		XCTAssertEqual(transactions.count, 1)
		XCTAssertEqual(transactions[0].key, "test-key")
		XCTAssertEqual(transactions[0].merchantName, "Test Merchant")
		XCTAssertEqual(transactions[0].transactionType, .debit)
		XCTAssertEqual(transactions[0].amount.value, 99.99)
		XCTAssertEqual(transactions[0].amount.currency, "CAD")
	}

	// MARK: - File not found

	func test_fetchTransactions_throwsFileNotFound_whenFileMissingInBundle() async {
		let bundle = try! makeTemporaryBundle(resourceName: "other-file", json: "{}")
		let service = TransactionService(bundle: bundle, fileName: "transaction-list")

		do {
			_ = try await service.fetchTransactions()
			XCTFail("Expected TransactionServiceError.fileNotFound")
		} catch let error as TransactionServiceError {
			if case .fileNotFound = error { /* expected */ }
			else { XCTFail("Expected .fileNotFound, got \(error)") }
		} catch {
			XCTFail("Expected TransactionServiceError, got \(error)")
		}
	}

	// MARK: - Decoding failed

	func test_fetchTransactions_throwsDecodingFailed_whenJSONInvalid() async {
		let bundle = try! makeTemporaryBundle(resourceName: "transaction-list", json: "{ invalid }")
		let service = TransactionService(bundle: bundle, fileName: "transaction-list")

		do {
			_ = try await service.fetchTransactions()
			XCTFail("Expected TransactionServiceError.decodingFailed")
		} catch let error as TransactionServiceError {
			if case .decodingFailed = error { /* expected */ }
			else { XCTFail("Expected .decodingFailed, got \(error)") }
		} catch {
			XCTFail("Expected TransactionServiceError, got \(error)")
		}
	}

	// MARK: - Helpers

	/// Creates a temporary bundle containing a single JSON resource for testing.
	private func makeTemporaryBundle(resourceName: String, json: String) throws -> Bundle {
		let tempDir = FileManager.default.temporaryDirectory
			.appendingPathComponent(UUID().uuidString, isDirectory: true)
		try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)

		let bundleDir = tempDir.appendingPathComponent("Test.bundle", isDirectory: true)
		let contentsDir = bundleDir.appendingPathComponent("Contents", isDirectory: true)
		let resourcesDir = contentsDir.appendingPathComponent("Resources", isDirectory: true)
		try FileManager.default.createDirectory(at: resourcesDir, withIntermediateDirectories: true)

		let fileURL = resourcesDir.appendingPathComponent("\(resourceName).json")
		try json.write(to: fileURL, atomically: true, encoding: .utf8)

		guard let bundle = Bundle(path: bundleDir.path) else {
			throw NSError(domain: "TransactionServiceTests", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to create bundle"])
		}
		return bundle
	}
}
