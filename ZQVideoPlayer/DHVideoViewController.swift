//
//  DHVideoViewController.swift
//  ZQ_Video
//
//  Created by 雷丹 on 2019/8/19.
//  Copyright © 2019 CZQ. All rights reserved.
//

import UIKit

class DHVideoViewController: UIViewController,DHPlayerWrapDelegate{
    
    /**播放器包围*/
    lazy var wrapView:DHPlayerWrapView = {
        let frame = CGRect(x: 0, y: kNaviBarHeight, width: kWidth, height: playerHeight)
        let subview = DHPlayerWrapView(frame: frame)
        subview.backgroundColor = UIColor.black
        subview.player.backgroundColor = UIColor.black
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
        
        let subFrame = CGRect(x: 10, y: 44, width: 64, height: 44)
        let dismissBut = UIButton(frame: subFrame)
        dismissBut.setTitle("返回", for: .normal)
        dismissBut.backgroundColor = UIColor.black
        view.addSubview(dismissBut)
        dismissBut.addTarget(self, action: #selector(didmissButClick), for: .touchUpInside)
    }
    
    /// 加载播放资源(网络)
    func setResourceDataForNet(resource:URL,title:String?,posterImageString:String?){
        wrapView.setResourceDataForNet(resource: resource, title: title, posterImageString: posterImageString)
    }
    
    /// 加载播放资源(本地)
    func setResourceDataForLocation(resource:URL,title:String?,posterImage:UIImage?){
        wrapView.setResourceDataForLocation(resource: resource, title: title, posterImage: posterImage)
    }
    
    

    /// 当播放时触发
    func onPlay(wrap: DHPlayerWrapView) {}
    
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
    
    
    @objc func didmissButClick()  {
        self.dismiss(animated: true, completion: nil)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        wrapView.setRate(2.0)
    }
}
