import User from '../../models/user.schema';
import { statuses } from '../const/api.statuses';
import { TRequest } from '../interfaces/overrides.interface';
import { isEmpty } from '../utils/utils';

export const isValidUser = async (req: TRequest, res: any, next: any) => {
  try {
    if (isEmpty(req.user.id)) {
      return res.status(404).json(statuses['0056']);
    }
    const user = await User.findById(req.user.id);
    if (!user) {
      return res.status(404).json(statuses['0056']);
    }

    next();
  } catch (error) {
    return res.status(401).json(statuses['500']);
  }
};
