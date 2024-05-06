import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_rank/global_providers.dart';

final dataSourceDecisionMakerProvider = Provider<DataSourceDecisionMaker>(
    (ref) => DataSourceDecisionMaker(ref.read(connectivityProvider)));

class DataSourceDecisionMaker {
  final Connectivity _connection;

  DataSourceDecisionMaker(this._connection);

  Future<bool> isNetworkSuitableDataSource() async {
    final currentConnectionResult = await _connection.checkConnectivity();
    return currentConnectionResult.contains(ConnectivityResult.wifi) ||
        currentConnectionResult.contains(ConnectivityResult.mobile) ||
        currentConnectionResult.contains(ConnectivityResult.ethernet);
  }
}
