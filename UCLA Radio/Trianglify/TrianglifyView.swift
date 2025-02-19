//
//  TrianglifyView.swift
//  Trianglify
//
//  Created by Christopher Laganiere on 8/19/16.
//  Copyright © 2016 Chris Laganiere. All rights reserved.
//

import Foundation
import UIKit
import DynamicColor

open class TrianglifyView: UIView {
    
    /// public
    
    open var cellSize = CGRect(x: 50, y: 50, width: 50, height: 50) {
        didSet {
            setNeedsLayout()
        }
    }
    open var offset: Int = 25
    open var variation: CGFloat = 0.65 {
        didSet {
            // 0.0 < x < 1.0
            variation = min(1.0, max(0.0, variation))
        }
    }
    open var colors: [UIColor] = Colorbrewer.colors("GnBu") ?? [] {
        didSet {
            setNeedsLayout()
        }
    }
    open var colorScheme: String? {
        didSet {
            if let colorScheme = colorScheme,
                let newColors = Colorbrewer.colors(colorScheme) {
                colors = newColors
            }
        }
    }
    
    /// private
    
    fileprivate var shapeLayers = [CAShapeLayer]()
    fileprivate let colorResolution = 100
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        updateTrianglePoints()
    }
    
    struct Triangle {
        let color: UIColor
        let points: [CGPoint]
        init?(points: [CGPoint], parentFrame: CGRect, potentialColors: [UIColor]) {
            guard points.count == 3 else {
                return nil
            }
            
            let triangleCenterX = points.reduce(0, { sum, next in
                sum + next.x
            }) / 3.0
            
            let triangleCenterY = points.reduce(0, { sum, next in
                sum + next.y
            }) / 3.0
            
            // percent down diagonal axis (TL / BR) at which triangle's center point sits
            let triangleAxisPercent = 0.5 * (triangleCenterX / parentFrame.width) + 0.5 * (triangleCenterY / parentFrame.height)
            
            let firstColor = potentialColors[1] // potentialColors[Int(floor(CGFloat(potentialColors.count - 1) * triangleAxisPercent))]
            let secondColor = potentialColors[7] // potentialColors[Int(ceil(CGFloat(potentialColors.count - 1) * triangleAxisPercent))]
            let colorMixWeight = triangleAxisPercent // CGFloat(potentialColors.count) * triangleAxisPercent - floor(CGFloat(potentialColors.count) * triangleAxisPercent)
            
            self.color = firstColor.mixed(withColor: secondColor, weight: colorMixWeight)
            self.points = points
        }
    }
    
    fileprivate func updateTrianglePoints() {
        let numRows = Int(frame.width / cellSize.width)
        let xSpacing = frame.width / CGFloat(numRows)
        
        let numCols = Int(frame.height / cellSize.height)
        let ySpacing = frame.height / CGFloat(numCols)
        
        // recalculate triangles
        var triangles = [Triangle]()
        var pointRows = [[CGPoint]]()
        for r in 0...numRows {
            var newRow = [CGPoint]()
            for c in 0...numCols {
                
                // calculate triangle point position
                let startPoint = CGPoint(x: CGFloat(r) * xSpacing, y: CGFloat(c) * ySpacing)
                let angle = CGFloat(arc4random_uniform(UInt32(variation * 2 * CGFloat(Double.pi)))).truncatingRemainder(dividingBy: CGFloat(2 * Double.pi))
                var newPoint = CGPoint(
                    x: startPoint.x + cos(angle) * variation * CGFloat(arc4random_uniform(UInt32(offset))),
                    y: startPoint.y + sin(angle) * variation * CGFloat(arc4random_uniform(UInt32(offset))))
                
                // 'edge' cases: end points should align with edges of view
                if r == 0 || r == numRows {
                    newPoint.x = startPoint.x
                }
                if c == 0 || c == numCols {
                    newPoint.y = startPoint.y
                }
                
                // calculate triangles
                if let lastRow = pointRows.last,
                    let bottomLeftPoint = newRow.last {
                    let topLeftPoint = lastRow[newRow.count - 1]
                    let topRightPoint = lastRow[newRow.count]
                    let bottomRightPoint = newPoint
                    
                    // .50 / .50 chance of (top left + bottom right) or (top right + bottom left) triangles
                    let flipStyle = (arc4random_uniform(2) == 0)
                    
                    // calculate top triangle of rect
                    let triangle1Points = flipStyle ? [topLeftPoint, topRightPoint, bottomLeftPoint] : [topLeftPoint, topRightPoint, bottomRightPoint]
                    if let triangle1 = Triangle(points: triangle1Points, parentFrame: frame, potentialColors: colors) {
                        triangles.append(triangle1)
                    }
                    
                    // calculate bottom triangle of rect
                    let triangle2Points = flipStyle ? [topRightPoint, bottomLeftPoint, bottomRightPoint] : [topLeftPoint, bottomLeftPoint, bottomRightPoint]
                    if let triangle2 = Triangle(points: triangle2Points, parentFrame: frame, potentialColors: colors) {
                        triangles.append(triangle2)
                    }
                }
                
                newRow.append(newPoint)
            }
            pointRows.append(newRow)
        }
        
        // reset layout
        for staleShape in shapeLayers {
            staleShape.removeFromSuperlayer()
        }
        shapeLayers = []
        
        // layout triangles
        for triangle in triangles {
            let trianglePath = UIBezierPath()
            trianglePath.move(to: triangle.points[0])
            trianglePath.addLine(to: triangle.points[1])
            trianglePath.addLine(to: triangle.points[2])
            trianglePath.close()
            
            let shapeLayer = CAShapeLayer()
            shapeLayer.path = trianglePath.cgPath
            shapeLayer.fillColor = triangle.color.cgColor
            shapeLayer.lineWidth = 1.0
            shapeLayer.strokeColor = triangle.color.cgColor
            layer.addSublayer(shapeLayer)
            shapeLayers.append(shapeLayer)
        }
        
    }
    
    
}
