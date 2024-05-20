import 'package:flutter/material.dart';
import 'package:country_state_city/country_state_city.dart' as csc;
import 'package:get/get.dart';
import 'package:google_map/controller/csc_controller.dart';
import 'package:google_map/utils/app_colors.dart';

class FilterDropDownButton extends StatefulWidget {
  const FilterDropDownButton(
      {super.key, required this.hintText, this.states, this.cities});

  final String hintText;
  final List<csc.State>? states;
  final List<csc.City>? cities;

  @override
  State<FilterDropDownButton> createState() => _FilterDropDownButtonState();
}

class _FilterDropDownButtonState extends State<FilterDropDownButton> {
  final cscController = Get.find<CscController>();
  String? selectedItem;

  @override
  void initState() {
    initSelectedItem();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant FilterDropDownButton oldWidget) {
    initSelectedItem();
    super.didUpdateWidget(oldWidget);
  }

  void initSelectedItem() {
    if (widget.states != null && cscController.state != null) {
      selectedItem = cscController.state!.name;
    } else if (widget.cities != null && cscController.city != null) {
      selectedItem = cscController.city!.name;
    } else {
      selectedItem = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        splashFactory: NoSplash.splashFactory,
      ),
      child: PopupMenuButton<dynamic>(
        icon: Container(
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selectedItem != null
                  ? AppColors().primaryOrange
                  : Colors.grey.shade400,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                selectedItem ?? widget.hintText,
                style: TextStyle(
                  color: selectedItem != null
                      ? AppColors().primaryOrange
                      : Colors.black,
                ),
              ),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                color: selectedItem != null
                    ? AppColors().primaryOrange
                    : Colors.black,
              ),
            ],
          ),
        ),
        offset: const Offset(0, 55),
        surfaceTintColor: Colors.transparent,
        padding: EdgeInsets.zero,
        constraints:
            BoxConstraints(maxHeight: MediaQuery.of(context).size.height / 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        itemBuilder: (BuildContext context) {
          return widget.states != null
              ? widget.states!
                  .map<PopupMenuEntry<csc.State>>((csc.State value) {
                  return PopupMenuItem<csc.State>(
                    value: value,
                    //padding: EdgeInsets.all(16),
                    child: ListTile(
                      dense: true,
                      title: Text(
                        value.name,
                        style: TextStyle(
                          fontSize: 12,
                          color: value.name == selectedItem
                              ? AppColors().primaryOrange
                              : Colors.black,
                        ),
                      ),
                    ),
                  );
                }).toList()
              : widget.cities!.map<PopupMenuEntry<csc.City>>((csc.City value) {
                  return PopupMenuItem<csc.City>(
                    value: value,
                    //padding: EdgeInsets.zero,
                    child: ListTile(
                      dense: true,
                      title: Text(
                        value.name,
                        style: TextStyle(
                          fontSize: 12,
                          color: value.name == selectedItem
                              ? AppColors().primaryOrange
                              : Colors.black,
                        ),
                      ),
                    ),
                  );
                }).toList();
        },
        onSelected: (value) {
          selectedItem = value.name;
          if (widget.states != null) {
            cscController.state = value;
            cscController.city = null;
            cscController.update(['city-dropdown']);
          } else {
            cscController.city = value;
          }
          setState(() {});
        },
      ),
    );
  }
}
