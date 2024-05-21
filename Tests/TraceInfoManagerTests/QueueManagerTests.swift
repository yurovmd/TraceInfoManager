import XCTest
@testable import TraceInfoManager

final class QueueManagerTests: XCTestCase {
    func testAllocateQueueIndex() async throws {
        let queueManager = TraceInfoManager.QueueManagerImpl(maxConcurrent: 5)
        let index1 = try await queueManager.allocateQueueIndex()
        let index2 = try await queueManager.allocateQueueIndex()
        XCTAssertEqual(index1, 0)
        XCTAssertEqual(index2, 1)
    }
    
    func testIncrementSent() async throws {
        let queueManager = TraceInfoManager.QueueManagerImpl(maxConcurrent: 5)
        let queueIndex = try await queueManager.allocateQueueIndex()
        try await queueManager.incrementSent(queueIndex: queueIndex)
        let traceInfo = await queueManager.getTraceInfo(queueIndex: queueIndex)
        XCTAssertNotNil(traceInfo)
        XCTAssertEqual(traceInfo?.sent, 1)
        XCTAssertEqual(traceInfo?.succeeded, 0)
    }
    
    func testIncrementSucceeded() async throws {
        let queueManager = TraceInfoManager.QueueManagerImpl(maxConcurrent: 5)
        let queueIndex = try await queueManager.allocateQueueIndex()
        try await queueManager.incrementSent(queueIndex: queueIndex)
        try await queueManager.incrementSucceeded(queueIndex: queueIndex)
        let traceInfo = await queueManager.getTraceInfo(queueIndex: queueIndex)
        XCTAssertNotNil(traceInfo)
        XCTAssertEqual(traceInfo?.sent, 1)
        XCTAssertEqual(traceInfo?.succeeded, 1)
    }
    
    func testMultipleRequests() async throws {
        let queueManager = TraceInfoManager.QueueManagerImpl(maxConcurrent: 5)
        let queueIndex = try await queueManager.allocateQueueIndex()
        try await queueManager.incrementSent(queueIndex: queueIndex)
        try await queueManager.incrementSucceeded(queueIndex: queueIndex)
        try await queueManager.incrementSent(queueIndex: queueIndex)
        try await queueManager.incrementSucceeded(queueIndex: queueIndex)
        let traceInfo = await queueManager.getTraceInfo(queueIndex: queueIndex)
        XCTAssertNotNil(traceInfo)
        XCTAssertEqual(traceInfo?.sent, 2)
        XCTAssertEqual(traceInfo?.succeeded, 2)
    }
    
    func testInvalidQueueIndex() async throws {
        let queueManager = TraceInfoManager.QueueManagerImpl(maxConcurrent: 5)
        let invalidQueueIndex: UInt = 10
        do {
            try await queueManager.incrementSent(queueIndex: invalidQueueIndex)
            XCTFail("Expected to throw, but didn't throw")
        } catch {
            XCTAssertEqual(error as? TraceInfoManager.QueueManagerError, .invalidQueueIndex)
        }
        do {
            try await queueManager.incrementSucceeded(queueIndex: invalidQueueIndex)
            XCTFail("Expected to throw, but didn't throw")
        } catch {
            XCTAssertEqual(error as? TraceInfoManager.QueueManagerError, .invalidQueueIndex)
        }
    }
    
    func testDeallocateQueueIndex() async throws {
        let queueManager = TraceInfoManager.QueueManagerImpl(maxConcurrent: 5)
        let queueIndex = try await queueManager.allocateQueueIndex()
        await queueManager.deallocateQueueIndex(queueIndex: queueIndex)
        let traceInfo = await queueManager.getTraceInfo(queueIndex: queueIndex)
        XCTAssertNil(traceInfo)
        let newIndex = try await queueManager.allocateQueueIndex()
        XCTAssertEqual(newIndex, queueIndex)
    }
}
