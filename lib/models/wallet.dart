import 'package:fil/index.dart';
import 'package:hive/hive.dart';
part 'wallet.g.dart';

@HiveType(typeId: 3)
class Wallet {
  @HiveField(0)
  int count;
  @HiveField(1)
  int readonly;
  @HiveField(2)
  int walletType;
  @HiveField(3)
  String label;
  @HiveField(4)
  String ck;
  @HiveField(5)
  String address;
  @HiveField(6)
  String type;
  @HiveField(7)
  String owner;
  @HiveField(8)
  String balance;
  @HiveField(9)
  bool inAddressBook;
  @HiveField(10)
  bool push;
  @HiveField(11)
  String skKek;
  @HiveField(12)
  String digest;
  @HiveField(13)
  String mne;
  Wallet(
      {int count = 1,
      String ck = '',
      String label = '',
      String address = '',
      String type = '1',
      int readonly = 0,
      int walletType = 0,
      String balance = '0',
      String owner = '',
      bool push = false,
      bool inAddressBook = true,
      String digest = '',
      String mne = '',
      String skKek = ''}) {
    this.count = count;
    this.ck = ck;
    this.label = label;
    this.address = address;
    this.type = type;
    this.readonly = readonly;
    this.walletType = walletType;
    this.balance = balance;
    this.owner = owner;
    this.inAddressBook = inAddressBook;
    this.push = push;
    this.skKek = skKek;
    this.digest = digest;
    this.mne = mne;
  }
  Wallet.fromJson(Map<dynamic, dynamic> json) {
    this.count = json['count'] as int;
    this.ck = json['ck'] as String;
    this.label = json['label'] as String;
    this.address = json['address'] as String;
    this.type = json['type'] as String;
    this.readonly = json['readonly'] as int;
    this.walletType = json['walletType'] as int;
    this.owner = json['owner'] as String;
    this.balance = json['balance'] as String;
    this.skKek = json['skKek'] as String;
    this.digest = json['digest'] as String;
    this.mne = json['mne'] as String;
    this.push = json['push'] as bool;
  }
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'count': this.count,
      'ck': this.ck,
      'label': this.label,
      'address': this.address,
      'type': this.type,
      'readonly': this.readonly,
      'walletType': this.walletType,
      'owner': this.owner,
      'balance': this.balance,
      'skKek': this.skKek,
      'digest': this.digest,
      'inAddressBook': this.inAddressBook,
      'mne': mne,
      'push': push
    };
  }

  String get addr {
    return address;
  }

  String get addrWithNet {
    if (addr == '') {
      return '';
    }
    return Global.netPrefix + addr.substring(1);
  }

  BigInt get balanceNum {
    try {
      var v = BigInt.parse(balance);
      return v;
    } catch (e) {
      return BigInt.zero;
    }
  }
}

@HiveType(typeId: 14)
class MultiSignWallet {
  @HiveField(0)
  String label;
  @HiveField(1)
  String id;
  @HiveField(2)
  String owner;
  @HiveField(3)
  String balance;
  @HiveField(4)
  int threshold;
  @HiveField(5)
  List<String> signers;
  @HiveField(6)
  String cid;
  @HiveField(7)
  int status;
  @HiveField(8)
  num blockTime;
  @HiveField(9)
  Map<String, String> signerMap;
  @HiveField(10)
  String robustAddress;
  MultiSignWallet(
      {this.label = '',
      this.id = '',
      this.owner = '',
      this.balance = '0',
      this.threshold,
      this.cid = '',
      this.blockTime = 0,
      this.status = 0,
      this.signerMap,
      this.robustAddress,
      this.signers});
  MultiSignWallet.fromJson(Map<String, dynamic> json) {
    label = json['label'];
    id = json['id'];
    owner = json['owner'];
    balance = json['balance'];
    threshold = json['threshold'];
    signers = json['signers'];
    status = json['status'];
    cid = json['cid'];
    robustAddress = json['robustAddress'];
    signerMap = json['signerMap'];
  }
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'label': label,
      'id': id,
      'owner': owner,
      'balance': balance,
      'threshold': threshold,
      'signers': signers,
      'cid': cid,
      'status': status,
      'signerMap': signerMap,
      'robustAddress': robustAddress
    };
  }

  String get addrWithNet {
    return Global.netPrefix + id.substring(1);
  }
}

class MultiWalletInfo {
  String balance;
  num approveRequired;
  List<Map<String, String>> signers;
  Map<String, String> signerMap;
  String robustAddress;
  MultiWalletInfo(
      {this.balance,
      this.approveRequired,
      this.signers,
      this.signerMap,
      this.robustAddress});
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'balance': balance,
      'signers': signers,
      'approveRequired': approveRequired
    };
  }
}

class FilPrice {
  double usd;
  double cny;
  FilPrice({this.usd = 0.0, this.cny = 0.0});
  FilPrice.fromJson(Map<String, dynamic> json) {
    usd = json['usd'] + 0.0 as double;
    cny = json['cny'] + 0.0 as double;
  }
  double get rate {
    //var lang = Global.langCode;
    var lang = 'en';
    return lang == 'en' ? usd : cny;
  }

  Map<String, double> toJson() {
    return <String, double>{"usd": usd, "cny": cny};
  }
}
