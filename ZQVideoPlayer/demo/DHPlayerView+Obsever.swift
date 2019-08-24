//
//  DHPlayerView+Obsever.swift
//  albatross
//
//  Created by 雷丹 on 2019/8/12.
//  Copyright © 2019 CZQ. All rights reserved.
//

//  DHPlayerView+Obsever.swift
//  albatross
//
//  Created by 雷丹 on 2019/8/12.
//  Copyright © 2019 CZQ. All rights reserved.


import Foundation
import AVFoundation
import UIKit

extension DHPlayerView {
    // 接收监听事件
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        let item = object as! AVPlayerItem
        if keyPath == "loadedTimeRanges" {
            updateBufferProgress()
        } else if keyPath == "status" {
            let status = item.status
            switch status {
            case .failed,.unknown:
                delegate?.onError(player: self)
            case .readyToPlay:
                readyPaly()
            default:
                break
            }
        }  else if keyPath == "playbackBufferEmpty" && item.isPlaybackBufferEmpty {
            // 监听播放器在缓冲数据的状态
            buffering()
        }else if keyPath == "playbackLikelyToKeepUp" {
            // 缓存足够了，可以播放
            bufferDone()
        }
    }

    /// 准备播放
    func readyPaly(){
        //读取播放时长
        readTotalDuration()
        //从指定时间播放
        guard beginSeekTime != -1 else{return}
        let seekTime = CMTimeMake(value: Int64(beginSeekTime), timescale: 1)
        avplayer.seek(to: seekTime) { (r) in
            debugPrint("------------- 从\(seekTime)继续播放 ------------------")
        }
    }

    /// 更新缓冲进度
    func updateBufferProgress(){
        let bufferedRanges = playerItem?.loadedTimeRanges
        let timeRange = bufferedRanges?.first?.timeRangeValue;  // 获取缓冲区域
        let startSeconds = CMTimeGetSeconds(timeRange!.start)
        let durationSeconds = CMTimeGetSeconds(timeRange!.duration)
        let timeInterval = startSeconds + durationSeconds
        let duration = playerItem!.duration
        let totalDuration = CMTimeGetSeconds(duration)
        let value = Float(timeInterval)/Float(totalDuration)
        print("已缓冲：\(value)")
    }

    //显示总时长
    private func readTotalDuration(){
        totalTimeSecounds = TimeInterval(playerItem.duration.value) / TimeInterval(playerItem.duration.timescale);
        let totalStr = formatPlayTime(secounds: totalTimeSecounds)
        consoleBar.changeTotalDurationLabel(text: totalStr)
    }

    /// 更新进度
    @objc func updateSchedule(){
        //计算当前播放时间
        currentTime = CMTimeGetSeconds(avplayer.currentTime())
        let timeStr = "\(formatPlayTime(secounds: currentTime))"
        consoleBar.changeCurrDurationLabel(text: timeStr)
        // 滑动不在滑动的时候
        if !sliding{
            let value = Float(currentTime/totalTimeSecounds)
            // 播放进度
            consoleBar.changeSliderProgress(value)

        }
        readTotalDuration()
    }

    ///  格式化时间字符串
    private func formatPlayTime(secounds:TimeInterval)->String{
        if secounds.isNaN{return "00:00"}
        let m = Int(secounds / 60)
        let s = Int(secounds.truncatingRemainder(dividingBy: 60))
        let str = String(format: "%02d:%02d", m, s)
        return str
    }

    /// 滑动块释放事件
    ///
    /// - Parameter slider: slider description
    @objc func sliderTouchUpOut(slider:UISlider){
        //当视频状态为AVPlayerStatusReadyToPlay时才处理
        if avplayer.status == AVPlayer.Status.readyToPlay{
            let duration = slider.value * Float(CMTimeGetSeconds(avplayer.currentItem!.duration))
            if duration.isNaN {
                //还没有获取到资源信息
                slider.value = 0
                return
            }
            let seekTime = CMTimeMake(value: Int64(duration), timescale: 1)
            avplayer.seek(to: seekTime, completionHandler: { (b) in
                self.sliding = false
            })
        }
    }

    /// 渐显控制视图
    ///
    /// - Parameter time: 过渡时间
    ///   - view: 视图对象
    func slowConsoleBarView(time:TimeInterval) {
        consoleBar.isHidden = false
        UIView.animate(withDuration: time, animations: {
            self.consoleBar.alpha = 1
            if self.fullScreenStatus{
                self.consoleBar.fullScreenShowConsolerView()
            }else{
                
            }
        }) { (finish) in
            self.setConsoleBarTimer()
        }
    }

    /// 渐隐控制视图
    ///
    /// - Parameter time: 过渡时间
    ///   - view: 视图对象
    func hideConsoleBarView(time:TimeInterval) {
        if avplayer == nil {return}
        UIView.animate(withDuration: time, animations: {
            if self.fullScreenStatus{
                self.consoleBar.fullScreenHiddenConsolerView()
            }else{
                self.consoleBar.alpha = 0
            }
        }) { (r) in
            self.consoleBar.isHidden = true
            self.consoleBarTimeOffTimer()
        }
    }



    /// 当视频缓冲中，暂停播放
    func buffering(){
        debugPrint("缓冲中")
        if state == .playing {
            //暂停
            pause()
            state = .bufferPause
            //显示动画
            consoleBar.loadIndicatorStartAnimating()
        }
    }

    /// 当视频缓冲到可以继续播放时
    func bufferDone(){
        debugPrint("缓冲完成，可以播放")
        //完成初始化播放缓冲
       finishSceneTransition()
        //隐藏动画
        consoleBar.loadIndicatorStopAnimating()
        if state == .bufferPause {
            play()
        }
        consoleBar.rateButtonIsHidden(false)
        consoleBar.titleLabelIsHidden(false)
    }

    /// 初始化应用场景过渡，此方法
    func initSceneTransition(){
        consoleBar.posterImageViewIsHidden(false)
        //显示加载动画和封面
        consoleBar.loadIndicatorStopAnimating()
    }

    /// 待准备完成后，开始缓冲播放，应用此方法
    func finishSceneTransition(){
        consoleBar.loadIndicatorStopAnimating()
        //隐藏封面
        consoleBar.posterImageViewIsHidden(true)
        //直接隐藏控制面板
        hideConsoleBarView(time: 0.2)
    }
}

///// MARK - 控制版面计时器
extension DHPlayerView{
    func setConsoleBarTimer()  {
        consoleBarTimeInterval = 0
        if consoleBarTimer == nil {
            consoleBarTimer = Timer.scheduledTimer(timeInterval: 1.0,target: self,selector: #selector(consoleBarTimerRuning),userInfo: nil,repeats: true)
        }
    }
    /// 计时器跑起来
    @objc func consoleBarTimerRuning(){
        consoleBarTimeInterval += 1
        if consoleBarTimeInterval >= 3{
            hideConsoleBarView(time: 0.5)
            if self.state != .playing {return}
            consoleBarTimeOffTimer()
        }
    }

    /// 关闭定时器
    func consoleBarTimeOffTimer()  {
        guard let timer = consoleBarTimer else{ return }
        timer.invalidate()
        self.consoleBarTimer = nil
    }
}
