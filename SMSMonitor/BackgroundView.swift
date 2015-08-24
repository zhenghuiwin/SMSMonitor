//
//  BackgroundView.swift
//  SMSMonitor
//
//  Created by zhenghuiwin on 15/3/14.
//  Copyright (c) 2015年 zhenghuiwin. All rights reserved.
//

import UIKit

class BackgroundView: UIView {
      
      let heightOfBottomLine: CGFloat = 34.0
      let distanceToLeft: CGFloat = 20.0
      let distanceToRight: CGFloat = 20.0
      let distanceToTop: CGFloat = 38.0
      
      var _startColor: UIColor = UIColor(red: 250.0 / 255.0, green: 233.0 / 255.0, blue: 222.0 / 255.0, alpha: 1.0 )
      var _endColor:   UIColor = UIColor(red: 252.0 / 255.0, green: 79 / 255.0, blue: 8 / 255.0, alpha: 1.0 )
      
      @IBInspectable var startColor: UIColor {
            get {
                  return  _startColor
            }
            
            set {
                  _startColor = newValue
            }
      }
      
      @IBInspectable var endColor: UIColor {
            get {
                  return _endColor
            }
            
            set {
                  _endColor = newValue
            }
      }

      override init( frame: CGRect ) {
            super.init( frame: frame )
      }

      required init( coder aDecoder: NSCoder ) {
            super.init( coder: aDecoder )
      }
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
      override func drawRect(rect: CGRect) {
            // Drawing code
            setUpBackgroundClipArea()
            drawBackgroundGradient()
            
            
            let context = UIGraphicsGetCurrentContext()
            CGContextSaveGState( context )
            CGContextTranslateCTM( context, 0, self.bounds.height )
            CGContextScaleCTM( context, 1, -1 )
            
            let axisLine = UIBezierPath()
            
            // Draw bottom axis
            axisLine.moveToPoint( CGPoint( x: distanceToLeft, y: heightOfBottomLine ) )
            axisLine.addLineToPoint( CGPoint( x: self.bounds.width - distanceToRight, y: heightOfBottomLine ) )
            UIColor.whiteColor().setStroke()
            axisLine.stroke()
            
            // Draw top axis
            axisLine.moveToPoint( CGPoint( x: distanceToLeft, y: self.bounds.height - distanceToTop ) )
            axisLine.addLineToPoint( CGPoint( x: self.bounds.width - distanceToRight, y: self.bounds.height - distanceToTop ) )
            axisLine.stroke()
            
            CGContextRestoreGState( context )
      
      }
      
//      private func initGraphView() {
//            var graphView = GraphView( frame: CGRect( x: <#CGFloat#>, y: <#CGFloat#>, width: <#CGFloat#>, height: <#CGFloat#>)) )
//      }
      
      private func setUpBackgroundClipArea() {
            var clipRect = CGRect( x:0, y: 0, width: self.bounds.width, height: self.bounds.height )
            var clipPath = UIBezierPath( roundedRect: clipRect, byRoundingCorners: UIRectCorner.AllCorners, cornerRadii: CGSize( width: 8.0, height: 8.0 ) )
            clipPath.addClip()
      }
      
      
      private func drawBackgroundGradient() {
            let cnt = UIGraphicsGetCurrentContext()
            
            let colors = [ self.startColor.CGColor, self.endColor.CGColor ]
            let colorSpaces = CGColorSpaceCreateDeviceRGB()
            let colorLocations: [ CGFloat ] = [ 0.0, 1.0 ]
            
            let gradient = CGGradientCreateWithColors( colorSpaces, colors, colorLocations )
            
            var startPoint = CGPoint.zeroPoint
            var endPoint = CGPoint( x: 0, y: self.bounds.height )
            
            CGContextDrawLinearGradient( cnt, gradient, startPoint, endPoint, 0 )
      }


}
