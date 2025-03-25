import { Types } from 'mongoose';
import { findProfileByUser } from '../../services/profile.service';
import { statuses } from '../const/api.statuses';
import { TRequest } from '../interfaces/overrides.interface';
import { isEmpty } from '../utils/utils';

export const isProfileCreated = async (req: TRequest, res: any, next: any) => {
  try {
    if (isEmpty(req.user.id)) {
      return res.status(404).json(statuses['0056']);
    }
    const profile = await findProfileByUser(req.user.id as any);
    if (!profile) {
      return res.status(404).json(statuses['0104']);
    }

    next();
  } catch (error) {
    return res.status(401).json(statuses['500']);
  }
};
