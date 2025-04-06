class UpdateActiveStatus {
  final bool isActive;
  final String user;

  UpdateActiveStatus({required this.isActive, required this.user});

  Map<String, dynamic> toJson() {
    return {'isActive': isActive, 'user': user};
  }
}
