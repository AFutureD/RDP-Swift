//
//  VecRDP.swift
//
//
//  Created by AFuture on 2024/4/20.
//

import Foundation
import Accelerate

// Swift implementation of the Ramer-Douglas-Peucker algorithm.
public struct VecRDP: RDP {
    
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
    
    public func polygonApproximationMask(epsilon: Double = 0.0) -> [Double] {
        let start_idx = 0
        let end_idx = pointCount - 1
        var mask = [Double](repeating: 1.0, count: pointCount)
        
        var stack: [(start:Int, end:Int)] = []
        stack.append((start:start_idx, end:end_idx))
        
        var ax  = [Double](repeating: 0, count: end_idx - start_idx + 1)
        var ay  = [Double](repeating: 0, count: end_idx - start_idx + 1)
        var bx  = [Double](repeating: 0, count: end_idx - start_idx + 1)
        var by  = [Double](repeating: 0, count: end_idx - start_idx + 1)
        let px  = pointArrayX[start_idx...end_idx]
        let py  = pointArrayY[start_idx...end_idx]
        
        var PAx = [Double](repeating: 0, count: end_idx - start_idx + 1)
        var PAy = [Double](repeating: 0, count: end_idx - start_idx + 1)
        var PBx = [Double](repeating: 0, count: end_idx - start_idx + 1)
        var PBy = [Double](repeating: 0, count: end_idx - start_idx + 1)
        var ABx = [Double](repeating: 0, count: end_idx - start_idx + 1)
        var ABy = [Double](repeating: 0, count: end_idx - start_idx + 1)
        
        var PAB = [Double](repeating: 0, count: end_idx - start_idx + 1)
        var AB  = [Double](repeating: 0, count: end_idx - start_idx + 1)
        
        var PAB_abs  = [Double](repeating: 0, count: end_idx - start_idx + 1)
        var AB_square = [Double](repeating: 0, count: end_idx - start_idx + 1)
        
        var distance = [Double](repeating: 0, count: end_idx - start_idx + 1)
        
        
        while !stack.isEmpty {
            
//            print("[A] stack \(stack)")
            for range in stack {
                let (start, end) = range
                var A = points[start]
                var B = points[end]
                
                ax.withUnsafeMutableBufferPointer { ref in
                    vDSP_vfillD(&A.x, ref.baseAddress! + start, 1, vDSP_Length(end - start + 1))
                }
                
                ay.withUnsafeMutableBufferPointer { ref in
                    vDSP_vfillD(&A.y, ref.baseAddress! + start, 1, vDSP_Length(end - start + 1))
                }
                
                bx.withUnsafeMutableBufferPointer { ref in
                    vDSP_vfillD(&B.x, ref.baseAddress! + start, 1, vDSP_Length(end - start + 1))
                }
                
                by.withUnsafeMutableBufferPointer { ref in
                    vDSP_vfillD(&B.y, ref.baseAddress! + start, 1, vDSP_Length(end - start + 1))
                }
            }
            
            vDSP.subtract(ax, px, result: &PAx)
            vDSP.subtract(ay, py, result: &PAy)
            vDSP.subtract(bx, px, result: &PBx)
            vDSP.subtract(by, py, result: &PBy)
            vDSP.subtract(bx, ax, result: &ABx)
            vDSP.subtract(by, ay, result: &ABy)
            
            vDSP.subtract(multiplication: (a:PAx, b:PBy), multiplication: (c: PAy, d:PBx), result: &PAB)
            vDSP.add(multiplication: (a:ABx, b:ABx), multiplication: (c:ABy, d:ABy), result: &AB)
            
            vDSP.absolute(PAB, result: &PAB_abs)
            vForce.sqrt(AB, result: &AB_square)
            
            vDSP.divide(PAB_abs, AB_square, result: &distance)
            
            var current_stack = stack
            stack = []
            
            while !current_stack.isEmpty {
                let (start, end) = current_stack.popLast()!
                if (end - start <= 1) {continue}
                
                var partial_idx = -1;
                var partial_dis = 0.0;
                
                distance.withUnsafeMutableBufferPointer { ref in
                    vDSP_maxviD(ref.baseAddress! + start, 1, &partial_dis, &partial_idx, vDSP_Length(end - start))
                }
                let middle = start + partial_idx
//                print("[B] middle \(middle) partial_dis \(partial_dis)")
                
                if partial_dis > epsilon {
                    stack.append((start, middle))
                    stack.append((middle, end))
                } else {
                    mask.withUnsafeMutableBufferPointer { ref in
                        var tmp = 0.0
                        vDSP_vfillD(&tmp, ref.baseAddress! + start + 1, 1, vDSP_Length(end - start - 1))
                    }
                }
            }
//            print(arrayDescription(arr: mask))
//            print()
        }
        
        return mask
    }
    
    public func polygonApproximation(epsilon: Double = 0.0) -> [Point2D] {
        var res: [Point2D] = []
        let mask:[Double] = polygonApproximationMask(epsilon: epsilon)
        
        for i in 0 ..< pointCount {
            if mask[i] > 0.5 {
                res.append(points[i])
            }
        }
        
        return res
    }
    
}
