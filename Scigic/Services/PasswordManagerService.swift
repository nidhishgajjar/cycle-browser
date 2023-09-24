//
//  PasswordManagerService.swift
//  Scigic
//
//  Created by Nidhish Gajjar on 2023-07-27.
//

//import Foundation
//import Security

//class PasswordManagerService {
//
//    enum KeychainError: Error {
//        case noPassword
//        case unexpectedPasswordData
//        case unhandledError(status: OSStatus)
//    }
//
//    func getPassword(for server: String) throws -> String {
//        let query: [String: Any] = [kSecClass as String: kSecClassInternetPassword,
//                                    kSecAttrServer as String: server,
//                                    kSecReturnAttributes as String: kCFBooleanTrue!,
//                                    kSecReturnData as String: kCFBooleanTrue!,
//                                    kSecMatchLimit as String: kSecMatchLimitOne]
//
//        var item: CFTypeRef?
//        let status = SecItemCopyMatching(query as CFDictionary, &item)
//        guard status != errSecItemNotFound else { throw KeychainError.noPassword }
//        guard status == errSecSuccess else { throw KeychainError.unhandledError(status: status) }
//
//        guard let existingItem = item as? [String : Any],
//            let passwordData = existingItem[kSecValueData as String] as? Data,
//            let password = String(data: passwordData, encoding: String.Encoding.utf8),
//            !password.isEmpty
//            else {
//                throw KeychainError.unexpectedPasswordData
//            }
//
//        return password
//    }
//
//    func storeOrUpdatePassword(_ password: String, for server: String, user: String) throws {
//        let passwordData = password.data(using: String.Encoding.utf8)!
//        let query: [String: Any] = [kSecClass as String: kSecClassInternetPassword,
//                                    kSecAttrServer as String: server,
//                                    kSecAttrAccount as String: user,
//                                    kSecReturnAttributes as String: kCFBooleanTrue ?? false,
//                                    kSecMatchLimit as String: kSecMatchLimitOne]
//
//        // Check if an item already exists.
//        var item: CFTypeRef?
//        let status = SecItemCopyMatching(query as CFDictionary, &item)
//        if status == errSecSuccess {
//            // An item with this server and username already exists, update it.
//            let updateQuery: [String: Any] = [kSecClass as String: kSecClassInternetPassword,
//                                              kSecAttrServer as String: server,
//                                              kSecAttrAccount as String: user]
//            let attributesToUpdate: [String: Any] = [kSecValueData as String: passwordData]
//
//            let status = SecItemUpdate(updateQuery as CFDictionary, attributesToUpdate as CFDictionary)
//            guard status == errSecSuccess else { throw KeychainError.unhandledError(status: status) }
//        } else if status == errSecItemNotFound {
//            // No item with this server and username exists, add a new one.
//            let newQuery: [String: Any] = [kSecClass as String: kSecClassInternetPassword,
//                                           kSecAttrServer as String: server,
//                                           kSecAttrAccount as String: user,
//                                           kSecValueData as String: passwordData]
//
//            let status = SecItemAdd(newQuery as CFDictionary, nil)
//            guard status == errSecSuccess else { throw KeychainError.unhandledError(status: status) }
//        } else {
//            throw KeychainError.unhandledError(status: status)
//        }
//    }
//}



// Key chain access group $(AppIdentifierPrefix)ai.constitute.scigic


//
//
//do {
//    let password = try passwordManagerService.getPassword(for: "www.example.com")
//    print("Retrieved password: \(password)")
//} catch KeychainError.noPassword {
//    print("No password found in keychain for this server")
//} catch KeychainError.unexpectedPasswordData {
//    print("Could not interpret password data from keychain")
//} catch KeychainError.unhandledError(let status) {
//    print("Unhandled error occurred: \(status)")
//} catch {
//    print("An unexpected error occurred: \(error)")
//}
//
//do {
//    try passwordManagerService.storeOrUpdatePassword("password12345", for: "www.example.com", user: "user123")
//} catch KeychainError.unhandledError(let status) {
//    print("Unhandled error: \(status)")
//} catch {
//    print("Some other error occurred.")
//}
