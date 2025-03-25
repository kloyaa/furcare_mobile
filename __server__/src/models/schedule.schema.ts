import { Schema, model } from 'mongoose';
import { IBookingSchedule } from '../_core/interfaces/schema/schema.interface';

const bookingSchedulesSchema = new Schema<IBookingSchedule>(
  {
    title: {
      type: String,
      required: true,
    },
  },
  { timestamps: true },
);

const BookingSchedule = model<IBookingSchedule>('BookingSchedule', bookingSchedulesSchema);

export default BookingSchedule;
