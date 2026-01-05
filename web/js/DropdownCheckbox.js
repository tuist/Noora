/**
 * Phoenix LiveView Hook for dropdown checkbox items.
 * Handles clicks on the checkbox to toggle without closing the dropdown,
 * while clicks on the label toggle and close the dropdown.
 */
export default {
  mounted() {
    this.handleClick = (event) => {
      const checkbox = this.el.querySelector('[data-part="checkbox"]');
      const clickedOnCheckbox = checkbox && checkbox.contains(event.target);

      // Stop propagation so zag-js doesn't interfere
      event.stopPropagation();

      // Trigger the phx-click event
      const phxClick = this.el.getAttribute("phx-click");
      if (phxClick) {
        const values = {};
        for (const attr of this.el.attributes) {
          if (attr.name.startsWith("phx-value-")) {
            const key = attr.name.replace("phx-value-", "");
            values[key] = attr.value;
          }
        }
        this.pushEvent(phxClick, values);
      }

      // Close dropdown if clicked on label (not checkbox)
      if (!clickedOnCheckbox) {
        const dropdown = this.el.closest(".noora-dropdown");
        if (dropdown) {
          window.dispatchEvent(
            new CustomEvent("phx:close-dropdown", {
              detail: { id: dropdown.id },
            })
          );
        }
      }
    };

    this.el.addEventListener("click", this.handleClick);
  },

  destroyed() {
    this.el.removeEventListener("click", this.handleClick);
  },
};
