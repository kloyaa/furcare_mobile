import { getEnv } from "../_core/config/env.config";
import { statuses } from "../_core/const/api.statuses";
import { TRequest, TResponse } from "../_core/interfaces/overrides.interface";
import Booking from "../models/booking.schema";
import Cage from "../models/cage.schema";
import { findCageLimitByTitle } from "../services/cage.service";

export const getCages = async (req: TRequest, res: TResponse) => {
    try {
        const boardingApplicationsWithBookingCount = await Booking.aggregate([
            { $match: { status: { $in: ['confirmed'] } } },
            {
                $lookup: {
                    from: 'boardingapplications',
                    localField: 'application',
                    foreignField: '_id',
                    as: 'boardingapplications'
                }
            },
            { $unwind: '$boardingapplications' },
            {
                $lookup: {
                    from: 'cages',
                    localField: 'boardingapplications.cage',
                    foreignField: '_id',
                    as: 'boardingapplications.cage'
                }
            },
            {
                $group: {
                    _id: '$_id',
                    user: { $first: '$user' },
                    pet: { $first: '$pet' },
                    applicationType: { $first: '$applicationType' },
                    application: { $first: '$application' },
                    payable: { $first: '$payable' },
                    status: { $first: '$status' },
                    createdAt: { $first: '$createdAt' },
                    updatedAt: { $first: '$updatedAt' },
                    __v: { $first: '$__v' },
                    boardingapplications: { $push: '$boardingapplications' }
                }
            }
        ]);

        const cageCounts: { [cageId: string]: number } = {};
        boardingApplicationsWithBookingCount.forEach(booking => {
            booking.boardingapplications.forEach((boardingApp: any) => {
                const cageId = boardingApp.cage[0]._id.toString();
                cageCounts[cageId] = (cageCounts[cageId] || 0) + 1;
            });
        });

        const cages = await Cage.find();
        const result = cages.map((cage) => ({
            _id: cage._id,
            title: cage.title,
            price: cage.price,
            used: cageCounts[cage._id.toString()] || 0,
            limit: findCageLimitByTitle(cage.title),
            available: Number((cageCounts[cage._id.toString()] || 0)) < Number(findCageLimitByTitle(cage.title))
        }));

        return res.status(200).json(result);
    } catch (error) {
        console.error('@getCages', error);
        return res.status(500).json(statuses["0900"]);
    }
};