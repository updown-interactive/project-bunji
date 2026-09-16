/// Utility for extracting and formatting intelligent, concise conversation titles and snippets.
class ChatTitleHelper {
  ChatTitleHelper._();

  /// Creates a clean, intelligent 2-4 word conversation title from user text.
  /// Never returns generic "New Chat".
  static String createIntelligentTitle(String text) {
    var cleaned = text.replaceAll(RegExp(r'[\r\n]+'), ' ').trim();
    if (cleaned.isEmpty) return 'Image Conversation';

    // Remove greetings like "Hello Bunji", "Hi", etc.
    final greetingPattern = RegExp(
      r'^(hello bunji|hi bunji|hey bunji|hello|hi|hey)[!,.]*\s*',
      caseSensitive: false,
    );
    cleaned = cleaned.replaceFirst(greetingPattern, '').trim();

    // Remove common question and prompt prefixes
    final fillerPattern = RegExp(
      r'^(can you please |could you please |please |can you |could you |tell me about |tell me |explain to me |explain how |explain |what is |what are |who is |how do i |how does |how to |how |help me with |summarize |i want to know about |write a |give me )+',
      caseSensitive: false,
    );
    cleaned = cleaned.replaceFirst(fillerPattern, '').trim();

    // Remove leading/trailing non-alphanumeric punctuation
    cleaned = cleaned.replaceAll(RegExp(r'^[^\w]+|[^\w]+$'), '').trim();
    if (cleaned.isEmpty) return 'Conversation';

    // Split words
    final words =
        cleaned.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    if (words.isEmpty) return 'Conversation';

    // Take at most 4 salient words
    final titleWords = words.take(4).map((w) {
      if (w.length <= 1) return w.toUpperCase();
      return '${w[0].toUpperCase()}${w.substring(1)}';
    }).toList();

    return titleWords.join(' ');
  }

  /// Extracts the body snippet for chat cards: max 20 words of the AI response.
  /// Strips reasoning `<think>` blocks and markdown formatting.
  static String? extractAiSnippet(String? text, {int maxWords = 20}) {
    if (text == null) return null;

    // Strip reasoning <think> tags if present
    final thinkRegex =
        RegExp(r'<think>[\s\S]*?(?:<\/think>|$)', caseSensitive: false);
    var cleaned = text.replaceAll(thinkRegex, '').trim();
    if (cleaned.isEmpty) return null;

    // Strip markdown formatting characters (headers, bold, asterisks, backticks, blockquotes)
    cleaned = cleaned
        .replaceAll(RegExp(r'[#*_`~>]+'), ' ')
        .replaceAll(RegExp(r'[\r\n]+'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    final words =
        cleaned.split(' ').where((w) => w.isNotEmpty).toList();
    if (words.isEmpty) return null;

    if (words.length <= maxWords) {
      return words.join(' ');
    }
    return '${words.take(maxWords).join(' ')}...';
  }
}
