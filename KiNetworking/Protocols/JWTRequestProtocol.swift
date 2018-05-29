//
//  JWTRequestProtocol.swift
//  KiNetworking
//
//  Created by Anh Phan Tran on 28/05/2018.
//

import Foundation
import Promises

public protocol JWTRequestProtocol: RequestProtocol {
  var accessToken: String { get }
  var refreshToken: String { get }
  var accessTokenUnauthorizeCode: Int { get }
  var refreshed: Bool { get set }

  func refresh() -> Promise<(String, String)>
  mutating func authorize()
}

public extension JWTRequestProtocol {
  mutating func authorize() {
    if self.additionalHeaders == nil {
      self.additionalHeaders = ["Authorization": "Bearer \(self.accessToken)"]
    } else {
      self.additionalHeaders!["Authorization"] = "Bearer \(self.accessToken)"
    }
  }
}
