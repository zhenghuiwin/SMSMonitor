//
//  AboutViewController.swift
//  SMSMonitor
//
//  Created by zhenghuiwin on 15/9/8.
//  Copyright (c) 2015年 zhenghuiwin. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {
      
      @IBAction func openEmail(sender: AnyObject) {
            if let url = NSURL( string: "mailto:bluegene.hao@gmail.com" ) {
                  UIApplication.sharedApplication().openURL( url )
            }
            
      }
}