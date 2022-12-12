// ignore_for_file: empty_catches

import 'dart:core';

import 'package:app/structures/models/customerModel.dart';

class CustomerManager {
  CustomerManager._();
  
  static final List<CustomerModel> _list = [];
  static List<CustomerModel> get customerList => _list;
  ///-----------------------------------------------------------------------------------------
  static CustomerModel? getById(String? id){
    try {
      return _list.firstWhere((element) => element.userId == id);
    }
    catch(e){
      return null;
    }
  }

  static CustomerModel addItem(CustomerModel item){
    final existItem = getById(item.userId);

    if(existItem == null) {
      _list.add(item);
      return item;
    }
    else {
      existItem.matchBy(item);
      return existItem;
    }
  }

  static List<CustomerModel> addItemsFromMap(List? itemList, {String? domain}){
    final res = <CustomerModel>[];

    if(itemList != null){
      for(final row in itemList){
        final itm = CustomerModel.fromMap(row, domain: domain);
        addItem(itm);

        res.add(itm);
      }
    }

    return res;
  }

  static Future removeItem(String id) async {
    _list.removeWhere((element) => element.userId == id);
  }

  static Future removeNotMatchByServer(List<String> serverIds) async {
    _list.removeWhere((element) => !serverIds.contains(element.userId));
  }
}
