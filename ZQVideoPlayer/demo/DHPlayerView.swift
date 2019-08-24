//
//  DHPlayerView.swift
//  albatross
//
//  Created by 雷丹 on 2019/8/12.
//  Copyright © 2019 CZQ. All rights reserved.


import UIKit
import AVFoundation
import MediaPlayer
import SnapKit
/// 播放器状态
enum DHPlayerState:String {
    case playing = "播放中"
    case pause = "暂停"
    case buffering = "缓冲中"
    case bufferPause = "缓冲暂停"
    case stop = "已停止"
}
class DHPlayerView: UIView {
    // 监听 playerItem 的状态通知
    private let noticeCenter = NotificationCenter.default
    /// 服务代理
    var delegate:DHPlayerViewDelegate?
    //资源状态
    var state:DHPlayerState = .stop
    //当前播放时间
    var currentTime:TimeInterval = 0.00
    //缓冲时间
    var loadedTime:TimeInterval = 0.00
    //总时长
    var totalTimeSecounds:TimeInterval = 0
    //资源
    var playerItem:AVPlayerItem!
    //布局对象
    var playerLayer:AVPlayerLayer!
    //播放器
    var avplayer:AVPlayer!
    //监视链接器
    var link:CADisplayLink!
    //网络路径
    var resource_url:URL?
    //滑动块交互中
    var sliding:Bool = false
    //是否全屏
    var fullScreenStatus:Bool = false
    //是否准备好了组件
    var isReadyCombin:Bool = false
    
    //当前屏幕方向，默认为竖向正常
    var screenOrient:UIDeviceOrientation = .portrait
    // 播放器父view
    var parentView:UIView?
    //原始宽高
    var originalBounds:CGRect?
    //开始播放时指定的时间
    var beginSeekTime:TimeInterval = -1
    // 是否正在修改音量
    var isChangeVolume:Bool!
    //  手势滑动方向
    var direction:Direction = .none
    //  屏幕亮度
    var brightness:CGFloat = 0
    //  手势作用在屏幕的左侧还是右侧
    var isSestureRecognizerLocationLeft = true
    // 代替系统音量滑块的滑块
    var volumeViewSlider:UISlider!
    // 系统音量
    var volume:CGFloat = 0
    // 滑动屏幕快进/快退的增量
    var changeProgresValue:CGFloat = 30
    
    // 物理音量键计时器
    var volumeTimer:Timer!
    var timeInterval = -1
    
    // 控制面板计时器
    var consoleBarTimer:Timer!
    var consoleBarTimeInterval = 0
    
    //控制面板
    lazy var consoleBar : DHPlayerConsolerView = {
        let subview = DHPlayerConsolerView(frame: bounds)
        return subview
    }()
    
    //播放器视图
    lazy var playerView:UIView = {
        let subview = UIView()
        return subview
    }()
    
    //  懒加载音量控件
    lazy var volumeView:MPVolumeView = {
        let volumeView:MPVolumeView = MPVolumeView(frame: CGRect(x: -1111, y: -1000, width: 11, height: 11))
        for view in volumeView.subviews {
            if (NSStringFromClass(view.classForCoder) == "MPVolumeSlider"){
                volumeViewSlider = (view as! UISlider)
                break
            }
        }
        return volumeView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        //构建控制面板
        consoleBar.delegate = self
        consoleBar.frame = bounds
        addSubview(consoleBar)
        addSubview(volumeView)
        addGestureRecognizer()
        volumeViewSlider.addTarget(self, action: #selector(volumeViewSliderValueChanged(_ :)), for: .valueChanged)
    }
    
    /// 执行初始播放
    @objc func initPlay(){
        initSceneTransition()
        combineFrame()
        tracking()
        play()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 搭建播放器
    func combineFrame(){
        if isReadyCombin {return}
        //如果未准备好，或者被释放删除，重新构建
        isReadyCombin = true
        playerItem = AVPlayerItem(url: resource_url!)
        avplayer = AVPlayer(playerItem: playerItem)
        playerLayer = AVPlayerLayer(player: avplayer)
        //设置模式
        playerLayer.videoGravity = AVLayerVideoGravity.resizeAspect
        playerLayer.contentsScale = UIScreen.main.scale
        //播放器视图
        insertSubview(playerView, belowSubview: consoleBar)
        playerView.layer.insertSublayer(playerLayer, at: 0)
        layer.insertSublayer(playerLayer, at: 0)
    }
    
    /// 播放出错通知
    @objc func backStalledNotice(){
        debugPrint("播放出错")
    }
    
    /// 播放完成通知
    @objc func toEndTimeNotice(){
        debugPrint("播放完成了")
        stop()
        //变更播放按钮图像
        consoleBar.replayButtonIsHidden(false)
        consoleBar.titleLabelIsHidden(true)
        consoleBar.rateButtonIsHidden(true)
        //
        // 获取屏幕窗口
        let keyWindow = UIApplication.shared.keyWindow!
        DHPlayerHUD.hidden(superview: fullScreenStatus ? keyWindow:self)
        /// 播放完成 关闭计时器
        consoleBarTimeOffTimer()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer?.frame = bounds
    }
    
    deinit {
        releaseTrack()
    }
}

/// MARK - 物理音量键调节音量时实时更新自定义音量进度条
extension DHPlayerView{
    @objc func volumeViewSliderValueChanged(_ slider:UISlider)  {
        if timeInterval == -1 {
            timeInterval = 0
            return
        }
        timeInterval = 0
        // 获取屏幕窗口
        let keyWindow = UIApplication.shared.keyWindow!
        DHPlayerHUD.showVolume(progress: CGFloat(volumeViewSlider!.value), superview:fullScreenStatus ? keyWindow:self,fullScreenStatus:fullScreenStatus )
        if volumeTimer == nil {
            /// 计时器，监听是否在用物理音量键修改音量
            volumeTimer = Timer.scheduledTimer(timeInterval: 1.0,target: self,selector: #selector(volumeTimerRuning),userInfo: nil,repeats: true)
        }
    }
    
    /// 计时器跑起来
    @objc func volumeTimerRuning(){
        timeInterval += 1
        /// 当音量超过2秒没有变化后，删除显示音量的进度条
        if timeInterval >= 2{
            // 获取屏幕窗口
            let keyWindow = UIApplication.shared.keyWindow!
            DHPlayerHUD.hidden(superview: fullScreenStatus ? keyWindow:self)
            volumeOffTimer()
        }
    }
    
    /// 关闭定时器
    func volumeOffTimer()  {
        guard let timer = volumeTimer else{ return }
        timer.invalidate()
        self.volumeTimer = nil
    }
}

/// MARK - 修改控制面板
extension DHPlayerView{
    /// 跳转到指定位置
    func seek(time:TimeInterval){
        beginSeekTime = time
    }
    
    /// 添加资源
    func setResourceUrl(url:URL)  {
        resource_url = url
    }
    
    /// 设置封面（网络）
    func setPosterImage(imagePath:String)  {
        consoleBar.setPosterImageView(imagePath: imagePath)
    }
    
    /// 设置封面（网络）
    func setPosterImage(image:UIImage)  {
        consoleBar.setPosterImageView(image: image)
    }
    
    /// 设置标题
    func setTitle(title:String)  {
        consoleBar.setTitleLabel(text: title)
    }
    
    /// 设置播放速度
    func setRate(_ rate:Float){
        if let avplayer = avplayer{
            avplayer.rate = rate
        }
    }
}

/// MARK - 跟踪
extension DHPlayerView{
    //执行播放跟踪
    private func tracking(){
        //监听缓冲进度改变
        playerItem.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions.new, context: nil)
        playerItem.addObserver(self, forKeyPath: "loadedTimeRanges", options: NSKeyValueObservingOptions.new, context: nil)
        playerItem.addObserver(self, forKeyPath: "playbackBufferEmpty", options: NSKeyValueObservingOptions.new, context: nil)
        playerItem.addObserver(self, forKeyPath: "playbackLikelyToKeepUp", options: NSKeyValueObservingOptions.new, context: nil)
        //监视器配置
        link = CADisplayLink(target: self, selector: #selector(updateSchedule))
        link.add(to: RunLoop.main, forMode: RunLoop.Mode.default)
        //
        noticeCenter.addObserver(self, selector: #selector(toEndTimeNotice), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
        noticeCenter.addObserver(self, selector: #selector(backStalledNotice), name: NSNotification.Name.AVPlayerItemPlaybackStalled, object: playerItem)
        //监听屏幕旋转
        noticeCenter.addObserver(self, selector: #selector(receiverNotification), name: UIDevice.orientationDidChangeNotification, object: nil)
        // 监听app 进入后台 返回前台的通知
        noticeCenter.addObserver(self, selector: #selector(pause), name: UIApplication.willResignActiveNotification, object: nil)
    }
    
    /// 释放跟踪
    private func releaseTrack(){
        if avplayer == nil {return}
        debugPrint(">>> 释放资源")
        playerItem.cancelPendingSeeks()
        playerItem.asset.cancelLoading()
        avplayer.currentItem?.cancelPendingSeeks()
        avplayer.currentItem?.asset.cancelLoading()
        //移除所有通知
        noticeCenter.removeObserver(self)
        //监视器监听
        link.remove(from: RunLoop.main, forMode: RunLoop.Mode.default)
        //移除监听器
        playerItem.removeObserver(self, forKeyPath: "loadedTimeRanges")
        playerItem.removeObserver(self, forKeyPath: "status")
        playerItem.removeObserver(self, forKeyPath: "playbackBufferEmpty")
        playerItem.removeObserver(self, forKeyPath: "playbackLikelyToKeepUp")
        //清除播放层
        playerLayer.removeFromSuperlayer()
        avplayer.replaceCurrentItem(with: nil)
        playerItem = nil
        playerLayer = nil
        avplayer = nil
        //将状态标识为未准备好
        isReadyCombin = false
    }
}

/// MARK - 改变播放状态
extension DHPlayerView{
    
    //切换播放状态
    @objc func playOrPause(){
        if state == .pause || state == .stop{
            //播放
            play()
        } else if state == .playing {
            //暂停
            pause()
        }
    }
    
    /// 播放
    func play(){
        if state == .playing {return}
        debugPrint("播放中")
        state = .playing
        avplayer.play()
        consoleBar.changePlayButton(imageName: "player_pause")
        
        //隐藏封面
        consoleBar.posterImageViewIsHidden(true)
        //直接隐藏控制面板
        hideConsoleBarView(time: 0.2)
        
        //显示控制面板
        consoleBar.bottomBarIsHidden(false)
        delegate?.onPlay(player: self)
    }
    
    
    /// 当播放被停止
    func stop(){
        debugPrint("停止")
        if state == .stop {return}
        pause()
        state = .stop
        //如果是全屏，退出
        if fullScreenStatus {
            quitFullScreen()
        }
        //停止
        consoleBar.loadIndicatorStopAnimating()
        //显示封面
        consoleBar.posterImageViewIsHidden(false)
        //隐藏控制面板
        consoleBar.bottomBarIsHidden(true)
        delegate?.onStop(player: self)
        releaseTrack()
    }
    
    /// 当播放被暂停
    ///
    @objc func pause(){
        debugPrint("暂停")
        if state == .pause {return}
        state = .pause
        avplayer.pause()
        consoleBar.changePlayButton(imageName: "player_play_btn")
        //显示面板
        slowConsoleBarView(time: 0.2)
        delegate?.onPause(player: self)
    }
}

/// MARK - DHPlayerConsolerViewDelegate
extension DHPlayerView:DHPlayerConsolerViewDelegate{
    
    /// 修改播放速度
    func rateButtonClick() {
        hideConsoleBarView(time: 0.1)
        DHPlayerRateView.show(superview: self, fullScreenStatus: fullScreenStatus) {[weak self] (rate) in
            guard let strongSelf = self else{return}
            strongSelf.setRate(rate)
        }
    }
    
    /// 返回普通控制器
    func backButtonClick(){
        fullScreenBtnEvent()
    }
    
    /// 播放按钮被点击
    func playBtnClick(){
        playOrPause()
    }
    
    /// 暂停按钮被点击
    func replayButtonClick()  {
        initPlay()
        consoleBar.replayButtonIsHidden(true)
    }
    
    /// 切换横竖屏按钮被点击
    func fullScreenBtnClick(){
        fullScreenBtnEvent()
    }
    
    /// 滑动块滑动中事件
    func sliderTouchDown(_ slider:UISlider){
        sliding = true
        pause()
    }
    
    /// 滑动块滑动中事件
    func sliderTouchUpOut(_ slider:UISlider){
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
                self.play()
            })
        }
    }
}

