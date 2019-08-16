//
//  DHPlayerHUD.swift
//  albatross
//
//  Created by 雷丹 on 2019/8/16.
//  Copyright © 2019 CZQ. All rights reserved.
//

import UIKit

class DHPlayerHUD: NSObject {

    static func showVolume(progress:CGFloat,superview:UIView,fullScreenStatus:Bool = false)  {
        if (superview.viewWithTag(19950526) == nil) {
            var subFrame = CGRect(x: 0, y: 0, width: kWidth/2, height: 40)
            let backgroundView = UIView(frame: subFrame)
            backgroundView.tag = 19950526
            backgroundView.backgroundColor  = UIColor.black.withAlphaComponent(0.2)
            backgroundView.layer.cornerRadius = 5
            backgroundView.layer.masksToBounds = true
            backgroundView.center = superview.center
            superview.addSubview(backgroundView)
            ///
            subFrame = CGRect(x: 10, y: 10, width: 20, height: 20)
            let icon = UIImageView(frame: subFrame)
            icon.tag = 199505261
            backgroundView.addSubview(icon)
            if progress < 0.3 {
                icon.image = UIImage.init(named: "player_volume")
            }else if progress < 0.7 {
                icon.image = UIImage.init(named: "player_volume")
            }else  {
                icon.image = UIImage.init(named: "player_volume")
            }
            subFrame = CGRect(x: icon.frame.maxX+10, y: 18, width: backgroundView.frame.width-icon.frame.maxX-20, height: 4)
            let progressView = UIProgressView(frame: subFrame)
            progressView.backgroundColor = .clear
            progressView.trackTintColor = UIColor.black.withAlphaComponent(0.5)
            progressView.progressImage = UIImage.init(named: "player_progress")
            progressView.progress = Float(progress)
            progressView.tag = 199505262
            backgroundView.addSubview(progressView)
            
            if fullScreenStatus{
                backgroundView.transform = CGAffineTransform(rotationAngle: .pi/2)
            }
            
            
        }else{
            guard let backgroundView = superview.viewWithTag(19950526) else {return}
            guard let subview1 = backgroundView.viewWithTag(199505261) else {return}
            let icon:UIImageView = subview1 as! UIImageView
            if progress < 0.3 {
                icon.image = UIImage.init(named: "player_volume")
            }else if progress < 0.7 {
                icon.image = UIImage.init(named: "player_volume")
            }else  {
                icon.image = UIImage.init(named: "player_volume")
            }
            guard let subview2 = backgroundView.viewWithTag(199505262) else {return}
            let progressView:UIProgressView = subview2 as! UIProgressView
            progressView.progress = Float(progress)
        }
    }
    
    static func showBrightness(progress:CGFloat,superview:UIView,fullScreenStatus:Bool = false)  {
        if (superview.viewWithTag(19950526) == nil) {
            var subFrame = CGRect(x: 0, y: 0, width: kWidth/2, height: 40)
            let backgroundView = UIView(frame: subFrame)
            backgroundView.tag = 19950526
            backgroundView.backgroundColor  = UIColor.black.withAlphaComponent(0.2)
            backgroundView.layer.cornerRadius = 5
            backgroundView.layer.masksToBounds = true
            backgroundView.center = superview.center
            superview.addSubview(backgroundView)
            ///
            subFrame = CGRect(x: 10, y: 10, width: 20, height: 20)
            let icon = UIImageView(frame: subFrame)
            icon.tag = 199505261
            backgroundView.addSubview(icon)
            icon.image = UIImage.init(named: "player_liangdu")
            subFrame = CGRect(x: icon.frame.maxX+10, y: 18, width: backgroundView.frame.width-icon.frame.maxX-20, height: 4)
            let progressView = UIProgressView(frame: subFrame)
            progressView.backgroundColor = .clear
            progressView.trackTintColor = UIColor.black.withAlphaComponent(0.5)
            progressView.progressImage = UIImage.init(named: "player_progress")
            progressView.progress = Float(progress)
            progressView.tag = 199505262
            backgroundView.addSubview(progressView)
            if fullScreenStatus{
                backgroundView.transform = CGAffineTransform(rotationAngle: .pi/2)
            }
        }else{
            guard let backgroundView = superview.viewWithTag(19950526) else {return}
            let progressView:UIProgressView = backgroundView.viewWithTag(199505262) as! UIProgressView
            progressView.progress = Float(progress)
        }
    }

    static func showPlayerProgress(currentTime:CGFloat,totalTime:CGFloat,superview:UIView,fullScreenStatus:Bool = false)  {
        
        let current = DHPlayerHUD.formatPlayTime(secounds: TimeInterval(currentTime))
        let total = DHPlayerHUD.formatPlayTime(secounds: TimeInterval(currentTime))

        if (superview.viewWithTag(19950526) == nil) {
            var subFrame = CGRect(x: 0, y: 0, width: kWidth*3/4, height: 40)
            let backgroundView = UIView(frame: subFrame)
            backgroundView.tag = 19950526
            backgroundView.backgroundColor  = UIColor.black.withAlphaComponent(0.2)
            backgroundView.layer.cornerRadius = 5
            backgroundView.layer.masksToBounds = true
            backgroundView.center = superview.center
            superview.addSubview(backgroundView)
            superview.bringSubviewToFront(backgroundView)
            ///
            subFrame = CGRect(x: 10, y: 10, width: 70, height: 20)
            let label = UILabel(frame: subFrame)
            label.tag = 199505261
            backgroundView.addSubview(label)
            label.textColor = .white
            label.font = UIFont.systemFont(ofSize: 11)
            label.text = "\(current)/\(total)"
            ///
            subFrame = CGRect(x: label.frame.maxX+10, y: 18, width: backgroundView.frame.width-label.frame.maxX-20, height: 4)
            let progressView = UIProgressView(frame: subFrame)
            progressView.backgroundColor = .clear
            progressView.trackTintColor = UIColor.black.withAlphaComponent(0.5)
            progressView.progressImage = UIImage.init(named: "player_progress")
            progressView.progress = Float(currentTime/totalTime)
            progressView.tag = 199505262
            backgroundView.addSubview(progressView)
            if fullScreenStatus{
                backgroundView.transform = CGAffineTransform(rotationAngle: .pi/2)
            }
        }else{
            guard let backgroundView = superview.viewWithTag(19950526) else {return}
            superview.bringSubviewToFront(backgroundView)

            guard let subview1 = backgroundView.viewWithTag(199505261) else {return}
            let label:UILabel = subview1 as! UILabel
            label.text = "\(current)/\(total)"
            guard let subview2 = backgroundView.viewWithTag(199505262) else {return}
            let progressView:UIProgressView = subview2 as! UIProgressView
            progressView.progress = Float(currentTime/totalTime)
        }
        
    }
    
    static func hidden(superview:UIView)  {
        UIView.animate(withDuration: 0.3, animations: {
            if  let backgroundView = superview.viewWithTag(19950526) {
                backgroundView.alpha = 0
            }
        }, completion: { (_) in
            if  let backgroundView = superview.viewWithTag(19950526) {
                backgroundView.removeFromSuperview()
            }
        })
    }
    
    //    格式化时间字符串
    static func formatPlayTime(secounds:TimeInterval)->String{
        if secounds.isNaN{return "00:00"}
        let m = Int(secounds / 60)
        let s = Int(secounds.truncatingRemainder(dividingBy: 60))
        let str = String(format: "%02d:%02d", m, s)
        return str
    }
}
