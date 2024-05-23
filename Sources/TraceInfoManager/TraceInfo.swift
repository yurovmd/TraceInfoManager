//
//  TraceInfo.swift
//
//
//  Created by MAKSIM YUROV on 21/05/2024.
//

import Foundation

/// `TraceInfo` keeps track of the number of tasks sent to and successfully processed by a specific queue.
public struct TraceInfo: Codable {
    /// The index of the queue this `TraceInfo` is associated with.
    public let queueIndex: UInt
    
    /// Total number of items processed (sent).
    public var sent: UInt
    
    /// Number of successfully processed items.
    public var succeeded: UInt
    
    /// Initializes a new `TraceInfo` object.
    /// - Parameters:
    ///   - queueIndex: The index of the queue.
    ///   - sent: The initial number of items sent. Default is 0.
    ///   - succeeded: The initial number of items succeeded. Default is 0.
    public init(
        queueIndex: UInt,
        sent: UInt = 0,
        succeeded: UInt = 0
    ) {
        self.queueIndex = queueIndex
        self.sent = sent
        self.succeeded = succeeded
    }
}
