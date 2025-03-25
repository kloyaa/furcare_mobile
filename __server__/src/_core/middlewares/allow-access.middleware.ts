import { NextFunction, type Response, type Request } from 'express';
import { isEmpty } from '../utils/utils';
import { statuses } from '../const/api.statuses';
import { getEnv } from '../config/env.config';

export const allowApiAccessMiddleware = async (req: Request, res: Response, next: NextFunction) => {
  const accessKey = req.headers['nodex-access-key'];
  const secretKey = req.headers['nodex-secret-key'];
  const userOrigin = req.headers['nodex-user-origin'];

  if (isEmpty(accessKey) || isEmpty(secretKey) || isEmpty(userOrigin)) {
    return res.status(403).json(statuses['0060']);
  }

  const env = await getEnv();
  if (accessKey?.toString().trim() === env.NODEX_ACCESS_KEY && secretKey?.toString().trim() === env.NODEX_SECRET_KEY) {
    next();
  } else {
    return res.status(403).json(statuses['0070']);
  }
};
