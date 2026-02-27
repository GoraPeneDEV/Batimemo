class ApiResponseModel {
  int? statusCode;
  String? status;
  bool? success;
  dynamic data;

  ApiResponseModel({this.statusCode, this.status, this.success, this.data});

  ApiResponseModel.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    status = json['status'];
    success = json['success'] ??
        (json['status'] == true ||
         json['status'] == 'true' ||
         json['status'] == 'success');
    data = json['data'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> result = <String, dynamic>{};
    result['statusCode'] = statusCode;
    result['status'] = status;
    result['success'] = success;
    result['data'] = data;
    return result;
  }
}
