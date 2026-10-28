import 'package:storeus_delivery/core/helpers/apis/api_result.dart';
import '../../data/models/submit_pos_request_body.dart';

abstract class SubmitPosRepoInterface {
  Future<ApiResult<SubmitPosResponse>> submitPos(
    int tripId,
    SubmitPosRequestBody request,
  );
}
