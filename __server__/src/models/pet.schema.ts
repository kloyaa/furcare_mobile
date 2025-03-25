import { Schema, model } from 'mongoose';
import { IPet } from '../_core/interfaces/schema/schema.interface';

const petSchema = new Schema<IPet>(
  {
    user: {
      type: Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    }, // Reference to the User model
    name: {
      type: String,
      required: true,
    },
    age: {
      type: Number,
      required: true,
    },
    gender: {
      type: String,
      required: true,
    },
    breed: {
      type: String,
      required: true,
    },
  },
  { timestamps: true },
);

const Pet = model<IPet>('Pet', petSchema);

export default Pet;
