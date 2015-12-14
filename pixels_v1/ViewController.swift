//
//  ViewController.swift
//  pixels_v1
//
//  Created by Soohyun Christine Park on 2015. 4. 28..
//  Copyright (c) 2015년 SP. All rights reserved.
//

import UIKit

class ViewController: UIViewController, PTDBeanManagerDelegate, PTDBeanDelegate {

    var manager: PTDBeanManager!
    var connectedBean: PTDBean?
    
    func updateBean() {
        connectedBean?.setLedColor(UIColor.redColor())
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        manager = PTDBeanManager(delegate: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: PTDBeanManagerDelegate
    
    func beanManagerDidUpdateState(beanManager: PTDBeanManager!) {
        switch beanManager.state {
        case .Unsupported:
            UIAlertView(
                title: "Error",
                message: "This device is unsupported.",
                delegate: self,
                cancelButtonTitle: "OK"
                ).show()
        case .PoweredOff:
            UIAlertView(
                title: "Error",
                message: "Please turn on Bluetooth.",
                delegate: self,
                cancelButtonTitle: "OK"
                ).show()
        case .PoweredOn:
            beanManager.startScanningForBeans_error(nil);
        default:
            break
        }
    }
    
    func beanManager(beanManager: PTDBeanManager!, didDiscoverBean bean: PTDBean!, error: NSError!) {
        print("DISCOVERED BEAN \nName: \(bean.name), UUID: \(bean.identifier) RSSI: \(bean.RSSI)")
        if connectedBean == nil {
            if bean.state == .Discovered {
                manager.connectToBean(bean, error: nil)
            }
        }
    }
    
    func BeanManager(beanManager: PTDBeanManager!, didConnectToBean bean: PTDBean!, error: NSError!) {
        print("CONNECTED BEAN \nName: \(bean.name), UUID: \(bean.identifier) RSSI: \(bean.RSSI)")
        if connectedBean == nil {
            connectedBean = bean
        }
    }
    
    func beanManager(beanManager: PTDBeanManager!, didDisconnectBean bean: PTDBean!, error: NSError!) {
        print("DISCONNECTED BEAN \nName: \(bean.name), UUID: \(bean.identifier) RSSI: \(bean.RSSI)")
        
        // Dismiss any modal view controllers.
        presentedViewController?.dismissViewControllerAnimated(true, completion: {
            self.dismissViewControllerAnimated(true, completion: nil)
        })
        
        self.connectedBean = nil
    }


}

