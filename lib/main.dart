import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(PortfolioApp());
}

class PortfolioApp extends StatelessWidget {
  PortfolioApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sidharth Biju - Portfolio',
      theme: ThemeData(
        brightness: Brightness.dark,
        textTheme: GoogleFonts.tomorrowTextTheme(ThemeData.dark().textTheme),
      ),
      home: PortfolioPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class PortfolioPage extends StatefulWidget {
  PortfolioPage({Key? key}) : super(key: key);

  @override
  State<PortfolioPage> createState() => _PortfolioPageState();
}

class _PortfolioPageState extends State<PortfolioPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final ScrollController _scrollController = ScrollController();

  bool _isAboutVisible = false;
  bool _isProjectsVisible = false;
  bool _isContactsVisible = false;
  bool _isMenuOpen = false;

  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _msgCtrl = TextEditingController();

  static Color _accentColor = Color(0xFFF86E5B);
  static Color _secondaryAccent = Color(0xFF924136);
  static Duration _fastDuration = Duration(milliseconds: 300);
  static Duration _mediumDuration = Duration(milliseconds: 500);
  static Curve _defaultCurve = Curves.easeOut;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _scrollController.addListener(_handleScroll);
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      vsync: this,
      duration: _mediumDuration,
    );

    _slideController = AnimationController(
      vsync: this,
      duration: _mediumDuration,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: _defaultCurve,
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(-0.1, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _slideController,
        curve: _defaultCurve,
      ),
    );

    _fadeController.forward();
    _slideController.forward();
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position.pixels;
    final maxScroll = _scrollController.position.maxScrollExtent;

    if (maxScroll <= 0) return;

    final aboutVisible = position > maxScroll * 0.2;
    final projectsVisible = position > maxScroll * 0.5;
    final contactsVisible = position > maxScroll * 0.75;

    if (aboutVisible != _isAboutVisible ||
        projectsVisible != _isProjectsVisible ||
        contactsVisible != _isContactsVisible) {
      setState(() {
        _isAboutVisible = aboutVisible;
        _isProjectsVisible = projectsVisible;
        _isContactsVisible = contactsVisible;
      });
    }
  }

  void _submitForm() {
    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final message = _msgCtrl.text.trim();

    if (name.isEmpty) {
      _showSnackBar('Please enter your name', isError: true);
      return;
    }

    if (email.isEmpty) {
      _showSnackBar('Please enter your email', isError: true);
      return;
    }

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      _showSnackBar('Please enter a valid email address', isError: true);
      return;
    }

    if (message.isEmpty) {
      _showSnackBar('Please enter your message', isError: true);
      return;
    }

    _showSnackBar(
      'Message sent successfully! I\'ll get back to you soon.',
      isError: false,
    );

    _nameCtrl.clear();
    _emailCtrl.clear();
    _msgCtrl.clear();
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: isError ? Colors.red.shade700 : _accentColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: EdgeInsets.all(20),
        duration: Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Close',
          textColor: Colors.white,
          onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
        ),
      ),
    );
  }

  void _scrollToFraction(double fraction) {
    if (!_scrollController.hasClients) return;
    final max = _scrollController.position.maxScrollExtent;
    _scrollController.animateTo(
      (max * fraction).clamp(0.0, max),
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
    setState(() => _isMenuOpen = false);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scrollController.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _msgCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isMobile = screenWidth < 768;
    final isLandscape = screenWidth > screenHeight && isMobile;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/KX3.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          controller: _scrollController,
          physics: BouncingScrollPhysics(),
          child: Column(
            children: [
              _buildHeader(isMobile, screenWidth),
              _buildHeroSection(isMobile, isLandscape, screenWidth, screenHeight),
              _buildSkillsSection(isMobile, isLandscape, screenWidth),
              _buildAboutSection(isMobile, isLandscape, screenWidth),
              _buildProjectsSection(isMobile, isLandscape, screenWidth),
              _buildContactSection(isMobile, isLandscape, screenWidth),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isMobile, double screenWidth) {
    return RepaintBoundary(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? screenWidth * 0.04 : 80,
            vertical: isMobile ? 16 : 30,
          ),
          child: isMobile
              ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Sidharth Biju',
                    style: TextStyle(
                      fontSize: screenWidth * 0.06,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _isMenuOpen ? Icons.close : Icons.menu,
                      color: Colors.white,
                      size: screenWidth * 0.07,
                    ),
                    onPressed: () {
                      setState(() => _isMenuOpen = !_isMenuOpen);
                    },
                  ),
                ],
              ),
              if (_isMenuOpen) _buildMobileMenu(),
            ],
          )
              : Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Sidharth Biju',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Row(
                children: [
                  _NavButton('Home', () => _scrollToFraction(0)),
                  SizedBox(width: 50),
                  _NavButton('About', () => _scrollToFraction(0.37)),
                  SizedBox(width: 50),
                  _NavButton('Projects', () => _scrollToFraction(0.69)),
                  SizedBox(width: 50),
                  _NavButton('Contacts', () => _scrollToFraction(1.0)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileMenu() {
    return Container(
      color: Colors.black.withOpacity(0.95),
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _MobileNavButton('Home', () => _scrollToFraction(0)),
          SizedBox(height: 20),
          _MobileNavButton('About', () => _scrollToFraction(0.35)),
          SizedBox(height: 20),
          _MobileNavButton('Projects', () => _scrollToFraction(0.66)),
          SizedBox(height: 20),
          _MobileNavButton('Contacts', () => _scrollToFraction(1.0)),
        ],
      ),
    );
  }

  Widget _buildHeroSection(bool isMobile, bool isLandscape, double screenWidth, double screenHeight) {
    return RepaintBoundary(
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? screenWidth * 0.04 : 80,
          vertical: isMobile ? (isLandscape ? 20 : 40) : 60,
        ),
        child: isMobile
            ? isLandscape
            ? Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: _HeroContent(
                    onProjectTap: () => _scrollToFraction(1.0),
                    isMobile: true,
                    isLandscape: true,
                    screenWidth: screenWidth,
                  ),
                ),
              ),
            ),
            SizedBox(width: 20),
            Expanded(
              flex: 2,
              child: _HeroImage(
                fadeAnimation: _fadeAnimation,
                isMobile: true,
                isLandscape: true,
                screenWidth: screenWidth,
              ),
            ),
          ],
        )
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: _HeroContent(
                  onProjectTap: () => _scrollToFraction(1.0),
                  isMobile: true,
                  isLandscape: false,
                  screenWidth: screenWidth,
                ),
              ),
            ),
            SizedBox(height: 30),
            _HeroImage(
              fadeAnimation: _fadeAnimation,
              isMobile: true,
              isLandscape: false,
              screenWidth: screenWidth,
            ),
          ],
        )
            : Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 5,
              child: SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: _HeroContent(
                    onProjectTap: () => _scrollToFraction(1.0),
                    isMobile: false,
                    isLandscape: false,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 4,
              child: _HeroImage(
                fadeAnimation: _fadeAnimation,
                isMobile: false,
                isLandscape: false,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillsSection(bool isMobile, bool isLandscape, double screenWidth) {
    return RepaintBoundary(
      child: Container(
        color: Colors.black.withOpacity(0.7),
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? screenWidth * 0.04 : 80,
          vertical: isMobile ? (isLandscape ? 15 : 20) : 40,
        ),
        child: isMobile
            ? Wrap(
          spacing: isLandscape ? 12 : 20,
          runSpacing: isLandscape ? 12 : 20,
          alignment: WrapAlignment.center,
          children: [
            _SkillChip('Flutter', 0, screenWidth: screenWidth, isMobile: true, isLandscape: isLandscape),
            _SkillChip('UI / UX', 50, screenWidth: screenWidth, isMobile: true, isLandscape: isLandscape),
            _SkillChip('C++', 100, screenWidth: screenWidth, isMobile: true, isLandscape: isLandscape),
            _SkillChip('Git', 150, screenWidth: screenWidth, isMobile: true, isLandscape: isLandscape),
            _SkillChip('Github', 200, screenWidth: screenWidth, isMobile: true, isLandscape: isLandscape),
          ],
        )
            : Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _SkillChip('Flutter', 0, isMobile: false),
            _SkillChip('UI / UX', 50, isMobile: false),
            _SkillChip('C++', 100, isMobile: false),
            _SkillChip('Git', 150, isMobile: false),
            _SkillChip('Github', 200, isMobile: false),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutSection(bool isMobile, bool isLandscape, double screenWidth) {
    return RepaintBoundary(
      child: AnimatedOpacity(
        duration: _mediumDuration,
        opacity: _isAboutVisible ? 1.0 : 0.0,
        curve: _defaultCurve,
        child: AnimatedContainer(
          duration: _mediumDuration,
          curve: _defaultCurve,
          transform: Matrix4.translationValues(0, _isAboutVisible ? 0 : 20, 0),
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? screenWidth * 0.04 : 80,
            vertical: isMobile ? (isLandscape ? 25 : 40) : 100,
          ),
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/KX7.jpg"),
              fit: BoxFit.cover,
            ),
          ),
          child: _AboutContent(
            isVisible: _isAboutVisible,
            isMobile: isMobile,
            isLandscape: isLandscape,
            screenWidth: screenWidth,
          ),
        ),
      ),
    );
  }

  Widget _buildProjectsSection(bool isMobile, bool isLandscape, double screenWidth) {
    return RepaintBoundary(
      child: AnimatedOpacity(
        duration: _mediumDuration,
        opacity: _isProjectsVisible ? 1.0 : 0.0,
        curve: _defaultCurve,
        child: AnimatedContainer(
          duration: _mediumDuration,
          curve: _defaultCurve,
          transform: Matrix4.translationValues(0, _isProjectsVisible ? 0 : 20, 0),
          child: _ProjectsContent(
            isVisible: _isProjectsVisible,
            isMobile: isMobile,
            isLandscape: isLandscape,
            screenWidth: screenWidth,
          ),
        ),
      ),
    );
  }

  Widget _buildContactSection(bool isMobile, bool isLandscape, double screenWidth) {
    return RepaintBoundary(
      child: AnimatedOpacity(
        duration: _mediumDuration,
        opacity: _isContactsVisible ? 1.0 : 0.0,
        curve: _defaultCurve,
        child: AnimatedContainer(
          duration: _mediumDuration,
          curve: _defaultCurve,
          transform: Matrix4.translationValues(0, _isContactsVisible ? 0 : 20, 0),
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/KX41.jpeg"),
              fit: BoxFit.cover,
            ),
          ),
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            vertical: isMobile ? (isLandscape ? 25 : 40) : 90,
            horizontal: isMobile ? screenWidth * 0.04 : 80,
          ),
          child: _ContactContent(
            nameCtrl: _nameCtrl,
            emailCtrl: _emailCtrl,
            msgCtrl: _msgCtrl,
            onSubmit: _submitForm,
            isMobile: isMobile,
            isLandscape: isLandscape,
            screenWidth: screenWidth,
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  _NavButton(this.text, this.onTap);

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 18,
              color: Colors.white70,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}

class _MobileNavButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  _MobileNavButton(this.text, this.onTap);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 24,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _HeroContent extends StatelessWidget {
  final VoidCallback onProjectTap;
  final bool isMobile;
  final bool isLandscape;
  final double? screenWidth;

  _HeroContent({
    required this.onProjectTap,
    required this.isMobile,
    required this.isLandscape,
    this.screenWidth,
  });

  @override
  Widget build(BuildContext context) {
    final actualScreenWidth = screenWidth ?? MediaQuery.of(context).size.width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Hello',
              style: TextStyle(
                fontSize: isMobile
                    ? (isLandscape ? actualScreenWidth * 0.06 : actualScreenWidth * 0.1)
                    : 72,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            TweenAnimationBuilder<double>(
              duration: Duration(milliseconds: 500),
              tween: Tween(begin: 0.0, end: 1.0),
              curve: Curves.elasticOut,
              builder: (context, value, child) => Transform.scale(
                scale: value,
                child: child,
              ),
              child: Text(
                '.',
                style: TextStyle(
                  fontSize: isMobile
                      ? (isLandscape ? actualScreenWidth * 0.06 : actualScreenWidth * 0.1)
                      : 72,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFF86E5B),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: isLandscape ? 4 : 10),
        _AnimatedLine(width: isMobile ? (isLandscape ? actualScreenWidth * 0.2 : actualScreenWidth * 0.35) : 230),
        SizedBox(height: isMobile ? (isLandscape ? 8 : 15) : 30),
        Text(
          "I'm Sidharth",
          style: TextStyle(
            fontSize: isMobile
                ? (isLandscape ? actualScreenWidth * 0.035 : actualScreenWidth * 0.06)
                : 42,
            fontWeight: FontWeight.w300,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
        SizedBox(height: isLandscape ? 2 : 5),
        Text(
          'Flutter Developer',
          style: TextStyle(
            fontSize: isMobile
                ? (isLandscape ? actualScreenWidth * 0.045 : actualScreenWidth * 0.075)
                : 68,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            height: 1.1,
          ),
        ),
        SizedBox(height: isMobile ? (isLandscape ? 12 : 20) : 40),
        isMobile
            ? isLandscape
            ? Row(
          children: [
            Expanded(
              child: _GradientButton(
                text: 'Got A Project ?',
                onPressed: onProjectTap,
                filled: true,
                isMobile: true,
                isLandscape: true,
                screenWidth: actualScreenWidth,
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: _GradientButton(
                text: 'My Resume',
                onPressed: () {},
                filled: false,
                isMobile: true,
                isLandscape: true,
                screenWidth: actualScreenWidth,
              ),
            ),
          ],
        )
            : Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _GradientButton(
              text: 'Got A Project ?',
              onPressed: onProjectTap,
              filled: true,
              isMobile: true,
              isLandscape: false,
              screenWidth: actualScreenWidth,
            ),
            SizedBox(height: 12),
            _GradientButton(
              text: 'My Resume',
              onPressed: () {},
              filled: false,
              isMobile: true,
              isLandscape: false,
              screenWidth: actualScreenWidth,
            ),
          ],
        )
            : Row(
          children: [
            _GradientButton(
              text: 'Got A Project ?',
              onPressed: onProjectTap,
              filled: true,
              isMobile: false,
            ),
            SizedBox(width: 30),
            _GradientButton(
              text: 'My Resume',
              onPressed: () {},
              filled: false,
              isMobile: false,
            ),
          ],
        ),
        SizedBox(height: isMobile ? (isLandscape ? 15 : 25) : 60),
        _AvailabilityIndicator(isLandscape: isLandscape),
      ],
    );
  }
}

class _AnimatedLine extends StatelessWidget {
  final double width;

  _AnimatedLine({required this.width});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 500),
      tween: Tween(begin: 0.0, end: width),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Container(
          width: value,
          height: 3,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFF86E5B),
                Color(0xFF924136),
                Color(0xFF924136).withOpacity(0),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool filled;
  final bool isMobile;
  final bool isLandscape;
  final double? screenWidth;

  _GradientButton({
    required this.text,
    required this.onPressed,
    required this.filled,
    required this.isMobile,
    this.isLandscape = false,
    this.screenWidth,
  });

  static const gradient = LinearGradient(
    colors: [Color(0xFFF86E5B), Color(0xFF924136)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  @override
  Widget build(BuildContext context) {
    final actualScreenWidth = screenWidth ?? MediaQuery.of(context).size.width;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? (isLandscape ? actualScreenWidth * 0.03 : actualScreenWidth * 0.06) : 40,
            vertical: isMobile ? (isLandscape ? 10 : 14) : 20,
          ),
          decoration: BoxDecoration(
            gradient: filled ? gradient : null,
            color: filled ? null : Color(0xFF1a2332),
            borderRadius: BorderRadius.circular(6),
            boxShadow: filled
                ? [
              BoxShadow(
                color: Color(0xFFF86E5B).withOpacity(0.3),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ]
                : null,
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                fontSize: isMobile ? (isLandscape ? actualScreenWidth * 0.028 : actualScreenWidth * 0.035) : 16,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

class _AvailabilityIndicator extends StatelessWidget {
  final bool isLandscape;

  _AvailabilityIndicator({this.isLandscape = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 1000),
          tween: Tween(begin: 0.0, end: 1.0),
          curve: Curves.easeInOut,
          builder: (context, value, child) {
            return Container(
              width: isLandscape ? 8 : 10,
              height: isLandscape ? 8 : 10,
              decoration: BoxDecoration(
                color: Color.lerp(
                  Colors.transparent,
                  Color(0xFFF86E5B),
                  value,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFFF86E5B).withOpacity(value * 0.6),
                    blurRadius: 6,
                    spreadRadius: 1,
                  ),
                ],
              ),
            );
          },
        ),
        SizedBox(width: isLandscape ? 6 : 10),
        Text(
          'Available For Work',
          style: TextStyle(
            fontSize: isLandscape ? 14 : 16,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }
}

class _HeroImage extends StatelessWidget {
  final Animation<double> fadeAnimation;
  final bool isMobile;
  final bool isLandscape;
  final double? screenWidth;

  _HeroImage({
    required this.fadeAnimation,
    required this.isMobile,
    required this.isLandscape,
    this.screenWidth,
  });

  @override
  Widget build(BuildContext context) {
    final actualScreenWidth = screenWidth ?? MediaQuery.of(context).size.width;

    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 600),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(20 * (1 - value), 0),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Align(
        alignment: Alignment.center,
        child: Container(
          width: isMobile
              ? (isLandscape ? actualScreenWidth * 0.35 : actualScreenWidth * 0.7)
              : 450,
          height: isMobile
              ? (isLandscape ? 180 : actualScreenWidth * 0.7 * 0.75)
              : 550,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            image: DecorationImage(
              image: AssetImage("assets/images/Prof.jpeg"),
              fit: BoxFit.cover,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 15,
                offset: Offset(0, 8),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SkillChip extends StatelessWidget {
  final String text;
  final int delay;
  final double? screenWidth;
  final bool isMobile;
  final bool isLandscape;

  const _SkillChip(
      this.text,
      this.delay, {
        this.screenWidth,
        this.isMobile = true,
        this.isLandscape = false,
      });

  @override
  Widget build(BuildContext context) {
    final actualScreenWidth = screenWidth ?? MediaQuery.of(context).size.width;

    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300 + delay),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Padding(
            padding: EdgeInsets.all(4),
            child: Text(
              text,
              style: TextStyle(
                fontSize: isMobile
                    ? (isLandscape ? actualScreenWidth * 0.03 : actualScreenWidth * 0.04)
                    : 16,
                color: Colors.white70,
                fontWeight: FontWeight.w300,
                letterSpacing: 0.5,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _AboutContent extends StatelessWidget {
  final bool isVisible;
  final bool isMobile;
  final bool isLandscape;
  final double? screenWidth;

  _AboutContent({
    required this.isVisible,
    required this.isMobile,
    required this.isLandscape,
    this.screenWidth,
  });

  final List<String> techItems = [
    "Dart",
    "Flutter",
    "Provider",
    "GetX",
    "BLoC",
    "Riverpod",
    "sqflite",
    "Hive",
    "Figma",
    "Cursor",
    "Firebase",
    "REST API",
    "Git / GitHub",
    "Dependency Injection",
    "Payment Integration",
    "MVVM",
    "Responsive Design",
  ];

  @override
  Widget build(BuildContext context) {
    final actualScreenWidth = screenWidth ?? MediaQuery.of(context).size.width;

    if (isMobile && isLandscape) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'About',
                style: TextStyle(
                  fontSize: actualScreenWidth * 0.05,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 6),
              Text(
                'Me',
                style: TextStyle(
                  fontSize: actualScreenWidth * 0.05,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFF86E5B),
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          _AnimatedLine(width: actualScreenWidth * 0.15),
          SizedBox(height: 15),
          Text(
            'I am a multidisciplinary creative technologist specializing in Cross-Platform Mobile Development and User Interface Design. With a strong foundation in Flutter and expert proficiency in Figma, I help startups and businesses transform abstract ideas into deployable, high-performance products.',
            style: TextStyle(
              fontSize: actualScreenWidth * 0.025,
              color: Colors.white.withOpacity(0.8),
              height: 1.5,
              letterSpacing: 0.2,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'My journey in mobile development has equipped me with a strong foundation in UI/UX principles, state management, and modern development practices. I constantly strive to learn new technologies and improve my craft.',
            style: TextStyle(
              fontSize: actualScreenWidth * 0.025,
              color: Colors.white.withOpacity(0.8),
              height: 1.5,
              letterSpacing: 0.2,
            ),
          ),
          SizedBox(height: 20),
          // Tech Stack Section
          _buildTechStackSection(isMobile: true, isLandscape: true, screenWidth: actualScreenWidth),
          SizedBox(height: 20),
          _SkillsColumn(
            isVisible: isVisible,
            isMobile: isMobile,
            isLandscape: isLandscape,
            screenWidth: actualScreenWidth,
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'About',
              style: TextStyle(
                fontSize: isMobile ? actualScreenWidth * 0.08 : 56,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 8),
            Text(
              'Me',
              style: TextStyle(
                fontSize: isMobile ? actualScreenWidth * 0.08 : 56,
                fontWeight: FontWeight.bold,
                color: Color(0xFFF86E5B),
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        _AnimatedLine(width: isMobile ? actualScreenWidth * 0.35 : 150),
        SizedBox(height: isMobile ? 20 : 50),
        isMobile
            ? Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'I am a multidisciplinary creative technologist specializing in Cross-Platform Mobile Development and User Interface Design. With a strong foundation in Flutter and expert proficiency in Figma, I help startups and businesses transform abstract ideas into deployable, high-performance products.',
              style: TextStyle(
                fontSize: actualScreenWidth * 0.038,
                color: Colors.white.withOpacity(0.8),
                height: 1.5,
                letterSpacing: 0.3,
              ),
            ),
            SizedBox(height: 15),
            Text(
              'My journey in mobile development has equipped me with a strong foundation in UI/UX principles, state management, and modern development practices. I constantly strive to learn new technologies and improve my craft.',
              style: TextStyle(
                fontSize: actualScreenWidth * 0.038,
                color: Colors.white.withOpacity(0.8),
                height: 1.5,
                letterSpacing: 0.3,
              ),
            ),
            SizedBox(height: 30),
            // Tech Stack Section
            _buildTechStackSection(isMobile: true, isLandscape: false, screenWidth: actualScreenWidth),
            SizedBox(height: 30),
            _SkillsColumn(
              isVisible: isVisible,
              isMobile: isMobile,
              isLandscape: isLandscape,
              screenWidth: actualScreenWidth,
            ),
          ],
        )
            : Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 6,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20),
                  Text(
                    'I am a multidisciplinary creative technologist specializing in Cross-Platform Mobile Development and User Interface Design. With a strong foundation in Flutter and expert proficiency in Figma, I help startups and businesses transform abstract ideas into deployable, high-performance products.',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white.withOpacity(0.8),
                      height: 1.8,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'My journey in mobile development has equipped me with a strong foundation in UI/UX principles, state management, and modern development practices. I constantly strive to learn new technologies and improve my craft.',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white.withOpacity(0.8),
                      height: 1.8,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: 40),
                  // Tech Stack Section for Desktop
                  _buildTechStackSection(isMobile: false, isLandscape: false, screenWidth: actualScreenWidth),
                ],
              ),
            ),
            SizedBox(width: 60),
            Expanded(
              flex: 4,
              child: _SkillsColumn(
                isVisible: isVisible,
                isMobile: isMobile,
                isLandscape: isLandscape,
                screenWidth: actualScreenWidth,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTechStackSection({
    required bool isMobile,
    required bool isLandscape,
    required double screenWidth,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tech Stack',
          style: TextStyle(
            fontSize: isMobile
                ? (isLandscape ? screenWidth * 0.04 : screenWidth * 0.055)
                : 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: isMobile ? (isLandscape ? 6 : 8) : 12),
        Text(
          'Great products need great tools — here are the ones I use daily.',
          style: TextStyle(
            fontSize: isMobile
                ? (isLandscape ? screenWidth * 0.025 : screenWidth * 0.032)
                : 15,
            color: Colors.white.withOpacity(0.7),
            height: 1.4,
          ),
        ),
        SizedBox(height: isMobile ? (isLandscape ? 12 : 16) : 24),
        Wrap(
          spacing: isMobile ? (isLandscape ? 8 : 10) : 12,
          runSpacing: isMobile ? (isLandscape ? 8 : 10) : 12,
          children: techItems
              .asMap()
              .entries
              .map((entry) => _TechChip(
            text: entry.value,
            delay: entry.key * 50,
            isMobile: isMobile,
            isLandscape: isLandscape,
            screenWidth: screenWidth,
          ))
              .toList(),
        ),
      ],
    );
  }
}

class _TechChip extends StatefulWidget {
  final String text;
  final int delay;
  final bool isMobile;
  final bool isLandscape;
  final double screenWidth;

  const _TechChip({
    required this.text,
    required this.delay,
    required this.isMobile,
    required this.isLandscape,
    required this.screenWidth,
  });

  @override
  State<_TechChip> createState() => _TechChipState();
}

class _TechChipState extends State<_TechChip> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        curve: Curves.easeOut,
        margin: EdgeInsets.only(
          top: _isHovered ? 0 : 2,
          bottom: _isHovered ? 2 : 0,
        ),
        transform: Matrix4.identity()..scale(_isHovered ? 1.08 : 1.0),
        decoration: BoxDecoration(
          color: Color(0xFF1A1F3A).withOpacity(_isHovered ? 0.8 : 0.6),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _isHovered
                ? Color(0xFFF86E5B)
                : Color(0xFFF86E5B).withOpacity(0.2),
            width: _isHovered ? 1.5 : 1,
          ),
          boxShadow: _isHovered
              ? [
            BoxShadow(
              color: Color(0xFFF86E5B).withOpacity(0.3),
              blurRadius: 12,
              spreadRadius: 1,
              offset: Offset(0, 4),
            ),
          ]
              : [
            BoxShadow(
              color: Color(0xFFF86E5B).withOpacity(0.1),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 300 + widget.delay),
          tween: Tween(begin: 0.0, end: 1.0),
          curve: Curves.easeOut,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.scale(
                scale: 0.8 + (value * 0.2),
                child: child,
              ),
            );
          },
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: widget.isMobile
                  ? (widget.isLandscape ? 10 : 12)
                  : 14,
              vertical: widget.isMobile
                  ? (widget.isLandscape ? 6 : 8)
                  : 9,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  width: widget.isMobile
                      ? (widget.isLandscape ? 5 : 6)
                      : 6,
                  height: widget.isMobile
                      ? (widget.isLandscape ? 5 : 6)
                      : 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFF86E5B),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFFF86E5B).withOpacity(
                            _isHovered ? 0.8 : 0.5
                        ),
                        blurRadius: _isHovered ? 8 : 4,
                        spreadRadius: _isHovered ? 2 : 1,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: widget.isMobile
                    ? (widget.isLandscape ? 6 : 8)
                    : 8),
                Text(
                  widget.text,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: widget.isMobile
                        ? (widget.isLandscape
                        ? widget.screenWidth * 0.024
                        : widget.screenWidth * 0.03)
                        : 14,
                    fontWeight: _isHovered
                        ? FontWeight.w600
                        : FontWeight.w400,
                    letterSpacing: _isHovered ? 0.4 : 0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SkillsColumn extends StatelessWidget {
  final bool isVisible;
  final bool isMobile;
  final bool isLandscape;
  final double? screenWidth;

  _SkillsColumn({
    required this.isVisible,
    required this.isMobile,
    required this.isLandscape,
    this.screenWidth,
  });

  @override
  Widget build(BuildContext context) {
    final actualScreenWidth = screenWidth ?? MediaQuery.of(context).size.width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Technical Skills',
          style: TextStyle(
            fontSize: isMobile
                ? (isLandscape ? actualScreenWidth * 0.04 : actualScreenWidth * 0.055)
                : 24,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        SizedBox(height: isMobile ? (isLandscape ? 12 : 15) : 30),
        _SkillProgress('Flutter & Dart', 90, isVisible, isMobile: isMobile, isLandscape: isLandscape, screenWidth: actualScreenWidth),
        SizedBox(height: isMobile ? (isLandscape ? 12 : 15) : 25),
        _SkillProgress('UI/UX Design', 85, isVisible, isMobile: isMobile, isLandscape: isLandscape, screenWidth: actualScreenWidth),
        SizedBox(height: isMobile ? (isLandscape ? 12 : 15) : 25),
        _SkillProgress('C++', 75, isVisible, isMobile: isMobile, isLandscape: isLandscape, screenWidth: actualScreenWidth),
        SizedBox(height: isMobile ? (isLandscape ? 12 : 15) : 25),
        _SkillProgress('Git & GitHub', 80, isVisible, isMobile: isMobile, isLandscape: isLandscape, screenWidth: actualScreenWidth),
        SizedBox(height: isMobile ? (isLandscape ? 12 : 15) : 25),
        _SkillProgress('Firebase', 70, isVisible, isMobile: isMobile, isLandscape: isLandscape, screenWidth: actualScreenWidth),
      ],
    );
  }
}

class _SkillProgress extends StatelessWidget {
  final String skill;
  final double percentage;
  final bool isVisible;
  final bool isMobile;
  final bool isLandscape;
  final double? screenWidth;

  _SkillProgress(this.skill, this.percentage, this.isVisible, {
    required this.isMobile,
    this.isLandscape = false,
    this.screenWidth,
  });

  @override
  Widget build(BuildContext context) {
    final actualScreenWidth = screenWidth ?? MediaQuery.of(context).size.width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                skill,
                style: TextStyle(
                  fontSize: isMobile
                      ? (isLandscape ? actualScreenWidth * 0.028 : actualScreenWidth * 0.035)
                      : 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              '${percentage.toInt()}%',
              style: TextStyle(
                fontSize: isMobile
                    ? (isLandscape ? actualScreenWidth * 0.028 : actualScreenWidth * 0.035)
                    : 16,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ],
        ),
        SizedBox(height: isMobile ? (isLandscape ? 4 : 6) : 10),
        Stack(
          children: [
            Container(
              height: isMobile ? (isLandscape ? 4 : 5) : 8,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            TweenAnimationBuilder<double>(
              duration: Duration(milliseconds: 800),
              tween: Tween(begin: 0.0, end: isVisible ? percentage / 100 : 0.0),
              curve: Curves.easeOut,
              builder: (context, value, child) {
                return FractionallySizedBox(
                  widthFactor: value,
                  child: Container(
                    height: isMobile ? (isLandscape ? 4 : 5) : 8,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFFF86E5B), Color(0xFF924136)],
                      ),
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFFF86E5B).withOpacity(0.5),
                          blurRadius: 6,
                          spreadRadius: 0.5,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}

class _ProjectsContent extends StatelessWidget {
  final bool isVisible;
  final bool isMobile;
  final bool isLandscape;
  final double screenWidth;

  _ProjectsContent({
    required this.isVisible,
    required this.isMobile,
    required this.isLandscape,
    required this.screenWidth,
  });

  @override
  Widget build(BuildContext context) {
    // Determine columns based on screen size
    int getColumnCount() {
      if (isMobile) {
        return isLandscape ? 2 : 1;
      } else {
        return 3;
      }
    }

    // Determine aspect ratio based on screen size
    double getAspectRatio() {
      if (isMobile) {
        return isLandscape ? 1.0 : 1.2;
      } else {
        return 0.85;
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.45),
      ),
      padding: EdgeInsets.symmetric(
        vertical: isMobile ? (isLandscape ? 25 : 40) : 70,
        horizontal: isMobile ? screenWidth * 0.04 : 80,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Projects',
            style: TextStyle(
              fontSize: isMobile
                  ? (isLandscape ? screenWidth * 0.05 : screenWidth * 0.08)
                  : 56,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Where Innovation Meets Execution',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: isMobile
                  ? (isLandscape ? screenWidth * 0.025 : screenWidth * 0.035)
                  : 18,
            ),
          ),
          SizedBox(height: 12),
          _AnimatedLine(width: isMobile ? (isLandscape ? screenWidth * 0.15 : screenWidth * 0.35) : 150),
          SizedBox(height: 30),
          GridView.count(
            crossAxisCount: getColumnCount(),
            crossAxisSpacing: isMobile ? (isLandscape ? 12 : 16) : 20,
            mainAxisSpacing: isMobile ? (isLandscape ? 12 : 16) : 20,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            childAspectRatio: getAspectRatio(),
            children: [
              _ProjectCard(
                title: 'Nike App Clone',
                description: 'Nike Clone – Clone Of The Official Nike Store',
                imageUrl: 'assets/images/1.png',
                tags: ['Flutter'],
                isLandscape: isLandscape,
              ),
              _ProjectCard(
                title: 'Rivio',
                description: 'Track daily routines with charts & filters',
                imageUrl: 'images/R2.png',
                tags: ['Flutter', 'Figma', 'Firebase'],
                isLandscape: isLandscape,
              ),
              _ProjectCard(
                title: 'SnackSnap',
                description: 'Modern UI design exploration',
                imageUrl: 'assets/images/F1.png',
                tags: ['Figma'],
                isLandscape: isLandscape,
              ),
            ],
          ),
          SizedBox(height: 40),
          Center(
            child: TextButton(
              onPressed: () {},
              child: Text(
                'See More',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: isMobile
                      ? (isLandscape ? screenWidth * 0.025 : screenWidth * 0.035)
                      : 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProjectCard extends StatefulWidget {
  final String title;
  final String description;
  final String imageUrl;
  final List<String> tags;
  final bool isLandscape;

  _ProjectCard({
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.tags,
    this.isLandscape = false,
  });

  @override
  State<_ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<_ProjectCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        curve: Curves.easeOut,
        margin: EdgeInsets.only(
          top: _isHovered ? 0 : 4,
          bottom: _isHovered ? 4 : 0,
        ),
        transform: Matrix4.identity()..scale(_isHovered ? 1.02 : 1.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: _isHovered
              ? [
            BoxShadow(
              color: Color(0xFFF86E5B).withOpacity(0.35),
              blurRadius: 16,
              spreadRadius: 1,
              offset: Offset(0, 6),
            ),
          ]
              : [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              color: Color(0xFF1A1F3A),
              border: Border.all(color: Color(0xFF2A2F4A), width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    margin: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Color(0xFF0A0E27),
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: AssetImage(widget.imageUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(12, 0, 12, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: widget.isLandscape ? 16 : 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 6),
                      Text(
                        widget.description,
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: widget.isLandscape ? 12 : 13,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 12),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: widget.tags
                            .map(
                              (tag) => Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Color(0xFF0A0E27),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Color(0xFF2A2F4A),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              tag,
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: widget.isLandscape ? 10 : 11,
                              ),
                            ),
                          ),
                        )
                            .toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ContactContent extends StatelessWidget {
  final TextEditingController nameCtrl;
  final TextEditingController emailCtrl;
  final TextEditingController msgCtrl;
  final VoidCallback onSubmit;
  final bool isMobile;
  final bool isLandscape;
  final double? screenWidth;

  _ContactContent({
    required this.nameCtrl,
    required this.emailCtrl,
    required this.msgCtrl,
    required this.onSubmit,
    required this.isMobile,
    required this.isLandscape,
    this.screenWidth,
  });

  @override
  Widget build(BuildContext context) {
    final actualScreenWidth = screenWidth ?? MediaQuery.of(context).size.width;

    // Adjust layout for landscape mobile
    if (isMobile && isLandscape) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: actualScreenWidth * 0.08,
                      height: 3,
                      color: Color(0xFFF86E5B),
                      margin: EdgeInsets.only(right: 10),
                    ),
                    Text(
                      'Contacts',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.92),
                        fontSize: actualScreenWidth * 0.05,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 15),
                Text(
                  "Have a project ?",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: actualScreenWidth * 0.035,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  "Let's talk !",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: actualScreenWidth * 0.035,
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFF86E5B),
                      elevation: 0,
                      padding: EdgeInsets.symmetric(
                        vertical: actualScreenWidth * 0.025,
                        horizontal: actualScreenWidth * 0.06,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    child: Text(
                      "Submit",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: actualScreenWidth * 0.028,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Connect With Me',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: actualScreenWidth * 0.035,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                    SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _SocialIcon(
                          icon: Bootstrap.github,
                          label: 'GitHub',
                          url: 'https://github.com/RealSid45',
                          isMobile: true,
                          isLandscape: true,
                        ),
                        _SocialIcon(
                          icon: Bootstrap.linkedin,
                          label: 'LinkedIn',
                          url: 'https://www.linkedin.com/in/sidharth-biju-414273310/',
                          isMobile: true,
                          isLandscape: true,
                        ),
                        _SocialIcon(
                          icon: Bootstrap.twitter_x,
                          label: 'X',
                          url: 'https://x.com/SidharthSidu1',
                          isMobile: true,
                          isLandscape: true,
                        ),
                        _SocialIcon(
                          icon: Bootstrap.dribbble,
                          label: 'Dribbble',
                          url: 'https://dribbble.com/',
                          isMobile: true,
                          isLandscape: true,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 20),
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ContactField(
                  label: "Name",
                  controller: nameCtrl,
                  isMobile: true,
                  isLandscape: true,
                  screenWidth: actualScreenWidth,
                ),
                SizedBox(height: 12),
                _ContactField(
                  label: "Email",
                  controller: emailCtrl,
                  isMobile: true,
                  isLandscape: true,
                  screenWidth: actualScreenWidth,
                ),
                SizedBox(height: 12),
                _ContactField(
                  label: "Message",
                  controller: msgCtrl,
                  maxLines: 2,
                  isMobile: true,
                  isLandscape: true,
                  screenWidth: actualScreenWidth,
                ),
              ],
            ),
          ),
        ],
      );
    }

    return isMobile
        ? Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: actualScreenWidth * 0.12,
              height: 3,
              color: Color(0xFFF86E5B),
              margin: EdgeInsets.only(right: 10),
            ),
            Text(
              'Contacts',
              style: TextStyle(
                color: Colors.white.withOpacity(0.92),
                fontSize: actualScreenWidth * 0.08,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
        SizedBox(height: 20),
        Text(
          "Have a project ?",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: actualScreenWidth * 0.06,
            letterSpacing: -0.8,
          ),
        ),
        Text(
          "Let's talk !",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: actualScreenWidth * 0.06,
            letterSpacing: -0.8,
          ),
        ),
        SizedBox(height: 25),
        _ContactField(
          label: "Name",
          controller: nameCtrl,
          isMobile: true,
          isLandscape: false,
          screenWidth: actualScreenWidth,
        ),
        SizedBox(height: 15),
        _ContactField(
          label: "Email",
          controller: emailCtrl,
          isMobile: true,
          isLandscape: false,
          screenWidth: actualScreenWidth,
        ),
        SizedBox(height: 15),
        _ContactField(
          label: "Message",
          controller: msgCtrl,
          maxLines: 3,
          isMobile: true,
          isLandscape: false,
          screenWidth: actualScreenWidth,
        ),
        SizedBox(height: 25),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFF86E5B),
              elevation: 0,
              padding: EdgeInsets.symmetric(
                vertical: actualScreenWidth * 0.035,
                horizontal: actualScreenWidth * 0.08,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            child: Text(
              "Submit",
              style: TextStyle(
                color: Colors.white,
                fontSize: actualScreenWidth * 0.04,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ),
        SizedBox(height: 30),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Connect With Me',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: actualScreenWidth * 0.045,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
            SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _SocialIcon(
                  icon: Bootstrap.github,
                  label: 'GitHub',
                  url: 'https://github.com/RealSid45',
                  isMobile: true,
                  isLandscape: false,
                ),
                _SocialIcon(
                  icon: Bootstrap.linkedin,
                  label: 'LinkedIn',
                  url: 'https://www.linkedin.com/in/sidharth-biju-414273310/',
                  isMobile: true,
                  isLandscape: false,
                ),
                _SocialIcon(
                  icon: Bootstrap.twitter_x,
                  label: 'X',
                  url: 'https://x.com/SidharthSidu1',
                  isMobile: true,
                  isLandscape: false,
                ),
                _SocialIcon(
                  icon: Bootstrap.dribbble,
                  label: 'Dribbble',
                  url: 'https://dribbble.com/',
                  isMobile: true,
                  isLandscape: false,
                ),
              ],
            ),
          ],
        ),
      ],
    )
        : Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 1,
          child: Padding(
            padding: EdgeInsets.only(right: 50.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 80,
                      height: 4,
                      color: Color(0xFFF86E5B),
                      margin: EdgeInsets.only(right: 16),
                    ),
                    Text(
                      'Contacts',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.92),
                        fontSize: 56,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 50),
                Text(
                  "Have a project ?",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 40,
                    letterSpacing: -1.5,
                  ),
                ),
                Text(
                  "Let's talk !",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 40,
                    letterSpacing: -1.5,
                  ),
                ),
                SizedBox(height: 50),
                ElevatedButton(
                  onPressed: onSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFF86E5B),
                    elevation: 0,
                    padding: EdgeInsets.symmetric(horizontal: 56, vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  child: Text(
                    "Submit",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                SizedBox(height: 60),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Connect With Me',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        _SocialIcon(
                          icon: Bootstrap.github,
                          label: 'GitHub',
                          url: 'https://github.com/RealSid45',
                        ),
                        SizedBox(width: 16),
                        _SocialIcon(
                          icon: Bootstrap.linkedin,
                          label: 'LinkedIn',
                          url: 'https://www.linkedin.com/in/sidharth-biju-414273310/',
                        ),
                        SizedBox(width: 16),
                        _SocialIcon(
                          icon: Bootstrap.twitter_x,
                          label: 'X',
                          url: 'https://x.com/SidharthSidu1',
                        ),
                        SizedBox(width: 16),
                        _SocialIcon(
                          icon: Bootstrap.dribbble,
                          label: 'Dribbble',
                          url: 'https://dribbble.com/',
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Padding(
            padding: EdgeInsets.only(left: 40, top: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ContactField(label: "Name", controller: nameCtrl),
                SizedBox(height: 30),
                _ContactField(label: "Email", controller: emailCtrl),
                SizedBox(height: 30),
                _ContactField(label: "Message", controller: msgCtrl, maxLines: 4),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ContactField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final int maxLines;
  final bool isMobile;
  final bool isLandscape;
  final double? screenWidth;

  _ContactField({
    required this.label,
    required this.controller,
    this.maxLines = 1,
    this.isMobile = false,
    this.isLandscape = false,
    this.screenWidth,
  });

  @override
  Widget build(BuildContext context) {
    final actualScreenWidth = screenWidth ?? MediaQuery.of(context).size.width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: isMobile
                ? (isLandscape ? actualScreenWidth * 0.03 : actualScreenWidth * 0.04)
                : 20,
            fontWeight: FontWeight.w400,
          ),
        ),
        TextField(
          controller: controller,
          cursorColor: Colors.white,
          maxLines: maxLines,
          style: TextStyle(
            color: Colors.white,
            fontSize: isMobile
                ? (isLandscape ? actualScreenWidth * 0.03 : actualScreenWidth * 0.04)
                : 22,
          ),
          decoration: InputDecoration(
            border: InputBorder.none,
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white, width: 1.5),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white70, width: 2),
            ),
            isDense: true,
            contentPadding: EdgeInsets.symmetric(vertical: 8),
          ),
        ),
      ],
    );
  }
}

class _SocialIcon extends StatelessWidget {
  final dynamic icon;
  final String label;
  final String url;
  final bool isMobile;
  final bool isLandscape;

  _SocialIcon({
    required this.icon,
    required this.label,
    required this.url,
    this.isMobile = false,
    this.isLandscape = false,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () async {
            final uri = Uri.parse(url);
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri);
            }
          },
          child: Container(
            padding: EdgeInsets.all(isMobile ? (isLandscape ? 8 : 10) : 14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: isMobile ? (isLandscape ? 16 : 18) : 24,
            ),
          ),
        ),
      ),
    );
  }
}