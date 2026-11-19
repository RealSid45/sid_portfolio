# Portfolio Evaluation & Refinement Plan

This plan outlines the evaluation of the `sid_portfolio` project from a senior tester/developer perspective and proposes specific refactorings to improve maintainability, testability, and robustness without altering the aesthetic "coolness" of the site.

## User Review Required

> [!IMPORTANT]
> The proposed changes are architectural. While the website will look identical to users, the code structure will change significantly to follow Flutter best practices.
> I will be moving widgets out of `main.dart` into a organized directory structure.

## Open Questions
- Do you have a preferred state management solution if the app grows beyond `StatefulWidget` (e.g., BLoC, Riverpod)? For now, I'll stick to `StatefulWidget` to minimize disruption but organized better.

## Proposed Changes

### 1. Data Layer & Configuration
- **[NEW] [portfolio_data.dart](file:///C:/Users/sidhu/AndroidStudioProjects/sid_portfolio/lib/data/portfolio_data.dart)**: Centralized class for all hardcoded strings, project info, and URLs.
- **[NEW] [app_assets.dart](file:///C:/Users/sidhu/AndroidStudioProjects/sid_portfolio/lib/constants/app_assets.dart)**: Constants for all image and asset paths.

### 2. Widget Refactoring (Decomposition)
- **[MODIFY] [main.dart](file:///C:/Users/sidhu/AndroidStudioProjects/sid_portfolio/lib/main.dart)**: Simplify to only contain the app shell and navigation logic.
- **[NEW] [sections/](file:///C:/Users/sidhu/AndroidStudioProjects/sid_portfolio/lib/sections/)**: New directory for top-level page sections.
    - `hero_section.dart`
    - `about_section.dart`
    - `projects_section.dart`
    - `experience_section.dart`
    - `contact_section.dart`
- **[NEW] [widgets/](file:///C:/Users/sidhu/AndroidStudioProjects/sid_portfolio/lib/widgets/)**: Move reusable components here.
    - `nav_button.dart`
    - `skill_chip.dart`
    - `project_card.dart`
    - `gradient_button.dart`

### 3. Robustness & Error Handling
- **[MODIFY] [main.dart](file:///C:/Users/sidhu/AndroidStudioProjects/sid_portfolio/lib/main.dart)**: Improve Supabase initialization feedback. If config is missing, show a non-intrusive warning or disable the form with a tooltip explanation.

### 4. Testing
- **[MODIFY] [widget_test.dart](file:///C:/Users/sidhu/AndroidStudioProjects/sid_portfolio/test/widget_test.dart)**: Replace boilerplate with a test that verifies the presence of key sections (Home, About, Projects).

---

## Verification Plan

### Automated Tests
- Run `flutter test` to ensure the new widget test passes.
- Perform a build check: `flutter build web --dart-define=SUPABASE_URL=test --dart-define=SUPABASE_ANON_KEY=test`.

### Manual Verification
- Verify responsiveness across different screen sizes using the IDE's Flutter Inspector.
- Ensure all hover animations and scroll-to-section behaviors remain intact.
- Check that the "Show More" experience logic still works as expected.
