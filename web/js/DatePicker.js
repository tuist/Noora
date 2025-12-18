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
 * Format a date into day, month, year parts
 */
function formatDateParts(date) {
  if (!date) return { day: "", month: "", year: "" };
  const d = new Date(date);
  return {
    day: String(d.getDate()).padStart(2, "0"),
    month: String(d.getMonth() + 1).padStart(2, "0"),
    year: String(d.getFullYear()),
  };
}

/**
 * Parse day, month, year inputs into a Date
 * @returns {Date|null}
 */
function parseDateFromParts(day, month, year) {
  const d = parseInt(day, 10);
  const m = parseInt(month, 10);
  const y = parseInt(year, 10);

  if (isNaN(d) || isNaN(m) || isNaN(y)) return null;
  if (d < 1 || d > 31 || m < 1 || m > 12 || y < 1000) return null;

  const date = new Date(y, m - 1, d);
  // Validate the date is real (e.g., Feb 30 would fail)
  if (
    date.getDate() !== d ||
    date.getMonth() !== m - 1 ||
    date.getFullYear() !== y
  ) {
    return null;
  }
  return date;
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

    // Independent calendar view states - each calendar tracks its own viewed month
    // These will be initialized after machine starts with default value
    this.startCalendarMonth = null; // { year, month } for first calendar
    this.endCalendarMonth = null; // { year, month } for second calendar

    // Bind navigation handlers so they can be added/removed
    this.handlePrevClickStart = this.handlePrevClickStart.bind(this);
    this.handleNextClickStart = this.handleNextClickStart.bind(this);
    this.handlePrevClickEnd = this.handlePrevClickEnd.bind(this);
    this.handleNextClickEnd = this.handleNextClickEnd.bind(this);
  }

  // Helper to compare months: returns negative if a < b, 0 if equal, positive if a > b
  compareMonths(a, b) {
    if (a.year !== b.year) return a.year - b.year;
    return a.month - b.month;
  }

  // Navigate start calendar (first/left) backwards one month
  handlePrevClickStart() {
    if (!this.startCalendarMonth) return;
    let { year, month } = this.startCalendarMonth;
    month -= 1;
    if (month < 1) {
      month = 12;
      year -= 1;
    }
    this.startCalendarMonth = { year, month };
    this.render();
  }

  // Navigate start calendar (first/left) forwards one month
  // Cannot go to or past the right calendar's month
  handleNextClickStart() {
    if (!this.startCalendarMonth || !this.endCalendarMonth) return;
    let { year, month } = this.startCalendarMonth;
    month += 1;
    if (month > 12) {
      month = 1;
      year += 1;
    }
    const newMonth = { year, month };
    // Only allow if new month is still before the right calendar
    if (this.compareMonths(newMonth, this.endCalendarMonth) < 0) {
      this.startCalendarMonth = newMonth;
      this.render();
    }
  }

  // Navigate end calendar (second/right) backwards one month
  // Cannot go to or before the left calendar's month
  handlePrevClickEnd() {
    if (!this.startCalendarMonth || !this.endCalendarMonth) return;
    let { year, month } = this.endCalendarMonth;
    month -= 1;
    if (month < 1) {
      month = 12;
      year -= 1;
    }
    const newMonth = { year, month };
    // Only allow if new month is still after the left calendar
    if (this.compareMonths(newMonth, this.startCalendarMonth) > 0) {
      this.endCalendarMonth = newMonth;
      this.render();
    }
  }

  // Navigate end calendar (second/right) forwards one month
  handleNextClickEnd() {
    if (!this.endCalendarMonth) return;
    let { year, month } = this.endCalendarMonth;
    month += 1;
    if (month > 12) {
      month = 1;
      year += 1;
    }
    this.endCalendarMonth = { year, month };
    this.render();
  }

  // Initialize calendar view months based on current value
  // Ensures the two calendars show different months
  initializeCalendarMonths() {
    const value = this.api.value;
    const now = new Date();

    if (value && value.length >= 2) {
      const startDate = value[0];
      const endDate = value[1];

      // Check if start and end are in the same month
      const sameMonth =
        startDate.year === endDate.year && startDate.month === endDate.month;

      if (sameMonth) {
        // Show previous month in left calendar so we have two different months
        let prevMonth = endDate.month - 1;
        let prevYear = endDate.year;
        if (prevMonth < 1) {
          prevMonth = 12;
          prevYear -= 1;
        }
        this.startCalendarMonth = { year: prevYear, month: prevMonth };
        this.endCalendarMonth = { year: endDate.year, month: endDate.month };
      } else {
        // Show start date's month in first calendar, end date's month in second
        this.startCalendarMonth = {
          year: startDate.year,
          month: startDate.month,
        };
        this.endCalendarMonth = {
          year: endDate.year,
          month: endDate.month,
        };
      }
    } else {
      // Default to previous month and current month
      const prevMonth = now.getMonth() === 0 ? 12 : now.getMonth();
      const prevYear =
        now.getMonth() === 0 ? now.getFullYear() - 1 : now.getFullYear();
      this.startCalendarMonth = {
        year: prevYear,
        month: prevMonth,
      };
      this.endCalendarMonth = {
        year: now.getFullYear(),
        month: now.getMonth() + 1,
      };
    }
  }

  // Calculate weeks for any arbitrary month (not tied to Zag's focusedValue)
  // Returns proper DateValue objects using Zag's parse function
  calculateWeeksForMonth(year, month) {
    const startOfWeek = parseInt(this.el.dataset.startOfWeek || "0", 10);
    const weeks = [];

    // Get first day of month and total days
    const firstDay = new Date(year, month - 1, 1);
    const lastDay = new Date(year, month, 0);
    const totalDays = lastDay.getDate();

    // Calculate which day of week the month starts on
    let dayOfWeek = firstDay.getDay();
    // Adjust for start of week setting
    let startOffset = (dayOfWeek - startOfWeek + 7) % 7;

    // Build 6 weeks (to match fixedWeeks: true)
    let currentDay = 1 - startOffset;

    for (let weekIndex = 0; weekIndex < 6; weekIndex++) {
      const week = [];
      for (let dayIndex = 0; dayIndex < 7; dayIndex++) {
        if (currentDay >= 1 && currentDay <= totalDays) {
          // Day is in current month - create proper DateValue using Zag's parse
          const dateStr = `${year}-${String(month).padStart(2, "0")}-${String(currentDay).padStart(2, "0")}`;
          week.push(datePicker.parse(dateStr));
        } else {
          // Day is outside current month - push null (will be hidden)
          week.push(null);
        }
        currentDay++;
      }
      weeks.push(week);
    }

    return weeks;
  }

  // Get visible range for a given month (for Zag API compatibility)
  // Returns proper DateValue objects
  getVisibleRangeForMonth(year, month) {
    const lastDay = new Date(year, month, 0).getDate();
    const startStr = `${year}-${String(month).padStart(2, "0")}-01`;
    const endStr = `${year}-${String(month).padStart(2, "0")}-${String(lastDay).padStart(2, "0")}`;
    return {
      start: datePicker.parse(startStr),
      end: datePicker.parse(endStr),
    };
  }

  initMachine(context) {
    const forceOpen = getBooleanOption(this.el, "open");
    // Check mobile before this.isMobileView is set (super() runs initMachine first)
    const isMobile = window.innerWidth < 768;

    // Parse min/max date constraints upfront
    const minDate = context.min ? datePicker.parse(context.min) : null;
    const maxDate = context.max ? datePicker.parse(context.max) : null;

    // Set default value from selected preset or explicit value
    const defaultValue = this.getDefaultValueFromPreset(
      context.presets,
      context.selectedPreset,
      context.valueStart,
      context.valueEnd,
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
      // We render months independently, but Zag still needs numOfMonths for its internal state
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

  getDefaultValueFromPreset(presets, selectedPreset, valueStart, valueEnd) {
    // If explicit value is provided (for custom preset), use it
    if (valueStart && valueEnd) {
      const startDateStr = valueStart.includes("T")
        ? valueStart.split("T")[0]
        : valueStart;
      const endDateStr = valueEnd.includes("T")
        ? valueEnd.split("T")[0]
        : valueEnd;
      const startDate = datePicker.parse(startDateStr);
      const endDate = datePicker.parse(endDateStr);
      if (startDate && endDate) {
        return [startDate, endDate];
      }
    }

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
        this.isSettingPreset = true;
        this.api.setValue([startDate, endDate]);

        // Check if start and end are in the same month
        const sameMonth =
          startDate.year === endDate.year && startDate.month === endDate.month;

        if (sameMonth) {
          // Show previous month in left calendar so we have two different months
          let prevMonth = endDate.month - 1;
          let prevYear = endDate.year;
          if (prevMonth < 1) {
            prevMonth = 12;
            prevYear -= 1;
          }
          this.startCalendarMonth = { year: prevYear, month: prevMonth };
          this.endCalendarMonth = { year: endDate.year, month: endDate.month };
        } else {
          // Show start date's month in first calendar, end date's month in second
          this.startCalendarMonth = {
            year: startDate.year,
            month: startDate.month,
          };
          this.endCalendarMonth = {
            year: endDate.year,
            month: endDate.month,
          };
        }

        // Re-render with new calendar months
        queueMicrotask(() => {
          this.api = this.initApi();
          this.isSettingPreset = false;
          this.render();
        });
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

      // Update trigger label before closing
      this.updateTriggerLabel(startDate, endDate);

      this.emitValueChange(startDate, endDate, this.selectedPreset);
      this.close();
    }
  }

  /**
   * Update the trigger button label based on current preset and date range
   */
  updateTriggerLabel(startDate, endDate) {
    const triggerLabel = this.el.querySelector("[data-part='trigger-label']");
    if (!triggerLabel) return;

    if (this.selectedPreset === "custom") {
      const locale = this.el.dataset.locale || "en-US";
      const formatter = new Intl.DateTimeFormat(locale, {
        day: "2-digit",
        month: "2-digit",
        year: "numeric",
      });
      triggerLabel.textContent = `${formatter.format(startDate)} - ${formatter.format(endDate)}`;
    } else {
      // Find the preset and use its label
      const preset = this.presets.find((p) => p.id === this.selectedPreset);
      if (preset) {
        triggerLabel.textContent = preset.label;
      }
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
    // Initialize calendar months on first render
    if (!this.startCalendarMonth || !this.endCalendarMonth) {
      this.initializeCalendarMonths();
    }

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
    const parseISODate = (str) => {
      if (!str || str.length === 0) return null;
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

      // Get the calendar month for this view (independent navigation)
      const calendarMonth =
        monthIndex === 0 ? this.startCalendarMonth : this.endCalendarMonth;

      if (!calendarMonth) return;

      // Render month title
      const viewTrigger = monthEl.querySelector("[data-part='view-trigger']");
      if (viewTrigger) {
        const date = new Date(calendarMonth.year, calendarMonth.month - 1, 1);
        const monthName = date.toLocaleDateString(
          this.el.dataset.locale || "en-US",
          { month: "long", year: "numeric" },
        );
        viewTrigger.textContent = monthName;
      }

      // Render navigation buttons - each calendar has its own prev/next
      const prevTrigger = monthEl.querySelector("[data-part='prev-trigger']");
      const nextTrigger = monthEl.querySelector("[data-part='next-trigger']");

      // Check if we can navigate prev/next based on min/max constraints for THIS calendar
      let canGoPrev =
        !minDate ||
        calendarMonth.year > minDate.year ||
        (calendarMonth.year === minDate.year &&
          calendarMonth.month > minDate.month);
      let canGoNext =
        !maxDate ||
        calendarMonth.year < maxDate.year ||
        (calendarMonth.year === maxDate.year &&
          calendarMonth.month < maxDate.month);

      // Additional constraint: left calendar must stay before right calendar
      if (monthIndex === 0 && this.endCalendarMonth) {
        // Left calendar: can only go next if result is still before right calendar
        let nextMonth = calendarMonth.month + 1;
        let nextYear = calendarMonth.year;
        if (nextMonth > 12) {
          nextMonth = 1;
          nextYear += 1;
        }
        if (this.compareMonths({ year: nextYear, month: nextMonth }, this.endCalendarMonth) >= 0) {
          canGoNext = false;
        }
      } else if (monthIndex === 1 && this.startCalendarMonth) {
        // Right calendar: can only go prev if result is still after left calendar
        let prevMonth = calendarMonth.month - 1;
        let prevYear = calendarMonth.year;
        if (prevMonth < 1) {
          prevMonth = 12;
          prevYear -= 1;
        }
        if (this.compareMonths({ year: prevYear, month: prevMonth }, this.startCalendarMonth) <= 0) {
          canGoPrev = false;
        }
      }

      // Both prev and next are visible for each calendar
      if (prevTrigger) {
        prevTrigger.style.visibility = "";
        // Remove old handler if switching between months
        if (prevTrigger._navHandlerAttached) {
          prevTrigger.removeEventListener("click", prevTrigger._navHandler);
        }
        // Attach the correct handler based on which calendar
        prevTrigger._navHandler =
          monthIndex === 0
            ? this.handlePrevClickStart
            : this.handlePrevClickEnd;
        prevTrigger.addEventListener("click", prevTrigger._navHandler);
        prevTrigger._navHandlerAttached = true;

        if (!canGoPrev) {
          prevTrigger.disabled = true;
          prevTrigger.style.cursor = "not-allowed";
        } else {
          prevTrigger.disabled = false;
          prevTrigger.style.cursor = "";
        }
      }

      if (nextTrigger) {
        nextTrigger.style.visibility = "";
        // Remove old handler if switching between months
        if (nextTrigger._navHandlerAttached) {
          nextTrigger.removeEventListener("click", nextTrigger._navHandler);
        }
        // Attach the correct handler based on which calendar
        nextTrigger._navHandler =
          monthIndex === 0
            ? this.handleNextClickStart
            : this.handleNextClickEnd;
        nextTrigger.addEventListener("click", nextTrigger._navHandler);
        nextTrigger._navHandlerAttached = true;

        if (!canGoNext) {
          nextTrigger.disabled = true;
          nextTrigger.style.cursor = "not-allowed";
        } else {
          nextTrigger.disabled = false;
          nextTrigger.style.cursor = "";
        }
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

      // Calculate weeks for this calendar's viewed month (independent of Zag's focusedValue)
      const monthWeeks = this.calculateWeeksForMonth(
        calendarMonth.year,
        calendarMonth.month,
      );
      const monthVisibleRange = this.getVisibleRangeForMonth(
        calendarMonth.year,
        calendarMonth.month,
      );

      // Get the selected range from the API
      const selectedValue = this.api.value;
      const rangeStart = selectedValue && selectedValue[0];
      const rangeEnd = selectedValue && selectedValue[1];

      // Get today's date for marking
      const today = new Date();
      const todayValue = {
        year: today.getFullYear(),
        month: today.getMonth() + 1,
        day: today.getDate(),
      };

      // Render day cells
      const rows = monthEl.querySelectorAll(
        "[data-part='table-body'] [data-part='table-row']",
      );
      rows.forEach((row, weekIndex) => {
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

            // Clear stale state from previous renders (but preserve hover-related attrs until Zag sets them)
            trigger.removeAttribute("data-disabled");
            trigger.removeAttribute("data-unavailable");
            trigger.removeAttribute("aria-disabled");
            trigger.removeAttribute("data-outside-range");
            trigger.removeAttribute("data-today");
            trigger.disabled = false;
            cell.removeAttribute("data-disabled");
            cell.removeAttribute("aria-disabled");

            // Get base props from Zag API (for click handlers, accessibility, hover states, etc.)
            const { id: triggerPropsId, ...dayProps } =
              this.api.getDayTableCellTriggerProps({
                value: day,
                visibleRange: monthVisibleRange,
              });
            const { id: cellPropsId, ...cellProps } =
              this.api.getDayTableCellProps({
                value: day,
                visibleRange: monthVisibleRange,
              });

            spreadProps(trigger, dayProps);
            spreadProps(cell, cellProps);

            // For complete selections, manually ensure correct display across both calendars
            // (Zag's visibleRange logic may not work perfectly with our independent calendar navigation)
            if (rangeStart && rangeEnd) {
              const isRangeStart = this.compareDates(day, rangeStart) === 0;
              const isRangeEnd = this.compareDates(day, rangeEnd) === 0;
              const isInRange =
                this.compareDates(day, rangeStart) >= 0 &&
                this.compareDates(day, rangeEnd) <= 0;

              if (isRangeStart) {
                trigger.setAttribute("data-selected", "");
                trigger.setAttribute("data-range-start", "");
                cell.setAttribute("data-range-start", "");
              }
              if (isRangeEnd) {
                trigger.setAttribute("data-selected", "");
                trigger.setAttribute("data-range-end", "");
                cell.setAttribute("data-range-end", "");
              }
              if (isInRange) {
                trigger.setAttribute("data-in-range", "");
                cell.setAttribute("data-in-range", "");
              }
            } else if (rangeStart && !rangeEnd) {
              // Partial selection: first date is selected, show it
              const isRangeStart = this.compareDates(day, rangeStart) === 0;
              if (isRangeStart) {
                trigger.setAttribute("data-selected", "");
                trigger.setAttribute("data-range-start", "");
                cell.setAttribute("data-range-start", "");
              }
              // Let Zag handle the hover preview (data-highlighted, data-in-range during hover)
            }

            // Mark today
            if (this.compareDates(day, todayValue) === 0) {
              trigger.setAttribute("data-today", "");
            }

            // Manually disable dates outside min/max range
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

    // Post-process: mark highlight start/end for proper styling
    this.markHighlightBoundaries();
  }

  // Mark the first and last highlighted cells in each row for proper border radius
  markHighlightBoundaries() {
    const months = this.el.querySelectorAll(
      "[data-part='months'] > [data-part='month']",
    );

    months.forEach((monthEl) => {
      const rows = monthEl.querySelectorAll(
        "[data-part='table-body'] [data-part='table-row']",
      );

      rows.forEach((row) => {
        const cells = row.querySelectorAll("[data-part='table-cell']");

        // Clear previous highlight boundary markers
        cells.forEach((cell) => {
          const trigger = cell.querySelector("[data-part='table-cell-trigger']");
          if (trigger) {
            trigger.removeAttribute("data-highlight-start");
            trigger.removeAttribute("data-highlight-end");
          }
        });

        // Find all highlighted cells in this row (visible ones only)
        const highlightedCells = Array.from(cells).filter((cell) => {
          const trigger = cell.querySelector("[data-part='table-cell-trigger']");
          return (
            trigger &&
            trigger.hasAttribute("data-highlighted") &&
            trigger.style.display !== "none"
          );
        });

        if (highlightedCells.length > 0) {
          // Mark first highlighted cell in row
          const firstTrigger = highlightedCells[0].querySelector(
            "[data-part='table-cell-trigger']",
          );
          if (firstTrigger) {
            firstTrigger.setAttribute("data-highlight-start", "");
          }

          // Mark last highlighted cell in row
          const lastTrigger = highlightedCells[
            highlightedCells.length - 1
          ].querySelector("[data-part='table-cell-trigger']");
          if (lastTrigger) {
            lastTrigger.setAttribute("data-highlight-end", "");
          }
        }
      });
    });
  }

  renderRangeDisplay() {
    const value = this.api.value;

    // Render start date inputs
    const startDisplay = this.el.querySelector(
      "[data-part='date-display'][data-type='start']",
    );
    if (startDisplay) {
      const parts =
        value && value[0]
          ? formatDateParts(value[0].toDate())
          : formatDateParts(null);
      this.updateDateInputs(startDisplay, parts, "start");
    }

    // Render end date inputs
    const endDisplay = this.el.querySelector(
      "[data-part='date-display'][data-type='end']",
    );
    if (endDisplay) {
      const parts =
        value && value[1]
          ? formatDateParts(value[1].toDate())
          : formatDateParts(null);
      this.updateDateInputs(endDisplay, parts, "end");
    }
  }

  updateDateInputs(container, parts, type) {
    const dayInput = container.querySelector("[data-field='day']");
    const monthInput = container.querySelector("[data-field='month']");
    const yearInput = container.querySelector("[data-field='year']");

    // Only update if not focused (don't interrupt user typing)
    if (dayInput && document.activeElement !== dayInput) {
      dayInput.value = parts.day;
    }
    if (monthInput && document.activeElement !== monthInput) {
      monthInput.value = parts.month;
    }
    if (yearInput && document.activeElement !== yearInput) {
      yearInput.value = parts.year;
    }

    // Attach handlers
    this.attachDateFieldHandler(dayInput, container, type);
    this.attachDateFieldHandler(monthInput, container, type);
    this.attachDateFieldHandler(yearInput, container, type);
  }

  attachDateFieldHandler(input, container, type) {
    if (!input || input._dateFieldHandlerAttached) return;
    input._dateFieldHandlerAttached = true;

    // Handle blur to parse and apply the date
    input.addEventListener("blur", () => {
      this.handleDateFieldChange(container, type);
    });

    // Handle Enter key and arrow key navigation
    input.addEventListener("keydown", (e) => {
      if (e.key === "Enter") {
        e.preventDefault();
        this.handleDateFieldChange(container, type);
        input.blur();
        return;
      }

      const cursorPos = input.selectionStart;
      const valueLen = input.value.length;

      // Get all inputs in DOM order for this container
      const inputs = Array.from(
        container.querySelectorAll("[data-part='date-input']"),
      );
      const currentIndex = inputs.indexOf(input);

      // Left arrow at start of field -> go to previous field
      if (e.key === "ArrowLeft" && cursorPos === 0) {
        e.preventDefault();
        if (currentIndex > 0) {
          // Go to previous field in this container
          const prevInput = inputs[currentIndex - 1];
          prevInput.focus();
          prevInput.setSelectionRange(
            prevInput.value.length,
            prevInput.value.length,
          );
        } else if (type === "end") {
          // Jump to start date's last field
          const startDisplay = this.el.querySelector(
            "[data-part='date-display'][data-type='start']",
          );
          if (startDisplay) {
            const startInputs = startDisplay.querySelectorAll(
              "[data-part='date-input']",
            );
            const lastInput = startInputs[startInputs.length - 1];
            if (lastInput) {
              lastInput.focus();
              lastInput.setSelectionRange(
                lastInput.value.length,
                lastInput.value.length,
              );
            }
          }
        }
        return;
      }

      // Right arrow at end of field -> go to next field
      if (e.key === "ArrowRight" && cursorPos === valueLen) {
        e.preventDefault();
        if (currentIndex < inputs.length - 1) {
          // Go to next field in this container
          const nextInput = inputs[currentIndex + 1];
          nextInput.focus();
          nextInput.setSelectionRange(0, 0);
        } else if (type === "start") {
          // Jump to end date's first field
          const endDisplay = this.el.querySelector(
            "[data-part='date-display'][data-type='end']",
          );
          if (endDisplay) {
            const firstInput = endDisplay.querySelector(
              "[data-part='date-input']",
            );
            if (firstInput) {
              firstInput.focus();
              firstInput.setSelectionRange(0, 0);
            }
          }
        }
        return;
      }
    });

    // Auto-advance to next field when maxlength reached
    input.addEventListener("input", () => {
      if (input.value.length >= parseInt(input.maxLength, 10)) {
        const inputs = Array.from(
          container.querySelectorAll("[data-part='date-input']"),
        );
        const currentIndex = inputs.indexOf(input);

        if (currentIndex < inputs.length - 1) {
          // Move to next field
          inputs[currentIndex + 1].focus();
        } else {
          // Last field (year) complete - update the calendar immediately
          this.handleDateFieldChange(container, type);
        }
      }
    });
  }

  handleDateFieldChange(container, type) {
    const dayInput = container.querySelector("[data-field='day']");
    const monthInput = container.querySelector("[data-field='month']");
    const yearInput = container.querySelector("[data-field='year']");

    const day = dayInput?.value || "";
    const month = monthInput?.value || "";
    const year = yearInput?.value || "";

    // Don't validate if fields are incomplete
    if (!day || !month || !year || year.length < 4) return;

    const parsed = parseDateFromParts(day, month, year);
    if (!parsed) {
      // Invalid date - restore previous values
      this.restoreDateInputs(container, type);
      return;
    }

    // Check against min/max constraints
    if (this.minDate) {
      const minJs = new Date(
        this.minDate.year,
        this.minDate.month - 1,
        this.minDate.day,
      );
      if (parsed < minJs) {
        this.restoreDateInputs(container, type);
        return;
      }
    }
    if (this.maxDate) {
      const maxJs = new Date(
        this.maxDate.year,
        this.maxDate.month - 1,
        this.maxDate.day,
      );
      if (parsed > maxJs) {
        this.restoreDateInputs(container, type);
        return;
      }
    }

    // Convert to Zag DateValue
    const dateStr = `${parsed.getFullYear()}-${String(parsed.getMonth() + 1).padStart(2, "0")}-${String(parsed.getDate()).padStart(2, "0")}`;
    const newDateValue = datePicker.parse(dateStr);

    if (!newDateValue) {
      this.restoreDateInputs(container, type);
      return;
    }

    // Update the value based on type
    const currentValue = this.api.value || [];
    let newValue;

    if (type === "start") {
      const endDate = currentValue[1] || newDateValue;
      // Ensure start is not after end
      if (this.compareDates(newDateValue, endDate) > 0) {
        newValue = [newDateValue, newDateValue];
      } else {
        newValue = [newDateValue, endDate];
      }
    } else {
      const startDate = currentValue[0] || newDateValue;
      // Ensure end is not before start
      if (this.compareDates(newDateValue, startDate) < 0) {
        newValue = [newDateValue, newDateValue];
      } else {
        newValue = [startDate, newDateValue];
      }
    }

    // Switch to custom preset when manually entering dates
    if (this.selectedPreset !== "custom") {
      this.selectedPreset = "custom";
      this.updatePresetSelection("custom");
    }

    this.isSettingPreset = true;
    this.api.setValue(newValue);
    setTimeout(() => {
      this.isSettingPreset = false;
    }, 0);
  }

  restoreDateInputs(container, type) {
    const value = this.api.value;
    let parts;

    if (type === "start" && value && value[0]) {
      parts = formatDateParts(value[0].toDate());
    } else if (type === "end" && value && value[1]) {
      parts = formatDateParts(value[1].toDate());
    } else {
      parts = { day: "", month: "", year: "" };
    }

    const dayInput = container.querySelector("[data-field='day']");
    const monthInput = container.querySelector("[data-field='month']");
    const yearInput = container.querySelector("[data-field='year']");

    if (dayInput) dayInput.value = parts.day;
    if (monthInput) monthInput.value = parts.month;
    if (yearInput) yearInput.value = parts.year;
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
      valueStart: getOption(this.el, "valueStart"),
      valueEnd: getOption(this.el, "valueEnd"),
      min: getOption(this.el, "min"),
      max: getOption(this.el, "max"),
    };
  },
};
