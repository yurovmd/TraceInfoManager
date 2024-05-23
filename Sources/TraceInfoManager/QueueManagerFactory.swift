//
//  QueueManagerFactory.swift
//
//
//  Created by MAKSIM YUROV on 22/05/2024.
//

import Foundation


/// `QueueManagerFactory` provides a factory method to create a `QueueManager` instance.
public class QueueManagerFactory {
    /// Initializes the QueueManager that works with TraceInfo, with a specified number of concurrent queues.
    /// - Parameter maxConcurrent: The maximum number of concurrent queues.
    public static func traceInfoCounter(maxConcurrent: UInt) -> QueueManager {
        QueueManagerImpl(maxConcurrent: maxConcurrent)
    }
}
