export const isEmpty = (value: any) => {
  if (value === null || value === undefined) {
    return true;
  }

  if (Array.isArray(value)) {
    return value.length === 0;
  }

  if (typeof value === 'string') {
    return value.trim().length === 0;
  }

  return false;
};


/**
 * Returns a promise that resolves after a specified number of seconds.
 *
 * @param {number} seconds Number of seconds to wait.
 * @return {Promise<void>} A promise that resolves after the specified amount of time.
 */
export const delay = (seconds: number) => {
  return new Promise(resolve => setTimeout(resolve, seconds * 1000));
}
