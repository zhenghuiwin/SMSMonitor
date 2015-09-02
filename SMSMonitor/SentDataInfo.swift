//
//  SentDataInfo.swift
//  SMSMonitor
//
//  Created by zhenghuiwin on 15/8/27.
//  Copyright (c) 2015年 zhenghuiwin. All rights reserved.
//

import Foundation
import UIKit

class SentDataInfo {
      private var _company: Int?
      
      private var _updateTime: NSString = "2015-9-1 00:00:00"
      
      private var _statsData: [CGFloat] = [CGFloat]( count: 24, repeatedValue: 0 )
      
      init( companyType comp: Int, updateTime time: NSString?, statsData sData: [CGFloat]? ) {
            _company = comp
            if let definiteTime = time {
                  _updateTime = definiteTime
            }
            
            if let definiteData = sData {
                  _statsData = definiteData
            }
      }
      
      var company: Int? {
            get {
                  return _company
            }
      }
      
      var updateTime: NSString {
            get {
                  return _updateTime
            }
      }
      
      var statsData: [CGFloat] {
            get {
                  return _statsData
            }
      }
      
      // Format of updatTime is yyyy-MM-dd hh:mm:ss
      func hourOfUpdateTime() -> Int? {
            let component = _updateTime.componentsSeparatedByString( " " )
            if component.count == 2 {
                  let timeComp = ( component[1] as! NSString ).componentsSeparatedByString( ":" )
                  if timeComp.count > 0 {
                        if let hour = ( timeComp[0] as! String ).toInt() {
                               return hour
                        }
                  }
            }
      
            return nil
      }
}
