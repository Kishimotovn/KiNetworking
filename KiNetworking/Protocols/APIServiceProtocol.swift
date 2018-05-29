//
//  APIServiceProtocol.swift
//  KiNetworking
//
//  Created by Anh Phan Tran on 28/05/2018.
//

import Foundation
import Promises

public protocol APIServiceProtocol {
  var configuration: APIServiceConfig { get }
  var headers: HeadersDict { get }

  init(_ config: APIServiceConfig)

  func execute(_ request: RequestProtocol) -> Promise<ResponseProtocol>
}
