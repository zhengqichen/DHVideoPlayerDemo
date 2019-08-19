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
    static func show(superview:UIView,fullScreenStatus:Bool = false,completionHandler:@escaping((_ rate:Float)->Void))  {
        var subFrame = CGRect(x: 0, y: 0, width: kWidth/2, height: 40)
        let backgroundView = DHButton(frame: superview.bounds)
        backgroundView.backgroundColor  = UIColor.black.withAlphaComponent(0.2)
        superview.addSubview(backgroundView)
        backgroundView.dh_ButtonClick { (button) in
            backgroundView.removeFromSuperview()
        }
        ///
        let tempWidth = (kWidth-50)/4
        subFrame = CGRect(x: 10, y: superview.frame.height-tempWidth-20, width: 200, height: 20)
        let titleLabel = UILabel(frame: subFrame)
        titleLabel.textColor = UIColor.white
        titleLabel.font = UIFont.systemFont(ofSize: fullScreenStatus ? 18:15)
        titleLabel.text = "倍速"
        backgroundView.addSubview(titleLabel)
        let rates = [0.5,1.0,1.5,2.0]
        for index in 0...3 {
            subFrame = CGRect(x: CGFloat(index)*(tempWidth+10)+10, y: superview.frame.height-tempWidth+10, width: tempWidth, height: tempWidth-20)
            let tempButton = DHButton(frame:subFrame)
            tempButton.setTitle("\(rates[index])X", for: .normal)
            tempButton.layer.cornerRadius = fullScreenStatus ? 10:5
            tempButton.titleLabel?.font = UIFont.systemFont(ofSize: fullScreenStatus ? 22:15)
            tempButton.backgroundColor = UIColor.black.withAlphaComponent(0.7)
            tempButton.tag = 19950526 + index
            backgroundView.addSubview(tempButton)
            tempButton.dh_ButtonClick { (button) in
                completionHandler(Float(rates[index]))
                backgroundView.removeFromSuperview()
            }
        }
    }
}
