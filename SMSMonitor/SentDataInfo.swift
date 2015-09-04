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
      
      private var _statsData: [CGFloat] = [CGFloat]( count: 24, repeatedValue: 0 )
      
      init( companyType comp: Int, updateTime time: NSString?, statsData sData: [CGFloat]? ) {
            _company = comp
            // TODO: Check the format of the updateTime  "yyyy-MM-dd hh:mm:ss"
            _updateTime = time
            
            if let definiteData = sData {
                  if definiteData.count > 0 {
                        _statsData = definiteData
                  }
            }
      }
      
      var company: Int? {
            get {
                  return _company
            }
      }
      
      var updateTime: NSString? {
            get {
                  if let definiteTime = _updateTime {
                        let comp = definiteTime.componentsSeparatedByString( " " )
                        if comp.count == 2 {
                              return comp[1] as? NSString
                        }
                  }
                  return nil
            }
      }
      
      var statsData: [CGFloat] {
            get {
                  return _statsData
            }
      }
      
      // Format of updatTime is yyyy-MM-dd hh:mm:ss
      // The default value is 0
      func hourOfUpdateTime() -> Int {
            if let definiteTime = _updateTime {
                  let component = definiteTime.componentsSeparatedByString( " " )
                  if component.count == 2 {
                        let timeComp = ( component[1] as! NSString ).componentsSeparatedByString( ":" )
                        if timeComp.count > 0 {
                              if let hour = ( timeComp[0] as! String ).toInt() {
                                    return hour
                              }
                        }
                  }
                  
            }
            
            return 0
      }
}
