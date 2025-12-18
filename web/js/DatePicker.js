import * as datePicker from "@zag-js/date-picker";
import {
  getOption,
  getBooleanOption,
  getPartSelector,
  normalizeProps,
  spreadProps,
  renderPart,
} from "./util.js";
import { Component } from "./component.js";
import { VanillaMachine } from "./machine.js";

const WEEKDAYS = ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"];

/**
 * Calculate a date range based on a duration from now
 * @param {Object} duration - Duration object with amount and unit
 * @returns {{start: Date, end: Date}}
 */
function calculateRangeFromDuration(duration) {
  const now = new Date();
  const end = now;
  let start;

  const amount = duration.amount;
  const unit = duration.unit;

  switch (unit) {
    case "hour":
      start = new Date(now.getTime() - amount * 60 * 60 * 1000);
      break;
    case "day":
      start = new Date(now.getTime() - amount * 24 * 60 * 60 * 1000);
      break;
    case "week":
      start = new Date(now.getTime() - amount * 7 * 24 * 60 * 60 * 1000);
      break;
    case "month":
      start = new Date(now);
      start.setMonth(start.getMonth() - amount);
      break;
    case "year":
      start = new Date(now);
      start.setFullYear(start.getFullYear() - amount);
      break;
    default:
      start = new Date(now.getTime() - amount * 24 * 60 * 60 * 1000);
  }

  return { start, end };
}

/**
 * Format a date for display (DD • MM • YYYY format)
 */
function formatDateParts(date) {
  if (!date) return { day: "--", month: "--", year: "----" };
  const d = new Date(date);
  return {
    day: String(d.getDate()).padStart(2, "0"),
    month: String(d.getMonth() + 1).padStart(2, "0"),
    year: String(d.getFullYear()),
  };
}

class DatePicker extends Component {
  constructor(el, props) {
    super(el, props);
    this.presets = props.presets || [];
    this.selectedPreset = props.selectedPreset;
    this.isMobileView = window.innerWidth < 768;
    this.pendingRange = null;
    // Flag to track programmatic value changes (vs user clicking dates)
    this.isSettingPreset = false;
    // Store parsed min/max for use in rendering
    this.minDate = props.min ? datePicker.parse(props.min) : null;
    this.maxDate = props.max ? datePicker.parse(props.max) : null;
  }

  initMachine(context) {
    const forceOpen = getBooleanOption(this.el, "open");
    // Check mobile before this.isMobileView is set (super() runs initMachine first)
    const isMobile = window.innerWidth < 768;

    // Parse min/max date constraints upfront
    const minDate = context.min ? datePicker.parse(context.min) : null;
    const maxDate = context.max ? datePicker.parse(context.max) : null;

    // Set default value from selected preset (use context since this.presets isn't set yet)
    const defaultValue = this.getDefaultValueFromPreset(
      context.presets,
      context.selectedPreset,
    );

    // Create isDateUnavailable function to disable dates outside min/max range
    const isDateUnavailable = (date) => {
      if (minDate) {
        if (date.year < minDate.year) return true;
        if (date.year === minDate.year && date.month < minDate.month)
          return true;
        if (
          date.year === minDate.year &&
          date.month === minDate.month &&
          date.day < minDate.day
        )
          return true;
      }
      if (maxDate) {
        if (date.year > maxDate.year) return true;
        if (date.year === maxDate.year && date.month > maxDate.month)
          return true;
        if (
          date.year === maxDate.year &&
          date.month === maxDate.month &&
          date.day > maxDate.day
        )
          return true;
      }
      return false;
    };

    const machineContext = {
      ...context,
      selectionMode: "range",
      numOfMonths: isMobile ? 1 : 2,
      fixedWeeks: true,
      closeOnSelect: false,
      open: forceOpen || undefined,
      defaultValue: defaultValue || undefined,
      min: minDate || undefined,
      max: maxDate || undefined,
      isDateUnavailable,
      positioning: {
        zIndex: 50,
        offset: { mainAxis: 8 },
      },
      onValueChange: () => {
        // When user clicks a date (not from preset selection), switch to "custom"
        if (!this.isSettingPreset && this.selectedPreset !== "custom") {
          this.selectedPreset = "custom";
          this.updatePresetSelection("custom");
        }
      },
    };

    return new VanillaMachine(datePicker.machine, machineContext);
  }

  // Compare two DateValue objects, returns -1 if a < b, 0 if equal, 1 if a > b
  compareDates(a, b) {
    if (a.year !== b.year) return a.year - b.year;
    if (a.month !== b.month) return a.month - b.month;
    return a.day - b.day;
  }

  getDefaultValueFromPreset(presets, selectedPreset) {
    if (!selectedPreset || !presets || !presets.length) return null;

    const preset = presets.find((p) => p.id === selectedPreset);
    if (!preset || !preset.duration) return null;

    const range = calculateRangeFromDuration(preset.duration);

    // Format dates as ISO strings for Zag to parse
    const startStr = `${range.start.getFullYear()}-${String(range.start.getMonth() + 1).padStart(2, "0")}-${String(range.start.getDate()).padStart(2, "0")}`;
    const endStr = `${range.end.getFullYear()}-${String(range.end.getMonth() + 1).padStart(2, "0")}-${String(range.end.getDate()).padStart(2, "0")}`;

    // Use Zag's module-level parse function to create DateValue objects
    const startDate = datePicker.parse(startStr);
    const endDate = datePicker.parse(endStr);

    if (startDate && endDate) {
      return [startDate, endDate];
    }
    return null;
  }

  initApi() {
    return datePicker.connect(this.machine.service, normalizeProps);
  }

  // Fallback click handler in case Zag's trigger props don't work
  setupTriggerFallback() {
    const trigger = this.el.querySelector("[data-part='trigger']");
    if (trigger) {
      trigger.addEventListener("click", () => {
        this.api.setOpen(!this.api.open);
      });
    }
  }

  open() {
    this.api.setOpen(true);
  }

  close() {
    this.api.setOpen(false);
  }

  setupResizeListener() {
    this.resizeHandler = () => {
      const newIsMobile = window.innerWidth < 768;
      if (newIsMobile !== this.isMobileView) {
        this.isMobileView = newIsMobile;
        // Re-render to adjust number of months
        this.render();
      }
    };
    window.addEventListener("resize", this.resizeHandler);
  }

  handlePresetClickById(presetId) {
    const preset = this.presets.find((p) => p.id === presetId);
    if (!preset) return;

    this.selectedPreset = presetId;
    this.updatePresetSelection(presetId);

    if (preset.duration) {
      // Calculate the range
      const range = calculateRangeFromDuration(preset.duration);

      // Update Zag's selection state so the calendar updates visually
      const startStr = `${range.start.getFullYear()}-${String(range.start.getMonth() + 1).padStart(2, "0")}-${String(range.start.getDate()).padStart(2, "0")}`;
      const endStr = `${range.end.getFullYear()}-${String(range.end.getMonth() + 1).padStart(2, "0")}-${String(range.end.getDate()).padStart(2, "0")}`;

      const startDate = datePicker.parse(startStr);
      const endDate = datePicker.parse(endStr);

      if (startDate && endDate && this.api.setValue) {
        // Set flag to prevent onValueChange from switching to "custom"
        // Use setTimeout to clear flag after Zag's async onValueChange fires
        this.isSettingPreset = true;
        this.api.setValue([startDate, endDate]);
        setTimeout(() => {
          this.isSettingPreset = false;
        }, 0);
      }

      // Don't emit or close - let user confirm with Apply button
    }
    // For "custom" preset, user will select dates manually
  }

  handleCancel() {
    this.pendingRange = null;
    this.close();
    if (this.el.dataset.onCancel) {
      this.pushEvent(this.el.dataset.onCancel, {});
    }
  }

  handleApply() {
    const value = this.api.value;
    if (value && value.length >= 2) {
      const startDate = value[0].toDate();
      const endDate = value[1].toDate();

      // Set time: start to beginning of day, end to end of day
      startDate.setHours(0, 0, 0, 0);
      endDate.setHours(23, 59, 59, 999);

      this.emitValueChange(startDate, endDate, "custom");
      this.close();
    }
  }

  emitValueChange(start, end, preset) {
    if (this.el.dataset.onValueChange) {
      this.pushEvent(this.el.dataset.onValueChange, {
        value: {
          start: start.toISOString(),
          end: end.toISOString(),
        },
        preset: preset,
      });
    }
  }

  updatePresetSelection(selectedId) {
    // Don't modify selection if no selectedId provided - preserve server-rendered state
    if (!selectedId) return;

    const presetButtons = this.el.querySelectorAll("[data-part='preset-item']");
    presetButtons.forEach((btn) => {
      const isSelected = btn.dataset.presetId === selectedId;
      if (isSelected) {
        btn.setAttribute("data-selected", "true");
      } else {
        btn.removeAttribute("data-selected");
      }
    });
  }

  render() {
    this.renderTriggerAndPositioner();
    this.renderMonths();
    this.renderRangeDisplay();
    this.hideSecondMonthOnMobile();
    this.attachPresetHandlers();
  }

  attachPresetHandlers() {
    // Attach click handlers to preset buttons after content is rendered
    // Query from document since Zag may portal the content outside our root
    const content = document.querySelector(
      `[data-scope="date-picker"][data-part="content"]`,
    );
    if (!content) return;

    const presetButtons = content.querySelectorAll("[data-part='preset-item']");
    presetButtons.forEach((btn) => {
      // Only attach if not already attached
      if (!btn._presetHandlerAttached) {
        btn._presetHandlerAttached = true;
        btn.addEventListener("click", (e) => {
          const presetId = e.currentTarget.dataset.presetId;
          this.handlePresetClickById(presetId);
        });
      }
    });
  }

  renderTriggerAndPositioner() {
    renderPart(this.el, "control", this.api);
    renderPart(this.el, "control:trigger", this.api);
    renderPart(this.el, "positioner", this.api);
    renderPart(this.el, "positioner:content", this.api);

    // Override Zag's default z-index: auto (see https://github.com/chakra-ui/zag/issues/981)
    const positioner = this.el.querySelector("[data-part='positioner']");
    if (positioner) {
      positioner.style.zIndex = "50";
    }
  }

  renderMonths() {
    // Use specific selector to only get calendar months, not date-display spans
    const months = this.el.querySelectorAll(
      "[data-part='months'] > [data-part='month']",
    );

    // Read min/max directly from data attributes for reliability
    // Parse manually to ensure consistent DateValue-like structure
    const parseISODate = (str) => {
      if (!str || str.length === 0) return null;
      // Handle both "2024-12-18" and "2024-12-18T..." formats
      const datePart = str.split("T")[0];
      const [year, month, day] = datePart.split("-").map(Number);
      if (isNaN(year) || isNaN(month) || isNaN(day)) return null;
      return { year, month, day };
    };
    const minDate = parseISODate(this.el.dataset.min);
    const maxDate = parseISODate(this.el.dataset.max);

    months.forEach((monthEl, monthIndex) => {
      // Only render first month on mobile
      if (this.isMobileView && monthIndex > 0) return;

      // Render month title
      const viewTrigger = monthEl.querySelector("[data-part='view-trigger']");
      if (viewTrigger) {
        const visibleRange = this.api.visibleRange;
        if (visibleRange) {
          const date = new Date(
            visibleRange.start.year,
            visibleRange.start.month - 1 + monthIndex,
            1,
          );
          const monthName = date.toLocaleDateString(
            this.el.dataset.locale || "en-US",
            { month: "long", year: "numeric" },
          );
          viewTrigger.textContent = monthName;
        }
      }

      // Render navigation buttons
      const prevTrigger = monthEl.querySelector("[data-part='prev-trigger']");
      const nextTrigger = monthEl.querySelector("[data-part='next-trigger']");

      // On mobile (single month), both buttons work on month 0
      // On desktop (two months), prev on first month, next on last month
      const isFirstMonth = monthIndex === 0;
      const isLastMonth = this.isMobileView
        ? monthIndex === 0
        : monthIndex === months.length - 1;

      if (prevTrigger && isFirstMonth) {
        spreadProps(prevTrigger, this.api.getPrevTriggerProps());
      } else if (prevTrigger) {
        prevTrigger.style.visibility = "hidden";
      }

      if (nextTrigger && isLastMonth) {
        spreadProps(nextTrigger, this.api.getNextTriggerProps());
      } else if (nextTrigger) {
        nextTrigger.style.visibility = "hidden";
      }

      // Render weekday headers
      const headerCells = monthEl.querySelectorAll(
        "[data-part='table-header']",
      );
      const startOfWeek = parseInt(this.el.dataset.startOfWeek || "0", 10);
      headerCells.forEach((cell, i) => {
        const dayIndex = (startOfWeek + i) % 7;
        cell.textContent = WEEKDAYS[dayIndex];
      });

      // Get the weeks and visibleRange for this month
      const monthWeeks = this.getWeeksForMonth(monthIndex);
      const monthOffset =
        monthIndex === 0 ? null : this.api.getOffset({ months: monthIndex });
      const visibleRange = monthOffset?.visibleRange || this.api.visibleRange;

      // Render day cells
      const rows = monthEl.querySelectorAll(
        "[data-part='table-body'] [data-part='table-row']",
      );
      rows.forEach((row, weekIndex) => {
        // Use 'td' selector since Zag overwrites data-part="day-table-cell" to "table-cell"
        const cells = row.querySelectorAll("td");
        const week = monthWeeks[weekIndex];

        cells.forEach((cell, dayIndex) => {
          const trigger = cell.querySelector(
            "[data-part='table-cell-trigger']",
          );
          if (!trigger) return;

          if (week && week[dayIndex]) {
            const day = week[dayIndex];
            trigger.textContent = day.day;

            // Get props from Zag API, passing visibleRange for multi-month support
            // Exclude id to avoid duplicates in multi-month view
            const { id: triggerPropsId, ...dayProps } =
              this.api.getDayTableCellTriggerProps({
                value: day,
                visibleRange,
              });
            const { id: cellPropsId, ...cellProps } =
              this.api.getDayTableCellProps({ value: day, visibleRange });

            spreadProps(trigger, dayProps);
            spreadProps(cell, cellProps);

            // Manually disable dates outside min/max range
            // (Zag's max only prevents navigation, doesn't disable cells)
            const isBeforeMin = minDate && this.compareDates(day, minDate) < 0;
            const isAfterMax = maxDate && this.compareDates(day, maxDate) > 0;

            if (isBeforeMin || isAfterMax) {
              trigger.setAttribute("data-disabled", "true");
              trigger.setAttribute("data-unavailable", "true");
              trigger.setAttribute("aria-disabled", "true");
              trigger.disabled = true;
              cell.setAttribute("data-disabled", "true");
              cell.setAttribute("aria-disabled", "true");
            }

            trigger.style.display = "";
          } else {
            trigger.style.display = "none";
            trigger.textContent = "";
          }
        });
      });
    });
  }

  getWeeksForMonth(monthIndex) {
    // For the first month (or mobile view), use api.weeks directly
    if (this.isMobileView || monthIndex === 0) {
      return this.api.weeks || [];
    }

    // For subsequent months, use getOffset to get that month's weeks
    const offset = this.api.getOffset({ months: monthIndex });
    return offset?.weeks || [];
  }

  renderRangeDisplay() {
    const value = this.api.value;
    const startDisplay = this.el.querySelector(
      "[data-part='date-display'][data-type='start']",
    );
    const endDisplay = this.el.querySelector(
      "[data-part='date-display'][data-type='end']",
    );

    if (startDisplay) {
      const startParts =
        value && value[0]
          ? formatDateParts(value[0].toDate())
          : formatDateParts(null);
      const dayEl = startDisplay.querySelector("[data-part='day']");
      const monthEl = startDisplay.querySelector("[data-part='month']");
      const yearEl = startDisplay.querySelector("[data-part='year']");
      if (dayEl) dayEl.textContent = startParts.day;
      if (monthEl) monthEl.textContent = startParts.month;
      if (yearEl) yearEl.textContent = startParts.year;
    }

    if (endDisplay) {
      const endParts =
        value && value[1]
          ? formatDateParts(value[1].toDate())
          : formatDateParts(null);
      const dayEl = endDisplay.querySelector("[data-part='day']");
      const monthEl = endDisplay.querySelector("[data-part='month']");
      const yearEl = endDisplay.querySelector("[data-part='year']");
      if (dayEl) dayEl.textContent = endParts.day;
      if (monthEl) monthEl.textContent = endParts.month;
      if (yearEl) yearEl.textContent = endParts.year;
    }
  }

  hideSecondMonthOnMobile() {
    const secondMonth = this.el.querySelector(
      "[data-part='month'][data-index='1']",
    );
    if (secondMonth) {
      secondMonth.style.display = this.isMobileView ? "none" : "";
    }
  }

  destroy() {
    super.destroy();
    if (this.resizeHandler) {
      window.removeEventListener("resize", this.resizeHandler);
    }
  }
}

export default {
  mounted() {
    this.datePicker = new DatePicker(this.el, this.context());
    this.datePicker.pushEvent = (event, payload) =>
      this.pushEvent(event, payload);
    this.datePicker.init();

    // Cancel event handler
    this.handleCancelEvent = (event) => {
      if (event.detail.id === this.el.id) {
        this.datePicker.handleCancel();
      }
    };
    window.addEventListener("phx:date-picker-cancel", this.handleCancelEvent);

    // Apply event handler
    this.handleApplyEvent = (event) => {
      if (event.detail.id === this.el.id) {
        this.datePicker.handleApply();
      }
    };
    window.addEventListener("phx:date-picker-apply", this.handleApplyEvent);

    // Outside click handler
    this.handleOutsideClick = (event) => {
      if (!this.datePicker.api.open) return;

      const trigger = this.el.querySelector("[data-part='trigger']");
      const content = document.querySelector(
        `[data-scope="date-picker"][data-part="content"]`,
      );

      const clickedOutside =
        trigger &&
        !trigger.contains(event.target) &&
        (!content || !content.contains(event.target));

      if (clickedOutside) {
        this.datePicker.api.setOpen(false);
      }
    };
    document.addEventListener("mousedown", this.handleOutsideClick);

    // Resize handler for responsive layout
    this.datePicker.setupResizeListener();
  },

  updated() {
    this.datePicker.render();
  },

  beforeDestroy() {
    this.datePicker.destroy();
  },

  destroyed() {
    window.removeEventListener(
      "phx:date-picker-cancel",
      this.handleCancelEvent,
    );
    window.removeEventListener("phx:date-picker-apply", this.handleApplyEvent);
    document.removeEventListener("mousedown", this.handleOutsideClick);
  },

  context() {
    const presetsJson = this.el.dataset.presets;
    const presets = presetsJson ? JSON.parse(presetsJson) : [];

    return {
      id: this.el.id,
      locale: getOption(this.el, "locale") || "en-US",
      startOfWeek: parseInt(getOption(this.el, "startOfWeek") || "0", 10),
      disabled: getBooleanOption(this.el, "disabled"),
      presets,
      selectedPreset: getOption(this.el, "selectedPreset"),
      min: getOption(this.el, "min"),
      max: getOption(this.el, "max"),
    };
  },
};
