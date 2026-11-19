import 'package:flutter/material.dart';
import '../design_system.dart';
import '../widgets/responsive_layout.dart';
import '../widgets/social_icon.dart';
import '../data/portfolio_data.dart';

class ContactSection extends StatelessWidget {
  final bool isVisible;
  final TextEditingController nameCtrl;
  final TextEditingController emailCtrl;
  final TextEditingController msgCtrl;
  final VoidCallback onSubmit;

  const ContactSection({
    Key? key,
    required this.isVisible,
    required this.nameCtrl,
    required this.emailCtrl,
    required this.msgCtrl,
    required this.onSubmit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final padding = AppDesign.responsivePadding(context);
    return AnimatedOpacity(
      duration: AppDesign.mediumDuration,
      opacity: isVisible ? 1.0 : 0.0,
      curve: AppDesign.defaultCurve,
      child: AnimatedContainer(
        duration: AppDesign.mediumDuration,
        curve: AppDesign.defaultCurve,
        transform: Matrix4.translationValues(0, isVisible ? 0 : 20, 0),
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          vertical: AppDesign.isMobile(context) ? 60 : 90,
          horizontal: padding,
        ),
        child: ResponsiveLayout(
          mobile: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildContactHeader(context),
              const SizedBox(height: 40),
              _buildContactForm(),
              const SizedBox(height: 40),
              _buildSubmitButton(),
              const SizedBox(height: 40),
              _buildSocialLinks(context),
            ],
          ),
          desktop: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.only(right: 50.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildContactHeader(context),
                      const SizedBox(height: 50),
                      _buildSubmitButton(),
                      const SizedBox(height: 60),
                      _buildSocialLinks(context),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.only(left: 40, top: 32),
                  child: _buildContactForm(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactHeader(BuildContext context) {
    final titleSize = AppDesign.responsiveFontSize(context, AppDesign.displayL);
    final headingSize =
        AppDesign.responsiveFontSize(context, AppDesign.displayM);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
                width: 80,
                height: 4,
                color: AppDesign.primary,
                margin: const EdgeInsets.only(right: 16)),
            Flexible(
                child: Text('Contacts',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: titleSize,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1))),
          ],
        ),
        const SizedBox(height: 50),
        Text("Have a project?",
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: headingSize,
                letterSpacing: -1.5)),
        Text("Let's talk!",
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: headingSize,
                letterSpacing: -1.5)),
      ],
    );
  }

  Widget _buildContactForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ContactField(label: "Name", controller: nameCtrl),
        const SizedBox(height: 30),
        _ContactField(label: "Email", controller: emailCtrl),
        const SizedBox(height: 30),
        _ContactField(label: "Message", controller: msgCtrl, maxLines: 4),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: onSubmit,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppDesign.primary,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 56, vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
      ),
      child: const Text("Submit",
          style: TextStyle(
              color: Colors.white,
              fontSize: AppDesign.bodyL,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5)),
    );
  }

  Widget _buildSocialLinks(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Connect With Me',
            style: TextStyle(
                color: Colors.white,
                fontSize: AppDesign.bodyL,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5)),
        const SizedBox(height: 20),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: PortfolioData.contactSocials
              .map((social) => SocialIcon(social: social, isHome: false))
              .toList(),
        ),
      ],
    );
  }
}

class _ContactField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final int maxLines;

  const _ContactField(
      {required this.label, required this.controller, this.maxLines = 1});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w400)),
        TextField(
          controller: controller,
          cursorColor: Colors.white,
          maxLines: maxLines,
          style: const TextStyle(color: Colors.white, fontSize: 22),
          decoration: const InputDecoration(
            border: InputBorder.none,
            enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white, width: 1.5)),
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white, width: 2)),
            isDense: true,
            contentPadding: EdgeInsets.symmetric(vertical: 8),
          ),
        ),
      ],
    );
  }
}
