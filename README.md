# TraceInfoManager

## Overview

`TraceInfoManager` is a Swift package designed to manage the allocation and tracking of multiple asynchronous operations using a queue-based approach. It ensures that a specified maximum number of concurrent operations can be executed, while keeping track of the total number of operations sent and the number of operations that successfully completed.

## Features

- Manages concurrent execution of tasks with a specified maximum concurrency.
- Tracks the total number of operations sent and succeeded for each queue.
- Provides a simple and clear interface for executing operations.
- Ensures operations are executed with a read-only copy of `TraceInfo` for tracking purposes.
- Handles the allocation and deallocation of queue indices transparently.

## Use Case

The `TraceInfoManager` is ideal for scenarios where you need to manage a limited number of concurrent operations and track their success. For example, in a network request manager, you might want to limit the number of concurrent requests to avoid overwhelming the server and track the number of successful requests for monitoring or logging purposes.

## Installation

To add `TraceInfoManager` to your project, include the following dependency in your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/TraceInfoManager.git", from: "1.0.0")
]
```

## Usage

```swift
import TraceInfoManager

let queueManager = QueueManagerFactory.traceInfoCounter(maxConcurrent: 5)

Task {
    do {
        try await queueManager.execute { traceInfo in
            print("Operation started with TraceInfo: \(traceInfo)")
            // Simulate a long-running operation
            try await Task.sleep(nanoseconds: 1_000_000_000)
            print("Operation completed with TraceInfo: \(traceInfo)")
        }
    } catch {
        print("Operation failed with error: \(error)")
    }
}
```

## License

This project is licensed under the MIT License.
