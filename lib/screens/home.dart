import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animations/animations.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../providers/weather_provider.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenWidth < 600;
    final weatherProvider = Provider.of<WeatherProvider>(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1E91BD).withOpacity(0.99),
              Color(0xFF203A43).withOpacity(0.9),
              Color(0xFF2C5364).withOpacity(0.85),
            ],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: CustomScrollView(
            physics: BouncingScrollPhysics(),
            slivers: [
              // App Bar with Search
              SliverAppBar(
                expandedHeight: screenHeight * 0.2,
                collapsedHeight: screenHeight * 0.12,
                pinned: true,
                stretch: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.pin,
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.3),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  titlePadding: EdgeInsets.only(
                    left: isSmallScreen ? 16 : 20,
                    bottom: isSmallScreen ? 12 : 16,
                    right: isSmallScreen ? 16 : 20,
                  ),
                  title: weatherProvider.isLoading && weatherProvider.weatherData == null
                      ? _buildSearchBarShimmer(isSmallScreen)
                      : _buildSearchBar(isSmallScreen, weatherProvider),
                ),
              ),

              // Error Message
              if (weatherProvider.error.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 16 : 20,
                      vertical: 10,
                    ),
                    child: Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error, color: Colors.red, size: 20),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              weatherProvider.error,
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.close, color: Colors.white, size: 18),
                            onPressed: weatherProvider.clearError,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // Main Weather Card
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 16 : 20,
                  ),
                  child: weatherProvider.isLoading && weatherProvider.weatherData == null
                      ? _buildWeatherCardShimmer(isSmallScreen)
                      : (weatherProvider.weatherData != null
                      ? OpenContainer(
                    closedElevation: 0,
                    closedColor: Colors.transparent,
                    closedBuilder: (context, action) =>
                        _buildWeatherCard(isSmallScreen, weatherProvider),
                    openBuilder: (context, action) =>
                        _buildDetailedWeatherView(weatherProvider),
                  )
                      : _buildNoDataCard(isSmallScreen)),
                ),
              ),

              // Hourly Forecast
              if (weatherProvider.isLoading && weatherProvider.weatherData == null)
                SliverToBoxAdapter(
                  child: _buildHourlyForecastShimmer(isSmallScreen),
                )
              else if (!weatherProvider.isLoading && weatherProvider.weatherData != null)
                SliverToBoxAdapter(
                  child: _buildHourlyForecast(isSmallScreen, weatherProvider),
                ),

              // Daily Forecast Header
              if (weatherProvider.isLoading && weatherProvider.weatherData == null)
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _StickyHeaderDelegate(
                    minHeight: 60,
                    maxHeight: 60,
                    child: Container(
                      color: Colors.black.withOpacity(0.3),
                      padding: EdgeInsets.symmetric(
                        horizontal: isSmallScreen ? 16 : 20,
                      ),
                      child: Shimmer.fromColors(
                        baseColor: Colors.white.withOpacity(0.1),
                        highlightColor: Colors.white.withOpacity(0.2),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: 120,
                              height: 16,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              else if (!weatherProvider.isLoading && weatherProvider.weatherData != null)
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _StickyHeaderDelegate(
                    minHeight: 60,
                    maxHeight: 60,
                    child: Container(
                      color: Colors.black.withOpacity(0.3),
                      padding: EdgeInsets.symmetric(
                        horizontal: isSmallScreen ? 16 : 20,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '7-DAY FORECAST',
                            style: GoogleFonts.poppins(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: isSmallScreen ? 14 : 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1,
                            ),
                          ),
                          Icon(
                            Icons.calendar_today,
                            color: Colors.white.withOpacity(0.8),
                            size: isSmallScreen ? 18 : 22,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // Daily Forecast List
              if (weatherProvider.isLoading && weatherProvider.weatherData == null)
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) => _buildDailyForecastItemShimmer(index, isSmallScreen),
                    childCount: 7,
                  ),
                )
              else if (!weatherProvider.isLoading && weatherProvider.weatherData != null)
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) => _buildDailyForecastItem(
                      index,
                      isSmallScreen,
                      weatherProvider,
                    ),
                    childCount: weatherProvider.getDailyForecast().length,
                  ),
                ),

              // Popular Cities Header
              SliverPersistentHeader(
                pinned: true,
                delegate: _StickyHeaderDelegate(
                  minHeight: 60,
                  maxHeight: 60,
                  child: Container(
                    color: Colors.black.withOpacity(0.3),
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 16 : 20,
                    ),
                    child: weatherProvider.isLoading && weatherProvider.weatherData == null
                        ? Shimmer.fromColors(
                      baseColor: Colors.white.withOpacity(0.1),
                      highlightColor: Colors.white.withOpacity(0.2),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 120,
                            height: 16,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ],
                      ),
                    )
                        : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'POPULAR CITIES',
                          style: GoogleFonts.poppins(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: isSmallScreen ? 14 : 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                          ),
                        ),
                        Icon(
                          Icons.public,
                          color: Colors.white.withOpacity(0.8),
                          size: isSmallScreen ? 18 : 22,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Popular Cities Grid
              SliverPadding(
                padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isSmallScreen ? 2 : 2,
                    crossAxisSpacing: isSmallScreen ? 12 : 15,
                    mainAxisSpacing: isSmallScreen ? 12 : 15,
                    childAspectRatio: isSmallScreen ? 1.6 : 1.8,
                  ),
                  delegate: SliverChildBuilderDelegate(
                        (context, index) => weatherProvider.isLoading && weatherProvider.weatherData == null
                        ? _buildCityCardShimmer(index, isSmallScreen)
                        : _buildCityCard(index, isSmallScreen, weatherProvider),
                    childCount: weatherProvider.isLoading && weatherProvider.weatherData == null
                        ? 4
                        : weatherProvider.popularCities.length,
                  ),
                ),
              ),

              // Bottom padding
              SliverToBoxAdapter(
                child: SizedBox(height: screenHeight * 0.1),
              ),
            ],
          ),
        ),
      ),

      // Bottom Navigation
      bottomNavigationBar: _buildBottomNavigationBar(isSmallScreen),

      // Floating Action Button for Current Location
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          weatherProvider.fetchWeatherByLocation();
        },
        backgroundColor: Colors.white,
        foregroundColor: Color(0xFF2C5364),
        child: Icon(Icons.my_location, size: isSmallScreen ? 24 : 28),
        shape: CircleBorder(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  // SHIMMER WIDGETS
  Widget _buildSearchBarShimmer(bool isSmallScreen) {
    return Shimmer.fromColors(
      baseColor: Colors.white.withOpacity(0.1),
      highlightColor: Colors.white.withOpacity(0.2),
      child: Container(
        height: isSmallScreen ? 48 : 56,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(isSmallScreen ? 24 : 28),
        ),
      ),
    );
  }

  Widget _buildWeatherCardShimmer(bool isSmallScreen) {
    return Container(
      margin: EdgeInsets.only(bottom: isSmallScreen ? 16 : 20),
      constraints: BoxConstraints(
        maxHeight: isSmallScreen ? 380 : 480, // ADD max height
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(isSmallScreen ? 20 : 24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.15),
            Colors.white.withOpacity(0.05),
          ],
        ),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 18 : 26),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Location and Time Shimmer
            Shimmer.fromColors(
              baseColor: Colors.white.withOpacity(0.1),
              highlightColor: Colors.white.withOpacity(0.2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 150,
                        height: 28,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          SizedBox(width: 8),
                          Container(
                            width: 100,
                            height: 14,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(7),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    width: 50,
                    height: 30,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: isSmallScreen ? 20 : 30),

            // Temperature Shimmer
            Shimmer.fromColors(
              baseColor: Colors.white.withOpacity(0.1),
              highlightColor: Colors.white.withOpacity(0.2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 100,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            SizedBox(width: 4),
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Container(
                          width: 120,
                          height: 20,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: isSmallScreen ? 80 : 120,
                    height: isSmallScreen ? 80 : 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: isSmallScreen ? 20 : 30),

            // Weather Details Grid Shimmer - SIMPLIFIED
            SizedBox(
              height: isSmallScreen ? 120 : 150, // FIXED HEIGHT
              child: GridView.count(
                physics: NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: isSmallScreen ? 12 : 20,
                mainAxisSpacing: isSmallScreen ? 12 : 20,
                childAspectRatio: isSmallScreen ? 2.5 : 3,
                children: List.generate(4, (index) =>
                    Shimmer.fromColors(
                      baseColor: Colors.white.withOpacity(0.1),
                      highlightColor: Colors.white.withOpacity(0.2),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHourlyForecastShimmer(bool isSmallScreen) {
    return Container(
      height: isSmallScreen ? 140 : 160,
      padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 16 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 16 : 20),
            child: Shimmer.fromColors(
              baseColor: Colors.white.withOpacity(0.1),
              highlightColor: Colors.white.withOpacity(0.2),
              child: Container(
                width: 120,
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          SizedBox(height: isSmallScreen ? 12 : 16),
          Expanded(
            child: Shimmer.fromColors(
              baseColor: Colors.white.withOpacity(0.1),
              highlightColor: Colors.white.withOpacity(0.2),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 16 : 20),
                itemCount: 8,
                itemBuilder: (context, index) {
                  return Container(
                    width: isSmallScreen ? 70 : 80,
                    margin: EdgeInsets.only(right: isSmallScreen ? 10 : 12),
                    padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(isSmallScreen ? 14 : 16),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Container(
                          width: 30,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        Container(
                          width: 30,
                          height: 16,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyForecastItemShimmer(int index, bool isSmallScreen) {
    return Shimmer.fromColors(
      baseColor: Colors.white.withOpacity(0.1),
      highlightColor: Colors.white.withOpacity(0.2),
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 16 : 20,
          vertical: isSmallScreen ? 6 : 8,
        ),
        padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(isSmallScreen ? 14 : 16),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Container(
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            Expanded(
              child: Container(
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            Expanded(
              child: Container(
                height: 14,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(7),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    width: 30,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  SizedBox(width: isSmallScreen ? 12 : 16),
                  Container(
                    width: 30,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCityCardShimmer(int index, bool isSmallScreen) {
    return Shimmer.fromColors(
      baseColor: Colors.white.withOpacity(0.1),
      highlightColor: Colors.white.withOpacity(0.2),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(isSmallScreen ? 14 : 16),
          color: Colors.white.withOpacity(0.1),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              right: isSmallScreen ? 8 : 12,
              top: isSmallScreen ? 8 : 12,
              child: Container(
                width: isSmallScreen ? 32 : 40,
                height: isSmallScreen ? 32 : 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 80,
                        height: 18,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(9),
                        ),
                      ),
                      SizedBox(height: isSmallScreen ? 2 : 4),
                      Container(
                        width: 60,
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(7),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: 40,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ORIGINAL WIDGETS
  Widget _buildSearchBar(bool isSmallScreen, WeatherProvider weatherProvider) {
    return Container(
      height: isSmallScreen ? 48 : 56,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(isSmallScreen ? 24 : 28),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Autocomplete<String>(
        fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
          return TextField(
            controller: textEditingController,
            focusNode: focusNode,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: isSmallScreen ? 14 : 16,
            ),
            decoration: InputDecoration(
              prefixIcon: Icon(
                Icons.search,
                color: Colors.white.withOpacity(0.7),
                size: isSmallScreen ? 20 : 24,
              ),
              hintText: 'Search city...',
              hintStyle: GoogleFonts.poppins(
                color: Colors.white.withOpacity(0.5),
                fontSize: isSmallScreen ? 14 : 16,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 16 : 20,
                vertical: isSmallScreen ? 12 : 16,
              ),
            ),
            onSubmitted: (value) {
              if (value.isNotEmpty) {
                weatherProvider.fetchWeatherByCity(value);
                textEditingController.clear();
              }
            },
          );
        },
        optionsBuilder: (TextEditingValue textEditingValue) {
          if (textEditingValue.text.isEmpty) {
            return const Iterable<String>.empty();
          }
          return weatherProvider.popularCities.where((city) {
            return city.toLowerCase().contains(textEditingValue.text.toLowerCase());
          });
        },
        onSelected: (String selection) {
          _searchController.clear();
          weatherProvider.fetchWeatherByCity(selection);
        },
        optionsViewBuilder: (context, onSelected, options) {
          return Align(
            alignment: Alignment.topLeft,
            child: Material(
              elevation: 4.0,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                decoration: BoxDecoration(
                  color: Color(0xFF2C5364),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  itemCount: options.length,
                  itemBuilder: (BuildContext context, int index) {
                    final option = options.elementAt(index);
                    return ListTile(
                      leading: Icon(
                        Icons.location_city,
                        color: Colors.white.withOpacity(0.7),
                        size: isSmallScreen ? 20 : 24,
                      ),
                      title: Text(
                        option,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: isSmallScreen ? 14 : 16,
                        ),
                      ),
                      onTap: () {
                        onSelected(option);
                      },
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWeatherCard(bool isSmallScreen, WeatherProvider weatherProvider) {
    final currentWeather = weatherProvider.getCurrentWeather();
    if (currentWeather == null) return SizedBox();

    return Container(
      margin: EdgeInsets.only(bottom: isSmallScreen ? 16 : 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(isSmallScreen ? 20 : 24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.withOpacity(0.15),
            Colors.white.withOpacity(0.05),
          ],
        ),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 20 : 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, // CHANGED: Use min instead of max
          children: [
            // Location and Time
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        weatherProvider.currentLocation.split(',')[0],
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: isSmallScreen ? 22 : 28,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: isSmallScreen ? 2 : 4),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: isSmallScreen ? 14 : 16,
                            color: Colors.white.withOpacity(0.7),
                          ),
                          SizedBox(width: isSmallScreen ? 6 : 8),
                          Expanded(
                            child: Text(
                              weatherProvider.currentLocation,
                              style: GoogleFonts.poppins(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: isSmallScreen ? 12 : 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 12 : 16,
                    vertical: isSmallScreen ? 6 : 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
                  ),
                  child: Text(
                    'Now',
                    style: GoogleFonts.poppins(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: isSmallScreen ? 10 : 12,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: isSmallScreen ? 20 : 30),

            // Temperature
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Flexible( // CHANGED: Use Flexible instead of Expanded
                            child: Text(
                              currentWeather.temperature.toStringAsFixed(0),
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: isSmallScreen ? 60 : 80,
                                fontWeight: FontWeight.w300,
                                height: 0.8,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: isSmallScreen ? 4 : 8),
                            child: Text(
                              '°C',
                              style: GoogleFonts.poppins(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: isSmallScreen ? 20 : 24,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: isSmallScreen ? 4 : 8),
                      Text(
                        currentWeather.condition,
                        style: GoogleFonts.poppins(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: isSmallScreen ? 16 : 20,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Weather Icon
                Container(
                  width: isSmallScreen ? 80 : 120,
                  height: isSmallScreen ? 80 : 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                  ),
                  child: Icon(
                    _getWeatherIcon(currentWeather.icon),
                    size: isSmallScreen ? 40 : 60,
                    color: Colors.white,
                  ),
                ),
              ],
            ),

            SizedBox(height: isSmallScreen ? 20 : 30),

            // Weather Details Grid - ADD HEIGHT CONSTRAINT
            SizedBox( // ADDED: Wrap GridView with SizedBox
              height: isSmallScreen ? 140 : 170, // Adjust based on your design
              child: GridView.count(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: isSmallScreen ? 12 : 20,
                mainAxisSpacing: isSmallScreen ? 12 : 20,
                childAspectRatio: isSmallScreen ? 2.5 : 3,
                children: [
                  _buildWeatherDetail(
                    Icons.thermostat,
                    'Feels Like',
                    '${currentWeather.feelsLike.toStringAsFixed(0)}°C',
                    isSmallScreen,
                  ),
                  _buildWeatherDetail(
                    Icons.air,
                    'Wind',
                    '${currentWeather.windSpeed.toStringAsFixed(0)} km/h',
                    isSmallScreen,
                  ),
                  _buildWeatherDetail(
                    Icons.water_drop,
                    'Humidity',
                    '${currentWeather.humidity.toStringAsFixed(0)}%',
                    isSmallScreen,
                  ),
                  _buildWeatherDetail(
                    Icons.visibility,
                    'Visibility',
                    '${currentWeather.visibility.toStringAsFixed(0)} km',
                    isSmallScreen,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHourlyForecast(bool isSmallScreen, WeatherProvider weatherProvider) {
    final hourlyForecast = weatherProvider.getHourlyForecast();

    return Container(
      height: isSmallScreen ? 140 : 160,
      padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 16 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 16 : 20),
            child: Text(
              'HOURLY FORECAST',
              style: GoogleFonts.poppins(
                color: Colors.white.withOpacity(0.8),
                fontSize: isSmallScreen ? 14 : 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            ),
          ),
          SizedBox(height: isSmallScreen ? 12 : 16),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 16 : 20),
              itemCount: hourlyForecast.length,
              itemBuilder: (context, index) {
                final forecast = hourlyForecast[index];
                final hour = forecast.time.hour;

                return Container(
                  width: isSmallScreen ? 70 : 80,
                  margin: EdgeInsets.only(right: isSmallScreen ? 10 : 12),
                  padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(isSmallScreen ? 14 : 16),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        '${hour}:00',
                        style: GoogleFonts.poppins(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: isSmallScreen ? 10 : 12,
                        ),
                      ),
                      Icon(
                        _getWeatherIcon(forecast.icon),
                        color: Colors.white,
                        size: isSmallScreen ? 18 : 22,
                      ),
                      Text(
                        '${forecast.temperature.toStringAsFixed(0)}°',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: isSmallScreen ? 14 : 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyForecastItem(int index, bool isSmallScreen, WeatherProvider weatherProvider) {
    final dailyForecast = weatherProvider.getDailyForecast();
    if (index >= dailyForecast.length) return SizedBox();

    final forecast = dailyForecast[index];

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 16 : 20,
        vertical: isSmallScreen ? 6 : 8,
      ),
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(isSmallScreen ? 14 : 16),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              forecast.day,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: isSmallScreen ? 14 : 16,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            child: Icon(
              _getWeatherIcon(forecast.icon),
              color: Colors.white,
              size: isSmallScreen ? 20 : 24,
            ),
          ),
          Expanded(
            child: Text(
              '${forecast.precipitation.toStringAsFixed(0)}%',
              style: GoogleFonts.poppins(
                color: Colors.white.withOpacity(0.8),
                fontSize: isSmallScreen ? 12 : 14,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  '${forecast.maxTemp.toStringAsFixed(0)}°',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: isSmallScreen ? 14 : 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: isSmallScreen ? 12 : 16),
                Text(
                  '${forecast.minTemp.toStringAsFixed(0)}°',
                  style: GoogleFonts.poppins(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: isSmallScreen ? 14 : 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCityCard(int index, bool isSmallScreen, WeatherProvider weatherProvider) {
    final city = weatherProvider.popularCities[index];
    final cityParts = city.split(',');
    final cityName = cityParts[0];
    final country = cityParts.length > 1 ? cityParts[1] : '';

    return InkWell(
      onTap: () {
        weatherProvider.fetchWeatherByCity(city);
      },
      borderRadius: BorderRadius.circular(isSmallScreen ? 14 : 16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(isSmallScreen ? 14 : 16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _getCityColor(index).withOpacity(0.3),
              _getCityColor(index).withOpacity(0.1),
            ],
          ),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              right: isSmallScreen ? 8 : 12,
              top: isSmallScreen ? 8 : 12,
              child: Container(
                width: isSmallScreen ? 32 : 40,
                height: isSmallScreen ? 32 : 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.1),
                ),
                child: Icon(
                  Icons.add,
                  color: Colors.white.withOpacity(0.7),
                  size: isSmallScreen ? 16 : 20,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cityName,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: isSmallScreen ? 16 : 18,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: isSmallScreen ? 2 : 4),
                      if (country.isNotEmpty)
                        Text(
                          country,
                          style: GoogleFonts.poppins(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: isSmallScreen ? 12 : 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                  Text(
                    '${20 + (index % 10)}°C',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: isSmallScreen ? 20 : 24,
                      fontWeight: FontWeight.w300,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingCard(bool isSmallScreen) {
    return Container(
      height: isSmallScreen ? 320 : 400,
      margin: EdgeInsets.only(bottom: isSmallScreen ? 16 : 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(isSmallScreen ? 20 : 24),
        color: Colors.white.withOpacity(0.05),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            SizedBox(height: 16),
            Text(
              'Loading weather...',
              style: GoogleFonts.poppins(
                color: Colors.white.withOpacity(0.8),
                fontSize: isSmallScreen ? 14 : 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoDataCard(bool isSmallScreen) {
    return Container(
      height: isSmallScreen ? 320 : 400,
      margin: EdgeInsets.only(bottom: isSmallScreen ? 16 : 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(isSmallScreen ? 20 : 24),
        color: Colors.white.withOpacity(0.05),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_off,
              color: Colors.white.withOpacity(0.5),
              size: isSmallScreen ? 60 : 80,
            ),
            SizedBox(height: 16),
            Text(
              'No weather data',
              style: GoogleFonts.poppins(
                color: Colors.white.withOpacity(0.8),
                fontSize: isSmallScreen ? 16 : 20,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Search for a city or use your location',
              style: GoogleFonts.poppins(
                color: Colors.white.withOpacity(0.6),
                fontSize: isSmallScreen ? 12 : 14,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final weatherProvider = Provider.of<WeatherProvider>(context, listen: false);
                weatherProvider.fetchWeatherByLocation();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.1),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: Colors.white.withOpacity(0.3)),
                ),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.my_location, size: isSmallScreen ? 18 : 20),
                  SizedBox(width: 8),
                  Text(
                    'Use Current Location',
                    style: GoogleFonts.poppins(
                      fontSize: isSmallScreen ? 14 : 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherDetail(IconData icon, String label, String value, bool isSmallScreen) {
    return Row(
      children: [
        Container(
          width: isSmallScreen ? 32 : 40,
          height: isSmallScreen ? 32 : 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.1),
          ),
          child: Icon(
            icon,
            size: isSmallScreen ? 16 : 20,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
        SizedBox(width: isSmallScreen ? 8 : 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: isSmallScreen ? 10 : 12,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: isSmallScreen ? 1 : 2),
              Text(
                value,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: isSmallScreen ? 14 : 16,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  BottomNavigationBar _buildBottomNavigationBar(bool isSmallScreen) {
    return BottomNavigationBar(
      backgroundColor: Colors.blueGrey,
      elevation: 0,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white.withOpacity(0.5),
      selectedLabelStyle: GoogleFonts.poppins(
        fontSize: isSmallScreen ? 10 : 12,
      ),
      unselectedLabelStyle: GoogleFonts.poppins(
        fontSize: isSmallScreen ? 10 : 12,
      ),
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home, size: isSmallScreen ? 22 : 24),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.map, size: isSmallScreen ? 22 : 24),
          label: 'Map',
        ),
        BottomNavigationBarItem(
          icon: Container(
            width: isSmallScreen ? 30 : 40,
          ),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications, size: isSmallScreen ? 22 : 24),
          label: 'Alerts',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person, size: isSmallScreen ? 22 : 24),
          label: 'Profile',
        ),
      ],
      currentIndex: 0,
      onTap: (index) {
        // Handle navigation
        print('Navigation index: $index');
      },
    );
  }

  Widget _buildDetailedWeatherView(WeatherProvider weatherProvider) {
    final currentWeather = weatherProvider.getCurrentWeather();
    final dailyForecast = weatherProvider.getDailyForecast();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Detailed Forecast',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
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
        child: ListView(
          padding: EdgeInsets.all(20),
          children: [
            // Current Weather Summary
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white.withOpacity(0.1),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Weather',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 16),
                  if (currentWeather != null)
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Temperature',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  '${currentWeather.temperature.toStringAsFixed(1)}°C',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.1),
                              ),
                              child: Icon(
                                _getWeatherIcon(currentWeather.icon),
                                color: Colors.white,
                                size: 40,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        GridView.count(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          childAspectRatio: 3,
                          crossAxisSpacing: 20,
                          mainAxisSpacing: 20,
                          children: [
                            _buildDetailItem('Feels Like', '${currentWeather.feelsLike.toStringAsFixed(1)}°C'),
                            _buildDetailItem('Humidity', '${currentWeather.humidity.toStringAsFixed(0)}%'),
                            _buildDetailItem('Wind Speed', '${currentWeather.windSpeed.toStringAsFixed(1)} km/h'),
                            _buildDetailItem('Pressure', '${currentWeather.pressure.toStringAsFixed(0)} hPa'),
                            _buildDetailItem('Visibility', '${currentWeather.visibility.toStringAsFixed(1)} km'),
                            _buildDetailItem('Condition', currentWeather.condition),
                          ],
                        ),
                      ],
                    ),
                ],
              ),
            ),

            SizedBox(height: 20),

            // 7-Day Forecast
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white.withOpacity(0.1),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '7-Day Forecast',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 16),
                  ...dailyForecast.map((forecast) => Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            forecast.day,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Icon(
                            _getWeatherIcon(forecast.icon),
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            '${forecast.precipitation.toStringAsFixed(0)}%',
                            style: GoogleFonts.poppins(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                '${forecast.maxTemp.toStringAsFixed(0)}°',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(width: 12),
                              Text(
                                '${forecast.minTemp.toStringAsFixed(0)}°',
                                style: GoogleFonts.poppins(
                                  color: Colors.white.withOpacity(0.6),
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )).toList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            color: Colors.white.withOpacity(0.7),
            fontSize: 12,
          ),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  IconData _getWeatherIcon(String iconCode) {
    switch (iconCode) {
      case '01d': return Icons.wb_sunny;
      case '01n': return Icons.nightlight_round;
      case '02d': return Icons.wb_cloudy;
      case '02n': return Icons.nightlight_round;
      case '03d':
      case '03n': return Icons.cloud;
      case '04d':
      case '04n': return Icons.cloud;
      case '09d':
      case '09n': return Icons.beach_access;
      case '10d':
      case '10n': return Icons.grain;
      case '11d':
      case '11n': return Icons.flash_on;
      case '13d':
      case '13n': return Icons.ac_unit;
      case '50d':
      case '50n': return Icons.blur_on;
      default: return Icons.wb_sunny;
    }
  }

  Color _getCityColor(int index) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
      Colors.amber,
      Colors.cyan,
      Colors.deepOrange,
    ];
    return colors[index % colors.length];
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}

// SliverPersistentHeader Delegate Class
class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final Widget child;

  _StickyHeaderDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  @override
  Widget build(
      BuildContext context,
      double shrinkOffset,
      bool overlapsContent,
      ) {
    return SizedBox.expand(child: child);
  }

  @override
  double get maxExtent => maxHeight;

  @override
  double get minExtent => minHeight;

  @override
  bool shouldRebuild(_StickyHeaderDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}