import 'package:flutter/material.dart';
import 'package:qiot_admin/models/menu_model.dart';

class TopMenuData {
  final menu = const <MenuModel>[
    MenuModel(icon: Icons.supervised_user_circle_rounded, title: 'Users'),
    MenuModel(icon: Icons.notifications, title: 'Notifications'),
  ];
}
