import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_icons/line_icons.dart';
import 'package:animations/animations.dart';

import 'home.dart';

class LocationSelectionScreen extends StatefulWidget {
  @override
  _LocationSelectionScreenState createState() => _LocationSelectionScreenState();
}

class _LocationSelectionScreenState extends State<LocationSelectionScreen> {
  List<String> _savedLocations = [
    'New York, USA',
    'London, UK',
    'Tokyo, Japan',
  ];

  List<Map<String, dynamic>> _citiesByRegion = [
    {
      'region': 'North America',
      'cities': ['New York', 'Los Angeles', 'Toronto', 'Chicago', 'Miami'],
    },
    {
      'region': 'Europe',
      'cities': ['London', 'Paris', 'Berlin', 'Rome', 'Madrid'],
    },
    {
      'region': 'Asia',
      'cities': ['Tokyo', 'Shanghai', 'Singapore', 'Dubai', 'Mumbai'],
    },
    {
      'region': 'Oceania',
      'cities': ['Sydney', 'Melbourne', 'Auckland', 'Brisbane'],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0F2027),
              Color(0xFF203A43),
              Color(0xFF2C5364),
            ],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 120,
              pinned: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  'Select Location',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                centerTitle: true,
              ),
              actions: [
                IconButton(
                  icon: Icon(LineIcons.plus, color: Colors.white),
                  onPressed: () {
                    // Add new location
                  },
                ),
              ],
            ),

            // Current Location
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: OpenContainer(
                  closedElevation: 0,
                  closedColor: Colors.transparent,
                  closedBuilder: (context, action) => _buildLocationCard(
                    'Current Location',
                    'Using GPS',
                    LineIcons.locationArrow,
                    Colors.blue,
                    isCurrent: true,
                  ),
                  openBuilder: (context, action) => HomeScreen(),
                ),
              ),
            ),

            // Saved Locations
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'SAVED LOCATIONS',
                  style: GoogleFonts.poppins(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 12,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),

            SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) => Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: _buildSavedLocationItem(index),
                ),
                childCount: _savedLocations.length,
              ),
            ),

            // Browse by Region
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'BROWSE BY REGION',
                  style: GoogleFonts.poppins(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 12,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),

            SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildRegionSection(index),
                childCount: _citiesByRegion.length,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationCard(String title, String subtitle, IconData icon, Color color, {bool isCurrent = false}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.3),
            color.withOpacity(0.1),
          ],
        ),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 28,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            if (isCurrent)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Active',
                  style: GoogleFonts.poppins(
                    color: Colors.green,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            SizedBox(width: 12),
            Icon(
              LineIcons.chevronRight,
              color: Colors.white.withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSavedLocationItem(int index) {
    final location = _savedLocations[index];
    return Dismissible(
      key: Key(location),
      background: Container(
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20),
        child: Icon(
          LineIcons.trash,
          color: Colors.red,
        ),
      ),
      child: InkWell(
        onTap: () {
          Navigator.pop(context, location);
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  LineIcons.mapMarked,
                  color: Colors.white.withOpacity(0.7),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Text(
                    location,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
                Icon(
                  LineIcons.chevronRight,
                  color: Colors.white.withOpacity(0.5),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRegionSection(int index) {
    final region = _citiesByRegion[index];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Text(
            region['region'],
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Container(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 20),
            itemCount: region['cities'].length,
            itemBuilder: (context, cityIndex) {
              return Padding(
                padding: EdgeInsets.only(right: 12),
                child: InkWell(
                  onTap: () {
                    Navigator.pop(context, '${region['cities'][cityIndex]}, ${region['region'].split(' ').first}');
                  },
                  child: Container(
                    width: 160,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.white.withOpacity(0.05),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          right: 12,
                          top: 12,
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.1),
                            ),
                            child: Icon(
                              LineIcons.plus,
                              color: Colors.white.withOpacity(0.7),
                              size: 16,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                region['cities'][cityIndex],
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '${20 + cityIndex}°C',
                                style: GoogleFonts.poppins(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(height: 20),
      ],
    );
  }
}