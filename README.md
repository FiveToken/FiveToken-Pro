# FiveToken Pro

FiveToken Pro, to provide professional transaction service for Filecoin storage providers and to bridge Filecoin ecosystem to Web 3 metaverse with reliable ID management.

# Introduction of  product

The future of Filecoin ecosystem and Web3 network are highly expected especially when the related applications are booming because it means Filecoin network has converted the data value from storing to flowing. But from the perspective of Token Infrastructure, Filecoin ecosystem is lacking a product that can both offer professional token service for miners and help Filecoin to expand its awareness to the big blockchain world and the broader communities. Web 3 is lacking a decentralized and comprehensive payment app like PayPal.

After several iterations, the basic functions of filecoin wallet have strong security, availability and stability. 

The current features FiveToken supports are:

- Android & IOS - download and install
- Create wallet, import mnemonic words and import private key;
- Support HD wallets (Hierarchical Deterministic) that support to create multiple wallet addresses from one mnemonic phrase
- Locally store and encrypt the private key
- FIL transaction & Gas consumption estimation
- Defined method ID of message by user
- Display records of messages and message delivery status
- Address list management
- Multiple wallet management (add, switch, etc.)
- Storage provider status monitoring
- Quick & easy transfer for owner and quick & easy recharge for worker and owner
- Storage provider withdraw, change owner address, change worker address and push ID message by user
- Private key backup
- Information transmission via QR code on different devices
- Multi-sign wallet (create, import, propose, approve)
- Read only Wallet
- Message notification 
- Cold Wallet
- Support f1 (secp256k1) & f3 (BLS)
- Multilingual support (Chinese, English, Japanese, Korean) 

## How to run

### Necessary dependencies

- Flutter (Channel stable, 1.22.5）
- Android toolchain - develop for Android devices (Android SDK )
- Xcode - develop for iOS and macOS 
- Android Studio 

After install the dependencies above, clone this project and enter the root directory. Then you can run `flutter pub get` to install third-party code required for this project. When the above operations are completed，run `flutter run` to start app.

## How to switch network

We support Filecoin mainnet and calibration network. If you want to run this app in different network, you can find the file at `lib->common->global.dart` and edit the value of variable NetPrefix. The value of mainnet is 'f' and calibration is 't'.

## How to build

### Android

Just run `flutter build apk`

### IOS

- Run `flutter build ios`
- Open the ios directory in Xcode
- Click Product -> Archive 

# How to use

Check [FiveToken Documentation](https://docs.fivetoken.io/userguide/proapp.html)

## License

[MIT](https://github.com/FiveToken/FiveToken-Pro/blob/master/LICENSE)

