import { Schema, model } from 'mongoose';
import { IBoardingApplication } from '../_core/interfaces/schema/schema.interface';

const boardingApplication = new Schema<IBoardingApplication>(
  {
    schedule: {
      type: Date,
      required: true,
    },
    daysOfStay: {
      type: Number,
      required: true,
    },
    cage: {
      type: Schema.Types.ObjectId,
      ref: 'Cage',
      required: true,
    },
  },
  { timestamps: true },
);

const BoardingApplication = model<IBoardingApplication>('BoardingApplication', boardingApplication);

export default BoardingApplication;
