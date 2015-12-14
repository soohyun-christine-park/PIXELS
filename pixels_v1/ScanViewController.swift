//
//  ScanViewController.swift
//  pixels_v1
//
//  Created by Soohyun Christine Park on 2015. 4. 28..
//  Copyright (c) 2015년 SP. All rights reserved.
//

import UIKit

protocol ScanViewControllerDelegate {
    func disconnect(bean: PTDBean)
}


class ScanViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, PTDBeanManagerDelegate, PTDBeanDelegate, PlayViewControllerDelegate{
    
    var manager: PTDBeanManager!
    var beans: PTDBean?
    var connectedBean: PTDBean?
    
    var fromPlay:Bool = false
    
   // var beanArray: [(AnyObject)]!
    
//    var fullPeripheralArray: [(String,String,String,PTDBean)]! // Array of Tuples  - Process Order 1
//    var cleanAndSortedArray: [(String,String,String,PTDBean)]! // Same as above  - Process Order 3
    
    //var myPeripheralDictionary: [String:(String,String,String,PTDBean)]!
    
    //var myPeripheralDictionary: [String:(String,String,String,PTDBean)] = ["Key": ("","","",connectedBean)] // - Process Order 2

    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        manager = PTDBeanManager(delegate: self)
        tableView.allowsMultipleSelection = true
        
//        if (connectedBean != nil){
//            disconnect(connectedBean!)
//        }
        
        //var beanO: PTDBean!
        
        //var myPeripheralDictionary: [String:(String,String,String,PTDBean)] = ["Key": ("","","",beanO)] // - Process Order 2
        // Do any additional setup after loading the view.
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
//        if connectedBean == nil {
//            if bean.state == .Discovered {
//                manager.connectToBean(bean, error: nil)
//            }
//        }
        
        let myUUIDString = bean.identifier.UUIDString
        let myRSSIString = String(bean.RSSI.intValue)
        var myNameString = bean.name
        var myAdvertString = "\(bean.advertisementData)"
        
        // RSSI = 127 0 ~ -100
        
        if bean.RSSI.intValue < 0{
            
            beans = bean
            
           // beanArray.append(bean)
            
            //let myTuple = (myUUIDString,myRSSIString,"\(myNameString)",bean!)
            
            //myPeripheralDictionary[myTuple.0] = myTuple  // No Duplicate Peripheral's
            //fullPeripheralArray.append(myTuple)
            
            // Clean Array
//            self.fullPeripheralArray.removeAll(keepCapacity: false)
//            
//            // Transfer dictionary into Array
//            for eachItem in myPeripheralDictionary{
//                fullPeripheralArray.append(eachItem.1)
//            }
            
            // Sort Array by RSSI
            //cleanAndSortedArray = sorted(fullPeripheralArray, {(str1: (String,String,String,PTDBean), str2: (String, String,String,PTDBean)) -> Bool in return str1.1.toInt() > str2.1.toInt()})
            
        }
        
        tableView.reloadData()
        
    }
    
    func beanManager(beanManager: PTDBeanManager!, didConnectBean bean: PTDBean!, error: NSError!) {
        connectedBean = bean
    }
    
    func beanManager(beanManager: PTDBeanManager!, didDisconnectBean bean: PTDBean!, error: NSError!) {
        if connectedBean == bean {
            connectedBean = nil
        }
    }
    
    func disconnect(bean: PTDBean){
        
       // if bean == nil{}else{
            manager.disconnectBean(bean, error: nil)
        //}
    }
    

    
    // MARK: UI Stuff
    
    @IBAction func scanSwitch(sender: UISwitch) {
        if sender.on{
            manager.startScanningForBeans_error(nil);
            print("Started Scan")
        }else {
            manager.stopScanningForBeans_error(nil)
            print("Stopped Scan")
        }
    }
    
    @IBAction func refreshPressed(sender: UIButton) {
        cleanUpData()
    }
    
    func connectClicked(sender: UIButton){
        
    }
    
    
    // MARK: UI Table View
    
    func cleanUpData(){
//        fullPeripheralArray.removeAll(keepCapacity: false)
//       // myPeripheralDictionary.removeAll(keepCapacity: false)
//        cleanAndSortedArray.removeAll(keepCapacity: false)
        //beanArray.removeAll(keepCapacity: false)
        tableView.reloadData()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //println("COUNT ARRAY   : \(beanArray.count)")
        return 1
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) 
        // more stuff to come
        
        
            cell.textLabel?.text = beans?.name
            cell.detailTextLabel?.text = "Connect"
            cell.detailTextLabel?.textColor = UIColor.blueColor()
        
        
        return cell
        
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.cellForRowAtIndexPath(indexPath)?.detailTextLabel?.text = "Connected"
        tableView.cellForRowAtIndexPath(indexPath)?.detailTextLabel?.textColor = UIColor.redColor()
        
        self.connectedBean = beans
        manager.connectToBean(beans, error: nil)
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        
            tableView.cellForRowAtIndexPath(indexPath)?.detailTextLabel?.text = "Connect"
            tableView.cellForRowAtIndexPath(indexPath)?.detailTextLabel?.textColor = UIColor.blueColor()
            
            disconnect(beans!)
    }
    
    
    
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if (connectedBean != nil){
            var playView = segue.destinationViewController as! PlayViewController
            
            // Pass the selected object to the new view controller.
            
             //playView.connectedBean = self.connectedBean!
             //println(self.connectedBean!.name)
             manager.stopScanningForBeans_error(nil)

            // webView.data = self.dataArray.objectAtIndex(indexPath.row) // get data by index and pass it to second view controller
            
        }
    
    }
    

}
