
import 'package:storeus_delivery/core/helpers/apis/api_result.dart';
import 'package:storeus_delivery/features/notifications/data/models/notifications_response.dart';
import 'package:storeus_delivery/features/notifications/domain/repo/notifications_repo_interface.dart';

class GetNotificationsUsecase {
  final NotificationsRepoInterface _repo;

  GetNotificationsUsecase(this._repo);

  Future<ApiResult<NotificationsResponse>> call() {
    return _repo.getNotifications();
  }
}
