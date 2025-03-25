import { Schema, model } from 'mongoose';
import { IGroomingApplication } from '../_core/interfaces/schema/schema.interface';

const groomingApplication = new Schema<IGroomingApplication>(
  {
    schedule: {
      type: Schema.Types.ObjectId,
      ref: 'BookingSchedule',
      required: true,
    },
  },
  { timestamps: true },
);

const GroomingApplication = model<IGroomingApplication>('GroomingApplication', groomingApplication);

export default GroomingApplication;
