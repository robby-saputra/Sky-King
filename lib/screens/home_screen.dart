import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return Scaffold(
                          children: [
                            Icon(Icons.location_on, color: Colors.white),
                          ],
                        ),
                        ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                                Text(
                                  style: GoogleFonts.lato(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  style: GoogleFonts.lato(
                                    fontSize: 16,
                                    color: Colors.white70,
                                  ),
                                ),
                                Text(
                                  style: GoogleFonts.lato(
                                    color: Colors.white,
                                  ),
                                ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        style: GoogleFonts.lato(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 10),
                      SizedBox(
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) {
                                margin: EdgeInsets.only(right: 10),
                                decoration: BoxDecoration(
                                    ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        style: GoogleFonts.lato(
                                          fontSize: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                      SizedBox(height: 5),
                                      SizedBox(height: 5),
                                      Text(
                                        style: GoogleFonts.lato(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        style: GoogleFonts.lato(
                                        ),
                                      ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
        ),
      ),
    );
  }
}
