import 'package:storeus_delivery/core/helpers/apis/api_result.dart';
import 'package:storeus_delivery/features/drawer_features/treasury/data/models/treasury_wallet_response.dart';

abstract class TreasuryWalletRepoInterface {
  Future<ApiResult<TreasuryWalletResponse>> getWallet({required int tripId});
}
