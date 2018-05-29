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

public struct RequestBody {
  
  let data: Any
  
  let encoding: Encoding

  public enum Encoding {
    case rawData
    case rawString(_: String.Encoding?)
    case json
    case urlEncoded(_: String.Encoding?)
    case custom(_: CustomEncoder)
    
    /// Encoder function typealias
    public typealias CustomEncoder = ((Any) -> (Data))
  }
  
  private init(_ data: Any, as encoding: Encoding = .json) {
    self.data = data
    self.encoding = encoding
  }
  
  public static func json(_ data: Any) -> RequestBody {
    return RequestBody(data, as: .json)
  }
  
  public static func urlEncoded(_ data: Parameters, encoding: String.Encoding? = .utf8) -> RequestBody {
    return RequestBody(data, as: .urlEncoded(encoding))
  }
  
  public static func raw(data: Data) -> RequestBody {
    return RequestBody(data, as: .rawData)
  }
  
  public static func raw(string: String, encoding: String.Encoding? = .utf8) -> RequestBody {
    return RequestBody(string, as: .rawString(encoding))
  }
  
  public static func custom(_ data: Data, encoder: @escaping Encoding.CustomEncoder) -> RequestBody {
    return RequestBody(data, as: .custom(encoder))
  }
  
  public func encodedData() throws -> Data {
    switch self.encoding {
    case .rawData:
      return self.data as! Data
    case .rawString(let encoding):
      guard let string = (self.data as! String).data(using: encoding ?? .utf8) else {
        throw APIError.dataIsNotEncodable(self.data)
      }
      return string
    case .json:
      return try JSONSerialization.data(withJSONObject: self.data, options: [])
    case .urlEncoded(let encoding):
      let encodedString = try (self.data as! Parameters).urlEncodedString()
      guard let data = encodedString.data(using: encoding ?? .utf8) else {
        throw APIError.dataIsNotEncodable(encodedString)
      }
      return data
    case .custom(let encodingFunc):  return encodingFunc(self.data)
    }
  }
  
  public func encodedString(_ encoding: String.Encoding = .utf8) throws -> String {
    let encodedData = try self.encodedData()
    guard let stringRepresentation = String(data: encodedData, encoding: encoding) else {
      throw APIError.stringFailedToDecode(encodedData, encoding: encoding)
    }
    return stringRepresentation
  }
}
