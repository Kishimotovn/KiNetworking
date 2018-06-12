//
//  Extensions.swift
//  KiNetworking
//
//  Created by Anh Phan Tran on 28/05/2018.
//

import Foundation
import Alamofire

public extension String {
  public func stringByAdding(urlEncodedFields fields: Parameters?) throws -> String {
    guard let f = fields else { return self }
    var components: [(String, String)] = []
    
    for key in f.keys.sorted(by: <) {
      let value = f[key]!
      components += URLEncoding.default.queryComponents(fromKey: key, value: value)
    }
    
    var urlComponents = URLComponents(string: self)!
    urlComponents.queryItems = components.map {
      return URLQueryItem(name: $0.0, value: $0.1)
    }

    guard let encodedString = urlComponents.url else {
      throw APIError.dataIsNotEncodable(self)
    }
    return encodedString.absoluteString
  }
}
