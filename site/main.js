const root = document.documentElement;
const themeColor = document.querySelector('meta[name="theme-color"]');
const themeToggle = document.querySelector('[data-theme-toggle]');
const prefersLight = window.matchMedia('(prefers-color-scheme: light)').matches;
const queryTheme = new URLSearchParams(window.location.search).get('theme');
const storedTheme = localStorage.getItem('mecha-theme');
const initialTheme = ['dark', 'light'].includes(queryTheme)
  ? queryTheme
  : storedTheme || (prefersLight ? 'light' : 'dark');

const THEMES = {
  dark: { color: '#0e1009' },
  light: { color: '#e9e5cb' },
};

function setTheme(theme, persist = true) {
  root.dataset.theme = theme;
  if (themeColor) themeColor.content = THEMES[theme].color;
  if (themeToggle) {
    themeToggle.setAttribute(
      'aria-label',
      theme === 'dark' ? 'Switch to light mode' : 'Switch to dark mode'
    );
  }
  document.querySelectorAll('[data-mode]').forEach((button) => {
    button.setAttribute('aria-pressed', String(button.dataset.mode === theme));
  });
  document.querySelectorAll('.js-desktop-download').forEach((link) => {
    link.href = link.dataset[`${theme}Href`];
  });
  if (persist) localStorage.setItem('mecha-theme', theme);
  if (window.liveWallpaper) window.liveWallpaper.setTheme(theme);
}

setTheme(initialTheme, false);
themeToggle?.addEventListener('click', () => {
  setTheme(root.dataset.theme === 'dark' ? 'light' : 'dark');
});
document.querySelectorAll('[data-mode]').forEach((button) => {
  button.addEventListener('click', () => setTheme(button.dataset.mode));
});

const INSTALL_COMMANDS = {
  dark: [
    'omarchy theme install https://github.com/sazardev/omarchy-mecha-green-theme',
    'omarchy theme set "Mecha Green"',
  ].join('\n'),
  light: [
    'omarchy theme install https://github.com/sazardev/omarchy-mecha-green-light-theme',
    'omarchy theme set "Mecha Green Light"',
  ].join('\n'),
};

const installCommand = document.getElementById('install-command');
document.querySelectorAll('[data-install-mode]').forEach((button) => {
  button.addEventListener('click', () => {
    const mode = button.dataset.installMode;
    document.querySelectorAll('[data-install-mode]').forEach((item) => {
      item.setAttribute('aria-selected', String(item === button));
    });
    if (installCommand) installCommand.textContent = INSTALL_COMMANDS[mode];
  });
});

async function copyText(text) {
  if (navigator.clipboard?.writeText) {
    await navigator.clipboard.writeText(text);
    return;
  }
  const area = document.createElement('textarea');
  area.value = text;
  area.style.position = 'fixed';
  area.style.opacity = '0';
  document.body.append(area);
  area.select();
  document.execCommand('copy');
  area.remove();
}

document.querySelectorAll('[data-copy-target]').forEach((button) => {
  button.addEventListener('click', async () => {
    const target = document.getElementById(button.dataset.copyTarget);
    if (!target) return;
    await copyText(target.textContent);
    const original = button.textContent;
    button.textContent = 'Copied';
    setTimeout(() => { button.textContent = original; }, 1400);
  });
});

const LOOPS = {
  drift: { number: '100', name: 'Drift' },
  fold: { number: '101', name: 'Fold' },
  field: { number: '102', name: 'Field' },
  terrain: { number: '103', name: 'Terrain' },
  panorama: { number: '104', name: 'Panorama' },
  undulate: { number: '105', name: 'Undulate' },
};

const video = document.getElementById('live-video');
const videoStage = video?.closest('.video-stage');
const videoToggle = document.querySelector('[data-video-toggle]');
const videoTimecode = document.getElementById('video-timecode');
const loopDownload = document.querySelector('.js-loop-download');
let currentLoop = 'drift';
let manualPause = false;
let isVisible = true;

function videoPath(slug, theme) {
  if (theme === 'light') {
    return `assets/video/${slug}-light.mp4`;
  }
  return `assets/video/${slug}-dark.mp4`;
}

function posterPath(slug, theme) {
  return `assets/images/posters/${slug}-${theme}.webp`;
}

function loopDownloadUrl(slug, theme) {
  const loop = LOOPS[slug];
  const themeDir = theme === 'light' ? 'mecha-green-light' : 'mecha-green';
  const suffix = theme === 'light' ? '-light' : '';
  return `https://raw.githubusercontent.com/sazardev/omarchy-mecha-green/main/themes/${themeDir}/backgrounds/${loop.number}-${slug}${suffix}.mp4`;
}

function formatTime(seconds) {
  const value = Number.isFinite(seconds) ? Math.floor(seconds) : 0;
  return `00:${String(value).padStart(2, '0')}`;
}

function updateVideoMeta(theme) {
  if (!loopDownload) return;
  loopDownload.href = loopDownloadUrl(currentLoop, theme);
}

function loadLoop(slug, theme, shouldPlay = true) {
  if (!video) return;
  currentLoop = slug;
  const wasPlaying = !video.paused;
  video.poster = posterPath(slug, theme);
  video.src = videoPath(slug, theme);
  video.load();
  updateVideoMeta(theme);
  document.querySelectorAll('[data-loop]').forEach((button) => {
    const active = button.dataset.loop === slug;
    button.classList.toggle('is-active', active);
    button.setAttribute('aria-pressed', String(active));
  });
  if (shouldPlay && !manualPause && isVisible) {
    video.play().catch(() => {});
  } else if (!wasPlaying) {
    video.pause();
  }
}

if (video) {
  video.addEventListener('timeupdate', () => {
    if (videoTimecode) {
      videoTimecode.textContent = `${formatTime(video.currentTime)} / ${formatTime(video.duration || 8)}`;
    }
  });
  video.addEventListener('play', () => {
    videoStage?.classList.remove('is-paused');
    videoToggle?.setAttribute('aria-label', 'Pause live wallpaper preview');
  });
  video.addEventListener('pause', () => {
    videoStage?.classList.add('is-paused');
    videoToggle?.setAttribute('aria-label', 'Play live wallpaper preview');
  });

  videoToggle?.addEventListener('click', () => {
    if (video.paused) {
      manualPause = false;
      video.play().catch(() => {});
    } else {
      manualPause = true;
      video.pause();
    }
  });

  document.querySelectorAll('[data-loop]').forEach((button) => {
    button.addEventListener('click', () => {
      manualPause = false;
      loadLoop(button.dataset.loop, root.dataset.theme, true);
    });
  });

  if ('IntersectionObserver' in window) {
    new IntersectionObserver((entries) => {
      entries.forEach((entry) => {
        isVisible = entry.isIntersecting;
        if (!entry.isIntersecting) {
          video.pause();
        } else if (!manualPause) {
          video.play().catch(() => {});
        }
      });
    }, { threshold: 0.25 }).observe(videoStage || video);
  }

  if (window.matchMedia('(prefers-reduced-motion: reduce)').matches) {
    manualPause = true;
    video.pause();
  }
}

window.liveWallpaper = {
  setTheme(theme) {
    if (!video) return;
    loadLoop(currentLoop, theme, !manualPause);
  },
};

if (video) {
  document.querySelectorAll('[data-loop]').forEach((button) => {
    button.setAttribute('aria-pressed', String(button.dataset.loop === currentLoop));
  });
  if (initialTheme !== 'dark') {
    loadLoop(currentLoop, initialTheme, true);
  }
}

if ('IntersectionObserver' in window) {
  const revealObserver = new IntersectionObserver((entries) => {
    entries.forEach((entry) => {
      if (entry.isIntersecting) {
        entry.target.classList.add('is-visible');
        revealObserver.unobserve(entry.target);
      }
    });
  }, { threshold: 0.08, rootMargin: '0px 0px -40px' });
  document.querySelectorAll('[data-reveal]').forEach((element) => revealObserver.observe(element));
} else {
  document.querySelectorAll('[data-reveal]').forEach((element) => element.classList.add('is-visible'));
}
