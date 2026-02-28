// ============================================================
// MATHPILOT LANDING — INTERACTIVE FEATURES
// ============================================================

// Navigation scroll effect
const nav = document.getElementById('nav');
window.addEventListener('scroll', () => {
  nav.classList.toggle('scrolled', window.scrollY > 40);
});

// Animated counters
function animateCounter(el) {
  const target = parseInt(el.dataset.target);
  const duration = 1500;
  const step = target / (duration / 16);
  let current = 0;
  const timer = setInterval(() => {
    current = Math.min(current + step, target);
    el.textContent = Math.floor(current);
    if (current >= target) clearInterval(timer);
  }, 16);
}

// Intersection Observer for reveal animations and counters
const observer = new IntersectionObserver((entries) => {
  entries.forEach(entry => {
    if (entry.isIntersecting) {
      entry.target.classList.add('visible');
      // Trigger counters if in stats section
      entry.target.querySelectorAll('[data-target]').forEach(animateCounter);
      observer.unobserve(entry.target);
    }
  });
}, { threshold: 0.1 });

// Add reveal class to all sections and cards
document.querySelectorAll('.feature-card, .grade-card, .step, .faq-item, .hero-stats').forEach(el => {
  el.classList.add('reveal');
  observer.observe(el);
});

// FAQ accordion
document.querySelectorAll('.faq-question').forEach(btn => {
  btn.addEventListener('click', () => {
    const item = btn.closest('.faq-item');
    const isOpen = item.classList.contains('open');
    // Close all
    document.querySelectorAll('.faq-item').forEach(i => i.classList.remove('open'));
    // Open clicked if was closed
    if (!isOpen) item.classList.add('open');
  });
});

// Hero stats counter trigger
const heroStats = document.querySelector('.hero-stats');
if (heroStats) observer.observe(heroStats);
