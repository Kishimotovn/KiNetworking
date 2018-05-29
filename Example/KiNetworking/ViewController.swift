//
//  ViewController.swift
//  KiNetworking
//
//  Created by Anh Phan Tran on 05/27/2018.
//  Copyright (c) 2018 Anh Phan Tran. All rights reserved.
//

import UIKit
import KiNetworking
import Alamofire
import SwiftyJSON

var globalAccessToken = "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsImp0aSI6Ijg5ZGUzMzJlNmQ2YTU1Yjc0NWI5MWRjYzczYjBhNGZkNjU5ZWNiYTIxMGY5OThhNDk1OTg3ZjM0ZGFkMWMwNzgzZDdhMGI2NWYyZmU3MmI5In0.eyJhdWQiOiJESVNUQU5DRV9BTkRST0lEX0RFViIsImp0aSI6Ijg5ZGUzMzJlNmQ2YTU1Yjc0NWI5MWRjYzczYjBhNGZkNjU5ZWNiYTIxMGY5OThhNDk1OTg3ZjM0ZGFkMWMwNzgzZDdhMGI2NWYyZmU3MmI5IiwiaWF0IjoxNTI3NTgyMzAwLCJuYmYiOjE1Mjc1ODIzMDAsImV4cCI6MTUyNzYxMTEwMCwic3ViIjoiMDAwMDAwMDYzNDkiLCJzY29wZXMiOltdfQ.kheyD5pS-1sFLXuWD9pocqmTzk_TAifCiPqzKynWOQscmj6NrjaHczMIzxuAoFG1mwqEDt-YribCDB__ijFR5mJ3IAWC6Qtdrff_QmCFKhFt5LxHkP3cuYqJCaL1w1zOZ98thbc_HJrFZ5l5fq3sRAt-JMIV_N40sz9r79zFVEy53aabzGV-068HiMQI4_L_R9dAiHz5C8ltVJbSaJOkTYJrjGPIi-T2ljmOOBWKT-EtI-YE7o07rgzHiELI6lxx1fMDeDgBwU_uxFliAiekPX7flQUr4YK9xZ2cjHIBJOXDLZgXbLelLxivRCkCr6YtDsq6TEPYOKyBB0v-G-2L"

var globalRefreshToken = "def50200a037e75ab4c345e6ad6225ba9e6c533d2f13ee63661485b50c36716404ed4cb95c8d97197877b181856ade673f4b3e2ab7a38b47f4b98633e9a43b009a59bffdc4202c2269b1cd18119d127a9c469ab77a56f7f8f9575bda53dd2f0de20eb7c55b2a82a401559ebcffe8b0dbe83dd9a2f29cab0e8e52e2b349a504643c06475b0e6bd368e12b30befa80c2a558bba2bba555aab6b1a029f0b999926c830efc7f39f5db9516ce490b7227a4325430a5baf56b5050f498c6086e52f2f8792ba9de2947f00a862303171c174b5aab73ea711bc34dd8c613e0d5e18b8609aa21e4e6904daf0f852ac014940e41d63bc1f5dec27eb0ae852adbde58e51da4b82cc1d80b8fc586050ceca407391e0f4a85eaf87472455f6be9e18223e1ad178174ca9a263a3b6797633d086bb2176c3bc7f6f4c448534bb3aa5c0129cb49ea209e06b0bc9342ad8211e57ea40ae21f805c3722e849b6e09bebfb92df72bd389892aedc139b4668f298662b7ed900d2cd2e6020886c0620bb271d94fc9447ef"

class ViewController: UIViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    let config = APIServiceConfig(
      name: "Staging",
      base: "https://staging.touchrightsoftware.com/api/v5",
      commonHeaders: [
        "X-TR-App-Version": "5.0.0",
        "X-TR-Device-Id": UIDevice.current.identifierForVendor?.uuidString ?? "randomString",
        "X-TR-Device-OS": "IOS",
        "X-TR-Device-OS-Version": UIDevice.current.systemVersion
      ])
    config?.debugEnabled = .request
    let service = APIService.init(config!)
    
    GetCustomerRecord(customerId: 1234).execute(in: service).then { json in
      print("got response: \(json.dictionaryValue)")
    }.catch { error in
      print("got error: \(error.localizedDescription)")
    }
  }
}

class GetCustomerRecord: JSONOperation<JSON> {
  public init(customerId: Int) {
    super.init()
    self.request = SampleJWTRequest(method: .get, endpoint: "/users/00000006348")
    self.onParseResponse = { json in
      return json
    }
  }
}
