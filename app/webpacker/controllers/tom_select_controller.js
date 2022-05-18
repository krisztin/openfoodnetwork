import { Controller } from "stimulus";
import TomSelect from "tom-select";

export default class extends Controller {
  static values = { options: Object };
  static defaults = {
    maxItems: 1,
    maxOptions: null,
    plugins: ["dropdown_input"],
    allowEmptyOption: true,
  };

  connect(options = {}) {
    this.control = new TomSelect(this.element, {
      ...this.constructor.defaults,
      ...this.optionsValue,
      ...options,
    });
  }

  disconnect() {
    if (this.control) this.control.destroy();
  }
}
