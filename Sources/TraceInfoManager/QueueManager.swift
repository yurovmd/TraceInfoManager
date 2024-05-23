//
//  QueueManager.swift
//
//
//  Created by MAKSIM YUROV on 21/05/2024.
//

import AsyncAlgorithms
import Foundation

/// `QueueManager` defines the methods for managing queues and their associated `TraceInfo` objects.
public protocol QueueManager {
    /// Executes a closure with an available `TraceInfo`.
    /// - Parameter operation: The closure to execute.
    func execute(operation: @escaping (TraceInfo) async throws -> Void) async throws
}

/// `QueueManagerImpl` implements the `QueueManager` protocol to manage queues and their associated `TraceInfo` objects.
actor QueueManagerImpl: QueueManager {
    private var traceInfos = [UInt: TraceInfo]()
    private let maxConcurrent: UInt
    private var availableIndices: Set<UInt>
    private let waitingLine = AsyncChannel<CheckedContinuation<UInt, Error>>()
    
    /// Initializes the `QueueManagerImpl` with a specified number of concurrent queues.
    /// - Parameter maxConcurrent: The maximum number of concurrent queues.
    init(maxConcurrent: UInt = 10) {
        self.maxConcurrent = maxConcurrent
        self.availableIndices = Set(0..<maxConcurrent)
        for index in 0..<maxConcurrent {
            traceInfos[index] = TraceInfo(queueIndex: index)
        }
        Task {
            await self.processWaitingLine()
        }
    }
    
    // MARK: - QueueManager
    
    func execute(operation: @escaping (TraceInfo) async throws -> Void) async throws {
        let queueIndex = try await getQueueIndex()
        guard var traceInfo = traceInfos[queueIndex] else {
            fatalError("Queue index \(queueIndex) should always be valid")
        }
        traceInfo.sent += 1
        traceInfos[queueIndex] = traceInfo
        do {
            try await operation(traceInfo)
            traceInfo.succeeded += 1
            traceInfos[queueIndex] = traceInfo
        } catch {
            Task {
                await self.returnQueueIndex(queueIndex)
            }
            throw error
        }
        Task {
            await self.returnQueueIndex(queueIndex)
        }
    }
    
    // MARK: - Private Section
    
    private func getQueueIndex() async throws -> UInt {
        if let index = availableIndices.first {
            availableIndices.remove(index)
            return index
        }
        return try await withCheckedThrowingContinuation { continuation in
            Task {
                await self.waitingLine.send(continuation)
            }
        }
    }
    
    private func returnQueueIndex(_ index: UInt) async {
        availableIndices.insert(index)
        await processWaitingLine()
    }
    
    private func processWaitingLine() async {
        for await continuation in waitingLine {
            if let index = availableIndices.first {
                availableIndices.remove(index)
                continuation.resume(returning: index)
            } else {
                await waitingLine.send(continuation)
            }
        }
    }
}
