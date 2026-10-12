import 'package:storeus_delivery/core/helpers/apis/api_result.dart';
import 'package:storeus_delivery/features/drawer_features/top_rank/data/models/top_rank_response.dart';
import 'package:storeus_delivery/features/drawer_features/top_rank/domain/repo/top_rank_repo_interface.dart';

class GetTopRankUsecase {
  const GetTopRankUsecase(this._repository);

  final TopRankRepoInterface _repository;

  Future<ApiResult<TopRankResponse>> call({
    required String range,
    String? category,
    String? entity,
  }) {
    return _repository.getTopRank(
      range: range,
      category: category,
      entity: entity,
    );
  }
}
