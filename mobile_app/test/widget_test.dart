import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:dfm_korba_official/presentation/widgets/neumorphic_card.dart';
import 'package:dfm_korba_official/presentation/widgets/neumorphic_button.dart';
import 'package:dfm_korba_official/presentation/widgets/notice_bar.dart';
import 'package:dfm_korba_official/presentation/providers/language_provider.dart';
import 'package:dfm_korba_official/presentation/screens/role_selection_screen.dart';

void main() {
  testWidgets('NeuCard renders with correct dimensional properties', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: NeuCard(
            child: Text('Test Card Content'),
          ),
        ),
      ),
    );

    expect(find.text('Test Card Content'), findsOneWidget);
  });

  testWidgets('NeuButton handles press and renders text', (WidgetTester tester) async {
    bool pressed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NeuButton(
            label: 'Submit Test',
            onPressed: () {
              pressed = true;
            },
          ),
        ),
      ),
    );

    expect(find.text('Submit Test'), findsOneWidget);
    await tester.tap(find.byType(NeuButton));
    await tester.pumpAndSettle();
    expect(pressed, isTrue);
  });

  testWidgets('NoticeBar displays title and category icon', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: NoticeBar(
            title: 'Drone Shoot Due Tomorrow',
            category: 'COMMON_TASK_NOTICE',
          ),
        ),
      ),
    );

    expect(find.text('Drone Shoot Due Tomorrow'), findsOneWidget);
    expect(find.text('Task Alert'), findsOneWidget);
  });

  testWidgets('RoleSelectionScreen displays all 4 user roles', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ],
        child: const MaterialApp(
          home: RoleSelectionScreen(),
        ),
      ),
    );

    expect(find.text('Welcome to'), findsOneWidget);
    expect(find.text('DFM Korba'), findsOneWidget);
    expect(find.text('Choose Your Role'), findsOneWidget);
    expect(find.text('Student'), findsOneWidget);
    expect(find.text('Teacher'), findsOneWidget);
    expect(find.text('Team'), findsOneWidget);
    expect(find.text('Admin'), findsOneWidget);
  });
}
