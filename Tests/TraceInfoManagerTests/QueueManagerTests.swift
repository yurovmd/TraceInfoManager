import XCTest
@testable import TraceInfoManager

final class QueueManagerTests: XCTestCase {
    func testExecute() async throws {
        let queueManager = QueueManagerFactory.traceInfoCounter(maxConcurrent: 1)
        var sentBefore = 0
        var succeededBefore = 0
        var sentAfter = 0
        var succeededAfter = 0
        // Check initial state
        try await queueManager.execute { traceInfo in
            XCTAssertEqual(traceInfo.queueIndex, 0)
            sentBefore = Int(traceInfo.sent)
            succeededBefore = Int(traceInfo.succeeded)
            // Simulate a long-running operation
            try await Task.sleep(nanoseconds: 1_000_000_000)
        }
        // Check state after execution
        try await queueManager.execute { traceInfo in
            XCTAssertEqual(traceInfo.queueIndex, 0)
            sentAfter = Int(traceInfo.sent)
            succeededAfter = Int(traceInfo.succeeded)
            // Simulate a long-running operation
            try await Task.sleep(nanoseconds: 1_000_000_000)
        }
        XCTAssertEqual(sentAfter, sentBefore + 1)
        XCTAssertEqual(succeededAfter, succeededBefore + 1)
    }
    
    func testFailedExecute() async throws {
        let queueManager = QueueManagerFactory.traceInfoCounter(maxConcurrent: 1)
        var sentBefore = 0
        var succeededBefore = 0
        var sentAfter = 0
        var succeededAfter = 0
        // Check initial state
        do {
            try await queueManager.execute { traceInfo in
                XCTAssertEqual(traceInfo.queueIndex, 0)
                sentBefore = Int(traceInfo.sent)
                succeededBefore = Int(traceInfo.succeeded)
                // Simulate a failure
                throw NSError(domain: "TestError", code: 1, userInfo: nil)
            }
        } catch {
            // Expected error
        }
        // Check state after execution
        do {
            try await queueManager.execute { traceInfo in
                XCTAssertEqual(traceInfo.queueIndex, 0)
                sentAfter = Int(traceInfo.sent)
                succeededAfter = Int(traceInfo.succeeded)
                // Simulate a long-running operation
                try await Task.sleep(nanoseconds: 1_000_000_000)
            }
        } catch {
            XCTFail("Execution should not fail here: \(error)")
        }
        XCTAssertEqual(sentAfter, sentBefore + 1)
        XCTAssertEqual(succeededAfter, succeededBefore)
    }
    
    func testThreeConcurrentQueues() async throws {
        let queueManager = QueueManagerFactory.traceInfoCounter(maxConcurrent: 3)
        let collector = TraceInfoCollector()
        let expectation1 = XCTestExpectation(description: "First operation")
        let expectation2 = XCTestExpectation(description: "Second operation")
        let expectation3 = XCTestExpectation(description: "Third operation")
        let expectation4 = XCTestExpectation(description: "Fourth operation")
        async let operation1: Void = queueManager.execute { traceInfo in
            XCTAssertTrue((0..<3).contains(traceInfo.queueIndex))
            await collector.add(traceInfo)
            try await Task.sleep(nanoseconds: 2_000_000_000)
            expectation1.fulfill()
        }
        async let operation2: Void = queueManager.execute { traceInfo in
            XCTAssertTrue((0..<3).contains(traceInfo.queueIndex))
            await collector.add(traceInfo)
            try await Task.sleep(nanoseconds: 2_000_000_000)
            expectation2.fulfill()
        }
        async let operation3: Void = queueManager.execute { traceInfo in
            XCTAssertTrue((0..<3).contains(traceInfo.queueIndex))
            await collector.add(traceInfo)
            try await Task.sleep(nanoseconds: 2_000_000_000)
            expectation3.fulfill()
        }
        async let operation4: Void = queueManager.execute { traceInfo in
            XCTAssertTrue((0..<3).contains(traceInfo.queueIndex))
            await collector.add(traceInfo)
            try await Task.sleep(nanoseconds: 2_000_000_000)
            expectation4.fulfill()
        }
        await fulfillment(of: [expectation1, expectation2, expectation3], timeout: 3.0)
        await fulfillment(of: [expectation4], timeout: 5.0)
        try await operation1
        try await operation2
        try await operation3
        try await operation4
        // Ensure that each index is used at least once and no index is used more than the max concurrent limit
        let indices = await collector.traceInfos.map { $0.queueIndex }
        XCTAssertEqual(Set(indices).count, 3)
    }
}

fileprivate actor TraceInfoCollector {
    private(set) var traceInfos: [TraceInfo] = []
    
    func add(_ traceInfo: TraceInfo) {
        traceInfos.append(traceInfo)
    }
}
