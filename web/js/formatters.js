/**
 * Formats hours into a human readable string
 * @param {number} hours - The time duration in hours
 * @returns {string} Formatted time string (e.g., "1h", "25h", "168h")
 */
export function formatHours(hours) {
  const wholeHours = Math.round(hours);
  return `${wholeHours}h`;
}
