//
//  PlayerWrapView.swift
//  albatross
//
//  Created by 雷丹 on 2019/8/12.
//  Copyright © 2019 CZQ. All rights reserved.
//

import UIKit

class DHPlayerWrapView: UIView,DHPlayerViewDelegate  {

    //播放器视图
    var player = DHPlayerView()
    //列表播放代理
    var wrapDelegate:DHPlayerWrapDelegate?

    /// 封面
    var posterImageUrlString : String? {
        didSet{
            player.setPosterImage(imagePath: posterImageUrlString!)
        }
    }
    
    /// 标题
    var title : String? {
        didSet{
            player.setTitle(title: title!)
        }
    }
    
    /// 资源
    var resource_url : URL? {
        didSet{
            player.setResourceUrl(url: resource_url!)
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .black
        player.backgroundColor = .black
        fillElementsToView()
        makeElementsConstraints()
    }

    //    此对象需要copy副本，在序列化初始方法中应用构建
    required init?(coder aDecoder: NSCoder) {
        super.init(frame: CGRect.zero)
        fillElementsToView()
        makeElementsConstraints()
    }
    
    /// 填充到视图
    func fillElementsToView() {
        addSubview(player)
        onStop(player:player)
        player.delegate = self
        player.parentView = self
    }
    
    /// 当视频播放出现错误
    func onError(player: DHPlayerView) {
        if player.resource_url != nil {
            DHMediaTool.shared.remove(ident: player.resource_url!.absoluteString)
        }
    }
    
    /// 当播放被暂停
    func onPause(player: DHPlayerView) {
        
    }
    
    /// 当播放被停止
    func onStop(player: DHPlayerView) {

        if player.resource_url != nil {
            //当视频停止播放，记录播放当前时间
            DHMediaTool.shared.record(ident:player.resource_url!.absoluteString, current: player.currentTime, total: player.totalTimeSecounds)
        }
    }
    
    /// 当视频播放时
    func onPlay(player: DHPlayerView) {
        wrapDelegate?.onPlay(wrap: self)
        //尝试继续播放
        let ctime = DHMediaTool.shared.lastBreakTime(ident: player.resource_url!.absoluteString)
        if ctime != -1 {
            player.seek(time: ctime)
        }
    }
    
    /// 尝试暂停当前播放资源
    func tryPause(){
        if player.state != .stop {
            player.pause()
        }
    }
    
    /// 应用元素约束
    func makeElementsConstraints(){
        //播放器
        player.backgroundColor = UIColor.black
        player.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalToSuperview()
        }
    }
}
