//
//  RDP.swift
//  
//
//  Created by AFuture on 2024/4/21.
//

import Foundation

public struct Point2D {
    public var x: Double
    public var y: Double
    
    public init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }
}

public protocol RDP {
    
    func polygonApproximation(epsilon: Double) -> [Point2D];
}
