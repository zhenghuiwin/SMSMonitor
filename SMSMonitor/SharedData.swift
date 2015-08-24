//
//  SharedData.swift
//  SMSMonitor
//
//  Created by zhenghuiwin on 15/4/20.
//  Copyright (c) 2015年 zhenghuiwin. All rights reserved.
//

import Foundation

class SharedData {
      static let sharedInstance = SharedData()
      
      private var _selectedDate: CVDate = CVDate( date: NSDate() )
      
      var selectedDate: CVDate {
            set {
                  _selectedDate = newValue
            }
            
            get {
                  return _selectedDate
            }
      }
      
}