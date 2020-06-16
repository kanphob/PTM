class ModelProduct {
  String sName;
  String sCode;
  String sBarcode;
  String sGroup;
  String sImg64;

  ModelProduct(this.sBarcode, this.sCode, this.sName, this.sGroup, this.sImg64);

  static bool get isEmpty => null;

  String get getBarcode => sBarcode;

  String get getCode => sCode;

  String get getName => sName;

  String get getGroup => sGroup;

  String get getsImg64 => sImg64;

  set setBarcode(String sBarcode) {
    this.sBarcode = sBarcode;
  }

  set setCode(String sCode) {
    this.sCode = sCode;
  }

  set setName(String sName) {
    this.sName = sName;
  }

  set setGroup(String sGroup) {
    this.sGroup = sGroup;
  }
}
