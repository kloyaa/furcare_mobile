import { Schema, model } from 'mongoose';
import { ITransitApplication } from '../_core/interfaces/schema/schema.interface';

const transitApplication = new Schema<ITransitApplication>(
  {
    schedule: {
      type: Date,
      required: true,
    },
  },
  { timestamps: true },
);

const TransitApplication = model<ITransitApplication>('TransitApplication', transitApplication);

export default TransitApplication;
