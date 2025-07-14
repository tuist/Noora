/**
 * Formats hours into a human readable string
 * @param {number} hours - The time duration in hours
 * @returns {string} Formatted time string (e.g., "1h", "2h", "1d 5h")
 */
export function formatHours(hours) {
  if (Math.abs(hours) < 24) {
    const wholeHours = Math.round(hours);
    return `${wholeHours}h`;
  } else {
    const days = Math.floor(hours / 24);
    const remainingHours = Math.round(hours % 24);
    return `${days}d ${remainingHours}h`;
  }
}
