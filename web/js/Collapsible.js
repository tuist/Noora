import * as collapsible from "@zag-js/collapsible";
import {
  getBooleanOption,
  normalizeProps,
  renderPart,
  getPartSelector,
  spreadProps,
} from "./util.js";
import { Component } from "./component.js";
import { VanillaMachine } from "./machine.js";

class Collapsible extends Component {
  initMachine(context) {
    return new VanillaMachine(collapsible.machine, context);
  }

  initApi() {
    return collapsible.connect(this.machine.service, normalizeProps);
  }

  render() {
    // Render root and content with direct child selectors
    renderPart(this.el, "root", this.api);
    renderPart(this.el, "root:content", this.api);

    // Find trigger anywhere inside root but not inside content
    const root = this.el.querySelector(":scope > [data-part='root']");
    if (root) {
      const content = root.querySelector(":scope > [data-part='content']");
      const triggers = root.querySelectorAll("[data-part='trigger']");
      for (const trigger of triggers) {
        if (!content || !content.contains(trigger)) {
          if (typeof this.api.getTriggerProps === "function") {
            spreadProps(trigger, this.api.getTriggerProps());
          }
          break;
        }
      }
    }
  }
}

export default {
  mounted() {
    this.collapsible = new Collapsible(this.el, this.context());
    this.collapsible.init();
  },

  updated() {
    this.collapsible.render();
  },

  beforeDestroy() {
    this.collapsible.destroy();
  },

  context() {
    return {
      id: this.el.id,
      disabled: getBooleanOption(this.el, "disabled"),
      defaultOpen: getBooleanOption(this.el, "open"),
      onOpenChange: (details) => {
        if (this.el.dataset.onOpenChange) {
          this.pushEvent(this.el.dataset.onOpenChange, details);
        }
      },
    };
  },
};
