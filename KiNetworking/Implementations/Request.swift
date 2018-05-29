//
//  Request.swift
//  KiNetworking
//
//  Created by Anh Phan Tran on 28/05/2018.
//

import Foundation
import Promises
import SwiftyJSON
import Alamofire

open class Request: RequestProtocol {
  public var additionalHeaders: HeadersDict?
  public var context: DispatchQueue?
  public var endpoint: String
  public var method: Alamofire.HTTPMethod
  public var cachePolicy: URLRequest.CachePolicy?
  public var timeout: TimeInterval?
  public var parameters: Parameters?
  public var body: RequestBody?

  public init(method: Alamofire.HTTPMethod = .get, endpoint: String = "", parameters: Parameters? = nil, body: RequestBody? = nil) {
    self.method = method
    self.endpoint = endpoint
    self.parameters = parameters
    self.body = body
  }
}
