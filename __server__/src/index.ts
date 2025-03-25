import express, { type Application } from 'express';
import cors from 'cors';
import helmet from 'helmet';
import { connectDB } from './_core/utils/db/db.util';
import { getEnv } from './_core/config/env.config';
import { maintenanceModeMiddleware } from './_core/middlewares/maintenance-mode.middleware';

import branchRoute from './routes/branch.route';
import activityRoute from './routes/activity.route';
import authRoute from './routes/auth.route';
import userRoute from './routes/user.route';
import ownerRoute from './routes/pet_owner.route';
import petRoute from './routes/pet.route';
import adminRoute from './routes/admin.route';
import serviceRoute from './routes/service_fee.route';
import cageRoute from './routes/cage.route';
import groomingApplicationRoute from './routes/grooming_application.route';
import scheduleRoute from './routes/schedule.route';
import boardingApplicationRoute from './routes/boarding_application.route';
import bookingRoute from './routes/booking.route';
import transitApplicationRoute from './routes/transit_application.route';
import uploadRoute from './routes/upload.route';
import cookieParser from 'cookie-parser';
import multer from "multer";

import { requestLoggerMiddleware } from './_core/middlewares/request-logger.middleware';
import { allowApiAccessMiddleware } from './_core/middlewares/allow-access.middleware';
import { fileFilter, storage } from './services/upload/image_upload.service';

const app: Application = express();

async function runApp() {
  const env = await getEnv();
  app.use(helmet());
  app.use(
    cors({
      exposedHeaders: ['X-Nodex-DateTime'],
    }),
  );
  app.use(express.json());

  app.use(cookieParser());
  app.use(allowApiAccessMiddleware);
  app.use(maintenanceModeMiddleware);
  app.use(requestLoggerMiddleware);
  app.use(multer({ storage, fileFilter }).array("media"));


  app.use('/api', authRoute);
  app.use('/api', userRoute);
  app.use('/api', ownerRoute);
  app.use('/api', petRoute);
  app.use('/api', adminRoute);
  app.use('/api', serviceRoute);
  app.use('/api', cageRoute);
  app.use('/api', scheduleRoute);
  app.use('/api', groomingApplicationRoute);
  app.use('/api', boardingApplicationRoute);
  app.use('/api', transitApplicationRoute);
  app.use('/api', bookingRoute);
  app.use('/api', uploadRoute);
  app.use('/api', branchRoute);
  app.use('/api', activityRoute);

  connectDB();

  app.listen(Number(env?.PORT) || 5000, () => {
    console.log('@environment ', env?.ENVIRONMENT);
    console.log('@port ', Number(env?.PORT));
  });
}

runApp();
