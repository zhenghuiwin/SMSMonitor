//
//  CVCalendarContentViewController.swift
//  CVCalendar Demo
//
//  Created by E. Mozharovsky on 1/28/15.
//  Copyright (c) 2015 GameApp. All rights reserved.
//

import UIKit

class CVCalendarContentViewController: UIViewController, UIScrollViewDelegate {
    
    // MARK: - Type Work
    
    typealias CalendarView = CVCalendarView
    typealias ContentDelegate = CVCalendarContentDelegate
    typealias CalendarMode = CVCalendarViewMode
    typealias MonthContent = CVCalendarMonthContentView
    typealias WeekContent = CVCalendarWeekContentView
    typealias MonthView = CVCalendarMonthView
    typealias DayView = CVCalendarDayView
    
    // MARK: - Private Properties
    
    var calendarView: CalendarView!
    var presentedMonthView: MonthView!
    
    private var scrollView: UIScrollView!
    private var delegate: ContentDelegate!

    // MARK: - Initialization
    
      init(calendarView: CalendarView, frame: CGRect ) {
        super.init(nibName: nil, bundle: nil)
        
        self.calendarView = calendarView
        self.scrollView = UIScrollView(frame: frame)
        
        // Setup Scroll View.
        scrollView.contentSize = CGSizeMake(frame.width * 3, frame.height)
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.pagingEnabled = true
        scrollView.delegate = self
        
        presentedMonthView = MonthView(calendarView: calendarView, date: NSDate() )
        
        if calendarView.calendarMode == CalendarMode.MonthView {
            delegate = MonthContent(contentController: self)
        } else {
            delegate = WeekContent(contentController: self)
        }
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
      
  
    // MARK: - View Control
    
    func preparedScrollView() -> UIScrollView {
        if let scrollView = self.scrollView {
            return scrollView
        } else {
            return UIScrollView()
        }
    }
    
    // MARK: - Appearance Update
    
    func updateFrames(frame: CGRect) {
        
        presentedMonthView.updateAppearance(frame)
        
        scrollView.frame = frame
        scrollView.contentSize = CGSizeMake(frame.size.width * 3, frame.size.height)
        
        delegate.updateFrames()
        
//        calendarView.hidden = false
      calendarView.hidden = true   
    }
      
      func resizeFrames( frame: CGRect ) {
            presentedMonthView.resizeAppearance( frame )
            
            scrollView.frame = frame
            scrollView.contentSize = CGSizeMake(frame.size.width * 3, frame.size.height)
            
            delegate.updateFrames()
            
            calendarView.hidden = false
      }
      
      // MARK: - Added by me
      func heightLiehtTheCurerntDay() {
            presentedMonthView.setDayHeightLight()
      }
    
    // MARK: - Scroll View Delegate
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        delegate.scrollViewDidScroll(scrollView)
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        delegate.scrollViewWillBeginDragging(scrollView)
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        delegate.scrollViewDidEndDecelerating(scrollView)
    }
    
    // MARK: - Day View Selection
    
    func performedDayViewSelection(dayView: DayView) {
        delegate.performedDayViewSelection(dayView)
    }
    
    // MARK: - Toggle Date
    
    func togglePresentedDate(date: NSDate) {
        delegate.togglePresentedDate(date)
    }
    
    // MARK: - Paging
    
    func presentNextView(dayView: DayView?) {
        delegate.presentNextView(dayView)
    }
    
    func presentPreviousView(dayView: DayView?) {
        delegate.presentPreviousView(dayView)
    }
    
    // MARK: - Days Out Showing
    
    func updateDayViews(hidden: Bool) {
        delegate.updateDayViews(hidden)
    }
}
