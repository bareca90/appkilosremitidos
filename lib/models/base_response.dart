class BaseResponse<T> {
  final int code;
  final T data;
  final String message;

  BaseResponse({required this.code, required this.data, required this.message});

  factory BaseResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) fromJsonT,
  ) {
    return BaseResponse(
      code: json['code'],
      data: fromJsonT(json['data']),
      message: json['message'],
    );
  }
}
