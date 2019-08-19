
//
//  DHPlayerConsolerView.swift
//  albatross
//
//  Created by 雷丹 on 2019/8/12.
//  Copyright © 2019 CZQ. All rights reserved.


import UIKit
import Kingfisher
protocol DHPlayerConsolerViewDelegate:class {
    /// 返回普通控制器
    func backButtonClick()
    
    /// 播放按钮被点击
    func playBtnClick()
    
    /// 暂停按钮被点击
    func replayButtonClick()
    
    /// 切换横竖屏按钮被点击
    func fullScreenBtnClick()
    
    /// 修改播放速度
    func rateButtonClick()
    
    /// 滑动块滑动中事件
    func sliderTouchDown(_ slider:UISlider)
    
    /// 滑动块滑动中事件
    func sliderTouchUpOut(_ slider:UISlider)
}

class DHPlayerConsolerView: UIView {
    
    //遮罩视图图像
    private lazy var topShadeImageView: UIImageView = {
        let img = UIImage(named: "player_topshadow")
        let subview = UIImageView(image: img)
        subview.contentMode = .scaleToFill
        subview.isUserInteractionEnabled = true
        return subview
    }()
    
    //顶部返回普通屏幕按钮
    private lazy var backButton:DHAmplifyButton = {
        let subview = DHAmplifyButton()
        //默认为隐藏
        subview.isHidden = true
        //设置标题、背景图像大小和位置
        subview.imageView?.contentMode = .left
        subview.setImage(UIImage(named: "player_back_filled"), for: UIControl.State.normal)
        return subview
    }()
    
    //标题label
    private lazy var titleLabel:UILabel = {
        let subview = UILabel()
        subview.textColor = UIColor.white
        subview.font = UIFont.boldSystemFont(ofSize: 18)
        return subview
    }()
    
    //封面
    private lazy var posterImageView:UIImageView = {
        let subview = UIImageView()
        //保持比例拉伸
        subview.clipsToBounds = true
        subview.contentMode = .scaleAspectFill
        subview.autoresizingMask = .flexibleHeight
        subview.backgroundColor = UIColor.gray.withAlphaComponent(0.1)
        return subview
    }()
    
    //加载动画视图
    private lazy var loadIndicator:UIActivityIndicatorView = {
        //动画
        let subview = UIActivityIndicatorView(style: .white)
        subview.isHidden = true
        return subview
    }()
    
    //播放&暂停按钮
    private lazy var playButton:UIButton = {
        let subview = UIButton()
        subview.setImage(UIImage(named: "player_play_btn"), for: UIControl.State.normal)
        subview.imageEdgeInsets = UIEdgeInsets(top: 0, left: -25, bottom: 0, right: 0)
        return subview
    }()
    
    //重播
    private lazy var replayButton:UIButton = {
        let subview = UIButton()
        subview.setImage(UIImage(named: "player_replay_btn"), for: UIControl.State.normal)
        subview.imageEdgeInsets = UIEdgeInsets(top: 0, left: -25, bottom: 0, right: 0)
        subview.isHidden = true
        return subview
    }()
    
    //遮罩视图图像
    private lazy var bottomShadeImageView: UIImageView = {
        let img = UIImage(named: "player_bottomshadow")
        let subview = UIImageView(image: img)
        subview.contentMode = .scaleToFill
        subview.isUserInteractionEnabled = true
        return subview
    }()
    
    //滑动块，播放进度位置
    lazy var slider:UISlider = {
        let subview = UISlider()
        subview.minimumValue = 0
        subview.maximumValue = 1
        subview.value = 0
        let size = CGSize(width: 0, height: 1)
        //颜色
        subview.tintColor = UIColor.gray
        // 从最大值滑向最小值时杆的颜色
        subview.maximumTrackTintColor = UIColor.white
        // 从最小值滑向最大值时杆的颜色
        subview.minimumTrackTintColor = UIColor.orange
        // 在滑块圆按钮添加图片
        subview.setThumbImage(UIImage(named:"player_slider_thumb"), for: UIControl.State.normal)
        return subview
    }()
    
    //横屏切换按钮
    private lazy var fullScreenButton:UIButton = {
        let subview = UIButton()
        subview.setImage(UIImage(named: "player_full_screen"), for: UIControl.State.normal)
        subview.imageEdgeInsets = UIEdgeInsets(top: 0, left: 25, bottom: 0, right: 0)
        return subview
    }()
    
    //当前播放时长
    private lazy var currDurationLabel:UILabel = {
        let subview = UILabel()
        subview.textColor = UIColor.white
        subview.text = "0:00"
        subview.textAlignment = .right
        subview.font = UIFont.systemFont(ofSize: 11)
        return subview
    }()
    
    //总时长
    private lazy var totalDurationLabel:UILabel = {
        let subview = UILabel()
        subview.text = "0:00"
        subview.textColor = UIColor.white
        subview.font = UIFont.systemFont(ofSize: 11)
        return subview
    }()
    
    //总时长
    private lazy var rateButton:UIButton = {
        let subview = UIButton()
        subview.setTitle("倍速", for: .normal)
        subview.titleLabel?.font = UIFont.systemFont(ofSize: 11)
        subview.layer.cornerRadius = 2
        subview.layer.borderWidth = 1
        subview.layer.borderColor = UIColor.white.cgColor
        return subview
    }()
    
    weak var delegate:DHPlayerConsolerViewDelegate!
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(posterImageView)
        addSubview(topShadeImageView)
        topShadeImageView.addSubview(titleLabel)
        topShadeImageView.addSubview(backButton)
        addSubview(replayButton)
        addSubview(loadIndicator)
        addSubview(bottomShadeImageView)
        bottomShadeImageView.addSubview(playButton)
        bottomShadeImageView.addSubview(currDurationLabel)
        bottomShadeImageView.addSubview(slider)
        bottomShadeImageView.addSubview(totalDurationLabel)
        bottomShadeImageView.addSubview(fullScreenButton)
        setNormalSubviewFrame()
        backButton.addTarget(self, action: #selector(backButtonClick), for: .touchUpInside)
        playButton.addTarget(self, action: #selector(playButtonClick), for: .touchUpInside)
        replayButton.addTarget(self, action: #selector(replayButtonClick), for: .touchUpInside)
        fullScreenButton.addTarget(self, action: #selector(fullScreenBtnClick), for: .touchUpInside)
        rateButton.addTarget(self, action: #selector(rateButtonClick), for: .touchUpInside)
        slider.addTarget(self, action: #selector(sliderTouchDown(_ :)), for: .touchDown)
        slider.addTarget(self, action: #selector(sliderTouchUpOut(_ :)), for: .touchUpOutside)
        slider.addTarget(self, action: #selector(sliderTouchUpOut(_ :)), for: .touchUpInside)
        slider.addTarget(self, action: #selector(sliderTouchUpOut(_ :)), for: .touchCancel)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension DHPlayerConsolerView{
    
    // 退出全屏重设置frame
    func setNormalSubviewFrame(){
        topShadeImageView.addSubview(rateButton)
        backButton.isHidden = true
        //封面
        posterImageView.frame = bounds
        var subframe = CGRect(x: 0, y: 0, width: frame.width, height: frame.height/2)
        //遮罩图像1
        topShadeImageView.frame = subframe
        //播放按钮
         subframe = CGRect(x: (frame.width-50)/2, y: (frame.height-50)/2, width: 50, height: 50)
        replayButton.frame = subframe
        //标题
        subframe = CGRect(x: 10, y: 10, width: frame.width-20, height: 30)
        titleLabel.frame = subframe
        //设置播放速度
        subframe = CGRect(x: frame.width-45, y: 12.5, width: 35, height: 20)
        rateButton.frame = subframe
        //加载动画
        loadIndicator.frame = bounds
        //遮罩图像2
        subframe = CGRect(x: 0, y: frame.height/2, width: frame.width, height: frame.height/2)
        bottomShadeImageView.frame = subframe
        //滑动块
        subframe = CGRect(x: 76, y: bottomShadeImageView.frame.height-15, width: frame.width-152, height: 1)
        slider.frame = subframe
        //播放按钮
        //滑动块
        subframe = CGRect(x: 5, y: bottomShadeImageView.frame.height-35, width: 50, height: 40)
        playButton.frame = subframe
        //当前播放时长
        subframe = CGRect(x: 16, y: bottomShadeImageView.frame.height-30, width: 50, height: 30)
        currDurationLabel.frame = subframe
        //总时长
        subframe = CGRect(x:slider.frame.maxX + 10, y: bottomShadeImageView.frame.height-30, width: 50, height: 30)
        totalDurationLabel.frame = subframe
        //横屏切换
        subframe = CGRect(x:frame.width - 55, y: bottomShadeImageView.frame.height-35, width: 50, height: 40)
        fullScreenButton.frame = subframe
    }
    
    // 全屏重设置frame
    func setFullScreenSubviewFrame(){
        bottomShadeImageView.addSubview(rateButton)
        backButton.isHidden = false
        //封面
        posterImageView.frame = bounds
        //遮罩图像1
        topShadeImageView.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height/2)
        //播放按钮
        var subframe = CGRect(x: (frame.width-50)/2, y: (frame.height-50)/2, width: 50, height: 50)
        replayButton.frame = subframe
        //返回按钮
        subframe = CGRect(x: kNaviBarHeight, y: 20, width: 50, height: 40)
        backButton.frame = subframe
        //标题
        subframe = CGRect(x:kNaviBarHeight+40, y: 20, width: frame.width-kNaviBarHeight*2-50, height: 40)
        titleLabel.frame = subframe
        //加载动画
        loadIndicator.frame = bounds
        //遮罩图像2
        subframe = CGRect(x: 0, y: frame.height/2, width: frame.width, height: frame.height/2)
        bottomShadeImageView.frame = subframe
        //滑动块
        subframe = CGRect(x: kNaviBarHeight, y: bottomShadeImageView.frame.height-60, width: frame.width-kNaviBarHeight*2, height: 1)
        slider.frame = subframe
        //播放按钮
        subframe = CGRect(x: kNaviBarHeight+5, y: bottomShadeImageView.frame.height-50, width: 50, height: 40)
        playButton.frame = subframe
        //当前播放时长
        subframe = CGRect(x: kNaviBarHeight+5, y: bottomShadeImageView.frame.height-90, width: 50, height: 20)
        currDurationLabel.frame = subframe
        //总时长
        subframe = CGRect(x:frame.width-kNaviBarHeight-55, y: bottomShadeImageView.frame.height-90, width: 50, height: 20)
        totalDurationLabel.frame = subframe
        //横屏切换
        subframe = CGRect(x:frame.width - 55-kNaviBarHeight, y: bottomShadeImageView.frame.height-50, width: 50, height: 40)
        fullScreenButton.frame = subframe
        
        //设置播放速度
        subframe = CGRect(x: frame.width-kNaviBarHeight-100, y: bottomShadeImageView.frame.height-40, width: 35, height: 20)
        rateButton.frame = subframe
    }
}

extension DHPlayerConsolerView{

    /// 返回普通控制器
    @objc func backButtonClick()  {
        guard let delegate = delegate else {return}
        delegate.backButtonClick()
    }
    
    /// 播放按钮被点击
    @objc func playButtonClick()  {
        guard let delegate = delegate else {return}
        delegate.playBtnClick()
    }
    
    
    
    /// 切换横竖屏按钮被点击
    @objc func fullScreenBtnClick()  {
        guard let delegate = delegate else {return}
        delegate.fullScreenBtnClick()
    }
    
    /// 滑动块滑动中事件
    @objc func sliderTouchDown(_ slider:UISlider){
        guard let delegate = delegate else {return}
        delegate.sliderTouchDown(slider)
    }
    
    /// 滑动块滑动中事件
    @objc func sliderTouchUpOut(_ slider:UISlider){
        guard let delegate = delegate else {return}
        delegate.sliderTouchUpOut(slider)
    }
    
    /// 点击重播按钮
    @objc func replayButtonClick()  {
        guard let delegate = delegate else {return}
        delegate.replayButtonClick()
    }
    
    /// 修改播放速度
    @objc func rateButtonClick()  {
        guard let delegate = delegate else {return}
        delegate.rateButtonClick()
    }
}

extension DHPlayerConsolerView{
    
    /// 设置标题
    func setTitleLabel(text:String)  {
        titleLabel.text = text
    }
    
    /// 设置封面(网络)
    func setPosterImageView(imagePath:String)  {
        guard let url = URL.init(string: imagePath) else {return}
        posterImageView.kf.setImage(with: url)
    }
    
    /// 设置封面(本地)
    func setPosterImageView(image:UIImage)  {
        posterImageView.image = image
    }
    /// 更换播放按钮状态图标
    func changePlayButton(imageName:String)  {
        playButton.setImage(UIImage.init(named: imageName), for: .normal)
    }
    
    /// 更换全屏切换按钮图标
    func changeFullScreenButton(imageName:String)  {
        fullScreenButton.setImage(UIImage.init(named: imageName), for: .normal)
    }
    
    /// 设置总时长
    func changeTotalDurationLabel(text:String)  {
        totalDurationLabel.text = text
    }
    
    /// 设置进度时间
    func changeCurrDurationLabel(text:String)  {
        currDurationLabel.text = text
    }
    
    /// 设置滑块进度
    func changeSliderProgress(_ value:Float)  {
        slider.value = value
    }
    
    /// 隐藏/显示封面
    func posterImageViewIsHidden(_ hidden:Bool)  {
        posterImageView.isHidden = hidden
    }
    
    /// 隐藏/显示返回按钮
    func backButtonIsHidden(_ hidden:Bool)  {
        backButton.isHidden = hidden
    }
    
    /// 隐藏/显示bottomBar
    func bottomBarIsHidden(_ hidden:Bool)  {
        bottomShadeImageView.isHidden = hidden
    }
    
    /// 隐藏/显示全屏按钮
    func fullScreenButtonIsHidden(_ hidden:Bool)  {
        fullScreenButton.isHidden = hidden
    }
    
    /// 隐藏/显示重播按钮
    func replayButtonIsHidden(_ hidden:Bool)  {
        replayButton.isHidden = hidden
    }
    
    /// 隐藏/显示标题
    func titleLabelIsHidden(_ hidden:Bool)  {
        titleLabel.isHidden = hidden
    }
    
    /// 开启加载动画
    func loadIndicatorStartAnimating()  {
        loadIndicator.startAnimating()
    }
    
    /// 关闭加载动画
    func loadIndicatorStopAnimating()  {
        loadIndicator.stopAnimating()
    }
}
extension DHPlayerConsolerView{

    // 全屏模式下显示操作面板
    func fullScreenShowConsolerView()  {
        topShadeImageView.transform = .identity
        bottomShadeImageView.transform = .identity
    }
    
    // 全屏模式下隐藏操作面板
    func fullScreenHiddenConsolerView()  {
        topShadeImageView.transform = CGAffineTransform(translationX: 0, y: -frame.height/2)
        bottomShadeImageView.transform = CGAffineTransform(translationX: 0, y: frame.height/2)
    }
}
