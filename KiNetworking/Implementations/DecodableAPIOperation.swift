//
//  CodableAPIOperation.swift
//  Alamofire
//
//  Created by Anh Phan Tran on 27/07/2019.
//

import Foundation
import Promises

open class DecodableOperation<Output: Decodable>: APIOperationProtocol {
  typealias T = Output

  public var request: RequestProtocol?

  public func execute(in service: APIServiceProtocol) -> Promise<Output> {
    let promise = Promise<Output> { fullfill, reject in
      guard let request = self.request else {
        reject(APIError.missingEndpoint)
        return
      }
      
      service.execute(request)
        .validate({response in return response.data != nil})
        .then { response -> T in
          let decoder = JSONDecoder()
          return try decoder.decode(T.self, from: response.data!)
      }
    }
    return promise
  }
}
