class SubtitlesDataUiModel {
  bool? status;
  List<Result>? results;
  List<Subtitle>? subtitles;

  SubtitlesDataUiModel({
    this.status,
    this.results,
    this.subtitles,
  });

  factory SubtitlesDataUiModel.fromJson(Map<String, dynamic> json) =>
      SubtitlesDataUiModel(
        status: json["status"],
        results: json["results"] == null
            ? []
            : List<Result>.from(
                json["results"]!.map((x) => Result.fromJson(x))),
        subtitles: json["subtitles"] == null
            ? []
            : List<Subtitle>.from(
                json["subtitles"]!.map((x) => Subtitle.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "results": results == null
            ? []
            : List<dynamic>.from(results!.map((x) => x.toJson())),
        "subtitles": subtitles == null
            ? []
            : List<dynamic>.from(subtitles!.map((x) => x.toJson())),
      };
}

class Result {
  int? sdId;
  String? type;
  String? name;
  String? imdbId;
  int? tmdbId;
  DateTime? firstAirDate;
  String? slug;
  DateTime? releaseDate;
  int? year;

  Result({
    this.sdId,
    this.type,
    this.name,
    this.imdbId,
    this.tmdbId,
    this.firstAirDate,
    this.slug,
    this.releaseDate,
    this.year,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        sdId: json["sd_id"],
        type: json["type"],
        name: json["name"],
        imdbId: json["imdb_id"],
        tmdbId: json["tmdb_id"],
        firstAirDate: json["first_air_date"] == null
            ? null
            : DateTime.parse(json["first_air_date"]),
        slug: json["slug"],
        releaseDate: json["release_date"] == null
            ? null
            : DateTime.parse(json["release_date"]),
        year: json["year"],
      );

  Map<String, dynamic> toJson() => {
        "sd_id": sdId,
        "type": type,
        "name": name,
        "imdb_id": imdbId,
        "tmdb_id": tmdbId,
        "first_air_date": firstAirDate?.toIso8601String(),
        "slug": slug,
        "release_date": releaseDate?.toIso8601String(),
        "year": year,
      };
}

class Subtitle {
  String? releaseName;
  String? name;
  Lang? lang;
  String? author;
  String? url;
  String? subtitlePage;
  int? season;
  int? episode;
  Language? language;
  bool? hi;
  String? comment;
  List<String>? releases;

  Subtitle({
    this.releaseName,
    this.name,
    this.lang,
    this.author,
    this.url,
    this.subtitlePage,
    this.season,
    this.episode,
    this.language,
    this.hi,
    this.comment,
    this.releases,
  });

  factory Subtitle.fromJson(Map<String, dynamic> json) => Subtitle(
        releaseName: json["release_name"],
        name: json["name"],
        lang: langValues.map[json["lang"]],
        author: json["author"],
        url: json["url"],
        subtitlePage: json["subtitlePage"],
        season: json["season"],
        episode: json["episode"],
        language: languageValues.map[json["language"]],
        hi: json["hi"],
        comment: json["comment"],
        releases: json["releases"] == null
            ? []
            : List<String>.from(json["releases"]!.map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "release_name": releaseName,
        "name": name,
        "lang": langValues.reverse[lang],
        "author": author,
        "url": url,
        "subtitlePage": subtitlePage,
        "season": season,
        "episode": episode,
        "language": languageValues.reverse[language],
        "hi": hi,
        "comment": comment,
        "releases":
            releases == null ? [] : List<dynamic>.from(releases!.map((x) => x)),
      };
}

enum Lang { ENGLISH }

final langValues = EnumValues({"english": Lang.ENGLISH});

enum Language { EN }

final languageValues = EnumValues({"EN": Language.EN});

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
