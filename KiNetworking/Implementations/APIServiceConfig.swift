//
//  APIServiceConfig.swift
//  KiNetworking
//
//  Created by Anh Phan Tran on 28/05/2018.
//

import Foundation

public final class APIServiceConfig {
  public enum DebugLevel: Int {
    case none = 0
    case request
    case response
  }

  private(set) var name: String
  private(set) var baseURL: URL
  private(set) var commonHeaders: HeadersDict
  public var cachePolicy: URLRequest.CachePolicy = URLRequest.CachePolicy.useProtocolCachePolicy
  public var timeout: TimeInterval = 15.0
  public var debugEnabled: DebugLevel = .none

  public init?(name: String? = nil, base urlString: String, commonHeaders: HeadersDict) {
    guard let url = URL(string: urlString) else { return nil }
    self.baseURL = url
    self.name = name ?? (url.host ?? "")
    self.commonHeaders = commonHeaders
  }
}

extension APIServiceConfig: CustomStringConvertible {
  public var description: String {
    return "\(self.name): \(self.baseURL.absoluteString)"
  }
}

extension APIServiceConfig: Equatable {
  public static func ==(lhs: APIServiceConfig, rhs: APIServiceConfig) -> Bool {
    return lhs.baseURL.absoluteString.lowercased() == rhs.baseURL.absoluteString.lowercased()
  }
}
