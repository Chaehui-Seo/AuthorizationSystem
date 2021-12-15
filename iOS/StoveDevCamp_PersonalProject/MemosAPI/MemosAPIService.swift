//
//  MemosAPIService.swift
//  StoveDevCamp_PersonalProject
//
//  Created by chuiseo-MN on 2021/12/15.
//

import Foundation
import UIKit

struct MemosAPIService {
    static let shared = MemosAPIService()
    
    func loadMemos(jwt : String?, userId: String, isAdmin: Int, completion: @escaping ([MemoInfo])->Void) {
        let url = URL(string: "http://localhost:3306/memos?userId=\(userId)&isAdmin=\(isAdmin)")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        if let token = jwt {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        let dataTask = URLSession.shared.dataTask(with: request) { data, response, error in
            let successRange = 200 ..< 300
            guard error == nil, let statusCode = (response as? HTTPURLResponse)?.statusCode, successRange.contains(statusCode) else { return }
            guard let resultData = data else { return }
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode([MemoInfo].self, from: resultData)
                completion(response)
            } catch let error {
                print("---> error load memos: \(error.localizedDescription)")
                completion([])
            }
        }
        dataTask.resume()
    }
    
    func createMemo(jwt : String?, color : String, userId: String, isAdmin: Int, content : String, completion: @escaping ([MemoInfo])->Void) {
        let url = URL(string: "http://localhost:3306/memos/create")!
        var request = URLRequest(url: url)
        let postData : [String: Any] = ["color": color, "content": content, "userId" : userId, "isAdmin" : isAdmin]
        let jsonData = try? JSONSerialization.data(withJSONObject: postData)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        if let token = jwt {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            let successRange = 200 ..< 300
            guard error == nil, let statusCode = (response as? HTTPURLResponse)?.statusCode, successRange.contains(statusCode) else { return }
            guard let resultData = data else { return }
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode([MemoInfo].self, from: resultData)
                completion(response)
            } catch let error {
                print("---> error load memos: \(error.localizedDescription)")
                completion([])
            }
        }
        task.resume()
    }
}
