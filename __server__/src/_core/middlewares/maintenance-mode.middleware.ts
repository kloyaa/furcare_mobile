import { getEnv } from '../config/env.config';
import { statuses } from '../const/api.statuses';

export const maintenanceModeMiddleware = async (_: any, res: any, next: any) => {
  const env = await getEnv();
  if (env?.ENVIRONMENT_MAINTENANCE === 'true') {
    return res.status(500).json(statuses['500']);
  }
  next();
};
