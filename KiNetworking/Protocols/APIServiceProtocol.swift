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
  var delegate: APIServiceDelegate? { get set }

  init(_ config: APIServiceConfig, delegate: APIServiceDelegate?)

  func execute(_ request: RequestProtocol) -> Promise<ResponseProtocol>
}
