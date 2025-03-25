import { Schema, model } from 'mongoose';
import { IUpload } from '../_core/interfaces/schema/schema.interface';
import { UploadContentScope, UploadContentType } from '../_core/enum/booking.enum';

const upload = new Schema<IUpload>(
    {
        user: {
            type: Schema.Types.ObjectId,
            ref: 'User',
            required: true,
        }, // Reference to the User model
        uploadData: {
            type: Schema.Types.Map,
            required: true,
        },
        uploadContentScope: {
            type: String,
            enum: Object.values(UploadContentScope),
            required: true,
        },
        uploadContentType: {
            type: String,
            enum: Object.values(UploadContentType),
            required: true,
        },
    },
    { timestamps: true },
);

const Upload = model<IUpload>('Upload', upload);

export default Upload;
