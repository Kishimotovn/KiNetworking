//
//  RequestProtocol.swift
//  Alamofire
//
//  Created by Anh Phan Tran on 28/05/2018.
//

import Foundation
import Alamofire

public protocol RequestProtocol {
  var endpoint: String { get }
  var parameters: Parameters? { get }
  var additionalHeaders: HeadersDict? { get set }
  var method: Alamofire.HTTPMethod { get }
  var cachePolicy: URLRequest.CachePolicy? { get }
  var timeout: TimeInterval? { get }
  var context: DispatchQueue? { get }
  var body: RequestBody? { get set }

  func headers(in service: APIServiceProtocol) -> HeadersDict
  func fullURL(in service: APIServiceProtocol) throws -> URL
  func urlRequest(in service: APIServiceProtocol) throws -> URLRequest
}

public extension RequestProtocol {
  var context: DispatchQueue? {
    return nil
  }

  var method: Alamofire.HTTPMethod {
    return .get
  }

  var parameters: Parameters? {
    return nil
  }

  var timeout: TimeInterval? {
    return nil
  }

  var cachePolicy: URLRequest.CachePolicy? {
    return nil
  }

  func headers(in service: APIServiceProtocol) -> HeadersDict {
    var headers = service.headers
    self.additionalHeaders?.forEach { k, v in
      headers[k] = v
    }
    return headers
  }

  func fullURL(in service: APIServiceProtocol) throws -> URL {
    let baseURLString = service.configuration.baseURL.absoluteString
    let endpointURLString = baseURLString.appending(self.endpoint)

    let fullURLString = try endpointURLString.stringByAdding(urlEncodedFields: self.parameters)

    guard let validURL = URL(string: fullURLString) else {
      throw APIError.invalidURL(fullURLString)
    }

    return validURL
  }

  func urlRequest(in service: APIServiceProtocol) throws -> URLRequest {
    let requestURL = try self.fullURL(in: service)

    let cachePolicy = self.cachePolicy ?? service.configuration.cachePolicy
    let timeout = self.timeout ?? service.configuration.timeout
    let headers = self.headers(in: service)

    var urlRequest = URLRequest(url: requestURL, cachePolicy: cachePolicy, timeoutInterval: timeout)
    urlRequest.httpMethod = self.method.rawValue
    urlRequest.allHTTPHeaderFields = headers

    if let bodyData = try self.body?.encodedData() { // set body if specified
      urlRequest.httpBody = bodyData
    }

    return urlRequest
  }
}
