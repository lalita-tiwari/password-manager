# Password Manager Application


This repository contanis code for a password manager application which is created to support mac OS.

## Overview:

- This app is a local password vault for users and can be installed on MacOS and IOS platforms.    Release:   https://github.com/lalita-tiwari/password-manager/releases/tag/v1.0.0
- Upon installation users need to set a vault password to access the password manager application. First time set password will be set for lifetime for the app and will be immutable.
- For every record user wants to save they need to provide domain, username and password.
- As the user keeps adding the records, all the domains can be seen as a link on the left panel as a hyperlink.
- User can delete the record whenever no longer required.
- User can also update and delete a record.

## Technolgies:
 - Swift5

 ## Development Tools:
 - XCode

 ## Detailed Setup [MacOs]:

 - Download the distributed binary from Release page: https://github.com/lalita-tiwari/password-manager/releases/tag/v1.0.0
 - The binary is compatible with MacOs App Store and IOS App Store.
 - Upon Download manually move the app to your application folder.

![image](https://user-images.githubusercontent.com/83514861/204662187-4c7dbbab-ade0-433e-ab33-7c58408e2872.png)

- Double click "Trust" and "Open"

![image](https://user-images.githubusercontent.com/83514861/204662389-ceca0b82-4db5-4ede-b546-d51e13670fcb.png)

- Now First time user needs to enter a password that will set as password of the vault. The password is immutable and can not be changed for life time of the application.
- Vault password will be validated upon every time app launched.

![image](https://user-images.githubusercontent.com/83514861/204662770-e1bbec09-0aa2-4497-8e22-f372917a3831.png)

- After successfully authenticated user can add any number of credential records:

![image](https://user-images.githubusercontent.com/83514861/204663133-9d254530-c73e-4803-b4bb-3c93d8d9c6c1.png)

- Click on record on left hand pane will populate the record in editable form on content area from where credentials and password can be copied using "unhide" button.

![image](https://user-images.githubusercontent.com/83514861/204663953-deb66818-57b9-47fe-9095-19084392a91f.png)

- Same screen can be used to edit and update the credentials.
- Records can be deleted using delete button next to record on left hand side pane:

![image](https://user-images.githubusercontent.com/83514861/204664246-db1de109-84df-40f0-b916-74b45a0f857e.png)


## Technical Details:

- The application is written in Swift5 using xCode and is compatible with MacOS and IOS App Store. Tested for Macos Monterey and IOS 15
- All app data will be store locally on ~/Library/Preferences/$bundleid.plist
- All the app data is AES128 encrypted using a unique 16 bit hash key which is randomly generated first time user uses the application:

```
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
```
- So the decryption of data outside the app is immpossible.
- For encryption AES128 algorithm is using with Swift Crypto Framework. kCCOptionPKCS7Padding is used for passing to match 128 bytes.

```
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
```
- Decryption of data to show it in human readable format is done using the same hash key and AES128 algorithm:

```
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
```
