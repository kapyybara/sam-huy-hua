<script setup lang="ts">
import { ref, computed, onMounted, onUnmounted, nextTick } from 'vue'

// --- Data ---
interface Product {
  name: string
  url: string
  image: string
}

interface Category {
  id: string
  label: string
  labelEn: string
  products: Product[]
}

interface Testimonial {
  text: string
  name: string
  role: string
  initial: string
}

const categories: Category[] = [
  {
    id: 'hac-sam',
    label: 'Hắc Sâm',
    labelEn: 'Black Ginseng',
    products: [
      { name: 'Hắc Sâm Thiên Ma', url: 'https://dtbshop.cloud/kbgg-hac-sam-thien-ma.html', image: '' },
      { name: 'Cao Hắc Sâm Nhung Hươu Đông Trùng Hạ Thảo', url: 'https://dtbshop.cloud/365kbgcdac-cao-hac-sam-nhung-huou-dong-trung-ha-thao.html', image: '' },
      { name: 'An Cung Hoạt Huyết Trầm Hương Hoàn Jimhyangdan Gold', url: 'https://dtbshop.cloud/jg-an-cung-hoat-huyet-tram-huong-jimhyangdan-gold.html', image: '' },
      { name: 'Cao Hắc Sâm Hàn Quốc 365', url: 'https://dtbshop.cloud/365kbgep-cao-hac-sam-han-quoc-365.html', image: '' },
      { name: 'Tinh Chất Hắc Sâm Đông Trùng Hạ Thảo Cao Cấp', url: 'https://dtbshop.cloud/kbgcap-tinh-chat-hac-sam-dong-trung-cao-cap.html', image: '' },
      { name: 'Hắc Sâm Đông Trùng Hạ Thảo', url: 'https://dtbshop.cloud/kbgc-hac-sam-dong-trung.html', image: '' },
      { name: 'Cao Hắc Sâm Hàn Quốc', url: 'https://dtbshop.cloud/kbgpg-cao-hac-sam-han-quoc.html', image: '' },
      { name: 'Hắc Sâm Linh Chi Nhung Hươu', url: 'https://dtbshop.cloud/kbgrmda-hac-sam-linh-chi-nhung-huou.html', image: '' },
      { name: 'Hắc Sâm Nhung Hươu Đông Trùng Hạ Thảo', url: 'https://dtbshop.cloud/kbgdac-hac-sam-nhung-huou-dong-trung-ha-thao.html', image: '' },
      { name: 'Hoạt Huyết Dưỡng Não Trầm Hương Hoàn Ginseng King', url: 'https://dtbshop.cloud/agw-hoat-huyet-duong-nao-tram-huong-hoan-ginseng-king.html', image: '' },
      { name: 'Sâm Núi Đông Trùng Hạ Thảo Lên Men', url: 'https://dtbshop.cloud/fkcwgcp-sam-nui-dong-trung-len-men.html', image: '' },
    ]
  },
  {
    id: 'dong-trung',
    label: 'Đông Trùng Hạ Thảo',
    labelEn: 'Cordyceps',
    products: [
      { name: 'Đông Trùng Hạ Thảo Lên Men', url: 'https://dtbshop.cloud/kfcm-dong-trung-ha-thao-len-men.html', image: '' },
      { name: 'Hoa Đông Trùng Sấy Khô', url: 'https://dtbshop.cloud/kfdcm-hoa-dong-trung-kho.html', image: '' },
      { name: 'Mát Gan Đông Trùng Hạ Thảo', url: 'https://dtbshop.cloud/kordchc-mat-gan-dong-trung-ha-thao.html', image: '' },
    ]
  },
  {
    id: 'hong-sam',
    label: 'Hồng Sâm',
    labelEn: 'Red Ginseng',
    products: [
      { name: 'Cao Hồng Sâm Nhung Hươu Linh Chi', url: 'https://dtbshop.cloud/365mrgdae-cao-hong-sam-nhung-huou-linh-chi.html', image: '' },
      { name: 'Hồng Sâm Lát Tẩm Mật Ong', url: 'https://dtbshop.cloud/hrgs-hong-sam-lat-tam-mat-ong.html', image: '' },
      { name: 'Hồng Sâm Củ Khô HG Bio Hàn Quốc', url: 'https://dtbshop.cloud/krgshgb-hong-sam-cu-kho-hg-bio.html', image: '' },
      { name: 'Cao Hồng Sâm Đông Trùng Hạ Thảo', url: 'https://dtbshop.cloud/p365krgc-cao-hong-sam-dong-trung-ha-thao.html', image: '' },
      { name: 'Hồng Sâm Lên Men', url: 'https://dtbshop.cloud/fkrgp-hong-sam-len-men.html', image: '' },
      { name: 'Kẹo Hồng Sâm Hàn Quốc Không Đường', url: 'https://dtbshop.cloud/sfkrgc-keo-hong-sam-han-quoc-khong-duong.html', image: '' },
      { name: 'Hồng Sâm Linh Chi Đông Trùng 365', url: 'https://dtbshop.cloud/krgrmc-hong-sam-linh-chi-dong-trung-365.html', image: '' },
      { name: 'Hồng Sâm Maca', url: 'https://dtbshop.cloud/krgm-hong-sam-maca-tang-luc.html', image: '' },
      { name: 'Hồng Sâm Đông Trùng Hạ Thảo 365', url: 'https://dtbshop.cloud/krgdchc-hong-sam-dong-trung-ha-thao-365.html', image: '' },
      { name: 'Hồng Sâm Nhung Hươu Linh Chi 365', url: 'https://dtbshop.cloud/krgda-hong-sam-nhung-huou-linh-chi-365.html', image: '' },
      { name: 'Hồng sâm Kid', url: 'https://dtbshop.cloud/dhargk-hong-sam-kid.html', image: '' },
      { name: 'Kẹo Hồng Sâm 365 Hàn Quốc Không Đường', url: 'https://dtbshop.cloud/365sfkrgc-keo-hong-sam-365-han-quoc-khong-duong.html', image: '' },
    ]
  },
  {
    id: 'nhan-sam',
    label: 'Nhân Sâm Củ Tươi',
    labelEn: 'Fresh Ginseng',
    products: [
      { name: 'Nhân Sâm Hàn Quốc Củ Tươi — Loại 8 Củ × 1 Kg', url: 'https://dtbshop.cloud/fg-1kg-8r-sam-cu-tuoi.html', image: '' },
      { name: 'Nhân Sâm Hàn Quốc Củ Tươi — Loại 6 Củ × 1 Kg', url: 'https://dtbshop.cloud/fg-1kg-6r-sam-cu-tuoi.html', image: '' },
      { name: 'Nhân Sâm Hàn Quốc Củ Tươi — Loại 10 Củ × 1 Kg', url: 'https://dtbshop.cloud/fg-1kg-10r-sam-cu-tuoi.html', image: '' },
    ]
  }
]

const testimonials: Testimonial[] = [
  {
    text: 'Sản phẩm Hắc Sâm của DTB Shop chất lượng tuyệt vời. Mình dùng đã 6 tháng và cảm nhận rõ rệt sức khỏe cải thiện rất nhiều.',
    name: 'Nguyễn Thị Mai',
    role: 'Khách hàng thân thiết',
    initial: 'M'
  },
  {
    text: 'Đóng gói cẩn thận, sản phẩm chính hãng 100%. Tư vấn nhiệt tình, giao hàng nhanh. Sẽ ủng hộ shop dài dài!',
    name: 'Trần Văn Hùng',
    role: 'Đã mua 3 lần',
    initial: 'H'
  },
  {
    text: 'Mua Đông Trùng Hạ Thảo tặng bố mẹ, cả nhà ai cũng khen. Giá hợp lý so với chất lượng. Rất hài lòng.',
    name: 'Lê Thị Hoa',
    role: 'Khách hàng mới',
    initial: 'H'
  }
]

const trustItems = [
  'Chính hãng 100%',
  'Nhập khẩu từ Hàn Quốc',
  'Giao hàng toàn quốc',
  'Tư vấn miễn phí',
  'Đổi trả dễ dàng',
  'Thanh toán an toàn',
]

const ZALO_URL = 'https://zalo.me/0778727469'
const HOTLINE = '0778 727 469'
const HOTLINE_2 = '0936 035 156'

// --- State ---
const scrolled = ref(false)
const showBackToTop = ref(false)
const mobileMenuOpen = ref(false)
const activeCategory = ref('all')

const filteredProducts = computed(() => {
  if (activeCategory.value === 'all') return categories
  return categories.filter(c => c.id === activeCategory.value)
})

// --- Scroll handler ---
function onScroll() {
  scrolled.value = window.scrollY > 40
  showBackToTop.value = window.scrollY > 600
}

function scrollToSection(id: string) {
  mobileMenuOpen.value = false
  const el = document.getElementById(id)
  if (el) {
    el.scrollIntoView({ behavior: 'smooth' })
  }
}

function scrollToTop() {
  window.scrollTo({ top: 0, behavior: 'smooth' })
}

function setCategory(id: string) {
  activeCategory.value = id
  nextTick(() => {
    setupRevealObserver()
  })
}

// --- Scroll Reveal with IntersectionObserver ---
let revealObserver: IntersectionObserver | null = null

function setupRevealObserver() {
  if (revealObserver) revealObserver.disconnect()

  revealObserver = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        entry.target.classList.add('visible')
        revealObserver?.unobserve(entry.target)
      }
    })
  }, { threshold: 0.1, rootMargin: '0px 0px -40px 0px' })

  document.querySelectorAll('.reveal').forEach(el => {
    if (!el.classList.contains('visible')) {
      revealObserver?.observe(el)
    }
  })
}

onMounted(() => {
  window.addEventListener('scroll', onScroll, { passive: true })
  onScroll()

  nextTick(() => {
    setupRevealObserver()
  })
})

onUnmounted(() => {
  window.removeEventListener('scroll', onScroll)
  if (revealObserver) revealObserver.disconnect()
})
</script>

<template>
  <!-- ========== HEADER ========== -->
  <header class="site-header" :class="{ scrolled }">
    <div class="container header-inner">
      <a class="brand" href="#" @click.prevent="scrollToSection('hero')">
        <div class="brand-icon">
          <svg viewBox="0 0 44 44" fill="none" xmlns="http://www.w3.org/2000/svg">
            <circle cx="22" cy="22" r="20" stroke="#CA8A04" stroke-width="2" fill="none"/>
            <path d="M22 8C20 14 16 18 14 22c-2 4-1 8 2 10s8 2 10-1c2-3 2-7 0-11-1-2-3-6-4-12z" fill="#CA8A04" opacity="0.9"/>
            <path d="M22 8c2 6 6 10 8 14 2 4 1 8-2 10s-8 2-10-1c-2-3-2-7 0-11 1-2 3-6 4-12z" fill="#1C1917" opacity="0.6"/>
          </svg>
        </div>
        <span class="brand-name">SÂM <span class="gold">DTB</span> SHOP</span>
      </a>

      <nav class="nav-links">
        <a @click.prevent="scrollToSection('hero')">Trang chủ</a>
        <a @click.prevent="scrollToSection('about')">Giới thiệu</a>
        <a @click.prevent="scrollToSection('products')">Sản phẩm</a>
        <a @click.prevent="scrollToSection('testimonials')">Đánh giá</a>
        <a @click.prevent="scrollToSection('contact')">Liên hệ</a>
      </nav>

      <div class="header-cta">
        <a :href="ZALO_URL" target="_blank" class="btn btn-zalo btn-sm">
          <svg class="btn-icon" viewBox="0 0 24 24" fill="currentColor"><path d="M20 2H4c-1.1 0-2 .9-2 2v18l4-4h14c1.1 0 2-.9 2-2V4c0-1.1-.9-2-2-2zm-2 12H6v-2h12v2zm0-3H6V9h12v2zm0-3H6V6h12v2z"/></svg>
          Chat Zalo
        </a>
        <a :href="'tel:' + HOTLINE.replace(/\s/g, '')" class="btn btn-gold btn-sm">
          <svg class="btn-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M22 16.92v3a2 2 0 01-2.18 2 19.79 19.79 0 01-8.63-3.07 19.5 19.5 0 01-6-6 19.79 19.79 0 01-3.07-8.67A2 2 0 014.11 2h3a2 2 0 012 1.72c.127.96.361 1.903.7 2.81a2 2 0 01-.45 2.11L8.09 9.91a16 16 0 006 6l1.27-1.27a2 2 0 012.11-.45c.907.339 1.85.573 2.81.7A2 2 0 0122 16.92z"/></svg>
          {{ HOTLINE }}
        </a>
      </div>

      <button class="menu-toggle" :class="{ active: mobileMenuOpen }" @click="mobileMenuOpen = !mobileMenuOpen" aria-label="Menu">
        <span></span>
        <span></span>
        <span></span>
      </button>
    </div>
  </header>

  <!-- Mobile Nav -->
  <div class="mobile-nav" :class="{ open: mobileMenuOpen }">
    <a @click.prevent="scrollToSection('hero')">Trang chủ</a>
    <a @click.prevent="scrollToSection('about')">Giới thiệu</a>
    <a @click.prevent="scrollToSection('products')">Sản phẩm</a>
    <a @click.prevent="scrollToSection('testimonials')">Đánh giá</a>
    <a @click.prevent="scrollToSection('contact')">Liên hệ</a>
    <div style="display:flex; gap:12px; margin-top:16px; flex-wrap:wrap; justify-content:center;">
      <a :href="ZALO_URL" target="_blank" class="btn btn-zalo">Chat Zalo</a>
      <a :href="'tel:' + HOTLINE.replace(/\s/g, '')" class="btn btn-gold">{{ HOTLINE }}</a>
    </div>
  </div>

  <!-- ========== HERO ========== -->
  <section id="hero" class="hero">
    <div class="hero-orb"></div>
    <div class="hero-content">
      <div class="hero-badge">
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z"/></svg>
        Chính hãng Hàn Quốc
      </div>
      <h1 class="hero-title">
        SÂM <span class="gold">DTB</span> SHOP
      </h1>
      <p class="hero-tagline">Khí Huyết Vững — Sức Khỏe Bền</p>
      <p class="hero-desc">
        Chuyên các sản phẩm Sâm & Chăm sóc sức khoẻ nhập khẩu từ Hàn Quốc.
        Hắc Sâm, Hồng Sâm, Đông Trùng Hạ Thảo, Nhân Sâm Củ Tươi chính hãng.
      </p>
      <div class="hero-actions">
        <a :href="ZALO_URL" target="_blank" class="btn btn-gold">
          <svg class="btn-icon" viewBox="0 0 24 24" fill="currentColor"><path d="M20 2H4c-1.1 0-2 .9-2 2v18l4-4h14c1.1 0 2-.9 2-2V4c0-1.1-.9-2-2-2z"/></svg>
          Tư vấn Zalo
        </a>
        <a :href="'tel:' + HOTLINE.replace(/\s/g, '')" class="btn btn-outline" style="border-color: rgba(255,255,255,0.3); color: #fff;">
          <svg class="btn-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M22 16.92v3a2 2 0 01-2.18 2 19.79 19.79 0 01-8.63-3.07 19.5 19.5 0 01-6-6 19.79 19.79 0 01-3.07-8.67A2 2 0 014.11 2h3a2 2 0 012 1.72c.127.96.361 1.903.7 2.81a2 2 0 01-.45 2.11L8.09 9.91a16 16 0 006 6l1.27-1.27a2 2 0 012.11-.45c.907.339 1.85.573 2.81.7A2 2 0 0122 16.92z"/></svg>
          Hotline: {{ HOTLINE }}
        </a>
      </div>
    </div>
    <div class="hero-scroll">
      <span>Khám phá</span>
      <div class="hero-scroll-line"></div>
    </div>
  </section>

  <!-- ========== TRUST MARQUEE STRIP ========== -->
  <div class="trust-strip">
    <div class="trust-marquee">
      <template v-for="(_round, ri) in 2" :key="ri">
        <template v-for="(item, i) in trustItems" :key="ri + '-' + i">
          <div class="trust-item">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M22 11.08V12a10 10 0 11-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>
            {{ item }}
          </div>
          <div class="trust-dot"></div>
        </template>
      </template>
    </div>
  </div>

  <!-- ========== BENEFITS BAR ========== -->
  <section class="benefits-bar">
    <div class="container">
      <div class="benefits-grid">
        <div class="benefit-item reveal">
          <div class="benefit-icon">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></svg>
          </div>
          <div>
            <div class="benefit-title">Chính hãng 100%</div>
            <div class="benefit-desc">Nhập khẩu trực tiếp từ Hàn Quốc</div>
          </div>
        </div>
        <div class="benefit-item reveal reveal-delay-1">
          <div class="benefit-icon">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="1" y="3" width="15" height="13"/><polygon points="16 8 20 8 23 11 23 16 16 16 16 8"/><circle cx="5.5" cy="18.5" r="2.5"/><circle cx="18.5" cy="18.5" r="2.5"/></svg>
          </div>
          <div>
            <div class="benefit-title">Giao hàng toàn quốc</div>
            <div class="benefit-desc">Ship COD, kiểm hàng trước</div>
          </div>
        </div>
        <div class="benefit-item reveal reveal-delay-2">
          <div class="benefit-icon">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 15a2 2 0 01-2 2H7l-4 4V5a2 2 0 012-2h14a2 2 0 012 2z"/></svg>
          </div>
          <div>
            <div class="benefit-title">Tư vấn miễn phí</div>
            <div class="benefit-desc">Hỗ trợ Zalo & Hotline 24/7</div>
          </div>
        </div>
        <div class="benefit-item reveal reveal-delay-3">
          <div class="benefit-icon">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="23 6 13.5 15.5 8.5 10.5 1 18"/><polyline points="17 6 23 6 23 12"/></svg>
          </div>
          <div>
            <div class="benefit-title">Cam kết chất lượng</div>
            <div class="benefit-desc">Hoàn tiền nếu không hài lòng</div>
          </div>
        </div>
      </div>
    </div>
  </section>

  <!-- ========== ABOUT/INTRO ========== -->
  <section id="about" class="intro-banner">
    <div class="container">
      <div class="intro-inner">
        <div class="intro-text reveal">
          <span class="section-label">Về chúng tôi</span>
          <h2>Cam Kết Chất Lượng <br/>Từ Xứ Sở Nhân Sâm</h2>
          <p>
            SÂM DTB SHOP chuyên cung cấp các sản phẩm nhân sâm và chăm sóc sức khỏe
            nhập khẩu chính hãng từ Hàn Quốc. Với hơn nhiều năm kinh nghiệm trong ngành,
            chúng tôi tự hào mang đến cho khách hàng những sản phẩm cao cấp nhất.
          </p>
          <p>
            Mỗi sản phẩm đều được kiểm định chất lượng nghiêm ngặt, đảm bảo nguồn gốc
            và công dụng tốt nhất cho sức khỏe của bạn và gia đình.
          </p>
          <div class="intro-stats">
            <div class="stat-item">
              <div class="stat-number">100%</div>
              <div class="stat-label">Chính hãng</div>
            </div>
            <div class="stat-item">
              <div class="stat-number">28+</div>
              <div class="stat-label">Sản phẩm</div>
            </div>
            <div class="stat-item">
              <div class="stat-number">4</div>
              <div class="stat-label">Dòng sâm</div>
            </div>
          </div>
        </div>
        <div class="intro-visual reveal reveal-delay-2">
          <div style="background: linear-gradient(135deg, #1C1917 0%, #292524 100%); border-radius: 16px; padding: 40px; text-align: center; box-shadow: 0 24px 60px rgba(0,0,0,0.1);">
            <svg width="120" height="120" viewBox="0 0 120 120" fill="none" xmlns="http://www.w3.org/2000/svg">
              <circle cx="60" cy="60" r="56" stroke="#CA8A04" stroke-width="2" fill="none" opacity="0.3"/>
              <circle cx="60" cy="60" r="40" stroke="#CA8A04" stroke-width="1" fill="none" opacity="0.15"/>
              <path d="M60 20C56 35 48 45 44 55c-4 10-2 20 5 25s20 5 25-2c5-7 5-17 0-27-3-5-8-16-14-31z" fill="#CA8A04" opacity="0.8"/>
              <path d="M60 20c4 15 12 25 16 35 4 10 2 20-5 25s-20 5-25-2c-5-7-5-17 0-27 3-5 8-16 14-31z" fill="#EAB308" opacity="0.4"/>
            </svg>
            <div style="margin-top: 24px; font-family: var(--font-heading); font-size: 1.5rem; font-weight: 600; color: #CA8A04;">Nhập khẩu</div>
            <div style="font-family: var(--font-body); font-size: 0.9rem; color: rgba(255,255,255,0.6); margin-top: 8px;">Trực tiếp từ Hàn Quốc</div>
          </div>
        </div>
      </div>
    </div>
  </section>

  <!-- ========== PRODUCTS ========== -->
  <section id="products" class="section">
    <div class="container">
      <div class="section-header reveal">
        <span class="section-label">Bộ sưu tập</span>
        <h2 class="section-title">Sản Phẩm Của Chúng Tôi</h2>
        <p class="section-subtitle">Tuyển chọn những sản phẩm sâm và sức khỏe cao cấp nhất từ Hàn Quốc</p>
        <div class="section-divider"></div>
      </div>

      <!-- Category Tabs -->
      <div class="category-tabs reveal">
        <button
          class="category-tab"
          :class="{ active: activeCategory === 'all' }"
          @click="setCategory('all')"
        >
          Tất cả
        </button>
        <button
          v-for="cat in categories"
          :key="cat.id"
          class="category-tab"
          :class="{ active: activeCategory === cat.id }"
          @click="setCategory(cat.id)"
        >
          {{ cat.label }}
        </button>
      </div>

      <!-- Product Categories -->
      <div v-for="cat in filteredProducts" :key="cat.id" :id="'cat-' + cat.id" style="margin-bottom: 64px;">
        <div style="margin-bottom: 28px;" class="reveal">
          <h3 class="text-h2" style="margin-bottom: 4px;">{{ cat.label }}</h3>
          <span class="text-small text-muted" style="font-style: italic;">{{ cat.labelEn }}</span>
        </div>

        <div class="product-grid">
          <div v-for="(product, i) in cat.products" :key="i" class="glass-card reveal" :class="'reveal-delay-' + (i % 4 + 1)">
            <a :href="product.url" target="_blank" class="card-image">
              <div class="card-image-placeholder">
                <svg viewBox="0 0 64 64" fill="none" xmlns="http://www.w3.org/2000/svg">
                  <path d="M32 8C28 18 22 26 18 34c-4 8-2 16 4 20s16 4 20-2c4-6 4-14 0-22-2-4-6-12-10-22z" stroke="#CA8A04" stroke-width="1.5" fill="none" opacity="0.5"/>
                  <path d="M32 8c4 10 10 18 14 26 4 8 2 16-4 20s-16 4-20-2c-4-6-4-14 0-22 2-4 6-12 10-22z" stroke="#78716C" stroke-width="1" fill="none" opacity="0.25"/>
                  <circle cx="32" cy="32" r="6" fill="#CA8A04" opacity="0.15"/>
                </svg>
              </div>
              <div class="card-overlay">
                <span class="card-overlay-text">Xem chi tiết</span>
              </div>
            </a>
            <div class="card-body">
              <h4 class="card-title">{{ product.name }}</h4>
              <div class="card-actions">
                <a :href="ZALO_URL" target="_blank" class="btn btn-zalo">
                  <svg class="btn-icon" viewBox="0 0 24 24" fill="currentColor"><path d="M20 2H4c-1.1 0-2 .9-2 2v18l4-4h14c1.1 0 2-.9 2-2V4c0-1.1-.9-2-2-2z"/></svg>
                  Chat Zalo
                </a>
                <a :href="'tel:' + HOTLINE.replace(/\s/g, '')" class="btn btn-hotline">
                  <svg class="btn-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M22 16.92v3a2 2 0 01-2.18 2 19.79 19.79 0 01-8.63-3.07 19.5 19.5 0 01-6-6 19.79 19.79 0 01-3.07-8.67A2 2 0 014.11 2h3a2 2 0 012 1.72c.127.96.361 1.903.7 2.81a2 2 0 01-.45 2.11L8.09 9.91a16 16 0 006 6l1.27-1.27a2 2 0 012.11-.45c.907.339 1.85.573 2.81.7A2 2 0 0122 16.92z"/></svg>
                  Mua hàng
                </a>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </section>

  <!-- ========== TESTIMONIALS ========== -->
  <section id="testimonials" class="testimonials-section">
    <div class="container">
      <div class="section-header reveal" style="margin-bottom: 48px;">
        <span class="section-label" style="color: var(--color-accent-light);">Đánh giá</span>
        <h2 class="section-title" style="color: white;">Khách Hàng Nói Gì?</h2>
        <p class="section-subtitle" style="color: rgba(255,255,255,0.5);">Niềm tin của khách hàng là động lực lớn nhất của chúng tôi</p>
        <div class="section-divider"></div>
      </div>

      <div class="testimonials-grid">
        <div v-for="(t, i) in testimonials" :key="i" class="testimonial-card reveal" :class="'reveal-delay-' + (i + 1)">
          <div class="testimonial-stars">
            <svg v-for="s in 5" :key="s" viewBox="0 0 24 24"><path d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z"/></svg>
          </div>
          <p class="testimonial-text">"{{ t.text }}"</p>
          <div class="testimonial-author">
            <div class="testimonial-avatar">{{ t.initial }}</div>
            <div>
              <div class="testimonial-name">{{ t.name }}</div>
              <div class="testimonial-role">{{ t.role }}</div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </section>

  <!-- ========== CTA BANNER ========== -->
  <section class="cta-banner">
    <div class="container">
      <div class="cta-inner reveal">
        <span class="section-label">Liên hệ ngay</span>
        <h2>Bạn Cần Tư Vấn<br/>Sản Phẩm Phù Hợp?</h2>
        <p>Đội ngũ chuyên gia sẵn sàng hỗ trợ bạn chọn sản phẩm tốt nhất cho sức khỏe gia đình.</p>
        <div class="cta-actions">
          <a :href="ZALO_URL" target="_blank" class="btn btn-gold">
            <svg class="btn-icon" viewBox="0 0 24 24" fill="currentColor"><path d="M20 2H4c-1.1 0-2 .9-2 2v18l4-4h14c1.1 0 2-.9 2-2V4c0-1.1-.9-2-2-2z"/></svg>
            Tư vấn qua Zalo
          </a>
          <a :href="'tel:' + HOTLINE.replace(/\s/g, '')" class="btn btn-dark">
            <svg class="btn-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M22 16.92v3a2 2 0 01-2.18 2 19.79 19.79 0 01-8.63-3.07 19.5 19.5 0 01-6-6 19.79 19.79 0 01-3.07-8.67A2 2 0 014.11 2h3a2 2 0 012 1.72c.127.96.361 1.903.7 2.81a2 2 0 01-.45 2.11L8.09 9.91a16 16 0 006 6l1.27-1.27a2 2 0 012.11-.45c.907.339 1.85.573 2.81.7A2 2 0 0122 16.92z"/></svg>
            Gọi: {{ HOTLINE }}
          </a>
        </div>
      </div>
    </div>
  </section>

  <!-- ========== FOOTER ========== -->
  <footer id="contact" class="site-footer">
    <div class="container">
      <div class="footer-grid">
        <div>
          <div class="footer-brand-name">SÂM <span class="gold">DTB</span> SHOP</div>
          <p class="footer-desc">
            Chuyên các sản phẩm Sâm & Chăm sóc sức khoẻ nhập khẩu từ Hàn Quốc.
            Cam kết 100% chính hãng, chất lượng cao.
          </p>
          <div class="footer-social">
            <a :href="ZALO_URL" target="_blank" class="footer-social-btn" aria-label="Zalo">
              <svg viewBox="0 0 24 24" fill="currentColor"><path d="M20 2H4c-1.1 0-2 .9-2 2v18l4-4h14c1.1 0 2-.9 2-2V4c0-1.1-.9-2-2-2zm-2 12H6v-2h12v2zm0-3H6V9h12v2zm0-3H6V6h12v2z"/></svg>
            </a>
            <a href="mailto:tuvan@dtbshop.cloud" class="footer-social-btn" aria-label="Email">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/><polyline points="22,6 12,13 2,6"/></svg>
            </a>
            <a :href="'tel:' + HOTLINE.replace(/\s/g, '')" class="footer-social-btn" aria-label="Phone">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M22 16.92v3a2 2 0 01-2.18 2 19.79 19.79 0 01-8.63-3.07 19.5 19.5 0 01-6-6 19.79 19.79 0 01-3.07-8.67A2 2 0 014.11 2h3a2 2 0 012 1.72c.127.96.361 1.903.7 2.81a2 2 0 01-.45 2.11L8.09 9.91a16 16 0 006 6l1.27-1.27a2 2 0 012.11-.45c.907.339 1.85.573 2.81.7A2 2 0 0122 16.92z"/></svg>
            </a>
          </div>
        </div>

        <div>
          <h4 class="footer-heading">Danh mục</h4>
          <div class="footer-links">
            <a @click.prevent="setCategory('hac-sam'); scrollToSection('products')">Hắc Sâm</a>
            <a @click.prevent="setCategory('dong-trung'); scrollToSection('products')">Đông Trùng Hạ Thảo</a>
            <a @click.prevent="setCategory('hong-sam'); scrollToSection('products')">Hồng Sâm</a>
            <a @click.prevent="setCategory('nhan-sam'); scrollToSection('products')">Nhân Sâm Củ Tươi</a>
          </div>
        </div>

        <div>
          <h4 class="footer-heading">Điều hướng</h4>
          <div class="footer-links">
            <a @click.prevent="scrollToSection('hero')">Trang chủ</a>
            <a @click.prevent="scrollToSection('about')">Giới thiệu</a>
            <a @click.prevent="scrollToSection('products')">Sản phẩm</a>
            <a @click.prevent="scrollToSection('testimonials')">Đánh giá</a>
            <a @click.prevent="scrollToSection('contact')">Liên hệ</a>
          </div>
        </div>

        <div>
          <h4 class="footer-heading">Liên hệ</h4>
          <div class="footer-contact-item">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M22 16.92v3a2 2 0 01-2.18 2 19.79 19.79 0 01-8.63-3.07 19.5 19.5 0 01-6-6 19.79 19.79 0 01-3.07-8.67A2 2 0 014.11 2h3a2 2 0 012 1.72c.127.96.361 1.903.7 2.81a2 2 0 01-.45 2.11L8.09 9.91a16 16 0 006 6l1.27-1.27a2 2 0 012.11-.45c.907.339 1.85.573 2.81.7A2 2 0 0122 16.92z"/></svg>
            <div>
              <a :href="'tel:' + HOTLINE.replace(/\s/g, '')">{{ HOTLINE }}</a><br/>
              <a :href="'tel:' + HOTLINE_2.replace(/\s/g, '')">{{ HOTLINE_2 }}</a>
            </div>
          </div>
          <div class="footer-contact-item">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/><polyline points="22,6 12,13 2,6"/></svg>
            <div>
              <a href="mailto:tuvan@dtbshop.cloud">tuvan@dtbshop.cloud</a><br/>
              <a href="mailto:dtbshopkorea@gmail.com">dtbshopkorea@gmail.com</a>
            </div>
          </div>
          <div class="footer-contact-item">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0118 0z"/><circle cx="12" cy="10" r="3"/></svg>
            <a href="https://maps.app.goo.gl/WDRnBZEr9qWK1mod6" target="_blank">
              P202, Tòa nhà Hữu Nguyên, 1446 Ba Tháng Hai, P. Minh Phụng, TPHCM
            </a>
          </div>
        </div>
      </div>

      <div class="footer-bottom">
        <span class="footer-copyright">© 2026 SÂM DTB SHOP. All rights reserved.</span>
      </div>
    </div>
  </footer>

  <!-- ========== FLOATING WIDGET ========== -->
  <div class="floating-zalo">
    <a :href="'tel:' + HOTLINE.replace(/\s/g, '')" class="floating-btn phone" :aria-label="'Gọi ' + HOTLINE">
      <span class="floating-label">Gọi ngay</span>
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M22 16.92v3a2 2 0 01-2.18 2 19.79 19.79 0 01-8.63-3.07 19.5 19.5 0 01-6-6 19.79 19.79 0 01-3.07-8.67A2 2 0 014.11 2h3a2 2 0 012 1.72c.127.96.361 1.903.7 2.81a2 2 0 01-.45 2.11L8.09 9.91a16 16 0 006 6l1.27-1.27a2 2 0 012.11-.45c.907.339 1.85.573 2.81.7A2 2 0 0122 16.92z"/></svg>
    </a>
    <a :href="ZALO_URL" target="_blank" class="floating-btn zalo" aria-label="Chat Zalo">
      <span class="floating-label">Chat Zalo</span>
      <svg viewBox="0 0 24 24" fill="currentColor"><path d="M20 2H4c-1.1 0-2 .9-2 2v18l4-4h14c1.1 0 2-.9 2-2V4c0-1.1-.9-2-2-2zm-2 12H6v-2h12v2zm0-3H6V9h12v2zm0-3H6V6h12v2z"/></svg>
    </a>
  </div>

  <!-- ========== BACK TO TOP ========== -->
  <button class="back-to-top" :class="{ visible: showBackToTop }" @click="scrollToTop" aria-label="Về đầu trang">
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="18 15 12 9 6 15"/></svg>
  </button>
</template>
