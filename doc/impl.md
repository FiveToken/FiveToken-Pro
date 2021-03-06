### Generate wallet address

1. #### Generate private key

   - Generate private key via mnemonic words

     Mnemonic words is a random list of 12 English words

     `wood buzz drive exclude squeeze cloud clutch zone winner lazy omit reopen` 

     According to BIP39 protocol, the seeds are generated from the mnemonic words, and the seeds are generated by the BIP32 protocol.

     ```dart
         var mne='wood buzz drive exclude squeeze cloud clutch zone winner lazy omit reopen';
         var seed = bip39.mnemonicToSeed(mne);
         bip32.BIP32 nodeFromSeed = bip32.BIP32.fromSeed(seed);
         var rs = nodeFromSeed.derivePath("m/44'/60'/0'/0");
         var rs0 = rs.derive(0);
         rs0.privateKey; 
     ```

   - Import private key

2. #### Generate address via private key

   There are two types of addresses in a Filecoin network, f1 and F3, which are generated by different signature algorithms.  

   f1: secp256k1 algorithm

   ```json
   {"Type":"secp256k1","PrivateKey":"A0fU665oZgQMFekQDCL1hhrEkvFNDYUvj93mLUep0yI="}
   // hex 7B2254797065223A22736563703235366B31222C22507269766174654B6579223A22413066553636356F5A67514D46656B5144434C31686872456B76464E445955766A39336D4C5565703079493D227D
   ```

   ```dart
   var publickKey = await Flotus.secpPrivateToPublic(ck: privateKey);
   String address = await Flotus.genAddress(pk: publickKey, t: 'secp256k1');
   ```

   f3: bls algorithm

   ```json
   {"Type":"bls","PrivateKey":"A0fU665oZgQMFekQDCL1hhrEkvFNDYUvj93mLUep0yI="}
   // hex 7B2254797065223A22626C73222C22507269766174654B6579223A22413066553636356F5A67514D46656B5144434C31686872456B76464E445955766A39336D4C5565703079493D227D
   ```

   ```dart
   var publickKey = await Bls.pkgen(num: ck);
   String address = await Flotus.genAddress(pk: publickKey, t: 'bls');
   ```

   

### 导入地址

1. #### 只读

2. #### 节点

### Encrypted storage of private key and mnemonic words

1. #### Private key encryption

   - Generate salt via passwords and addresses

     ```dart
     Future<List<int>> genSalt(String addr, String pass) async {
       var str = '${addr}filwalllet$pass';
       final message = utf8.encode(str);
       final hash = await sha256.hash(message);
       return hash.bytes;
     }
     ```

     

   - Generate kek via above salt and password 

     ```dart
     Future<Uint8List> genKek(String addr, String pass, {int size = 32}) async {
       final pbkdf2 = Pbkdf2(
         macAlgorithm: Hmac(sha256),
         iterations: 10000,
         bits: size * 8,
       );
       final nonce = await genSalt(addr, pass);
       final newSecretKey = await pbkdf2.deriveBits(
         utf8.encode(pass),
         nonce: Nonce(nonce),
       );
       return newSecretKey;
     }
     ```

     

   - Convert kek and private key to bin text and store the skkek private key locally via bitwise and encryption

     ```dart
     String xor(List<int> kek, List<int> private, {int size = 32}) {
       var list = <int>[];
       for (var i = 0; i < kek.length; i++) {
         var ele = kek[i];
         var ele2 = private[i];
         var res = ele ^ ele2;
         list.add(res);
       }
       return base64Encode(list);
     }
     ```

     

   - Generate a digest of the private key for password verification

     

     ```dart
     Future<String> genPrivateKeyDigest(String privateKey) async {
       final hash = await sha256.hash(
         base64Decode(privateKey),
       );
       return base64Encode(hash.bytes.sublist(0, 16));
     }
     ```

     

2. #### Mnemonic word encryption

   - Mnemonic words are encrypted by the private key using the AES algorithm.

     ```dart
     String aesEncrypt(String raw, String mix) {
       if (raw == '') {
         return '';
       }
       var m = sha256.convert(base64.decode(mix));
       var key = encrypt.Key.fromBase64(base64.encode(m.bytes));
       final encrypter =
           encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cfb64));
       var encoded = encrypter.encrypt(raw, iv: encrypt.IV.fromLength(16));
       return encoded.base64;
     }
     ```

     

   

### Password verification and private key and mnemonic export

1. #### Verify the passwords

   Generate a kek based on the password and address, obtain the skkek stored locally, convert it to binary, and then perform bit xor with the kek to obtain the decrypted private key.  

     

   ```dart
  Future<String> getPrivateKey(
       String pass,
     ) async {
       var skBytes = base64Decode(skKek);
       var kek = await genKek(address, pass);
       var sk = xor(skBytes, kek);
       var res = addressType == 'eth' ? hex.encode(base64Decode(sk)) : sk;
       return res;
     }
   }
     Future<bool> validatePrivateKey(
       String pass,
     ) async {
       var sk = await this.getPrivateKey(pass);
       var digest = await genPrivateKeyDigest(sk);
       if (this.digest != digest) {
         return false;
       } else {
         return true;
       }
     }
   ```
   
   

2. #### Export private key and mnemonic words

   The process is the same as that for verifying the password. The private key can be exported directly after being extracted based on the password. Mnemonic words is encrypted by the private key.

   ```dart
   var ck = await wallet.getPrivateKey(pass);
   
   var mne = aesDecrypt(wallet.mne, ck);
   ```

   Note that the private key of Filecoin network is only stored within the Private Key part of the json. You need to restore the Private Key to hex format according to the corresponding encryption algorithm based on the address f1 or f3.

### Transfer

1. #### Obtain the nonce value of current address

   Nonce is an integer that increases with the number of transactions. Only the message corresponding to the previous Nonce is linked, and the message corresponding to the next Nonce is packaged  

2. #### Estimated fee

   The estimated fee of Filecoin network consists of three parts: GasFeeCap, GasPremium, and GasLimit. GasFeeCap shall be larger than GasPremium. Also, when transferring FILs to a new account, the required GasLimit is higher than a normal transfer message during account creating.

3. #### Push message

   After finishing message push, the corresponding hash can be obtained and the transaction can be uniquely determined in the blockchain network.

4. #### Accelerate the message on chain

   Miners prioritize messages offered with higher fees, so in a congested network, messages may be blocked in the message pool due to low fees. In this case, the same Nonce message can be sent again, and the new message can be packaged smoothly by raising the handling fee. 

### Build Message

Message building is used to generate unsigned message

```json
{ 
  "Version": 0, 
  "From": "f1azn6pdmnyvszwkv3ufkmp2ucijr6hfb2ezu2hny", 
  "To": "f01035845",
  "Value": 0, 
  "Method": 2, 
  "GasLimit": 6042185, 
  "GasFeeCap": "364043016", 
  "GasPremium": "149331", 
  "Nonce": 65, 
  "Params": "hEQAxZw/QAVYGIJVAZgwIDw7rnFRgTzQ5DfmXYEl7Imi9A==" 
}
//unsigned message
```

The filecoin network contains many different types of messages. Each type of message uses different `Method` and `Params` ,`Method`is a positive integer, and `Params `  is a string generated according to the original JSON serialization. 

1. Transfer

   ```json
   "Method": 0
   "Params": null
   ```

   

2. CreateMiner

   ```json
   "Method": 2
   "Params": {
           "Peer": null,
           "Owner": '',//address of owner
           "Worker": '',//address of worker
           "Multiaddrs": null,
           "WindowPoStProofType": 8 //sector size 8:32G 9:64G
         }
   ```

   

3. ChangeWorkerAddress

   ```json
   "Method": 3
   "Params": {
           "NewWorker": "", //address of new worker
           "NewControlAddrs": [] //address of controller
         }
   ```

   

4. WithdrawBalance

   ```json
   "Method": 16
   "Params":{
     "AmountRequested":"1000000"//amount 
   }
   ```

   

5. ConfirmUpdateWorkerKey

   ```json
   "Method": 21
   "Params": null
   ```

   

6. ChangeOwnerAddress

   ```json
   "Method": 23
   "Params": "" //actor id of new owner
   ```

   

### Sign Message

Use the private key to sign the unsigned message . Different algorithms are adopted according to different sending addresses. When sign a message, first generate the corresponding cid according to the unsigned message, and then sign the cid.

```dart
var cid = await Flotus.messageCid(msg: jsonEncode(message));
//f1
var sign = await Flotus.secpSign(ck: private, msg: cid);
//f3
var sign = await Bls.cksign(num: "$private $cid");
```

```json
{
  "Message": {
    "Version":0,      
    "To":"t134ljmsuc6ab45jiaf2qjahs3j2vl6jv7pm5oema",
    "From":"t16wkgzlglyejqlougingwbnztnp7lrh2xgzlbviq",
    "Value":"1000000000000000000",
    "GasFeeCap":"199610",
    "GasPremium":"199310",
    "GasLimit":47308,
    "Params":"",
    "Nonce":126,
    "Method":0
  },
  "Signature": {
    "Type":1, 
    "Data":"ExDscQ4Au4/pIJqHtoIfLfg4AoeaMxCkJKzyDQTDGZpdq9SXSMdZnI3jRKY5RsJ/r/4sBQE="
  }
}
//signed message
```

### Message Push

push signed message to block chain

### Multi-sign Account

1. Create

```json
"Method": 2
"Params": {
      'signers': [],//signer address
      'threshold': 1,//the minimum number of signers whose proposal is approved
      'unlock_duration': 0 //unlock duration
    }
```

2. Import

3. Propose

   The proposer is one of the signers of the multi-sign account, and the receiver is the multi-sign account itself. The supported methods are the same as message building.

4. Approve
