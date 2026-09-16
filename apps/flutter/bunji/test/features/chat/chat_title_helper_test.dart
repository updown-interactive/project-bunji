import 'package:bunji/features/chat/chat.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ChatTitleHelper Tests', () {
    test('createIntelligentTitle strips greetings and question prefixes', () {
      expect(
        ChatTitleHelper.createIntelligentTitle('Hello Bunji! Tell me about Australia.'),
        'Australia',
      );
      expect(
        ChatTitleHelper.createIntelligentTitle('Can you please explain how quantum computing works?'),
        'Quantum Computing Works',
      );
      expect(
        ChatTitleHelper.createIntelligentTitle('what is machine learning'),
        'Machine Learning',
      );
      expect(
        ChatTitleHelper.createIntelligentTitle(''),
        'Image Conversation',
      );
    });

    test('createIntelligentTitle limits title length to 4 words', () {
      final title = ChatTitleHelper.createIntelligentTitle(
        'recommend top tourist destinations for holiday season travel',
      );
      expect(title.split(' ').length, lessThanOrEqualTo(4));
    });

    test('extractAiSnippet limits to first max 20 words and strips reasoning think tags', () {
      const responseWithThink =
          '<think>Analyzing the user query about local AI</think>'
          'Bunji is a privacy-first personal AI companion that runs directly on your device without sending any data to the cloud.';

      final snippet = ChatTitleHelper.extractAiSnippet(responseWithThink, maxWords: 20);
      expect(snippet, isNotNull);
      expect(snippet, isNot(contains('<think>')));
      expect(snippet, isNot(contains('Analyzing the user query')));
      expect(snippet!.startsWith('Bunji is a privacy-first'), isTrue);

      // Verify word count is at most 20 words (plus trailing ellipsis if truncated)
      final words = snippet.replaceAll('...', '').split(' ').where((w) => w.isNotEmpty).toList();
      expect(words.length, lessThanOrEqualTo(20));
    });

    test('extractAiSnippet strips markdown formatting', () {
      const markdownResponse = '### Key Points\n**1. Fast:** Instant.\n**2. Private:** On device.';
      final snippet = ChatTitleHelper.extractAiSnippet(markdownResponse, maxWords: 20);
      expect(snippet, isNotNull);
      expect(snippet, isNot(contains('###')));
      expect(snippet, isNot(contains('**')));
      expect(snippet, 'Key Points 1. Fast: Instant. 2. Private: On device.');
    });
  });
}
