//
//  APIService.swift
//  KiNetworking
//
//  Created by Anh Phan Tran on 28/05/2018.
//

import Foundation
import Promises
import Alamofire

public class APIService: APIServiceProtocol {
  public var configuration: APIServiceConfig
  public var headers: HeadersDict {
    return self.configuration.commonHeaders
  }

  public required init(_ config: APIServiceConfig) {
    self.configuration = config
  }

  public func execute(_ request: RequestProtocol) -> Promise<ResponseProtocol> {
    let promise = Promise<ResponseProtocol>.init(on: request.context ?? .global(qos: .background)) { fullfill, reject in
      let dataRequest = try Alamofire.request(request.urlRequest(in: self))

      if self.configuration.debugEnabled.rawValue >= 1 {
        debugPrint("-----------------------------")
        debugPrint("Requested:")
        debugPrint("    Method: \(request.method.rawValue)")
        debugPrint("    URL: \(dataRequest.request?.url?.absoluteString ?? "N/A")")
        debugPrint("    Params: \(request.parameters ?? [:])")
        debugPrint("    Headers : \(dataRequest.request?.allHTTPHeaderFields ?? [:])")
        debugPrint("    Body: \(String(describing: try? request.body?.encodedString() ?? "Empty"))")
        debugPrint("-----------------------------")
      }
      
      dataRequest.response { responseData in
        let parsedResponse = Response(afResponse: responseData, request: request)
        if self.configuration.debugEnabled.rawValue >= 1 {
          debugPrint("-----------------------------")
          debugPrint("Response:")
          debugPrint("    Method: \(request.method.rawValue)")
          debugPrint("    URL: \(dataRequest.request?.url?.absoluteString ?? "N/A")")
          debugPrint("    Params: \(request.parameters ?? [:])")
          debugPrint("    Took (seconds): \(parsedResponse.metrics?.totalDuration ?? 0)")
          debugPrint("    Status Code: \(parsedResponse.httpStatusCode ?? -1)")
          if self.configuration.debugEnabled.rawValue >= 2 {
            debugPrint("    Response: \(parsedResponse.toString() ?? "Empty")")
          } else {
            switch parsedResponse.result {
            case .error:
              debugPrint("    Response: \(parsedResponse.toString() ?? "Empty")")
            case .noResponse:
              debugPrint("    No Response...")
            default:
              break
            }
          }
          debugPrint("-----------------------------")
        }
        switch parsedResponse.result {
        case .success:
          fullfill(parsedResponse)
        case .error(let code):
          if
            var jwtRequest = request as? JWTRequestProtocol,
            code == jwtRequest.accessTokenUnauthorizeCode,
            !jwtRequest.refreshed
          {
            if self.configuration.debugEnabled.rawValue >= 1 {
              debugPrint("-----------------------------")
              debugPrint("Requesting new access token...")
              debugPrint("-----------------------------")
            }
            jwtRequest.refresh().then { updatedAccessToken, updatedRefreshToken in
              if self.configuration.debugEnabled.rawValue >= 1 {
                debugPrint("-----------------------------")
                debugPrint("Got new tokens:")
                debugPrint("    AccessToken: \(updatedAccessToken)")
                debugPrint("    RefreshToken: \(updatedRefreshToken)")
                debugPrint("-----------------------------")
                jwtRequest.refreshed = true
                jwtRequest.authorize()
              }
            }.then { _ in
              return self.execute(request)
            }
            .catch { error in
              jwtRequest.refreshed = true
              reject(error)
            }
          } else {
            reject(APIError.error(parsedResponse))
          }
        case .noResponse:
          reject(APIError.noResponse(parsedResponse))
        }
      }
    }
    return promise
  }
}
