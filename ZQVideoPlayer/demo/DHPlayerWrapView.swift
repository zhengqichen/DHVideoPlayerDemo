

//  PlayerWrapView.swift
//  albatross
//
//  Created by 雷丹 on 2019/8/12.
//  Copyright © 2019 CZQ. All rights reserved.


import UIKit

class DHPlayerWrapView: UIView,DHPlayerViewDelegate  {

    //播放器视图
    var player : DHPlayerView!

    //列表播放代理
    var wrapDelegate:DHPlayerWrapDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .black
        player = DHPlayerView(frame: bounds)
        player.backgroundColor = UIColor.black
        addSubview(player)
        onStop(player:player)
        player.delegate = self
        player.parentView = self
    }
    
    /// 加载播放资源(网络)
    func setResourceDataForNet(resource:URL,title:String?,posterImageString:String?,isPlay:Bool=true){
        player.setResourceUrl(url: resource)
        if let title = title {
            player.setTitle(title: title)
        }
        if let posterImageString = posterImageString {
            player.setPosterImage(imagePath: posterImageString)
        }
        if isPlay{
            play()
        }
    }

    /// 加载播放资源(本地)
    func setResourceDataForLocation(resource:URL,title:String?,posterImage:UIImage?,isPlay:Bool=true){
        player.setResourceUrl(url: resource)
        if let title = title {
            player.setTitle(title: title)
        }
        if let posterImage = posterImage {
            player.setPosterImage(image: posterImage)
        }
        if isPlay{
            play()
        }
    }

    /// 播放
    func play()  {
        player.initPlay()
    }

    // 此对象需要copy副本，在序列化初始方法中应用构建
    required init?(coder aDecoder: NSCoder) {
        super.init(frame: CGRect.zero)
        player = DHPlayerView(frame: bounds)
        player.backgroundColor = UIColor.black
        addSubview(player)
        onStop(player:player)
        player.delegate = self
        player.parentView = self
    }

    /// 当视频播放出现错误
    func onError(player: DHPlayerView) {
        wrapDelegate?.onError()
        if player.resource_url != nil {
            DHMediaTool.shared.remove(ident: player.resource_url!.absoluteString)
        }
    }

    /// 当播放被暂停
    func onPause(player: DHPlayerView) {
        wrapDelegate?.onPause()
    }

    /// 当播放被停止
    func onStop(player: DHPlayerView) {
        wrapDelegate?.onStop()
        if player.resource_url != nil {
            //当视频停止播放，记录播放当前时间
            DHMediaTool.shared.record(ident:player.resource_url!.absoluteString, current: player.currentTime, total: player.totalTimeSecounds)
        }
    }

    /// 当视频播放时
    func onPlay(player: DHPlayerView) {
        wrapDelegate?.onPlay()
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
}
