import 'package:storeus_delivery/core/helpers/apis/api_result.dart';
import 'package:storeus_delivery/features/drawer_features/reports/data/models/reports_models.dart';

abstract class ReportsRepoInterface {
  Future<ApiResult<ReportsData>> getOverview({
    required String from,
    required String to,
  });
}
