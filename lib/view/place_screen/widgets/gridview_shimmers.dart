import 'package:flutter/material.dart';
import 'package:google_map/utils/app_colors.dart';
import 'package:shimmer/shimmer.dart';

class PlaceGridviewShimmers extends StatelessWidget {
  const PlaceGridviewShimmers({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors().greyColor.shade200,
      highlightColor: AppColors().greyColor.shade100,
      child: GridView.builder(
        shrinkWrap: true,
        //padding: const EdgeInsets.symmetric(vertical: 20),
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 30,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 12,
          crossAxisSpacing: 10,
          childAspectRatio: 0.9,
        ),
        itemBuilder: (context, index) {
          return Column(
            children: [
              Expanded(
                flex: 2,
                child: Container(
                  height: double.infinity,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Container(
                height: 10,
                width: double.infinity,
                color: Colors.white,
              ),
            ],
          );
        },
      ),
    );
  }
}
