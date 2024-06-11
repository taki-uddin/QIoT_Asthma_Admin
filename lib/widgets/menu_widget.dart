import 'package:flutter/material.dart';
import 'package:qiot_admin/data/top_menu_data.dart';

class MenuWidget extends StatefulWidget {
  const MenuWidget({super.key});

  @override
  State<MenuWidget> createState() => _MenuWidgetState();
}

class _MenuWidgetState extends State<MenuWidget> {
  int _selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final data = TopMenuData();
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 8.0,
            vertical: 4.0,
          ),
          height: screenSize.height * 0.6,
          child: ListView.builder(
            itemCount: data.menu.length,
            itemBuilder: (context, index) => _buildMenu(data, index),
          ),
        ),
      ],
    );
  }

  Widget _buildMenu(TopMenuData data, int index) {
    final bool isSelected = _selectedIndex == index;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 2.0,
      ),
      child: Container(
        height: 42,
        padding: const EdgeInsets.symmetric(
          horizontal: 8.0,
          vertical: 4.0,
        ),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF004283) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedIndex = index;
            });
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                data.menu[index].icon,
                color: isSelected
                    ? const Color(0xFFFFFFFF)
                    : const Color(0xFF004283),
              ),
              const SizedBox(width: 8.0),
              Text(
                data.menu[index].title,
                style: TextStyle(
                  fontSize: isSelected ? 14.0 : 12.0,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? const Color(0xFFFFFFFF)
                      : const Color(0xFF004283),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
