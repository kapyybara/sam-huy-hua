import { createRouter, createWebHistory } from 'vue-router'
import HomePage from './views/HomePage.vue'
import ProductDetail from './views/ProductDetail.vue'

const router = createRouter({
  history: createWebHistory(),
  routes: [
    {
      path: '/',
      name: 'home',
      component: HomePage,
    },
    {
      path: '/san-pham/:slug',
      name: 'product',
      component: ProductDetail,
    },
  ],
  scrollBehavior(_to, _from, savedPosition) {
    if (savedPosition) return savedPosition
    return { top: 0 }
  },
})

export default router
