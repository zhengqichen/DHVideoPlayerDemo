//
//  DHPlayerView+Screen.swift
//  albatross
//
//  Created by 雷丹 on 2019/8/12.
//  Copyright © 2019 CZQ. All rights reserved.
//

import UIKit

extension DHPlayerView {

    //全屏视图切换按钮事件
    @objc func fullScreenBtnEvent(){
        fullScreenStatus ? quitFullScreen():fullScreen(isLeft: true)
    }

    /// 切换全屏视图后调用事件
    @objc func fullScreenTiggerAfter() {
        if fullScreenStatus {
            fullScreenStatus = false
            consoleBar.changeFullScreenButton(imageName: "player_full_screen")
        }else{
            fullScreenStatus = true
            consoleBar.changeFullScreenButton(imageName: "player_normal_screen")
        }
    }

    /// 判断屏幕滚动方向
    @objc func receiverNotification(){
        let orient = UIDevice.current.orientation
        switch orient {
        case .portrait :
            quitFullScreen()
            break
        case .portraitUpsideDown:
            break
        case .landscapeLeft:
            fullScreen(isLeft: true)
            break
        case .landscapeRight:
            fullScreen(isLeft: false)
            break
        default:
            break
        }
    }

    /// 旋转屏幕并全屏
    ///
    /// - Parameter isLeft: 如果为left方向旋转，参数为true,否则为false
    func fullScreen(isLeft:Bool){
        if screenOrient != .portrait {
            return
        }
        originalBounds = self.frame
        var rotaAngle = CGFloat(Double.pi/2)
        if isLeft {
            //变更状态
            screenOrient = .landscapeLeft
            //状态栏方向
            UIApplication.shared.statusBarOrientation = .landscapeRight
        }else{
            rotaAngle = -rotaAngle
            screenOrient = .landscapeRight
            UIApplication.shared.statusBarOrientation = .landscapeLeft
        }
        //变更状态栏颜色
        UIApplication.shared.statusBarStyle = .lightContent
        //移除原始视图
        removeFromSuperview()
        //添加播放器视图
        // 获取屏幕窗口
        let keyWindow = UIApplication.shared.keyWindow!
        keyWindow.addSubview(self)
        //动画
        UIView.animate(withDuration: 0.2, animations: {
            self.transform = CGAffineTransform.identity
            self.transform = CGAffineTransform(rotationAngle: rotaAngle)
            self.frame = CGRect(x: 0, y: 0, width: kWidth, height: kHeight)
            self.consoleBar.frame = self.bounds
            self.consoleBar.setFullScreenSubviewFrame()
        }) { (r) in
            self.fullScreenTiggerAfter()
        }
    }


    //退出全屏
    func quitFullScreen(){
        if (screenOrient != .landscapeLeft) && (screenOrient != .landscapeRight) {return}
        //从window中移除视图
        removeFromSuperview()
        parentView?.addSubview(self)
        UIView.animate(withDuration: 0.2, animations: {
            self.transform = CGAffineTransform.identity
            //恢复到原始角度
            self.transform = CGAffineTransform(rotationAngle: 0)
            self.frame = self.originalBounds!
            self.consoleBar.frame = self.bounds
            self.consoleBar.setNormalSubviewFrame()
            DHPlayerRateView.hidden(superview: self)
        }) { (r) in
            //变更状态
            self.screenOrient = .portrait
            UIApplication.shared.statusBarOrientation = .portrait
            UIApplication.shared.statusBarStyle = .default
            self.fullScreenTiggerAfter()
        }
    }
}

