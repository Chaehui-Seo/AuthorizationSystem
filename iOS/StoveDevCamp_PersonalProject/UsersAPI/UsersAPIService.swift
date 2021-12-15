//
//  UsersAPIService.swift
//  StoveDevCamp_PersonalProject
//
//  Created by chuiseo-MN on 2021/12/15.
//

import Foundation

struct UsersAPIService {
    static let shared = UsersAPIService()
    
    func loadUsers(completion: @escaping ([UserInfo])->Void) {
        let session = URLSession(configuration: .default)
        let urlComponents = URLComponents(string: "http://localhost:3306/users")!
        let requestURL = urlComponents.url!
        let dataTask = session.dataTask(with: requestURL) { data, response, error in
            let successRange = 200 ..< 300
            guard error == nil, let statusCode = (response as? HTTPURLResponse)?.statusCode, successRange.contains(statusCode) else {
                completion([])
                return
            }
            guard let resultData = data else {
                completion([])
                return
            }
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .millisecondsSince1970
                let response = try decoder.decode([UserInfo].self, from: resultData)
                completion(response)
            } catch let error {
                print("---> error in load user : \(error.localizedDescription)")
            }
        }
        dataTask.resume()
    }
    
    func login(userId: String, pw: String, completion: @escaping ([String: Any])->Void) {
        let url = URL(string: "http://localhost:3306/users/login")!
        var request = URLRequest(url: url)
        
        let postData : [String: Any] = ["userId" : userId, "password": pw]
        let jsonData = try? JSONSerialization.data(withJSONObject: postData)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                completion(["success" : 0])
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let result = responseJSON as? [String: Any] {
                completion(result)
            } else {
                do {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .millisecondsSince1970
                    let response = try decoder.decode([UserInfo].self, from: data)
                    completion(["success":1, "user": response[0]])
                } catch let error {
                    print("---> error in login : \(error.localizedDescription)")
                    completion(["success" : 0])
                }
            }
        }
        task.resume()
    }

    func checkUserIdDuplicate(userId: String, completion: @escaping ([String: Any])->Void) {
        let url = URL(string: "http://localhost:3306/users/userid-validation")!
        var request = URLRequest(url: url)
        
        let postData : [String: Any] = ["userId" : userId]
        let jsonData = try? JSONSerialization.data(withJSONObject: postData)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                completion(["success" : 0])
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let result = responseJSON as? [String: Any] {
                completion(result)
            } else {
                completion(["success" : 0])
            }
        }
        task.resume()
    }

    func checkNickNameDuplicate(nickName: String, completion: @escaping ([String: Any])->Void) {
        let url = URL(string: "http://localhost:3306/users/nickname-validation")!
        var request = URLRequest(url: url)
        
        let postData : [String: Any] = ["nickName" : nickName]
        let jsonData = try? JSONSerialization.data(withJSONObject: postData)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                completion(["success" : 0])
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let result = responseJSON as? [String: Any] {
                completion(result)
            } else {
                completion(["success" : 0])
            }
        }
        task.resume()
    }

    func emailVerified(userId: String, completion: @escaping ([String: Any])->Void) {
        let url = URL(string: "http://localhost:3306/users/finish-email-verification")!
        var request = URLRequest(url: url)
        
        let postData : [String: Any] = ["userId" : userId]
        let jsonData = try? JSONSerialization.data(withJSONObject: postData)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                completion(["success" : 0])
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let result = responseJSON as? [String: Any] {
                completion(result)
            } else {
                completion(["success" : 0])
            }
        }
        task.resume()
    }

    func sendEmailVerification(userId: String, completion: @escaping ([String: Any])->Void) {
        let url = URL(string: "http://localhost:3306/users/send-email-verification")!
        var request = URLRequest(url: url)
        
        let postData : [String: Any] = ["userId" : userId]
        let jsonData = try? JSONSerialization.data(withJSONObject: postData)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                completion(["success" : 0])
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let result = responseJSON as? [String: Any] {
                completion(result)
            } else {
                completion(["success" : 0])
            }
        }
        task.resume()
    }

    func sendForPasswordChange(userId: String, completion: @escaping ([String: Any])->Void) {
        let url = URL(string: "http://localhost:3306/users/temp-password")!
        var request = URLRequest(url: url)
        
        let postData : [String: Any] = ["userId" : userId]
        let jsonData = try? JSONSerialization.data(withJSONObject: postData)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                completion(["success" : 0])
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let result = responseJSON as? [String: Any] {
                completion(result)
            } else {
                completion(["success" : 0])
            }
        }
        task.resume()
    }


    func changePassword(jwt: String?, userId: String, password: String, isAdmin: Int, completion: @escaping ([String: Any])->Void) {
        let url = URL(string: "http://localhost:3306/users/temp-password")!
        var request = URLRequest(url: url)
        
        let postData : [String: Any] = ["userId" : userId, "newPw" : password, "isAdmin": isAdmin]
        let jsonData = try? JSONSerialization.data(withJSONObject: postData)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = jwt {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        request.httpBody = jsonData
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                completion(["success" : 0])
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let result = responseJSON as? [String: Any] {
                completion(result)
            } else {
                completion(["success" : 0])
            }
        }
        task.resume()
    }

    func changeNickName(jwt: String?, userId: String, nickName: String, isAdmin: Int, completion: @escaping ([String: Any])->Void) {
        let url = URL(string: "http://localhost:3306/users/change-nickname")!
        var request = URLRequest(url: url)
        
        let postData : [String: Any] = ["userId" : userId, "nickName" : nickName, "isAdmin": isAdmin]
        let jsonData = try? JSONSerialization.data(withJSONObject: postData)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = jwt {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        request.httpBody = jsonData
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                completion(["success" : 0])
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let result = responseJSON as? [String: Any] {
                completion(result)
            } else {
                completion(["success" : 0])
            }
        }
        task.resume()
    }


    func changeEmailVerification(jwt: String?, userId: String, isEmailVerified: Int, isAdmin: Int, completion: @escaping ([String: Any])->Void) {
        let url = URL(string: "http://localhost:3306/users/change-email-verification")!
        var request = URLRequest(url: url)
        
        let postData : [String: Any] = ["userId" : userId, "isEmailVerified" : isEmailVerified, "isAdmin": isAdmin]
        let jsonData = try? JSONSerialization.data(withJSONObject: postData)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = jwt {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        request.httpBody = jsonData
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                completion(["success" : 0])
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let result = responseJSON as? [String: Any] {
                completion(result)
            } else {
                completion(["success" : 0])
            }
        }
        task.resume()
    }

    func changeUserBlock(jwt: String?, userId: String, isBlocked: Int, isAdmin: Int, completion: @escaping ([String: Any])->Void) {
        let url = URL(string: "http://localhost:3306/users/change-user-block")!
        var request = URLRequest(url: url)
        
        let postData : [String: Any] = ["userId" : userId, "isBlocked" : isBlocked, "isAdmin": isAdmin]
        let jsonData = try? JSONSerialization.data(withJSONObject: postData)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = jwt {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        request.httpBody = jsonData
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                completion(["success" : 0])
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let result = responseJSON as? [String: Any] {
                completion(result)
            } else {
                completion(["success" : 0])
            }
        }
        task.resume()
    }


    func register(userId: String, nickName: String, password: String, completion: @escaping ([String: Any])->Void) {
        let url = URL(string: "http://localhost:3306/users/create")!
        var request = URLRequest(url: url)
        
        let postData : [String: Any] = ["userId" : userId, "nickName" : nickName, "password": password]
        let jsonData = try? JSONSerialization.data(withJSONObject: postData)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                completion(["success" : 0])
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let result = responseJSON as? [String: Any] {
                completion(result)
            } else {
                do {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .millisecondsSince1970
                    let response = try decoder.decode([UserInfo].self, from: data)
                    completion(["success":1, "user": response[0]])
                } catch let error {
                    print("---> error in login : \(error.localizedDescription)")
                    completion(["success" : 0])
                }
            }
        }
        task.resume()
    }

    func setFcmToken(jwt: String, userId: String, fcmToken: String, completion: @escaping ([String: Any])->Void) {
        let url = URL(string: "http://localhost:3306/users/set-fcm-token")!
        var request = URLRequest(url: url)
        
        let postData : [String: Any] = ["userId" : userId, "fcmToken" : fcmToken]
        let jsonData = try? JSONSerialization.data(withJSONObject: postData)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(jwt)", forHTTPHeaderField: "Authorization")
        request.httpBody = jsonData
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                completion(["success" : 0])
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let result = responseJSON as? [String: Any] {
                completion(result)
            } else {
                completion(["success" : 0])
            }
        }
        task.resume()
    }
}
