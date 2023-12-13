// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_word_rm.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DailyWordRM _$DailyWordRMFromJson(Map<String, dynamic> json) => DailyWordRM(
      word: json['word'] as String,
      definition: json['definition'] as String,
      snippet: WordSnippetRM.fromJson(json['snippet'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      objectId: json['objectId'] as String,
    );

WordSnippetRM _$WordSnippetRMFromJson(Map<String, dynamic> json) =>
    WordSnippetRM(
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      audioUrl: json['audioUrl'] as String,
      content: json['content'] as String,
      objectId: json['objectId'] as String,
      words: (json['words'] as List<dynamic>).map((e) => e as String).toList(),
      dubbingCount: json['dubbingCount'] as int,
      snippetId: json['snippetId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      imageUrl: json['imageUrl'] as String,
      level: json['level'] as int,
      author: json['author'] as String,
      movieName: json['movieName'] as String,
      videoUrl: json['videoUrl'] as String,
      videoStart: json['videoStart'] as int,
    );
