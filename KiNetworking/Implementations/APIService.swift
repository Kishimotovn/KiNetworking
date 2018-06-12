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
  public var delegate: APIServiceDelegate?

  public required init(_ config: APIServiceConfig, delegate: APIServiceDelegate?) {
    self.configuration = config
    self.delegate = delegate
  }

  public func execute(_ request: RequestProtocol) -> Promise<ResponseProtocol> {
    let promise = Promise<ResponseProtocol>.init(on: request.context ?? .global(qos: .background)) { fullfill, reject in
      // Attempt to automatically a content type header
      self.addContentTypeHeaderIfNeeded(for: request)

      self.delegate?.service(self, willExecute: request)
  
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
          if self.delegate?.service(self, shouldHandleCode: code, on: request) == true {
            self.delegate?.service(self, handleResponse: parsedResponse, on: request).then { recoveredResponse in
              fullfill(recoveredResponse)
            }.catch { error in
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

  private func addContentTypeHeaderIfNeeded(for request: RequestProtocol) {
    if let encoding = request.body?.encoding, request.additionalHeaders?["Content-Type"] == nil {
      var contentType: String?
      switch encoding {
      case .json:
        contentType = "application/json"
      case .urlEncoded:
        contentType = "application/x-www-form-urlencoded"
      default:
        break
      }
      
      var mutatedRequest = request
      if let contentType = contentType {
        if request.additionalHeaders != nil {
          mutatedRequest.additionalHeaders!["Content-Type"] = contentType
        } else {
          mutatedRequest.additionalHeaders = ["Content-Type": contentType]
        }
      }
    }
  }
}
