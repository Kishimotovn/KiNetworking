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

class SampleJWTRequest: KiNetworking.Request, JWTRequestProtocol {
  var accessToken: String {
    return globalAccessToken
  }
  var refreshToken: String {
    return globalRefreshToken
  }
  var accessTokenUnauthorizeCode: Int = 401
  var refreshed: Bool = false

  func refresh() -> Promise<(String, String)> {
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
    let jwtService = APIService(jwtServiceConfig)
    let promise = Promise<(String, String)> { fullfill, reject in
      RefreshTokenOperation(refreshToken: self.refreshToken).execute(in: jwtService).then { accessToken, refreshToken in
        fullfill((accessToken, refreshToken))
      }.catch { error in
        reject(error)
      }
    }
    return promise
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
