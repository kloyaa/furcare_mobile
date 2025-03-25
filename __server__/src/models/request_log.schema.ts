import mongoose, { Schema } from 'mongoose';
import { IRequestLog } from '../_core/interfaces/schema/schema.interface';

const requestLogSchema = new Schema<IRequestLog>({
  timestamp: {
    type: Date,
    required: true,
  },
  clientIp: {
    type: String,
    required: true,
  },
  requestMethod: {
    type: String,
    required: true,
  },
  requestUrl: {
    type: String,
    required: true,
  },
  userAgent: {
    type: String,
    required: true,
  },
  requestBody: {
    type: Object,
  },
  responseStatus: {
    type: Number,
    required: true,
  },
  responseStatusMessage: {
    type: String,
    required: true,
  },
  elapsed: {
    type: Number,
    required: true,
  },
});

const RequestLog = mongoose.model<IRequestLog>('RequestLog', requestLogSchema);

export default RequestLog;
