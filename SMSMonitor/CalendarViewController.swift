//
//  CalendarViewController.swift
//  SMSMonitor
//
//  Created by zhenghuiwin on 15/4/11.
//  Copyright (c) 2015年 zhenghuiwin. All rights reserved.
//

import UIKit

class CalendarViewController: UIViewController, CVCalendarViewDelegate {

      @IBOutlet weak var menuView: CVCalendarMenuView!
     
      @IBOutlet weak var calendarView: CVCalendarView!
      
      @IBOutlet weak var selectedDateLabel: UILabel!
      
      @IBOutlet weak var currentYearLabel: UILabel!
      @IBOutlet weak var currentMonthLabel: UILabel!
      
      
      let _monthMap: [ Int : String ] = [ 1 : "JAN", 2 : "FEB", 3 : "MAR", 4 : "APR", 5 : "MAY", 6 : "JUN", 7 : "JUL", 8 : "AUG", 9 : "SEP", 10 : "OCT", 11 : "NOV", 12 : "DEC" ]

      
      override func viewDidLoad() {
            super.viewDidLoad()

            // Do any additional setup after loading the view.
            self.calendarView.commitCalendarViewUpdate()
            calendarView.delegate = self
      }
      
      
      override func viewDidAppear(animated: Bool) {
            super.viewDidAppear( animated )
            
            self.menuView.commitMenuViewUpdate()
            self.calendarView.commitCalendarViewResize()

            let sharedData = SharedData.sharedInstance
            self.calendarView.toggleMonthViewWithDate( sharedData.selectedDate.toDate()! )
            updateTheDateLabel( sharedData.selectedDate )

            //            self.calendarView.heightLightCurrentDay()
      }
      
      override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
            self.menuView.commitMenuViewUpdate()
            self.calendarView.commitCalendarViewResize()
      }

      override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
      }
      
      
      private func updateTheDateLabel( cvdate: CVDate ) {
            selectedDateLabel.text = "\(cvdate.year!)-\(cvdate.month!)-\(cvdate.day!)"
            
            if currentYearLabel.text == "" || currentMonthLabel.text == "" {
                  currentYearLabel.text = "\(cvdate.year!)"
                  currentMonthLabel.text = _monthMap[ cvdate.month! ]
            }
      }
      
      // MARK: - Calendar view delegate
      func shouldShowWeekdaysOut() -> Bool {
            return false
      }
      
      func didSelectDayView(dayView: CVCalendarDayView) {
            if let cvdate = dayView.date {
                  SharedData.sharedInstance.selectedDate = cvdate
                  updateTheDateLabel( cvdate )
            }
      }
      
      func presentedDateUpdated(date: CVDate) {
            currentYearLabel.text = "\(date.year!)"
            currentMonthLabel.text = _monthMap[ date.month! ]
      }
      
      func topMarker(shouldDisplayOnDayView dayView: CVCalendarDayView) -> Bool {
            return true
      }
      
      func dotMarker(shouldMoveOnHighlightingOnDayView dayView: CVCalendarDayView) -> Bool {
            return false
      }
      
      func dotMarker(shouldShowOnDayView dayView: CVCalendarDayView) -> Bool {
            return false
      }
      
      func dotMarker(colorOnDayView dayView: CVCalendarDayView) -> UIColor {
            return UIColor.blueColor()
      }


  /*
      // MARK: - Navigation

      // In a storyboard-based application, you will often want to do a little preparation before navigation
      override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
      }
 */

}
