//
//  RequestBody.swift
//  Alamofire
//
//  Created by Anh Phan Tran on 12/06/2018.
//

import Foundation
import SwiftyJSON
import Alamofire

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
  
  public static func encodable<T: Encodable>(_ encodable: T) throws -> RequestBody {
    let encoder = JSONEncoder()
    let data = try encoder.encode(encodable)
    return RequestBody(data, as: .rawData)
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
      let encodedString = self.query(self.data as! Parameters)
      guard let data = encodedString.data(using: encoding ?? .utf8, allowLossyConversion: false) else {
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

  private func query(_ parameters: Parameters) -> String {
    var components: [(String, String)] = []
    
    for key in parameters.keys.sorted(by: <) {
      let value = parameters[key]!
      components += URLEncoding.default.queryComponents(fromKey: key, value: value)
    }
    return components.map { "\($0)=\($1)" }.joined(separator: "&")
  }
}
