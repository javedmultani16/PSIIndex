//
//  APIHelper.swift
//  PSI_Index
//
//  Created by javedmultani16 on 19/11/19.
//  Copyright © 2019 Javed Multani. All rights reserved.
//

import UIKit

class APIHelper: NSObject {
    private let baseUrl = "https://api.data.gov.sg/v1/environment/psi"
    
    
    func getPSIData(handler: @escaping ([String: Any]?)->Void) {
        let url = URL(string: baseUrl)
        URLSession.shared.dataTask(with: url!, completionHandler: {
            (data, response, error) in
            if(error != nil){
                print("error")
            } else {
                do{
                    let json = try JSONSerialization.jsonObject(with: data!, options:.allowFragments) as! [String : Any]
                    handler(json)
                } catch let error as NSError{
                    handler(nil)
                    print(error)
                }
            }
        }).resume()
    }
}
