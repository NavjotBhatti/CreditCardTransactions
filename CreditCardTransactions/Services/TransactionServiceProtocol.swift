//
//  TransactionServiceProtocol.swift
//  CreditCardTransactions
//
//  Created by Navjot Singh Bhatti on 2026-02-12.
//
import Foundation

protocol TransactionServiceProtocol: Sendable {
	func fetchTransactions() async throws -> [Transaction]
}
