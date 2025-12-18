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
  }

  initMachine(context) {
    // Calculate initial value from selected preset if present
    const initialValue = this.getInitialValueFromPreset();
    const forceOpen = getBooleanOption(this.el, "open");

    const machineContext = {
      ...context,
      selectionMode: "range",
      numOfMonths: this.isMobileView ? 1 : 2,
      fixedWeeks: true,
      closeOnSelect: false,
      value: initialValue,
      positioning: {
        zIndex: 50,
        offset: { mainAxis: 8 },
      },
    };

    // Only set open if explicitly true (for storybook), otherwise let Zag handle it
    if (forceOpen) {
      machineContext.open = true;
    }

    return new VanillaMachine(datePicker.machine, machineContext);
  }

  getInitialValueFromPreset() {
    if (!this.selectedPreset || !this.presets.length) return undefined;

    const preset = this.presets.find((p) => p.id === this.selectedPreset);
    if (!preset || !preset.duration) return undefined;

    const range = calculateRangeFromDuration(preset.duration);

    // Convert to Zag's date format (array of DateValue-like objects)
    return [this.dateToZagValue(range.start), this.dateToZagValue(range.end)];
  }

  dateToZagValue(date) {
    return {
      year: date.getFullYear(),
      month: date.getMonth() + 1,
      day: date.getDate(),
    };
  }

  initApi() {
    return datePicker.connect(this.machine.service, normalizeProps);
  }

  init() {
    super.init();
    this.setupTriggerFallback();
    this.setupPresetListeners();
    this.setupActionListeners();
    this.setupResizeListener();
    this.updatePresetSelection(this.selectedPreset);
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

  setupPresetListeners() {
    const presetButtons = this.el.querySelectorAll("[data-part='preset-item']");
    presetButtons.forEach((btn) => {
      btn.addEventListener("click", (e) => this.handlePresetClick(e));
    });
  }

  setupActionListeners() {
    const cancelBtn = this.el.querySelector("[data-part='cancel']");
    const applyBtn = this.el.querySelector("[data-part='apply']");

    if (cancelBtn) {
      cancelBtn.addEventListener("click", () => this.handleCancel());
    }
    if (applyBtn) {
      applyBtn.addEventListener("click", () => this.handleApply());
    }
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

  handlePresetClick(e) {
    const presetId = e.currentTarget.dataset.presetId;
    const preset = this.presets.find((p) => p.id === presetId);

    if (!preset) return;

    this.selectedPreset = presetId;
    this.updatePresetSelection(presetId);

    if (preset.duration) {
      // Calculate the range and emit immediately, then close
      const range = calculateRangeFromDuration(preset.duration);
      this.emitValueChange(range.start, range.end, presetId);
      this.close();
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
    const months = this.el.querySelectorAll("[data-part='month']");
    const offset = this.api.getOffset({ months: 0 });
    const weeks = this.api.weeks;
    const weekDays = this.api.weekDays;

    months.forEach((monthEl, monthIndex) => {
      // Only render first month on mobile
      if (this.isMobileView && monthIndex > 0) return;

      const monthOffset = this.api.getOffset({ months: monthIndex });

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

      if (prevTrigger && monthIndex === 0) {
        spreadProps(prevTrigger, this.api.getPrevTriggerProps());
      } else if (prevTrigger) {
        prevTrigger.style.visibility = "hidden";
      }

      if (nextTrigger && monthIndex === months.length - 1) {
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

      // Get the weeks for this month
      const monthWeeks = this.getWeeksForMonth(monthIndex);

      // Render day cells
      const rows = monthEl.querySelectorAll(
        "[data-part='table-body'] [data-part='table-row']",
      );
      rows.forEach((row, weekIndex) => {
        const cells = row.querySelectorAll("[data-part='day-table-cell']");
        const week = monthWeeks[weekIndex];

        cells.forEach((cell, dayIndex) => {
          const trigger = cell.querySelector(
            "[data-part='table-cell-trigger']",
          );
          if (!trigger) return;

          if (week && week[dayIndex]) {
            const day = week[dayIndex];
            trigger.textContent = day.day;

            // Get props from Zag API, but exclude id to avoid duplicates in multi-month view
            const { id: triggerPropsId, ...dayProps } =
              this.api.getDayTableCellTriggerProps({ value: day });
            const { id: cellPropsId, ...cellProps } =
              this.api.getDayTableCellProps({ value: day });

            spreadProps(trigger, dayProps);
            spreadProps(cell, cellProps);

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
    // Get weeks array - each week contains days for all visible months
    const weeks = this.api.weeks;
    if (!weeks) return [];

    // For dual-month view, we need to split the weeks
    // Zag provides weeks for the current view
    return weeks.map((week) => {
      if (this.isMobileView || monthIndex === 0) {
        // Return days for first month (first 7 days or filtered by month)
        return week.slice(0, 7);
      } else {
        // For second month in dual view, we might need offset
        // Zag.js handles this internally via getOffset
        return week.slice(0, 7);
      }
    });
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
  },

  updated() {
    this.datePicker.render();
  },

  beforeDestroy() {
    this.datePicker.destroy();
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
    };
  },
};
