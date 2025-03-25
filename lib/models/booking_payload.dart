class BoardingPayload {
  final String cage;
  final String pet;
  final String schedule;
  final int daysOfStay;

  BoardingPayload({
    required this.cage,
    required this.pet,
    required this.schedule,
    required this.daysOfStay,
  });

  Map<String, dynamic> toJson() {
    return {
      'cage': cage,
      'pet': pet,
      'schedule': schedule,
      'daysOfStay': daysOfStay,
    };
  }
}

class GroomingPayload {
  final String pet;
  final String schedule;

  GroomingPayload({required this.pet, required this.schedule});

  Map<String, dynamic> toJson() {
    return {'pet': pet, 'schedule': schedule};
  }
}

class TransitgPayload {
  final String pet;
  final String schedule;

  TransitgPayload({required this.pet, required this.schedule});

  Map<String, dynamic> toJson() {
    return {'pet': pet, 'schedule': schedule};
  }
}

class UpdateBookingStatusPayload {
  final String status;
  final String booking;

  UpdateBookingStatusPayload({required this.status, required this.booking});

  Map<String, dynamic> toJson() {
    return {'status': status, 'booking': booking};
  }
}
