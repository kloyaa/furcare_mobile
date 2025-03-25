import { NextFunction, Response } from 'express';
import { statuses } from '../const/api.statuses';

export const checkUserOrigin = (req: any, res: Response, next: NextFunction) => {
  const from = req.headers['from'];
  if (from === 'mobile' || from === 'web') {
    req.from = from;
    next();
  } else {
    return res.status(403).json(statuses['0059']);
  }
};
