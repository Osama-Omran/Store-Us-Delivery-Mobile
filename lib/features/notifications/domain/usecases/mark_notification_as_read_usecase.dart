
import 'package:storeus_delivery/core/helpers/apis/api_result.dart';
import 'package:storeus_delivery/features/notifications/domain/repo/notifications_repo_interface.dart';

class MarkNotificationAsReadUsecase {
  final NotificationsRepoInterface _repo;

  MarkNotificationAsReadUsecase(this._repo);

  Future<ApiResult<dynamic>> call({
    required int notificationId,
  }) {
    return _repo.markAsRead(
      notificationId: notificationId,
    );
  }
}
