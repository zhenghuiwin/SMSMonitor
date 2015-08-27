//
//  GraphLayerView.swift
//  SMSMonitor
//
//  Created by zhenghuiwin on 15/4/28.
//  Copyright (c) 2015年 zhenghuiwin. All rights reserved.
//

import UIKit

class GraphLayerView: UIView {
      
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
      private var _barSharpeLayers = [ CAShapeLayer ]()
      private var _hourlyAmount = [ CGFloat ]()
      private var _hourlyData = [ CGFloat ]()
      private var _scaleOfCurve: CGFloat = 1
      
      
      private var _curveLineLayer = CAShapeLayer()
      private var _gradLayer = CAGradientLayer()
      private var _maskLayer = CAShapeLayer()
      private var _circleLayer = CAShapeLayer()
      private var _firstDisplayCurveLine = true
      private var _barAnimation = CABasicAnimation( keyPath: "strokeEnd" )
      private var _lineAnimation = CABasicAnimation( keyPath: "strokeEnd" )
      var maskAnimation = CABasicAnimation( keyPath: "fillColor" )
      var gradAnimation = CABasicAnimation( keyPath: "endPoint" )
      
      private var _lastTouchedBarLayer: CAShapeLayer?
      private let _touchedGrayColor = UIColor( red: 218/255, green: 218/255, blue: 218/255, alpha: 1 )

      private var _didSelectBarClosure: ( ( hourlyData: CGFloat, hourlyAmount: CGFloat ) -> () )?
      
      
      private var _count: Int = 0
      
      
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
      
      // MARK: -override methods
      override init( frame: CGRect ) {
            super.init( frame: frame )
            self.backgroundColor = UIColor.clearColor()
            setup()
      }
      
      required init( coder aDecoder: NSCoder ) {
            super.init( coder: aDecoder )
            self.backgroundColor = UIColor.clearColor()
            setup()
      }
      
      
      override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
            if touches.first != nil {
                  var touch = touches.first as! UITouch
                  var p: CGPoint = touch.locationInView( self )
                  p.y = heightTranslate - p.y
                  for var i = 0; i < _barRect.count; i++ {
                        
                        var bRect = biggerRect( i )
                        
                        if CGRectContainsPoint( bRect, p ) {
                              
                              if i < _barSharpeLayers.count {
                                    var layer = _barSharpeLayers[ i ]
                                    layer.strokeColor = _touchedGrayColor.CGColor
                                    if let lastTouchedLayer = _lastTouchedBarLayer {
                                          lastTouchedLayer.strokeColor = UIColor.whiteColor().CGColor
                                    }
                                    _lastTouchedBarLayer = layer
                              }
                              
                              var hourlyData = _hourlyData[ i ]
                              var hourlyAmount = _hourlyAmount[ i ]
                              if let closure = _didSelectBarClosure {
                                    closure( hourlyData: hourlyData, hourlyAmount: hourlyAmount )
                              }
                        }
                  }
            }
            
            
      }
      
      
      override func animationDidStop(anim: CAAnimation!, finished flag: Bool) {
            if flag {
                  
                  _circleLayer.hidden = false
                  _gradLayer.hidden = false
                  
                  maskAnimation.fromValue = UIColor.clearColor().CGColor
                  maskAnimation.toValue = UIColor.blackColor().CGColor
                  maskAnimation.duration = 0.6
                  
                  maskAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut) // animation curve is Ease Out
                  maskAnimation.fillMode = kCAFillModeBoth // keep to value after finishing
                  maskAnimation.removedOnCompletion = false // don't remove after finishing
                  _maskLayer.addAnimation( maskAnimation, forKey: maskAnimation.keyPath )
                  
                  
                  
                  gradAnimation.fromValue = NSValue( CGPoint: CGPoint(x: 0, y: 0) )
                  gradAnimation.toValue = NSValue( CGPoint: CGPoint(x: 0, y: 1) )
                  gradAnimation.duration = 0.6
                  
                  gradAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut) // animation curve is Ease Out
                  gradAnimation.fillMode = kCAFillModeBoth // keep to value after finishing
                  gradAnimation.removedOnCompletion = false // don't remove after finishing
                  _gradLayer.addAnimation( maskAnimation, forKey: maskAnimation.keyPath )
            }
            
      }
      
      // MARK: - public methods
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
                  // Calculate the new x value of bars
                  for i in 0..<_barRect.count {
                        var rect = _barRect[ i ]
                        var newPoint = CGPoint( x: barViewXAt( indexOfBarView: i ), y: rect.origin.y )
                        var newRect = CGRect( origin: newPoint, size: rect.size )
                        _barRect[ i ] = newRect
                  }
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
      
      // Very import public method,it likes a main method
      func setStatisticalData( statsData sData: [CGFloat] ) {
            _hourlyData = sData
            
            var max = maxElement( sData )
            var scale: CGFloat = maxHeight / max
            
            let count = min( sData.count, 24 )
            println( "min of count:\(count)" )
            
            // Clear the hourlyAmount
            _hourlyAmount = [ CGFloat ]( count: count, repeatedValue: 0 )
            
            var index = 0
            for ; index < count; ++index {
                  
                  if index == 0 || index == 12 {
                        _hourlyAmount[ index ] = sData[ index ]
                  } else {
                        _hourlyAmount[ index ] =  sData[ index ] + _hourlyAmount[ index - 1 ]
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
//            self.setNeedsDisplay()
            self.displayGraph()
            
      }
      
      
      func calculateContentSize() {
            if let pview = self.superview as? UIScrollView {
                  var width = max( pview.bounds.width, self.bounds.width )
                  pview.contentSize = CGSize( width: width, height: GraphView.height )
            }
      }
      
      func displayGraph() {
            let scaleTransform = CATransform3DMakeScale( 1, -1, 1 )
            let translateTransform = CATransform3DMakeTranslation( 0, heightTranslate, 0 )
            let newTransform = CATransform3DConcat( scaleTransform, translateTransform )
            
            displayBarGraph( newTransform )
            displayLineGraph( newTransform )
            
            startBarAnimation()
            startLineAnimation()
      }

      
      // MARK: - private methods
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
      
      private func setup() {
            setupCurveLineLayer()
            setupGradiLayer()
            setupMaskLayer()
            setupCircleLayer()
            
            setupBarAnimation()
            setupLineAnimation()
      }
      
      private func setupCurveLineLayer() {
            _curveLineLayer.fillColor = nil //UIColor.clearColor().CGColor
            _curveLineLayer.strokeColor = UIColor.redColor().CGColor
            _curveLineLayer.lineWidth = 1
            _curveLineLayer.position = CGPoint(x: 0, y: 0)
      }
      
      private func setupGradiLayer() {
            
            var startColor:   UIColor = UIColor(red: 106.0 / 255.0, green: 161.0 / 255.0, blue: 253.0 / 255.0, alpha: 1.0 )
            var endColor: UIColor = UIColor(red: 5.0 / 255.0, green: 42 / 255.0, blue: 133 / 255.0, alpha: 1.0 )
            _gradLayer.colors = [ startColor.CGColor, endColor.CGColor ]
            
            var startPoint = CGPoint( x:0, y: 0 )
            var endPoint = CGPoint( x: 0, y: 1.0 )
            _gradLayer.startPoint = startPoint
            _gradLayer.endPoint = endPoint
            
            _gradLayer.hidden = true

      }
      
      private func setupMaskLayer() {
            _maskLayer.fillColor = UIColor.blackColor().CGColor
      }
      
      private func setupCircleLayer() {
            _circleLayer.strokeColor = UIColor.redColor().CGColor
            _circleLayer.fillColor = UIColor.redColor().CGColor
            _circleLayer.lineWidth = 1
            _circleLayer.hidden = true
      }
      
      private func setupBarAnimation() {
            _barAnimation.duration = 0.6
            _barAnimation.fromValue = 0.0
            _barAnimation.toValue = 1.0
            _barAnimation.delegate = self
      }
      
      private func setupLineAnimation() {
            _lineAnimation.duration = 0.8
            _lineAnimation.fromValue = 0.0
            _lineAnimation.toValue = 1.0
//            _lineAnimation.delegate = self
      }
      
      
      private func startBarAnimation() {
            for barLayer in _barSharpeLayers {
                  barLayer.addAnimation( _barAnimation, forKey: _barAnimation.keyPath )
            }
      }
      
      private func startLineAnimation() {
            _curveLineLayer.addAnimation( _lineAnimation, forKey: _lineAnimation.keyPath )
      }
      
      private func setZeroValueToAllElements( inout array: Array<CGFloat> ) {

            for var index = 0; index < array.count; ++index {
                  array[index] = 0
            }

      }
      
      private func biggerRect( index: Int ) -> CGRect {
            
            if index < _timeLabelArray.count {
                  let timeLabel = _timeLabelArray[index]
                  let rect = timeLabel.frame
                  return CGRect( x: rect.origin.x,
                                 y: _barRect[index].origin.y,
                                 width: rect.size.width,
                                 height: _barRect[index].size.height * ( 1 + 0.3) )
            }
            
            return _barRect[index]
            
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
      
      private func drawCurvePoint( curvePoint: CGPoint, thePath path: UIBezierPath ) {
//            var point = curvePoint
//            point.x -= 5.0 / 2
//            point.y -= 5.0 / 2
            
            path.moveToPoint( curvePoint )
            
            path.addArcWithCenter( curvePoint, radius: 2.2, startAngle: 0, endAngle: CGFloat( 2 * M_PI ) , clockwise: true )
//            let circle = UIBezierPath( rect:
//                  CGRect(origin: point,
//                        size: CGSize(width: 5.0, height: 5.0)))
//            UIColor.redColor().setFill()
//            circle.fill()
      }
      
      
      private func displayBarGraph( transform: CATransform3D ) {
            // Drawing bar graph for hourly data
            for index in 0..<_barRect.count {
                  
                  var rect = _barRect[ index ]
                  // let barPath = UIBezierPath( rect: rect )
                  
                  let barPath = UIBezierPath()
                  
                  var startPoint = CGPoint( x: CGRectGetMidX( rect ), y: 0 )
                  barPath.moveToPoint( startPoint )
                  barPath.addLineToPoint( CGPoint( x: startPoint.x, y: startPoint.y + rect.size.height ) )
                  
                  if index >= _barSharpeLayers.count {
                        // The shapeLayer has not exited,so create it with the CGPath
                        
                        var sharpeLayer = CAShapeLayer()
                        
                        sharpeLayer.transform = transform
                        sharpeLayer.path = barPath.CGPath
                        sharpeLayer.strokeColor = UIColor.whiteColor().CGColor
                        sharpeLayer.lineWidth = rect.width
                        sharpeLayer.position = CGPoint(x: 0, y: 0)
                        
                        _barSharpeLayers.append( sharpeLayer )
                        self.layer.addSublayer( sharpeLayer )
                  } else {
                        // Update the CGPath of the exited sharpeLayer
                        var sharpeLayer = _barSharpeLayers[ index ]
                        sharpeLayer.path = barPath.CGPath
                  }
            }
      }
      
      private func displayLineGraph( transform: CATransform3D ) {
            var linePath  = UIBezierPath()
            var circlePath = UIBezierPath()
            var maskPath = UIBezierPath()
            
            for index in 0..<_hourlyAmount.count {
                  
                  if let curvePoint: CGPoint = curvePointOfHourlyAmount( indexOfHourlyAmount: index ) {
                        
                        if index == 0 {
                              // 0 AM
                              linePath.moveToPoint( curvePoint )
                              drawCurvePoint( curvePoint, thePath: circlePath )
                              maskPath.moveToPoint( curvePoint )
                              
                        } else if index < 12 {
                              // 1 AM ~ 11 AM
                              linePath.addLineToPoint( curvePoint )
                              drawCurvePoint( curvePoint, thePath: circlePath )
                              maskPath.addLineToPoint( curvePoint )
                              
                              if index == 11 {
                                    // 11 AM, it's a border point, the statistics of morning end with it
                                    var p = curvePoint
                                    p.y = 0
                                    maskPath.addLineToPoint( p )
                              }
                              
                        }
                        
                        if index == 12 {
                              // 12 PM, a new phase
                              linePath.moveToPoint( curvePoint )
                              drawCurvePoint( curvePoint, thePath: circlePath )
                              
                              var p = curvePoint
                              p.y = 0
                              maskPath.addLineToPoint( p )
                              maskPath.addLineToPoint( curvePoint )
                        }
                        
                        if index > 12 {
                              // 1 PM ~ 24 PM
                              linePath.addLineToPoint( curvePoint )
                              drawCurvePoint( curvePoint, thePath: circlePath )
                              maskPath.addLineToPoint( curvePoint )
                              
                              if index == _hourlyAmount.count - 1 {
                                    // 24 PM
                                    var p = curvePoint
                                    p.y = 0
                                    
                                    maskPath.addLineToPoint( p )
                                    if let afternoonFirstPoint = curvePointOfHourlyAmount(indexOfHourlyAmount: 0 ) {
                                          p.x = afternoonFirstPoint.x
                                          maskPath.addLineToPoint( p )
                                          maskPath.closePath()
                                    }
                              }
                        }
                  }
            }
            
            
            _circleLayer.transform = transform
            _circleLayer.path = circlePath.CGPath
            _circleLayer.position = _curveLineLayer.position
            _circleLayer.hidden = true
            
            _curveLineLayer.transform = transform
            _curveLineLayer.path = linePath.CGPath
            
            _maskLayer.position = _curveLineLayer.position
            _maskLayer.transform = transform
            _maskLayer.path = maskPath.CGPath
            
            _gradLayer.hidden = true
            _gradLayer.frame = self.bounds //CGRect( origin: self.bounds.origin, size: CGSize(width: 0, height: self.bounds.height ) )
            _gradLayer.mask = _maskLayer
            
            if _firstDisplayCurveLine {
                  _firstDisplayCurveLine = false
                  self.layer.insertSublayer( _gradLayer, below: _barSharpeLayers.first ) //addSublayer( _gradLayer )
                  self.layer.addSublayer( _curveLineLayer )
                  self.layer.addSublayer( _circleLayer )
            }
      }
      
      

      
      
      // Only override drawRect: if you perform custom drawing.
      // An empty implementation adversely affects performance during animation.
//      override func drawRect( rect: CGRect ) {
//            super.drawRect( rect )
//            // Drawing code
//            let cnt = UIGraphicsGetCurrentContext()
//            CGContextSaveGState( cnt )
//            
//            
//            // Drawing curve of hourly amount
//            CGContextTranslateCTM( cnt, 0, heightTranslate )
//            CGContextScaleCTM( cnt, 1, -1 )
//            
//            let path = UIBezierPath()
//            let clipPath = UIBezierPath()
//            
//            UIColor.redColor().setStroke()
//            path.lineWidth = 3
//            for index in 0..<_hourlyAmount.count {
//                  if let curvePoint: CGPoint = curvePointOfHourlyAmount( indexOfHourlyAmount: index ) {
//                        
//                        
//                        if index == 0 {
//                              path.moveToPoint( curvePoint )
//                              drawCurvePoint( curvePoint )
//                              
//                              clipPath.moveToPoint( curvePoint )
//                        } else if index < 12 {
//                              path.addLineToPoint( curvePoint )
//                              drawCurvePoint( curvePoint )
//                              
//                              clipPath.addLineToPoint( curvePoint )
//                              
//                              if index == 11 {
//                                    // 11 AM, it's a border point, the statistics of morning end with it
//                                    var p = curvePoint
//                                    p.y = 0
//                                    clipPath.addLineToPoint( p )
//                              }
//                              
//                        }
//                        
//                        if index == 12 {
//                              path.moveToPoint( curvePoint )
//                              drawCurvePoint( curvePoint )
//                              
//                              var p = curvePoint
//                              p.y = 0
//                              clipPath.addLineToPoint( p )
//                              clipPath.addLineToPoint( curvePoint )
//                        }
//                        
//                        if index > 12 {
//                              path.addLineToPoint( curvePoint )
//                              drawCurvePoint( curvePoint )
//                              
//                              clipPath.addLineToPoint( curvePoint )
//                              if index == _hourlyAmount.count - 1 {
//                                    var p = curvePoint
//                                    p.y = 0
//                                    clipPath.addLineToPoint( p )
//                                    if let afternoonFirstPoint = curvePointOfHourlyAmount(indexOfHourlyAmount: 0 ) {
//                                          p.x = afternoonFirstPoint.x
//                                          clipPath.addLineToPoint( p )
//                                          clipPath.closePath()
//                                    }
//                              }
//                        }
//                  }
//            }
//            
//            
//            
//            CGContextSaveGState( cnt )
//            // Gradation drawing below the curve of hourly amount
//            clipPath.addClip()
//            var  endColor:   UIColor = UIColor(red: 106.0 / 255.0, green: 161.0 / 255.0, blue: 253.0 / 255.0, alpha: 1.0 )
//            var  startColor: UIColor = UIColor(red: 5.0 / 255.0, green: 42 / 255.0, blue: 133 / 255.0, alpha: 1.0 )
//            
//            let colors = [ startColor.CGColor, endColor.CGColor ]
//            let colorSpaces = CGColorSpaceCreateDeviceRGB()
//            let colorLocations: [ CGFloat ] = [ 0.0, 1.0 ]
//            
//            let gradient = CGGradientCreateWithColors( colorSpaces, colors, colorLocations )
//            
//            var startPoint = CGPoint.zeroPoint
//            var endPoint = CGPoint( x: 0, y: maxHeight )
//            
//            CGContextDrawLinearGradient( cnt, gradient, startPoint, endPoint, 0 )
//            
//            CGContextRestoreGState( cnt )
//            
//            path.stroke()
//            
//            
//            // Drawing bar graph for hourly data
//            for index in 0..<_barRect.count {
//                  var newX: CGFloat = barViewXAt( indexOfBarView: index )
//                  var rect = _barRect[ index ]
//                  var newRect = CGRect( origin: CGPoint( x: newX, y: 0 ), size: rect.size )
//                  let barPath = UIBezierPath( rect: newRect )
//                  
//                  UIColor.whiteColor().setFill()
//                  barPath.fill()
//                  
//                  _barRect[ index ] = newRect
//            }
//            
//            
//            CGContextRestoreGState( cnt )
            
//      }
      
      
      private func forTest() {
            let path = UIBezierPath( rect: CGRect(x: 5, y: 5, width: 50, height: 50 ) )
            UIColor.yellowColor().setFill()
            path.fill()
            
            let path1 = UIBezierPath( rect: CGRect( x: self.bounds.width - 55, y: 5, width: 50, height: 50 ) )
            path1.fill()
            
      }
}
