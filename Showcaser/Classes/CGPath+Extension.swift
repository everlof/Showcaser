// MIT License
//
// Copyright (c) 2018 David Everlöf
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import UIKit

// Smoothing algorithm adopted from:
// https://www.codeproject.com/Articles/31859/Draw-a-Smooth-Curve-through-a-Set-of-2D-Points-wit

extension CGPath {

    internal class func smoothBezierThrough(points: [CGPoint]) -> CGPath {
        let path = CGMutablePath()
        var firstPoints: [CGPoint] = []
        var secondPoints: [CGPoint] = []

        getControlPoints(knots: points,
                         firstControlPoints: &firstPoints,
                         secondControlPoints: &secondPoints)

        path.move(to: points.first!)
        stride(from: 0, to: points.count - 1, by: 1).forEach { i in
            let p1 = firstPoints[i]
            let p2 = secondPoints[i]
            let p3 = points[i + 1]
            path.addCurve(to: p3, control1: p1, control2: p2)
        }

        return path
    }

    private class func getControlPoints(knots: [CGPoint],
                                        firstControlPoints: inout [CGPoint],
                                        secondControlPoints: inout [CGPoint]) {
        let n = knots.count - 1

        // Calculate first Bezier control points
        // Right hand side vector
        var rhs = [CGFloat](repeating: 0, count: n)

        // Set right hand side X values
        stride(from: 1, to: n - 1, by: 1).forEach { i in
            rhs[i] = 4 * knots[i].x + 2 * knots[i + 1].x
        }

        rhs[0] = knots[0].x + 2 * knots[1].x
        rhs[n - 1] = (8 * knots[n - 1].x + knots[n].x) / 2.0

        // Get first control points X-values
        let x = getFirstControlPoints(rhs: rhs)

        // Set right hand side Y values
        stride(from: 1, to: n - 1, by: 1).forEach { i in
            rhs[i] = 4 * knots[i].y + 2 * knots[i + 1].y
        }
        rhs[0] = knots[0].y + 2 * knots[1].y
        rhs[n - 1] = (8 * knots[n - 1].y + knots[n].y) / 2.0;

        // Get first control points Y-values
        let y = getFirstControlPoints(rhs: rhs)

        // Fill output arrays.
        firstControlPoints = [CGPoint](repeating: .zero, count: n)
        secondControlPoints = [CGPoint](repeating: .zero, count: n)
        stride(from: 0, to: n, by: 1).forEach { i in
            // First control point
            firstControlPoints[i] = CGPoint(x: x[i], y: y[i])
            // Second control point
            if (i < n - 1) {
                secondControlPoints[i] =
                    CGPoint(x: 2 * knots[i + 1].x - x[i + 1],
                            y: 2 * knots[i + 1].y - y[i + 1])
            } else {
                secondControlPoints[i] =
                    CGPoint(x: (knots[n].x + x[n - 1]) / 2,
                            y: (knots[n].y + y[n - 1]) / 2)
            }
        }
    }

    private class func getFirstControlPoints(rhs: [CGFloat]) -> [CGFloat] {
        let n = rhs.count

        var x = [CGFloat](repeating: 0, count: n)
        var tmp = [CGFloat](repeating: 0, count: n)

        var b: CGFloat = 2.0
        x[0] = rhs[0] / b
        stride(from: 1, to: n, by: 1).forEach { i in
            tmp[i] = 1 / b
            b = (i < n - 1 ? 4.0 : 3.5) - tmp[i]
            x[i] = (rhs[i] - x[i - 1]) / b
        }

        stride(from: 1, to: n, by: 1).forEach { i in
            x[n - i - 1] -= tmp[n - i] * x[n - i]
        }

        return x
    }

}
