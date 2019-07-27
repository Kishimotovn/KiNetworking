# KiNetworking

[![CI Status](https://img.shields.io/travis/Anh Phan Tran/KiNetworking.svg?style=flat)](https://travis-ci.org/Anh Phan Tran/KiNetworking)
[![Version](https://img.shields.io/cocoapods/v/KiNetworking.svg?style=flat)](https://cocoapods.org/pods/KiNetworking)
[![License](https://img.shields.io/cocoapods/l/KiNetworking.svg?style=flat)](https://cocoapods.org/pods/KiNetworking)
[![Platform](https://img.shields.io/cocoapods/p/KiNetworking.svg?style=flat)](https://cocoapods.org/pods/KiNetworking)

This library is a modern network layer built for high configuration + TDD
The library has the uasge of Alamofire, Promises and SwiftyJSON to make operations that help you go from API call to model directly.

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

KiNetworking is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following lines to your Podfile:

```ruby
pod 'KiNetworking'
```

## Usage

To make a request, you first need to provide the API service that the request is running on. This is so that you can have a service instance for each of the environment that the app runs on.

An API service requires an APIServiceConfiguration to initialize:

```swift
let config = APIServiceConfig(
  name: "Staging",
  base: "https://stagingBaseURL",
  commonHeaders: [
    "Someheaderkey": "SomeValue"
  ])
config?.debugEnabled = .request // .none, .request, .response
let service = APIService.init(config!)
```

After having the service, you can create a request and execute it on the service like so:

```swift
let request = Request(method: .get, endpoint: "someEndpoint")
request.execute(on: service).then(...).catch(...)
```

The service will invoke the request (request protocol) and return with a response (response protocol).

## Request and request protocol: 
A Request Protocol has these parameters:

```swift
public protocol RequestProtocol {
  // Endpoint of the request
  var endpoint: String { get }
  
  // Request's params that will be encoded into the final request URL
  var parameters: Parameters? { get }
  
  // Request specific headers, will override service's header if share the same key, else, append to the service's headers
  var additionalHeaders: HeadersDict? { get set }
  
  // Method: .get, .post, .put, .patch, .delete
  var method: Alamofire.HTTPMethod { get }

  // Request specific cache policy, if nil will use the service's cache policy
  var cachePolicy: URLRequest.CachePolicy? { get }
  
  // Request specific timeout, if nil will use the service's timeout interval
  var timeout: TimeInterval? { get }
  
  // Queue that we make the request, if nil will use the service's context
  var context: DispatchQueue? { get }
  
  // Body of the request: .json, .formURL, .custom, .data
  var body: RequestBody? { get set }

  func headers(in service: APIServiceProtocol) -> HeadersDict
  func fullURL(in service: APIServiceProtocol) throws -> URL
  func urlRequest(in service: APIServiceProtocol) throws -> URLRequest
}
```

A base class called Request which conforms to this protocol is implemented

## Response and Response Protocol:
A Response Protocol has these parameters:

```swift
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
```

A base class called Response which conforms to this protocol is implemented

## Operations:

The library provide a DataOperation and a JSONOperation out of the box. 

DataOperations are just operation which directly returns the data response for you to manipulate.

DecodableOperation or JSONOperation on the other hand can help you return directly models from your request.

```swift
// Customer class with Decodable

struct Customer: Decodable {
}
```

```swift
class GetCustomerRecord: DecodableOperation<Customer> {
  public init(customerId: Int) {
    super.init()
    self.request = SampleJWTRequest(method: .get, endpoint: "/users/\(customerId)", parameters: nil, encoder: JSONEncoding.default)
    self.request.timeout = 15
  }
}
```

```swift
// Customer class with JSON

class Customer {
  init?(from json: JSON) {
    // Do your init here
  }
}
```

```swift
class GetCustomerRecord: JSONOperation<Customer> {
  public init(customerId: Int) {
    super.init()
    self.request = SampleJWTRequest(method: .get, endpoint: "/users/\(customerId)", parameters: nil, encoder: JSONEncoding.default)
    self.request.timeout = 15
    self.onParseResponse = { json in
      return Customer(from: json)
    }
  }
}
```

```swift
// When you need to invoke the get customer record API:

...
let service = APIService(...)
GetCustomerRecord(customerId: 123).execute(on: service).then { customer in
  // Do what you want with customer
}.catch { error in
  // Show error
}
```

## APIServiceDelegate:

Each API service can have an optional delegate if required:

```swift
public protocol APIServiceDelegate: class {
func service(_ apiService: APIServiceProtocol, willExecute request: RequestProtocol)
func service(_ apiService: APIServiceProtocol, shouldHandleCode errorCode: Int, on request: RequestProtocol) -> Bool
func service(_ apiService: APIServiceProtocol, handleResponse: ResponseProtocol, on request: RequestProtocol) -> Promise<ResponseProtocol>
}

```

This delegate can be used to authorize or refresh access tokens of requests.

## Author

Anh Phan Tran, anh@thedistance.co.uk

## License

KiNetworking is available under the MIT license. See the LICENSE file for more info.
