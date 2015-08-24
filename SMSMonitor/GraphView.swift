//
//  GraphView.swift
//  Monitor
//
//  Created by zhenghuiwin on 15/2/25.
//  Copyright (c) 2015年 zhenghuiwin. All rights reserved.
//

import UIKit

class GraphView: UIView {
      
      private let heightTranslate: CGFloat = 180 - 5 + 6
      private let maxHeight: CGFloat = 180 - 5 - 5 + 6
      // Width of time label
      let widthOfTimeLabel: CGFloat = 24
      // Height of time label
      private let heightOfTimeLabel: CGFloat = 10
      // Clearance of time label
      private var _clearance: CGFloat = 10
      
      let barWidth: CGFloat = 10
      
      private var _timeLabelArray = [ UILabel ]()
      private var _barRect = [ CGRect ]()
      private var _hourlyAmount = [ CGFloat ]()
      private var _hourlyData = [ CGFloat ]()
      private var _scaleOfCurve: CGFloat = 1
      
      private var _didSelectBarClosure: ( ( hourlyData: CGFloat, hourlyAmount: CGFloat ) -> () )?
      
      
      var minWidth: CGFloat {
            get {
                  return  806//widthOfTimeLabel * 24 + _clearance * 23
            }
      }
      
      class var height: CGFloat {
            get {
                  return 210
            }
      }
      
//      var _startColor: UIColor = UIColor(red: 250.0 / 255.0, green: 233.0 / 255.0, blue: 222.0 / 255.0, alpha: 1.0 )
//      var _endColor:   UIColor = UIColor(red: 252.0 / 255.0, green: 79 / 255.0, blue: 8 / 255.0, alpha: 1.0 )
      
      
      override init( frame: CGRect ) {
            super.init( frame: frame )
            self.backgroundColor = UIColor.clearColor()
            self.setup()
      }
      
      required init( coder aDecoder: NSCoder ) {
            super.init( coder: aDecoder )
            self.backgroundColor = UIColor.clearColor()
            self.setup()
      }
      
      private func setup() {
            for i in 0..<12 {
                  _barRect.append( CGRect(x: 0, y: 0, width: barWidth, height: 0 ) )
            }
      }
      
//      override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
//            var allTouches = touches.
//            if allTouches.count > 0 {
//                  var touch = allTouches[ 0 ] as UITouch
//                  var point: CGPoint =  touch.locationInView( self )
//                  point.y = heightTranslate - point.y
//                  for var i = 0; i < _barRect.count; i++ {
//                        if CGRectContainsPoint( _barRect[ i ], point ) {
//                              println("index of rect is \(i)")
//                              var hourlyData = _hourlyData[ i ]
//                              var hourlyAmount = _hourlyAmount[ i ]
//                              println("hourlyData=\(hourlyData)     hourlyAmount=\(hourlyAmount)")
//                              if let closure = _didSelectBarClosure {
//                                    closure( hourlyData: hourlyData, hourlyAmount: hourlyAmount )
//                              }
//                        }
//                  }
//                  
//            }
//      }
      
      
      override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
            if touches.first != nil {
                  var touch = touches.first as! UITouch
                  var p: CGPoint = touch.locationInView( self )
                  p.y = heightTranslate - p.y
                  for var i = 0; i < _barRect.count; i++ {
                        if CGRectContainsPoint( _barRect[ i ], p ) {
                              var hourlyData = _hourlyData[ i ]
                              var hourlyAmount = _hourlyAmount[ i ]
                              if let closure = _didSelectBarClosure {
                                    closure( hourlyData: hourlyData, hourlyAmount: hourlyAmount )
                              }
                        }
                  }
            }

            
      }
      
      
//      override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
//            
//
//      }
      
      func setSelectBarClosure( closure: ( hourlyData: CGFloat, hourlyAmount: CGFloat ) -> () ) {
            _didSelectBarClosure = closure
      }
      
      func resize() {
            if let pView = self.superview {
                  var newWidth: CGFloat = 0;
                  if pView.bounds.width > self.minWidth {
                        newWidth =  pView.bounds.width
                  } else {
                        newWidth = minWidth
                  }
                  
                  // Resize the width of GraphView with it's superview's width
                  self.frame = CGRect(origin: self.frame.origin, size: CGSize(width: newWidth, height: self.bounds.height ) )
                  // Recalculate the value of clearance with new width of GraphView
                  _clearance = calculateClearance( widthOfSuperView: newWidth )
            }
      }
      
      func arrangeTimeLable() {
            if _timeLabelArray.count == 0 {
                  // No existing timeLabel,so create them
                  initTimeLabel()
            }
            
            for var i = 0; i < _timeLabelArray.count; i++ {
                  var newOrigin = newOriginOfTimeLabel( indexOfTimeLabel: i )
                  var size = CGSize( width: widthOfTimeLabel, height: heightOfTimeLabel )
                  
                  var tmLabel = _timeLabelArray[ i ]
                  tmLabel.frame = CGRect( origin: newOrigin, size: size )
                  
                  if tmLabel.superview == nil {
                        self.addSubview( tmLabel )
                  }
            }
      }
      
      func setStatisticalData( statsData sData: [CGFloat] ) {
            _hourlyData = sData
            var max = maxElement( sData )
            var scale: CGFloat = maxHeight / max
            
            var index = 0
            for ; index < sData.count && index < 24; index++ {
                  if index == 0 || index == 12 {
                        _hourlyAmount.append( sData[ index ] )
                  } else {
                        _hourlyAmount.append( sData[ index ] + _hourlyAmount[ index - 1 ] )
                  }
                  
                  
                  var barHeight = sData[ index ] * scale
                  var barViewX = barViewXAt( indexOfBarView: index )
                  var rect = CGRect( x: barViewX, y: 0, width: barWidth, height: barHeight )
                  if index < _barRect.count {
                        _barRect[ index ] = rect
                  } else {
                        _barRect.append( rect )
                  }
            }
            
            // Clear the height of barView which dose not have correspondent value from sData
            for ; index < _barRect.count; index++ {
                  var rect = _barRect[ index ]
                  _barRect[ index ] = CGRect( origin: rect.origin, size: CGSize(width: rect.width, height: 0 ) )
            }
            
            _scaleOfCurve = maxHeight / maxElement( _hourlyAmount )
            self.setNeedsDisplay()
      }

      
      func calculateContentSize() {
            if let pview = self.superview as? UIScrollView {
                  var width = max( pview.bounds.width, self.bounds.width )
                  pview.contentSize = CGSize( width: width, height: GraphView.height )
            }
      }
      
      private func initTimeLabel() {
            var amOrPm = "AM"
            var time = 0;
            
            for i in 0...23 {
                  var tmLabel = UILabel()
                  if i == 12 {
                        amOrPm = "PM"
                        tmLabel.backgroundColor = UIColor.redColor()
                        tmLabel.textColor = UIColor.whiteColor()
                        tmLabel.font = UIFont( name: "Helvetica Bold", size: 9)
                  } else {
                        tmLabel.backgroundColor = UIColor.whiteColor()
                        tmLabel.textColor = UIColor.blackColor()
                  }
                  
                  tmLabel.textAlignment = .Center
                  tmLabel.font = UIFont( name: "Helvetica Neue", size: 9)
            
                  time = i
                  
                  if i > 12 {
                        time = i - 12
                  }
                  tmLabel.text = "\(time)\(amOrPm)"
                  _timeLabelArray.append( tmLabel )
            }
      }
      
      
      private func calculateClearance( widthOfSuperView w: CGFloat ) -> CGFloat {
            return ( w - 24 * widthOfTimeLabel ) / 23
      }
      
      private func barViewXAt( indexOfBarView index: Int ) -> CGFloat {
            var halfBarWidth: CGFloat = barWidth / 2
            var clearanceOfBar = widthOfTimeLabel - barWidth + _clearance
            var barViewStartX: CGFloat = widthOfTimeLabel / 2 - halfBarWidth
            
            return barViewStartX + ( barWidth + clearanceOfBar ) * CGFloat(index)
      }
      
      private func newOriginOfTimeLabel( indexOfTimeLabel index: Int ) -> CGPoint {
            var timeLabelY: CGFloat = self.bounds.height - 19
            var timeLabelX: CGFloat = ( widthOfTimeLabel + _clearance ) * CGFloat(index)
            
            return CGPoint( x: timeLabelX, y: timeLabelY )
      }
      
      
      private func curvePointOfHourlyAmount( indexOfHourlyAmount index: Int ) -> CGPoint? {
            
            if index >= 0 && index < _hourlyAmount.count {
                  var y: CGFloat = _hourlyAmount[ index ] * _scaleOfCurve
                  
                  var startX: CGFloat = widthOfTimeLabel / 2
                  var x: CGFloat = startX + ( widthOfTimeLabel + _clearance ) * CGFloat(index)
                  
                  return CGPoint( x: x, y: y )
            }
            
            return nil
      }
      
      private func drawCurvePoint( curvePoint: CGPoint ) {
            var point = curvePoint
            point.x -= 5.0 / 2
            point.y -= 5.0 / 2
            let circle = UIBezierPath( rect:
                  CGRect(origin: point,
                        size: CGSize(width: 5.0, height: 5.0)))
            UIColor.redColor().setFill()
            circle.fill()
      }
      
      
      // Only override drawRect: if you perform custom drawing.
      // An empty implementation adversely affects performance during animation.
      override func drawRect( rect: CGRect ) {
            super.drawRect( rect )
        // Drawing code
            let cnt = UIGraphicsGetCurrentContext()
            CGContextSaveGState( cnt )
            
            
            // Drawing curve of hourly amount
            CGContextTranslateCTM( cnt, 0, heightTranslate )
            CGContextScaleCTM( cnt, 1, -1 )
            
            let path = UIBezierPath()
            let clipPath = UIBezierPath()
            
            UIColor.redColor().setStroke()
            path.lineWidth = 3
            for index in 0..<_hourlyAmount.count {
                  if let curvePoint: CGPoint = curvePointOfHourlyAmount( indexOfHourlyAmount: index ) {
                       
                        
                        if index == 0 {
                              path.moveToPoint( curvePoint )
                              drawCurvePoint( curvePoint )

                              clipPath.moveToPoint( curvePoint )
                        } else if index < 12 {
                              path.addLineToPoint( curvePoint )
                              drawCurvePoint( curvePoint )
                              
                              clipPath.addLineToPoint( curvePoint )
                              
                              if index == 11 {
                                    // 11 AM, it's a border point, the statistics of morning end with it
                                    var p = curvePoint
                                    p.y = 0
                                    clipPath.addLineToPoint( p )
                              }

                        }
                        
                        if index == 12 {
                              path.moveToPoint( curvePoint )
                              drawCurvePoint( curvePoint )
                              
                              var p = curvePoint
                              p.y = 0
                              clipPath.addLineToPoint( p )
                              clipPath.addLineToPoint( curvePoint )
                        }
                        
                        if index > 12 {
                              path.addLineToPoint( curvePoint )
                              drawCurvePoint( curvePoint )
                              
                              clipPath.addLineToPoint( curvePoint )
                              if index == _hourlyAmount.count - 1 {
                                    var p = curvePoint
                                    p.y = 0
                                    clipPath.addLineToPoint( p )
                                    if let afternoonFirstPoint = curvePointOfHourlyAmount(indexOfHourlyAmount: 0 ) {
                                          p.x = afternoonFirstPoint.x
                                          clipPath.addLineToPoint( p )
                                          clipPath.closePath()
                                    }
                              }
                        }
                  }
            }
            
            
            
            CGContextSaveGState( cnt )
            // Gradation drawing below the curve of hourly amount
            clipPath.addClip()
            var  endColor:   UIColor = UIColor(red: 106.0 / 255.0, green: 161.0 / 255.0, blue: 253.0 / 255.0, alpha: 1.0 )
            var  startColor: UIColor = UIColor(red: 5.0 / 255.0, green: 42 / 255.0, blue: 133 / 255.0, alpha: 1.0 )
            
            let colors = [ startColor.CGColor, endColor.CGColor ]
            let colorSpaces = CGColorSpaceCreateDeviceRGB()
            let colorLocations: [ CGFloat ] = [ 0.0, 1.0 ]
            
            let gradient = CGGradientCreateWithColors( colorSpaces, colors, colorLocations )
            
            var startPoint = CGPoint.zeroPoint
            var endPoint = CGPoint( x: 0, y: maxHeight )
            
            CGContextDrawLinearGradient( cnt, gradient, startPoint, endPoint, 0 )
            
            CGContextRestoreGState( cnt )

            path.stroke()
            
            
            // Drawing bar graph for hourly data
            for index in 0..<_barRect.count {
                  var newX: CGFloat = barViewXAt( indexOfBarView: index )
                  var rect = _barRect[ index ]
                  var newRect = CGRect( origin: CGPoint( x: newX, y: 0 ), size: rect.size )
                  let barPath = UIBezierPath( rect: newRect )
                  
                  UIColor.whiteColor().setFill()
                  barPath.fill()
                  
                  _barRect[ index ] = newRect
            }
            
            
            CGContextRestoreGState( cnt )
 
      }
      
      
      private func forTest() {
            let path = UIBezierPath( rect: CGRect(x: 5, y: 5, width: 50, height: 50 ) )
            UIColor.yellowColor().setFill()
            path.fill()
            
            let path1 = UIBezierPath( rect: CGRect( x: self.bounds.width - 55, y: 5, width: 50, height: 50 ) )
            path1.fill()

      }
      
      
      
      
      
      


}
