import { Schema, model } from 'mongoose';
import { IBranch } from '../_core/interfaces/branch.interface';

const branchSchema = new Schema<IBranch>(
    {
        name: {
            type: String,
            required: true,
        },
        address: {
            type: String,
            required: true,
        },
        isActive: {
            type: Boolean,
            default: true,
        },
        mobileNo: {
            type: String,
            required: true,
        }
    },
    { timestamps: true },
);

const Branch = model<IBranch>('Branch', branchSchema);

export default Branch;
