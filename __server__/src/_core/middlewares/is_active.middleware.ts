import Profile from '../../models/profile.schema';
import { statuses } from '../const/api.statuses';
import { TRequest } from '../interfaces/overrides.interface';
import { isEmpty } from '../utils/utils';

export const isActive = async (req: TRequest, res: any, next: any) => {
  try {
    if(isEmpty(req.user.id)) {
        return res.status(404).json(statuses['0056']);
    }
    const profile = await Profile.findById(req.user.id);
    console.log(profile)
    if (profile) {
        if (!profile.isActive) {
            return res.status(404).json(statuses['0058']);
        }
    }

    next();
  } catch (error) {
    console.log(error)
    return res.status(401).json(statuses['500']);
  }
};
