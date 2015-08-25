//
//  ViewController.swift
//  Monitor
//
//  Created by zhenghuiwin on 15/2/17.
//  Copyright (c) 2015年 zhenghuiwin. All rights reserved.
//

import UIKit
import Alamofire

class ViewController: UIViewController, ViewPassDataProtocol {

      let heightOfMainScrollView: CGFloat = 1260
      
      @IBOutlet weak var mainScrollView: UIScrollView!
      @IBOutlet weak var mobileBgView: BackgroundView!
      @IBOutlet weak var unicomBgView: BackgroundView!
      @IBOutlet weak var telcomBgView: BackgroundView!
      @IBOutlet weak var moileOwnBgView: BackgroundView!

      @IBOutlet weak var mobileGView: GraphLayerView!
      @IBOutlet weak var unicomGView: GraphLayerView!
      @IBOutlet weak var telcomGView: GraphLayerView!
      @IBOutlet weak var mobileOwnGView: GraphLayerView!
      
      @IBOutlet weak var mobileHourlyData: UILabel!
      @IBOutlet weak var mobileHourlyAmount: UILabel!
      @IBOutlet weak var unicomHourlyData: UILabel!
      @IBOutlet weak var unicomHourlyAmount: UILabel!
      @IBOutlet weak var telcomHourlyData: UILabel!
      @IBOutlet weak var telcomHourlyAmount: UILabel!
      @IBOutlet weak var mobileOwnHourlyData: UILabel!
      @IBOutlet weak var mobileOwnHourlyAmount: UILabel!
      
     
      @IBOutlet weak var barItem: UIBarButtonItem!
      
      let dateFormatter = NSDateFormatter()
      
      
      // The default date is today
      private var _selectedDate: String = ""
      var selectedDate: String {
            set {
                  _selectedDate = newValue
            }
            get {
                  if _selectedDate == "" {
                        // today
                        dateFormatter.dateFormat = "yyyy/MM/dd"
                        _selectedDate = dateFormatter.stringFromDate( NSDate() )
                  }
                  
                  return _selectedDate
            }
      }
      
      
      
      var _graphViews: [ GraphView ] = []
      

      
      override func viewDidLoad() {
            super.viewDidLoad()
            // Do any additional setup after loading the view, typically from a nib.
            
            self.navigationController!.navigationBar.barTintColor = UIColor( red: 68 / 255, green: 128 / 255, blue: 240 / 255, alpha: 1 )
            self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
      
      }
      
      override func viewWillAppear(animated: Bool) {
            
      }
      
      override func viewDidLayoutSubviews() {
            
      }
      
      override func viewDidAppear( animated: Bool ) {
            println("ViewController-viewDidAppear")
            
            super.viewDidAppear( animated )
            
            mainScrollView.contentSize = CGSize( width: mainScrollView.bounds.size.width, height: heightOfMainScrollView )
            
            // TODO: TEST
            println( "selected date is \(self.selectedDate)" )

            Alamofire.request(.GET, "http://114.215.125.44:9002/hd")
                  .responseJSON { _, _, JSON, _ in

                        if let array = JSON as? NSArray {
                             println( "count is \(array.count)" )
                              for hashObj in array {
                                    if let company = hashObj["company"] as? Int {
                                          if let updateTime = hashObj["updateTime"] as? String {
                                                if let sentData = hashObj["data"] as? Array<CGFloat> {
                                                      
                                                      // Update the UI with data fetched from the Server
                                                      self.setDataToGraphLayerViews( company: company, updateTime: updateTime, statsData: sentData )
                                                }
                                          }
                                          
                                    }
                              }
                        }
            }

            
      }

      override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
            // Dispose of any resources that can be recreated.
      }
      
      
      
      override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
            println("ViewController-didRotateFromInterfaceOrientation")
            
            mainScrollView.contentSize = CGSize( width: mainScrollView.bounds.size.width, height: heightOfMainScrollView )
            
            mobileBgView.setNeedsDisplay()
            
            unicomBgView.setNeedsDisplay()
            
            telcomBgView.setNeedsDisplay()
            
            moileOwnBgView.setNeedsDisplay()
            
            self.didRoateForGraphLayerView( mobileGView )
            
            self.didRoateForGraphLayerView( unicomGView )
            
            self.didRoateForGraphLayerView( telcomGView )
            
            self.didRoateForGraphLayerView( mobileOwnGView )
      }
      
      // MARK: - ViewPassDataProtocol methods
      func setData( data: String ) {
            self.selectedDate = data
      }
      
      func data() -> String {
            return self.selectedDate
      }
      
      // MARK: -Navigation
      override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
            if let destViewController = segue.destinationViewController as? CalendarViewController {
                  destViewController.delegate = self
            }
      }
      
      // MARK: - private method
      private func setupGraphLayerView( graphView: GraphLayerView,
            statsData sData: [CGFloat],
            closure: ( hourlyData: CGFloat, hourlyAmount: CGFloat ) -> () ) {
                  graphView.resize()
                  graphView.arrangeTimeLable()
                  graphView.calculateContentSize()
                  graphView.setSelectBarClosure( closure )
                  graphView.setStatisticalData( statsData: sData )
      }
      
      private func didRoateForGraphLayerView( graphView: GraphLayerView ) {
            graphView.resize()
            graphView.arrangeTimeLable()
            graphView.calculateContentSize()
            graphView.setNeedsDisplay()
            graphView.displayGraph()
      }
      
      private func setDataToGraphLayerViews( company comp: Int, updateTime time: String, statsData sentData: [CGFloat] ) {
            
            switch comp {
            case 1:
                  // Setup mobileGView
                  self.setupGraphLayerView( mobileGView, statsData: sentData ) {
                        (hourlyData, hourlyAmount) -> () in
                        self.mobileHourlyData.text = "\(hourlyData)"
                        self.mobileHourlyAmount.text = "\(hourlyAmount)"
                  }
                  
            case 2:
                  // Setup unicomGView
                  self.setupGraphLayerView( unicomGView, statsData: sentData ) {
                        (hourlyData, hourlyAmount) -> () in
                        self.unicomHourlyData.text = "\(hourlyData)"
                        self.unicomHourlyAmount.text = "\(hourlyAmount)"
                  }
            case 3:
                  // Setup telcomGView
                  self.setupGraphLayerView( telcomGView, statsData: sentData ) {
                        (hourlyData, hourlyAmount) -> () in
                        self.telcomHourlyData.text = "\(hourlyData)"
                        self.telcomHourlyAmount.text = "\(hourlyAmount)"
                  }
            case 4:
                  // Setup mobileOwnGView
                  self.setupGraphLayerView( mobileOwnGView, statsData: sentData ) {
                        (hourlyData, hourlyAmount) -> () in
                        self.mobileOwnHourlyData.text = "\(hourlyData)"
                        self.mobileOwnHourlyAmount.text = "\(hourlyAmount)"
                  }
            default:
                  println( "No correspond company!" )
            }
            
            
            
      }
      
      
      

}

