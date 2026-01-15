// SPDX-License-Identifier: AGPL-3.0-or-later

import { ready, endpoint, Endpoints } from "../toolkit.ts";

// Audio context for Web Audio API sounds
let audioContext: AudioContext | null = null;
let currentOscillators: OscillatorNode[] = [];
let currentGainNodes: GainNode[] = [];
let alarmInterval: number | null = null;

// Sound generators using Web Audio API
const AlarmSounds = {
  // Peaceful sounds
  gentle_birds: (ctx: AudioContext, volume: number): void => {
    // Chirping birds - high frequency warbles
    const playChirp = () => {
      const osc = ctx.createOscillator();
      const gain = ctx.createGain();
      osc.type = "sine";
      osc.frequency.setValueAtTime(2000 + Math.random() * 1000, ctx.currentTime);
      osc.frequency.exponentialRampToValueAtTime(3000 + Math.random() * 500, ctx.currentTime + 0.05);
      osc.frequency.exponentialRampToValueAtTime(1800 + Math.random() * 400, ctx.currentTime + 0.1);
      gain.gain.setValueAtTime(0, ctx.currentTime);
      gain.gain.linearRampToValueAtTime(volume * 0.3, ctx.currentTime + 0.02);
      gain.gain.linearRampToValueAtTime(0, ctx.currentTime + 0.15);
      osc.connect(gain).connect(ctx.destination);
      osc.start(ctx.currentTime);
      osc.stop(ctx.currentTime + 0.15);
      currentOscillators.push(osc);
      currentGainNodes.push(gain);
    };
    for (let i = 0; i < 5; i++) {
      setTimeout(playChirp, i * 200 + Math.random() * 100);
    }
  },

  ocean_waves: (ctx: AudioContext, volume: number): void => {
    // White noise filtered to sound like waves
    const bufferSize = ctx.sampleRate * 2;
    const buffer = ctx.createBuffer(1, bufferSize, ctx.sampleRate);
    const data = buffer.getChannelData(0);
    for (let i = 0; i < bufferSize; i++) {
      data[i] = Math.random() * 2 - 1;
    }
    const noise = ctx.createBufferSource();
    noise.buffer = buffer;
    const filter = ctx.createBiquadFilter();
    filter.type = "lowpass";
    filter.frequency.setValueAtTime(400, ctx.currentTime);
    filter.frequency.linearRampToValueAtTime(800, ctx.currentTime + 1);
    filter.frequency.linearRampToValueAtTime(300, ctx.currentTime + 2);
    const gain = ctx.createGain();
    gain.gain.setValueAtTime(0, ctx.currentTime);
    gain.gain.linearRampToValueAtTime(volume * 0.4, ctx.currentTime + 0.5);
    gain.gain.linearRampToValueAtTime(volume * 0.2, ctx.currentTime + 1.5);
    gain.gain.linearRampToValueAtTime(0, ctx.currentTime + 2);
    noise.connect(filter).connect(gain).connect(ctx.destination);
    noise.start();
    noise.stop(ctx.currentTime + 2);
    currentGainNodes.push(gain);
  },

  soft_chimes: (ctx: AudioContext, volume: number): void => {
    // Wind chimes - multiple high harmonics
    const frequencies = [523.25, 659.25, 783.99, 1046.5, 1318.5]; // C5, E5, G5, C6, E6
    frequencies.forEach((freq, i) => {
      setTimeout(() => {
        const osc = ctx.createOscillator();
        const gain = ctx.createGain();
        osc.type = "sine";
        osc.frequency.value = freq;
        gain.gain.setValueAtTime(0, ctx.currentTime);
        gain.gain.linearRampToValueAtTime(volume * 0.25, ctx.currentTime + 0.01);
        gain.gain.exponentialRampToValueAtTime(0.001, ctx.currentTime + 2);
        osc.connect(gain).connect(ctx.destination);
        osc.start();
        osc.stop(ctx.currentTime + 2);
        currentOscillators.push(osc);
        currentGainNodes.push(gain);
      }, i * 300);
    });
  },

  morning_forest: (ctx: AudioContext, volume: number): void => {
    // Combination of bird-like sounds and gentle rustling
    // Low rumble (wind through trees)
    const noise = ctx.createBufferSource();
    const bufferSize = ctx.sampleRate * 2;
    const buffer = ctx.createBuffer(1, bufferSize, ctx.sampleRate);
    const data = buffer.getChannelData(0);
    for (let i = 0; i < bufferSize; i++) {
      data[i] = Math.random() * 2 - 1;
    }
    noise.buffer = buffer;
    const filter = ctx.createBiquadFilter();
    filter.type = "lowpass";
    filter.frequency.value = 200;
    const gain = ctx.createGain();
    gain.gain.value = volume * 0.15;
    noise.connect(filter).connect(gain).connect(ctx.destination);
    noise.start();
    noise.stop(ctx.currentTime + 2);
    currentGainNodes.push(gain);
    // Bird sounds on top
    AlarmSounds.gentle_birds(ctx, volume * 0.7);
  },

  // Moderate sounds
  meditation_bell: (ctx: AudioContext, volume: number): void => {
    // Deep resonant bell sound
    const fundamental = 220; // A3
    const harmonics = [1, 2.4, 3.8, 5.4];
    harmonics.forEach((mult, i) => {
      const osc = ctx.createOscillator();
      const gain = ctx.createGain();
      osc.type = "sine";
      osc.frequency.value = fundamental * mult;
      const harmGain = volume * (0.5 / (i + 1));
      gain.gain.setValueAtTime(harmGain, ctx.currentTime);
      gain.gain.exponentialRampToValueAtTime(0.001, ctx.currentTime + 4);
      osc.connect(gain).connect(ctx.destination);
      osc.start();
      osc.stop(ctx.currentTime + 4);
      currentOscillators.push(osc);
      currentGainNodes.push(gain);
    });
  },

  gentle_piano: (ctx: AudioContext, volume: number): void => {
    // Piano-like tones (C major arpeggio)
    const notes = [261.63, 329.63, 392.0, 523.25]; // C4, E4, G4, C5
    notes.forEach((freq, i) => {
      setTimeout(() => {
        const osc = ctx.createOscillator();
        const osc2 = ctx.createOscillator();
        const gain = ctx.createGain();
        osc.type = "triangle";
        osc2.type = "sine";
        osc.frequency.value = freq;
        osc2.frequency.value = freq * 2;
        gain.gain.setValueAtTime(volume * 0.3, ctx.currentTime);
        gain.gain.exponentialRampToValueAtTime(0.001, ctx.currentTime + 1.5);
        osc.connect(gain);
        osc2.connect(gain);
        gain.connect(ctx.destination);
        osc.start();
        osc2.start();
        osc.stop(ctx.currentTime + 1.5);
        osc2.stop(ctx.currentTime + 1.5);
        currentOscillators.push(osc, osc2);
        currentGainNodes.push(gain);
      }, i * 400);
    });
  },

  classic_alarm: (ctx: AudioContext, volume: number): void => {
    // Classic mechanical alarm clock - dual bells
    const ring = (time: number) => {
      const osc = ctx.createOscillator();
      const gain = ctx.createGain();
      osc.type = "square";
      osc.frequency.setValueAtTime(1200, ctx.currentTime + time);
      gain.gain.setValueAtTime(0, ctx.currentTime + time);
      gain.gain.linearRampToValueAtTime(volume * 0.2, ctx.currentTime + time + 0.01);
      gain.gain.linearRampToValueAtTime(0, ctx.currentTime + time + 0.05);
      osc.connect(gain).connect(ctx.destination);
      osc.start(ctx.currentTime + time);
      osc.stop(ctx.currentTime + time + 0.05);
      currentOscillators.push(osc);
      currentGainNodes.push(gain);
    };
    for (let i = 0; i < 20; i++) {
      ring(i * 0.1);
    }
  },

  digital_beep: (ctx: AudioContext, volume: number): void => {
    // Simple digital watch beep pattern
    const beep = (time: number, duration: number) => {
      const osc = ctx.createOscillator();
      const gain = ctx.createGain();
      osc.type = "square";
      osc.frequency.value = 1000;
      gain.gain.setValueAtTime(volume * 0.25, ctx.currentTime + time);
      gain.gain.setValueAtTime(0, ctx.currentTime + time + duration);
      osc.connect(gain).connect(ctx.destination);
      osc.start(ctx.currentTime + time);
      osc.stop(ctx.currentTime + time + duration + 0.01);
      currentOscillators.push(osc);
      currentGainNodes.push(gain);
    };
    // Pattern: beep beep beep - beep beep beep
    beep(0, 0.1);
    beep(0.2, 0.1);
    beep(0.4, 0.1);
    beep(0.8, 0.1);
    beep(1.0, 0.1);
    beep(1.2, 0.1);
  },

  // Abrupt sounds
  urgent_buzzer: (ctx: AudioContext, volume: number): void => {
    // Industrial buzzer sound
    const osc = ctx.createOscillator();
    const osc2 = ctx.createOscillator();
    const gain = ctx.createGain();
    osc.type = "sawtooth";
    osc2.type = "square";
    osc.frequency.value = 150;
    osc2.frequency.value = 155;
    gain.gain.value = volume * 0.35;
    osc.connect(gain);
    osc2.connect(gain);
    gain.connect(ctx.destination);
    osc.start();
    osc2.start();
    // Pulsing
    const lfo = ctx.createOscillator();
    const lfoGain = ctx.createGain();
    lfo.frequency.value = 8;
    lfoGain.gain.value = volume * 0.15;
    lfo.connect(lfoGain).connect(gain.gain);
    lfo.start();
    setTimeout(() => {
      osc.stop();
      osc2.stop();
      lfo.stop();
    }, 2000);
    currentOscillators.push(osc, osc2, lfo);
    currentGainNodes.push(gain, lfoGain);
  },

  retro_alarm: (ctx: AudioContext, volume: number): void => {
    // Old-fashioned mechanical bell alarm (more aggressive)
    const hit = (time: number, freq: number) => {
      const osc = ctx.createOscillator();
      const gain = ctx.createGain();
      osc.type = "triangle";
      osc.frequency.setValueAtTime(freq, ctx.currentTime + time);
      osc.frequency.exponentialRampToValueAtTime(freq * 0.5, ctx.currentTime + time + 0.2);
      gain.gain.setValueAtTime(volume * 0.4, ctx.currentTime + time);
      gain.gain.exponentialRampToValueAtTime(0.001, ctx.currentTime + time + 0.2);
      osc.connect(gain).connect(ctx.destination);
      osc.start(ctx.currentTime + time);
      osc.stop(ctx.currentTime + time + 0.2);
      currentOscillators.push(osc);
      currentGainNodes.push(gain);
    };
    for (let i = 0; i < 16; i++) {
      hit(i * 0.125, i % 2 === 0 ? 2400 : 2000);
    }
  },

  starship_alert: (ctx: AudioContext, volume: number): void => {
    // Star Trek style alert - sweeping tones
    const osc = ctx.createOscillator();
    const gain = ctx.createGain();
    osc.type = "sine";
    gain.gain.value = volume * 0.35;
    osc.connect(gain).connect(ctx.destination);
    // Sweep up and down
    osc.frequency.setValueAtTime(400, ctx.currentTime);
    osc.frequency.linearRampToValueAtTime(800, ctx.currentTime + 0.5);
    osc.frequency.linearRampToValueAtTime(400, ctx.currentTime + 1);
    osc.frequency.linearRampToValueAtTime(800, ctx.currentTime + 1.5);
    osc.frequency.linearRampToValueAtTime(400, ctx.currentTime + 2);
    osc.start();
    osc.stop(ctx.currentTime + 2);
    currentOscillators.push(osc);
    currentGainNodes.push(gain);
  },

  red_alert: (ctx: AudioContext, volume: number): void => {
    // Emergency klaxon - very urgent
    const osc = ctx.createOscillator();
    const osc2 = ctx.createOscillator();
    const gain = ctx.createGain();
    osc.type = "sawtooth";
    osc2.type = "square";
    gain.gain.value = volume * 0.4;
    osc.connect(gain);
    osc2.connect(gain);
    gain.connect(ctx.destination);
    // Alternating two-tone siren
    const pattern = [600, 450];
    let idx = 0;
    const interval = setInterval(() => {
      osc.frequency.value = pattern[idx];
      osc2.frequency.value = pattern[idx] * 1.5;
      idx = (idx + 1) % 2;
    }, 250);
    osc.start();
    osc2.start();
    setTimeout(() => {
      clearInterval(interval);
      osc.stop();
      osc2.stop();
    }, 2000);
    currentOscillators.push(osc, osc2);
    currentGainNodes.push(gain);
  }
};

// Stop any currently playing alarm
const stopAlarm = (): void => {
  if (alarmInterval) {
    clearInterval(alarmInterval);
    alarmInterval = null;
  }
  for (const osc of currentOscillators) {
    try {
      osc.stop();
    } catch {
      // Already stopped
    }
  }
  for (const gain of currentGainNodes) {
    try {
      gain.disconnect();
    } catch {
      // Already disconnected
    }
  }
  currentOscillators = [];
  currentGainNodes = [];
};

// Play alarm sound
const playAlarmSound = (soundName: string, volume: number): void => {
  stopAlarm();

  if (!audioContext) {
    audioContext = new AudioContext();
  }

  const normalizedVolume = Math.max(0, Math.min(1, volume / 100));
  const soundFn = AlarmSounds[soundName as keyof typeof AlarmSounds];

  if (soundFn) {
    soundFn(audioContext, normalizedVolume);
  }
};

// Play alarm with repeat
const playAlarmWithRepeat = (soundName: string, volume: number): void => {
  playAlarmSound(soundName, volume);
  // Repeat every 3 seconds
  alarmInterval = window.setInterval(() => {
    playAlarmSound(soundName, volume);
  }, 3000);
};

// Request notification permission
const requestNotificationPermission = async (): Promise<boolean> => {
  if (!("Notification" in window)) {
    return false;
  }
  if (Notification.permission === "granted") {
    return true;
  }
  if (Notification.permission !== "denied") {
    const permission = await Notification.requestPermission();
    return permission === "granted";
  }
  return false;
};

// Show browser notification
const showNotification = (title: string, body: string): void => {
  if (Notification.permission === "granted") {
    new Notification(title, {
      body: body,
      icon: "/static/themes/simple/img/onlinefinder.png",
      requireInteraction: true
    });
  }
};

// Format time based on settings
const formatTime = (date: Date, format: string): { time: string; period: string } => {
  let hours = date.getHours();
  const minutes = date.getMinutes().toString().padStart(2, "0");
  const seconds = date.getSeconds().toString().padStart(2, "0");
  let period = "";

  if (format === "12h") {
    period = hours >= 12 ? "PM" : "AM";
    hours = hours % 12 || 12;
  }

  const time = `${hours.toString().padStart(2, "0")}:${minutes}:${seconds}`;
  return { time: time, period: period };
};

// Regex for parsing alarm time
const ALARM_TIME_REGEX = /^(\d{1,2}):(\d{2})$/;

// Parse alarm time string (HH:MM)
const parseAlarmTime = (timeStr: string): { hours: number; minutes: number } | null => {
  if (!timeStr) return null;
  const match = timeStr.match(ALARM_TIME_REGEX);
  if (!match) return null;
  return {
    hours: Number.parseInt(match[1], 10),
    minutes: Number.parseInt(match[2], 10)
  };
};

// Check if alarm should trigger
const checkAlarm = (alarmTime: { hours: number; minutes: number }, lastTriggered: string | null): boolean => {
  const now = new Date();
  const currentHours = now.getHours();
  const currentMinutes = now.getMinutes();
  const currentKey = `${currentHours}:${currentMinutes}`;

  // Only trigger once per minute
  if (lastTriggered === currentKey) return false;

  return currentHours === alarmTime.hours && currentMinutes === alarmTime.minutes;
};

const ALARM_TOGGLE_KEY = "onlinefinder_alarm_enabled";

const getAlarmToggleState = (preferenceEnabled: boolean): boolean => {
  const stored = localStorage.getItem(ALARM_TOGGLE_KEY);
  return stored === null ? preferenceEnabled : stored === "true";
};

const setAlarmToggleState = (enabled: boolean): void => {
  localStorage.setItem(ALARM_TOGGLE_KEY, String(enabled));
};

// Initialize clock
const initClock = (): void => {
  const clockElement = document.getElementById("digital-clock");
  if (!clockElement) return;

  const enabled = clockElement.dataset.enabled === "true";
  if (!enabled) return;

  // Show the clock
  clockElement.style.display = "block";

  const format = clockElement.dataset.format || "12h";
  const alarmEnabledPref = clockElement.dataset.alarmEnabled === "true";
  const alarmTimeStr = clockElement.dataset.alarmTime || "";
  const alarmSound = clockElement.dataset.alarmSound || "gentle_birds";
  const alarmVolume = Number.parseInt(clockElement.dataset.alarmVolume || "50", 10);

  const clockTimeEl = document.getElementById("clock-time");
  const clockPeriodEl = document.getElementById("clock-period");
  const alarmIndicatorEl = document.getElementById("alarm-indicator");
  const alarmTimeDisplayEl = document.getElementById("alarm-time-display");
  const alarmToggleEl = document.getElementById("alarm-toggle");

  const alarmTime = parseAlarmTime(alarmTimeStr);

  let alarmEnabled = getAlarmToggleState(alarmEnabledPref);

  const getFormattedAlarmTime = (): string => {
    if (!alarmTime) return "";
    if (format === "12h") {
      const h = alarmTime.hours % 12 || 12;
      const p = alarmTime.hours >= 12 ? "PM" : "AM";
      return `${h}:${alarmTime.minutes.toString().padStart(2, "0")} ${p}`;
    }
    return alarmTimeStr;
  };

  const updateAlarmIndicator = (): void => {
    if (!alarmToggleEl || !alarmIndicatorEl || !alarmTimeDisplayEl) return;

    if (!alarmEnabledPref) {
      alarmToggleEl.style.display = "none";
      alarmIndicatorEl.style.display = "none";
      return;
    }

    alarmToggleEl.style.display = "inline-flex";

    if (alarmEnabled) {
      alarmToggleEl.classList.add("alarm-on");
      alarmToggleEl.classList.remove("alarm-off");
      if (alarmTime) {
        alarmIndicatorEl.style.display = "inline-flex";
        alarmTimeDisplayEl.textContent = getFormattedAlarmTime();
      } else {
        alarmIndicatorEl.style.display = "inline-flex";
        alarmTimeDisplayEl.textContent = "No time set";
      }
    } else {
      alarmToggleEl.classList.remove("alarm-on");
      alarmToggleEl.classList.add("alarm-off");
      alarmIndicatorEl.style.display = "none";
    }
  };

  if (alarmToggleEl) {
    alarmToggleEl.addEventListener("click", () => {
      alarmEnabled = !alarmEnabled;
      setAlarmToggleState(alarmEnabled);
      updateAlarmIndicator();
    });
  }

  updateAlarmIndicator();

  let lastTriggered: string | null = null;
  let alarmActive = false;

  // Update clock every second
  const updateClock = (): void => {
    const now = new Date();
    const { time, period } = formatTime(now, format);

    if (clockTimeEl) clockTimeEl.textContent = time;
    if (clockPeriodEl) clockPeriodEl.textContent = period;

    if (alarmTime && alarmEnabled && !alarmActive && checkAlarm(alarmTime, lastTriggered)) {
      const currentKey = `${now.getHours()}:${now.getMinutes()}`;
      lastTriggered = currentKey;
      alarmActive = true;

      playAlarmWithRepeat(alarmSound, alarmVolume);
      showNotification("Alarm", "Your alarm is ringing!");
      clockElement.classList.add("alarm-ringing");
      const stopAlarmHandler = (): void => {
        stopAlarm();
        alarmActive = false;
        clockElement.classList.remove("alarm-ringing");
        clockElement.removeEventListener("click", stopAlarmHandler);
      };

      clockElement.addEventListener("click", stopAlarmHandler);
    }
  };

  // Initial update
  updateClock();

  // Update every second
  setInterval(updateClock, 1000);
};

// Export for preferences page testing
(window as Window & { testAlarmSound?: typeof playAlarmWithRepeat }).testAlarmSound = playAlarmWithRepeat;
(window as Window & { stopAlarmSound?: typeof stopAlarm }).stopAlarmSound = stopAlarm;
(window as Window & { requestNotificationPermission?: typeof requestNotificationPermission }).requestNotificationPermission =
  requestNotificationPermission;

// Initialize on index page
ready(initClock, { on: [endpoint === Endpoints.index] });
