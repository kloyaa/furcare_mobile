import { Schema, model } from 'mongoose';
import { IBooking } from '../_core/interfaces/schema/schema.interface';
import { BookingServiceType, BookingStatus } from '../_core/enum/booking.enum';

const bookingSchema = new Schema<IBooking>(
  {
    user: {
      type: Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },
    staff: {
      type: Schema.Types.ObjectId,
      required: false,
    }, // Populate during edit or update status
    pet: {
      type: Schema.Types.ObjectId,
      ref: 'Pet',
      required: true,
    },
    extraServices: {
      type: [Schema.Types.ObjectId],
      ref: 'GroomingService',
      required: false,
    },
    branch: {
      type: Schema.Types.ObjectId,
      ref: 'Branch',
      required: true,
    },
    applicationType: {
      type: String,
      enum: Object.values(BookingServiceType),
      required: true,
    },
    application: {
      type: Schema.Types.ObjectId,
      required: true,
    },
    payable: {
      type: Number,
      required: true,
    },
    extension: {
      type: Number,
      required: false,
    },
    status: {
      type: String,
      enum: Object.values(BookingStatus),
      required: true,
    },
  },
  { timestamps: true },
);

const Booking = model<IBooking>('Booking', bookingSchema);

export default Booking;
