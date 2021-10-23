//
//  JMHTTPDataTask.swift
//  JMNetworkKit_Example
//
//  Created by 马克吐温° on 2020/1/22.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import HandyJSON

public enum JMRequestMethod {
    case post
    case get
    case put
}

public class JMBaseResponse<T:HandyJSON>: HandyJSON {
    public var code: Int = 0 // 服务端返回码
    public var data: T = T() // 具体的data的格式和业务相关，故用泛型定义
    public var message: String = ""
    public var success: Bool = true
    public required init() {}
}

open class JMHTTPDataTask: NSObject, HandyJSON{
    
    public var disposeBag: DisposeBag = DisposeBag()
    
    ///是否显示HUD
    public lazy var showHUD: Bool = true
    
    ///是否显示loading
    public lazy var showLoading: Bool = true
    
    ///请求url
    public var urlString: String = ""
    
    ///开启模拟数据
    public var openSimulationData: Bool = false
    
    ///持久化请求数据
    public var saveLocalRequest: Bool = false
    
    ///个性化header (除特殊请求外，其他不需要设置)
    public var personalizedHeader: [String: String]?

    required override public init() {}

    ///请求前调用，可做数据处理
    open func willRequest(){}

    ///模拟数据填充
    open func returnSimulateResponse<T>(_ type: T.Type) -> String{
        return ""
    }
        
    ///mapping后调用
    open func didFinishMapping() {}
}

public extension JMHTTPDataTask{
    func post<T:HandyJSON>(_ type: T.Type, showHUD: Bool = true, showLoading: Bool = true) -> Single<JMBaseResponse<T>>{
        self.requestMethod(T.self, method: .post, showHUD: showHUD, showLoading: showLoading)
    }
    
    func get<T:HandyJSON>(_ type: T.Type, showHUD: Bool = true, showLoading: Bool = true) -> Single<JMBaseResponse<T>>{
        self.requestMethod(T.self, method: .get, showHUD: showHUD, showLoading: showLoading)
    }

    func put<T:HandyJSON>(_ type: T.Type, showHUD: Bool = true, showLoading: Bool = true) -> Single<JMBaseResponse<T>>{
        self.requestMethod(T.self, method: .put, showHUD: showHUD, showLoading: showLoading)
    }
    
    func localRequestKey() -> String {
        return "Request"+"\(type(of: self))"
    }

    func localResponseKey() -> String {
        return "Responce"+"\(type(of: self))"
    }
}

public extension JMHTTPDataTask{
    func requestMethod<T:HandyJSON>(_ type: T.Type, method: JMRequestMethod, showHUD: Bool = true, showLoading: Bool = true) -> Single<JMBaseResponse<T>>{
        self.showHUD = showHUD
        self.showLoading = showLoading
        return self.returnSingleWithRequestMethod(T.self, method: method)
    }
    
    func returnSingleWithRequestMethod<T:HandyJSON>(_ type: T.Type, method: JMRequestMethod) -> Single<JMBaseResponse<T>>{
        
        let parameters = self.filterRequestParameters()
        
        let single: Single = self.handlerRequestParameters(parameters: parameters).flatMap { (parameters) -> Single<Any> in
            
            if self.showLoading == true{
                JMLoading.statLoading()
            }
            //打开模拟数据开关返回模拟数据
            if self.openSimulationData == true{
                return Single<Any>.create { (single) -> Disposable in
                    single(.success(self.toJsonFile(type)))
                    return Disposables.create()
                }.delay(DispatchTimeInterval.milliseconds(200), scheduler: MainScheduler.instance)
            }
            //返回网络请求信号
            return self.httpRequesWithParameters(parameters: parameters, method: method)
        }.flatMap { (responce) -> Single<JMBaseResponse<T>> in
            //是否储存数据到本地
            if self.saveLocalRequest == true{
                self.saveLocalRequest(request: parameters)
                self.saveLocalResponce(responce: responce)
            }
            return self.handlerResponesParameters(responce: responce, retrunType: T.self)
        }.catchError { (error) -> Single<JMBaseResponse<T>> in
            
            return self.handlerError(error: error as! JMHTTPError)
        }
        return single
    }

    func httpRequesWithParameters(parameters: [String: Any]? = nil, method: JMRequestMethod) -> Single<Any>{
        return JMNetworkManager.shared.networkRequest(method: method, urlStr: self.urlString, parameters: parameters, header: self.personalizedHeader)
    }

    func handlerRequestParameters(parameters: [String: Any]? = nil) -> Single<[String: Any]?>{
        return Single.create { (single) -> Disposable in
                
            single(.success(parameters))

            return Disposables.create()
        }
    }
    
    //网络响应处理
    func handlerResponesParameters<T:HandyJSON>(responce: Any, retrunType: T.Type) -> Single<JMBaseResponse<T>>{
        
        return Single.create { (single) -> Disposable in
            
            if self.showLoading == true{
                JMLoading.stopLoading()
            }
            
            guard let json = responce as? [String: Any] else{
                single(.error(JMHTTPError.structureError))
                return Disposables.create()
            }
            
            guard let responseModel = JMBaseResponse<T>.deserialize(from: json) else {
                single(.error(JMHTTPError.parseError))
                return Disposables.create()
            }
            
            guard responseModel.success == true else {
               
                single(.error(JMHTTPError.errorMessage(message: responseModel.message, code: responseModel.code)))
               
                if self.showHUD == true && responseModel.code != 401 && responseModel.message.isEmpty == false{
                    JMMessage.showInfo(message: responseModel.message, presentStyle: .center)
                }
                
                //将success后的错误码抛出业务端进行监听
                NotificationCenter.default.post(name: JMNetworkNotification.errorNotification,
                                                object: nil,
                                                userInfo:["error": JMHTTPError.errorMessage(message: responseModel.message, code: responseModel.code),
                                                          "url":self.urlString])
                
                return Disposables.create()
            }
                        
            single(.success(responseModel))

            return Disposables.create()
            
        }
    }
    
    //网络错误处理
    func handlerError<T: HandyJSON>(error: JMHTTPError) -> Single<JMBaseResponse<T>>{
        return Single.create { (single) -> Disposable in
            if self.showLoading == true{
                JMLoading.stopLoading()
            }
            single(.error(error))
            
            //根据变量判断是否直接内部进行错误toast展示
            if self.showHUD == true && error.localizedDescription.isEmpty == false{
                
                JMMessage.showInfo(message: error.localizedDescription, presentStyle: .center)
            }
            return Disposables.create()
        }
    }
    
    //请求参数识别前缀
    func filterRequestParameters() -> [String: Any]{
        self.willRequest()
        let parameters:[String: Any] = self.toJSON() ?? [String: Any]()
        let originalParameters: [String: Any] = parameters
        var filterParameters: Dictionary = [String: Any]()
        for (key, value) in originalParameters {
            if key.contains(JMNetworkManager.shared.configuration.requestParamPrefix) {
                filterParameters.updateValue(value, forKey: String(key.suffix(from: key.index(key.startIndex, offsetBy: JMNetworkManager.shared.configuration.requestParamPrefix.count))))
            }
        }
        return filterParameters
    }
    
    //读取本地假数据Json文件
    func toJsonFile<T>(_ type: T.Type) -> [String: Any] {
        if let jsonPath = Bundle.main.path(forResource: self.returnSimulateResponse(type), ofType: "geojson"){
            if let jsonData: Data = try? Data(contentsOf: URL(fileURLWithPath: jsonPath)) {
                if let json = try? JSONSerialization.jsonObject(with: jsonData, options: .allowFragments) as? [String: Any]{
                    return json
                }
            }
        }
        return [String: Any]()
    }
    
    func saveLocalRequest(request: Any){
        UserDefaults.standard.set(request, forKey: self.localRequestKey())
        UserDefaults.standard.synchronize()
    }
    
    func saveLocalResponce(responce: Any){
        UserDefaults.standard.set(responce, forKey: self.localResponseKey())
        UserDefaults.standard.synchronize()
    }
}
