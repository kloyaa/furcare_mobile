import { Schema, model } from 'mongoose';
import { IBookingCage } from '../_core/interfaces/schema/schema.interface';

const cageSchema = new Schema<IBookingCage>(
  {
    title: {
      type: String,
      required: true,
    },
    price: {
      type: Number,
      required: true,
    },
  },
  { timestamps: true },
);

const Cage = model<IBookingCage>('Cage', cageSchema);

export default Cage;
