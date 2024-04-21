//
//  IterRDP.swift
//
//
//  Created by AFuture on 2024/4/20.
//

import Foundation
import Accelerate

// Swift implementation of the Ramer-Douglas-Peucker algorithm.
public struct IterRDP: RDP {
    
    var points:[Point2D]
    var pointCount: Int = 0
    var pointArrayX:[Double] = []
    var pointArrayY:[Double] = []
    
    public init(points: [Point2D]) {
        self.points = points
        self.pointCount  = points.count
        self.pointArrayX = points.map {$0.x}
        self.pointArrayY = points.map {$0.y}
    }
    
    
    public func polygonApproximationMask(epsilon: Double = 0.0) -> [Bool] {
        let start_idx = 0
        let end_idx = pointCount - 1
        var mask = [Bool](repeating: true, count: pointCount)
        
        var stack: [(start:Int, end:Int)] = []
        stack.append((start:start_idx, end:end_idx))
        
        while !stack.isEmpty {
            let (start, end) = stack.popLast()!
            
            var max_distance: Double = 0.0
            var max_idx: Int = start
            
            
            for i in start..<end {
                if !mask[i] {
                    continue
                }
                let distance = calDistance(p: i, a: start, b:end)
                if distance <= max_distance {
                    continue
                }
                
                max_distance = distance
                max_idx = i
                
            }
            //            print("start \(start), end \(end)")
            //            print("max_idx \(max_idx) max_distance \(max_distance)")
            
            if max_distance > epsilon {
                stack.append((start, max_idx))
                stack.append((max_idx, end))
                
            } else {
                for i in start + 1 ..< end {
                    mask[i] = false
                }
            }
        }
        return mask
    }
    
    public func polygonApproximation(epsilon: Double = 0.0) -> [Point2D] {
        var res: [Point2D] = []
        let mask:[Bool] = polygonApproximationMask(epsilon: epsilon)
        
        for i in 0 ..< pointCount {
            if mask[i] {
                res.append(points[i])
            }
        }
        return res
    }
    
    public func calDistance(p:Int, a:Int, b: Int) -> Double {
        let P = points[p]
        let A = points[a]
        let B = points[b]
        
        
        let PA = Point2D(x: A.x - P.x, y: A.y - P.y)
        let PB = Point2D(x: B.x - P.x, y: B.y - P.y)
        
        
        let corss = abs(PA.x * PB.y - PA.y * PB.x)
        let AB = (B.x - A.x) * (B.x - A.x) + (B.y - A.y) * (B.y - A.y)
        let ab_sp = sqrt(AB)
        
        let res = corss / ab_sp
        return res
    }
    
}
