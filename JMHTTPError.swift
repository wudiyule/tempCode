//
//  JMHTTPError.swift
//  JMNetworkKit
//
//  Created by 马克吐温° on 2020/3/27.
//

import Foundation

public enum JMHTTPError: Error {
    case errorMessage(message: String, code: Int)
    ///结构错误
    case structureError
    ///解析错误
    case parseError
    ///最外层非Data数据
    case noneDataError
    ///服务端错误
    case serverError
    ///网络错误
    case networkError
}

extension JMHTTPError: LocalizedError {
   public var localizedDescription: String {
        switch self {
        case .parseError:
            return "解析错误"
        case .structureError:
            return "非JSON结构"
        case .noneDataError:
            return "最外层非Data数据"
        case .serverError:
            return "Server error, please try again later"
        case .networkError:
            return "Server error, please try again later"
        case .errorMessage(let message, _):
            return message
        }
    }
    
    public var errorCode: Int {
        switch self {
        case .errorMessage( _, let code):
            return code
        default:
            return 10000000
        }
    }
}
