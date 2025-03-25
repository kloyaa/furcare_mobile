import { Schema, model } from 'mongoose';
import { IUser } from '../_core/interfaces/schema/schema.interface';

const userSchema = new Schema<IUser>(
  {
    username: {
      type: String,
      required: true,
      unique: true,
      trim: true,
    },
    email: {
      type: String,
      required: true,
      unique: true,
      trim: true,
    },
    password: {
      type: String,
      required: true,
    },
  },
  { timestamps: true },
);

const User = model<IUser>('User', userSchema);

export default User;
