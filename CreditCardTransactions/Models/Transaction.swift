//
//  Transaction.swift
//  CreditCardTransactions
//
//  Created by Navjot Singh Bhatti on 2026-02-11.
//

import Foundation

enum TransactionType: String, Codable, CaseIterable, Hashable, Sendable {
	case credit = "CREDIT"
	case debit = "DEBIT"
}

struct Amount: Codable, Equatable, Hashable, Sendable {
	let value: Double
	let currency: String
}

struct Transaction: Codable, Identifiable, Hashable, Equatable, Sendable {
	let key: String
	let transactionType: TransactionType
	let merchantName: String
	let description: String?
	let amount: Amount
	let postedDate: String
	let fromAccount: String
	let fromCardNumber: String

	var id: String {
		key
	}

	/// Parsed date from `postedDate` (yyyy-MM-dd). Nil if string cannot be parsed.
	var postedDateAsDate: Date? {
		Self.postedDateFormatter.date(from: postedDate)
	}

	private static let postedDateFormatter: DateFormatter = {
		let f = DateFormatter()
		f.dateFormat = "yyyy-MM-dd"
		f.locale = Locale(identifier: "en_US_POSIX")
		f.timeZone = TimeZone(identifier: "UTC")
		return f
	}()

	enum CodingKeys: String, CodingKey {
		case key
		case transactionType = "transaction_type"
		case merchantName = "merchant_name"
		case description
		case amount
		case postedDate = "posted_date"
		case fromAccount = "from_account"
		case fromCardNumber = "from_card_number"
	}

	var formattedAmount: String {
		let formatter = NumberFormatter()
		formatter.numberStyle = .currency
		formatter.currencyCode = amount.currency
		return formatter.string(from: NSNumber(value: amount.value)) ?? "\(amount.value) \(amount.currency)"
	}
}


struct TransactionsListResponse: Codable, Sendable {
	let transactions: [Transaction]
}
