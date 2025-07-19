import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:carebellmom/patient_management/patients_management.dart';
import '../notification.dart';
import 'package:carebellmom/patientPages/viewDetails.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:carousel_slider/carousel_slider.dart';

class PatientHomePage extends StatelessWidget {
  const PatientHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: EdgeInsets.only(top: 5.0, left: 15.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // เว้นระยะห่างระหว่างรูปกับข้อความ
                    Text(
                      "ยินดีต้อนรับเข้าสู่",
                      style: TextStyle(
                        fontFamily: "Anuphun",
                        fontSize: screenWidth * 0.03,
                        fontWeight: FontWeight.w300,
                        color: const Color.fromARGB(255, 0, 0, 0),
                        /*shadows: [
                          Shadow(
                            color:
                                Colors.grey, // หรือเปลี่ยนเป็นสีที่คุณต้องการ
                            offset: Offset(0, 1.0), // เลื่อนเงาแนวนอนและแนวตั้ง
                            blurRadius: 0.1, // ความเบลอของเงา
                          ),
                        ],*/
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: EdgeInsets.only(top: 5.0, left: 15.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // เว้นระยะห่างระหว่างรูปกับข้อความ
                    Text(
                      "Care bell mom",
                      style: TextStyle(
                        fontFamily: "Inter",
                        fontSize: screenWidth * 0.04,
                        fontWeight: FontWeight.w600,
                        color: const Color.fromARGB(255, 0, 65, 206),
                        /*shadows: [
                          Shadow(
                            color:
                                Colors.grey, // หรือเปลี่ยนเป็นสีที่คุณต้องการ
                            offset: Offset(0, 1.0), // เลื่อนเงาแนวนอนและแนวตั้ง
                            blurRadius: 0.1, // ความเบลอของเงา
                          ),
                        ],*/
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        toolbarHeight: 130,
        backgroundColor: const Color.fromARGB(255, 150, 208, 255),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
        ),
        shadowColor: const Color.fromARGB(255, 124, 124, 124),
      ),
      body: Container(
        child: Column(
          children: [
            Expanded(child: content(context)),
            Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: SizedBox(
                width: screenWidth * 0.6,
                height: screenHeight * 0.05,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    shadowColor: Colors.grey[700],
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ViewDetails(),
                      ),
                    );
                  },

                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.list_alt_rounded),
                      SizedBox(width: 10),
                      Text('รายละเอียดการนัดครวจครรภ์'),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget content(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return CarouselSlider(
      items:
          ['assets/jk/1.jpg', 'assets/jk/2.jpg', 'assets/jk/3.jpg'].map((
            imagePath,
          ) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 5,
                    offset: Offset(2, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.fill,
                  width: screenWidth * 0.75,
                ),
              ),
            );
          }).toList(),
      options: CarouselOptions(
        height: screenHeight * 0.55,
        enlargeCenterPage: true,
        aspectRatio: 16 / 9,
        viewportFraction: 0.80,
      ),
    );
  }
}
