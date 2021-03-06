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

      let heightOfMainScrollView: CGFloat = 1108 //1260
      
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
      @IBOutlet weak var mobileUpdateTime: UILabel!
      
      @IBOutlet weak var unicomHourlyData: UILabel!
      @IBOutlet weak var unicomHourlyAmount: UILabel!
      @IBOutlet weak var unicomUpdateTime: UILabel!

      
      @IBOutlet weak var telcomHourlyData: UILabel!
      @IBOutlet weak var telcomHourlyAmount: UILabel!
      @IBOutlet weak var telcomUpdateTime: UILabel!
      
      @IBOutlet weak var mobileOwnHourlyData: UILabel!
      @IBOutlet weak var mobileOwnHourlyAmount: UILabel!
      @IBOutlet weak var mobileOwnUpdateTime: UILabel!
      
     
      @IBOutlet weak var barItem: UIBarButtonItem!
      
      let dateFormatter = NSDateFormatter()
      
      lazy var workingQueue = dispatch_queue_create("workingQueue", nil)
      lazy var refreshControl = UIRefreshControl()
      
      
      // The default date is today
      private var _selectedDate: String = ""
      var selectedDate: String {
            set {
                  _selectedDate = newValue
            }
            get {
                  if _selectedDate == "" {
                        // today
                        dateFormatter.dateFormat = "yyyy-MM-dd"
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
            
            
            refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
            refreshControl.addTarget( self, action: "refresh", forControlEvents: UIControlEvents.ValueChanged )
            
            self.mainScrollView.insertSubview( refreshControl, atIndex: 0 )
      
      }
      
      override func viewWillAppear(animated: Bool) {
            
      }
      
      override func viewDidLayoutSubviews() {
            
      }
      
      override func viewDidAppear( animated: Bool ) {
            println("ViewController-viewDidAppear")
            
            super.viewDidAppear( animated )
            
            mainScrollView.contentSize = CGSize( width: mainScrollView.bounds.size.width, height: heightOfMainScrollView )
            
            fetchSatsDataFromServer()
            
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
      
      func refresh(  ) {
            self.fetchSatsDataFromServer()
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
            sentDataInfo sDataInfo: SentDataInfo,
            closure: ( hourlyData: CGFloat, hourlyAmount: CGFloat ) -> () ) {
                  graphView.resize()
                  graphView.arrangeTimeLable()
                  graphView.calculateContentSize()
                  graphView.setSelectBarClosure( closure )
                  graphView.setStatisticalData( sentDataInfo: sDataInfo )
      }
      
      private func didRoateForGraphLayerView( graphView: GraphLayerView ) {
            graphView.resize()
            graphView.arrangeTimeLable()
            graphView.calculateContentSize()
            graphView.setNeedsDisplay()
            graphView.displayGraph()
      }
      
      private func setDataToGraphLayerViews( sentDataInfo sDataInfo: SentDataInfo ) {
            if let definiteCompany = sDataInfo.company {
                  switch definiteCompany {
                  case 1:
                        // Setup mobileGView
                        self.setupGraphLayerView( mobileGView, sentDataInfo: sDataInfo ) {
                              (hourlyData, hourlyAmount) -> () in
                              
                              let processedHourlyData = self.parseData( hourlyData )
                              let processedHourlyAmount = self.parseData( hourlyAmount )
                              
                              
                              self.mobileHourlyData.text = "\(processedHourlyData)"
                              self.mobileHourlyAmount.text = "\(processedHourlyAmount)"
                        }
                        
                        mobileUpdateTime.text = sDataInfo.updateTime as? String
                        
                  case 2:
                        // Setup unicomGView
                        self.setupGraphLayerView( unicomGView, sentDataInfo: sDataInfo ) {
                              (hourlyData, hourlyAmount) -> () in
                              
                              let processedHourlyData = self.parseData( hourlyData )
                              let processedHourlyAmount = self.parseData( hourlyAmount )
                              
                              self.unicomHourlyData.text = "\(processedHourlyData)"
                              self.unicomHourlyAmount.text = "\(processedHourlyAmount)"
                        }
      
                        unicomUpdateTime.text = sDataInfo.updateTime as? String
                  case 3:
                        // Setup telcomGView
                        self.setupGraphLayerView( telcomGView, sentDataInfo: sDataInfo ) {
                              (hourlyData, hourlyAmount) -> () in
                              
                              let processedHourlyData = self.parseData( hourlyData )
                              let processedHourlyAmount = self.parseData( hourlyAmount )
                              
                              self.telcomHourlyData.text = "\(processedHourlyData)"
                              self.telcomHourlyAmount.text = "\(processedHourlyAmount)"
                        }
                        
                        telcomUpdateTime.text = sDataInfo.updateTime as? String
                  case 4:
                        // Setup mobileOwnGView
                        self.setupGraphLayerView( mobileOwnGView, sentDataInfo: sDataInfo ) {
                              (hourlyData, hourlyAmount) -> () in
                              
                              let processedHourlyData = self.parseData( hourlyData )
                              let processedHourlyAmount = self.parseData( hourlyAmount )
                              
                              self.mobileOwnHourlyData.text = "\(processedHourlyData)"
                              self.mobileOwnHourlyAmount.text = "\(processedHourlyAmount)"
                        }
                        mobileOwnUpdateTime.text = sDataInfo.updateTime as? String
                  default:
                        println( "No correspond company!" )
                  }
            }
            
      }
      
      private func clearLabels() {
            mobileHourlyData.text = ""
            mobileHourlyAmount.text = ""
            mobileUpdateTime.text = ""
            
            unicomHourlyData.text = ""
            unicomHourlyAmount.text = ""
            unicomUpdateTime.text = ""
            
            telcomHourlyData.text = ""
            telcomHourlyAmount.text = ""
            telcomUpdateTime.text = ""
            
            mobileOwnHourlyData.text = ""
            mobileOwnHourlyAmount.text = ""
            mobileOwnUpdateTime.text = ""
      }
      
      
      private func fetchSatsDataFromServer() {
            clearLabels()
            
            // Set the default SentDataInfo for each company
            // Because sometimes for some company, there is no corresponding statistical data
            var dataHash: [ Int : SentDataInfo] = [ 1:SentDataInfo( companyType: 1, updateTime: nil, statsData: nil ),
                  2:SentDataInfo( companyType: 2, updateTime: nil, statsData: nil ),
                  3:SentDataInfo( companyType: 3, updateTime: nil, statsData: nil ),
                  4:SentDataInfo( companyType: 4, updateTime: nil, statsData: nil ) ]
            
            
            let url = "http://114.215.125.44:9002/hd/\(self.selectedDate)"
            println( "url is \(url)" )

            dispatch_async( workingQueue, { () -> Void in
                  Alamofire.request(.GET, url )
                        .responseJSON { _, _, JSON, _ in
                              fetchDataWithURL( url, updateUIWithHash: dataHash, andJson: JSON )
                  }
            })
      }
      
      private func fetchDataWithURL( url: String, updateUIWithHash hash: [ Int:SentDataInfo ], andJson JSON: AnyObject? ) {
            // TODO: TEST
            println("[GOT THE DATA FROM THE SERVER]")
            var dataHash = hash
            if let array = JSON as? NSArray {
                  println( "count is \(array.count)" )
                  for hashObj in array {
                        if let company = hashObj["company"] as? Int {
                              if let updateTime = hashObj["updateTime"] as? String {
                                    if let sentData = hashObj["data"] as? Array<CGFloat> {
                                          dataHash[ company ] = SentDataInfo( companyType: company,
                                                updateTime: updateTime,
                                                statsData: sentData )
                                    }
                              }
                              
                        }
                  }
            }
            
            for ( com, sentDataInfo ) in dataHash {
                  // Update the UI with data fetched from the Server
                  dispatch_async( dispatch_get_main_queue(), { () -> Void in
                        self.refreshControl.endRefreshing()
                        self.setDataToGraphLayerViews( sentDataInfo: sentDataInfo )
                  })
            }
      }
      
      private func parseData( data: CGFloat ) -> String {
            var dataStr = NSString( format: "%f", data ) as String
            
            let dataArr = dataStr.componentsSeparatedByString( "." )
            var integerPortion = dataArr[0]
            
            // Processing the portion of integer of data
            var count = 0
            for var index = integerPortion.endIndex.predecessor();
                  index >= integerPortion.startIndex;
                  index = index.predecessor() {
                        if ++count == 3 && index > integerPortion.startIndex {
                              integerPortion.insert( ",", atIndex: index )
                              count = 0
                        }
                        
                        if index == integerPortion.startIndex {
                              break
                        }    
            }
            
            var result = integerPortion
            
            // Processing the portion of fractional of data
            var fractionalPortion = ""
            if dataArr.count >= 2 {
                  fractionalPortion = dataArr[1]
                  var availableIndex = fractionalPortion.startIndex
                  for var i = fractionalPortion.endIndex.predecessor();
                        i > fractionalPortion.startIndex;
                        i = i.predecessor() {
                              if  fractionalPortion[i] != "0" {
                                    availableIndex = i
                                    break
                              }
                  }
                  
                  result += "." + fractionalPortion.substringWithRange( Range<String.Index>( start: fractionalPortion.startIndex, end: availableIndex.successor() ) )
            }
            
            return result
      }

}

