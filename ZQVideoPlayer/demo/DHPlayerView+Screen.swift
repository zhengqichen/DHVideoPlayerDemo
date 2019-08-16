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
        let keyWindow = UIApplication.shared.keyWindow!
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
        keyWindow.addSubview(self)
        //动画
        UIView.animate(withDuration: 0.2, animations: {
            self.transform = CGAffineTransform.identity
            self.transform = CGAffineTransform(rotationAngle: rotaAngle)
            //重置约束
            self.snp.remakeConstraints({ (make) in
                //将视图插入到顶层中心位置
                make.centerX.equalToSuperview()
                make.centerY.equalToSuperview()
                //重新应用宽高
                make.width.equalTo(keyWindow.bounds.height)
                make.height.equalTo(keyWindow.bounds.width)
            })
            self.consoleBar.fullScreenLayout()
        }) { (r) in
            self.fullScreenTiggerAfter()
            self.consoleBar.titleLabelIsHidden(false)
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
            //重置约束
            self.snp.remakeConstraints({ (make) in
                //将视图插入到顶层中心位置
                make.left.equalTo((self.originalBounds?.origin.x)!)
                make.top.equalTo((self.originalBounds?.origin.y)!)
                //重新应用宽高
                make.width.equalTo((self.originalBounds?.width)!)
                make.height.equalTo((self.originalBounds?.height)!)
            })
            self.consoleBar.normalScreenLayout()
        }) { (r) in
            //变更状态
            self.screenOrient = .portrait
            UIApplication.shared.statusBarOrientation = .portrait
            UIApplication.shared.statusBarStyle = .default
            self.fullScreenTiggerAfter()
            //代理方法
            self.consoleBar.titleLabelIsHidden(true)
        }
    }
}
