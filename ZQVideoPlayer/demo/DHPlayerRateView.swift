//
//  DHPlayerRateView.swift
//  ZQVideoPlayer
//
//  Created by 雷丹 on 2019/8/19.
//  Copyright © 2019 CZQ. All rights reserved.
//

import UIKit


class DHPlayerRateView: NSObject {
    /// 播放速递
    static func show(superview:UIView,isLandscape:Bool = false,completionHandler:@escaping((_ rate:Float)->Void))  {
        var subFrame = superview.bounds
        if isLandscape{
            subFrame = CGRect(x: 0, y: 0, width: kHeight, height: kWidth)
        }
        
        ///
        let backgroundView = DHButton(frame: subFrame)
        backgroundView.backgroundColor  = UIColor.black.withAlphaComponent(0.3)
        superview.addSubview(backgroundView)
        backgroundView.tag = 19950526
        backgroundView.dh_ButtonClick { (button) in
            backgroundView.removeFromSuperview()
        }
        
        ///
        var tempWidth = (subFrame.width-50)/4
        if isLandscape{
            tempWidth = 120
            subFrame = CGRect(x: kNaviBarHeight, y: backgroundView.frame.height-tempWidth-90, width: 200, height: 20)
        }else{
            subFrame = CGRect(x: 10, y: backgroundView.frame.height-tempWidth-70, width: 200, height: 20)
        }

        let titleLabel = UILabel(frame: subFrame)
        titleLabel.textColor = UIColor.white
        titleLabel.font = UIFont.systemFont(ofSize: isLandscape ? 18:15)
        titleLabel.text = "播放倍速"
        backgroundView.addSubview(titleLabel)
        let rates = [0.5,1.0,1.5,2.0]
        for index in 0...3 {
            if isLandscape{
                subFrame = CGRect(x: CGFloat(index)*(tempWidth+10)+kNaviBarHeight, y: titleLabel.frame.maxY+20, width: tempWidth, height: tempWidth-20)
            }else{
                subFrame = CGRect(x: CGFloat(index)*(tempWidth+10)+10, y: titleLabel.frame.maxY+20, width: tempWidth, height: tempWidth-20)
            }
            let tempButton = DHButton(frame:subFrame)
            tempButton.setTitle("\(rates[index])X", for: .normal)
            tempButton.layer.cornerRadius = isLandscape ? 10:5
            tempButton.titleLabel?.font = UIFont.systemFont(ofSize: isLandscape ? 22:15)
            tempButton.backgroundColor = UIColor.black.withAlphaComponent(0.3)
            backgroundView.addSubview(tempButton)
            tempButton.dh_ButtonClick { (button) in
                completionHandler(Float(rates[index]))
                backgroundView.removeFromSuperview()
            }
        }
    }
    
    /// 删除HUD
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
}
