import { isObjectIdOrHexString } from "mongoose";
import { statuses } from "../_core/const/api.statuses";
import { TRequest, TResponse } from "../_core/interfaces/overrides.interface";
import GroomingApplication from "../models/grooming_application.schema";
import BookingSchedule from "../models/schedule.schema";
import Booking from "../models/booking.schema";
import Pet from "../models/pet.schema";
import { BookingServiceType, BookingStatus } from "../_core/enum/booking.enum";
import { findServiceFeeByTitle } from "../services/service_fee.service";
import { EventName, ActivityType } from "../_core/enum/activity.enum";
import { emitter } from "../_core/events/activity.event";
import { IActivity } from "../_core/interfaces/activity.interface";

export const createGroomingApplication = async (req: TRequest, res: TResponse) => {
    try {
        const { schedule: scheduleId, pet: petId } = req.body;
        if (!isObjectIdOrHexString(scheduleId) || !isObjectIdOrHexString(petId)) {
            return res.status(400).json(statuses["0901"]);
        }

        const schedule = await BookingSchedule.findById(scheduleId);
        if (!schedule) {
            return res.status(404).json(statuses["02"]);
        }

        const pet = await Pet.findOne({ user: req.user.id });
        if (!pet) {
            return res.status(404).json(statuses['99001']);
        }

        const newGroomingApplication = new GroomingApplication({ schedule });

        await newGroomingApplication.save();

        const serviceFee = await findServiceFeeByTitle(BookingServiceType.Grooming);

        const newBooking = new Booking({
            application: newGroomingApplication._id,
            applicationType: BookingServiceType.Grooming,
            user: req.user.id,
            pet: petId,
            status: BookingStatus.Pending,
            payable: serviceFee?.fee ?? 0
        })

        await newBooking.save();

        emitter.emit(EventName.ACTIVITY, {
            user: req.user.id as any,
            description: ActivityType.SERVICE_GROOMING_CREATED,
        } as IActivity);

        return res.status(200).json({
            referenceNo: newBooking._id,
            date: new Date()
        })
    } catch (error) {
        console.error('@createGroomingApplication', error);
        return res.status(500).json(statuses["0900"]);
    }
};