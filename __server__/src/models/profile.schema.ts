import { Schema, model } from 'mongoose';
import { IProfile } from '../_core/interfaces/schema/schema.interface';

const profileSchema = new Schema<IProfile>(
  {
    user: {
      type: Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },
    fullName: {
      type: String,
      required: true,
    },
    address: {
      type: String,
      required: true,
    },
    contact: {
      email: {
        type: String,
        required: true,
      },
      number: {
        type: String,
        required: true,
      },
    },
    facebook: {
      type: String,
      required: true
    },
    messenger: {
      type: String,
      required: true
    },
    isActive: {
      type: Boolean,
      default: false
    }
  },
  { timestamps: true },
);

const Profile = model<IProfile>('Profile', profileSchema);

export default Profile;
