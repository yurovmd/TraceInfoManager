# TraceInfoManager

A Swift package to manage and track concurrent processing of items.

## Features

- Track processed and successfully processed items per queue
- Supports multiple concurrent queues
- Lazy initialization of queues
- Automatic allocation and deallocation of queue indices
- Error handling for invalid queue indices
- Lightweight and easy to integrate

## Installation

### Swift Package Manager

Add the following dependency to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/TraceInfoManager.git", from: "1.0.0")
]
```

## Usage

```swift
import TraceInfoManager

let queueManager = TraceInfoManager.QueueManager(maxConcurrent: 5)
Task {
    let queueIndex = try await queueManager.allocateQueueIndex()
    try await queueManager.incrementSent(queueIndex: queueIndex)
    // Process your item here
    let success = true // Replace with actual result of processing
    try await queueManager.incrementSucceeded(queueIndex: queueIndex)
    // Deallocate the queue index when done
    await queueManager.deallocateQueueIndex(queueIndex: queueIndex)
}
```

## License

This project is licensed under the MIT License.
