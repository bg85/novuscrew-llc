//
//  ProgressView.swift
//  loyaltyApp
//
//  Created by Barbara Gonzalez on 12/28/15.
//  Copyright © 2015 Barbara Gonzalez. All rights reserved.
//

import UIKit

class ProgressView: UIView {
    
    private let progressLayer: CAShapeLayer = CAShapeLayer()
    
    private var progressLabel: UILabel
    
    required init?(coder aDecoder: NSCoder) {
        progressLabel = UILabel()
        super.init(coder: aDecoder)
        createProgressLayer()
        createLabel()
    }
    
    override init(frame: CGRect) {
        progressLabel = UILabel()
        super.init(frame: frame)
        
        self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.7)
        createProgressLayer()
        createLabel()
    }
    
    func createLabel() {
        progressLabel = UILabel(frame: CGRectMake(0.0, 0.0, CGRectGetWidth(frame), 60.0))
        progressLabel.textColor = UIColor.lightTextColor()
        progressLabel.textAlignment = .Center
        progressLabel.text = "Loading ..."
        progressLabel.font = UIFont(name: "HelveticaNeue-Light", size: 40.0)
        progressLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(progressLabel)
        
        addConstraint(NSLayoutConstraint(item: self, attribute: .CenterX, relatedBy: .Equal, toItem: progressLabel, attribute: .CenterX, multiplier: 1.0, constant: -30.0))
        addConstraint(NSLayoutConstraint(item: self, attribute: .CenterY, relatedBy: .Equal, toItem: progressLabel, attribute: .CenterY, multiplier: 1.0, constant: -105.0))
    }
    
    private func createProgressLayer() {
        //let startAngle = CGFloat(M_PI_2)
        //let endAngle = CGFloat(M_PI)
        //let centerPoint = CGPointMake(CGRectGetWidth(frame)/2 , CGRectGetHeight(frame)/2)
        
        //let gradientMaskLayer = gradientMask()
//        progressLayer.path = UIBezierPath(arcCenter:centerPoint, radius: CGRectGetWidth(frame)/2 - 100.0, startAngle:startAngle, endAngle:endAngle, clockwise: true).CGPath
        progressLayer.path = UIBezierPath(rect: CGRectMake(CGRectGetWidth(frame)/2 - 125, CGRectGetHeight(frame)/2 - 200, 10, 10)).CGPath
        progressLayer.backgroundColor = UIColor.clearColor().CGColor
        progressLayer.fillColor = nil
        progressLayer.strokeColor = UIColor.clearColor().CGColor
        progressLayer.lineWidth = 20.0
        progressLayer.strokeStart = 0.0
        //progressLayer.strokeEnd = 0.0
        
        let image = CALayer()
        image.frame = CGRectMake(CGRectGetWidth(frame)/2 - 155, CGRectGetHeight(frame)/2 - 200, 50, 50)
        image.contents = UIImage(named: "brownie")?.CGImage
        progressLayer.addSublayer(image)
        
//        gradientMaskLayer.mask = progressLayer
        layer.addSublayer(progressLayer)
        
        //drawCircle()
    }
    
    private func gradientMask() -> CAGradientLayer {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.backgroundColor = UIColor.clearColor().CGColor
        
        //let colorTop: AnyObject = UIColor.grayColor().CGColor //UIColor(red: 255.0/255.0, green: 213.0/255.0, blue: 63.0/255.0, alpha: 1.0).CGColor
        //let colorBottom: AnyObject = UIColor.redColor().CGColor //UIColor(red: 255.0/255.0, green: 198.0/255.0, blue: 5.0/255.0, alpha: 1.0).CGColor
        //let arrayOfColors: [AnyObject] = [colorTop, colorBottom]
        //gradientLayer.colors = arrayOfColors
        
        return gradientLayer
    }
    
    func hideProgressView() {
        progressLayer.strokeEnd = 0.0
        progressLayer.removeAllAnimations()
        progressLabel.text = ""
    }
    
    func animateProgressView() {
        let boundingRect = CGRectMake(CGRectGetWidth(frame)/2 - 125, CGRectGetHeight(frame)/2 - 125, 250, 250)
        
        let orbit = CAKeyframeAnimation()
        orbit.keyPath = "position";
        orbit.path = CGPathCreateWithEllipseInRect(boundingRect, nil)
        orbit.duration = 4;
        orbit.additive = true;
        orbit.repeatCount = HUGE;
        orbit.calculationMode = kCAAnimationPaced;
        orbit.rotationMode = kCAAnimationRotateAuto;
        
        progressLayer.addAnimation(orbit, forKey: "orbit")
    }
    
    private func drawCircle(){
        let gradientMaskLayer = gradientMask()
        let circleLayer = CAShapeLayer()
        circleLayer.path = CGPathCreateWithEllipseInRect(CGRectMake(CGRectGetWidth(frame)/2 - 115, CGRectGetHeight(frame)/2 - 115, 230, 230), nil)
        circleLayer.backgroundColor = UIColor.clearColor().CGColor
        circleLayer.fillColor = nil
        circleLayer.strokeColor = UIColor.blackColor().CGColor
        circleLayer.lineWidth = 3.0
        circleLayer.strokeStart = 0.0

        gradientMaskLayer.mask = circleLayer
        layer.addSublayer(gradientMaskLayer)
    }
}

