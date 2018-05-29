//
//  JSONAPIOperation.swift
//  KiNetworking
//
//  Created by Anh Phan Tran on 28/05/2018.
//

import Foundation
import SwiftyJSON
import Promises

open class JSONOperation<Output>: APIOperationProtocol {
  typealias T = Output

  public var request: RequestProtocol?
  public var onParseResponse: ((JSON) throws -> (Output))? = nil

  public init() {
    self.onParseResponse = { _ in
      fatalError("You must implement a `onParseResponse` to return your <Output> from JSONOperation")
    }
  }

  public func execute(in service: APIServiceProtocol) -> Promise<Output> {
    let promise = Promise<Output> { fullfill, reject in
      guard let request = self.request else {
        reject(APIError.missingEndpoint)
        return
      }

      service.execute(request).then { response in
        let json = response.toJSON()
        do {
          let parsedObj = try self.onParseResponse!(json)
          fullfill(parsedObj)
        } catch {
          throw APIError.failedToParseJSON(json, response)
        }
      }.catch(reject)
    }
    return promise
  }
}
