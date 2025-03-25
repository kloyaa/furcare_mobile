import { Schema, model } from 'mongoose';
import { IActivity } from '../_core/interfaces/activity.interface';

// Define the Activity Schema
const activitySchema = new Schema<IActivity>(
  {
    user: {
      type: Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    }, // Reference to the User model
    description: {
      type: String,
      required: true,
    },
  },
  { timestamps: true },
);

// Create the Activity model
const Activity = model<IActivity>('Activity', activitySchema);

export default Activity;
