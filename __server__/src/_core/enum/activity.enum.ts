export enum EventName {
  ACTIVITY = 'user-activity',
  NETWORK_ACTIVITY = 'network-activity',
}

export enum ActivityType {
  LOGIN = 'Logged in successfully',
  CHANGE_PASSWORD = 'Changed password successfully',
  REGISTRATION_SUCCESS = 'Registered successfully',
  EKYC_SUCCESS = 'EKYC completed',
  SEED_USER_ACCOUNT = 'Seeded user account successfully',
  PROFILE_CREATED = 'Profile created',
  PROFILE_UPDATED = 'Profile updated',

  PET_REMOVED = 'Pet removed',
  PET_ADDED = 'Pet added',
  PET_UPDATED = 'Pet updated',

  PET_OWNER_REMOVED = 'Pet Owner removed',
  PET_OWNER_ADDED = 'Pet Owner profile created',
  PET_OWNER_UPDATED = 'Pet Owner profile updated',

  BOOKING_CREATED = 'Booking created',
  BOOKING_UPDATED = 'Your booking was recently updated',
  BOOKING_DECLINED = 'Your booking was declined',
  BOOKING_COMPLETED = 'Your booking was completed',
  BOOKING_ACCEPTED = 'Your booking was accepted',
  BOOKING_CANCELLED = 'Your booking was cancelled',

  SERVICE_GROOMING_COMPLETED = 'Grooming application completed',
  SERVICE_TRANSIT_COMPLETED = 'Transit application completed',
  SERVICE_BOARDING_COMPLETED = 'Boarding application completed',

  SERVICE_GROOMING_CREATED = 'Grooming application successful',
  SERVICE_TRANSIT_CREATED = 'Home Service application successful',
  SERVICE_BOARDING_CREATED = 'Boarding application successful',

  UPLOAD_IMAGE_SUCCESSFUL = 'Image uploaded',
  UPLOAD_VIDEO_SUCCESSFUL = 'Video uploaded',
}
