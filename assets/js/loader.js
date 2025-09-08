document.addEventListener('DOMContentLoaded', () => {
  const containerId = 'blog-swiper-content';
  const container = document.getElementById(containerId);
  if (!container) {
    console.error(`loader.js: no element with id "${containerId}". Add id="${containerId}" to .swiper-wrapper`);
    return;
  }

  // EDIT this list to match your fragment file names
  const files = [
    'fragments/blog-slide-1.html',
    'fragments/blog-slide-2.html',
    'fragments/blog-slide-3.html'
  ];

  function deepMerge(target = {}, source = {}) {
    for (const key in source) {
      if (source[key] && typeof source[key] === 'object' && !Array.isArray(source[key])) {
        target[key] = deepMerge(target[key] || {}, source[key]);
      } else {
        target[key] = source[key];
      }
    }
    return target;
  }

  Promise.all(files.map(path =>
    fetch(path)
      .then(resp => {
        if (!resp.ok) throw new Error(`${path} -> ${resp.status} ${resp.statusText}`);
        return resp.text();
      })
      .catch(err => {
        console.error(`Error loading fragment "${path}":`, err);
        return ''; 
      })
  ))
  .then(parts => {
    container.innerHTML = parts.join('');

    const slides = container.querySelectorAll('.swiper-slide');
    if (!slides.length) {
      console.error('No .swiper-slide elements were injected. Ensure your fragments wrap content in <div class="swiper-slide">...</div>');
      return;
    }

    const sliderEl = document.querySelector('.blog-hero-slider');
    let configFromPage = {};
    const cfgScript = sliderEl?.querySelector('.swiper-config');
    if (cfgScript) {
      try {
        configFromPage = JSON.parse(cfgScript.textContent);
      } catch (e) {
        console.warn('Invalid JSON inside .swiper-config:', e);
      }
    }

    const defaultConfig = {
      loop: true,
      speed: 1000,
      effect: 'fade',
      autoplay: { delay: 5000 },
      slidesPerView: 1,
      navigation: { nextEl: '.swiper-button-next', prevEl: '.swiper-button-prev' }
    };

    const finalConfig = deepMerge(defaultConfig, configFromPage);

    try {
      new Swiper('.blog-hero-slider', finalConfig);
    } catch (e) {
      console.error('Error initializing Swiper:', e);
    }
  })
  .catch(err => {
    console.error('Unexpected error while loading slides:', err);
  });
});
