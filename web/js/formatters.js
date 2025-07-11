/**
 * Formats hours into a human readable string
 * @param {number} hours - The time duration in hours
 * @returns {string} Formatted time string (e.g., "30m", "2h 30m", "1d 5h")
 */
export function formatHours(hours) {
  if (hours < 1) {
    const minutes = Math.round(hours * 60);
    return `${minutes}m`;
  } else if (hours < 24) {
    const wholeHours = Math.floor(hours);
    const minutes = Math.round((hours - wholeHours) * 60);
    if (minutes === 0) {
      return `${wholeHours}h`;
    } else {
      return `${wholeHours}h ${minutes}m`;
    }
  } else {
    const days = Math.floor(hours / 24);
    const remainingHours = Math.floor(hours % 24);
    if (remainingHours === 0) {
      return `${days}d`;
    } else {
      return `${days}d ${remainingHours}h`;
    }
  }
}
