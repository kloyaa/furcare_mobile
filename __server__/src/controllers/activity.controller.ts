import { statuses } from "../_core/const/api.statuses";
import { TRequest, TResponse } from "../_core/interfaces/overrides.interface";
import Activity from "../models/activity.schema";

export const getActivitiesByAccessToken = async (req: TRequest, res: TResponse) => {
    try {
        const activities = await Activity.find({ user: req.user.id }).sort({
            'createdAt': -1
        });
        return res.status(200).json(activities);
    } catch (error) {
        console.log('@getActivitiesByAccessToken error', error);
        return res.status(500).json(statuses['0900']);
    }
};