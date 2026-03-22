import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'design_system.dart';
import 'widgets/responsive_layout.dart';

class SupabaseConfig {
  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const String supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  static const String messagesTable = 'contact_messages';
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  assert(
    SupabaseConfig.supabaseUrl.isNotEmpty,
    'SUPABASE_URL is missing.',
  );

  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.supabaseAnonKey,
  );

  runApp(PortfolioApp());
}

class MessageService {
  static final _client = Supabase.instance.client;

  static Future<bool> sendContactMessage({
    required String name,
    required String email,
    required String message,
  }) async {
    try {
      await _client.from(SupabaseConfig.messagesTable).insert({
        'name': name.trim(),
        'email': email.trim(),
        'message': message.trim(),
        'created_at': DateTime.now().toIso8601String(),
        'read': false,
      });
      return true;
    } on PostgrestException catch (e) {
      debugPrint('Supabase error: ${e.message}');
      return false;
    } catch (e) {
      debugPrint('Unexpected error: $e');
      return false;
    }
  }
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
  bool _isExperienceVisible = false;
  bool _isContactsVisible = false;
  bool _isMenuOpen = false;
  bool _isSubmitting = false;
  bool _showAdditionalExperiences = false;
  String _activeSection = 'home';

  final GlobalKey _homeKey = GlobalKey();
  final GlobalKey _aboutKey = GlobalKey();
  final GlobalKey _projectsKey = GlobalKey();
  final GlobalKey _experienceKey = GlobalKey();
  final GlobalKey _contactKey = GlobalKey();

  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _msgCtrl = TextEditingController();

  bool _isDownloading = false;
  double _downloadProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _scrollController.addListener(_handleScroll);
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      vsync: this,
      duration: AppDesign.mediumDuration,
    );
    _slideController = AnimationController(
      vsync: this,
      duration: AppDesign.mediumDuration,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: AppDesign.defaultCurve,
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset(-0.1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: AppDesign.defaultCurve,
    ));
    _fadeController.forward();
    _slideController.forward();
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position.pixels;
    final maxScroll = _scrollController.position.maxScrollExtent;
    if (maxScroll <= 0) return;

    final aboutVisible = position > maxScroll * 0.2;
    final projectsVisible = position > maxScroll * 0.45;
    final experienceVisible = position > maxScroll * 0.6;
    final contactsVisible = position > maxScroll * 0.85;

    String newActiveSection = 'home';
    if (contactsVisible) newActiveSection = 'contacts';
    else if (experienceVisible) newActiveSection = 'experience';
    else if (projectsVisible) newActiveSection = 'projects';
    else if (aboutVisible) newActiveSection = 'about';

    if (aboutVisible != _isAboutVisible ||
        projectsVisible != _isProjectsVisible ||
        experienceVisible != _isExperienceVisible ||
        contactsVisible != _isContactsVisible ||
        newActiveSection != _activeSection) {
      setState(() {
        _isAboutVisible = aboutVisible;
        _isProjectsVisible = projectsVisible;
        _isExperienceVisible = experienceVisible;
        _isContactsVisible = contactsVisible;
        _activeSection = newActiveSection;
      });
    }
  }

  Future<void> _downloadResume() async {
    const googleDriveFileId = '1L6HrWjoj4RH5CSddjPsDUSGQfHoBNCKs';
    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.0;
    });
    try {
      final url = Uri.parse(
          'https://drive.google.com/file/d/$googleDriveFileId/view?usp=sharing');
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        _showSnackBar('Could not open resume link', isError: true);
      }
    } catch (e) {
      debugPrint('Error opening resume: $e');
      _showSnackBar('Failed to open resume. Check your internet connection.',
          isError: true);
    } finally {
      setState(() => _isDownloading = false);
    }
  }

  Future<void> _submitForm() async {
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

    setState(() => _isSubmitting = true);

    final success = await MessageService.sendContactMessage(
      name: name,
      email: email,
      message: message,
    );

    setState(() => _isSubmitting = false);

    if (success) {
      _showSnackBar(
        "Message sent! I'll get back to you soon.",
        isError: false,
      );
      _nameCtrl.clear();
      _emailCtrl.clear();
      _msgCtrl.clear();
    } else {
      _showSnackBar(
        'Failed to send message. Please try again.',
        isError: true,
      );
    }
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
        backgroundColor: isError ? Colors.red.shade700 : AppDesign.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: EdgeInsets.all(20),
        duration: Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Close',
          textColor: Colors.white,
          onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
        ),
      ),
    );
  }

  void _scrollToSection(GlobalKey key) {
    if (key.currentContext == null) return;
    Scrollable.ensureVisible(
      key.currentContext!,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      alignment: 0.35,
    );
    String targetSection = 'home';
    if (key == _homeKey) targetSection = 'home';
    if (key == _aboutKey) targetSection = 'about';
    if (key == _projectsKey) targetSection = 'projects';
    if (key == _experienceKey) targetSection = 'experience';
    if (key == _contactKey) targetSection = 'contacts';

    setState(() {
      _isMenuOpen = false;
      _activeSection = targetSection;
    });
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

  Widget _buildMobileMenu() {
    return AnimatedPositioned(
      duration: AppDesign.fastDuration,
      top: 0,
      right: _isMenuOpen ? 0 : -300,
      bottom: 0,
      width: 300,
      child: Container(
        color: AppDesign.surfaceDark,
        child: SafeArea(
          child: Column(
            children: [
              SizedBox(height: 20),
              _MobileNavItem('Home', () => _scrollToSection(_homeKey)),
              _MobileNavItem('About', () => _scrollToSection(_aboutKey)),
              _MobileNavItem('Projects', () => _scrollToSection(_projectsKey)),
              _MobileNavItem('Experience', () => _scrollToSection(_experienceKey)),
              _MobileNavItem('Contacts', () => _scrollToSection(_contactKey)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          Container(
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
                  _buildHeader(screenWidth),
                  Container(key: _homeKey, child: _buildHeroSection(screenWidth)),
                  _buildSkillsSection(),
                  Container(key: _aboutKey, child: _buildAboutSection()),
                  Container(key: _projectsKey, child: _buildProjectsSection()),
                  Container(key: _experienceKey, child: _buildExperienceSection()),
                  if (_showAdditionalExperiences) _buildAdditionalExperienceSection(),
                  Container(key: _contactKey, child: _buildContactSection(screenWidth)),
                ],
              ),
            ),
          ),
          if (AppDesign.isMobile(context)) _buildMobileMenu(),
          if (_isMenuOpen && AppDesign.isMobile(context))
            GestureDetector(
              onTap: () => setState(() => _isMenuOpen = false),
              child: Container(color: Colors.black54),
            ),
          if (_isSubmitting)
            Container(
              color: Colors.black54,
              child: Center(
                child: Container(
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppDesign.surfaceDark,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppDesign.primary.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 50,
                        height: 50,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation(AppDesign.primary),
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Sending your message...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: AppDesign.bodyM,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(double screenWidth) {
    final isMobile = AppDesign.isMobile(context);
    final padding = AppDesign.responsivePadding(context);
    return RepaintBoundary(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: padding,
            vertical: isMobile ? 20 : 30,
          ),
          child: isMobile ? _buildMobileHeader() : _buildDesktopHeader(),
        ),
      ),
    );
  }

  Widget _buildMobileHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Sidharth Biju',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        IconButton(
          icon: Icon(_isMenuOpen ? Icons.close : Icons.menu,
              color: Colors.white),
          onPressed: () => setState(() => _isMenuOpen = !_isMenuOpen),
        ),
      ],
    );
  }

  Widget _buildDesktopHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Sidharth Biju',
            style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        Row(
          children: [
            _NavButton('Home', () => _scrollToSection(_homeKey), _activeSection == 'home'),
            SizedBox(width: 50),
            _NavButton('About', () => _scrollToSection(_aboutKey), _activeSection == 'about'),
            SizedBox(width: 50),
            _NavButton('Projects', () => _scrollToSection(_projectsKey), _activeSection == 'projects'),
            SizedBox(width: 50),
            _NavButton('Experience', () => _scrollToSection(_experienceKey), _activeSection == 'experience'),
            SizedBox(width: 50),
            _NavButton('Contacts', () => _scrollToSection(_contactKey), _activeSection == 'contacts'),
          ],
        ),
      ],
    );
  }

  Widget _buildHeroSection(double screenWidth) {
    final isMobile = AppDesign.isMobile(context);
    final padding = AppDesign.responsivePadding(context);
    return RepaintBoundary(
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: padding,
          vertical: isMobile ? 40 : 60,
        ),
        child: ResponsiveLayout(
          mobile: Column(
            children: [
              SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: _HeroContent(
                    onProjectTap: () => _scrollToSection(_contactKey),
                    onResumeTap: _downloadResume,
                    isDownloading: _isDownloading,
                    downloadProgress: _downloadProgress,
                  ),
                ),
              ),
              SizedBox(height: 40),
              _HeroImage(fadeAnimation: _fadeAnimation),
            ],
          ),
          desktop: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 5,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: _HeroContent(
                      onProjectTap: () => _scrollToSection(_contactKey),
                      onResumeTap: _downloadResume,
                      isDownloading: _isDownloading,
                      downloadProgress: _downloadProgress,
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 4,
                child: _HeroImage(fadeAnimation: _fadeAnimation),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSkillsSection() {
    final isMobile = AppDesign.isMobile(context);
    final padding = AppDesign.responsivePadding(context);
    return RepaintBoundary(
      child: Container(
        color: Colors.black.withOpacity(0.7),
        padding: EdgeInsets.symmetric(
          horizontal: padding,
          vertical: isMobile ? 30 : 40,
        ),
        child: isMobile
            ? Wrap(
          alignment: WrapAlignment.center,
          spacing: 20,
          runSpacing: 20,
          children: [
            _SkillChip('Flutter', 0),
            _SkillChip('UI / UX', 50),
            _SkillChip('C++', 100),
            _SkillChip('Git', 150),
            _SkillChip('Github', 200),
          ],
        )
            : Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _SkillChip('Flutter', 0),
            _SkillChip('UI / UX', 50),
            _SkillChip('C++', 100),
            _SkillChip('Git', 150),
            _SkillChip('Github', 200),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutSection() {
    final padding = AppDesign.responsivePadding(context);
    return RepaintBoundary(
      child: AnimatedOpacity(
        duration: AppDesign.mediumDuration,
        opacity: _isAboutVisible ? 1.0 : 0.0,
        curve: AppDesign.defaultCurve,
        child: AnimatedContainer(
          duration: AppDesign.mediumDuration,
          curve: AppDesign.defaultCurve,
          transform: Matrix4.translationValues(0, _isAboutVisible ? 0 : 20, 0),
          padding: EdgeInsets.symmetric(
            horizontal: padding,
            vertical: AppDesign.isMobile(context) ? 60 : 100,
          ),
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/KX9.jpg"),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.4),
                BlendMode.darken,
              ),
            ),
          ),
          child: _AboutContent(isVisible: _isAboutVisible),
        ),
      ),
    );
  }

  Widget _buildProjectsSection() {
    return RepaintBoundary(
      child: AnimatedOpacity(
        duration: AppDesign.mediumDuration,
        opacity: _isProjectsVisible ? 1.0 : 0.0,
        curve: AppDesign.defaultCurve,
        child: AnimatedContainer(
          duration: AppDesign.mediumDuration,
          curve: AppDesign.defaultCurve,
          transform: Matrix4.translationValues(0, _isProjectsVisible ? 0 : 20, 0),
          child: _ProjectsContent(isVisible: _isProjectsVisible),
        ),
      ),
    );
  }

  Widget _buildExperienceSection() {
    return RepaintBoundary(
      child: AnimatedOpacity(
        duration: AppDesign.mediumDuration,
        opacity: _isExperienceVisible ? 1.0 : 0.0,
        curve: AppDesign.defaultCurve,
        child: AnimatedContainer(
          duration: AppDesign.mediumDuration,
          curve: AppDesign.defaultCurve,
          transform: Matrix4.translationValues(0, _isExperienceVisible ? 0 : 20, 0),
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/KX10.jpg"),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.4),
                BlendMode.darken,
              ),
            ),
          ),
          child: _ExperienceContent(
            isVisible: _isExperienceVisible,
            showViewMoreButton: !_showAdditionalExperiences,
            onViewMorePressed: () => setState(() => _showAdditionalExperiences = true),
          ),
        ),
      ),
    );
  }

  Widget _buildAdditionalExperienceSection() {
    return RepaintBoundary(
      child: AnimatedContainer(
        duration: AppDesign.mediumDuration,
        curve: AppDesign.defaultCurve,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/KX11.jpg"),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.4),
              BlendMode.darken,
              ),
          ),
        ),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 80, vertical: 60),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.only(bottom: 30),
                padding: EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: Color(0xFF1A1F3A).withOpacity(0.8),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Color(0xFF2A2F4A), width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFFF86E5B).withOpacity(0.1),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Live Project - POS by ORAVCO',
                                style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                            SizedBox(height: 4),
                            Text('ORAVCO Private Limited',
                                style: TextStyle(
                                    fontSize: 18,
                                    color: Color(0xFFF86E5B),
                                    fontWeight: FontWeight.w500)),
                          ],
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFFF86E5B), Color(0xFF924136)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text('Dec 2025',
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                    SizedBox(height: 25),
                    Divider(color: Colors.white.withOpacity(0.2), height: 1),
                    SizedBox(height: 25),
                    Text(
                      'Successfully completed a Live Project titled "POS by ORAVCO" from 01/12/2025 to 06/12/2025',
                      style: TextStyle(
                          fontSize: 20,
                          color: Colors.white.withOpacity(0.9),
                          fontStyle: FontStyle.italic,
                          height: 1.6),
                    ),
                    SizedBox(height: 30),
                    Text('Key Contributions:',
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.w500)),
                    SizedBox(height: 20),
                    Column(
                      children: [
                        _AdditionalExperienceBullet('Integrated developed APIs into the client Application built with Flutter'),
                        SizedBox(height: 12),
                        _AdditionalExperienceBullet('Collaborated with the team to deliver project outcomes within timelines'),
                        SizedBox(height: 12),
                        _AdditionalExperienceBullet('Effectively contributed to the successful completion of the project'),
                      ],
                    ),
                    SizedBox(height: 30),
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Color(0xFF0A0E27).withOpacity(0.5),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: Color(0xFFF86E5B).withOpacity(0.3), width: 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Certificate Excerpt:',
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFFF86E5B),
                                  fontWeight: FontWeight.w600)),
                          SizedBox(height: 10),
                          Text(
                            '"We found him to be hardworking, dedicated, proactive, and a keen learner, who contributed effectively to the successful completion of the project."',
                            style: TextStyle(
                                fontSize: 16,
                                color: Colors.white.withOpacity(0.8),
                                fontStyle: FontStyle.italic,
                                height: 1.6),
                          ),
                          SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text('- ORAVCO Private Limited',
                                style: TextStyle(
                                    fontSize: 14, color: Colors.white70)),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 30),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _ExperienceSkillChip('Flutter'),
                        _ExperienceSkillChip('API Integration'),
                        _ExperienceSkillChip('Team Collaboration'),
                        _ExperienceSkillChip('Project Delivery'),
                        _ExperienceSkillChip('Problem Solving'),
                        _ExperienceSkillChip('Time Management'),
                      ],
                    ),
                  ],
                ),
              ),
              Center(
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () => setState(() => _showAdditionalExperiences = false),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Color(0xFFF86E5B), width: 2),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.arrow_upward, color: Color(0xFFF86E5B), size: 20),
                          SizedBox(width: 12),
                          Text('Show Less Experiences',
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Color(0xFFF86E5B),
                                  fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactSection(double screenWidth) {
    final padding = AppDesign.responsivePadding(context);
    return RepaintBoundary(
      child: AnimatedOpacity(
        duration: AppDesign.mediumDuration,
        opacity: _isContactsVisible ? 1.0 : 0.0,
        curve: AppDesign.defaultCurve,
        child: AnimatedContainer(
          duration: AppDesign.mediumDuration,
          curve: AppDesign.defaultCurve,
          transform: Matrix4.translationValues(0, _isContactsVisible ? 0 : 20, 0),
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            vertical: AppDesign.isMobile(context) ? 60 : 90,
            horizontal: padding,
          ),
          child: _ContactContent(
            nameCtrl: _nameCtrl,
            emailCtrl: _emailCtrl,
            msgCtrl: _msgCtrl,
            onSubmit: _submitForm,
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatefulWidget {
  final String text;
  final VoidCallback onTap;
  final bool isActive;
  const _NavButton(this.text, this.onTap, this.isActive);
  @override
  State<_NavButton> createState() => _NavButtonState();
}

class _NavButtonState extends State<_NavButton> {
  bool _isHovered = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              child: Text(
                widget.text,
                style: TextStyle(
                  fontSize: AppDesign.bodyM,
                  color: widget.isActive || _isHovered
                      ? AppDesign.primary
                      : Colors.white70,
                  fontWeight: widget.isActive ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            AnimatedContainer(
              duration: AppDesign.fastDuration,
              height: 2,
              width: _isHovered || widget.isActive ? 40 : 0,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [AppDesign.primary, AppDesign.secondary]),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroContent extends StatelessWidget {
  final VoidCallback onProjectTap;
  final VoidCallback onResumeTap;
  final bool isDownloading;
  final double downloadProgress;

  _HeroContent({
    required this.onProjectTap,
    required this.onResumeTap,
    required this.isDownloading,
    required this.downloadProgress,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = AppDesign.isMobile(context);
    final displaySize = AppDesign.responsiveFontSize(context, AppDesign.displayXL);
    final headingSize = AppDesign.responsiveFontSize(context, AppDesign.displayL);

    return Column(
      crossAxisAlignment: isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: isMobile ? MainAxisSize.min : MainAxisSize.max,
          children: [
            Text('Hello',
                style: TextStyle(
                    fontSize: displaySize,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
            TweenAnimationBuilder<double>(
              duration: AppDesign.mediumDuration,
              tween: Tween(begin: 0.0, end: 1.0),
              curve: Curves.elasticOut,
              builder: (context, value, child) =>
                  Transform.scale(scale: value, child: child),
              child: Text('.',
                  style: TextStyle(
                      fontSize: displaySize,
                      fontWeight: FontWeight.bold,
                      color: AppDesign.primary)),
            ),
          ],
        ),
        SizedBox(height: 10),
        _AnimatedLine(width: isMobile ? 150 : 230),
        SizedBox(height: 30),
        Text("I'm Sidharth",
            style: TextStyle(
                fontSize: AppDesign.responsiveFontSize(context, AppDesign.displayM),
                fontWeight: FontWeight.w300,
                color: Colors.white,
                letterSpacing: 0.5),
            textAlign: isMobile ? TextAlign.center : TextAlign.left),
        SizedBox(height: 5),
        Text('Flutter Developer',
            style: TextStyle(
                fontSize: headingSize,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                height: 1.1),
            textAlign: isMobile ? TextAlign.center : TextAlign.left),
        SizedBox(height: 40),
        isMobile
            ? Column(children: [
          _GradientButton(text: 'Got a Project?', onPressed: onProjectTap, filled: true),
          SizedBox(height: 16),
          _GradientButton(
              text: isDownloading ? 'Downloading...' : 'My Resume',
              onPressed: isDownloading ? null : onResumeTap,
              filled: false,
              showProgress: isDownloading,
              progress: downloadProgress),
        ])
            : Row(children: [
          _GradientButton(text: 'Got a Project?', onPressed: onProjectTap, filled: true),
          SizedBox(width: 30),
          _GradientButton(
              text: isDownloading ? 'Downloading...' : 'My Resume',
              onPressed: isDownloading ? null : onResumeTap,
              filled: false,
              showProgress: isDownloading,
              progress: downloadProgress),
        ]),
        SizedBox(height: 60),
        _AvailabilityIndicator(),
        SizedBox(height: 30),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          alignment: isMobile ? WrapAlignment.center : WrapAlignment.start,
          children: [
            _HomeSocialIcon(icon: Bootstrap.google, label: 'Gmail', url: 'mailto:sidhuxplore4@gmail.com'),
            _HomeSocialIcon(icon: Bootstrap.whatsapp, label: 'WhatsApp', url: 'https://wa.me/919544413854'),
            _HomeSocialIcon(icon: Bootstrap.instagram, label: 'Instagram', url: 'https://instagram.com/_the_realsid_'),
            _HomeSocialIcon(icon: Bootstrap.twitter_x, label: 'X', url: 'https://x.com/SidharthSidu1'),
          ],
        ),
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
      builder: (context, value, child) => Container(
        width: value,
        height: 3,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF86E5B), Color(0xFF924136), Color(0xFF924136)],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
      ),
    );
  }
}

class _GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool filled;
  final bool showProgress;
  final double progress;

  _GradientButton({
    required this.text,
    required this.onPressed,
    required this.filled,
    this.showProgress = false,
    this.progress = 0.0,
  });

  static const gradient = LinearGradient(
    colors: [Color(0xFFF86E5B), Color(0xFF924136)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: onPressed == null ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
          decoration: BoxDecoration(
            gradient: filled ? gradient : null,
            color: filled ? null : (onPressed == null ? Color(0xFF2A2F4A) : Color(0xFF1a2332)),
            borderRadius: BorderRadius.circular(6),
            boxShadow: filled && onPressed != null
                ? [BoxShadow(color: Color(0xFFF86E5B).withOpacity(0.3), blurRadius: 10, offset: Offset(0, 4))]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showProgress)
                Container(
                  width: 16,
                  height: 16,
                  margin: EdgeInsets.only(right: 8),
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              Text(text,
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(onPressed == null ? 0.5 : 1.0),
                      fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }
}

class _AvailabilityIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 1000),
          tween: Tween(begin: 0.0, end: 1.0),
          curve: Curves.easeInOut,
          builder: (context, value, child) => Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: Color.lerp(Colors.transparent, Color(0xFFF86E5B), value),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                    color: Color(0xFFF86E5B).withOpacity(value * 0.6),
                    blurRadius: 6,
                    spreadRadius: 1)
              ],
            ),
          ),
        ),
        SizedBox(width: 10),
        Text('Available For Work',
            style: TextStyle(fontSize: 16, color: Colors.white70)),
      ],
    );
  }
}

class _HomeSocialIcon extends StatefulWidget {
  final dynamic icon;
  final String label;
  final String url;
  _HomeSocialIcon({required this.icon, required this.label, required this.url});
  @override
  State<_HomeSocialIcon> createState() => _HomeSocialIconState();
}

class _HomeSocialIconState extends State<_HomeSocialIcon> {
  bool _isHovered = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () async {
          final uri = Uri.parse(widget.url);
          if (await canLaunchUrl(uri)) await launchUrl(uri);
        },
        child: Tooltip(
          message: widget.label,
          child: AnimatedContainer(
            duration: Duration(milliseconds: 200),
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _isHovered
                  ? Color(0xFFF86E5B).withOpacity(0.2)
                  : Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _isHovered ? Color(0xFFF86E5B) : Colors.white.withOpacity(0.2),
                width: _isHovered ? 1.5 : 1,
              ),
              boxShadow: _isHovered
                  ? [BoxShadow(color: Color(0xFFF86E5B).withOpacity(0.3), blurRadius: 8, spreadRadius: 1, offset: Offset(0, 2))]
                  : null,
            ),
            child: Icon(widget.icon,
                color: _isHovered ? Color(0xFFF86E5B) : Colors.white, size: 22),
          ),
        ),
      ),
    );
  }
}

class _HeroImage extends StatelessWidget {
  final Animation<double> fadeAnimation;
  _HeroImage({required this.fadeAnimation});
  @override
  Widget build(BuildContext context) {
    final isMobile = AppDesign.isMobile(context);
    final imageWidth = isMobile ? MediaQuery.of(context).size.width * 0.8 : 450.0;
    final imageHeight = isMobile ? imageWidth * 1.2 : 550.0;
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 600),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOut,
      builder: (context, value, child) => Transform.translate(
        offset: Offset(20 * (1 - value), 0),
        child: Opacity(opacity: value, child: child),
      ),
      child: Align(
        child: Container(
          width: imageWidth,
          height: imageHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            image: DecorationImage(
              image: AssetImage("assets/images/Prof.jpeg"),
              fit: BoxFit.cover,
            ),
            boxShadow: [BoxShadow(color: Colors.black, blurRadius: 15, offset: Offset(0, 8))],
          ),
        ),
      ),
    );
  }
}

class _SkillChip extends StatelessWidget {
  final String text;
  final int delay;
  _SkillChip(this.text, this.delay);
  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300 + delay),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOut,
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Padding(
          padding: EdgeInsets.all(4),
          child: Text(text,
              style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 0.5)),
        ),
      ),
    );
  }
}

class _AboutContent extends StatelessWidget {
  final bool isVisible;
  _AboutContent({required this.isVisible});

  final List<String> techItems = [
    "Dart", "Flutter", "Provider", "GetX", "BLoC", "Riverpod",
    "sqflite", "Hive", "Figma", "Cursor", "Firebase", "REST API",
    "Git / GitHub", "Dependency Injection", "Payment Integration",
    "MVVM", "Responsive Design",
  ];

  @override
  Widget build(BuildContext context) {
    final isMobile = AppDesign.isMobile(context);
    final titleSize = AppDesign.responsiveFontSize(context, AppDesign.displayL);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(child: Text('About', style: TextStyle(fontSize: titleSize, fontWeight: FontWeight.bold, color: Colors.white))),
            SizedBox(width: 8),
            Flexible(child: Text('Me', style: TextStyle(fontSize: titleSize, fontWeight: FontWeight.bold, color: AppDesign.primary))),
          ],
        ),
        SizedBox(height: 8),
        _AnimatedLine(width: isMobile ? 100 : 150),
        SizedBox(height: isMobile ? 30 : 50),
        ResponsiveLayout(
          mobile: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAboutText(),
              SizedBox(height: 40),
              _buildTechStackSection(context),
              SizedBox(height: 40),
              _SkillsColumn(isVisible: isVisible),
            ],
          ),
          desktop: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 6,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20),
                    _buildAboutText(),
                    SizedBox(height: 40),
                    _buildTechStackSection(context),
                  ],
                ),
              ),
              SizedBox(width: 60),
              Expanded(flex: 4, child: _SkillsColumn(isVisible: isVisible)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAboutText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'I am a multidisciplinary creative technologist specializing in Cross-Platform Mobile Development and User Interface Design. With a strong foundation in Flutter and expert proficiency in Figma, I help startups and businesses transform abstract ideas into deployable, high-performance products.',
          style: TextStyle(fontSize: AppDesign.bodyM, color: Colors.white.withOpacity(0.8), height: 1.8, letterSpacing: 0.5),
        ),
        SizedBox(height: 20),
        Text(
          'My journey in mobile development has equipped me with a strong foundation in UI/UX principles, state management, and modern development practices. I constantly strive to learn new technologies and improve my craft.',
          style: TextStyle(fontSize: AppDesign.bodyM, color: Colors.white.withOpacity(0.8), height: 1.8, letterSpacing: 0.5),
        ),
      ],
    );
  }

  Widget _buildTechStackSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Tech Stack',
            style: TextStyle(
                fontSize: AppDesign.responsiveFontSize(context, AppDesign.headingL),
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        SizedBox(height: 12),
        Text('Great products need great tools — here are the ones I use daily.',
            style: TextStyle(fontSize: AppDesign.bodyS, color: Colors.white.withOpacity(0.7), height: 1.4)),
        SizedBox(height: 24),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: techItems
              .asMap()
              .entries
              .map((entry) => _TechChip(text: entry.value, delay: entry.key * 50))
              .toList(),
        ),
      ],
    );
  }
}

class _TechChip extends StatefulWidget {
  final String text;
  final int delay;
  _TechChip({required this.text, required this.delay});
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
        margin: EdgeInsets.only(top: _isHovered ? 0 : 2, bottom: _isHovered ? 2 : 0),
        transform: Matrix4.identity()..scale(_isHovered ? 1.08 : 1.0),
        decoration: BoxDecoration(
          color: Color(0xFF1A1F3A).withOpacity(_isHovered ? 0.8 : 0.6),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _isHovered ? Color(0xFFF86E5B) : Color(0xFFF86E5B).withOpacity(0.2),
            width: _isHovered ? 1.5 : 1,
          ),
          boxShadow: _isHovered
              ? [BoxShadow(color: Color(0xFFF86E5B).withOpacity(0.3), blurRadius: 12, spreadRadius: 1, offset: Offset(0, 4))]
              : [BoxShadow(color: Color(0xFFF86E5B).withOpacity(0.1), blurRadius: 4, offset: Offset(0, 2))],
        ),
        child: TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 300 + widget.delay),
          tween: Tween(begin: 0.0, end: 1.0),
          curve: Curves.easeOut,
          builder: (context, value, child) => Opacity(
            opacity: value,
            child: Transform.scale(scale: 0.8 + (value * 0.2), child: child),
          ),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFF86E5B),
                    boxShadow: [
                      BoxShadow(
                          color: Color(0xFFF86E5B).withOpacity(_isHovered ? 0.8 : 0.5),
                          blurRadius: _isHovered ? 8 : 4,
                          spreadRadius: _isHovered ? 2 : 1)
                    ],
                  ),
                ),
                SizedBox(width: 8),
                Text(widget.text,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: _isHovered ? FontWeight.w600 : FontWeight.w400,
                        letterSpacing: _isHovered ? 0.4 : 0.2)),
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
  _SkillsColumn({required this.isVisible});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Technical Skills',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: Colors.white)),
        SizedBox(height: 30),
        _SkillProgress('Flutter & Dart', 90, isVisible),
        SizedBox(height: 25),
        _SkillProgress('UI/UX Design', 85, isVisible),
        SizedBox(height: 25),
        _SkillProgress('C++', 75, isVisible),
        SizedBox(height: 25),
        _SkillProgress('Git & GitHub', 80, isVisible),
        SizedBox(height: 25),
        _SkillProgress('Firebase', 70, isVisible),
      ],
    );
  }
}

class _SkillProgress extends StatelessWidget {
  final String skill;
  final double percentage;
  final bool isVisible;
  _SkillProgress(this.skill, this.percentage, this.isVisible);
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(skill,
                  style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis),
            ),
            Text('${percentage.toInt()}%',
                style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.7))),
          ],
        ),
        SizedBox(height: 10),
        Stack(
          children: [
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            TweenAnimationBuilder<double>(
              duration: Duration(milliseconds: 800),
              tween: Tween(begin: 0.0, end: isVisible ? percentage / 100 : 0.0),
              curve: Curves.easeOut,
              builder: (context, value, child) => FractionallySizedBox(
                widthFactor: value,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [Color(0xFFF86E5B), Color(0xFF924136)]),
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [BoxShadow(color: Color(0xFFF86E5B).withOpacity(0.5), blurRadius: 6, spreadRadius: 0.5)],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ProjectsContent extends StatelessWidget {
  final bool isVisible;
  _ProjectsContent({required this.isVisible});
  @override
  Widget build(BuildContext context) {
    final isMobile = AppDesign.isMobile(context);
    final padding = AppDesign.responsivePadding(context);
    final titleSize = AppDesign.responsiveFontSize(context, AppDesign.displayL);
    return Container(
      decoration: BoxDecoration(color: Colors.black.withOpacity(0.45)),
      padding: EdgeInsets.symmetric(vertical: isMobile ? 50 : 70, horizontal: padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Projects',
              style: TextStyle(fontSize: titleSize, fontWeight: FontWeight.bold, color: Colors.white)),
          SizedBox(height: 4),
          Text('Where Innovation Meets Execution',
              style: TextStyle(color: Colors.grey[400], fontSize: AppDesign.bodyM)),
          SizedBox(height: 12),
          _AnimatedLine(width: isMobile ? 100 : 150),
          SizedBox(height: 30),
          ResponsiveLayout(
            mobile: Column(
              children: [
                _ProjectCard(title: 'Nike App Clone', description: 'Nike Clone – Clone Of The Official Nike Store', imageUrl: 'assets/images/1.png', tags: ['Flutter']),
                SizedBox(height: 20),
                _ProjectCard(title: 'Rivio', description: 'Track daily routines with charts & filters', imageUrl: 'assets/images/R2.png', tags: ['Flutter', 'Figma', 'Firebase']),
                SizedBox(height: 20),
                _ProjectCard(title: 'SnackSnap', description: 'Modern UI design exploration', imageUrl: 'assets/images/F1.png', tags: ['Figma']),
              ],
            ),
            desktop: GridView.count(
              crossAxisCount: 3,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              childAspectRatio: 0.85,
              children: [
                _ProjectCard(title: 'Nike App Clone', description: 'Nike Clone – Clone Of The Official Nike Store', imageUrl: 'assets/images/1.png', tags: ['Flutter']),
                _ProjectCard(title: 'Rivio', description: 'Track daily routines with charts & filters', imageUrl: 'assets/images/R2.png', tags: ['Flutter', 'Figma', 'Firebase']),
                _ProjectCard(title: 'SnackSnap', description: 'Modern UI design exploration', imageUrl: 'assets/images/F1.png', tags: ['Figma']),
              ],
            ),
          ),
          SizedBox(height: 40),
          Center(child: TextButton(onPressed: () {}, child: Text('See More', style: TextStyle(color: Colors.white70, fontSize: AppDesign.bodyS)))),
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
  _ProjectCard({required this.title, required this.description, required this.imageUrl, required this.tags});
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
        margin: EdgeInsets.only(top: _isHovered ? 0 : 4, bottom: _isHovered ? 4 : 0),
        transform: Matrix4.identity()..scale(_isHovered ? 1.02 : 1.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: _isHovered
              ? [BoxShadow(color: Color(0xFFF86E5B).withOpacity(0.35), blurRadius: 16, spreadRadius: 1, offset: Offset(0, 6))]
              : [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8, offset: Offset(0, 4))],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(color: Color(0xFF1A1F3A), border: Border.all(color: Color(0xFF2A2F4A), width: 1)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    margin: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Color(0xFF0A0E27),
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(image: AssetImage(widget.imageUrl), fit: BoxFit.cover),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(12, 0, 12, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.title,
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      SizedBox(height: 6),
                      Text(widget.description,
                          style: TextStyle(color: Colors.grey[400], fontSize: 13, height: 1.3),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                      SizedBox(height: 12),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: widget.tags
                            .map((tag) => Container(
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Color(0xFF0A0E27),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Color(0xFF2A2F4A), width: 1),
                          ),
                          child: Text(tag, style: TextStyle(color: Colors.white70, fontSize: 11)),
                        ))
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

class _ExperienceContent extends StatelessWidget {
  final bool isVisible;
  final bool showViewMoreButton;
  final VoidCallback onViewMorePressed;
  _ExperienceContent({required this.isVisible, required this.showViewMoreButton, required this.onViewMorePressed});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 80, vertical: 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Experience', style: TextStyle(fontSize: 56, fontWeight: FontWeight.bold, color: Colors.white)),
              SizedBox(width: 8),
              Text('& Journey', style: TextStyle(fontSize: 56, fontWeight: FontWeight.bold, color: Color(0xFFF86E5B))),
            ],
          ),
          SizedBox(height: 8),
          _AnimatedLine(width: 200),
          SizedBox(height: 50),
          Container(
            padding: EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Color(0xFF1A1F3A).withOpacity(0.8),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Color(0xFF2A2F4A), width: 1),
              boxShadow: [BoxShadow(color: Color(0xFFF86E5B).withOpacity(0.1), blurRadius: 20, spreadRadius: 2)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Flutter Developer Intern',
                            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                        SizedBox(height: 4),
                        Text('Luminar Technolab',
                            style: TextStyle(fontSize: 18, color: Color(0xFFF86E5B), fontWeight: FontWeight.w500)),
                      ],
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [Color(0xFFF86E5B), Color(0xFF924136)], begin: Alignment.centerLeft, end: Alignment.centerRight),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text('2025 - Present',
                          style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
                SizedBox(height: 25),
                Divider(color: Colors.white.withOpacity(0.2), height: 1),
                SizedBox(height: 25),
                Text('Reflection of what I\'ve been doing so far, so long.',
                    style: TextStyle(fontSize: 20, color: Colors.white.withOpacity(0.9), fontStyle: FontStyle.italic, height: 1.6)),
                SizedBox(height: 30),
                Text('As a Flutter Developer Intern at Luminar Technolab, I\'m actively involved in:',
                    style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.w500)),
                SizedBox(height: 20),
                Column(
                  children: [
                    _ExperienceBullet('Developing cross-platform mobile applications using Flutter framework'),
                    SizedBox(height: 12),
                    _ExperienceBullet('Collaborating with design teams to implement pixel-perfect UI/UX designs'),
                    SizedBox(height: 12),
                    _ExperienceBullet('Integrating REST APIs and managing state using Provider/GetX'),
                    SizedBox(height: 12),
                    _ExperienceBullet('Working with Firebase for authentication, database, and cloud functions'),
                    SizedBox(height: 12),
                    _ExperienceBullet('Participating in code reviews and following best development practices'),
                    SizedBox(height: 12),
                    _ExperienceBullet('Learning and implementing clean architecture patterns'),
                  ],
                ),
                SizedBox(height: 30),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _ExperienceSkillChip('Flutter'), _ExperienceSkillChip('Dart'),
                    _ExperienceSkillChip('Firebase'), _ExperienceSkillChip('REST API'),
                    _ExperienceSkillChip('Git'), _ExperienceSkillChip('Figma'),
                    _ExperienceSkillChip('Provider'), _ExperienceSkillChip('Clean Architecture'),
                  ],
                ),
              ],
            ),
          ),
          if (showViewMoreButton) ...[
            SizedBox(height: 50),
            Center(
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: onViewMorePressed,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Color(0xFFF86E5B), width: 2),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('View More Experiences',
                            style: TextStyle(fontSize: 18, color: Color(0xFFF86E5B), fontWeight: FontWeight.w500)),
                        SizedBox(width: 12),
                        Icon(Icons.arrow_downward, color: Color(0xFFF86E5B), size: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _AdditionalExperienceBullet extends StatelessWidget {
  final String text;
  _AdditionalExperienceBullet(this.text);
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
            margin: EdgeInsets.only(top: 6),
            width: 8,
            height: 8,
            decoration: BoxDecoration(shape: BoxShape.circle, color: Color(0xFFF86E5B))),
        SizedBox(width: 16),
        Expanded(child: Text(text, style: TextStyle(fontSize: 17, color: Colors.white.withOpacity(0.8), height: 1.5))),
      ],
    );
  }
}

class _ExperienceBullet extends StatelessWidget {
  final String text;
  _ExperienceBullet(this.text);
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
            margin: EdgeInsets.only(top: 6),
            width: 8,
            height: 8,
            decoration: BoxDecoration(shape: BoxShape.circle, color: Color(0xFFF86E5B))),
        SizedBox(width: 16),
        Expanded(child: Text(text, style: TextStyle(fontSize: 17, color: Colors.white.withOpacity(0.8), height: 1.5))),
      ],
    );
  }
}

class _ExperienceSkillChip extends StatelessWidget {
  final String skill;
  _ExperienceSkillChip(this.skill);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Color(0xFF0A0E27),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Color(0xFF2A2F4A), width: 1),
      ),
      child: Text(skill, style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500)),
    );
  }
}

class _ContactContent extends StatelessWidget {
  final TextEditingController nameCtrl;
  final TextEditingController emailCtrl;
  final TextEditingController msgCtrl;
  final VoidCallback onSubmit;

  _ContactContent({
    required this.nameCtrl,
    required this.emailCtrl,
    required this.msgCtrl,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildContactHeader(context),
          SizedBox(height: 40),
          _buildContactForm(context),
          SizedBox(height: 40),
          _buildSubmitButton(context),
          SizedBox(height: 40),
          _buildSocialLinks(context),
        ],
      ),
      desktop: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child: Padding(
              padding: EdgeInsets.only(right: 50.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildContactHeader(context),
                  SizedBox(height: 50),
                  _buildSubmitButton(context),
                  SizedBox(height: 60),
                  _buildSocialLinks(context),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding: EdgeInsets.only(left: 40, top: 32),
              child: _buildContactForm(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactHeader(BuildContext context) {
    final titleSize = AppDesign.responsiveFontSize(context, AppDesign.displayL);
    final headingSize = AppDesign.responsiveFontSize(context, AppDesign.displayM);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(width: 80, height: 4, color: AppDesign.primary, margin: EdgeInsets.only(right: 16)),
            Flexible(child: Text('Contacts', style: TextStyle(color: Colors.white, fontSize: titleSize, fontWeight: FontWeight.bold, letterSpacing: 1))),
          ],
        ),
        SizedBox(height: 50),
        Text("Have a project?", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: headingSize, letterSpacing: -1.5)),
        Text("Let's talk!", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: headingSize, letterSpacing: -1.5)),
      ],
    );
  }

  Widget _buildContactForm(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ContactField(label: "Name", controller: nameCtrl),
        SizedBox(height: 30),
        _ContactField(label: "Email", controller: emailCtrl),
        SizedBox(height: 30),
        _ContactField(label: "Message", controller: msgCtrl, maxLines: 4),
      ],
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return ElevatedButton(
      onPressed: onSubmit,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppDesign.primary,
        elevation: 0,
        padding: EdgeInsets.symmetric(horizontal: 56, vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
      ),
      child: Text("Submit",
          style: TextStyle(color: Colors.white, fontSize: AppDesign.bodyL, fontWeight: FontWeight.w500, letterSpacing: 0.5)),
    );
  }

  Widget _buildSocialLinks(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Connect With Me',
            style: TextStyle(color: Colors.white, fontSize: AppDesign.bodyL, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
        SizedBox(height: 20),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _SocialIcon(icon: Bootstrap.github, label: 'GitHub', url: 'https://github.com/RealSid45'),
            _SocialIcon(icon: Bootstrap.linkedin, label: 'LinkedIn', url: 'https://www.linkedin.com/in/sidharth-biju-414273310/'),
            _SocialIcon(icon: Bootstrap.microsoft, label: 'Outlook', url: 'mailto:sidhuxplore4@outlook.com'),
            _SocialIcon(icon: Bootstrap.dribbble, label: 'Dribbble', url: 'https://dribbble.com/'),
          ],
        ),
      ],
    );
  }
}

class _ContactField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final int maxLines;
  _ContactField({required this.label, required this.controller, this.maxLines = 1});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w400)),
        TextField(
          controller: controller,
          cursorColor: Colors.white,
          maxLines: maxLines,
          style: TextStyle(color: Colors.white, fontSize: 22),
          decoration: InputDecoration(
            border: InputBorder.none,
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white, width: 1.5)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white, width: 2)),
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
  _SocialIcon({required this.icon, required this.label, required this.url});
  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () async {
            final uri = Uri.parse(url);
            if (await canLaunchUrl(uri)) await launchUrl(uri);
          },
          child: Container(
            padding: EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
        ),
      ),
    );
  }
}

class _MobileNavItem extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  const _MobileNavItem(this.text, this.onTap);
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(text, style: TextStyle(color: Colors.white, fontSize: AppDesign.bodyM, fontWeight: FontWeight.w500)),
      trailing: Icon(Icons.arrow_forward_ios, color: AppDesign.primary, size: 16),
      onTap: onTap,
    );
  }
}