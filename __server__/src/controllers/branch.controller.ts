import { statuses } from "../_core/const/api.statuses";
import Branch from "../models/branch.schema";

export const getBranches = async (req: any, res: any) => {
    try {
        const branches = await Branch.find();
        return res.status(200).json(branches);
    } catch (error) {
        console.log('@getBranches error', error);
        return res.status(500).json(statuses['0900']);
    }
};