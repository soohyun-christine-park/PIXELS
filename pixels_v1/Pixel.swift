//
//  Pixel.swift
//  pixels_v1
//
//  Created by Soohyun Christine Park on 2015. 5. 10..
//  Copyright (c) 2015년 SP. All rights reserved.
//

import Foundation

class Pixel : UILabel
{
    var dragStartPositionRelativeToCenter : CGPoint?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
//        self.userInteractionEnabled = true
//        
//        addGestureRecognizer(UIPanGestureRecognizer(target: self, action: "movePointer:"))
//        
//        self.text = ""
//        self.textAlignment = NSTextAlignment.Center
//        self.layer.cornerRadius = 0 //45
//        self.backgroundColor = UIColor.blackColor()
//        self.layer.borderColor = UIColor.whiteColor().CGColor
//        self.layer.borderWidth = 7
        
    }
    
    override init(frame:CGRect) {
        super.init(frame:frame)
        
        self.userInteractionEnabled = true
        
        addGestureRecognizer(UIPanGestureRecognizer(target: self, action: "movePointer:"))
        
        self.text = ""
        self.textAlignment = NSTextAlignment.Center
        self.layer.cornerRadius = 0 //45
        self.backgroundColor = UIColor.blackColor()
        self.layer.borderColor = UIColor.whiteColor().CGColor
        self.layer.borderWidth = 7
    }
    
    func movePointer(sender: UIPanGestureRecognizer!) {
    
        self.superview!.bringSubviewToFront(sender.view!)
        
        print(sender)
        
        if sender.state == UIGestureRecognizerState.Began {
            let locationInView = sender.locationInView(self.superview!)
            
            self.dragStartPositionRelativeToCenter = CGPoint(x: locationInView.x - sender.view!.center.x, y: locationInView.y - sender.view!.center.y)
            sender.view!.layer.shadowOffset = CGSize(width: 0, height: 20)
            sender.view!.layer.shadowOpacity = 0.3
            sender.view!.layer.shadowRadius = 6
            
            return
        }
        
        if sender.state == UIGestureRecognizerState.Ended {
            dragStartPositionRelativeToCenter = nil
            
            sender.view!.layer.shadowOffset = CGSize(width: 0, height: 3)
            sender.view!.layer.shadowOpacity = 0.5
            sender.view!.layer.shadowRadius = 2
            
            return
        }
        
        let locationInView = sender.locationInView(self.superview!)
        
        UIView.animateWithDuration(0.1) {
            sender.view!.center = CGPoint(x: locationInView.x - self.dragStartPositionRelativeToCenter!.x,
                y: locationInView.y - self.dragStartPositionRelativeToCenter!.y)
        }
    
    }
}