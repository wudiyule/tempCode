//
//  JMHTTPConfiguration.swift
//  JMNetworkKit_Example
//
//  Created by 马克吐温° on 2020/1/21.
//  Copyright © 2020 CocoaPods. All rights reserved.
//
//
import Foundation
import Alamofire

public class JMHTTPConfiguration{
    /// 请求超时时间
    public var timeoutIntervalForRequest: TimeInterval = 30
    /// 请求参数识别前缀
    public var requestParamPrefix: String = ""
    /// 默认请求头
    public var defaultHeader: (() -> [String : String]) = { [:] }
    /// 公共请求参数
    public var requestPublicParam: Dictionary = [String: Any]()
    /// 是否允许控制台打印日志
    public var showLog: Bool = false
    
    public static func defaultConfiguration()-> JMHTTPConfiguration{
        let configuration: JMHTTPConfiguration = JMHTTPConfiguration.init()
        configuration.timeoutIntervalForRequest = 30
        configuration.requestParamPrefix = "req_"
        configuration.requestPublicParam = [String: Any]()
        return configuration
    }
    
}
