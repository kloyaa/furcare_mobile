export enum BookingStatus {
  Cancel = 'cancelled',
  Pending = 'pending',
  Confirmed = 'confirmed',
  Declined = 'declined',
  Done = 'done',
}

export enum BookingServiceType {
  Grooming = 'grooming',
  Boarding = 'boarding',
  Transit = 'transit'
}

export enum UploadContentType {
  Video = 'video',
  Image = 'image',
}

export enum UploadContentScope {
  Avatar = 'avatar',
  QRCode = 'qrcode',
}