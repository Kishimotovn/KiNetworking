//
//  Response.swift
//  KiNetworking
//
//  Created by Anh Phan Tran on 28/05/2018.
//

import Foundation
import Alamofire
import SwiftyJSON

public class Response: ResponseProtocol {
  public enum Result {
    case success(_: Int)
    case error(_: Int)
    case noResponse
    
    private static let successCodes: Range<Int> = 200..<299
    
    public static func from(response: HTTPURLResponse?) -> Result {
      guard let r = response else {
        return .noResponse
      }
      return (Result.successCodes.contains(r.statusCode) ? .success(r.statusCode) : .error(r.statusCode))
    }
    
    public var code: Int? {
      switch self {
      case .success(let code):   return code
      case .error(let code):    return code
      case .noResponse:      return nil
      }
    }
  }
  
  public let result: Response.Result
  
  public var httpStatusCode: Int? {
    return self.result.code
  }
  
  public let httpResponse: HTTPURLResponse?
  
  public var data: Data?
  
  public let request: RequestProtocol
  
  public var metrics: ResponseTimeline?
  
  public init(afResponse response: DefaultDataResponse, request: RequestProtocol) {
    self.result = Result.from(response: response.response)
    self.httpResponse = response.response
    self.data = response.data
    self.request = request
    self.metrics = response.timeline
  }
  
  public func toJSON() -> JSON {
    return self.cachedJSON
  }
  
  public func toString(_ encoding: String.Encoding? = nil) -> String? {
    guard let d = self.data else { return nil }
    return String(data: d, encoding: encoding ?? .utf8)
  }
  
  private lazy var cachedJSON: JSON = {
    do {
      return try JSON(data: self.data ?? Data())
    } catch let error {
      return JSON([:])
    }
  }()
}
