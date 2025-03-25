import mongoose, { Aggregate } from "mongoose";
import UserRole from "../models/user_role.schema";

export const findRoleByUser = async (user: string): Promise<string | null> => {
    try {
        const roleNameAggregate: Aggregate<any[]> = UserRole.aggregate([
            {
                $match: { user: new mongoose.Types.ObjectId(user) }
            },
            {
                $lookup: {
                    from: 'rolenames',
                    localField: 'role',
                    foreignField: '_id',
                    as: 'role'
                }
            },
            {
                $unwind: '$role'
            },
            {
                $project: {
                    roleName: '$role.name'
                }
            }
        ]);
        const result: { roleName: string }[] = await roleNameAggregate.exec();

        if (result.length === 0) {
            return null;
        }
        return result[0].roleName;
    } catch (error) {
        return null;
    }
};