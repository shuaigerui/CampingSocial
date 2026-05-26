//
//  CS_IAPManager.swift
//  CampingSocailRp
//
//  Created by  mac on 2026/5/26.
//

import Foundation
import StoreKit

enum CS_IAPError: LocalizedError {
    case productNotFound
    case userCancelled
    case pending
    case unverified
    case purchaseFailed

    var errorDescription: String? {
        switch self {
        case .productNotFound:
            return "Product not available. Please try again later."
        case .userCancelled:
            return nil
        case .pending:
            return "Purchase is pending approval."
        case .unverified:
            return "Unable to verify purchase."
        case .purchaseFailed:
            return "Purchase failed. Please try again."
        }
    }
}

/// StoreKit 2 内购
@MainActor
final class CS_IAPManager {

    static let shared = CS_IAPManager()

    private var productsByID: [String: Product] = [:]
    private var transactionListener: Task<Void, Never>?

    private enum StorageKey {
        static let finishedTransactionIDs = "cs.iap.finishedTransactionIDs"
    }

    private init() {
        transactionListener = listenForTransactions()
    }

    deinit {
        transactionListener?.cancel()
    }

    // MARK: - Products

    @discardableResult
    func loadProducts() async -> [Product] {
        do {
            let products = try await Product.products(for: Set(CS_RechargePackage.productIds))
            productsByID = Dictionary(uniqueKeysWithValues: products.map { ($0.id, $0) })
            return products.sorted { lhs, rhs in
                (catalogIndex(for: lhs.id) ?? .max) < (catalogIndex(for: rhs.id) ?? .max)
            }
        } catch {
            productsByID = [:]
            return []
        }
    }

    func displayPrice(for package: CS_RechargePackage) -> String {
        productsByID[package.productId]?.displayPrice ?? package.displayPrice
    }

    func isProductReady(_ package: CS_RechargePackage) -> Bool {
        productsByID[package.productId] != nil
    }

    // MARK: - Purchase

    func purchase(package: CS_RechargePackage) async throws {
        var product = productsByID[package.productId]
        if product == nil {
            _ = await loadProducts()
            product = productsByID[package.productId]
        }
        guard let product else {
            throw CS_IAPError.productNotFound
        }

        let result = try await product.purchase()
        switch result {
        case .success(let verification):
            let transaction = try verify(verification)
            await deliverGems(for: transaction)
        case .userCancelled:
            throw CS_IAPError.userCancelled
        case .pending:
            throw CS_IAPError.pending
        @unknown default:
            throw CS_IAPError.purchaseFailed
        }
    }

    // MARK: - Transaction updates

    private func listenForTransactions() -> Task<Void, Never> {
        Task { [weak self] in
            for await result in Transaction.updates {
                await self?.handleTransactionUpdate(result)
            }
        }
    }

    private func handleTransactionUpdate(_ result: VerificationResult<Transaction>) async {
        do {
            let transaction = try verify(result)
            await deliverGems(for: transaction)
        } catch {
            // 忽略无法校验的交易
        }
    }

    private func deliverGems(for transaction: Transaction) async {
        let transactionID = String(transaction.id)
        guard !isTransactionFinished(transactionID) else {
            await transaction.finish()
            return
        }

        guard let package = CS_RechargePackage.package(productId: transaction.productID) else {
            await transaction.finish()
            return
        }

        guard CS_CurrentUser.shared.addGems(package.gems) else {
            return
        }

        markTransactionFinished(transactionID)
        await transaction.finish()
    }

    // MARK: - Private

    private func verify<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw CS_IAPError.unverified
        case .verified(let safe):
            return safe
        }
    }

    private func catalogIndex(for productId: String) -> Int? {
        CS_RechargePackage.catalog.firstIndex { $0.productId == productId }
    }

    private func isTransactionFinished(_ id: String) -> Bool {
        finishedTransactionIDs().contains(id)
    }

    private func markTransactionFinished(_ id: String) {
        var ids = finishedTransactionIDs()
        ids.insert(id)
        UserDefaults.standard.set(Array(ids), forKey: StorageKey.finishedTransactionIDs)
    }

    private func finishedTransactionIDs() -> Set<String> {
        Set(UserDefaults.standard.stringArray(forKey: StorageKey.finishedTransactionIDs) ?? [])
    }
}
