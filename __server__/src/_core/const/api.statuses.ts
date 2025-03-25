export const statuses = {
  /**
   * @alias Generic
   * @description from 00 - 100
   */
  '00': {
    message: 'Success',
    code: '00',
  },
  '01': {
    message: 'Error',
    code: '01',
  },
  '02': {
    message: 'Not Found',
    code: '02',
  },
  '03': {
    message: 'Failed',
    code: '03',
  },
  '04': {
    message: 'Duplicate',
    code: '04',
  },
  /**
   * @alias Authentication
   * @description from 0050 - 0100
   */
  '0050': {
    message: 'Account created successfully.',
    code: '0050',
  },
  '0051': {
    message: 'Incorrect username and/or password.',
    code: '0051',
  },
  '0052': {
    message: 'Account already registered, Please try logging in.',
    code: '0052',
  },
  '0053': {
    message: 'Account suspended.',
    code: '0053',
  },
  '0054': {
    message: 'Account blocked.',
    code: '0054',
  },
  '0055': {
    message: 'Account not verified. Please contact the administrator.',
    code: '0055',
  },
  '0056': {
    message: 'User not found.',
    code: '0056',
  },
  '0057': {
    message: 'User not authorized for this role.',
    code: '0057',
  },
  '0058': {
    message: 'Account has been invalidated. Please contact the administrator.',
    code: '0058',
  },
  '0059': {
    message: 'Incorrect origin.',
    code: '0059',
  },
  '0060': {
    message: 'Incomplete number of required headers.',
    code: '0060',
  },
  '0061': {
    message: 'Username and/or Email is already registered, Please try another.',
    code: '0061',
  },
  '0062': {
    message: "Oops! Your password and confirmation didn't match. Please re-enter to match them up.",
    code: '0062',
  },
  '0063': {
    message: 'Password does not match.',
    code: '0063',
  },
  '0064': {
    message: 'Current and New password cannot be the same.',
    code: '0064',
  },
  '0070': {
    message: 'Incorrect Secret and/or Access key.',
    code: '0070',
  },
  '0071': {
    message: 'User role not assigned. Please contact the administrator.',
    code: '0071',
  },
  /**
   * @alias Profile
   * @description from 0100 - 0200
   */
  '0100': {
    message: 'Profile created successfully.',
    code: '0100',
  },
  '0101': {
    message: 'Profile updated successfully.',
    code: '0101',
  },
  '0102': {
    message: 'Profile deleted.',
    code: '0102',
  },
  '0103': {
    message: 'Profile already exist.',
    code: '0103',
  },
  '0104': {
    message: 'Profile not found. Please create first and try again.',
    code: '0104',
  },

  '0900': {
    message: 'Something went wrong. Please try again later.',
    code: '0900',
  },

  '0901': {
    message: 'Incorrect format of id.',
    code: '0901',
  },
  /**
   * @alias
   * @description from 0100 - 0200
   */
  '0300': {
    message: 'Invalid/Incorrect AWS S3 config.',
    code: '0300',
  },
  '500': {
    message: 'Our server is currently undergoing maintenance to improve your experience. Please try again later.',
    code: '500',
  },
  '501': {
    message: 'Payload incomplete',
    code: '501',
  },
  '502': {
    message: 'Incorrect payload format.',
    code: '502',
  },
  '10010': {
    message: 'Aws S3 JWT_SECRET is incorrect/invalid',
    code: '10010',
  },
  '10020': {
    message: 'Session expired. Please login and try again.',
    code: '10020',
  },

  // custom
  '99000': {
    message: 'Pet Owner profile not found.',
    code: '99000',
  },
  '99001': {
    message: 'Pet profile not found.',
    code: '99001',
  },
  '99002': {
    message: 'Booking not found.',
    code: '99002',
  },
};
