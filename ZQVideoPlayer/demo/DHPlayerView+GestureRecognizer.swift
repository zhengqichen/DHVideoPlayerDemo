//
//  DHPlayerView+GestureRecognizer.swift
//  albatross
//
//  Created by 雷丹 on 2019/8/14.
//  Copyright © 2019 CZQ. All rights reserved.
//

import UIKit
import MediaPlayer
enum Direction {
    case none
    case up
    case down
    case left
    case right
}


extension DHPlayerView:UIGestureRecognizerDelegate{
    
    /// 添加手势
    func addGestureRecognizer()  {
        // 点击手势
        let consoleTap = UITapGestureRecognizer(target: self, action: #selector(isShowConsolerView))
        addGestureRecognizer(consoleTap)
        // 滑动手势
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleSwipeFrom(_ :)))
        panRecognizer.delegate = self
        addGestureRecognizer(panRecognizer)
    }
    
    /// 控制台隐藏或显示
    @objc func isShowConsolerView(){
        //如果没有播放，不响应事件
        if state != .playing || totalTimeSecounds == 0 {return}
        if consoleBar.isHidden {
            slowConsoleBarView(time: 0.2)
            delayHideConsoleBar()
        }else{
            hideConsoleBarView(time: 0.2)
        }
    }
    
    @objc func handleSwipeFrom(_ gesture:UIPanGestureRecognizer)  {
        /// 记录滑动手势的变换
        let translation = gesture.translation(in: self)
        /// 手势在X轴上的滑动进度
        let progressX = translation.x / gesture.view!.bounds.width
        /// 手势在Y轴上的滑动进度
        let progressY = translation.y / gesture.view!.bounds.height
        
        // 获取屏幕窗口
        let keyWindow = UIApplication.shared.keyWindow!
        if gesture.state == .began {
            /// 开始滑动时重置滑动方向为空
            direction = .none
            /// 开始滑动时获取当前屏幕亮度
            brightness = getBrightness()
            /// 开始滑动时获取当前系统音量
            volume = getVolume()
            /// 记录滑动是发生在屏幕的画左边还是右边
            let point = gesture.location(in: gesture.view)
            isSestureRecognizerLocationLeft = (point.x < gesture.view!.bounds.width/2)
        } else if gesture.state == .changed  {
            direction = determineCameraDirectionIfNeeded(translation: translation)
            switch direction {
            case .down,.up:
                if isSestureRecognizerLocationLeft {
                    // 滑动左边屏幕修改音量
                    volumeViewSlider.value = Float(volume - progressY)
                    DHPlayerHUD.showVolume(progress: CGFloat(volumeViewSlider!.value), superview:fullScreenStatus ? keyWindow:self,fullScreenStatus:fullScreenStatus )
                }else{
                    // 滑动右边屏幕修改亮度
                  UIScreen.main.brightness = brightness - progressY
                  DHPlayerHUD.showBrightness(progress: CGFloat(UIScreen.main.brightness), superview: fullScreenStatus ? keyWindow:self,fullScreenStatus:fullScreenStatus)
                }
                break
            case .right,.left:
                currentTime += TimeInterval(progressX*60)
                currentTime = max(currentTime, 0)
                currentTime = min(currentTime, totalTimeSecounds)
                changePlayerProgress(Float(currentTime))
                DHPlayerHUD.showPlayerProgress(currentTime: CGFloat(currentTime), totalTime: CGFloat(totalTimeSecounds), superview: fullScreenStatus ? keyWindow:self,fullScreenStatus:fullScreenStatus)
                break
            default :
                break
            }
        }else if gesture.state == .ended{
            DHPlayerHUD.hidden(superview: fullScreenStatus ? keyWindow:self)
        }
    }
    
    /// 计算手势方向
    func determineCameraDirectionIfNeeded(translation:CGPoint) -> Direction {
        let gestureMinimumTranslation:CGFloat = 20.0
        if direction != .none{
            return direction
        }
        if abs(translation.x) > gestureMinimumTranslation{
            var gestureHorizontal = false
            if translation.y == 0 {
                gestureHorizontal = true
            }else{
                gestureHorizontal = (abs(translation.x / translation.y) > 5.0)
            }
            if gestureHorizontal{
                return translation.x > 0 ? .right:.left
            }
        }else if abs(translation.y) > gestureMinimumTranslation{
            var gestureVertical = false
            if translation.x == 0 {
                gestureVertical = true
            }else{
                gestureVertical = (abs(translation.y / translation.x) > 5.0)
            }
            if gestureVertical{
                return translation.y > 0 ? .down:.up
            }
        }
        return direction
    }

    /// 修改播放进度后更新播放
    func changePlayerProgress(_ duration:Float){
        //当视频状态为AVPlayerStatusReadyToPlay时才处理
        guard avplayer != nil else{return}
        if avplayer.status == AVPlayer.Status.readyToPlay{
            let seekTime = CMTimeMake(value: Int64(duration), timescale: 1)
            avplayer.seek(to: seekTime, completionHandler: { (b) in
                self.sliding = false
                self.play()
            })
        }
    }
}

extension DHPlayerView{
    
    /// 获取屏幕亮度
    func getBrightness() -> CGFloat {
        return UIScreen.main.brightness
    }
    
    /// 获取视频音量
    func getVolume() -> CGFloat {
        return CGFloat(volumeViewSlider.value)
    }
    
    /// 获取当前模仿时间
    func getCurrentDuration() -> CGFloat {
        return CGFloat(CMTimeGetSeconds(avplayer.currentItem!.duration))
    }
}
