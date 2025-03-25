import { TRequest, TResponse } from "../_core/interfaces/overrides.interface";
import { isEmpty } from "../_core/utils/utils";
import { statuses } from "../_core/const/api.statuses";
import { uploadImage } from "../services/upload/image_upload.service";
import { validateUploadImages } from "../_core/validators/application.validator";
import { emitter } from "../_core/events/activity.event";
import { ActivityType, EventName } from "../_core/enum/activity.enum";
import { IActivity } from "../_core/interfaces/activity.interface";
import { UploadContentType } from "../_core/enum/booking.enum";
import Upload from "../models/upload.schema";

export const uploadImages = async (req: TRequest, res: TResponse) => {
    const error = validateUploadImages(req.body);
    if (error) {
        return res.status(400).json({
            ...statuses['501'],
            message: error.details[0].message.replace(/['"]/g, ''),
        });
    }

    try {
        const files = req.files;
        const { uploadContentScope, uploadContentType } = req.body;
        if (isEmpty(files?.length)) {
            return res.status(400).json(statuses["0900"]);
        }

        const uploadedImages = await uploadImage(files, uploadContentScope);

        if (Array.isArray(uploadedImages)) {
            const _mappedUploadedImages = uploadedImages.map((el) => {
                return {
                    user: req.user.id,
                    uploadContentScope,
                    uploadContentType,
                    uploadData: el,
                }
            });

            const _uploadedImages = await Upload.insertMany(_mappedUploadedImages);

            emitter.emit(EventName.ACTIVITY, {
                user: req.user.id as any,
                description: uploadContentType === UploadContentType.Image
                    ? ActivityType.UPLOAD_IMAGE_SUCCESSFUL
                    : ActivityType.UPLOAD_VIDEO_SUCCESSFUL,
            } as IActivity);

            return res.status(200).json(_uploadedImages);
        }

        const upload = new Upload({
            user: req.user.id,
            uploadContentScope,
            uploadContentType,
            uploadData: uploadedImages,
        });

        await upload.save();

        emitter.emit(EventName.ACTIVITY, {
            user: req.user.id as any,
            description: uploadContentType === UploadContentType.Image
                ? ActivityType.UPLOAD_IMAGE_SUCCESSFUL
                : ActivityType.UPLOAD_VIDEO_SUCCESSFUL,
        } as IActivity);

        return res.status(200).json(upload);
    } catch (error) {
        console.log(error)
    }
}