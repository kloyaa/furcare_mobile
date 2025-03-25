import { findRoleByUser } from '../../services/role.service';
import { statuses } from '../const/api.statuses';
import { TRequest } from '../interfaces/overrides.interface';
import { isEmpty } from '../utils/utils';

export const isStaff = async (req: TRequest, res: any, next: any) => {
  try {
    if(isEmpty(req.user.id)) {
        return res.status(404).json(statuses['0056']);
    }
    const role = await findRoleByUser(req.user.id);
    if(role !== "Staff") {
        return res.status(404).json(statuses['0057']);
    }
    next();
  } catch (error) {
    return res.status(401).json(statuses['500']);
  }
};
