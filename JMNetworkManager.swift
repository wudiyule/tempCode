////
////  JMNetworkManager.swift
////  JMNetworkKit_Example
////
////  Created by 马克吐温° on 2020/1/21.
////  Copyright © 2020 CocoaPods. All rights reserved.
////

import Foundation
import Alamofire
import RxCocoa
import RxSwift

public class JMNetworkManager: NSObject{
    
    public static let shared: JMNetworkManager = JMNetworkManager.init()
    
    public var configuration: JMHTTPConfiguration = JMHTTPConfiguration.defaultConfiguration()
    
    public var sessionManager: Session = Session.default
    
    public func setConfiguration(configuration:JMHTTPConfiguration){
       
        self.configuration = configuration
        
        let config = URLSessionConfiguration.default
        
        config.timeoutIntervalForRequest = self.configuration.timeoutIntervalForRequest
        
        self.sessionManager = Session.init(configuration: config)
    }
}


extension JMNetworkManager{
    
    func networkRequest(method: JMRequestMethod ,urlStr:String, parameters:[String: Any]? = nil, header: [String: String]? = nil) -> Single<Any> {
        switch method {
        case .post:
            return self.baseRequest(urlStr: urlStr, parameters: parameters, method: .post, encoding: JSONEncoding.default, header: header)
        case .get:
            return self.baseRequest(urlStr: urlStr, parameters: parameters, method: .get, encoding: URLEncoding.default, header: header)
        case .put:
            return self.baseRequest(urlStr: urlStr, parameters: parameters, method: .put, encoding: JSONEncoding.default, header: header)
        }
    }
    
    func baseRequest(urlStr: String, parameters:[String: Any]? = nil, method: HTTPMethod, encoding: ParameterEncoding, header: [String: String]? = nil) -> Single<Any> {
    
        // 获取默认header
        let defaultHeader = self.configuration.defaultHeader()
        
        return Single<Any>.create { (single) -> Disposable in
            self.sessionManager.request(urlStr, method: method, parameters: parameters, encoding: encoding, headers:HTTPHeaders(header ?? defaultHeader)).responseJSON(completionHandler: { (response) in
                
                #if DEBUG
                if JMNetworkManager.shared.configuration.showLog == true {
                    print("\n=========== request info ===========")
                    print("request url: \(urlStr)")
                    print("request method: \(method.rawValue)")
                    print("request headers: \(response.request?.allHTTPHeaderFields ?? [:])")
                    print("request parameters: \(parameters ?? [:])")
                    let jsonString = self.jsonResponseDataFormatter(response.data ?? Data())
                    print("\nresponse data: \(jsonString)")
                    print("=========== request info ===========\n")
                }
                #endif
                
                guard response.value != nil else {
                    if response.error != nil{
                        single(.error(JMHTTPError.networkError))
                    }
                    return
                }
                
                if response.response?.statusCode == 200{
                    single(.success(response.value!))
                }else{
                    single(.error(JMHTTPError.serverError))
                }
                
                if response.response?.statusCode == 401 {
                    NotificationCenter.default.post(name: JMNetworkNotification.errorNotification,
                                                    object: nil,
                                                    userInfo:["error": JMHTTPError.errorMessage(message: response.response?.description ?? "", code: 401),
                                                              "url":urlStr])
                }
            })
            return Disposables.create()
        }
    }
    
    private func jsonResponseDataFormatter(_ data: Data) -> String {
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
            let jsonData = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
            let jsonString = String(data: jsonData, encoding: String.Encoding.utf8)
            return jsonString ?? "## Cannot map data to String ##"
        } catch {
            return "## Cannot map data to String ##"
        }
    }
}
