import { Schema, model } from 'mongoose';
import { IRoleName, IUserRole } from '../_core/interfaces/schema/schema.interface';

// Define the RoleName Schema
const userRoleSchema = new Schema<IUserRole>(
  {
    user: {
      type: Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },
    role: {
      type: Schema.Types.ObjectId,
      ref: 'RoleName',
      required: true,
    },
  },
  { timestamps: true },
);

// Create the Activity model
const UserRole = model<IUserRole>('UserRole', userRoleSchema);

export default UserRole;
