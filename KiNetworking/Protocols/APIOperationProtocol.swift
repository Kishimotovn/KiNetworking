//
//  APIOperationProtocol.swift
//  KiNetworking
//
//  Created by Anh Phan Tran on 28/05/2018.
//

import Foundation
import Promises

protocol APIOperationProtocol {
  associatedtype T
  
  var request: RequestProtocol? { get set }
  func execute(in service: APIServiceProtocol) -> Promise<T>
}
