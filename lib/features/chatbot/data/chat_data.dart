class ChatData {
  static final List<String> suggestionChips = [
    "How to add a project?",
    "Track expenses",
    "Export reports",
    "Delete a project",
    "Contact Support",
  ];

  static final Map<String, String> botResponses = {
    // Exact match keys (for chips)
    "How to add a project?":
        "To add a new project:\n1. Go to the Home Screen.\n2. Tap the '+' (New Project) button at the bottom.\n3. Fill in the Project Name, Budget, and Dates.\n4. Tap 'Create Project'.",

    "Track expenses":
        "You can track expenses inside a project:\n1. Tap on any project card.\n2. You'll see the 'Materials' list.\n3. Tap '+' to add a new material or expense.\n4. It will automatically deduct from your budget.",

    "Export reports":
        "Currently, you can view the 'Financial Summary' by tapping the 'Project Insights' card on the Home Screen. PDF export features are coming soon in the next update! 📄",

    "Delete a project":
        "To delete a project:\n1. Long press on the project card in the Home Screen.\n2. Or tap the 'Trash' icon if available on the card.\n3. Confirm the deletion. Note: This action cannot be undone!",

    "Contact Support":
        "You can reach our support team at:\n📧 support@constructionapp.com\n📞 +91 98765 43210",

    // Default fallback
    "default":
        " didn't understand that. Try tapping one of the suggestions below! 👇",
  };

  static String getResponse(String query) {
    // Simple normalization
    final key = botResponses.keys.firstWhere(
      (k) => k.toLowerCase() == query.trim().toLowerCase(),
      orElse: () => "default",
    );
    return botResponses[key]!;
  }
}
