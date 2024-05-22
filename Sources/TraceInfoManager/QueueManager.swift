//
//  QueueManager.swift
//
//
//  Created by MAKSIM YUROV on 21/05/2024.
//

import Foundation

public protocol QueueManager {
    func allocateQueueIndex() async throws -> UInt
    func deallocateQueueIndex(queueIndex: UInt) async
    func incrementSent(queueIndex: UInt) async throws
    func incrementSucceeded(queueIndex: UInt) async throws
    func getTraceInfo(queueIndex: UInt) async -> TraceInfo?
}

/// Errors that can be thrown by `QueueManager`.
public enum QueueManagerError: Error {
    case invalidQueueIndex
    case noAvailableQueueIndex
}

/// Manages multiple concurrent queues and tracks the counts of processed and successfully processed items.
actor QueueManagerImpl: QueueManager {
    private var traceInfos = [UInt: TraceInfo]()
    private let maxConcurrent: UInt
    private var allocatedIndices = Set<UInt>()
    
    /// Initializes the QueueManager with a specified number of concurrent queues.
    /// - Parameter maxConcurrent: The maximum number of concurrent queues.
    init(maxConcurrent: UInt = 10) {
        self.maxConcurrent = maxConcurrent
    }
    
    /// Allocates and returns an available queue index.
    /// - Returns: An available queue index.
    func allocateQueueIndex() async throws -> UInt {
        for index in 0..<maxConcurrent {
            if !allocatedIndices.contains(index) {
                allocatedIndices.insert(index)
                return index
            }
        }
        throw QueueManagerError.noAvailableQueueIndex
    }
    
    /// Increments the count of processed items for a specified queue.
    /// - Parameter queueIndex: The index of the queue.
    func incrementSent(queueIndex: UInt) async throws {
        guard queueIndex < maxConcurrent else {
            throw QueueManagerError.invalidQueueIndex
        }
        
        var traceInfo = traceInfos[queueIndex] ?? TraceInfo(queueIndex: queueIndex)
        traceInfo.sent += 1
        traceInfos[queueIndex] = traceInfo
    }
    
    /// Increments the count of successfully processed items for a specified queue.
    /// - Parameter queueIndex: The index of the queue.
    func incrementSucceeded(queueIndex: UInt) async throws {
        guard queueIndex < maxConcurrent else {
            throw QueueManagerError.invalidQueueIndex
        }
        
        var traceInfo = traceInfos[queueIndex] ?? TraceInfo(queueIndex: queueIndex)
        traceInfo.succeeded += 1
        traceInfos[queueIndex] = traceInfo
    }
    
    /// Retrieves the trace information for a specified queue.
    /// - Parameter queueIndex: The index of the queue.
    /// - Returns: The trace information for the queue, if it exists.
    func getTraceInfo(queueIndex: UInt) async -> TraceInfo? {
        return traceInfos[queueIndex]
    }
    
    /// Deallocates a previously allocated queue index.
    /// - Parameter queueIndex: The index of the queue to deallocate.
    func deallocateQueueIndex(queueIndex: UInt) async {
        allocatedIndices.remove(queueIndex)
        traceInfos[queueIndex] = nil
    }
}
