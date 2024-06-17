# RDP-Swift

The Swift implementation of the Ramer-Douglas-Peucker algorithm.

## Usage

```swift
let points: [Point2D] = ...

let drp = VecRDP(points: points)    // The vector implementation using vDSP. 5 times faster than IterRDP
let drp = IterRDP(points: points)   // The simple implementation. Uses half the memory compared to VecRDP.

let _: [Point2D] = drp.polygonApproximation(epsilon: 0.00001)

```

