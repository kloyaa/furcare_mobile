import { Schema, model } from 'mongoose';
import { IServiceFee } from '../_core/interfaces/schema/schema.interface';

const serviceFeeSchema = new Schema<IServiceFee>(
  {
    fee: {
      type: Number,
      default: 0,
      required: true,
    }, // Reference to the User model
    title: {
      type: String,
      required: true,
    },
  },
  { timestamps: true },
);

// Create the Activity model
const ServiceFee = model<IServiceFee>('ServiceFee', serviceFeeSchema);

export default ServiceFee;
