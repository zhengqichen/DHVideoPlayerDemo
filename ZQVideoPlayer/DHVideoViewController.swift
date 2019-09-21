//
//  DHVideoViewController.swift
//  ZQ_Video
//
//  Created by 雷丹 on 2019/8/19.
//  Copyright © 2019 CZQ. All rights reserved.
//

import UIKit

class DHVideoViewController: UIViewController{

    /**播放器包围*/
    lazy var playerView:DHPlayerView = {
        let frame = CGRect(x: 0, y: kNaviBarHeight, width: kWidth, height: playerHeight)
        let subview = DHPlayerView(frame: frame)
        subview.backgroundColor = UIColor.black
        return subview
    }()
    
    /**视频高度*/
    let playerHeight:CGFloat = 200
    
    /**全屏状态*/
    var playerFullScreen:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let subFrame = CGRect(x: 10, y: 44, width: 64, height: 44)
        let dismissBut = UIButton(frame: subFrame)
        dismissBut.setTitle("返回", for: .normal)
        dismissBut.backgroundColor = UIColor.black
        view.addSubview(dismissBut)
        dismissBut.addTarget(self, action: #selector(didmissButClick), for: .touchUpInside)
        
        view.backgroundColor = .white
        view.addSubview(playerView)
        playerView.delegate = self
    }
    
    /// 加载播放资源(网络)
    func setResourceDataForNet(resource:URL,title:String?,posterImageString:String?){
        playerView.setResourceDataForNet(resource: resource, title: title, posterImageString: posterImageString)
        playerView.initPlay()
    }
    
    /// 加载播放资源(本地)
    func setResourceDataForLocation(resource:URL,title:String?,posterImage:UIImage?){
        playerView.setResourceDataForLocation(resource: resource, title: title, posterImage: posterImage)
    }

    /// 用于根据全屏切换状态栏样式
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if playerFullScreen{
            return .lightContent
        }
        else{
            return .default
        }
    }

    /// 当视图即将消失
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        //释放播放器
        print("viewDidDisappear")
        playerView.stop()
    }

    @objc func didmissButClick()  {
        self.dismiss(animated: true, completion: nil)
    }
    
    deinit {
        playerView.stop()
    }
}

extension DHVideoViewController:DHPlayerViewDelegate{
    /// 当视频播放时
    ///
    /// - Parameter player: player description
    func onPlay(player:DHPlayerView){
        
    }
    
    /// 当播放被暂停
    ///
    /// - Parameter player: player description
    func onPause(player:DHPlayerView){
        
    }
    
    /// 当播放被停止
    ///
    /// - Parameter player: player description
    func onStop(player:DHPlayerView){
        
    }
    
    /// 当视频播放出现错误
    ///
    /// - Parameter player: player description
    func onError(player:DHPlayerView){
        
    }
}
