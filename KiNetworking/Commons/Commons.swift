//
//  Commons.swift
//  KiNetworking
//
//  Created by Anh Phan Tran on 28/05/2018.
//

import Foundation
import SwiftyJSON
import Alamofire

public enum APIError: Error {
  case dataIsNotEncodable(_: Any)
  case stringFailedToDecode(_: Data, encoding: String.Encoding)
  case invalidURL(_: String)
  case error(_: ResponseProtocol)
  case noResponse(_: ResponseProtocol)
  case missingEndpoint
  case failedToParseJSON(_: JSON, _: ResponseProtocol)
  case invalidRefreshTokensCredentials
}

public typealias HeadersDict = [String: String]
