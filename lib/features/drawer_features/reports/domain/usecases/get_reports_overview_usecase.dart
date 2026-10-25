import 'package:storeus_delivery/core/helpers/apis/api_result.dart';
import 'package:storeus_delivery/features/drawer_features/reports/data/models/reports_models.dart';
import 'package:storeus_delivery/features/drawer_features/reports/domain/repo/reports_repo_interface.dart';

class GetReportsOverviewUsecase {
  const GetReportsOverviewUsecase(this._repository);

  final ReportsRepoInterface _repository;

  Future<ApiResult<ReportsData>> call({
    required String from,
    required String to,
  }) => _repository.getOverview(from: from, to: to);
}
