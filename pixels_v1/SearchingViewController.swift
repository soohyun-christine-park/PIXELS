//
//  SearchingViewController.swift
//  pixels_v1
//
//  Created by Soohyun Christine Park on 2015. 5. 7..
//  Copyright (c) 2015년 SP. All rights reserved.
//

import UIKit

class SearchingViewController: UIViewController, PTDBeanManagerDelegate, PTDBeanDelegate {
    
    
    // MARK: PTDBeanManagerDelegate
    
    var manager: PTDBeanManager!
    //var beans: PTDBean?
    var connectedBean: PTDBean?
    
//    struct beanContainer {
//        var bean: PTDBean
//        //var isConnected: BeanState
//        
//        init(bean:PTDBean){
//            self.bean = bean
//        }
//    }
    
    var beans: [PTDBean] = []
    var connectedBeans: [PTDBean] = []
    var beanButtons: [UIButton] = []
    
    // MARK: UI Stuff
    
    var searchable: Bool = true;
    var blueColor: UIColor = UIColor(red: 43/255, green: 154/255, blue: 255/255, alpha: 1)
    var countBeans = 0
    var buttonPosition: [(CGFloat, CGFloat)] = [(0.20, 0.22), (0.72, 0.22), (0.20, 0.70), (0.72, 0.70)]
    var screenSize: CGRect = UIScreen.mainScreen().bounds
    
    @IBOutlet weak var goButton: UIButton!

    @IBOutlet weak var searchButton: UIButton!
    
//    func rotated()
//    {
//        screenSize = UIScreen.mainScreen().bounds
//        
//    }
    
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
            if beans.count > 0{ beanManager.stopScanningForBeans_error(nil) }else {
                beanManager.startScanningForBeans_error(nil);
            }
        default:
            break
        }
    }
    
    func beanManager(beanManager: PTDBeanManager!, didDiscoverBean bean: PTDBean!, error: NSError!) {
        
        print("discover \(beans.count)")
    
        if let i = beans.indexOf(bean){print("bean in Beans")}else{ // if it is already found bean - skip.
        
            // RSSI = 127 0 ~ -100
            
            print("found!")
        
            
            print("DISCOVERED BEAN \nName: \(bean.name), UUID: \(bean.identifier) RSSI: \(bean.RSSI)")
            
            if beanButtons.count < 4 && bean.RSSI != nil { // set maximum beans to 4
                
                print("add")
        
                beans.append(bean)
        
                beanButtons.append(UIButton(frame:CGRectMake(CGFloat(screenSize.width * buttonPosition[beanButtons.count].0), CGFloat(screenSize.height * buttonPosition[beanButtons.count].1), 100, 100)))
               
                beanButtons[beanButtons.count - 1].setTitle("\(bean.name)",forState:UIControlState.Normal)
                beanButtons[beanButtons.count - 1].setTitleColor(UIColor.whiteColor(), forState:UIControlState.Normal)
                beanButtons[beanButtons.count - 1].layer.borderColor = UIColor.whiteColor().CGColor
                beanButtons[beanButtons.count - 1].layer.borderWidth = 1
                beanButtons[beanButtons.count - 1].addTarget(self, action: "beanAction:",  forControlEvents: UIControlEvents.TouchUpInside)
                
                beanButtons[beanButtons.count - 1].layer.cornerRadius = beanButtons[beanButtons.count - 1].bounds.size.height / 2
                self.view.addSubview(beanButtons[beanButtons.count - 1])
                
            }
            
        }
        
        
    }
    
    func beanAction(sender: UIButton){
        print("Counted beans :   \(beanButtons.count)")
   
        if let i = beanButtons.indexOf(sender){ // selected bean
            
            if let j = connectedBeans.indexOf(beans[i]) { // is connected already
            
                manager.disconnectBean(beans[i], error: nil)  // Let's disconnect
                //disconnectingAnimation(sender)
            
            }else{  // is disconnected
                
                print("\(beans[i].identifier)")
                manager.connectToBean(beans[i], error: nil)    // Let's connect
                connectingAnimation(sender)
                
            }
            
        }else { print("Couldn't find selected bean ...") }
    }
    
    func beanManager(beanManager: PTDBeanManager!, didConnectBean bean: PTDBean!, error: NSError!) {
        connectedBeans.append(bean)
        
        if let i = beans.indexOf(bean){
            beanButtons[i].layer.removeAllAnimations()
            connectedAnimation(beanButtons[i])
        }else {}
        
        if goButton.enabled == false {
            goButton.enabled = true
            goButton.alpha = 1.0
        }
    }
    
    func beanManager(beanManager: PTDBeanManager!, didDisconnectBean bean: PTDBean!, error: NSError!) {
        if let i = connectedBeans.indexOf(bean){
            connectedBeans.removeAtIndex(i)
        }else { print("Couldn't find selected bean ...") }
        
        if let i = beans.indexOf(bean){
            beanButtons[i].layer.removeAllAnimations()
            disconnectedAnimation(beanButtons[i])
        }else {}
        
        if connectedBeans.count == 0 {
            goButton.enabled = false
            goButton.alpha = 0.6
        }
    }
    
    
    func disconnect(bean: PTDBean){
        manager.disconnectBean(bean, error: nil)
    }

    
    
    // MARK: UI Stuff
    
    func searchAnimation(){
        UIView.animateWithDuration(0.7, delay: 0.0, options: [UIViewAnimationOptions.Autoreverse, UIViewAnimationOptions.Repeat, UIViewAnimationOptions.CurveEaseIn, UIViewAnimationOptions.AllowUserInteraction], animations: {
            self.searchButton.alpha = 0.3
            }, completion: nil)
        
    }

    func connectedAnimation(selectedButton : UIButton){
        UIView.animateWithDuration(0.1, delay: 0.0, options: [UIViewAnimationOptions.CurveEaseIn, UIViewAnimationOptions.AllowUserInteraction], animations: {
            selectedButton.backgroundColor = UIColor.greenColor()
            selectedButton.layer.borderWidth = 0.0
            selectedButton.alpha = 1.0
            selectedButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
            }, completion: nil)
    }
    
    func disconnectedAnimation(selectedButton : UIButton){
        UIView.animateWithDuration(0.1, delay: 0.0, options: [UIViewAnimationOptions.CurveEaseIn, UIViewAnimationOptions.AllowUserInteraction], animations: {
            selectedButton.backgroundColor = UIColor.clearColor()
            selectedButton.alpha = 1.0
            selectedButton.layer.borderWidth = 1
            selectedButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            }, completion: nil)
    }
    
    func connectingAnimation(selectedButton : UIButton){
        
        UIView.animateWithDuration(0.1, delay: 0.0, options: [UIViewAnimationOptions.CurveEaseIn, UIViewAnimationOptions.AllowUserInteraction], animations: {
            selectedButton.backgroundColor = UIColor.yellowColor()
            selectedButton.layer.borderWidth = 0.0
            selectedButton.alpha = 0.7
            }, completion: { finished in
                UIView.animateWithDuration(0.3, delay: 0.0, options: [UIViewAnimationOptions.Autoreverse, UIViewAnimationOptions.Repeat, UIViewAnimationOptions.CurveEaseIn, UIViewAnimationOptions.AllowUserInteraction], animations: {
                    selectedButton.alpha = 0.5
                }, completion: nil)
            }
        )
    }
    
//    func disconnectingAnimation(selectedButton : UIButton){
//        UIView.animateWithDuration(0.1, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn | UIViewAnimationOptions.AllowUserInteraction, animations: {
//            selectedButton.backgroundColor = UIColor.whiteColor()
//            selectedButton.alpha = 0.7
//            }, completion: { finished in
//                UIView.animateWithDuration(0.2, delay: 0.0, options: UIViewAnimationOptions.Autoreverse | UIViewAnimationOptions.Repeat | UIViewAnimationOptions.CurveEaseIn | UIViewAnimationOptions.AllowUserInteraction, animations: {
//                    selectedButton.alpha = 0.5
//                    }, completion: nil)
//            }
//        )
//    }
    
    @IBAction func searchPressed(sender: UIButton) {
        if searchable == true {
            searchable = false;
            searchButton.backgroundColor = UIColor.clearColor()
            searchButton.setTitle("Stopped Searching", forState: UIControlState.Normal)
            searchButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            searchButton.layer.removeAllAnimations()
            manager.stopScanningForBeans_error(nil);
            
        }else{
            searchable = true;
            searchButton.setTitle("Searching...", forState: UIControlState.Normal)
            searchButton.backgroundColor = UIColor.whiteColor()
            searchButton.setTitleColor(blueColor, forState: UIControlState.Normal)
            searchButton.alpha = 1.0
            searchAnimation()
            manager.startScanningForBeans_error(nil);
        }
        
        
    }
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        manager = PTDBeanManager(delegate: self)
        
        searchButton.layer.cornerRadius = searchButton.bounds.size.height / 2
        searchButton.layer.borderColor = UIColor.whiteColor().CGColor
        searchButton.layer.borderWidth = 2
        
        if connectedBeans.count > 0{
            goButton.enabled = true
            goButton.alpha = 1.0
            
            searchable = false
            searchButton.backgroundColor = UIColor.clearColor()
            searchButton.setTitle("Stopped Searching", forState: UIControlState.Normal)
            searchButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            searchButton.layer.removeAllAnimations()
            manager.stopScanningForBeans_error(nil)
            
            print("Here you are back!")
            print("Beans cout :::: \(beans.count)")
            
            for var i = 0; i < beans.count; i += 1{
                
                print("already connected beans name : \(beans[i])")
            
                beanButtons.append(UIButton(frame:CGRectMake(CGFloat(screenSize.width * buttonPosition[i].0), CGFloat(screenSize.height * buttonPosition[i].1), 100, 100)))
                
                beanButtons[i].setTitle("\(beans[i].name)",forState:UIControlState.Normal)
                beanButtons[i].setTitleColor(UIColor.blackColor(), forState:UIControlState.Normal)
                beanButtons[i].backgroundColor = UIColor.greenColor()
                beanButtons[i].layer.borderWidth = 0.0
                beanButtons[i].alpha = 1.0
                beanButtons[i].addTarget(self, action: "beanAction:",  forControlEvents: UIControlEvents.TouchUpInside)
                beanButtons[i].layer.cornerRadius = beanButtons[i].bounds.size.height / 2
                self.view.addSubview(beanButtons[i])
            }

        }else {
            goButton.enabled = false
            goButton.alpha = 0.6
            
            searchable = true
            searchButton.setTitle("Searching...", forState: UIControlState.Normal)
            searchButton.backgroundColor = UIColor.whiteColor()
            searchButton.setTitleColor(blueColor, forState: UIControlState.Normal)
            searchButton.alpha = 1.0
            searchAnimation()
            manager.startScanningForBeans_error(nil)
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if (connectedBeans.count != 0){
            let playView = segue.destinationViewController as! PlayViewController
            
            // Pass the selected object to the new view controller.
            
            playView.connectedBeans = self.connectedBeans
            //println(self.connectedBean!.name)
            manager.stopScanningForBeans_error(nil)
            
            // webView.data = self.dataArray.objectAtIndex(indexPath.row) // get data by index and pass it to second view controller
            
        }
    }


}
