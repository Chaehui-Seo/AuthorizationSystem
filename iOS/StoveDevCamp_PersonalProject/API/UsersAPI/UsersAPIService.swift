//
//  UsersAPIService.swift
//  StoveDevCamp_PersonalProject
//
//  Created by chuiseo-MN on 2021/12/15.
//

import Foundation
import SwiftKeychainWrapper

struct UsersAPIService {
    static let shared = UsersAPIService()
    
    func loadUsers(completion: @escaping ([String: Any])->Void) {
        let session = URLSession(configuration: .default)
        let urlComponents = URLComponents(string: "http://localhost:3306/users")!
        let requestURL = urlComponents.url!
        let task = session.dataTask(with: requestURL) { data, response, error in
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
                decoder.dateDecodingStrategy = .millisecondsSince1970
                let response = try decoder.decode([UserInfo].self, from: resultData)
                completion(["success": 1, "user" : response])
            } catch let error {
                print("---> error in loading user : \(error.localizedDescription)")
            }
        }
        task.resume()
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
            if let httpResponse = response as? HTTPURLResponse, let token = httpResponse.value(forHTTPHeaderField: "Token") {
                KeychainWrapper.standard[.accessToken] = token
            }
            let successRange = 200 ..< 300
            guard error == nil, let statusCode = (response as? HTTPURLResponse)?.statusCode, successRange.contains(statusCode), let resultData = data else {
                if (response as? HTTPURLResponse)?.statusCode == 401 {
                    completion(["success" : 0, "message" : "Incorrect password"])
                } else if (response as? HTTPURLResponse)?.statusCode == 402 {
                    completion(["success" : 0, "message" : "No user found"])
                } else {
                    completion(["success" : 0])
                }
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: resultData, options: [])
            if let result = responseJSON as? [String: Any] {
                completion(result)
            } else {
                do {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .millisecondsSince1970
                    let response = try decoder.decode([UserInfo].self, from: resultData)
                    KeychainWrapper.standard.set(response[0].refreshToken ?? "", forKey: KeychainWrapper.Key.refreshToken.rawValue)
                    completion(["success":1, "user": response[0]])
                } catch let error {
                    print("---> error in login : \(error.localizedDescription)")
                    completion(["success" : 0])
                }
            }
        }
        task.resume()
    }
    
    
    func autoLogin(userId: String, refreshToken: String, completion: @escaping ([String: Any])->Void) {
        let url = URL(string: "http://localhost:3306/users/auto-login")!
        var request = URLRequest(url: url)
        
        let postData : [String: Any] = ["userId" : userId]
        let jsonData = try? JSONSerialization.data(withJSONObject: postData)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(refreshToken)", forHTTPHeaderField: "Authorization")
        request.httpBody = jsonData
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let httpResponse = response as? HTTPURLResponse, let token = httpResponse.value(forHTTPHeaderField: "Token") {
                KeychainWrapper.standard[.accessToken] = token
            }
            let successRange = 200 ..< 300
            guard error == nil, let statusCode = (response as? HTTPURLResponse)?.statusCode, successRange.contains(statusCode), let resultData = data else {
                if (response as? HTTPURLResponse)?.statusCode == 404 {
                    completion(["success" : 0, "message" : "Invalid token"])
                } else if (response as? HTTPURLResponse)?.statusCode == 401 {
                    completion(["success" : 0, "message" : "Incorrect password"])
                } else if (response as? HTTPURLResponse)?.statusCode == 402 {
                    completion(["success" : 0, "message" : "No user found"])
                } else {
                    completion(["success" : 0])
                }
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: resultData, options: [])
            if let result = responseJSON as? [String: Any] {
                completion(result)
            } else {
                do {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .millisecondsSince1970
                    let response = try decoder.decode([UserInfo].self, from: resultData)
                    KeychainWrapper.standard.set(response[0].refreshToken ?? "", forKey: KeychainWrapper.Key.refreshToken.rawValue)
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
                completion(["success" : 0])
            }
        }
        task.resume()
    }

    func emailVerified(userId: String, completion: @escaping ([String: Any])->Void) {
        let url = URL(string: "http://localhost:3306/users/email-verification-checked")!
        var request = URLRequest(url: url)
        
        let postData : [String: Any] = ["userId" : userId]
        let jsonData = try? JSONSerialization.data(withJSONObject: postData)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
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
                completion(["success" : 0])
            }
        }
        task.resume()
    }

    func sendEmailVerification(userId: String, completion: @escaping ([String: Any])->Void) {
        let url = URL(string: "http://localhost:3306/users/email-verification-register")!
        var request = URLRequest(url: url)
        
        let postData : [String: Any] = ["userId" : userId]
        let jsonData = try? JSONSerialization.data(withJSONObject: postData)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
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
                completion(["success" : 0])
            }
        }
        task.resume()
    }


    func sendEmailForPw(userId: String, completion: @escaping ([String: Any])->Void) {
        let url = URL(string: "http://localhost:3306/users/email-verification-password")!
        var request = URLRequest(url: url)
        
        let postData : [String: Any] = ["userId" : userId]
        let jsonData = try? JSONSerialization.data(withJSONObject: postData)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
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
                completion(["success" : 0])
            }
        }
        task.resume()
    }
    
    func changePassword(jwt: String?, userId: String, newPw: String, isAdmin: Int, completion: @escaping ([String: Any])->Void) {
        let url = URL(string: "http://localhost:3306/users/change-password")!
        var request = URLRequest(url: url)
        
        let postData : [String: Any] = ["userId" : userId, "newPw" : newPw, "isAdmin": isAdmin]
        let jsonData = try? JSONSerialization.data(withJSONObject: postData)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = jwt {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        request.httpBody = jsonData
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
                do {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .millisecondsSince1970
                    let response = try decoder.decode([UserInfo].self, from: resultData)
                    completion(["success":1, "user": response[0]])
                } catch let error {
                    print("---> error in changing password : \(error.localizedDescription)")
                    completion(["success" : 0])
                }
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
                do {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .millisecondsSince1970
                    let response = try decoder.decode([UserInfo].self, from: resultData)
                    completion(["success":1, "user": response[0]])
                } catch let error {
                    print("---> error in changing nickname : \(error.localizedDescription)")
                    completion(["success" : 0])
                }
            }
        }
        task.resume()
    }


//    func changeEmailVerification(jwt: String?, userId: String, isEmailVerified: Int, isAdmin: Int, completion: @escaping ([String: Any])->Void) {
//        let url = URL(string: "http://localhost:3306/users/change-email-verification")!
//        var request = URLRequest(url: url)
//        
//        let postData : [String: Any] = ["userId" : userId, "isEmailVerified" : isEmailVerified, "isAdmin": isAdmin]
//        let jsonData = try? JSONSerialization.data(withJSONObject: postData)
//        request.httpMethod = "POST"
//        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//        if let token = jwt {
//            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
//        }
//        request.httpBody = jsonData
//        let task = URLSession.shared.dataTask(with: request) { data, response, error in
//            let successRange = 200 ..< 300
//            guard error == nil, let statusCode = (response as? HTTPURLResponse)?.statusCode, successRange.contains(statusCode), let resultData = data else {
//                if (response as? HTTPURLResponse)?.statusCode == 404 {
//                    completion(["success" : 0, "message" : "Invalid token"])
//                } else {
//                    completion(["success" : 0])
//                }
//                return
//            }
//            let responseJSON = try? JSONSerialization.jsonObject(with: resultData, options: [])
//            if let result = responseJSON as? [String: Any] {
//                completion(result)
//            } else {
//                completion(["success" : 0])
//            }
//        }
//        task.resume()
//    }

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
                decoder.dateDecodingStrategy = .millisecondsSince1970
                let response = try decoder.decode([UserInfo].self, from: resultData)
                completion(["success": 1, "user": response])
            } catch let error {
                print("---> error in blocking user : \(error.localizedDescription)")
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
            if let httpResponse = response as? HTTPURLResponse, let token = httpResponse.value(forHTTPHeaderField: "Token") {
                KeychainWrapper.standard[.accessToken] = token
            }
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
                do {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .millisecondsSince1970
                    let response = try decoder.decode([UserInfo].self, from: resultData)
                    KeychainWrapper.standard.set(response[0].refreshToken ?? "", forKey: KeychainWrapper.Key.refreshToken.rawValue)
                    completion(["success":1, "user": response[0]])
                } catch let error {
                    print("---> error in registering : \(error.localizedDescription)")
                    completion(["success" : 0])
                }
            }
        }
        task.resume()
    }
    
    func checkRefreshToken(jwt: String, userId: String, completion: @escaping ([String: Any])->Void) {
        print("refresh token")
        let url = URL(string: "http://localhost:3306/users/refresh-access-token")!
        var request = URLRequest(url: url)
        
        let postData : [String: Any] = ["userId" : userId]
        let jsonData = try? JSONSerialization.data(withJSONObject: postData)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(jwt)", forHTTPHeaderField: "Authorization")
        request.httpBody = jsonData
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
            if let httpResponse = response as? HTTPURLResponse, let token = httpResponse.value(forHTTPHeaderField: "Token") {
                KeychainWrapper.standard[.accessToken] = token
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: resultData, options: [])
            if let result = responseJSON as? [String: Any] {
                completion(result)
            } else {
                do {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .millisecondsSince1970
                    let response = try decoder.decode([UserInfo].self, from: resultData)
                    KeychainWrapper.standard.set(response[0].refreshToken ?? "", forKey: KeychainWrapper.Key.refreshToken.rawValue)
                    AdminViewModel.shared.adminUser = AdminViewModel.shared.adminUser?.userId == response[0].userId ? response[0] : AdminViewModel.shared.adminUser
                    MemoViewModel.shared.user = MemoViewModel.shared.user?.userId == response[0].userId ? response[0] : MemoViewModel.shared.user
                    UserInfoViewModel.shared.user = UserInfoViewModel.shared.user?.userId == response[0].userId ? response[0] : UserInfoViewModel.shared.user
                    completion(["success":1])
                } catch let error {
                    print("---> error in login : \(error.localizedDescription)")
                    completion(["success" : 0])
                }
            }
        }
        task.resume()
    }
    
    func withdrawal(jwt: String?, userId: String, password: String, isAdmin: Int, completion: @escaping ([String: Any])->Void) {
        let url = URL(string: "http://localhost:3306/users/withdrawal")!
        var request = URLRequest(url: url)
        let postData : [String: Any] = ["userId": userId, "password":password, "isAdmin": isAdmin]
        let jsonData = try? JSONSerialization.data(withJSONObject: postData)
        request.httpMethod = "DELETE"
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
                completion(["success" : 0])
            }
        }
        task.resume()

    }
}
