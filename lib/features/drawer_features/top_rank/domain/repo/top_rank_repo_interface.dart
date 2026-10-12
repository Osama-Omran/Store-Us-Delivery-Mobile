import 'package:storeus_delivery/core/helpers/apis/api_result.dart';
import 'package:storeus_delivery/features/drawer_features/top_rank/data/models/top_rank_response.dart';

abstract class TopRankRepoInterface {
  Future<ApiResult<TopRankResponse>> getTopRank({
    required String range,
    String? category,
    String? entity,
  });
}
