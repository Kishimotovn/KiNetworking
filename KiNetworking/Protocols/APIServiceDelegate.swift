//
//  APIServiceDelegate.swift
//  KiNetworking
//
//  Created by Anh Phan Tran on 06/06/2018.
//

import Foundation
import Promises

public protocol APIServiceDelegate: class {
  func service(_ apiService: APIServiceProtocol, willExecute request: RequestProtocol)
  func service(_ apiService: APIServiceProtocol, shouldHandleCode errorCode: Int, on request: RequestProtocol) -> Bool
  func service(_ apiService: APIServiceProtocol, handleResponse returnedResponse: ResponseProtocol, on request: RequestProtocol) -> Promise<ResponseProtocol>
}
