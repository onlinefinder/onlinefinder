// SPDX-License-Identifier: AGPL-3.0-or-later

import { http, listen, settings } from "../toolkit.ts";
import { assertElement } from "../util/assertElement.ts";

let engineDescriptions: Record<string, [string, string]> | undefined;

const loadEngineDescriptions = async (): Promise<void> => {
  if (engineDescriptions) return;
  try {
    const res = await http("GET", "engine_descriptions.json");
    engineDescriptions = await res.json();
  } catch (error) {
    console.error("Error fetching engineDescriptions:", error);
  }
  if (!engineDescriptions) return;

  for (const [engine_name, [description, source]] of Object.entries(engineDescriptions)) {
    const elements = document.querySelectorAll<HTMLElement>(`[data-engine-name="${engine_name}"] .engine-description`);
    const sourceText = ` (<i>${settings.translations?.Source}:&nbsp;${source}</i>)`;

    for (const element of elements) {
      element.innerHTML = description + sourceText;
    }
  }
};

const toggleEngines = (enable: boolean, engineToggles: NodeListOf<HTMLInputElement>): void => {
  for (const engineToggle of engineToggles) {
    // check if element visible, so that only engines of the current category are modified
    if (engineToggle.offsetParent) {
      engineToggle.checked = !enable;
    }
  }
};

const engineElements: NodeListOf<HTMLElement> = document.querySelectorAll<HTMLElement>("[data-engine-name]");
for (const engineElement of engineElements) {
  listen("mouseenter", engineElement, loadEngineDescriptions);
}

const engineToggles: NodeListOf<HTMLInputElement> = document.querySelectorAll<HTMLInputElement>(
  "tbody input[type=checkbox][class~=checkbox-onoff]"
);

const enableAllEngines: NodeListOf<HTMLElement> = document.querySelectorAll<HTMLElement>(".enable-all-engines");
for (const engine of enableAllEngines) {
  listen("click", engine, () => toggleEngines(true, engineToggles));
}

const disableAllEngines: NodeListOf<HTMLElement> = document.querySelectorAll<HTMLElement>(".disable-all-engines");
for (const engine of disableAllEngines) {
  listen("click", engine, () => toggleEngines(false, engineToggles));
}

listen("click", "#copy-hash", async function (this: HTMLElement) {
  const target = this.parentElement?.querySelector<HTMLPreElement>("pre");
  assertElement(target);

  if (window.isSecureContext) {
    await navigator.clipboard.writeText(target.innerText);
  } else {
    const selection = window.getSelection();
    if (selection) {
      const range = document.createRange();
      range.selectNodeContents(target);
      selection.removeAllRanges();
      selection.addRange(range);
      document.execCommand("copy");
    }
  }

  const copiedText = this.dataset.copiedText;
  if (copiedText) {
    this.innerText = copiedText;
  }
});

const volumeSlider = document.getElementById("alarm_volume") as HTMLInputElement | null;
const volumeDisplay = document.getElementById("alarm_volume_display");
if (volumeSlider && volumeDisplay) {
  volumeSlider.addEventListener("input", () => {
    volumeDisplay.textContent = `${volumeSlider.value}%`;
  });
}

const testSoundBtn = document.getElementById("test_alarm_sound") as HTMLButtonElement | null;
const alarmSoundSelect = document.getElementById("alarm_sound") as HTMLSelectElement | null;
if (testSoundBtn && alarmSoundSelect && volumeSlider) {
  let isPlaying = false;
  const originalText = testSoundBtn.textContent || "Test";

  testSoundBtn.addEventListener("click", () => {
    const testFn = (window as Window & { testAlarmSound?: (sound: string, volume: number) => void }).testAlarmSound;
    const stopFn = (window as Window & { stopAlarmSound?: () => void }).stopAlarmSound;

    if (isPlaying) {
      if (stopFn) stopFn();
      testSoundBtn.textContent = originalText;
      isPlaying = false;
    } else {
      if (testFn) {
        testFn(alarmSoundSelect.value, Number.parseInt(volumeSlider.value, 10));
        testSoundBtn.textContent = "Stop";
        isPlaying = true;
      }
    }
  });
}

const CLOCK_SETTINGS_SAVED_KEY = "clockSettingsSaved";
const NOTIFICATION_DISPLAY_DURATION = 3000;
const NOTIFICATION_FADE_DURATION = 300;

const hasClockSettings = (): boolean => {
  return (
    document.getElementById("clock_enabled") !== null ||
    document.getElementById("clock_format") !== null ||
    document.getElementById("alarm_time") !== null ||
    document.getElementById("alarm_sound") !== null ||
    document.getElementById("alarm_volume") !== null
  );
};

const showClockSavedNotification = (): void => {
  const notification = document.createElement("div");
  notification.className = "clock-saved-notification";
  notification.textContent = "Clock settings saved!";
  notification.setAttribute("role", "alert");
  document.body.appendChild(notification);

  requestAnimationFrame(() => {
    notification.classList.add("show");
  });

  setTimeout(() => {
    notification.classList.remove("show");
    setTimeout(() => notification.remove(), NOTIFICATION_FADE_DURATION);
  }, NOTIFICATION_DISPLAY_DURATION);
};

const preferencesForm = document.getElementById("search_form") as HTMLFormElement | null;
if (preferencesForm) {
  preferencesForm.addEventListener("submit", () => {
    if (hasClockSettings()) {
      sessionStorage.setItem(CLOCK_SETTINGS_SAVED_KEY, "true");
    }
  });

  if (sessionStorage.getItem(CLOCK_SETTINGS_SAVED_KEY) === "true") {
    sessionStorage.removeItem(CLOCK_SETTINGS_SAVED_KEY);
    showClockSavedNotification();
  }
}

const notificationBtn = document.getElementById("enable_notifications");
const notificationStatus = document.getElementById("notification_status");
if (notificationBtn && notificationStatus) {
  const updateNotificationStatus = (): void => {
    if (!("Notification" in window)) {
      notificationStatus.textContent = "Not supported";
      notificationStatus.className = "notification-status denied";
      notificationBtn.style.display = "none";
      return;
    }
    if (Notification.permission === "granted") {
      notificationStatus.textContent = "Enabled";
      notificationStatus.className = "notification-status granted";
      notificationBtn.style.display = "none";
    } else if (Notification.permission === "denied") {
      notificationStatus.textContent = "Blocked";
      notificationStatus.className = "notification-status denied";
      notificationBtn.style.display = "none";
    } else {
      notificationStatus.textContent = "";
      notificationBtn.style.display = "inline-block";
    }
  };

  updateNotificationStatus();

  notificationBtn.addEventListener("click", async () => {
    const reqFn = (window as Window & { requestNotificationPermission?: () => Promise<boolean> }).requestNotificationPermission;
    if (reqFn) {
      await reqFn();
    } else if ("Notification" in window) {
      await Notification.requestPermission();
    }
    updateNotificationStatus();
  });
}
