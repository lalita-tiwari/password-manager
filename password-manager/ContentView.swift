//
//  ContentView.swift
//  passwordsf
//
//  Created by Lalita Tiwari on 9/19/22.
//

import SwiftUI
import CoreData
import CommonCrypto


struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>
    @State private var url: String = ""
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var u_ph: String = ""
    @State private var p_ph: String = ""
    @State private var domain: String = ""
    @AppStorage("domain_data") private var domain_data: Data = "".data(using:String.Encoding.utf8)!
    @State private var users: String = ""
    @AppStorage("users_data") private var users_data: Data = "".data(using:String.Encoding.utf8)!
    @State private var secrets: String = ""
    @AppStorage("secrets_data") private var secrets_data: Data = "".data(using:String.Encoding.utf8)!
    @State private var root_secret: String = ""
    @State private var d: String = ""
    @State private var u: String = ""
    @State private var p: String = ""
    @State private var r_secret: String = ""
    @State private var showPassword: Bool = false
    @State private var showRootPassword: Bool = false
    @State private var is_loggedIn: Bool = false
    @State private var is_loginFailed: Bool = false
    @AppStorage("root_secret_data") private var root_secret_data: Data = "".data(using:String.Encoding.utf8)!
    @AppStorage("hash_key") var hash_key: String = ""
    @AppStorage("delimiter") var delimiter: String = "*****|||||#####"
    weak var delegate: SecKeychain?


    var body: some View {
        
        if(!is_loggedIn){
           
            HStack{
                
                if showRootPassword {
                    TextField(
                        "Please enter Vault Password",
                        text: $r_secret
                    ).frame(width:300, height: 50)
                    
                } else {
                    SecureField(
                        "Please enter Vault Password",
                        text: $r_secret
                    ).frame(width:300, height: 50)
                }
                Button("􀋰") {
                    self.showRootPassword.toggle()
                }.frame(width: 50)
                
            }
            if(is_loginFailed){
                Text("Login failed! Please enter correct password").bold().foregroundColor(.red).frame(width:600, height: 50)
            }
            Text("Please enter Vault Password. First time users --> whatever password you enter will be set as your Vault password").italic().foregroundColor(.red).frame(width:600, height: 50)
            
        
        Button("Login"){
            if(hash_key == ""){
                    hash_key = randomString(length: 16)
                
                do{ root_secret_data = try aesCBCEncrypt(str_data: r_secret,str_keyData: hash_key)
                    root_secret = r_secret
                    is_loggedIn = true
                }catch{
                    
                }
            }else{
                do{ root_secret = try aesCBCDecrypt(data: root_secret_data,str_keyData: hash_key) ??  ""
                }catch{
                    
                }
                if(r_secret == root_secret){
                    is_loggedIn = true
                    print(domain_data.count)
                    print(domain_data)
                    do{if(domain_data.count>0){domain = try aesCBCDecrypt(data: domain_data,str_keyData: hash_key) ??  ""}
                        if(users_data.count>0){users = try aesCBCDecrypt(data: users_data,str_keyData: hash_key) ??  ""}
                        if(secrets_data.count>0){secrets = try aesCBCDecrypt(data: secrets_data,str_keyData: hash_key) ??  ""}
                    } catch{
                        
                    }
                }else{
                    is_loginFailed = true
                }
            }
        }.disabled(r_secret.isEmpty)
    }
        
        if(is_loggedIn){
            HStack(spacing: 10){
                NavigationView{
                    //  ContentView().environment(\.managedObjectContext, //PersistenceController.preview.container.viewContext)
                    let array = domain.components(separatedBy: delimiter)
                    VStack(alignment: .trailing){
                        var i = 0
                        var k = 0
                        ForEach(array, id: \.self){ val_d in
                            HStack{
                                Button(val_d){
                                    print("val_d  "+val_d)
                                    if let j = array.firstIndex(of: val_d){
                                        i = j
                                    }
                                    url = val_d
                                    username = users.components(separatedBy: delimiter)[i]
                                    print("i  "+String(i))
                                    print("username  "+username)
                                    password = secrets.components(separatedBy: delimiter)[i]
                                    print("password  "+password)
                                    u_ph = username
                                    p_ph = password
                                    //i = i+1
                                }.buttonStyle(LinkButtonStyle())
                                Button("􀈑"){
                                    print("val_d -->  "+val_d)
                                    if let j = array.firstIndex(of: val_d){
                                        k = j
                                    }
                                    domain = domain.replacingOccurrences(of: val_d+delimiter, with: "")
                                    domain = domain.replacingOccurrences(of: delimiter+val_d, with: "")
                                    domain = domain.replacingOccurrences(of: val_d, with: "")
                                    var del_u  = users.components(separatedBy: delimiter)[k]
                                    users =  users.replacingOccurrences(of: del_u+delimiter, with: "")
                                    users = users.replacingOccurrences(of: delimiter+del_u, with: "")
                                    users = users.replacingOccurrences(of: del_u, with: "")
                                    var del_p  = secrets.components(separatedBy: delimiter)[k]
                                    secrets =  secrets.replacingOccurrences(of: del_p+delimiter, with: "")
                                    secrets = secrets.replacingOccurrences(of: delimiter+del_p, with: "")
                                    secrets = secrets.replacingOccurrences(of: del_p, with: "")
                                    do{ domain_data = try aesCBCEncrypt(str_data: domain,str_keyData: hash_key)
                                        users_data = try aesCBCEncrypt(str_data: users,str_keyData: hash_key)
                                        secrets_data = try aesCBCEncrypt(str_data: secrets,str_keyData: hash_key)
                                        
                                    } catch {
                                           print(error)
                                       }
                                }
                            }
                        }
                    }
                }
                VStack{
                    HStack{
                        Text("Domain: ")
                        TextField(
                            "Domain (URL or Location Specifier)",
                            text: $url)
                        // .autocapitalization(.none)
                        .disableAutocorrection(true).frame(width:300, height: 50)
                    }
                    HStack{
                        Text("User Name: ")
                        TextField(
                            "User name (email address)",
                            text: $username)
                        // .autocapitalization(.none)
                        .disableAutocorrection(true).frame(width:300, height: 50)
                    }
                    // .border(Color(UIColor.separator))
                    HStack{
                        Text("Password: ")
                        if showPassword {
                            TextField(
                                "Password",
                                text: $password
                            ).frame(width:240, height: 50)
                        } else {
                            SecureField(
                                "Password",
                                text: $password
                            ).frame(width:240, height: 50)
                        }
                        Button("􀋰") {
                            self.showPassword.toggle()
                        }.frame(width: 50)
                        
                    }
                    HStack{
                        Button("Save"){
                            
                            d = url
                            u = username
                            p = password
                            url = ""
                            username = ""
                            password = ""
                            if(domain == ""){
                                domain = d
                                users = u
                                secrets = p
                            }
                            else if(domain.contains(delimiter+d) || domain.components(separatedBy: delimiter)[0] == d){
                                print("Inside replace "+d+"   "+u_ph+"   "+p_ph)
                                
                                users = users.replacingOccurrences(of: u_ph, with: u)
                                secrets = secrets.replacingOccurrences(of: p_ph, with: p)
                            }
                            else{
                                domain = domain+delimiter+d
                                users = users+delimiter+u
                                secrets = secrets+delimiter+p
                            }
                            do{ domain_data = try aesCBCEncrypt(str_data: domain,str_keyData: hash_key)
                                users_data = try aesCBCEncrypt(str_data: users,str_keyData: hash_key)
                                secrets_data = try aesCBCEncrypt(str_data: secrets,str_keyData: hash_key)
                                
                            } catch {
                                   print(error)
                               }
                        }.disabled(url.isEmpty || username.isEmpty || password.isEmpty)
                        Button("Clear") {
                            url = ""
                            username = ""
                            password = ""
                        }
                    }
                    .submitLabel(.return)
                    .onSubmit {
                        let server = ""
                        var query: [String: Any] = [kSecClass as String: kSecClassInternetPassword,
                                                    kSecAttrAccount as String: $username,
                                                    kSecAttrServer as String: server,
                                                    kSecValueData as String: $password]
                        SecItemAdd(query as CFDictionary, nil)
                    }
                }
            }}}
    enum AESError: Error {
        case KeyError((String, Int))
        case IVError((String, Int))
        case CryptorError((String, Int))
    }

    // The iv is prefixed to the encrypted data
    func aesCBCEncrypt(str_data:String, str_keyData:String) throws -> Data {
        
        let data:Data = str_data.data(using:String.Encoding.utf8)!
        let keyData:Data = str_keyData.data(using:String.Encoding.utf8)!
        let keyLength = keyData.count
        let validKeyLengths = [kCCKeySizeAES128, kCCKeySizeAES192, kCCKeySizeAES256]
        if (validKeyLengths.contains(keyLength) == false) {
            throw AESError.KeyError(("Invalid key length", keyLength))
        }

        let ivSize = kCCBlockSizeAES128;
        let cryptLength = size_t(ivSize + data.count + kCCBlockSizeAES128)
        var cryptData = Data(count:cryptLength)

        let status = cryptData.withUnsafeMutableBytes {ivBytes in
            SecRandomCopyBytes(kSecRandomDefault, kCCBlockSizeAES128, ivBytes)
        }
        if (status != 0) {
            throw AESError.IVError(("IV generation failed", Int(status)))
        }

        var numBytesEncrypted :size_t = 0
        let options   = CCOptions(kCCOptionPKCS7Padding)

        let cryptStatus = cryptData.withUnsafeMutableBytes {cryptBytes in
            data.withUnsafeBytes {dataBytes in
                keyData.withUnsafeBytes {keyBytes in
                    CCCrypt(CCOperation(kCCEncrypt),
                            CCAlgorithm(kCCAlgorithmAES),
                            options,
                            keyBytes, keyLength,
                            cryptBytes,
                            dataBytes, data.count,
                            cryptBytes+kCCBlockSizeAES128, cryptLength,
                            &numBytesEncrypted)
                }
            }
        }

        if UInt32(cryptStatus) == UInt32(kCCSuccess) {
            cryptData.count = numBytesEncrypted + ivSize
        }
        else {
            throw AESError.CryptorError(("Encryption failed", Int(cryptStatus)))
        }

        return cryptData//String(decoding: cryptData, as: UTF8.self);
    }

    // The iv is prefixed to the encrypted data
    func aesCBCDecrypt(data:Data, str_keyData:String) throws -> String? {
        //let data:Data = str_data.data(using:String.Encoding.utf8)!
        let keyData:Data = str_keyData.data(using:String.Encoding.utf8)!
        let keyLength = keyData.count
        let validKeyLengths = [kCCKeySizeAES128, kCCKeySizeAES192, kCCKeySizeAES256]
        if (validKeyLengths.contains(keyLength) == false) {
            throw AESError.KeyError(("Invalid key length", keyLength))
        }

        let ivSize = kCCBlockSizeAES128;
        let clearLength = size_t(data.count - ivSize)
        var clearData = Data(count:clearLength)

        var numBytesDecrypted :size_t = 0
        let options   = CCOptions(kCCOptionPKCS7Padding)

        let cryptStatus = clearData.withUnsafeMutableBytes {cryptBytes in
            data.withUnsafeBytes {dataBytes in
                keyData.withUnsafeBytes {keyBytes in
                    CCCrypt(CCOperation(kCCDecrypt),
                            CCAlgorithm(kCCAlgorithmAES128),
                            options,
                            keyBytes, keyLength,
                            dataBytes,
                            dataBytes+kCCBlockSizeAES128, clearLength,
                            cryptBytes, clearLength,
                            &numBytesDecrypted)
                }
            }
        }

        if UInt32(cryptStatus) == UInt32(kCCSuccess) {
            clearData.count = numBytesDecrypted
        }
        else {
            throw AESError.CryptorError(("Decryption failed", Int(cryptStatus)))
        }

        return String(decoding: clearData, as: UTF8.self);
    }
    func randomString(length: Int) -> String {

        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789`~!@#$%^&*()_-+=:<>,.?"
        let len = UInt32(letters.length)

        var randomString = ""

        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }

        return randomString
    }
    private func addItem() {
        withAnimation {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()

            do {
               
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {

            ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            Label("abc", systemImage: "book.fill")

    }
}

