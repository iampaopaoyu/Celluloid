//
//  AttachView.swift
//  Celluloid
//
//  Created by Mango on 16/3/3.
//  Copyright © 2016年 Mango. All rights reserved.
//

import Foundation

public class AttachView: UIView {
    //MARK: Property
    let buttonWidth = CGFloat(32)
    let halfButtonWidth = CGFloat(16)
    
    public lazy var imageView:UIImageView = {
        let imageView = UIImageView(frame: self.bounds.insetBy(dx: self.halfButtonWidth, dy: self.halfButtonWidth))
        imageView.contentMode = .ScaleAspectFit
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.whiteColor().colorWithAlphaComponent(0.6).CGColor
        return imageView
    }()
    
    lazy var deleteButton: UIButton = {
        let button = UIButton(type: .Custom)
        button.frame = CGRect(x: self.bounds.width - self.buttonWidth, y: 0, width: self.buttonWidth, height: self.buttonWidth)
        button.setImage(UIImage(asset: .Btn_icon_sticker_delete_normal), forState: .Normal)
        button.addTarget(self, action: #selector(removeSelf), forControlEvents: .TouchUpInside)
        return button
    }()
    
    lazy var resizeButton: UIButton = {
        let button = UIButton(type: .Custom)
        button.frame = CGRect(x: self.bounds.width - self.buttonWidth, y: self.bounds.height - self.buttonWidth, width: self.buttonWidth, height: self.buttonWidth)
        button.setImage(UIImage(asset: .Btn_icon_sticker_edit_normal), forState: .Normal)
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(rotateAndResize(_:)))
        button.addGestureRecognizer(panGesture)
        
        return button
    }()
    
    public var hideButtonEnable:Bool = false {
        didSet {
            imageView.layer.borderWidth = hideButtonEnable ? 0 : 1
            imageView.layer.borderColor = UIColor.whiteColor().colorWithAlphaComponent(0.6).CGColor
            UIView.animateWithDuration(0.3, animations: {
                for view in self.subviews {
                    if let button = view as? UIButton {
                        button.hidden = self.hideButtonEnable
                    }
                }
            })
        }
    }
    
    //MARK: init
    private func commonInit() {
        self.addSubview(imageView)
        self.addSubview(deleteButton)
        self.addSubview(resizeButton)
        
        let moveGesture = UIPanGestureRecognizer(target: self, action: #selector(move(_:)))
        self.addGestureRecognizer(moveGesture)
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        //set frame.width & bounds.width is different because of the transform
        deleteButton.frame = CGRect(x: bounds.width - self.buttonWidth, y: 0, width: self.buttonWidth, height: self.buttonWidth)
        resizeButton.frame = CGRect(x: bounds.width - self.buttonWidth, y: bounds.height - self.buttonWidth, width: self.buttonWidth, height: self.buttonWidth)
        imageView.frame = self.bounds.insetBy(dx: self.halfButtonWidth, dy: self.halfButtonWidth)
    }
    
}

//MARK: Action
extension AttachView{
    @objc func removeSelf() {
        UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.3, options: [],
            animations: {
                self.transform = CGAffineTransformMakeScale(0.5, 0.5)
                self.alpha = 0
            },
            completion: { finish in
                self.removeFromSuperview()
            }
        )
    }
    
    @objc func rotateAndResize (gestureRecognizer:UIPanGestureRecognizer) {
        
        struct Static {
            static var deltaAngle = CGFloat()
            static var initialBounds = CGRect.zero
            static var initialDistance = CGFloat()
        }
        
        let touchLocation = gestureRecognizer.locationInView(self.superview!)
        let center = self.center
        
        if gestureRecognizer.state == .Began {
            Static.deltaAngle = atan2(touchLocation.y - center.y, touchLocation.x - center.x) - self.transform.angle
            Static.initialBounds = self.bounds
            Static.initialDistance = CGPointGetDistance(center, touchLocation)
        }else if gestureRecognizer.state == .Changed {
            let ang = atan2(touchLocation.y - center.y, touchLocation.x - center.x)
            let angleDiff = Static.deltaAngle - ang
            self.transform = CGAffineTransformMakeRotation(-angleDiff)
            
            //Finding scale between current touchPoint and previous touchPoint
            let scale = CGPointGetDistance(center, touchLocation)/Static.initialDistance;
            let scaleRect = Static.initialBounds.scaled(scale, scale)
            
            if scaleRect.width >= (buttonWidth + 20) && scaleRect.size.height >= (buttonWidth + 20) {
                self.bounds = scaleRect
            }
            self.layoutIfNeeded()
        }else{
            //do nothing
        }
    }
    
    @objc func move (gestureRecognizer: UIPanGestureRecognizer) {
        struct Static {
            static var touchLocation = CGPoint.zero
            static var beginningCenter = CGPoint.zero
            static var beginningPoint = CGPoint.zero
        }
        
        func makeCenter() -> CGPoint {
            return CGPoint(x: Static.beginningCenter.x + (Static.touchLocation.x - Static.beginningPoint.x), y: Static.beginningCenter.y+(Static.touchLocation.y-Static.beginningPoint.y))
        }
        
        Static.touchLocation = gestureRecognizer.locationInView(self.superview!)
        if gestureRecognizer.state == .Began {
            Static.beginningCenter = self.center
            Static.beginningPoint = Static.touchLocation
            self.center = makeCenter()
        }else if gestureRecognizer.state == .Changed || gestureRecognizer.state == .Ended {
            self.center = makeCenter()
        }
    }
}





