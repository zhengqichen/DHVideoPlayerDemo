//
//  ViewController.swift
//  ZQVideoPlayer
//
//  Created by 雷丹 on 2019/8/16.
//  Copyright © 2019 CZQ. All rights reserved.
//

import UIKit

class ViewController: UIViewController,DHPlayerWrapDelegate{
    
    /**播放器包围*/
    lazy var wrapView:DHPlayerWrapView = {
        let subview = DHPlayerWrapView()
        subview.backgroundColor = UIColor.black
        subview.player.backgroundColor = UIColor.black
        subview.frame = CGRect(x: 0, y: kNaviBarHeight, width: kWidth, height: playerHeight)
        subview.backgroundColor = UIColor.white
        return subview
    }()
    /**视频高度*/
    let playerHeight:CGFloat = 200
    /**全屏状态*/
    var playerFullScreen:Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(wrapView)
        wrapView.wrapDelegate = self
        wrapView.resource_url =  URL(string: "http://video.pearvideo.com/mp4/adshort/20190808/cont-1587931-14237006_adpkg-ad_sd.mp4")
        wrapView.posterImageUrlString = "http://goo.image.seegif.com/i/190812/100338334876.png"
        wrapView.title = "东红烤羊"
        wrapView.player.initPlay()
    }
    
    /// 当播放时触发
    ///
    /// - Parameter wrap: wrap description
    func onPlay(wrap: DHPlayerWrapView) {
        
    }
    
    /// 用于根据全屏切换状态栏样式
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if self.playerFullScreen{
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
        wrapView.player.stop()
    }
    
}
