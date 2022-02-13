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
  public var decoder: JSONDecoder?

  public init() { }

  open func execute(in service: APIServiceProtocol) -> Promise<Output> {
    let promise = Promise<Output> { fullfill, reject in
      guard let request = self.request else {
        reject(APIError.missingEndpoint)
        return
      }
      
      service.execute(request)
        .then { response in
          guard let data = response.data else {
            throw APIError.noResponse(response)
          }

          do {
            if self.decoder == nil {
              self.decoder = JSONDecoder()
            }
            let output = try self.decoder!.decode(T.self, from: data)
            fullfill(output)
          } catch {
            throw APIError.dataIsNotDecodable(response)
          }
        }.catch(reject)
    }
    return promise
  }
}
