import { Schema, model } from 'mongoose';
import { IServiceTransaction } from '../_core/interfaces/schema/schema.interface';

const serviceTransactionSchema = new Schema<IServiceTransaction>(
    {
        staff: {
            type: Schema.Types.ObjectId,
            ref: 'User',
            required: true,
        },
        customer: {
            type: Schema.Types.ObjectId,
            ref: 'User',
            required: true,
        },
        pet: {
            type: Schema.Types.ObjectId,
            ref: 'Pet',
            required: true,
        },
        service: {
            type: Schema.Types.ObjectId,
            ref: 'ServiceFee',
            required: true,
        },
        date: {
            type: Date,
            default: Date.now(),
        },
        feedback: {
            type: String,
            required: false,
        },
        payment: {
            type: Number,
            required: true,
        },
    },
    { timestamps: true },
);

// Create the Activity model
const ServiceTransaction = model<IServiceTransaction>('serviceTransaction', serviceTransactionSchema);

export default ServiceTransaction;
