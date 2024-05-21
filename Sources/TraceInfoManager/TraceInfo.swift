//
//  TraceInfo.swift
//
//
//  Created by MAKSIM YUROV on 21/05/2024.
//

import Foundation

public struct TraceInfo: Codable {
    /// Channel/queue `index` to which `count` and `sequence` belong.
    /// A number between 0 and up to `maxConcurrent` parameter received during enrollment process.
    public let queueIndex: UInt
    
    /// TOTAL number of requests SENT.
    public var sent: UInt
    
    /// Number of SUCCEEDED requests (SUCCESSFUL responses RECEIVED).
    public var succeeded: UInt
    
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
