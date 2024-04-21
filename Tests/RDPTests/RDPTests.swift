import XCTest
@testable import RDP

final class RDPTests: XCTestCase {
    
    var count = 500000
    var points: [Point]!
    
    override func setUp() async throws {
        points = {
            (0..<500000).map { _ in
                Point(x: Double.random(in: 20..<30), y: Double.random(in: 120..<130))
            }
        }()
    }
    
    func testExample() throws {
        let drp = IterRDP(points: points)
        measure(metrics: [XCTClockMetric.init()]) {
            let mask: [Point] = drp.polygonApproximation(epsilon: 0.00001)
            print(mask.count)
        }
    }
    
    func testP() {
        let drp = VecRDP(points: points)
        measure(metrics: [XCTClockMetric.init()]) {
            let mask: [Point] = drp.polygonApproximation(epsilon: 0.00001)
            print(mask.count)
        }
    }
    
}
