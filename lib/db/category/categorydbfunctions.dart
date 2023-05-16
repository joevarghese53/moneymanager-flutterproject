import 'package:flutter/foundation.dart';
import 'package:hive_flutter/adapters.dart';

import '../../models/category/categorymodel.dart';

const categorydbname = 'categorydbname';

abstract class Categoryfunctionsab {
  Future<List<Categorymodel>> getcategories();
  Future<void> insertcategory(Categorymodel value);
  Future<void> deletecategory(String categoryid);
}

class Categoryfunctions implements Categoryfunctionsab {
  Categoryfunctions._internal();
  static Categoryfunctions instance = Categoryfunctions._internal();

  factory Categoryfunctions() {
    return instance;
  }

  ValueNotifier<List<Categorymodel>> incomelistnotifier = ValueNotifier([]);
  ValueNotifier<List<Categorymodel>> expenselistnotifier = ValueNotifier([]);

  @override
  Future<void> insertcategory(Categorymodel value) async {
    final categorydbopen = await Hive.openBox<Categorymodel>(categorydbname);
    categorydbopen.put(value.id, value);
    refreshui();
  }

  @override
  Future<List<Categorymodel>> getcategories() async {
    final categorydbopen = await Hive.openBox<Categorymodel>(categorydbname);
    return categorydbopen.values.toList();
  }

  Future<void> refreshui() async {
    final _allcategorylist = await getcategories();
    incomelistnotifier.value.clear();
    expenselistnotifier.value.clear();
    Future.forEach(_allcategorylist, (Categorymodel category) {
      if (category.type == Categorytype.income) {
        incomelistnotifier.value.add(category);
      } else {
        expenselistnotifier.value.add(category);
      }
    });
    incomelistnotifier.notifyListeners();
    expenselistnotifier.notifyListeners();
  }

  @override
  Future<void> deletecategory(String categoryid) async {
    final categorydbopen = await Hive.openBox<Categorymodel>(categorydbname);
    await categorydbopen.delete(categoryid);
    refreshui();
  }
}
