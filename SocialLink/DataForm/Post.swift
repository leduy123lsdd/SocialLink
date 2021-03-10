//
//  Post.swift
//  SocialLink
//
//  Created by Lê Duy on 3/8/21.
//

import Foundation
import Alamofire

class DataRequest {
    func from<T:Decodable>(_ url:String , dataType:T.Type, dataResponse:@escaping((T)->Void)) {
        AF.request(url, encoding: JSONEncoding.default).responseData { (jsonData) in
            let blogPosts: T = try! JSONDecoder().decode(T.self, from: jsonData.data!)
            dataResponse(blogPosts)
        }
    }
}

struct Post:Decodable {
    var id:String
    var uuid:String
    var title:String
}
