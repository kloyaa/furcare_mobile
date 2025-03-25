import { Aggregate, isObjectIdOrHexString } from "mongoose";
import { TRequest, TResponse } from "../_core/interfaces/overrides.interface";
import { type Response } from 'express';
import User from "../models/user.schema";
import Activity from "../models/activity.schema";
import { statuses } from "../_core/const/api.statuses";
import Profile from "../models/profile.schema";
import { findProfileByUser } from "../services/profile.service";
import { validateUpdateUserActiveStatus } from "../_core/validators/user.validator";
import BoardingApplication from "../models/boarding_application.schema";
import TransitApplication from "../models/transit_application.schema";
import GroomingApplication from "../models/grooming_application.schema";
import Booking from "../models/booking.schema";
import Upload from "../models/upload.schema";
import UserRole from "../models/user_role.schema";

export const getCustomers = async (req: TRequest, res: Response) => {
    try {
        const getCustomerDataAggregate: Aggregate<any[]> = User.aggregate([
            {
                $lookup: {
                    from: 'profiles',
                    localField: '_id',
                    foreignField: 'user',
                    as: 'profile'
                }
            },
            {
                $unwind: {
                    path: '$profile',
                    preserveNullAndEmptyArrays: true
                }
            },
            {
                $lookup: {
                    from: 'userroles',
                    localField: '_id',
                    foreignField: 'user',
                    as: 'userRole'
                }
            },
            {
                $unwind: {
                    path: '$userRole',
                    preserveNullAndEmptyArrays: true
                }
            },
            {
                $lookup: {
                    from: 'rolenames',
                    localField: 'userRole.role',
                    foreignField: '_id',
                    as: 'roleName'
                }
            },
            {
                $unwind: {
                    path: '$roleName',
                    preserveNullAndEmptyArrays: true
                }
            },
            {
                $match: {
                    'roleName.name': 'Customer'
                }
            },
            {
                $lookup: {
                    from: 'petowners',
                    localField: '_id',
                    foreignField: 'user',
                    as: 'owner'
                }
            },
            {
                $unwind: {
                    path: '$owner',
                    preserveNullAndEmptyArrays: true
                }
            },
            {
                $lookup: {
                    from: 'pets',
                    localField: '_id',
                    foreignField: 'user',
                    as: 'pets'
                }
            },
            {
                $project: {
                    __v: 0,
                    password: 0,
                    userRole: 0,
                    roleName: 0,
                    'profile.user': 0,
                    'profile.__v': 0,
                    'owner.user': 0,
                    'owner.__v': 0,
                    'pets.__v': 0,
                    'pets.user': 0
                }
            },
            {
                $match: {
                    profile: { $exists: true },
                    owner: { $exists: true }

                }
            }
        ]);

        const result = await getCustomerDataAggregate.exec();

        return res.status(200).json(result);
    } catch (error) {
        console.log('@getCustomers error', error);
        return res.status(500).json(statuses['0900']);
    }
}

export const getStaffs = async (req: TRequest, res: TResponse) => {
    try {
        const getCustomerDataAggregate: Aggregate<any[]> = User.aggregate([
            {
                $lookup: {
                    from: 'profiles',
                    localField: '_id',
                    foreignField: 'user',
                    as: 'profile'
                }
            },
            {
                $unwind: {
                    path: '$profile',
                    preserveNullAndEmptyArrays: true
                }
            },
            {
                $lookup: {
                    from: 'userroles',
                    localField: '_id',
                    foreignField: 'user',
                    as: 'userRole'
                }
            },
            {
                $unwind: {
                    path: '$userRole',
                    preserveNullAndEmptyArrays: true
                }
            },
            {
                $lookup: {
                    from: 'rolenames',
                    localField: 'userRole.role',
                    foreignField: '_id',
                    as: 'roleName'
                }
            },
            {
                $unwind: {
                    path: '$roleName',
                    preserveNullAndEmptyArrays: true
                }
            },
            {
                $match: {
                    'roleName.name': 'Staff'
                }
            },
            {
                $project: {
                    __v: 0,
                    password: 0,
                    userRole: 0,
                    roleName: 0,
                    'profile.user': 0,
                    'profile.__v': 0,
                }
            },
            {
                $match: {
                    profile: { $exists: true }
                }
            }
        ]);

        const result = await getCustomerDataAggregate.exec();

        return res.status(200).json(result);
    } catch (error) {
        console.log('@getStaffs error', error);
        return res.status(500).json(statuses['0900']);
    }
}

export const getCheckInStats = async (req: TRequest, res: TResponse) => {
    try {
        const currentYear = new Date().getFullYear();

        const checkInStats = await Activity.aggregate([
            {
                $match: {
                    description: 'Logged in successfully',
                    createdAt: {
                        $gte: new Date(`${currentYear}-01-01`), // Start of the current year
                        $lte: new Date(`${currentYear}-12-31`)  // End of the current year
                    }
                }
            },
            {
                $group: {
                    _id: { $month: '$createdAt' },
                    count: { $sum: 1 }
                }
            },
            {
                $project: {
                    _id: 0,
                    month: '$_id',
                    count: 1
                }
            }
        ]);

        // Manually generate the months array
        const months = [
            'January', 'February', 'March', 'April', 'May', 'June',
            'July', 'August', 'September', 'October', 'November', 'December'
        ];

        // Create an object to store the result
        const result: { [key: string]: number } = {};

        // Initialize counts for all months to 0
        for (const month of months) {
            result[month] = 0;
        }

        // Update counts for months where data is available
        for (const stat of checkInStats) {
            result[months[stat.month - 1]] = stat.count;
        }


        return res.status(200).json(Object.entries(result).map(([month, count]) => ({ [month.toLowerCase()]: count })));
    } catch (error) {
        console.log('@getCheckInStats error', error);
        return res.status(500).json(statuses['0900']);
    }
};

export const getSeriveUsageStats = async (req: TRequest, res: TResponse) => {
    try {
        const currentYear = new Date().getFullYear();
        const startDate = new Date(currentYear, 0, 1);
        const endDate = new Date(currentYear, 11, 31);

        const getAggregateResult = async (model: any) => {
            return await model.aggregate([
                {
                    $match: {
                        createdAt: {
                            $gte: startDate,
                            $lte: endDate
                        }
                    }
                },
                {
                    $group: {
                        _id: null,
                        total: { $sum: 1 }
                    }
                }
            ]);
        };

        const [boardingStats, transitStats, groomingStats] = await Promise.all([
            getAggregateResult(BoardingApplication),
            getAggregateResult(TransitApplication),
            getAggregateResult(GroomingApplication)
        ]);

        console.log({ boardingStats, transitStats, groomingStats })

        const formatResult = (stats: any[]) => {
            return stats.length > 0 ? stats[0].total : 0;
        };

        return res.status(200).json([
            { Grooming: formatResult(groomingStats) },
            { "Pick up and drop off": formatResult(transitStats) },
            { Boarding: formatResult(boardingStats) }
        ]);
    } catch (error) {
        console.error('@getSeriveUsageStats error', error);
        return res.status(500).json({ error: 'Internal Server Error' });
    }
};

export const updateUserActiveStatus = async (req: TRequest, res: Response) => {
    const error = validateUpdateUserActiveStatus(req.body);
    if (error) {
        return res.status(400).json({
            ...statuses['501'],
            message: error.details[0].message.replace(/['"]/g, ''),
        });
    }

    try {
        const { user: userId, isActive } = req.body;

        const profile = await findProfileByUser(userId)
        if (!profile) {
            return res.status(404).json(statuses['0104']);
        }

        await Profile.updateOne({ user: profile?.user }, { isActive });

        return res.status(200).json(statuses["00"]);
    } catch (error) {
        console.log('@getCheckInStats error', error);
        return res.status(500).json(statuses['0900']);
    }
}

export const removeUser = async (req: TRequest, res: Response) => {
    try {
        const user = req.params._id;

        if(!user) {
            return res.status(400).json(statuses["501"]);
        }
        if(!isObjectIdOrHexString(user)) {
            return res.status(400).json(statuses["0901"]);
        }

        await Promise.all([
            User.deleteMany({ _id: user }),
            Profile.deleteMany({ user }),
            Activity.deleteMany({ user }),
            Booking.deleteMany({ user }),
            Upload.deleteMany({ user }),
            UserRole.deleteMany({ user }),
        ]);

        return res.status(200).json(statuses["00"]);
    } catch (error) {
        console.log('@removeUser error', error);
        return res.status(500).json(statuses['0900']);
    }
}
