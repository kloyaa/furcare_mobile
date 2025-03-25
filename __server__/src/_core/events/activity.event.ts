import EventEmitter from 'eventemitter3';
import { EventName } from '../enum/activity.enum';
import { IActivity } from '../interfaces/activity.interface';
import Activity from '../../models/activity.schema';
import RequestLog from '../../models/request_log.schema';
import { IRequestLog } from '../interfaces/schema/schema.interface';

// Create an EventEmitter instance
export const emitter = new EventEmitter();

// Event listener for 'login-activity' event
emitter.on(EventName.ACTIVITY, async (payload: IActivity) => {
  try {
    // Create a new Activity document
    const newActivity = new Activity({
      user: payload.user,
      description: payload.description,
    } as IActivity);

    // Save the new activity log to the database
    await newActivity.save();
  } catch (error) {
    console.error(`@${EventName.ACTIVITY} error`, error);
  }
});

// Event listener for 'network-activity' event
emitter.on(EventName.NETWORK_ACTIVITY, async (payload: IRequestLog) => {
  const {
    clientIp,
    requestMethod,
    requestUrl,
    userAgent,
    requestBody,
    responseStatus,
    responseStatusMessage,
    elapsed,
  } = payload;
  try {
    // Create a new RequestLog document
    const requestLog = new RequestLog({
      timestamp: new Date(),
      clientIp,
      requestMethod,
      requestUrl,
      userAgent,
      requestBody,
      responseStatus,
      responseStatusMessage,
      elapsed,
    });
    // Save the new activity log to the database
    await requestLog.save();
  } catch (error) {
    console.error(`@${EventName.NETWORK_ACTIVITY} error`, error);
  }
});
