import { Schema, model } from 'mongoose';
import { IServiceFee } from '../_core/interfaces/schema/schema.interface';

const groomingServiceSchema = new Schema<IServiceFee>(
  {
    title: {
      type: String,
      required: true,
    },
    fee: {
      type: Number,
      required: true,
    },
  },
  { timestamps: true },
);

const GroomingService = model<IServiceFee>('GroomingService', groomingServiceSchema);

export default GroomingService;
