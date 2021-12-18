//
//  BlockMessageAPIService.swift
//  StoveDevCamp_PersonalProject
//
//  Created by chuiseo-MN on 2021/12/15.
//

import Foundation

struct BlockMessageAPIService {
    static let shared = BlockMessageAPIService()
    
    func loadBlockMessages(jwt : String?, userId: String, completion: @escaping ([String: Any])->Void) {
        let url = URL(string: "http://localhost:3306/block-messages?userId=\(userId)")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        if let token = jwt {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            let successRange = 200 ..< 300
            guard error == nil, let statusCode = (response as? HTTPURLResponse)?.statusCode, successRange.contains(statusCode), let resultData = data else {
                if (response as? HTTPURLResponse)?.statusCode == 404 {
                    completion(["success" : 0, "message" : "Invalid token"])
                } else {
                    completion(["success" : 0])
                }
                return
            }
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode([BlockMessage].self, from: resultData)
                completion(["success" : 1, "message": response])
            } catch let error {
                print("---> error in loading block messages: \(error.localizedDescription)")
                completion(["success" : 0])
            }
        }
        task.resume()
    }

    func createBlockMessage(fromUser: String, toUser: String, content : String, completion: @escaping ([String: Any])->Void) {
        let url = URL(string: "http://localhost:3306/block-messages/create")!
        var request = URLRequest(url: url)
        let postData : [String: Any] = ["fromUser": fromUser, "content": content, "toUser" : toUser]
        let jsonData = try? JSONSerialization.data(withJSONObject: postData)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            let successRange = 200 ..< 300
            guard error == nil, let statusCode = (response as? HTTPURLResponse)?.statusCode, successRange.contains(statusCode), let resultData = data else {
                completion(["success" : 0])
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: resultData, options: [])
            if let result = responseJSON as? [String: Any] {
                completion(result)
            } else {
                completion(["success": 0])
            }
        }
        task.resume()
    }

    func editBlockMessage(jwt: String?, id: Int, userId: String, response: Int, completion: @escaping ([String: Any])->Void) {
        let url = URL(string: "http://localhost:3306/block-messages/response")!
        var request = URLRequest(url: url)
        let postData : [String: Any] = ["id": id, "userId": userId, "response" : response]
        let jsonData = try? JSONSerialization.data(withJSONObject: postData)
        request.httpMethod = "PUT"
        request.httpBody = jsonData
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        if let token = jwt {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            let successRange = 200 ..< 300
            guard error == nil, let statusCode = (response as? HTTPURLResponse)?.statusCode, successRange.contains(statusCode), let resultData = data else {
                if (response as? HTTPURLResponse)?.statusCode == 404 {
                    completion(["success" : 0, "message" : "Invalid token"])
                } else {
                    completion(["success" : 0])
                }
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: resultData, options: [])
            if let result = responseJSON as? [String: Any] {
                completion(result)
            } else {
                completion(["success": 0])
            }
        }
        task.resume()
    }
    
    func deleteBlockMessage(toUser: String, completion: @escaping ([String: Any])->Void) {
        let url = URL(string: "http://localhost:3306/block-messages/delete")!
        var request = URLRequest(url: url)
        let postData : [String: Any] = ["toUser": toUser]
        let jsonData = try? JSONSerialization.data(withJSONObject: postData)
        request.httpMethod = "DELETE"
        request.httpBody = jsonData
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            let successRange = 200 ..< 300
            guard error == nil, let statusCode = (response as? HTTPURLResponse)?.statusCode, successRange.contains(statusCode), let resultData = data else {
                completion(["success" : 0])
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: resultData, options: [])
            if let result = responseJSON as? [String: Any] {
                completion(result)
            } else {
                completion(["success": 0])
            }
        }
        task.resume()
    }
}
