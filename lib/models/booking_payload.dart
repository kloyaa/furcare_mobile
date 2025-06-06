class BoardingPayload {
  final String cage;
  final String branch;
  final String pet;
  final String schedule;
  final int daysOfStay;

  BoardingPayload({
    required this.cage,
    required this.branch,
    required this.pet,
    required this.schedule,
    required this.daysOfStay,
  });

  Map<String, dynamic> toJson() {
    return {
      'branch': branch,
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
  final String branch;
  final List<String> services; // Add this field

  GroomingPayload({
    required this.pet,
    required this.schedule,
    required this.branch,
    this.services = const [], // Default to empty list
  });

  Map<String, dynamic> toJson() {
    return {
      'pet': pet,
      'schedule': schedule,
      'branch': branch,
      'services': services, // Include in JSON payload
    };
  }
}

class TransitgPayload {
  final String pet;
  final String schedule;
  final String branch;

  TransitgPayload({
    required this.pet,
    required this.branch,
    required this.schedule,
  });

  Map<String, dynamic> toJson() {
    return {'pet': pet, 'schedule': schedule, 'branch': branch};
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

class BoardingExtensionPayload {
  final String booking;
  final int days;

  BoardingExtensionPayload({required this.booking, required this.days});

  Map<String, dynamic> toJson() {
    return {'booking': booking, 'days': days};
  }
}
