//
//  CVDate.swift
//  CVCalendar
//
//  Created by Мак-ПК on 12/31/14.
//  Copyright (c) 2014 GameApp. All rights reserved.
//

import UIKit

class CVDate: NSObject {
      private let date: NSDate?
      var year: Int?
      var month: Int?
      var week: Int?
      var day: Int?

      init(date: NSDate) {
            let calendarManager = CVCalendarManager.sharedManager

            self.date = date

            self.year = calendarManager.dateRange(date).year
            self.month = calendarManager.dateRange(date).month
            self.day = calendarManager.dateRange(date).day
            super.init()
      }

      init(day: Int, month: Int, week: Int, year: Int) {
            self.year = year
            self.month = month
            self.week = week
            self.day = day
            self.date = NSDate()
            super.init()
      }


      func toDate() -> NSDate? {
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            dateFormatter.timeZone = NSTimeZone( forSecondsFromGMT: 0 )
            
            var date = dateFormatter.dateFromString( "\(self.year!)-\(self.month!)-\(self.day!)" )

            return date
      }
      
      
      func dateDescription() -> String {
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "MMMM"

            let month = dateFormatter.stringFromDate(self.date!)

            return "\(month), \(self.year!)"
      }
}
