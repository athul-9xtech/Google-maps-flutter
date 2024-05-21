import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_map/utils/app_colors.dart';
import 'package:google_map/view/place_screen/widgets/filter_box.dart';

class AppbarWidget extends StatelessWidget {
  const AppbarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        InkWell(
          customBorder: const CircleBorder(),
          onTap: () => Navigator.pop(context),
          child: Icon(
            Icons.arrow_back_ios,
            color: AppColors().darkOrange,
            size: 20,
          ),
        ),
        Column(
          children: [
            Text(
              'Explore',
              style: TextStyle(
                fontSize: 16,
                color: AppColors().greyColor.shade600,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'GURUDWARAS',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),

        // ------- Filter button --------
        InkWell(
          customBorder: const CircleBorder(),
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => const FilterBox(), // open filter dialog box
            );
          },
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppColors().primaryOrange,
                  AppColors().darkOrange,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: const Center(
              child: Icon(
                CupertinoIcons.slider_horizontal_3,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
