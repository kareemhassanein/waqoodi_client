import 'package:flutter/material.dart';

abstract class Languages {
  static Languages? of(BuildContext context) {
    return Localizations.of<Languages>(context, Languages);
  }

  String get appName;
  String get langName;
  String get sar;
  String get hello;
  String get pending;
  String get inProgress;
  String get done;
  String get stations;
  String get station;
  String get myProfile;
  String get changeLanguage;
  String get changePassword;
  String get logOut;
  String get date;
  String get l;
  String get quantity;
  String get subTotal;
  String get vat;
  String get total;
  String get submit;
  String get edit;
  String get stationLocation;
  String get orderDetails;
  String get dueDate;
  String get invoiceDetails;
  String get productDetails;
  String get productType;
  String get noStationsAdded;
  String get orderStatus;
  String get cancelOrder;
  String get areYouSureToCancelOrder;
  String get yesCancel;
  String get no;
  String get noOrders;
  String get email;
  String get profile;
  String get name;
  String get required;
  String get save;
  String get addNewStation;
  String get address;
  String get location;
  String get cancel;
  String get areYouSureToLogOut;
  String get newPassword;
  String get confirmNewPassword;
  String get signIn;
  String get plsSignIn;
  String get plsSignUp;
  String get phone;
  String get enterPassword;
  String get forgerPassword;
  String get dontHaveAnAccount;
  String get signUp;
  String get confirmPassword;
  String get alreadyHaveAccount;
  String get tryAgain;
  String get createNewOrder;

  String get deliveryAddress;

  String get deliveryDate;

  String get exclusiveVAT;

  String get inclusiveVAT;

  String get requiredQuantity;

  String get requiredProduct;

  String get confirmOrder;
  String get paymentMethod;

}
