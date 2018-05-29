//
//  Extensions.swift
//  KiNetworking
//
//  Created by Anh Phan Tran on 28/05/2018.
//

import Foundation
import Alamofire

// MARK: - Dictionary Extension
public extension Dictionary where Key == String, Value == Any {
  public func urlEncodedString(base: String = "") throws -> String {
    guard self.count > 0 else { return "" } // nothing to encode
    let items: [URLQueryItem] = self.compactMap { arg in
      return URLQueryItem(name: arg.key, value: String(describing: arg.value))
    }
    var urlComponents = URLComponents(string: base)!
    urlComponents.queryItems = items
    guard let encodedString = urlComponents.url else {
      throw APIError.dataIsNotEncodable(self)
    }
    return encodedString.absoluteString
  }
}

public extension String {
  public func stringByAdding(urlEncodedFields fields: Parameters?) throws -> String {
    guard let f = fields else { return self }
    return try f.urlEncodedString(base: self)
  }
}
