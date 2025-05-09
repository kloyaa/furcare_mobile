require('dotenv').config();
import bcrypt from 'bcrypt';
import User from '../../../models/user.schema';
import { seedAdminAccounts, seedRoleNames, seedStaffAccounts, seedUserAccounts } from '../../const/accounts.const';
import { closeDB, connectDB } from './db.util';
import RoleName from '../../../models/role_name.schema';
import UserRole from '../../../models/user_role.schema';
import BookingSchedule from '../../../models/schedule.schema';
import { seedCageSizes, seedGroomgServices, seedSchedules, seedServiceFees, seedVaccinationServices } from '../../const/booking_seed_data.const';
import Cage from '../../../models/cage.schema';
import ServiceFee from '../../../models/service_fee.schema';
import Profile from '../../../models/profile.schema';
import { faker } from '@faker-js/faker';
import Branch from '../../../models/branch.schema';
import { seedBranches } from '../../const/branch_seed.data.const';
import { IBranch } from '../../interfaces/branch.interface';
import GroomingService from '../../../models/grooming_service.schema';
import VaccinationService from '../../../models/vaccination_service';

const registerAccounts = async (): Promise<any> => {
  try {
    console.log('Deleting previous account seeds...');

    await User.deleteMany();

    console.log('Creating accounts...');

    const userAccounts = await Promise.all(
      seedUserAccounts.map(async (el) => {
        const salt = await bcrypt.genSalt(10);
        const hashedPassword = await bcrypt.hash(el.password, salt);
        console.log(` -> Creating customer account ${el.username}...`);
        return {
          username: el.username,
          email: el.email,
          password: hashedPassword,
          origin: el.origin,
        };
      }),
    );

    const staffAccounts = await Promise.all(
      seedStaffAccounts.map(async (el) => {
        const salt = await bcrypt.genSalt(10);
        const hashedPassword = await bcrypt.hash(el.password, salt);
        console.log(` -> Creating staff account ${el.username}...`);
        return {
          username: el.username,
          email: el.email,
          password: hashedPassword,
          origin: el.origin,
        };
      }),
    );

    const adminAccounts = await Promise.all(
      seedAdminAccounts.map(async (el) => {
        const salt = await bcrypt.genSalt(10);
        const hashedPassword = await bcrypt.hash(el.password, salt);
        console.log(` -> Creating admin account ${el.username}...`);
        return {
          username: el.username,
          email: el.email,
          password: hashedPassword,
          origin: el.origin,
        };
      }),
    );

    const [users, staffs, admins] = await Promise.all([
      User.insertMany(userAccounts),
      User.insertMany(staffAccounts),
      User.insertMany(adminAccounts)
    ])

    const adminCreatedAccounts = admins.map((el) => {
      const fullName = faker.person.fullName();
      const firstName = faker.person.firstName('male');
      const lastName = faker.person.lastName('male');
      const present = faker.location.streetAddress({ useFullAddress: true });
      const email = faker.internet.email({ firstName, lastName });
      const number = `09277${faker.string.numeric(6)}`;
      return {
        user: el._id,
        fullName,
        address: present,
        contact: { email, number },
        isActive: true
      }
    });

    await createRoles({ staffs, users, admins });

    await Profile.insertMany(adminCreatedAccounts);

    return true;
  } catch (error) {
    console.log(error);
    return false;
  }
};

const roleName = async (): Promise<any> => {
  try {
    console.log('Deleting previous role names seeds...');
    await RoleName.deleteMany({});
    console.log('Creating role names...');
    const roles = await Promise.all(
      seedRoleNames.map(async (el) => {
        console.log(` -> Creating ${el.name} role...`);
        return {
          name: el.name,
        };
      }),
    );

    await RoleName.insertMany([...roles]);

    return true;
  } catch (error) {
    console.log(error);
    return false;
  }
};

const createRoles = async ({ users, staffs, admins }: any): Promise<any> => {
  try {
    console.log('Deleting previous user roles seeds...');
    await UserRole.deleteMany();
    console.log('Creating user roles...');
    const [customerRoleName, staffRoleName, adminRoleName] = await Promise.all([
      RoleName.findOne({ name: 'Customer' }),
      RoleName.findOne({ name: 'Staff' }),
      RoleName.findOne({ name: 'Administrator' }),
    ]);

    if (users) {
      const customerRoles = await Promise.all(
        users?.map(async (el: any) => {
          console.log(` -> Assigning ${el.username} as ${customerRoleName?.name}...`);
          return {
            user: el._id,
            role: customerRoleName?._id,
            name: el.name,
          };
        }),
      );

      await UserRole.insertMany([...customerRoles]);
    }

    if (staffs) {
      const staffRoles = await Promise.all(
        staffs?.map(async (el: any) => {
          console.log(` -> Assigning ${el.username} as ${staffRoleName?.name}...`);
          return {
            user: el._id,
            role: staffRoleName?._id,
            name: el.name,
          };
        }),
      );

      await UserRole.insertMany([...staffRoles]);
    }

    if (admins) {
      const adminRoles = await Promise.all(
        admins?.map(async (el: any) => {
          console.log(` -> Assigning ${el.username} as ${adminRoleName?.name}...`);
          return {
            user: el._id,
            role: adminRoleName?._id,
            name: el.name,
          };
        }),
      );

      await UserRole.insertMany([...adminRoles]);
    }
  } catch (error) {
    console.log(error);
    return false;
  }
};

const createSchedules = async (): Promise<any> => {
  try {
    console.log('Deleting previous schedules seeds...');
    await BookingSchedule.deleteMany({});
    console.log('Creating schedules...');
    const schedules = await Promise.all(
      seedSchedules.map(async (el) => {
        console.log(` -> Creating scedule ${el.title}...`);
        return {
          title: el?.title,
        };
      }),
    );

    await BookingSchedule.insertMany([...schedules]);

    return true;
  } catch (error) {
    console.log(error);
    return false;
  }
};

const createCages = async (): Promise<any> => {
  try {
    console.log('Deleting previous cages seeds...');
    await Cage.deleteMany({});
    console.log('Creating cages...');
    const cages = await Promise.all(
      seedCageSizes.map(async (el) => {
        console.log(` -> Creating cage ${el.title}...`);
        return {
          title: el?.title,
          price: el?.price
        };
      }),
    );

    await Cage.insertMany([...cages]);

    return true;
  } catch (error) {
    console.log(error);
    return false;
  }
};

const createServiceFees = async (): Promise<any> => {
  try {
    console.log('Deleting previous service fees seeds...');
    await Promise.all([
      ServiceFee.deleteMany({}),
      GroomingService.deleteMany({}),
    ])
    console.log('Creating service fees...');
    const services = await Promise.all(
      seedServiceFees.map(async (el: any) => {
        console.log(` -> Creating fee for ${el.title}...`);
        return {
          title: el?.title,
          fee: Number(el?.fee)
        };
      }),
    );

    const groomingServices = await Promise.all(
      seedGroomgServices.map(async (el: any) => {
        console.log(` -> Creating fee for ${el.title}...`);
        return {
          title: el?.title,
          fee: Number(el?.fee)
        };
      }),
    );

    const vaccinationServices = await Promise.all(
      seedVaccinationServices.map(async (el: any) => {
        console.log(` -> Creating fee for ${el.title}...`);
        return {
          title: el?.title,
          fee: Number(el?.fee)
        };
      }),
    );

    await Promise.all([
      ServiceFee.insertMany([...services]),
      GroomingService.insertMany([...groomingServices]),
      VaccinationService.insertMany([...vaccinationServices]),
    ])
    return true;
  } catch (error) {
    console.log(error);
    return false;
  }
};

const createBranches = async (): Promise<any> => {
  try {
    console.log('Deleting previous branches seeds...');
    await Branch.deleteMany({});
    console.log('Creating branches...');
    const branches = await Promise.all(
      seedBranches.map((el: IBranch) => {
        console.log(` -> Creating fee branch ${el.name}...`);
        return {
          name: el.name,
          mobileNo: el.mobileNo,
          address: el.address,
          isActive: el.isActive
        };
      }),
    );

    await Branch.insertMany([...branches]);

    return true;
  } catch (error) {
    console.log(error);
    return false;
  }
};

async function runSeed() {
  try {
    await connectDB();

    await roleName();
    await registerAccounts();
    await createSchedules();
    await createCages();
    await createServiceFees();
    await createBranches();

    await closeDB();
  } catch (error) {
    console.log(error);
  }
}

runSeed();
