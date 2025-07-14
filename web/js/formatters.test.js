import { describe, it, expect } from "vitest";
import { formatHours } from "./formatters.js";

describe("formatHours", () => {
  describe("when hours is less than 24", () => {
    it("formats fractional hours as rounded hours", () => {
      expect(formatHours(0.5)).toBe("1h");
      expect(formatHours(0.25)).toBe("0h");
      expect(formatHours(0.75)).toBe("1h");
    });

    it("rounds to nearest hour", () => {
      expect(formatHours(0.4)).toBe("0h");
      expect(formatHours(0.6)).toBe("1h");
    });

    it("handles zero hours", () => {
      expect(formatHours(0)).toBe("0h");
    });

    it("handles very small values", () => {
      expect(formatHours(0.001)).toBe("0h");
      expect(formatHours(0.4)).toBe("0h");
    });

    it("formats whole hours", () => {
      expect(formatHours(1)).toBe("1h");
      expect(formatHours(5)).toBe("5h");
      expect(formatHours(12)).toBe("12h");
      expect(formatHours(23)).toBe("23h");
    });

    it("rounds fractional hours to nearest whole hour", () => {
      expect(formatHours(1.3)).toBe("1h");
      expect(formatHours(1.5)).toBe("2h");
      expect(formatHours(2.7)).toBe("3h");
      expect(formatHours(12.1)).toBe("12h");
    });

    it("handles edge case at 24 hours boundary", () => {
      expect(formatHours(23.4)).toBe("23h");
      expect(formatHours(23.6)).toBe("24h");
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

    it("rounds remaining hours to nearest whole hour", () => {
      expect(formatHours(24.3)).toBe("1d");
      expect(formatHours(24.6)).toBe("1d 1h");
      expect(formatHours(25.7)).toBe("1d 2h");
    });

    it("handles large values", () => {
      expect(formatHours(168)).toBe("7d"); // 1 week
      expect(formatHours(720)).toBe("30d"); // 30 days
      expect(formatHours(8760)).toBe("365d"); // 1 year
    });
  });

  describe("edge cases", () => {
    it("handles negative values gracefully", () => {
      expect(formatHours(-1)).toBe("-1h");
      expect(formatHours(-24)).toBe("-1d");
    });

    it("handles decimal precision edge cases", () => {
      expect(formatHours(1.9999)).toBe("2h");
      expect(formatHours(0.99999)).toBe("1h");
    });
  });
});
