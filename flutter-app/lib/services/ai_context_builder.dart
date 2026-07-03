import 'package:intl/intl.dart';
import 'package:genui/genui.dart' hide TextPart;
import 'package:read_the_label/models/user_profile.dart';

class AiContextBuilder {
  static String buildSystemPrompt({
    UserProfile? profile,
    String? mealScanContext,
    String? locale,
  }) {
    final now = DateTime.now();
    final formattedDate = DateFormat('EEEE, MMMM d, yyyy').format(now);
    final formattedTime = DateFormat('h:mm a').format(now);

    final buffer = StringBuffer();
    buffer.writeln('You are a professional nutrition and health AI companion inside the "Read The Label" app.');
    buffer.writeln('Your role is to help users scan product labels, understand nutrition facts, plan healthy eating, track goals, and log meals.');
    buffer.writeln();

    buffer.writeln('## Context & Environment:');
    buffer.writeln('- Current Date: $formattedDate');
    buffer.writeln('- Current Time: $formattedTime');
    if (locale != null) {
      buffer.writeln('- User Locale: $locale');
    }
    if (profile?.country != null) {
      buffer.writeln('- User Country: ${profile!.country}');
    }
    buffer.writeln();

    buffer.writeln('## User Profile (If available):');
    if (profile != null && profile.isOnboardingComplete) {
      if (profile.dietaryPreference != null) {
        buffer.writeln('- Dietary Preference: ${profile.dietaryPreference}');
      }
      if (profile.weightKg != null) {
        buffer.writeln('- Weight: ${profile.weightKg!.toStringAsFixed(1)} kg');
      }
      if (profile.heightFeet != null && profile.heightInches != null) {
        buffer.writeln('- Height: ${profile.heightFeet} ft ${profile.heightInches} in');
      }
      if (profile.bmi != null) {
        buffer.writeln('- BMI: ${profile.bmi!.toStringAsFixed(1)} (${profile.bmiCategory ?? "Normal"})');
      }
      if (profile.goal != null) {
        buffer.writeln('- Health/Fitness Goal: ${profile.goal}');
      }
      if (profile.healthConditions.isNotEmpty) {
        final conditions = profile.healthConditions.map((c) => c.name).join(', ');
        buffer.writeln('- Diagnosed Health Conditions: $conditions');
      }
    } else {
      buffer.writeln('No user profile registered or onboarding is incomplete. Do not assume any pre-existing health conditions or goals.');
    }
    buffer.writeln();

    if (mealScanContext != null && mealScanContext.isNotEmpty) {
      buffer.writeln('## Active Context (Opened via Meal Scan):');
      buffer.writeln('The user opened this chat directly after scanning a food item/label. Here are the scanned meal details:');
      buffer.writeln(mealScanContext);
      buffer.writeln('Address this scanned meal directly at the start of your response, offering analysis or help to log it.');
      buffer.writeln();
    }

    buffer.writeln('## Logging Confirmation Flow Rules:');
    buffer.writeln('1. When the user indicates they ate/had something:');
    buffer.writeln('   - Always ask confirmation before logging. Provide a clear confirmation card or form.');
    buffer.writeln('   - Allow date and time selection. Pre-populate it if date and time was mentioned by the user.');
    buffer.writeln('   - Once confirmed, show a confirmation that it has been logged/added.');
    buffer.writeln('2. If the user does not specify date and time, ask for confirmation and pre-populate the selection to the current date and time.');
    buffer.writeln();

    buffer.writeln('## Guidelines:');
    buffer.writeln('- Be encouraging, empathetic, and scientifically accurate.');
    buffer.writeln('- Utilize the provided tools where appropriate to fulfill user requests.');
    buffer.writeln('- Present structured, visually engaging information. When displaying nutritional breakdowns or weekly trends, make sure to request rendering of visual charts (weeklyBarChart or macroPieChart).');

    return buffer.toString();
  }

  static String buildSystemPromptWrapped({
    required Catalog catalog,
    UserProfile? profile,
    String? mealScanContext,
    String? locale,
  }) {
    final instructions = buildSystemPrompt(
      profile: profile,
      mealScanContext: mealScanContext,
      locale: locale,
    );
    final promptBuilder = PromptBuilder.chat(
      catalog: catalog,
      systemPromptFragments: [instructions],
    );
    return promptBuilder.systemPromptJoined();
  }
}
