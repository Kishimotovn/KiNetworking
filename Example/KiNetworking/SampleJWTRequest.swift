//
//  SampleJWTRequest.swift
//  KiNetworking_Example
//
//  Created by Anh Phan Tran on 28/05/2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation
import KiNetworking
import Promises
import Alamofire

class SampleJWTServiceDelegate: APIServiceDelegate {
  func service(_ apiService: APIServiceProtocol, willExecute request: RequestProtocol) {
    if let jwtRequest = request as? SampleJWTRequest {
      jwtRequest.authorize()
    }
  }
  
  func service(_ apiService: APIServiceProtocol, shouldHandleCode errorCode: Int, on request: RequestProtocol) -> Bool {
    return ((request as? SampleJWTRequest) != nil) && errorCode == 401
  }
  
  func service(_ apiService: APIServiceProtocol, handleResponse returnedResponse: ResponseProtocol, on request: RequestProtocol) -> Promise<ResponseProtocol> {
    if let jwtRequest = request as? SampleJWTRequest {
      return jwtRequest.refresh(in: apiService)
    }

    return Promise(returnedResponse)
  }
}

class SampleAuthServiceDelegate: APIServiceDelegate {
  func service(_ apiService: APIServiceProtocol, willExecute request: RequestProtocol) { }
  
  func service(_ apiService: APIServiceProtocol, shouldHandleCode errorCode: Int, on request: RequestProtocol) -> Bool {
    return errorCode == 400
  }
  
  func service(_ apiService: APIServiceProtocol, handleResponse returnedResponse: ResponseProtocol, on request: RequestProtocol) -> Promise<ResponseProtocol> {
    return Promise(SampleError.invalidRefreshToken)
  }
}

enum SampleError: Error {
  case invalidRefreshToken
}

class SampleJWTRequest: KiNetworking.Request {
  var accessTokenUnauthorizeCode: Int = 401
  var refreshed: Bool = false

  func refresh(in service: APIServiceProtocol) -> Promise<ResponseProtocol> {
    let jwtServiceConfig = APIServiceConfig(
      name: "JWT",
      base: "https://staging.touchrightsoftware.com",
      commonHeaders: [
        "X-TR-App-Version": "5.0.0",
        "X-TR-Device-Id": "92c635c8e17b68b",
        "X-TR-Device-OS": "Android",
        "X-TR-Device-OS-Version": "7.0"
      ])!
    jwtServiceConfig.debugEnabled = .response
    let jwtService = APIService(jwtServiceConfig, delegate: SampleAuthServiceDelegate())

    return RefreshTokenOperation(refreshToken: globalRefreshToken).execute(in: jwtService).then { accessToken, refreshToken in
      globalAccessToken = accessToken
      globalRefreshToken = refreshToken
    }.then { _ in
      return service.execute(self)
    }
  }

  func authorize() {
    if self.additionalHeaders == nil {
      self.additionalHeaders = ["Authorization": "Bearer \(globalAccessToken)"]
    } else {
      self.additionalHeaders?["Authorization"] = "Bearer \(globalAccessToken)"
    }
  }
}

class RefreshTokenOperation: JSONOperation<(String, String)> {
  public init(refreshToken: String) {
    super.init()
    let refreshParams: Parameters = [
      "grant_type": "refresh_token",
      "client_id": "DISTANCE_ANDROID_DEV",
      "client_secret": "NP7MQpWx21ZA6W82",
      "refresh_token": refreshToken
    ]
    let request = Request(method: .post, endpoint: "/oauth/v2/tokens")
    request.body = RequestBody.urlEncoded(refreshParams)
    self.request = request
    self.onParseResponse = { json in
      guard
        let accessToken = json["access_token"].string,
        let refreshToken = json["refresh_token"].string
      else {
        throw APIError.invalidRefreshTokensCredentials
      }

      globalAccessToken = accessToken
      globalRefreshToken = refreshToken

      return (accessToken, refreshToken)
    }
  }
}
