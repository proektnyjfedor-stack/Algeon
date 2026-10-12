/**
 * Algeon landing — interactions & animations
 */

const THEME_KEY = 'algeon-theme';

function getTheme() {
  return document.documentElement.getAttribute('data-theme') === 'dark' ? 'dark' : 'light';
}

function setTheme(theme) {
  document.documentElement.setAttribute('data-theme', theme);
  try { localStorage.setItem(THEME_KEY, theme); } catch (_) {}
}

function toggleTheme() {
  setTheme(getTheme() === 'dark' ? 'light' : 'dark');
}

document.getElementById('themeToggle')?.addEventListener('click', toggleTheme);
document.getElementById('themeToggleMobile')?.addEventListener('click', toggleTheme);

const header = document.getElementById('header');
const menuToggle = document.getElementById('menuToggle');
const mobileNav = document.getElementById('mobileNav');
const scrollProgress = document.getElementById('scrollProgress');
const prefersReducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;

// Scroll progress + header
function onScroll() {
  const scrollTop = window.scrollY;
  const docHeight = document.documentElement.scrollHeight - window.innerHeight;
  const pct = docHeight > 0 ? (scrollTop / docHeight) * 100 : 0;

  if (scrollProgress) scrollProgress.style.width = `${pct}%`;
  header?.classList.toggle('scrolled', scrollTop > 24);
}

window.addEventListener('scroll', onScroll, { passive: true });
onScroll();

// Mobile menu
if (menuToggle && mobileNav) {
  menuToggle.addEventListener('click', () => {
    const open = mobileNav.classList.toggle('is-open');
    mobileNav.hidden = !open;
    menuToggle.setAttribute('aria-expanded', String(open));
  });

  mobileNav.querySelectorAll('a').forEach((link) => {
    link.addEventListener('click', () => {
      mobileNav.classList.remove('is-open');
      mobileNav.hidden = true;
      menuToggle.setAttribute('aria-expanded', 'false');
    });
  });
}

// Animated counters
function animateCounter(el) {
  if (el.dataset.animated) return;
  const target = parseInt(el.dataset.count, 10);
  if (Number.isNaN(target)) return;
  el.dataset.animated = '1';

  const duration = prefersReducedMotion ? 0 : 1400;
  if (duration === 0) {
    el.textContent = String(target);
    return;
  }

  const start = performance.now();
  function tick(now) {
    const t = Math.min((now - start) / duration, 1);
    const eased = 1 - Math.pow(1 - t, 4);
    el.textContent = String(Math.floor(eased * target));
    if (t < 1) requestAnimationFrame(tick);
  }
  requestAnimationFrame(tick);
}

// Scroll reveal with stagger
const revealObserver = new IntersectionObserver(
  (entries) => {
    entries.forEach((entry) => {
      if (!entry.isIntersecting) return;
      entry.target.classList.add('visible');
      entry.target.querySelectorAll('[data-count]').forEach(animateCounter);
      revealObserver.unobserve(entry.target);
    });
  },
  { threshold: 0.1, rootMargin: '0px 0px -50px 0px' }
);

document.querySelectorAll('.reveal').forEach((el) => revealObserver.observe(el));

// Hero counters on load
document.querySelectorAll('.hero-metrics [data-count]').forEach((el) => {
  setTimeout(() => animateCounter(el), 600);
});

// Parallax glows
if (!prefersReducedMotion) {
  const parallaxEls = document.querySelectorAll('[data-parallax]');
  const hero = document.getElementById('hero');

  if (hero && parallaxEls.length) {
    hero.addEventListener('mousemove', (e) => {
      const rect = hero.getBoundingClientRect();
      const x = (e.clientX - rect.left) / rect.width - 0.5;
      const y = (e.clientY - rect.top) / rect.height - 0.5;

      parallaxEls.forEach((el) => {
        const factor = parseFloat(el.dataset.parallax) || 0.03;
        el.style.transform = `translate(${x * factor * 120}px, ${y * factor * 120}px)`;
      });
    });

    hero.addEventListener('mouseleave', () => {
      parallaxEls.forEach((el) => {
        el.style.transform = '';
      });
    });
  }
}

// Tilt on device mock
const tiltCard = document.querySelector('.tilt-card');
if (tiltCard && !prefersReducedMotion) {
  const parent = tiltCard.closest('.hero-visual');
  parent?.addEventListener('mousemove', (e) => {
    const rect = tiltCard.getBoundingClientRect();
    const x = (e.clientX - rect.left) / rect.width - 0.5;
    const y = (e.clientY - rect.top) / rect.height - 0.5;
    tiltCard.style.transform = `rotateY(${x * 8}deg) rotateX(${-y * 8}deg) scale(1.01)`;
  });
  parent?.addEventListener('mouseleave', () => {
    tiltCard.style.transform = '';
  });
}

// Magnetic buttons
if (!prefersReducedMotion) {
  document.querySelectorAll('.magnetic').forEach((btn) => {
    btn.addEventListener('mousemove', (e) => {
      const rect = btn.getBoundingClientRect();
      const x = e.clientX - rect.left - rect.width / 2;
      const y = e.clientY - rect.top - rect.height / 2;
      btn.style.transform = `translate(${x * 0.15}px, ${y * 0.15}px)`;
    });
    btn.addEventListener('mouseleave', () => {
      btn.style.transform = '';
    });
  });
}

// Showcase tabs
const tabs = document.querySelectorAll('.showcase-tab');
const panels = {
  learn: document.getElementById('panel-learn'),
  practice: document.getElementById('panel-practice'),
  progress: document.getElementById('panel-progress'),
};

tabs.forEach((tab) => {
  tab.addEventListener('click', () => {
    const id = tab.dataset.tab;
    if (!panels[id]) return;

    tabs.forEach((t) => {
      t.classList.remove('active');
      t.setAttribute('aria-selected', 'false');
    });
    tab.classList.add('active');
    tab.setAttribute('aria-selected', 'true');

    Object.values(panels).forEach((panel) => {
      panel.classList.remove('active');
      panel.hidden = true;
    });

    const active = panels[id];
    active.hidden = false;
    active.classList.add('active');
  });
});

// Grade cards hover ripple
document.querySelectorAll('.grade-card').forEach((card) => {
  card.addEventListener('mouseenter', () => {
    card.style.setProperty('--hover', '1');
  });
});

// Keep the menu and showcase usable from a keyboard.
document.addEventListener('keydown', (event) => {
  if (event.key === 'Escape' && mobileNav?.classList.contains('is-open')) {
    mobileNav.classList.remove('is-open');
    mobileNav.hidden = true;
    menuToggle?.setAttribute('aria-expanded', 'false');
    menuToggle?.focus();
  }
});
tabs.forEach((tab, index) => {
  tab.tabIndex = tab.classList.contains('active') ? 0 : -1;
  tab.addEventListener('click', () => tabs.forEach((item) => {
    item.tabIndex = item === tab ? 0 : -1;
  }));
  tab.addEventListener('keydown', (event) => {
    let next;
    if (event.key === 'ArrowRight') next = (index + 1) % tabs.length;
    if (event.key === 'ArrowLeft') next = (index + tabs.length - 1) % tabs.length;
    if (event.key === 'Home') next = 0;
    if (event.key === 'End') next = tabs.length - 1;
    if (next === undefined) return;
    event.preventDefault();
    tabs[next].click();
    tabs[next].focus();
  });
});
