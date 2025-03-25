// request-logger.middleware.ts

import { type Request, type Response, type NextFunction } from 'express';
import { emitter } from '../events/activity.event';
import { EventName } from '../enum/activity.enum';
import { IRequestLog } from '../interfaces/schema/schema.interface';

export const requestLoggerMiddleware = async (req: Request, res: Response, next: NextFunction) => {
  const start = Date.now();

  // Get client IP address from headers (use a more accurate method if needed)
  const clientIp = req.headers['x-forwarded-for'] || req.socket.remoteAddress;

  const timestamp = new Date().toISOString();
  const requestMethod = req.method;
  const requestUrl = req.url;
  const userAgent = req.headers['user-agent'];

  // Capture response data
  let responseStatus: number;
  let responseStatusMessage: string;

  // Create a function to handle response data capture
  const captureResponseData = () => {
    const elapsed = Date.now() - start;
    responseStatus = res.statusCode || 500;
    responseStatusMessage = res.statusMessage || 'Unknown';

    // Emit the event with request and response data
    emitter.emit(EventName.NETWORK_ACTIVITY, {
      clientIp,
      timestamp,
      requestMethod,
      requestUrl,
      userAgent,
      requestBody: req.body,
      responseStatus,
      responseStatusMessage,
      elapsed,
    } as unknown as IRequestLog);
  };

  // Continue processing the request
  next();

  // Hook into the response's finish event to capture the response status
  res.on('finish', captureResponseData);

  // // Hook into the response's close event to capture the response status if it ends abruptly
  // res.on('close', captureResponseData);
};
