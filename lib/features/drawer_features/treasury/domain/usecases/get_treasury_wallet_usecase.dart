import 'package:storeus_delivery/core/helpers/apis/api_result.dart';
import 'package:storeus_delivery/features/drawer_features/treasury/data/models/treasury_wallet_response.dart';
import 'package:storeus_delivery/features/drawer_features/treasury/domain/repo/treasury_wallet_repo_interface.dart';

class GetTreasuryWalletUsecase {
  const GetTreasuryWalletUsecase(this._repo);

  final TreasuryWalletRepoInterface _repo;

  Future<ApiResult<TreasuryWalletResponse>> call({required int tripId}) =>
      _repo.getWallet(tripId: tripId);
}
