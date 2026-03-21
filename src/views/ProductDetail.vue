<script setup lang="ts">
import { ref, computed, onMounted, watch, nextTick } from 'vue'
import { useRoute } from 'vue-router'
import { products } from '../data/products'
import type { Product } from '../data/types'

const route = useRoute()
const product = computed<Product | undefined>(() => {
  const slug = route.params.slug as string
  return products.find(p => p.slug === slug)
})

const ZALO_URL = 'https://zalo.me/0778727469'
const HOTLINE = '0778 727 469'
const HOTLINE_2 = '0936 035 156'

// Gallery state
const currentImageIndex = ref(0)
const mainImageSrc = ref('')

function selectImage(index: number) {
  if (!product.value) return
  const images = product.value.images
  if (index < 0) index = images.length - 1
  if (index >= images.length) index = 0
  currentImageIndex.value = index
  mainImageSrc.value = images[index]
}

// Touch swipe for gallery
let startX = 0
let deltaX = 0
const SWIPE_THRESHOLD = 40

function onTouchStart(e: TouchEvent) {
  startX = e.touches[0].clientX
  deltaX = 0
}
function onTouchMove(e: TouchEvent) {
  deltaX = e.touches[0].clientX - startX
}
function onTouchEnd() {
  if (Math.abs(deltaX) > SWIPE_THRESHOLD) {
    selectImage(deltaX < 0 ? currentImageIndex.value + 1 : currentImageIndex.value - 1)
  }
}

// Scroll state
const scrolled = ref(false)
const showBackToTop = ref(false)

function onScroll() {
  scrolled.value = window.scrollY > 40
  showBackToTop.value = window.scrollY > 600
}

function scrollToTop() {
  window.scrollTo({ top: 0, behavior: 'smooth' })
}

// Initialize gallery on mount and route change
function initGallery() {
  if (product.value && product.value.images.length > 0) {
    currentImageIndex.value = 0
    mainImageSrc.value = product.value.images[0]
  }
}

onMounted(() => {
  window.addEventListener('scroll', onScroll, { passive: true })
  onScroll()
  initGallery()
})

watch(() => route.params.slug, () => {
  nextTick(() => {
    initGallery()
    window.scrollTo({ top: 0 })
  })
})
</script>

<template>
  <!-- Not Found -->
  <div v-if="!product" class="not-found">
    <div class="container" style="text-align:center; padding: 120px 20px;">
      <h1 style="color: var(--color-accent); font-family: var(--font-heading);">Không tìm thấy sản phẩm</h1>
      <p style="color: var(--color-text-muted); margin-top: 16px;">Sản phẩm bạn tìm kiếm không tồn tại.</p>
      <router-link to="/" class="btn btn-gold" style="margin-top: 32px;">
        <svg class="btn-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="15 18 9 12 15 6"/></svg>
        Về trang chủ
      </router-link>
    </div>
  </div>

  <template v-else>
    <!-- ========== HEADER ========== -->
    <header class="site-header" :class="{ scrolled }">
      <div class="container header-inner">
        <router-link class="brand" to="/">
          <div class="brand-icon">
            <img src="/images/dtbshop-logo.png" alt="SÂM DTB SHOP" class="brand-logo-img" />
          </div>
          <span class="brand-name">SÂM <span class="gold">DTB</span> SHOP</span>
        </router-link>

        <nav class="nav-links">
          <router-link to="/">Trang chủ</router-link>
          <router-link to="/#products">Sản phẩm</router-link>
          <router-link to="/#contact">Liên hệ</router-link>
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
      </div>
    </header>

    <!-- ========== BREADCRUMB HERO ========== -->
    <section class="pd-hero">
      <div class="pd-hero-bg"></div>
      <div class="container pd-hero-content">
        <h1 class="pd-hero-title">{{ product.categoryName }}</h1>
        <nav class="pd-breadcrumb">
          <router-link to="/" class="pd-bc-link">Trang chủ</router-link>
          <span class="pd-bc-sep">›</span>
          <span class="pd-bc-link">{{ product.categoryName }}</span>
          <span class="pd-bc-sep">›</span>
          <span class="pd-bc-current">{{ product.name }}</span>
        </nav>
      </div>
    </section>

    <!-- ========== PRODUCT INFO ========== -->
    <section class="pd-info">
      <div class="container pd-grid">
        <!-- Gallery -->
        <div class="pd-gallery">
          <div class="pd-gallery-main"
            @touchstart="onTouchStart"
            @touchmove="onTouchMove"
            @touchend="onTouchEnd"
          >
            <img :src="mainImageSrc" :alt="product.fullName" />
          </div>
          <div class="pd-gallery-thumbs">
            <img
              v-for="(img, i) in product.images"
              :key="i"
              :src="img"
              :alt="product.fullName"
              :class="{ active: i === currentImageIndex }"
              @click="selectImage(i)"
              loading="lazy"
            />
          </div>
        </div>

        <!-- Info -->
        <div class="pd-details">
          <h1 class="pd-title">{{ product.fullName }}</h1>
          <p class="pd-short-desc">{{ product.shortDescription }}</p>

          <div class="pd-specs">
            <div v-if="product.brand" class="pd-spec-row">
              <span class="pd-spec-label">Thương hiệu</span>
              <span class="pd-spec-value">{{ product.brand }}</span>
            </div>
            <div v-if="product.sku" class="pd-spec-row">
              <span class="pd-spec-label">SKU</span>
              <span class="pd-spec-value">{{ product.sku }}</span>
            </div>
            <div class="pd-spec-row">
              <span class="pd-spec-label">Xuất xứ</span>
              <span class="pd-spec-value">{{ product.origin }}</span>
            </div>
            <div v-if="product.specs" class="pd-spec-row">
              <span class="pd-spec-label">Quy cách</span>
              <span class="pd-spec-value">{{ product.specs }}</span>
            </div>
            <div v-if="product.packaging" class="pd-spec-row">
              <span class="pd-spec-label">Đóng gói</span>
              <span class="pd-spec-value">{{ product.packaging }}</span>
            </div>
          </div>

          <div class="pd-cta">
            <a :href="ZALO_URL" target="_blank" class="btn btn-zalo">
              <svg class="btn-icon" viewBox="0 0 24 24" fill="currentColor"><path d="M20 2H4c-1.1 0-2 .9-2 2v18l4-4h14c1.1 0 2-.9 2-2V4c0-1.1-.9-2-2-2zm-2 12H6v-2h12v2zm0-3H6V9h12v2zm0-3H6V6h12v2z"/></svg>
              Chat Zalo
            </a>
            <a :href="'tel:' + HOTLINE.replace(/\s/g, '')" class="btn btn-hotline">
              <svg class="btn-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M22 16.92v3a2 2 0 01-2.18 2 19.79 19.79 0 01-8.63-3.07 19.5 19.5 0 01-6-6 19.79 19.79 0 01-3.07-8.67A2 2 0 014.11 2h3a2 2 0 012 1.72c.127.96.361 1.903.7 2.81a2 2 0 01-.45 2.11L8.09 9.91a16 16 0 006 6l1.27-1.27a2 2 0 012.11-.45c.907.339 1.85.573 2.81.7A2 2 0 0122 16.92z"/></svg>
              Mua hàng
            </a>
          </div>
        </div>
      </div>
    </section>

    <!-- ========== PRODUCT CONTENT ========== -->
    <section class="pd-content">
      <div class="container">
        <!-- Detailed Description -->
        <div class="pd-block" v-if="product.detailedDescription">
          <h2 class="pd-block-title pd-block-title--accent">{{ product.fullName }}</h2>
          <p class="pd-block-desc">{{ product.detailedDescription }}</p>
        </div>

        <!-- Ingredients -->
        <div class="pd-block" v-if="product.ingredients">
          <h2 class="pd-block-title">Thành phần chính</h2>
          <p>{{ product.ingredients }}</p>
        </div>

        <!-- Benefits -->
        <div class="pd-block" v-if="product.benefits.length">
          <h2 class="pd-block-title">Công dụng</h2>
          <ul class="pd-list">
            <li v-for="(b, i) in product.benefits" :key="i">{{ b }}</li>
          </ul>
        </div>

        <!-- Suitable For -->
        <div class="pd-block" v-if="product.suitableFor.length">
          <h2 class="pd-block-title">Đối tượng phù hợp</h2>
          <ul class="pd-list">
            <li v-for="(s, i) in product.suitableFor" :key="i">{{ s }}</li>
          </ul>
        </div>

        <!-- Usage -->
        <div class="pd-block" v-if="product.usage.length">
          <h2 class="pd-block-title">Cách dùng</h2>
          <ul class="pd-list">
            <li v-for="(u, i) in product.usage" :key="i">{{ u }}</li>
          </ul>
        </div>

        <!-- Precautions -->
        <div class="pd-block" v-if="product.precautions.length">
          <h2 class="pd-block-title">Thận trọng và bảo quản</h2>
          <ul class="pd-list pd-list--warn">
            <li v-for="(p, i) in product.precautions" :key="i">{{ p }}</li>
          </ul>
        </div>

        <!-- Gift -->
        <div class="pd-block pd-gift">
          <h2 class="pd-block-title pd-block-title--gift">
            <img src="/images/icon/gift.png" alt="Gift" class="pd-gift-icon" />
            QUÀ BIẾU SỨC KHOẺ DTB SHOP
          </h2>
          <p class="pd-block-desc">
            Vừa là lựa chọn hoàn hảo để chăm sóc sức khoẻ mỗi ngày, vừa là món quà tri ân tinh tế, sang trọng và ý nghĩa cho những giá trị bền vững dành cho người thân yêu và các đối tác.
          </p>
        </div>

        <!-- Commitments -->
        <div class="pd-block">
          <h2 class="pd-block-title">CAM KẾT TỪ DTB SHOP</h2>
          <ul class="pd-commitment">
            <li>
              <h3>Sản phẩm chính hãng 100%</h3>
              <span>Có tem nhãn, hóa đơn chứng từ đầy đủ theo quy định.</span>
            </li>
            <li>
              <h3>Nguồn gốc nhập khẩu Hàn Quốc và xuất xứ rõ ràng</h3>
              <span>Sản xuất và đóng gói theo dây chuyền hiện đại đạt tiêu chuẩn HACCP.</span>
            </li>
            <li>
              <h3>Chính sách đổi trả linh hoạt</h3>
              <span>Hỗ trợ đổi trả trong vòng 07 ngày nếu sản phẩm còn nguyên seal.</span>
            </li>
            <li>
              <h3>Thích hợp làm quà tặng</h3>
              <span>Hỗ trợ túi, hộp và thiệp chúc khi mua làm quà biếu.</span>
            </li>
            <li>
              <h3>Tư vấn tận tâm và chuyên nghiệp</h3>
              <span>Sẵn sàng tư vấn chi tiết về nguồn gốc, công dụng, cách sử dụng.</span>
            </li>
          </ul>
          <p class="pd-commitment-cta">
            Chọn DTB SHOP để an tâm về chất lượng và trải nghiệm dịch vụ chuyên nghiệp.
          </p>
        </div>
      </div>
    </section>

    <!-- ========== MOBILE CTA ========== -->
    <div class="pd-mobile-cta">
      <a :href="ZALO_URL" target="_blank" class="btn btn-zalo">
        <svg class="btn-icon" viewBox="0 0 24 24" fill="currentColor"><path d="M20 2H4c-1.1 0-2 .9-2 2v18l4-4h14c1.1 0 2-.9 2-2V4c0-1.1-.9-2-2-2zm-2 12H6v-2h12v2zm0-3H6V9h12v2zm0-3H6V6h12v2z"/></svg>
        Chat Zalo
      </a>
      <a :href="'tel:' + HOTLINE.replace(/\s/g, '')" class="btn btn-hotline">
        <svg class="btn-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M22 16.92v3a2 2 0 01-2.18 2 19.79 19.79 0 01-8.63-3.07 19.5 19.5 0 01-6-6 19.79 19.79 0 01-3.07-8.67A2 2 0 014.11 2h3a2 2 0 012 1.72c.127.96.361 1.903.7 2.81a2 2 0 01-.45 2.11L8.09 9.91a16 16 0 006 6l1.27-1.27a2 2 0 012.11-.45c.907.339 1.85.573 2.81.7A2 2 0 0122 16.92z"/></svg>
        Mua hàng
      </a>
    </div>

    <!-- ========== FOOTER ========== -->
    <footer class="site-footer">
      <div class="container">
        <div class="footer-grid">
          <div>
            <div class="footer-brand-name">SÂM <span class="gold">DTB</span> SHOP</div>
            <p class="footer-desc">
              Chuyên các sản phẩm Sâm &amp; Chăm sóc sức khoẻ nhập khẩu từ Hàn Quốc.
              Cam kết 100% chính hãng, chất lượng cao.
            </p>
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
</template>

<style scoped>
/* ========== PRODUCT DETAIL — Premium Dark+Gold ========== */

/* Hero / Breadcrumb */
.pd-hero {
  position: relative;
  min-height: 200px;
  display: flex;
  align-items: flex-end;
  background: linear-gradient(135deg, #1C1917 0%, #292524 60%, #1C1917 100%);
  padding: 0 0 40px;
  overflow: hidden;
}
.pd-hero-bg {
  position: absolute;
  inset: 0;
  background: radial-gradient(ellipse at 50% 0%, rgba(202,138,4,0.12) 0%, transparent 60%);
}
.pd-hero-content {
  position: relative;
  z-index: 1;
  padding-top: 120px;
}
.pd-hero-title {
  font-family: var(--font-heading);
  font-size: 2rem;
  font-weight: 600;
  color: #fff;
  margin: 0 0 12px;
}
.pd-breadcrumb {
  display: flex;
  align-items: center;
  gap: 8px;
  flex-wrap: wrap;
  font-family: var(--font-body);
  font-size: 0.9rem;
}
.pd-bc-link {
  color: rgba(255,255,255,0.6);
  text-decoration: none;
  transition: color 200ms;
}
.pd-bc-link:hover { color: var(--color-accent); }
.pd-bc-sep { color: rgba(255,255,255,0.3); }
.pd-bc-current { color: var(--color-accent); font-weight: 600; }

/* Product Info Grid */
.pd-info {
  padding: 48px 0;
  background: var(--color-bg);
}
.pd-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 48px;
  align-items: start;
}

/* Gallery */
.pd-gallery-main {
  border-radius: var(--radius-md);
  overflow: hidden;
  background: #fff;
  border: 1px solid var(--color-border);
  touch-action: pan-y;
}
.pd-gallery-main img {
  width: 100%;
  aspect-ratio: 1;
  object-fit: contain;
}
.pd-gallery-thumbs {
  display: flex;
  gap: 8px;
  margin-top: 12px;
}
.pd-gallery-thumbs img {
  width: 72px;
  height: 72px;
  object-fit: contain;
  border: 2px solid var(--color-border);
  border-radius: var(--radius-sm);
  padding: 3px;
  background: #fff;
  cursor: pointer;
  transition: border-color 200ms;
}
.pd-gallery-thumbs img.active {
  border-color: var(--color-accent);
}
.pd-gallery-thumbs img:hover {
  border-color: var(--color-accent-dark);
}

/* Details */
.pd-title {
  font-family: var(--font-heading);
  font-size: 1.8rem;
  font-weight: 700;
  color: var(--color-text);
  line-height: 1.3;
  margin: 0 0 16px;
}
.pd-short-desc {
  font-family: var(--font-body);
  font-size: 1rem;
  color: var(--color-text-muted);
  line-height: 1.7;
  margin: 0 0 24px;
}

/* Specs */
.pd-specs {
  border-top: 1px solid rgba(28,25,23,0.08);
  padding-top: 20px;
  margin-bottom: 28px;
}
.pd-spec-row {
  display: flex;
  padding: 8px 0;
  border-bottom: 1px solid rgba(28,25,23,0.04);
}
.pd-spec-label {
  font-weight: 600;
  font-size: 0.9rem;
  color: var(--color-text);
  min-width: 120px;
  font-family: var(--font-body);
}
.pd-spec-value {
  color: var(--color-text-muted);
  font-size: 0.9rem;
  font-family: var(--font-body);
}

/* CTA */
.pd-cta {
  display: flex;
  gap: 12px;
}
.pd-cta .btn {
  flex: 1;
  justify-content: center;
  padding: 14px 20px;
  font-size: 1rem;
}

/* Content Sections */
.pd-content {
  padding: 0 0 60px;
  background: var(--color-bg);
}
.pd-content .container {
  max-width: 900px;
}
.pd-block {
  margin-bottom: 40px;
}
.pd-block-title {
  font-family: var(--font-heading);
  font-size: 1.5rem;
  font-weight: 700;
  color: var(--color-primary);
  margin: 0 0 16px;
  padding-bottom: 12px;
  border-bottom: 2px solid var(--color-accent);
  display: inline-block;
}
.pd-block-title--accent {
  color: var(--color-accent-dark);
  font-size: 1.6rem;
}
.pd-block-title--gift {
  color: var(--color-accent);
  display: flex;
  align-items: center;
  gap: 10px;
  border-bottom: none;
}
.pd-gift-icon {
  width: 28px;
  height: 28px;
}
.pd-block-desc {
  font-family: var(--font-body);
  font-size: 1rem;
  color: var(--color-text-muted);
  line-height: 1.8;
}
.pd-block p {
  font-family: var(--font-body);
  color: var(--color-text);
  line-height: 1.8;
  margin: 0;
}

/* Lists */
.pd-list {
  list-style: none;
  padding: 0;
  margin: 0;
}
.pd-list li {
  position: relative;
  padding: 8px 0 8px 28px;
  font-family: var(--font-body);
  font-size: 0.95rem;
  line-height: 1.7;
  color: var(--color-text);
}
.pd-list li::before {
  content: "✦";
  position: absolute;
  left: 0;
  color: var(--color-accent);
  font-size: 0.75rem;
  top: 12px;
}
.pd-list--warn li::before {
  content: "⚠";
  font-size: 0.8rem;
  color: var(--color-hotline);
}

/* Commitment */
.pd-commitment {
  list-style: none;
  padding: 0;
  margin: 0;
}
.pd-commitment li {
  padding: 12px 0 12px 28px;
  position: relative;
  border-bottom: 1px solid rgba(28,25,23,0.06);
}
.pd-commitment li::before {
  content: "✔";
  position: absolute;
  left: 0;
  color: var(--color-accent);
  font-weight: bold;
  top: 14px;
}
.pd-commitment h3 {
  font-family: var(--font-heading);
  font-size: 1.1rem;
  font-weight: 600;
  color: var(--color-primary);
  margin: 0 0 4px;
}
.pd-commitment span {
  font-family: var(--font-body);
  font-size: 0.9rem;
  color: var(--color-text-muted);
}
.pd-commitment-cta {
  text-align: center;
  margin-top: 24px;
  font-weight: 700;
  text-transform: uppercase;
  color: var(--color-accent-dark);
  font-family: var(--font-body);
  font-size: 0.95rem;
}

/* Gift block */
.pd-gift {
  background: linear-gradient(135deg, rgba(202,138,4,0.06) 0%, rgba(234,179,8,0.04) 100%);
  border-radius: var(--radius-md);
  padding: 28px;
  border: 1px solid rgba(202,138,4,0.15);
}

/* Mobile CTA */
.pd-mobile-cta {
  display: none;
}

/* Responsive */
@media (max-width: 768px) {
  .pd-grid {
    grid-template-columns: 1fr;
    gap: 32px;
  }
  .pd-hero-title { font-size: 1.5rem; }
  .pd-title { font-size: 1.4rem; }
  .pd-hero-content { padding-top: 100px; }
  .pd-cta { display: none; }
  .pd-mobile-cta {
    display: flex !important;
    position: fixed;
    bottom: 0;
    left: 0;
    right: 0;
    z-index: 9999;
    background: #fff;
    padding: 8px 16px;
    gap: 8px;
    box-shadow: 0 -4px 16px rgba(0,0,0,0.1);
  }
  .pd-mobile-cta .btn {
    flex: 1;
    padding: 12px 0;
    font-size: 0.9rem;
    justify-content: center;
  }
  .pd-content { padding-bottom: 80px; }
  .pd-block-title { font-size: 1.3rem; }
  .header-cta { display: none !important; }
}
</style>
