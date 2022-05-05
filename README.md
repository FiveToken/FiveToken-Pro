# FiveToken Pro

FiveToken Pro is XXX

## How to run

### Necessary dependencies

- Flutter (Channel stable, 1.22.5）
- Android toolchain - develop for Android devices (Android SDK )
- Xcode - develop for iOS and macOS 
- Android Studio 

After  install the dependencies above, clone this project and enter the root directory. Then you can run `flutter pub get` to install third-party code required for this project. When the above operations are completed，run `flutter run` to start app.

## How to switch network

As we support filecoin mainnet and calibration net. If you want to run this app in different network, you should find the file at `lib->common->global.dart` and edit the value of variable NetPrefix. The value of mainnet is 'f' and calibration is 't'.

## Run Unit Test

`flutter test`

## How to build

### Android

just run `flutter build apk`

### IOS

- run `flutter build ios`
- open the ios directory in Xcode
- click Product -> Archive 

## License

[MIT](https://github.com/FiveToken/FiveToken-Pro/blob/master/LICENSE)

## Links

[Project structure](./doc/code-tree.txt)

[Design documents](./doc/impl.md)