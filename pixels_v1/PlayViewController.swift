//
//  PlayViewController.swift
//  pixels_v1
//
//  Created by Soohyun Christine Park on 2015. 4. 28..
//  Copyright (c) 2015년 SP. All rights reserved.
//

import UIKit
import WebKit

protocol PlayViewControllerDelegate {
    func disconnect(bean: PTDBean)
}


class PlayViewController: UIViewController, PTDBeanDelegate, UIWebViewDelegate, WKUIDelegate {

    // Bean Stuff
    //var connectedBean: PTDBean?
    var delegate : PlayViewControllerDelegate!
    var connectedBeans: [PTDBean] = []

    let maxConnection = 4
    

    
    // UI Stuff
    @IBOutlet weak var myWebView: UIWebView!
//    @IBOutlet var containerView : UIView! = nil
//    var webView: WKWebView?
    //var webView: WKWebView?
    @IBOutlet weak var myPixel: UILabel!
    var myPixels : [Pixel] = []
    //var dragGesture: [UIPanGestureRecognizer] = []
    var dragStartPositionRelativeToCenter0 : CGPoint?
    var dragStartPositionRelativeToCenter1 : CGPoint?
    var dragStartPositionRelativeToCenter2 : CGPoint?
    var dragStartPositionRelativeToCenter3 : CGPoint?
    //var dragStartPositionRelativeToCenter : [CGPoint] = [4]
    var prevColor: [UIColor] = []
    var selectedAction: String = ""
    @IBOutlet weak var menuContainer: UIView!
    @IBOutlet weak var cancel_bt: UIButton!
    @IBOutlet weak var exit_bt: UIButton!
    
    var receivedColor :UIColor?
    
    override func loadView() {
        super.loadView()
//        self.webView = WKWebView()
//        //self.containerView = self.webView
//        self.containerView.addSubview(self.webView!)
    }
   
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    
        menuContainer.transform.tx = 0
        menuContainer.transform.ty = menuContainer.frame.height
        menuContainer.alpha = 0.0
    
    }
 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    
//        if (NSClassFromString("WKWebView") != nil) {
//            // Use WebKit
//        } else {
//            // Fallback on UIWebView
//        }

        
        cancel_bt.layer.cornerRadius = cancel_bt.bounds.size.height / 2
        exit_bt.layer.cornerRadius = exit_bt.bounds.size.height / 2
        
        let longGesture: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: "longPressed:")
        longGesture.minimumPressDuration = 0.7
        self.myWebView.addGestureRecognizer(longGesture)
        self.view.addGestureRecognizer(longGesture)
        
        // Create an URL object with the above path:
        let url = NSURL(string: "http://a.parsons.edu/~parks566/Playground/playground.html") // The html cannot be nil.
        
        // Create a request object with the url object:
        let request = NSURLRequest(URL: url!) // The URL cannot be nil too.
        
        // Tell the Web view to load the url request object:
        self.myWebView.loadRequest(request)
        
        for var index:Int = 0 ; index < connectedBeans.count ;index += 1 {
            myPixels.append(Pixel(frame: CGRectMake(CGFloat(arc4random_uniform(UInt32(self.myWebView.bounds.width - 55))), CGFloat(arc4random_uniform(UInt32(self.myWebView.bounds.height - 55))), 30, 30)))
            
            self.view.addSubview(myPixels[index])
            
            print("myPixels - \(index) : \(myPixels[index])")
            
            connectedBeans[index].delegate = self
            connectedBeans[index].setLedColor(UIColor.whiteColor())
            prevColor.append(UIColor.whiteColor())
            getPixelColorAtPoint( index, point: myPixels[index].center)
        }
        
        
        
        var updateTimer = NSTimer.scheduledTimerWithTimeInterval(0.2, target: self, selector: "checkColor", userInfo: nil, repeats: true)
        
        
        myWebView.stringByEvaluatingJavaScriptFromString("currentColors(\"ffffff\");")

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Webkit webview
    
//    func userContentController(userContentController: WKUserContentController,didReceiveScriptMessage message: WKScriptMessage) {
//        
//        println("Message :: \(message)")
//        if(message.name == "callbackHandler") {
//            println("JavaScript is sending a message \(message.body)")
//        }
//        
//    }
    

    // MARK : PIXELS
    
    
    func longPressed(sender:UILongPressGestureRecognizer){
        
        
        if sender.state == UIGestureRecognizerState.Began {
            print("began")
        }else if sender.state == UIGestureRecognizerState.Ended {
            
            UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
                self.menuContainer.transform.ty = 0
                self.menuContainer.alpha = 1.0
            }, completion: nil)
           
           
            print("end")
        }
        
    }
    
    @IBAction func cancelClicked(sender: UIButton) {
        
        UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
            self.menuContainer.transform.ty = self.menuContainer.frame.height
            self.menuContainer.alpha = 0.0
            }, completion: nil)
    
    }
    
    @IBAction func exitClicked(sender: UIButton) {
    
    
    }
    
    
    func checkColor(){
       // connectedBean?.readLedColor()
        
        for var index:Int = 0 ; index < myPixels.count ;index += 1 {
            getPixelColorAtPoint( index, point: myPixels[index].center)
        }
        
        
        
    }
    
    // MARK: Bean
    
    
    func bean(bean: PTDBean!, didUpdateLedColor color: UIColor!) {
        //println("HEREEEEEEEEEEEEEEE ::  \(color.CGColor)")
        
        
    }
    
    func bean(bean: PTDBean!, serialDataReceived data: NSData!) {
        
        print(stringRepresentation(data))
        let fullData: String = stringRepresentation(data)
        let typeOfData: String = (fullData as NSString).substringToIndex(1)
        
        if typeOfData == "A" {
            
            var dataSet = fullData.componentsSeparatedByString(",")
            dataSet[0] = (dataSet[0] as NSString).substringFromIndex(1)
            
            if let i = connectedBeans.indexOf(bean){
            
                if let n = NSNumberFormatter().numberFromString(dataSet[0]) {
                    let f = CGFloat(n)
                    if f > 0 && myPixels[i].center.x + myPixels[i].frame.width / 2 + 1 < self.view.frame.width{
                        //myPixels[i].center.x = myPixels[i].center.x + 1
                        UIView.animateWithDuration(0.2, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
                            self.myPixels[i].transform.tx = f * 0.5
                            }, completion: nil)
                        
                    }else if f > 0 && myPixels[i].center.x + myPixels[i].frame.width / 2 + 1 >= self.myWebView.frame.width{
                        myPixels[i].center.x = 0 - myPixels[i].frame.width
                        
                    }else if f < 0 && myPixels[i].center.x - myPixels[i].frame.width / 2 - 1 < 0{
                        myPixels[i].center.x = self.myWebView.frame.width + myPixels[i].frame.width
                        
                    }else if f < 0 && myPixels[i].center.x - myPixels[i].frame.width / 2 - 1 >= 0{
                        //myPixels[i].center.x = myPixels[i].center.x - 1
                        UIView.animateWithDuration(0.2, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
                            self.myPixels[i].transform.tx = f * 0.5
                            }, completion: nil)
                    }
                }
                if let n = NSNumberFormatter().numberFromString(dataSet[1]) {
                    let f = CGFloat(n)
                    if f > 0 && myPixels[i].center.y + myPixels[i].frame.height / 2 + 1 < self.view.frame.height{
                        //myPixels[i].center.y = myPixels[i].center.y + 1
                        UIView.animateWithDuration(0.2, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
                            self.myPixels[i].transform.ty = f * 0.5
                            }, completion: nil)
                        
                    }else if f > 0 && myPixels[i].center.y + myPixels[i].frame.height / 2 + 1 >= self.myWebView.frame.height{
                        myPixels[i].center.y = 0 - myPixels[i].frame.height
                        
                    }else if f < 0 && myPixels[i].center.y - myPixels[i].frame.height / 2 - 1 < 0{
                        myPixels[i].center.y = self.myWebView.frame.height + myPixels[i].frame.height
                        
                    }else if f < 0 && myPixels[i].center.y - myPixels[i].frame.height / 2 - 1 >= 0{
                        //myPixels[i].center.y = myPixels[i].center.y - 1
                        UIView.animateWithDuration(0.2, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
                            self.myPixels[i].transform.ty = f * 0.5
                            }, completion: nil)
                        
                    }
                }
                
            }else{}

        
        }else{
            
            receivedColor = colorWithHexString(fullData)
            
            if let i = connectedBeans.indexOf(bean){
                
                myPixels[i].backgroundColor = receivedColor
                
                var jsString = "coloring(\"\(stringRepresentation(data))\");"
                
                
                
                let posX = myPixels[i].center.x / self.view.frame.width
                let posY = myPixels[i].center.y / self.view.frame.height
                
                myWebView.stringByEvaluatingJavaScriptFromString("coloring(\"\(stringRepresentation(data))\", \"\(posX)\", \"\(posY)\");")
                
            }else {}
        
        }
        
    
        
    }
    
    func stringRepresentation(receivedData: NSData)->String {
        
        //Write new received data to the console text view
        
        //convert data to string & replace characters we can't display
        let dataLength:Int = receivedData.length
        var data = [UInt8](count: dataLength, repeatedValue: 0)
        
        receivedData.getBytes(&data, length: dataLength)
        
        for index in 0..<dataLength {
            if (data[index] <= 0x1f) || (data[index] >= 0x80) { //null characters
                if (data[index] != 0x9)       //0x9 == TAB
                    && (data[index] != 0xa)   //0xA == NL
                    && (data[index] != 0xd) { //0xD == CR
                        data[index] = 0xA9
                }
                
            }
        }
        
        let newString = NSString(bytes: &data, length: dataLength, encoding: NSUTF8StringEncoding)
        
        return newString! as String
        
    }
    
    func colorWithHexString (hex:String) -> UIColor {
        var cString:String = hex.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet() as NSCharacterSet).uppercaseString
        
        if (cString.hasPrefix("#")) {
            cString = cString.substringFromIndex(cString.startIndex.advancedBy(1))
        }
        
        if (cString.characters.count != 6) {
            return UIColor.grayColor()
        }
        
        var rgbValue:UInt32 = 0
        NSScanner(string: cString).scanHexInt(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    func getPixelColorAtPoint(index: Int, point:CGPoint)->UIColor
    {
        let pixel = UnsafeMutablePointer<CUnsignedChar>.alloc(4)
        var colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.PremultipliedLast.rawValue)
        let context = CGBitmapContextCreate(pixel, 1, 1, 8, 4, colorSpace, CGImageAlphaInfo.PremultipliedLast.rawValue)
        
        CGContextTranslateCTM(context, -point.x, -point.y)
        self.myWebView!.layer.renderInContext(context!)
        
        var r:CGFloat = CGFloat(pixel[0])/255.0
        var g:CGFloat = CGFloat(pixel[1])/255.0
        var b:CGFloat = CGFloat(pixel[2])/255.0
        var a:CGFloat = CGFloat(pixel[3])/255.0
        
        
        var color:UIColor = UIColor(red: r, green: g, blue: b, alpha: 1.0)
        
        pixel.dealloc(4)
        
        
        myPixels[index].backgroundColor = color
        
        //println(color)
        
        //sendColor((UInt8(CGFloat(pixel[0])/255.0)), green: (UInt8(CGFloat(pixel[1])/255.0)), blue: (UInt8(CGFloat(pixel[2])/255.0)))
        
        if prevColor[index] == color {}else{
            //sendColor((UInt8(255.0 * Float(r))), green: (UInt8(255.0 * Float(g))), blue: (UInt8(255.0 * Float(b))))
            
            connectedBeans[index].setLedColor(color)
//            println("\(color)")
            prevColor[index] = color
            
        }
        
        return color
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        //delegate.disconnect(connectedBean!)
        
        if (connectedBeans.count != 0){
            let searchView = segue.destinationViewController as! SearchingViewController
            
            // Pass the selected object to the new view controller.
            
            searchView.connectedBeans = self.connectedBeans
            searchView.beans = self.connectedBeans
            searchView.searchable = false
            
        }
    }


}
