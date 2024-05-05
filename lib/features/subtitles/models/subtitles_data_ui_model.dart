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
  dynamic firstAirDate;
  dynamic year;

  Result({
    this.sdId,
    this.type,
    this.name,
    this.imdbId,
    this.tmdbId,
    this.firstAirDate,
    this.year,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        sdId: json["sd_id"],
        type: json["type"],
        name: json["name"],
        imdbId: json["imdb_id"],
        tmdbId: json["tmdb_id"],
        firstAirDate: json["first_air_date"],
        year: json["year"],
      );

  Map<String, dynamic> toJson() => {
        "sd_id": sdId,
        "type": type,
        "name": name,
        "imdb_id": imdbId,
        "tmdb_id": tmdbId,
        "first_air_date": firstAirDate,
        "year": year,
      };
}

class Subtitle {
  String? releaseName;
  String? name;
  String? lang;
  String? author;
  String? url;
  int? season;
  int? episode;

  Subtitle({
    this.releaseName,
    this.name,
    this.lang,
    this.author,
    this.url,
    this.season,
    this.episode,
  });

  factory Subtitle.fromJson(Map<String, dynamic> json) => Subtitle(
        releaseName: json["release_name"],
        name: json["name"],
        lang: json["lang"],
        author: json["author"],
        url: json["url"],
        season: json["season"],
        episode: json["episode"],
      );

  Map<String, dynamic> toJson() => {
        "release_name": releaseName,
        "name": name,
        "lang": lang,
        "author": author,
        "url": url,
        "season": season,
        "episode": episode,
      };
}
