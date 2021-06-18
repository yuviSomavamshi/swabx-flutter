import 'package:encrypt/encrypt.dart';
import 'package:swabx/constants.dart';

final key = Key.fromUtf8(CIPHER_SALT);
final iv = IV.fromLength(16);
final encrypter = Encrypter(AES(key, mode: AESMode.cbc));

class Convertor {
  String encrypt(input) {
    var enc = encrypter.encrypt(input, iv: iv).base64;
    return enc;
  }

  String decrypt(encoded) {
    return encrypter.decrypt64(encoded, iv: iv);
  }
}
