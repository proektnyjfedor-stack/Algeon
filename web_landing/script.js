// ============================================================
// MATHPILOT LANDING — INTERACTIVE FEATURES
// ============================================================

// Navigation scroll effect
window.addEventListener('scroll', () => {
    const nav = document.querySelector('.nav');
    if (window.scrollY > 50) {
        nav.classList.add('scrolled');
    } else {
        nav.classList.remove('scrolled');
    }
});

// ============================================================
// ANIMATED COUNTERS
// ============================================================

function animateCounter(element, target, duration = 2000) {
    let start = 0;
    const increment = target / (duration / 16); // 60fps
    
    const timer = setInterval(() => {
        start += increment;
        if (start >= target) {
            element.textContent = target;
            clearInterval(timer);
        } else {
            element.textContent = Math.floor(start);
        }
    }, 16);
}

// Trigger counters on scroll
const observerOptions = {
    threshold: 0.5,
    rootMargin: '0px'
};

const statsObserver = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
        if (entry.isIntersecting && !entry.target.classList.contains('counted')) {
            entry.target.classList.add('counted');
            const target = parseInt(entry.target.dataset.count);
            animateCounter(entry.target, target);
        }
    });
}, observerOptions);

document.querySelectorAll('.stat-value').forEach(stat => {
    statsObserver.observe(stat);
});

// ============================================================
// FADE IN ON SCROLL
// ============================================================

const fadeObserver = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
        if (entry.isIntersecting) {
            entry.target.classList.add('visible');
        }
    });
}, {
    threshold: 0.1,
    rootMargin: '0px 0px -50px 0px'
});

// Apply fade-in to feature cards
document.querySelectorAll('.feature-card').forEach(card => {
    card.classList.add('fade-in');
    fadeObserver.observe(card);
});

// Apply fade-in to grade cards
document.querySelectorAll('.grade-card').forEach(card => {
    card.classList.add('fade-in');
    fadeObserver.observe(card);
});

// ============================================================
// GLOWING CARD EFFECT (Mouse Follow)
// ============================================================

document.querySelectorAll('.feature-card').forEach(card => {
    card.addEventListener('mousemove', (e) => {
        const rect = card.getBoundingClientRect();
        const x = ((e.clientX - rect.left) / rect.width) * 100;
        const y = ((e.clientY - rect.top) / rect.height) * 100;
        
        card.style.setProperty('--mouse-x', `${x}%`);
        card.style.setProperty('--mouse-y', `${y}%`);
    });
});

// ============================================================
// FAQ ACCORDION
// ============================================================

document.querySelectorAll('.faq-question').forEach(button => {
    button.addEventListener('click', () => {
        const faqItem = button.parentElement;
        const wasActive = faqItem.classList.contains('active');
        
        // Close all other FAQ items
        document.querySelectorAll('.faq-item').forEach(item => {
            item.classList.remove('active');
        });
        
        // Toggle current item
        if (!wasActive) {
            faqItem.classList.add('active');
        }
    });
});

// ============================================================
// SMOOTH SCROLL FOR ANCHOR LINKS
// ============================================================

document.querySelectorAll('a[href^="#"]').forEach(anchor => {
    anchor.addEventListener('click', function (e) {
        e.preventDefault();
        const target = document.querySelector(this.getAttribute('href'));
        
        if (target) {
            const offsetTop = target.offsetTop - 80; // Account for fixed nav
            window.scrollTo({
                top: offsetTop,
                behavior: 'smooth'
            });
        }
    });
});

// ============================================================
// PHONE MOCKUP 3D TILT EFFECT
// ============================================================

const phoneMockup = document.querySelector('.phone-mockup');

if (phoneMockup) {
    document.addEventListener('mousemove', (e) => {
        const { clientX, clientY } = e;
        const { innerWidth, innerHeight } = window;
        
        // Calculate rotation based on mouse position (-10 to 10 degrees)
        const rotateY = ((clientX / innerWidth) - 0.5) * 20;
        const rotateX = ((clientY / innerHeight) - 0.5) * -20;
        
        phoneMockup.style.transform = `
            perspective(1000px)
            rotateY(${rotateY}deg)
            rotateX(${rotateX}deg)
        `;
    });
    
    // Reset on mouse leave
    document.addEventListener('mouseleave', () => {
        phoneMockup.style.transform = 'perspective(1000px) rotateY(0) rotateX(0)';
    });
}

// ============================================================
// TASK OPTIONS ANIMATION
// ============================================================

const taskOptions = document.querySelectorAll('.option');

taskOptions.forEach((option, index) => {
    // Stagger animation on load
    setTimeout(() => {
        option.style.opacity = '0';
        option.style.transform = 'translateY(10px)';
        
        setTimeout(() => {
            option.style.transition = 'all 0.3s ease';
            option.style.opacity = '1';
            option.style.transform = 'translateY(0)';
        }, 100);
    }, index * 100);
});

// ============================================================
// GRADIENT TEXT ANIMATION
// ============================================================

const gradientTexts = document.querySelectorAll('.gradient-text');

gradientTexts.forEach(text => {
    // Already animated via CSS, but can add JS effects if needed
    text.style.backgroundSize = '200% 200%';
});

// ============================================================
// PERFORMANCE OPTIMIZATION
// ============================================================

// Disable animations on mobile for better performance
if (window.innerWidth < 768) {
    document.querySelectorAll('.mesh-orb').forEach(orb => {
        orb.style.animation = 'none';
    });
}

// Reduce motion for users who prefer it
if (window.matchMedia('(prefers-reduced-motion: reduce)').matches) {
    document.querySelectorAll('*').forEach(element => {
        element.style.animationDuration = '0.01ms';
        element.style.animationIterationCount = '1';
        element.style.transitionDuration = '0.01ms';
    });
}

// ============================================================
// CONSOLE EASTER EGG
// ============================================================

console.log(
    '%c🚀 MathPilot ',
    'font-size: 20px; font-weight: bold; color: #0066FF; background: linear-gradient(135deg, #0066FF, #34C759); padding: 10px 20px; border-radius: 8px;'
);
console.log(
    '%cЗаинтересованы в разработке? Напишите нам на dev@mathpilot.app',
    'font-size: 14px; color: #8E8E93; margin-top: 10px;'
);

// ============================================================
// ANALYTICS (placeholder)
// ============================================================

// Track scroll depth
let maxScroll = 0;

window.addEventListener('scroll', () => {
    const scrollPercent = (window.scrollY / (document.body.scrollHeight - window.innerHeight)) * 100;
    
    if (scrollPercent > maxScroll) {
        maxScroll = scrollPercent;
        
        // Track milestones
        if (maxScroll > 25 && maxScroll < 30) {
            console.log('📊 Analytics: User scrolled 25%');
        } else if (maxScroll > 50 && maxScroll < 55) {
            console.log('📊 Analytics: User scrolled 50%');
        } else if (maxScroll > 75 && maxScroll < 80) {
            console.log('📊 Analytics: User scrolled 75%');
        } else if (maxScroll > 90) {
            console.log('📊 Analytics: User reached bottom');
        }
    }
});

// Track CTA clicks
document.querySelectorAll('.btn-primary, .download-btn, .nav-cta').forEach(button => {
    button.addEventListener('click', (e) => {
        console.log('📊 Analytics: CTA clicked -', e.target.textContent.trim());
        // Here you would send to your analytics service (GA, Mixpanel, etc.)
    });
});

// ============================================================
// LOADING OPTIMIZATION
// ============================================================

// Lazy load images when implemented
if ('loading' in HTMLImageElement.prototype) {
    // Browser supports native lazy loading
    console.log('✅ Native lazy loading supported');
} else {
    // Fallback for older browsers
    console.log('⚠️ Native lazy loading not supported, using IntersectionObserver');
}

// Preload critical resources
const preloadLink = document.createElement('link');
preloadLink.rel = 'preload';
preloadLink.as = 'font';
preloadLink.href = 'https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap';
preloadLink.crossOrigin = 'anonymous';
document.head.appendChild(preloadLink);

console.log('✅ MathPilot Landing Page initialized');
