import XCTest
@testable import RDP

final class RDPTests: XCTestCase {
    
    var count = 1000000
    var points: [Point2D]!
    
    override func setUp() async throws {
        points = {
            (0..<count).map { _ in
                Point2D(x: Double.random(in: 20..<30), y: Double.random(in: 120..<130))
            }
        }()
    }
    
    func testIter() throws {
        let drp = IterRDP(points: points)
        measure(metrics: [XCTClockMetric(), XCTMemoryMetric()]) {
            let _: [Point2D] = drp.polygonApproximation(epsilon: 0.00001)
        }
    }
    
    func testVec() {
        let drp = VecRDP(points: points)
        measure(metrics: [XCTClockMetric(), XCTMemoryMetric()]) {
            let _: [Point2D] = drp.polygonApproximation(epsilon: 0.00001)
        }
    }
    
}
