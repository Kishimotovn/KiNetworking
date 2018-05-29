//
//  ResponseProtocol.swift
//  KiNetworking
//
//  Created by Anh Phan Tran on 28/05/2018.
//

import Foundation
import SwiftyJSON
import Alamofire

public protocol ResponseTimeline: CustomStringConvertible {
  
  /// The time the request was initialized.
  var requestStartTime: CFAbsoluteTime { get }
  
  /// The time the first bytes were received from or sent to the server.
  var initialResponseTime: CFAbsoluteTime { get }
  
  /// The time when the request was completed.
  var requestCompletedTime: CFAbsoluteTime { get }
  
  /// The time interval in seconds from the time the request started to the initial
  /// response from the server.
  var latency: TimeInterval { get }
  
  /// The time interval in seconds from the time the request started
  /// to the time the request completed.
  var requestDuration: TimeInterval { get }
  
  /// The time interval in seconds from the time the request started
  /// to the time response serialization completed.
  var totalDuration: TimeInterval { get }
}

extension Timeline: ResponseTimeline {
  
}

public protocol ResponseProtocol {
  /// Type of response (success or failure)
  var result: Response.Result { get }
  
  /// Encapsulates the metrics for a session task.
  /// It contains the taskInterval and redirectCount, as well as metrics for each request / response
  /// transaction made during the execution of the task.
  var metrics: ResponseTimeline? { get }
  
  /// Request
  var request: RequestProtocol { get }
  
  /// Return the http url response
  var httpResponse: HTTPURLResponse? { get }
  
  /// Return HTTP status code of the response
  var httpStatusCode: Int? { get }
  
  /// Return the raw Data instance response of the request
  var data: Data? { get }
  
  /// Attempt to decode Data received from server and return a JSON object.
  /// If it fails it will return an empty JSON object.
  /// Value is stored internally so subsequent calls return cached value.
  ///
  /// - Returns: JSON
  func toJSON() -> JSON
  
  /// Attempt to decode Data received from server and return a String object.
  /// If it fails it return `nil`.
  /// Call is not cached but evaluated at each call.
  /// If no encoding is specified, `utf8` is used instead.
  ///
  /// - Parameter encoding: encoding of the data
  /// - Returns: String or `nil` if failed
  func toString(_ encoding: String.Encoding?) -> String?
}
