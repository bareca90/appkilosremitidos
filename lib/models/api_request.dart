class ApiRequest {
  final String option;

  ApiRequest({required this.option});

  Map<String, dynamic> toJson() => {'option': option};
}
