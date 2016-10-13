//
// Created by Zhishan Zhang on 7/14/16.
// Copyright (c) 2016 code4fun. All rights reserved.
//
import UIKit
import QuartzCore

// default diameter
let ZZSNotificationHubDefaultDiameter: CGFloat = 30
private let kCountMagnitudeAdaptationRatio = 0.3

// pop values
private let kPopStartRatio: CGFloat = 0.85
private let kPopOutRatio: CGFloat = 1.05
private let kPopInRatio: CGFloat = 0.95

// blink values
private let kBlinkDuration = 0.1
private let kBlinkAlpha: CGFloat = 0.1

// bump values
private let kFirstBumpDistance = 8.0
private let kBumpTimeSeconds = 0.13
private let SECOND_BUMP_DIST = 4.0
private let kBumpTimeSeconds2 = 0.1

class ZZSView : UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var isUserChangingBackgroundColor: Bool = false {
        didSet {
            if isUserChangingBackgroundColor {
                self.backgroundColor = backgroundColor
            }
            else {
                self.backgroundColor = UIColor.clear
            }
        }
    }

}

class ZZSNotificationHub {

    var curOrderMagnitude: Int?
    var countLabel: UILabel!
    var redCircle: ZZSView!
    var initialCenter: CGPoint?
    var baseFrame: CGRect!
    var initialFrame: CGRect!
    var isIndeterminateMode: Bool!
    var alpha: CGFloat = 0
    var count: Int = 0 {
        didSet {
            if count != 0 {
                countLabel.text = "\(self.count)"
                self.checkZero()
                self.expandToFitLargerDigits()
            }
            
        }
    }

    init(view: UIView) {
        self.setView(view, andCount: 0)
    }
    
    init(barButtonItem: UIBarButtonItem) {
        self.setView(barButtonItem.value(forKey: "view") as! UIView, andCount: 0)
        self.scaleCircleSizeBy(0.7)
        self.moveCircleByX(-5.0, Y: 0)
    }

    // give this a view and an initial count (0 hides the notification circle)
    // and it will make a hub for you
    func setView(_ view: UIView, andCount startCount: Int) {
        curOrderMagnitude = 0
        let frame: CGRect = view.frame
        isIndeterminateMode = false
        redCircle = ZZSView()
        redCircle.isUserInteractionEnabled = false
        redCircle.isUserChangingBackgroundColor = true
        redCircle.backgroundColor = UIColor.red
        countLabel = UILabel(frame: redCircle.frame)
        countLabel.isUserInteractionEnabled = false
        self.count = startCount
        countLabel.textAlignment = NSTextAlignment.center
        countLabel.textColor = UIColor.white
        countLabel.backgroundColor = UIColor.clear
        self.setCircleAtFrame(CGRect(x: frame.size.width - (ZZSNotificationHubDefaultDiameter * 2 / 3), y: -ZZSNotificationHubDefaultDiameter / 3, width: ZZSNotificationHubDefaultDiameter, height: ZZSNotificationHubDefaultDiameter))
        view.addSubview(redCircle)
        view.addSubview(countLabel)
        view.bringSubview(toFront: redCircle)
        view.bringSubview(toFront: countLabel)
        self.checkZero()
    }

    // set the frame of the notification circle relative to the button
    func setCircleAtFrame(_ frame: CGRect) {
        redCircle.frame = frame
        initialCenter = CGPoint(x: frame.origin.x + frame.size.width / 2, y: frame.origin.y + frame.size.height / 2)
        baseFrame = frame
        initialFrame = frame
        countLabel.frame = redCircle.frame
        redCircle.layer.cornerRadius = frame.size.height / 2
        countLabel.font = UIFont(name: "HelveticaNeue", size: frame.size.width / 2)
        self.expandToFitLargerDigits()
    }

    // moves the circle by x amount on the x axis and y amount on the y axis
    func moveCircleByX(_ x: CGFloat, Y y: CGFloat) {
        var frame: CGRect = redCircle.frame
        frame.origin.x += x
        frame.origin.y += y
        self.setCircleAtFrame(frame)
    }

    // changes the size of the circle. setting a scale of 1 has no effect
    func scaleCircleSizeBy(_ scale: CGFloat) {
        let fr = initialFrame
        let width = (fr?.size.width)! * scale
        let height = (fr?.size.height)! * scale
        let wdiff = ((fr?.size.width)! - width) / 2
        let hdiff = ((fr?.size.height)! - height) / 2
        let frame = CGRect(x: (fr?.origin.x)! + wdiff, y: (fr?.origin.y)! + hdiff, width: width, height: height)
        self.setCircleAtFrame(frame)
    }

    // change the color of the notification circle
    func setCircleColor(_ circleColor: UIColor, labelColor: UIColor) {
        redCircle.isUserChangingBackgroundColor = true
        redCircle.backgroundColor = circleColor
        countLabel.textColor = labelColor
    }

    func hideCount() {
        countLabel.isHidden = true
        isIndeterminateMode = true
    }

    func showCount() {
        isIndeterminateMode = false
        self.checkZero()
    }

    // MARK: - ATTRIBUTES
    // increases count by 1
    func increment() {
        self.incrementBy(1)
    }

    // increases count by amount
    func incrementBy(_ amount: Int) {
        self.count += amount
    }

    // decreases count
    func decrement() {
        self.decrementBy(1)
    }

    // decreases count by amount
    func decrementBy(_ amount: Int) {
        if amount >= self.count {
            self.count = 0
            return
        }
        self.count -= amount
    }


    //%% set the font of the label
    func setCountLabelFont(_ font: UIFont) {
        countLabel.font = font
    }

    func countLabelFont() -> UIFont {
        return countLabel.font
    }

    // MARK: - ANIMATION
    // animation that resembles facebook's pop
    func pop() {
        let height = baseFrame.size.height
        let width = baseFrame.size.width
        let pop_start_h = height * kPopStartRatio
        let pop_start_w = width * kPopStartRatio
        let time_start = 0.05
        let pop_out_h = height * kPopOutRatio
        let pop_out_w = width * kPopOutRatio
        let time_out = 0.2
        let pop_in_h = height * kPopInRatio
        let pop_in_w = width * kPopInRatio
        let time_in = 0.05
        let pop_end_h = height
        let pop_end_w = width
        let time_end = 0.05
        
        let startSize: CABasicAnimation = CABasicAnimation(keyPath: "cornerRadius")
        startSize.duration = time_start
        startSize.beginTime = 0
        startSize.fromValue = pop_end_h/2
        startSize.toValue = pop_start_h/2
        startSize.isRemovedOnCompletion = false
        
        let outSize: CABasicAnimation = CABasicAnimation(keyPath: "cornerRadius")
        outSize.duration = time_out
        outSize.beginTime = time_start
        outSize.fromValue = startSize.toValue
        outSize.toValue = pop_out_h/2
        outSize.isRemovedOnCompletion = false
        
        let inSize: CABasicAnimation = CABasicAnimation(keyPath: "cornerRadius")
        inSize.duration = time_in
        inSize.beginTime = time_start+time_out
        inSize.fromValue = outSize.toValue
        inSize.toValue = pop_in_h/2
        inSize.isRemovedOnCompletion = false
        
        let endSize: CABasicAnimation = CABasicAnimation(keyPath: "cornerRadius")
        endSize.duration = time_end
        endSize.beginTime = time_in+time_out+time_start
        endSize.fromValue = inSize.toValue
        endSize.toValue = pop_end_h/2
        endSize.isRemovedOnCompletion = false
        
        let group: CAAnimationGroup = CAAnimationGroup()
        group.duration = time_start+time_out+time_in+time_end
        group.animations = [startSize,outSize,inSize,endSize]
        
        redCircle.layer.add(group, forKey: nil)
        
        UIView.animate(withDuration: time_start, animations: {
            var frame: CGRect = self.redCircle.frame
            let center: CGPoint = self.redCircle.center
            frame.size.height = pop_start_h
            frame.size.width = pop_start_w
            self.redCircle.frame = frame
            self.redCircle.center = center

        }, completion: { (complete: Bool) in
            UIView.animate(withDuration: time_out, animations: {
                var frame: CGRect = self.redCircle.frame
                let center: CGPoint = self.redCircle.center
                frame.size.height = pop_out_h
                frame.size.width = pop_out_w
                self.redCircle.frame = frame
                self.redCircle.center = center

            }, completion: { (complete: Bool) in
                UIView.animate(withDuration: time_in, animations: {
                    var frame: CGRect = self.redCircle.frame
                    let center: CGPoint = self.redCircle.center
                    frame.size.height = pop_in_h
                    frame.size.width = pop_in_w
                    self.redCircle.frame = frame
                    self.redCircle.center = center

                }, completion: { (complete: Bool) in
                    UIView.animate(withDuration: time_end, animations: {
                        var frame: CGRect = self.redCircle.frame
                        let center: CGPoint = self.redCircle.center
                        frame.size.height = pop_end_h
                        frame.size.width = pop_end_w
                        self.redCircle.frame = frame
                        self.redCircle.center = center

                    })

                })

            })

        })
    }

    // animation that flashes on an off
    func blink() {
        self.alpha = kBlinkAlpha
        UIView.animate(withDuration: kBlinkDuration, animations: {
            self.alpha = 1
        }, completion: { (complete: Bool) in
            UIView.animate(withDuration: kBlinkDuration, animations: {
                self.alpha = kBlinkAlpha

            }, completion: { (complete: Bool) in
                UIView.animate(withDuration: kBlinkDuration, animations: {
                    self.alpha = 1

                })

            })

        })
    }

    // animation that jumps similar to OSX dock icons
    func bump() {
        if !initialCenter!.equalTo(redCircle.center) {
            // canel previous animation
        }
        self.bumpCenterY(0)
        UIView.animate(withDuration: kBumpTimeSeconds, animations: {
            self.bumpCenterY(kFirstBumpDistance)

        }, completion: { (complete: Bool) in
            UIView.animate(withDuration: kBumpTimeSeconds, animations: {	self.bumpCenterY(0)

            }, completion: { (complete: Bool) in
                UIView.animate(withDuration: kBumpTimeSeconds2, animations: {	self.bumpCenterY(SECOND_BUMP_DIST)

                }, completion: { (complete: Bool) in
                    UIView.animate(withDuration: kBumpTimeSeconds2, animations: {	self.bumpCenterY(0)

                    })

                })

            })

        })
    }

    // MARK: - HELPERS
    // changes the Y origin of the notification circle
    func bumpCenterY(_ yVal: Double) {
        var center: CGPoint = redCircle.center
        center.y = initialCenter!.y - CGFloat(yVal)
        redCircle.center = center
        countLabel.center = center
    }

    func setAlpha(_ alpha: Double) {
        redCircle.alpha = CGFloat(alpha)
        countLabel.alpha = CGFloat(alpha)
    }

    // hides the notification if the value is 0
    func checkZero() {
        if self.count <= 0 {
            redCircle.isHidden = true
            countLabel.isHidden = true
        }
        else {
            redCircle.isHidden = false
            if !isIndeterminateMode {
                countLabel.isHidden = false
            }

        }
    }

    func expandToFitLargerDigits() {
        var orderOfMagnitude = 1
        if self.count != 0 {
            orderOfMagnitude = Int(log10(CDouble(self.count)))
        }
        orderOfMagnitude = (orderOfMagnitude >= 2) ? orderOfMagnitude : 1
        var frame: CGRect = initialFrame
        frame.size.width = initialFrame.size.width * CGFloat((1 + kCountMagnitudeAdaptationRatio * Double(orderOfMagnitude - 1)))
        frame.origin.x = initialFrame.origin.x-(frame.size.width-initialFrame.size.width)/2
        redCircle.frame = frame
        initialCenter = CGPoint(x: frame.origin.x+frame.size.width/2, y: frame.origin.y+frame.size.height/2)
        baseFrame = frame
        countLabel.frame = redCircle.frame
        curOrderMagnitude = orderOfMagnitude
    }

}


