//
//  APIOperation.swift
//  KiNetworking
//
//  Created by Anh Phan Tran on 28/05/2018.
//

import Foundation
import Promises

open class DataAPIOperation<ResponseProtocol>: APIOperationProtocol {
  typealias T = ResponseProtocol
  
  /// Request to send
  public var request: RequestProtocol?
  
  /// Init
  public init() { }
  
  /// Execute the request in a service and return a promise with server response
  ///
  /// - Parameters:
  ///   - service: service to use
  ///   - retry: retry attempts in case of failure
  /// - Returns: Promise
  public func execute(in service: APIServiceProtocol) -> Promise<ResponseProtocol> {
    let promise = Promise<ResponseProtocol> { fullfill, reject in
      guard let request = self.request else {
        reject(APIError.missingEndpoint)
        return
      }

      service.execute(request).then { response in
        fullfill(response as! ResponseProtocol)
      }.catch(reject)
    }
    return promise
  }
}
