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
      
      private var _updateTime: NSString?
      
      private var _statsData: [CGFloat]?
      
      init( companyType comp: Int, updateTime time: NSString, statsData sData: [CGFloat] ) {
            _company = comp
            _updateTime = time
            _statsData = sData
      }
      
      var company: Int? {
            get {
                  return _company
            }
      }
      
      var updateTime: NSString? {
            get {
                  return _updateTime
            }
      }
      
      var statsData: [CGFloat]? {
            get {
                  return _statsData
            }
      }
      
      // Format of updatTime is yyyy-MM-dd hh:mm:ss
      func hourOfUpdateTime() -> Int? {
            if let time = _updateTime {
                  let component = time.componentsSeparatedByString( " " )
                  if component.count == 2 {
                        let timeComp = ( component[1] as! NSString ).componentsSeparatedByString( ":" )
                        if timeComp.count > 0 {
                              if let hour = ( timeComp[0] as! String ).toInt() {
                                    return hour
                              }
                        }
                  }
            }
            
            return nil
      }
}
