import { Schema, model } from 'mongoose';
import { IPetOwner } from '../_core/interfaces/schema/schema.interface';

const petOwnerSchema = new Schema<IPetOwner>(
  {
    user: {
      type: Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },
    name: {
      type: String,
      required: true,
    },
    address: {
      type: String,
      required: true,
    },
    mobileNo: {
      type: String,
      required: true,
    },
    email: {
      type: String,
      required: true,
    },
    emergencyContactNo: {
      type: String,
      required: true,
    },
    work: {
      type: String,
      required: true,
    },
  },
  { timestamps: true },
);

const PetOwner = model<IPetOwner>('PetOwner', petOwnerSchema);

export default PetOwner;
