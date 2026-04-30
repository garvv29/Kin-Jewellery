import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'main_navigation_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _fadeController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  bool _showSkeleton = true;

  @override
  void initState() {
    super.initState();
    _showSkeleton = false;
    _setupAnimations();
    _navigateToNextScreen();
  }

  void _setupAnimations() {
    // Scale animation for logo
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    // Fade animation for text
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );

    _scaleController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _fadeController.forward();
    });
  }

  void _navigateToNextScreen() async {
    await Future.delayed(const Duration(seconds: 2));

    // Always go to main navigation screen
    // Users can browse home without login
    // Login is required only for specific actions
    if (mounted) {
      Get.offAll(() => const MainNavigationScreen());
    }
  }

  @override
  void dispose() {
    if (!_showSkeleton) {
      _scaleController.dispose();
      _fadeController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_showSkeleton) {
      return _buildSkeletonScreen();
    }
    
    return _buildSplashScreen();
  }

  Widget _buildSkeletonScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F1E8),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFF5F1E8),
              const Color(0xFFFCF8F3),
            ],
          ),
        ),
        child: Stack(
          // children: [
          //   // Ring image background - right side with low opacity
          //   Positioned(
          //     right: 150,
          //     top: 50,
          //     bottom: 50,
          //     child: Opacity(
          //       opacity: 0.12,
          //       child: Transform.scale(
          //         scale: 0.8,
          //         child: Image.asset(
          //           'assets/images/ring.png',
          //           fit: BoxFit.cover,
          //           errorBuilder: (context, error, stackTrace) {
          //             return Container(
          //               color: const Color(0xFFD4AF37).withOpacity(0.1),
          //               child: const Center(
          //                 child: Icon(
          //                   Icons.diamond,
          //                   size: 100,
          //                   color: Color(0xFFD4AF37),
          //                 ),
          //               ),
          //             );
          //           },
          //         ),
          //       ),
          //     ),
          //   ),
          //   // Skeleton Content
          //   // SafeArea(
          //   //   child: Column(
          //   //     mainAxisAlignment: MainAxisAlignment.center,
          //   //     children: [
          //   //       const SizedBox(height: 40),
          //   //       // Skeleton icon circle
          //   //       _buildSkeletonShimmer(
          //   //         child: Container(
          //   //           height: 160,
          //   //           width: 160,
          //   //           decoration: BoxDecoration(
          //   //             shape: BoxShape.circle,
          //   //             color: Colors.grey[300],
          //   //           ),
          //   //         ),
          //   //       ),
          //   //       const SizedBox(height: 50),
          //   //       // Skeleton text lines
          //   //       Column(
          //   //         children: [
          //   //           _buildSkeletonShimmer(
          //   //             child: Container(
          //   //               height: 60,
          //   //               width: 150,
          //   //               decoration: BoxDecoration(
          //   //                 borderRadius: BorderRadius.circular(8),
          //   //                 color: Colors.grey[300],
          //   //               ),
          //   //             ),
          //   //           ),
          //   //           const SizedBox(height: 16),
          //   //           _buildSkeletonShimmer(
          //   //             child: Container(
          //   //               height: 12,
          //   //               width: 100,
          //   //               decoration: BoxDecoration(
          //   //                 borderRadius: BorderRadius.circular(6),
          //   //                 color: Colors.grey[300],
          //   //               ),
          //   //             ),
          //   //           ),
          //   //           const SizedBox(height: 24),
          //   //           _buildSkeletonShimmer(
          //   //             child: Container(
          //   //               height: 12,
          //   //               width: 120,
          //   //               decoration: BoxDecoration(
          //   //                 borderRadius: BorderRadius.circular(6),
          //   //                 color: Colors.grey[300],
          //   //               ),
          //   //             ),
          //   //           ),
          //   //         ],
          //   //       ),
          //   //       const Spacer(),
          //   //       // Skeleton loading animation
          //   //       _buildSkeletonShimmer(
          //   //         child: Row(
          //   //           mainAxisAlignment: MainAxisAlignment.center,
          //   //           children: List.generate(
          //   //             3,
          //   //             (index) => Padding(
          //   //               padding: const EdgeInsets.symmetric(horizontal: 7),
          //   //               child: Container(
          //   //                 width: 8,
          //   //                 height: 8,
          //   //                 decoration: BoxDecoration(
          //   //                   shape: BoxShape.circle,
          //   //                   color: Colors.grey[300],
          //   //                 ),
          //   //               ),
          //   //             ),
          //   //           ),
          //   //         ),
          //   //       ),
          //   //       const SizedBox(height: 20),
          //   //       _buildSkeletonShimmer(
          //   //         child: Container(
          //   //           height: 12,
          //   //           width: 60,
          //   //           decoration: BoxDecoration(
          //   //             borderRadius: BorderRadius.circular(6),
          //   //             color: Colors.grey[300],
          //   //           ),
          //   //         ),
          //   //       ),
          //   //       const SizedBox(height: 60),
          //   //     ],
          //   //   ),
          //   // ),
          // ],
        ),
      ),
    );
  }

  // Widget _buildSkeletonShimmer({required Widget child}) {
  //   return ShaderMask(
  //     shaderCallback: (bounds) {
  //       return LinearGradient(
  //         begin: Alignment.centerLeft,
  //         end: Alignment.centerRight,
  //         stops: const [0.0, 0.5, 1.0],
  //         colors: [
  //           Colors.grey[300]!,
  //           Colors.grey[100]!,
  //           Colors.grey[300]!,
  //         ],
  //         tileMode: TileMode.mirror,
  //       ).createShader(bounds);
  //     },
  //     child: child,
  //   );
  // }

  Widget _buildSplashScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F1E8),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFF5F1E8),
              const Color(0xFFFCF8F3),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Ring image background - right side with low opacity
            Positioned(
              right: -160,
              top: 80,
              bottom: 20,
              child: Opacity(
                opacity: 0.22,
                child: Transform.scale(
                  scale: 1.0,
                  child: Image.asset(
                    'assets/images/ring.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: const Color(0xFFD4AF37).withOpacity(0.1),
                        child: const Center(
                          child: Icon(
                            Icons.diamond,
                            size: 100,
                            color: Color(0xFFD4AF37),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            // Main content
            SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
              // Premium decorative line
              // Padding(
              //   padding: const EdgeInsets.symmetric(horizontal: 80),
              //   child: Container(
              //     height: 2,
              //     decoration: BoxDecoration(
              //       gradient: LinearGradient(
              //         colors: [
              //           Colors.transparent,
              //           const Color(0xFFD4AF37),
              //           Colors.transparent,
              //         ],
              //       ),
              //     ),
              //   ),
              // ),
              const SizedBox(height: 40),

              // Animated Jewellery Icon
              ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  height: 160,
                  width: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFFD4AF37),
                        const Color(0xFFFBD89B),
                        const Color(0xFFD4AF37),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFD4AF37).withOpacity(0.5),
                        blurRadius: 40,
                        spreadRadius: 5,
                      ),
                      BoxShadow(
                        color: const Color(0xFFD4AF37).withOpacity(0.2),
                        blurRadius: 60,
                        spreadRadius: 15,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.diamond,
                    size: 85,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 50),

              // Animated Title and Tagline
              FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    // App Logo/Name with premium styling
                    Text(
                      'Kin',
                      style: GoogleFonts.bodoniModa(
                        fontSize: 72,
                        fontWeight: FontWeight.w300,
                        color: const Color(0xFF1A1A1A),
                        letterSpacing: 8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Decorative dots
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFD4AF37),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFD4AF37),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFD4AF37),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'JEWELLERY',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFFD4AF37),
                        letterSpacing: 3,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // const Padding(
                    //   padding: EdgeInsets.symmetric(horizontal: 40),
                    //   child: Text(
                    //     'Timeless Elegance',
                    //     textAlign: TextAlign.center,
                    //     style: TextStyle(
                    //       fontSize: 16,
                    //       color: Color(0xFF666666),
                    //       letterSpacing: 1.5,
                    //       fontWeight: FontWeight.w400,
                    //     ),
                    //   ),
                    // ),
                    // const SizedBox(height: 12),
                    // const Padding(
                    //   padding: EdgeInsets.symmetric(horizontal: 40),
                    //   child: Text(
                    //     'Discover our premium collection of exquisite jewellery crafted for every moment',
                    //     textAlign: TextAlign.center,
                    //     style: TextStyle(
                    //       fontSize: 12,
                    //       color: Color(0xFF999999),
                    //       letterSpacing: 0.3,
                    //       height: 1.6,
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ),

              const Spacer(),

              // Loading animation at bottom
              Padding(
                padding: const EdgeInsets.only(bottom: 60),
                child: Column(
                  children: [
                    // Animated loading dots
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        3,
                        (index) => ScaleTransition(
                          scale: Tween<double>(begin: 0.7, end: 1.1).animate(
                            CurvedAnimation(
                              parent: _scaleController,
                              curve: Interval(
                                index * 0.15,
                                (index * 0.15) + 0.6,
                                curve: Curves.easeInOut,
                              ),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 7),
                            child: Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFFD4AF37),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Loading',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFFD4AF37),
                        letterSpacing: 1,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
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
}
