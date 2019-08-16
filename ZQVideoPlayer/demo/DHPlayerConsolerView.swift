//
//  DHPlayerConsolerView.swift
//  albatross
//
//  Created by 雷丹 on 2019/8/12.
//  Copyright © 2019 CZQ. All rights reserved.
//

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
    
    /// 滑动块滑动中事件
    func sliderTouchDown(_ slider:UISlider)
    
    /// 滑动块滑动中事件
    func sliderTouchUpOut(_ slider:UISlider)
}

class DHPlayerConsolerView: UIView {
    
    //遮罩视图图像
    private lazy var shadeImageView: UIImageView = {
        let img = UIImage(named: "player_topshadow")
        let subview = UIImageView(image: img)
        subview.contentMode = .scaleToFill
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
        subview.backgroundColor = .red
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
    //控制条
     private lazy var bottomBar:UIView = {
        let subview:UIView = UIView()
        subview.isHidden = true
        subview.backgroundColor = UIColor.black.withAlphaComponent(0.42)
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


    weak var delegate:DHPlayerConsolerViewDelegate!
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(posterImageView)
        addSubview(shadeImageView)
        addSubview(titleLabel)
        addSubview(backButton)
        addSubview(replayButton)
        addSubview(loadIndicator)
        addSubview(bottomBar)
        bottomBar.addSubview(playButton)
        bottomBar.addSubview(currDurationLabel)
        bottomBar.addSubview(slider)
        bottomBar.addSubview(totalDurationLabel)
        bottomBar.addSubview(fullScreenButton)
        makeSubviewsConstraints()
        backButton.addTarget(self, action: #selector(backButtonClick), for: .touchUpInside)
        playButton.addTarget(self, action: #selector(playButtonClick), for: .touchUpInside)
        replayButton.addTarget(self, action: #selector(replayButtonClick), for: .touchUpInside)
        fullScreenButton.addTarget(self, action: #selector(fullScreenBtnClick), for: .touchUpInside)
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
    
    func makeSubviewsConstraints(){
        //封面
        posterImageView.snp.makeConstraints { (make) in
            make.left.top.equalToSuperview()
            make.right.bottom.equalToSuperview()
        }
        
        //遮罩图像
        shadeImageView.snp.makeConstraints { (make) in
            make.left.top.equalToSuperview()
            make.right.bottom.equalToSuperview()
        }
        
        //播放按钮
        replayButton.snp.makeConstraints { (make) in
            make.centerY.centerX.equalToSuperview()
            make.width.height.equalTo(50)
        }
        //返回普通屏幕按钮
        backButton.snp.makeConstraints { (make) in
            make.left.equalTo(self).offset(kNaviBarHeight)
            make.top.equalTo(self).offset(30)
            make.height.equalTo(20)
            make.width.equalTo(20)
        }
        
        normalScreenLayout()
        //加载动画
        loadIndicator.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.height.equalTo(80)
        }
        
        //控制条
        bottomBar.snp.makeConstraints { (make) in
            make.left.width.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(30)
        }
        
        //滑动块
        slider.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(76)
            make.right.equalToSuperview().offset(-76)
            make.bottom.equalToSuperview().offset(-15)
            make.height.equalTo(1)
        }
        
        //播放按钮
        playButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(slider)
            make.left.equalToSuperview().offset(5)
            make.width.equalTo(50)
            make.height.equalTo(40)
        }
        
        //当前播放时长
        currDurationLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(slider)
            make.right.equalTo(slider.snp.left).offset(-10)
            make.width.equalTo(50)
        }
        
        //总时长
        totalDurationLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(slider)
            make.left.equalTo(slider.snp.right).offset(10)
            make.width.equalTo(50)
        }
        
        //横屏切换
        fullScreenButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(slider)
            make.right.equalToSuperview().offset(-5)
            make.width.equalTo(50)
            make.height.equalTo(40)
        }
        
    }
    
    /// 全屏布局
    func fullScreenLayout(){
        backButton.isHidden = false
        //标题
        titleLabel.snp.remakeConstraints { (make) in
            make.left.equalTo(kNaviBarHeight+25)
            make.right.equalTo(self).offset(-10)
            make.top.equalTo(self).offset(30)
        }
    }
    /// 普通窗口布局
    func normalScreenLayout(){
        backButton.isHidden = true
        //标题
        titleLabel.snp.remakeConstraints { (make) in
            make.left.equalTo(self).offset(10)
            make.right.equalTo(self).offset(-10)
            make.top.equalTo(self).offset(10)
        }
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
    
    /// 暂停按钮被点击
    @objc func replayButtonClick()  {
        guard let delegate = delegate else {return}
        delegate.replayButtonClick()
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
}

extension DHPlayerConsolerView{
   
    /// 设置标题
    func setTitleLabel(text:String)  {
        titleLabel.text = text
    }
    
    /// 设置封面
    func setPosterImageView(imagePath:String)  {
        guard let url = URL.init(string: imagePath) else {return}
        posterImageView.kf.setImage(with: url)
    }
    
    /// 更换播放按钮状态图标
    func changePlayButton(imageName:String)  {
        playButton.setImage(UIImage.init(named: imageName), for: .normal)
    }
    
    /// 更换全屏切换按钮图标
    func changeFullScreenButton(imageName:String)  {
        fullScreenButton.setImage(UIImage.init(named: imageName), for: .normal)
    }
    
    /// 设置总时间
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
        bottomBar.isHidden = hidden
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
