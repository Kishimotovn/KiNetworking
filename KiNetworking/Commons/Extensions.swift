//
//  Extensions.swift
//  KiNetworking
//
//  Created by Anh Phan Tran on 28/05/2018.
//

import Foundation
import Alamofire

public extension String {
  func stringByAdding(urlEncodedFields fields: Parameters?) throws -> String {
    guard let f = fields else { return self }

    var urlComponents = URLComponents(string: self)!

    urlComponents.queryItems = f.map { field -> URLQueryItem in
      return URLQueryItem(name: field.key, value: "\(field.value)".escaped())
    }

    guard let encodedString = urlComponents.url else {
      throw APIError.dataIsNotEncodable(self)
    }
    return encodedString.absoluteString
  }

  func escaped() -> String {
    let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
    let subDelimitersToEncode = "!$&'()*+;="

    var allowedCharacterSet = CharacterSet.urlQueryAllowed
    allowedCharacterSet.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")

    return self.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) ?? self
  }
}
