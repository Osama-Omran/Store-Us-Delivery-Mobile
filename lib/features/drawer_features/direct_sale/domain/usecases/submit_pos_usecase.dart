import 'package:storeus_delivery/core/helpers/apis/api_result.dart';
import '../../data/models/submit_pos_request_body.dart';
import '../repo/submit_pos_repo_interface.dart';

class SubmitPosUsecase {
  const SubmitPosUsecase(this._repo);
  final SubmitPosRepoInterface _repo;

  Future<ApiResult<SubmitPosResponse>> call(
    int tripId,
    SubmitPosRequestBody request,
  ) => _repo.submitPos(tripId, request);
}
