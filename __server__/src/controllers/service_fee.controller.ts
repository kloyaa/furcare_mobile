import { statuses } from "../_core/const/api.statuses";
import { TRequest } from "../_core/interfaces/overrides.interface";
import { type Response } from 'express';
import ServiceFee from "../models/service_fee.schema";
import GroomingService from "../models/grooming_service.schema";

export const getServiceFees = async (req: TRequest, res: Response) => {
    console.log('req.query', req.query);
    try {
        let query = {};
        if (req.query.title) {
            query = {
                title: req.query.title
            }
        }
        const serviceFees = await ServiceFee.find(query);

        return res.status(200).json(serviceFees);
    } catch (error) {
        console.log('@getServiceFees error', error);
        return res.status(500).json(statuses['0900']);
    }
}

export const getGroomingServiceFees = async (req: TRequest, res: Response) => {
    try {
        let query = {};
        if (req.query.title) {
            query = {
                title: req.query.title
            }
        }
        const serviceFees = await GroomingService.find(query);

        return res.status(200).json(serviceFees);
    } catch (error) {
        console.log('@getGroomingServiceFees error', error);
        return res.status(500).json(statuses['0900']);
    }
}
export const updateServiceFeeById = async (req: TRequest, res: Response) => {
    const { _id } = req.params;
    const { fee, title } = req.body;

    try {
        const existingServiceFee = await ServiceFee.findById(_id);
        if (!existingServiceFee) {
            return res.status(404).json(statuses["02"]);
        }

        existingServiceFee.fee = fee || existingServiceFee.fee;
        existingServiceFee.title = title || existingServiceFee.title;

        await existingServiceFee.save();

        return res.status(200).json(statuses["00"]);
    } catch (error) {
        console.log('@updateServiceFeeById error', error);
        return res.status(500).json(statuses['0900']);
    }
};