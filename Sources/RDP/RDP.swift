//
//  RDP.swift
//  
//
//  Created by AFuture on 2024/4/21.
//

import Foundation

public struct Point {
    var x: Double
    var y: Double
    
    public init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }
}

public protocol RDP {
    
    func polygonApproximation(epsilon: Double) -> [Point];
}
