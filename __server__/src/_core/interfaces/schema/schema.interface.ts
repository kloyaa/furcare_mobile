import { Types } from 'mongoose';
import { BookingServiceType, BookingStatus, UploadContentScope, UploadContentType } from '../../enum/booking.enum';
import { ICloudinaryImage } from '../cloudinary.interface';

export interface IUser extends Document {
  username: string;
  email: string;
  password: string;
}

export interface IProfile extends Document {
  user: Types.ObjectId;
  fullName: string;
  contact: {
    email: string;
    number: string;
  };
  address: string;
  facebook: string;
  messenger: string;
  isActive: boolean;
}

export interface IRequestLog extends Document {
  timestamp: Date;
  clientIp: string;
  requestMethod: string;
  requestUrl: string;
  userAgent: string;
  requestBody?: any;
  responseStatus: number;
  responseStatusMessage: string;
  elapsed: number;
}

export interface IRoleName extends Document {
  name: string;
}

export interface IUserRole extends Document {
  user: Types.ObjectId;
  role: Types.ObjectId;
}

export interface IPetOwner extends Document {
  user: Types.ObjectId;
  name: string;
  address: string;
  mobileNo: string;
  email: string;
  emergencyContactNo: string;
  work: string;
}

export interface IPet extends Document {
  user: Types.ObjectId;
  name: string;
  age: number;
  gender: string;
  breed: string;
}

export interface IBooking extends Document {
  user: Types.ObjectId;
  staff?: Types.ObjectId;
  pet: Types.ObjectId;
  application: Types.ObjectId;
  applicationType: BookingServiceType;
  status: BookingStatus;
  payable: Number;
}

export interface IGroomingApplication extends Document {
  serviceName: string;
  otherInformation: string;
  schedule: Types.ObjectId;
}

export interface IBoardingApplication extends Document {
  serviceName: string;
  schedule: Date;
  daysOfStay: Number;
  cage: Types.ObjectId;
}

export interface ITransitApplication extends Document {
  schedule: Date;
}

export interface IUpload extends Document {
  user: Types.ObjectId;
  uploadData: ICloudinaryImage;
  uploadContentScope: UploadContentScope;
  uploadContentType: UploadContentType;
}

export interface IBookingSchedule extends Document {
  title: string;
}

export interface IBookingCage extends Document {
  title: string;
}

export interface IServiceFee extends Document {
  title: string;
  fee: Number;
}

export interface IServiceTransaction extends Document {
  staff: Types.ObjectId;
  customer: Types.ObjectId;
  pet: Types.ObjectId;
  service: Types.ObjectId;
  date: Date;
  feedback?: string;
  payment: Number;
}