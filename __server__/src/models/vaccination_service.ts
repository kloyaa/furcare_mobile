import { Schema, model } from 'mongoose';
import { IServiceFee } from '../_core/interfaces/schema/schema.interface';

const vaccinationServiceSchema = new Schema<IServiceFee>(
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

const VaccinationService = model<IServiceFee>('VaccinationService', vaccinationServiceSchema);

export default VaccinationService;
