import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waqoodi_client/bloc/stations/stations_event.dart';
import 'package:waqoodi_client/repository/statios_repo.dart';

import '../../models/stations_model.dart';
import '../../repository/internet_conncection.dart';
import '../general_states.dart';

class StationsBloc extends Bloc<StationsEvents, GeneralStates> {
  StationsBloc() : super(InitialState());
  @override
  Stream<GeneralStates> mapEventToState(
    StationsEvents event,
  ) async* {
      if (event is GetStationsEvent) {
        if(await InternetConnection().isConnected()) {
          yield LoadingState(showDialog: false);
          print('sssss');

          StationsModel? stationsModel = await StationsRepo().allStations();
          print('sssss');
          if(stationsModel != null){
            if(stationsModel.message != null){
              yield ErrorState(msg: stationsModel.message??'Something Went Wrong!',);
            }else if(stationsModel.data != null && stationsModel.success!){
              yield SuccessState(response: stationsModel.data, showDialog: false);
            }else{
              yield ErrorState(msg: stationsModel.message??'Something Went Wrong!',);
            }
          }else{
            yield ErrorState(msg: 'Something Went Wrong!',);
          }
        }else{
          yield NoInternetState();
        }
      }else if (event is InitialEvent) {
        yield InitialState();
      }
  }
  GeneralStates get initialState => InitialState();
}