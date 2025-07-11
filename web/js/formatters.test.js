import { describe, it, expect } from "vitest";
import { formatHours } from "./formatters.js";

describe("formatHours", () => {
  describe("when hours is less than 1", () => {
    it("formats fractional hours as minutes", () => {
      expect(formatHours(0.5)).toBe("30m");
      expect(formatHours(0.25)).toBe("15m");
      expect(formatHours(0.75)).toBe("45m");
    });

    it("rounds to nearest minute", () => {
      expect(formatHours(0.016667)).toBe("1m"); // 1 minute
      expect(formatHours(0.033333)).toBe("2m"); // 2 minutes
    });

    it("handles zero hours", () => {
      expect(formatHours(0)).toBe("0m");
    });

    it("handles very small values", () => {
      expect(formatHours(0.001)).toBe("0m");
      expect(formatHours(0.008333)).toBe("0m"); // Less than 0.5 minutes
    });
  });

  describe("when hours is between 1 and 24", () => {
    it("formats whole hours without minutes", () => {
      expect(formatHours(1)).toBe("1h");
      expect(formatHours(5)).toBe("5h");
      expect(formatHours(12)).toBe("12h");
      expect(formatHours(23)).toBe("23h");
    });

    it("formats hours with minutes", () => {
      expect(formatHours(1.5)).toBe("1h 30m");
      expect(formatHours(2.25)).toBe("2h 15m");
      expect(formatHours(5.75)).toBe("5h 45m");
      expect(formatHours(12.1)).toBe("12h 6m");
    });

    it("rounds minutes to nearest whole number", () => {
      expect(formatHours(1.0083)).toBe("1h"); // 0.5 minutes rounds to 0
      expect(formatHours(1.0167)).toBe("1h 1m"); // 1 minute
      expect(formatHours(2.9917)).toBe("2h 60m"); // 59.5 minutes rounds to 60, shows as 2h 60m
    });

    it("handles edge case at 24 hours boundary", () => {
      expect(formatHours(23.99)).toBe("23h 59m"); // Shows as 23h 59m
    });
  });

  describe("when hours is 24 or more", () => {
    it("formats exact days without hours", () => {
      expect(formatHours(24)).toBe("1d");
      expect(formatHours(48)).toBe("2d");
      expect(formatHours(72)).toBe("3d");
    });

    it("formats days with remaining hours", () => {
      expect(formatHours(25)).toBe("1d 1h");
      expect(formatHours(30)).toBe("1d 6h");
      expect(formatHours(49)).toBe("2d 1h");
      expect(formatHours(75)).toBe("3d 3h");
    });

    it("ignores minutes when calculating days", () => {
      expect(formatHours(24.5)).toBe("1d"); // 24.5 hours = 1 day (remaining hours is 0, so not shown)
      expect(formatHours(25.75)).toBe("1d 1h"); // 25.75 hours = 1 day 1 hour (minutes ignored)
    });

    it("handles large values", () => {
      expect(formatHours(168)).toBe("7d"); // 1 week
      expect(formatHours(720)).toBe("30d"); // 30 days
      expect(formatHours(8760)).toBe("365d"); // 1 year
    });
  });

  describe("edge cases", () => {
    it("handles negative values gracefully", () => {
      // Note: The current implementation doesn't handle negative values explicitly
      // This test documents current behavior - you may want to add validation
      expect(formatHours(-1)).toBe("-60m");
      expect(formatHours(-24)).toBe("-1440m"); // -24 * 60 = -1440 minutes
    });

    it("handles decimal precision edge cases", () => {
      expect(formatHours(1.9999)).toBe("1h 60m"); // Shows as 1h 60m due to rounding
      expect(formatHours(0.99999)).toBe("60m"); // Should round to 60m (not 1h)
    });
  });
});
