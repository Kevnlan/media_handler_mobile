import 'media_model.dart';

class PaginationResponse<T> {
  final int count;
  final String? next;
  final String? previous;
  final List<T> results;

  PaginationResponse({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory PaginationResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return PaginationResponse(
      count: json['count'] ?? 0,
      next: json['next'],
      previous: json['previous'],
      results:
          (json['results'] as List<dynamic>?)
              ?.map((item) => fromJsonT(item as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  bool get hasNext => next != null;
  bool get hasPrevious => previous != null;
}

class MediaFilters {
  final MediaType? type;
  final String? search;
  final String? collectionId;
  final bool? isDeleted;

  MediaFilters({this.type, this.search, this.collectionId, this.isDeleted});

  Map<String, dynamic> toQueryParams() {
    final params = <String, dynamic>{};

    if (type != null) params['type'] = type!.value;
    if (search != null && search!.isNotEmpty) params['search'] = search;
    if (collectionId != null) params['collection'] = collectionId;
    if (isDeleted != null) params['is_deleted'] = isDeleted.toString();

    return params;
  }
}
