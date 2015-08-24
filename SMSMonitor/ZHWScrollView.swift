//
//  ZHWScrollView.swift
//  Monitor
//
//  Created by zhenghuiwin on 15/2/27.
//  Copyright (c) 2015年 zhenghuiwin. All rights reserved.
//

import UIKit

class ZHWScrollView: UIScrollView {
      
      var  _startColor: UIColor = UIColor(red: 250.0 / 255.0, green: 233.0 / 255.0, blue: 222.0 / 255.0, alpha: 1.0 )
      var _endColor:    UIColor = UIColor(red: 252.0 / 255.0, green: 79 / 255.0, blue: 8 / 255.0, alpha: 1.0 )
      
      var startColor: UIColor {
            get {
                  return  _startColor
            }
            
            set {
                  _startColor = newValue
            }
      }
      
      var endColor: UIColor {
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
            // Set up the background cliping area
            setUpBackgroundClipArea()
            drawBackgroundGradient()
      }
      
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
