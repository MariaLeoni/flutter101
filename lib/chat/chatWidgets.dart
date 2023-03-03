import 'package:flutter/material.dart';

Widget errorContainer() {
  return Container(
    clipBehavior: Clip.hardEdge,
    child: Image.asset('assets/images/img_not_available.jpeg',
      height: Sizes.dimen_200,
      width: Sizes.dimen_200,
    ),
  );
}

Widget chatImage({required String imageSrc}) {
  return Container(
    decoration: BoxDecoration(
      border: Border.all(width: 2,),),
    child: Image.network(
      imageSrc, width: Sizes.dimen_200,
      height: Sizes.dimen_200, fit: BoxFit.cover,
      loadingBuilder: (BuildContext ctx, Widget child, ImageChunkEvent? loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          decoration: BoxDecoration(
            color: AppColors.greyColor2,
            borderRadius: BorderRadius.circular(Sizes.dimen_10),
          ),
          width: Sizes.dimen_200,
          height: Sizes.dimen_200,
          child: Center(
            child: CircularProgressIndicator(
              color: AppColors.burgundy,
              value: loadingProgress.expectedTotalBytes != null &&
                  loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                  loadingProgress.expectedTotalBytes!
                  : null,
            ),
          ),
        );
      },
      errorBuilder: (context, object, stackTrace) => errorContainer(),
    ),
  );
}

Widget chatVideoThumbnail({required String videoSrc}) {
  String thumb = "https://firebasestorage.googleapis.com/v0/b/studentshared1.appspot.com/o/1677872264659?alt=media&token=fc1d355a-3733-4b30-8a99-c441fadb6467";
  print("Thumbnail $thumb");
  return Container(
    decoration: BoxDecoration(
      border: Border.all(width: 2,),),
    child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Image.network(thumb, width: Sizes.dimen_200,
            height: Sizes.dimen_200, fit: BoxFit.cover,
            loadingBuilder: (BuildContext ctx, Widget child, ImageChunkEvent? loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                decoration: BoxDecoration(
                  color: AppColors.greyColor2,
                  borderRadius: BorderRadius.circular(Sizes.dimen_10),
                ),
                width: Sizes.dimen_200,
                height: Sizes.dimen_200,
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.burgundy,
                    value: loadingProgress.expectedTotalBytes != null &&
                        loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                ),
              );
            },
            errorBuilder: (context, object, stackTrace) => errorContainer(),
          ),
          const Icon(Icons.play_arrow, color: Colors.green, size: Sizes.dimen_100,)
        ]),
  );
}

Widget messageBubble(
    {required String chatContent,
      required EdgeInsetsGeometry? margin,
      Color? color,
      Color? textColor}) {
  return Container(
    padding: const EdgeInsets.all(Sizes.dimen_10),
    margin: margin,
    width: Sizes.dimen_200,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(Sizes.dimen_10),
    ),
    child: Text(
      chatContent,
      style: TextStyle(fontSize: Sizes.dimen_16, color: textColor),
    ),
  );
}

class AppColors {
  AppColors._();
  static const Color spaceLight = Color(0xff2b3a67);
  static const Color orangeWeb = Color(0xFFf59400);
  static const Color white = Color(0xFFf5f5f5);
  static const Color greyColor = Color(0xffaeaeae);
  static const Color greyColor2 = Color(0xffE8E8E8);
  static const Color lightGrey = Color(0xff928a8a);
  static const Color burgundy = Color(0xFF880d1e);
  static const Color indyBlue = Color(0xFF414361);
  static const Color spaceCadet = Color(0xFF2a2d43);
}

class Sizes {
  Sizes._();

  static const double dimen_0 = 0;
  static const double dimen_1 = 1;
  static const double dimen_2 = 2;
  static const double dimen_4 = 4;
  static const double dimen_6 = 6;
  static const double dimen_8 = 8;
  static const double dimen_10 = 10;
  static const double dimen_12 = 12;
  static const double dimen_14 = 14;
  static const double dimen_16 = 16;
  static const double dimen_18 = 18;
  static const double dimen_20 = 20;
  static const double dimen_22 = 22;
  static const double dimen_24 = 24;
  static const double dimen_26 = 26;
  static const double dimen_28 = 28;
  static const double dimen_30 = 30;
  static const double dimen_32 = 32;
  static const double dimen_34 = 34;
  static const double dimen_36 = 36;
  static const double dimen_38 = 38;
  static const double dimen_40 = 40;
  static const double dimen_42 = 42;
  static const double dimen_44 = 44;
  static const double dimen_46 = 46;
  static const double dimen_48 = 48;
  static const double dimen_50 = 50;
  static const double dimen_64 = 64;
  static const double dimen_80 = 80;
  static const double dimen_100 = 100;
  static const double dimen_105 = 105;
  static const double dimen_110 = 110;
  static const double dimen_120 = 120;
  static const double dimen_140 = 140;
  static const double dimen_150 = 150;
  static const double dimen_160 = 160;
  static const double dimen_200 = 200;
  static const double dimen_230 = 230;
  static const double dimen_250 = 250;
  static const double dimen_300 = 300;
}