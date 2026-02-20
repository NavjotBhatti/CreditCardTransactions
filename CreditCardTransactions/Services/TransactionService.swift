//
//  TransactionService.swift
//  CreditCardTransactions
//
//  Created by Navjot Singh Bhatti on 2026-02-11.
//

import Foundation

final class TransactionService: TransactionServiceProtocol, @unchecked Sendable {
	private let bundle: Bundle
	private let fileName: String
	private let decoder: JSONDecoder
	
	init(bundle: Bundle = .main, fileName: String = "transaction-list", decoder: JSONDecoder = JSONDecoder()) {
		self.bundle = bundle
		self.fileName = fileName
		self.decoder = decoder
	}
	
	func fetchTransactions() async throws -> [Transaction] {
		guard let url = bundle.url(forResource: fileName, withExtension: "json") else {
			throw TransactionServiceError.fileNotFound
		}
		let data = try Data(contentsOf: url)
		do {
			let response = try decoder.decode(TransactionsListResponse.self, from: data)
			return response.transactions
		} catch {
			throw TransactionServiceError.decodingFailed(error)
		}
	}
}

enum TransactionServiceError: Error, LocalizedError {
	case fileNotFound
	case decodingFailed(Error)
	
	var errorDescription: String? {
		switch self {
		case .fileNotFound:
			return "Transaction list file not found."
		case .decodingFailed(let error):
			return "Failed to decode transactions: \(error.localizedDescription)"
		}
	}
}
