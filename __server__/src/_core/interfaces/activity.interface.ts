import { Types } from 'mongoose';

export interface IActivity {
  user: Types.ObjectId;
  description: string;
}
