import { TRequest, TResponse } from "../_core/interfaces/overrides.interface";
import { delay } from "../_core/utils/utils";
import Booking from "../models/booking.schema";
import GroomingApplication from "../models/grooming_application.schema";
import BookingSchedule from "../models/schedule.schema";

export const getSchedules = async (req: TRequest, res: TResponse) => {
    try {

        await delay(5);

        const groomingApplicationIds = await Booking
            .find({ status: { $in: ['confirmed'] } })
            .distinct('application');

        const groomingApplications = await GroomingApplication
            .find({ _id: { $in: groomingApplicationIds } })
            .distinct('schedule');;

        const bookingSchedules = await BookingSchedule
            .find({ _id: { $nin: groomingApplications } });

        return res.status(200).json(bookingSchedules);
    } catch (error) {
        console.error('@getSchedules error:', error);
        return res.status(500).json({ message: 'Internal server error' });
    }
};