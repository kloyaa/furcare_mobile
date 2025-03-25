require("dotenv").config();
import { v2 } from "cloudinary";
import multer from "multer";
import fs from "fs";

v2.config({
  cloud_name: process.env.CLOUDINARY_NAME,
  api_key: process.env.CLOUDINARY_KEY,
  api_secret: process.env.CLOUDINARY_SECRET,
});

export const fileFilter = (req: any, file: any, callback: any) => {
  if (
    file.mimetype === "image/png" ||
    file.mimetype === "image/jpg" ||
    file.mimetype === "image/jpeg" ||
    file.mimetype === "video/mp4") {
    callback(null, true);
  } else callback(null, false);
};

export const storage = multer.diskStorage({});

export const uploadImage = async (files: any, scope: string = "temp") => {
  const cloudOptions = {
    folder: `Public/${process.env.CLOUDINARY_PROJECT_NAME}}/${scope}/uploads`,
    unique_filename: true,
  };
  const urls = [];

  if (files?.length > 1) {
    for (const file of files) {
        const { path } = file;
        const upload = await v2.uploader.upload(path, cloudOptions);
        urls.push(upload);
        fs.unlinkSync(path);
    }
    return urls;
  }

  for (const file of files) {
    const { path } = file;
    const upload = await v2.uploader.upload(path, cloudOptions);
    urls.push(upload);
    fs.unlinkSync(path);
    break;
  }

  return urls[0];
}