import { Schema, model } from 'mongoose';
import { IRoleName } from '../_core/interfaces/schema/schema.interface';

// Define the RoleName Schema
const roleNameSchema = new Schema<IRoleName>(
  {
    name: {
      type: String,
      required: true,
    },
  },
  { timestamps: true },
);

// Create the Activity model
const RoleName = model<IRoleName>('RoleName', roleNameSchema);

export default RoleName;
