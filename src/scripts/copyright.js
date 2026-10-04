import { COPY_YEAR_ID } from "./constants";

export const Copyright = (() => {
  const copyYearElement = document.getElementById(COPY_YEAR_ID);
  const today = new Date();

  return { init };

  function init() {
    if (copyYearElement) {
      copyYearElement.textContent = today.getFullYear();
    }
  }
})();
