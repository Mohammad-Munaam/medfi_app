import 'package:flutter/material.dart';
import '../models/ambulance_request.dart';

class RequestProvider extends ChangeNotifier {
  AmbulanceRequest? currentRequest;

  void createRequest(AmbulanceRequest request) {
    currentRequest = request;
    notifyListeners();
  }

  void updateStatus(String status) {
    if (currentRequest != null) {
      currentRequest = AmbulanceRequest(
        id: currentRequest!.id,
        userId: currentRequest!.userId,
        name: currentRequest!.name,
        phone: currentRequest!.phone,
        location: currentRequest!.location,
        status: status,
      );
      notifyListeners();
    }
  }
}
