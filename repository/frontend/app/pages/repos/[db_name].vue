<script setup lang="ts">
import {
  Search, X, Download, Trash2, ChevronLeft, ChevronRight,
  FileText, FileCode, ArrowLeft
} from 'lucide-vue-next'

definePageMeta({ layout: 'default' })

const route = useRoute()
const db_name = computed(() => route.params.db_name as string)
const { apiFetch, user } = useAuth()
const { setTitle } = useTopbar()
setTitle(route.params.db_name as string) // updated to display name after loadRepoName()

// ── Types ────────────────────────────────────────────────────────────────────
interface ObjectListItem {
  id: number
  obj_type: string | null
  name: string | null
  author: string | null
  submitted: string | null
  data_type: string | null
  has_binary: boolean
}

interface ObjectListResponse {
  items: ObjectListItem[]
  total: number
  page: number
  page_size: number
}

interface TransactionEntry {
  username: string | null
  transdate: string | null
  direction: string | null
}

interface TypeData {
  xunits?: string | null
  yunits?: string | null
  fs?: number | null
  nsecs?: number | null
  t0?: string | null
  t0_adjusted?: string | null
  toffset?: number | null
  in_file?: string | null
}

interface ObjectDetail {
  id: number
  obj_type: string | null
  name: string | null
  author: string | null
  created: string | null
  version: string | null
  ip: string | null
  hostname: string | null
  os: string | null
  submitted: string | null
  experiment_title: string | null
  experiment_desc: string | null
  analysis_desc: string | null
  quantity: string | null
  additional_authors: string | null
  additional_comments: string | null
  keywords: string | null
  reference_ids: string | null
  validated: number | null
  vdate: string | null
  has_xml: boolean
  has_binary: boolean
  data_type: string | null
  type_data: TypeData | null
  transactions: TransactionEntry[]
}

// ── Object list state ─────────────────────────────────────────────────────────
const objects = ref<ObjectListItem[]>([])
const total = ref(0)
const page = ref(1)
const pageSize = 50
const loading = ref(false)
const listError = ref('')

const filters = reactive({
  name: '',
  obj_type: '',
  author: '',
  date_from: '',
  date_to: '',
})

const OBJ_TYPES = [
  'ao', 'collection', 'filterbank', 'matrix', 'mfir', 'miir',
  'parfrac', 'pest', 'plist', 'pzmodel', 'rational', 'smodel', 'ssm', 'timespan',
]

const totalPages = computed(() => Math.ceil(total.value / pageSize) || 1)

// ── Detail panel state ────────────────────────────────────────────────────────
const selectedId = ref<number | null>(null)
const detail = ref<ObjectDetail | null>(null)
const detailLoading = ref(false)
const detailError = ref('')

// ── Selection for bulk delete ─────────────────────────────────────────────────
const selected = ref<Set<number>>(new Set())
const deleteLoading = ref(false)

// ── Repo name ─────────────────────────────────────────────────────────────────
const repoName = ref<string>('')

async function loadRepoName() {
  try {
    const r = await apiFetch<{ name: string }>(`/repos/${db_name.value}`)
    repoName.value = r.name
    setTitle(r.name)
  } catch {
    repoName.value = db_name.value
  }
}

// ── Load objects ──────────────────────────────────────────────────────────────
async function loadObjects() {
  loading.value = true
  listError.value = ''
  try {
    const params = new URLSearchParams()
    params.set('page', String(page.value))
    params.set('page_size', String(pageSize))
    if (filters.name) params.set('name', filters.name)
    if (filters.obj_type) params.set('obj_type', filters.obj_type)
    if (filters.author) params.set('author', filters.author)
    if (filters.date_from) params.set('date_from', filters.date_from)
    if (filters.date_to) params.set('date_to', filters.date_to)

    const res = await apiFetch<ObjectListResponse>(
      `/repos/${db_name.value}/objects?${params.toString()}`
    )
    objects.value = res.items
    total.value = res.total
    selected.value.clear()
  } catch (e: unknown) {
    const fe = e as { data?: { detail?: string }; message?: string }
    listError.value = fe?.data?.detail || fe?.message || 'Failed to load objects.'
  } finally {
    loading.value = false
  }
}

function applyFilters() {
  page.value = 1
  selectedId.value = null
  detail.value = null
  loadObjects()
}

function clearFilters() {
  Object.assign(filters, { name: '', obj_type: '', author: '', date_from: '', date_to: '' })
  applyFilters()
}

function goPage(n: number) {
  if (n < 1 || n > totalPages.value) return
  page.value = n
  loadObjects()
}

// ── Load detail ───────────────────────────────────────────────────────────────
async function openDetail(obj: ObjectListItem) {
  selectedId.value = obj.id
  detail.value = null
  detailError.value = ''
  detailLoading.value = true
  try {
    detail.value = await apiFetch<ObjectDetail>(`/repos/${db_name.value}/objects/${obj.id}`)
  } catch (e: unknown) {
    const fe = e as { data?: { detail?: string }; message?: string }
    detailError.value = fe?.data?.detail || fe?.message || 'Failed to load object.'
  } finally {
    detailLoading.value = false
  }
}

// ── Downloads ─────────────────────────────────────────────────────────────────
async function downloadFile(obj_id: number, type: 'xml' | 'binary') {
  try {
    const ext = type === 'xml' ? 'xml' : 'mat'
    const blob = await apiFetch<Blob>(
      `/repos/${db_name.value}/objects/${obj_id}/${type}`,
      { responseType: 'blob' }
    )
    const url = URL.createObjectURL(blob)
    const a = document.createElement('a')
    a.href = url
    a.download = `${db_name.value}_${obj_id}.${ext}`
    a.click()
    URL.revokeObjectURL(url)
  } catch {
    alert('Download failed.')
  }
}

// ── Delete ────────────────────────────────────────────────────────────────────
async function deleteSelected() {
  if (!selected.value.size) return
  if (!confirm(`Delete ${selected.value.size} object(s)? This cannot be undone.`)) return
  deleteLoading.value = true
  try {
    await apiFetch(`/repos/${db_name.value}/objects`, {
      method: 'DELETE',
      body: { ids: [...selected.value] },
    })
    if (selectedId.value && selected.value.has(selectedId.value)) {
      selectedId.value = null
      detail.value = null
    }
    await loadObjects()
  } catch (e: unknown) {
    const fe = e as { data?: { detail?: string }; message?: string }
    listError.value = fe?.data?.detail || fe?.message || 'Delete failed.'
  } finally {
    deleteLoading.value = false
  }
}

function toggleSelect(id: number) {
  if (selected.value.has(id)) selected.value.delete(id)
  else selected.value.add(id)
}

// ── Helpers ───────────────────────────────────────────────────────────────────
function fmt(dt: string | null) {
  if (!dt) return '—'
  return new Date(dt).toLocaleString('en-US', { year: 'numeric', month: 'short', day: 'numeric', hour: '2-digit', minute: '2-digit' })
}

function fmtDate(dt: string | null) {
  if (!dt) return '—'
  return new Date(dt).toLocaleDateString('en-US', { year: 'numeric', month: 'short', day: 'numeric' })
}

onMounted(async () => {
  await loadRepoName()
  await loadObjects()
})
</script>

<template>
  <main class="main">

      <!-- ── Filter bar ── -->
      <form class="filter-bar" @submit.prevent="applyFilters">
        <input v-model="filters.name" placeholder="Name…" class="filter-input" />
        <select v-model="filters.obj_type" class="filter-select">
          <option value="">All types</option>
          <option v-for="t in OBJ_TYPES" :key="t" :value="t">{{ t }}</option>
        </select>
        <input v-model="filters.author" placeholder="Author…" class="filter-input" />
        <input v-model="filters.date_from" type="date" class="filter-date" title="Submitted from" />
        <input v-model="filters.date_to" type="date" class="filter-date" title="Submitted to" />
        <button type="submit" class="btn-primary btn-sm">
          <Search :size="13" />
          Search
        </button>
        <button type="button" class="btn-ghost btn-sm" @click="clearFilters">
          <X :size="13" />
          Clear
        </button>
        <div class="filter-spacer" />
        <button
          v-if="user?.is_admin && selected.size > 0"
          type="button"
          class="btn-danger btn-sm"
          :disabled="deleteLoading"
          @click="deleteSelected"
        >
          <Trash2 :size="13" />
          Delete ({{ selected.size }})
        </button>
      </form>

      <div v-if="listError" class="banner-error">
        {{ listError }}
        <button @click="listError = ''">✕</button>
      </div>

      <!-- ── Content area ── -->
      <div class="content-area" :class="{ 'with-panel': selectedId !== null }">

        <!-- Object table -->
        <div class="list-panel">
          <div v-if="loading" class="loading-wrap">
            <div class="spin" />
          </div>

          <template v-else>
            <div class="table-wrap">
              <table class="table">
                <thead>
                  <tr>
                    <th v-if="user?.is_admin" class="th-check" />
                    <th>ID</th>
                    <th>Name</th>
                    <th>Type</th>
                    <th>Data type</th>
                    <th>Author</th>
                    <th>Submitted</th>
                    <th>Downloads</th>
                  </tr>
                </thead>
                <tbody>
                  <tr
                    v-for="obj in objects"
                    :key="obj.id"
                    :class="{ 'row-selected': selectedId === obj.id }"
                    @click="openDetail(obj)"
                    style="cursor: pointer"
                  >
                    <td v-if="user?.is_admin" class="td-check" @click.stop>
                      <input
                        type="checkbox"
                        :checked="selected.has(obj.id)"
                        @change="toggleSelect(obj.id)"
                      />
                    </td>
                    <td class="td-id">{{ obj.id }}</td>
                    <td class="td-name">{{ obj.name || '—' }}</td>
                    <td><span class="type-badge">{{ obj.obj_type || '—' }}</span></td>
                    <td class="td-sub">{{ obj.data_type || '—' }}</td>
                    <td>{{ obj.author || '—' }}</td>
                    <td class="td-date">{{ fmtDate(obj.submitted) }}</td>
                    <td class="td-dl" @click.stop>
                      <button
                        class="dl-btn"
                        title="Download XML"
                        @click="downloadFile(obj.id, 'xml')"
                      >
                        <FileCode :size="13" />
                      </button>
                      <button
                        v-if="obj.has_binary"
                        class="dl-btn"
                        title="Download binary (.mat)"
                        @click="downloadFile(obj.id, 'binary')"
                      >
                        <FileText :size="13" />
                        .mat
                      </button>
                    </td>
                  </tr>
                  <tr v-if="objects.length === 0">
                    <td :colspan="user?.is_admin ? 8 : 7" class="empty-row">
                      No objects found.
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>

            <!-- Pagination -->
            <div class="pagination">
              <span class="pg-info">
                {{ total.toLocaleString() }} object{{ total === 1 ? '' : 's' }}
                <template v-if="totalPages > 1">
                  — page {{ page }} of {{ totalPages }}
                </template>
              </span>
              <div class="pg-btns">
                <button class="pg-btn" :disabled="page <= 1" @click="goPage(page - 1)">
                  <ChevronLeft :size="14" />
                </button>
                <button class="pg-btn" :disabled="page >= totalPages" @click="goPage(page + 1)">
                  <ChevronRight :size="14" />
                </button>
              </div>
            </div>
          </template>
        </div>

        <!-- ── Detail panel ── -->
        <div v-if="selectedId !== null" class="detail-panel">
          <div class="detail-head">
            <span class="detail-title">Object #{{ selectedId }}</span>
            <button class="close-btn" @click="selectedId = null; detail = null">
              <X :size="14" />
            </button>
          </div>

          <div v-if="detailLoading" class="detail-loading">
            <div class="spin" />
          </div>
          <div v-else-if="detailError" class="detail-error">{{ detailError }}</div>
          <template v-else-if="detail">

            <div class="detail-dl-row">
              <button v-if="detail.has_xml" class="btn-dl" @click="downloadFile(detail.id, 'xml')">
                <FileCode :size="13" />
                Download XML
              </button>
              <button v-if="detail.has_binary" class="btn-dl" @click="downloadFile(detail.id, 'binary')">
                <FileText :size="13" />
                Download .mat
              </button>
            </div>

            <div class="detail-section">
              <div class="detail-row">
                <span class="dl">Type</span>
                <span class="dv"><span class="type-badge">{{ detail.obj_type }}</span></span>
              </div>
              <div class="detail-row" v-if="detail.data_type">
                <span class="dl">Data type</span>
                <span class="dv">{{ detail.data_type }}</span>
              </div>
              <div class="detail-row">
                <span class="dl">Name</span>
                <span class="dv">{{ detail.name || '—' }}</span>
              </div>
              <div class="detail-row">
                <span class="dl">Author</span>
                <span class="dv">{{ detail.author || '—' }}</span>
              </div>
              <div class="detail-row">
                <span class="dl">Created</span>
                <span class="dv">{{ fmt(detail.created) }}</span>
              </div>
              <div class="detail-row">
                <span class="dl">Submitted</span>
                <span class="dv">{{ fmt(detail.submitted) }}</span>
              </div>
              <div class="detail-row" v-if="detail.version">
                <span class="dl">Version</span>
                <span class="dv mono">{{ detail.version }}</span>
              </div>
              <div class="detail-row" v-if="detail.hostname">
                <span class="dl">Host</span>
                <span class="dv mono">{{ detail.hostname }}</span>
              </div>
            </div>

            <div v-if="detail.experiment_title || detail.experiment_desc || detail.analysis_desc || detail.quantity" class="detail-section">
              <div class="detail-section-head">Experiment</div>
              <div class="detail-row" v-if="detail.experiment_title">
                <span class="dl">Title</span>
                <span class="dv">{{ detail.experiment_title }}</span>
              </div>
              <div class="detail-row" v-if="detail.quantity">
                <span class="dl">Quantity</span>
                <span class="dv">{{ detail.quantity }}</span>
              </div>
              <div class="detail-row" v-if="detail.experiment_desc">
                <span class="dl">Exp. desc</span>
                <span class="dv">{{ detail.experiment_desc }}</span>
              </div>
              <div class="detail-row" v-if="detail.analysis_desc">
                <span class="dl">Analysis desc</span>
                <span class="dv">{{ detail.analysis_desc }}</span>
              </div>
              <div class="detail-row" v-if="detail.keywords">
                <span class="dl">Keywords</span>
                <span class="dv">{{ detail.keywords }}</span>
              </div>
              <div class="detail-row" v-if="detail.additional_comments">
                <span class="dl">Comments</span>
                <span class="dv">{{ detail.additional_comments }}</span>
              </div>
            </div>

            <div v-if="detail.type_data" class="detail-section">
              <div class="detail-section-head">Signal data</div>
              <template v-if="detail.data_type === 'tsdata'">
                <div class="detail-row" v-if="detail.type_data.t0_adjusted">
                  <span class="dl">t0</span>
                  <span class="dv mono">{{ fmt(detail.type_data.t0_adjusted) }}</span>
                </div>
                <div class="detail-row" v-if="detail.type_data.nsecs != null">
                  <span class="dl">Duration</span>
                  <span class="dv mono">{{ detail.type_data.nsecs }} s</span>
                </div>
                <div class="detail-row" v-if="detail.type_data.fs != null">
                  <span class="dl">Sample rate</span>
                  <span class="dv mono">{{ detail.type_data.fs }} Hz</span>
                </div>
              </template>
              <template v-else-if="detail.data_type === 'fsdata'">
                <div class="detail-row" v-if="detail.type_data.fs != null">
                  <span class="dl">Sample rate</span>
                  <span class="dv mono">{{ detail.type_data.fs }} Hz</span>
                </div>
              </template>
              <div class="detail-row" v-if="detail.type_data.xunits">
                <span class="dl">X units</span>
                <span class="dv mono">{{ detail.type_data.xunits }}</span>
              </div>
              <div class="detail-row" v-if="detail.type_data.yunits">
                <span class="dl">Y units</span>
                <span class="dv mono">{{ detail.type_data.yunits }}</span>
              </div>
            </div>

            <div v-if="detail.validated != null" class="detail-section">
              <div class="detail-row">
                <span class="dl">Validated</span>
                <span class="dv">{{ detail.validated ? 'Yes' : 'No' }}<template v-if="detail.vdate"> ({{ fmtDate(detail.vdate) }})</template></span>
              </div>
            </div>

            <div v-if="detail.transactions.length" class="detail-section">
              <div class="detail-section-head">Transaction history</div>
              <table class="tx-table">
                <thead><tr><th>User</th><th>Date</th><th>Action</th></tr></thead>
                <tbody>
                  <tr v-for="(tx, i) in detail.transactions" :key="i">
                    <td>{{ tx.username || '—' }}</td>
                    <td>{{ fmt(tx.transdate) }}</td>
                    <td><span class="tx-dir" :class="`tx-${tx.direction}`">{{ tx.direction }}</span></td>
                  </tr>
                </tbody>
              </table>
            </div>

          </template>
        </div>

      </div>
  </main>
</template>

<style scoped>
.main { flex: 1; display: flex; flex-direction: column; padding: 1.5rem 1.5rem; gap: 1rem; overflow: hidden; }

/* ── Filter bar ── */
.filter-bar {
  display: flex; align-items: center; flex-wrap: wrap; gap: 0.5rem;
  padding: 0.75rem 1rem; background: #fff; border: 1px solid #d0dcea; border-radius: 10px;
  flex-shrink: 0;
}
.filter-input {
  flex: 1; min-width: 110px; max-width: 180px;
  height: 32px; padding: 0 0.6rem; font-size: 0.8rem;
  border: 1px solid #c8d8ec; border-radius: 6px; background: #fff; color: #1e3050;
}
.filter-select {
  height: 32px; padding: 0 0.5rem; font-size: 0.8rem;
  border: 1px solid #c8d8ec; border-radius: 6px; background: #fff; color: #1e3050; cursor: pointer;
}
.filter-date {
  height: 32px; padding: 0 0.5rem; font-size: 0.8rem;
  border: 1px solid #c8d8ec; border-radius: 6px; background: #fff; color: #1e3050;
}
.filter-spacer { flex: 1; }
.btn-sm { height: 32px; padding: 0 0.75rem; font-size: 0.8rem; }
.btn-danger {
  display: flex; align-items: center; gap: 0.3rem;
  background: #fef2f2; color: #b91c1c; border: 1px solid #fecaca;
  border-radius: 6px; padding: 0 0.75rem; height: 32px; font-size: 0.8rem;
  font-weight: 500; cursor: pointer; transition: background 0.1s;
}
.btn-danger:hover { background: #fee2e2; }
.btn-danger:disabled { opacity: 0.5; cursor: not-allowed; }

/* ── Content area ── */
.content-area {
  display: flex; gap: 1rem; flex: 1; min-height: 0; overflow: hidden;
}
.list-panel {
  flex: 1; display: flex; flex-direction: column; min-width: 0;
  background: #fff; border: 1px solid #d0dcea; border-radius: 12px; overflow: hidden;
}
.content-area.with-panel .list-panel { flex: 3; }
.loading-wrap { display: flex; justify-content: center; padding: 4rem; flex: 1; }
.table-wrap { flex: 1; overflow: auto; }

/* ── Table ── */
.table { width: 100%; border-collapse: collapse; font-size: 0.8rem; }
.table thead th {
  position: sticky; top: 0; z-index: 1;
  padding: 0.6rem 0.9rem; text-align: left;
  font-size: 0.65rem; font-weight: 700; text-transform: uppercase; letter-spacing: 0.08em;
  color: #8aa0b8; background: #f4f7fb; border-bottom: 1px solid #d0dcea;
  white-space: nowrap;
}
.th-check { width: 36px; }
.table tbody tr { transition: background 0.1s; }
.table tbody tr:hover { background: #f8fafd; }
.table tbody tr.row-selected { background: #eff6ff; }
.table tbody td { padding: 0.6rem 0.9rem; border-bottom: 1px solid #e8eef6; color: #4a6080; vertical-align: middle; }
.table tbody tr:last-child td { border-bottom: none; }
.td-check { width: 36px; }
.td-id { font-variant-numeric: tabular-nums; color: #8aa0b8; font-size: 0.75rem; }
.td-name { font-weight: 600; color: #1e3050; max-width: 160px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
.td-sub { color: #8aa0b8; font-size: 0.78rem; }
.td-date { white-space: nowrap; font-size: 0.78rem; }
.td-dl { display: flex; gap: 0.3rem; align-items: center; }
.type-badge {
  font-size: 0.68rem; font-weight: 600; letter-spacing: 0.04em;
  padding: 0.15em 0.5em; border-radius: 999px;
  background: #e8eef6; color: #4a6080;
}
.dl-btn {
  display: flex; align-items: center; gap: 0.2rem;
  font-size: 0.72rem; color: #6a84a0; background: none; border: 1px solid #d0dcea;
  border-radius: 5px; padding: 0.2rem 0.45rem; cursor: pointer; white-space: nowrap;
  transition: background 0.1s, color 0.1s;
}
.dl-btn:hover { background: #eff6ff; color: #1d4ed8; border-color: #bfdbfe; }
.empty-row { text-align: center; color: #b8cce0; padding: 3rem; font-size: 0.825rem; }

/* ── Pagination ── */
.pagination {
  display: flex; align-items: center; justify-content: space-between;
  padding: 0.65rem 1rem; border-top: 1px solid #e8eef6; flex-shrink: 0;
  font-size: 0.775rem; color: #8aa0b8;
}
.pg-btns { display: flex; gap: 0.3rem; }
.pg-btn {
  width: 28px; height: 28px; display: flex; align-items: center; justify-content: center;
  background: none; border: 1px solid #d0dcea; border-radius: 6px; cursor: pointer;
  color: #6a84a0; transition: background 0.1s;
}
.pg-btn:hover:not(:disabled) { background: #f0f5fb; }
.pg-btn:disabled { opacity: 0.3; cursor: not-allowed; }

/* ── Detail panel ── */
.detail-panel {
  width: 340px; flex-shrink: 0; display: flex; flex-direction: column;
  background: #fff; border: 1px solid #d0dcea; border-radius: 12px; overflow: hidden;
}
.detail-head {
  display: flex; align-items: center; justify-content: space-between;
  padding: 0.85rem 1rem; border-bottom: 1px solid #e8eef6; flex-shrink: 0;
  background: #f4f7fb;
}
.detail-title { font-size: 0.825rem; font-weight: 700; color: #1e3050; }
.close-btn {
  width: 26px; height: 26px; display: flex; align-items: center; justify-content: center;
  background: none; border: none; cursor: pointer; color: #a8bdd0; border-radius: 5px;
  transition: background 0.1s, color 0.1s;
}
.close-btn:hover { background: #e8eef6; color: #4a6080; }
.close-btn svg { width: 12px; height: 12px; }

.detail-loading { display: flex; justify-content: center; padding: 3rem; }
.detail-error { padding: 1rem; font-size: 0.8rem; color: #b91c1c; }

.detail-dl-row {
  display: flex; gap: 0.5rem; padding: 0.75rem 1rem; border-bottom: 1px solid #e8eef6;
  flex-shrink: 0;
}
.btn-dl {
  display: flex; align-items: center; gap: 0.35rem; flex: 1; justify-content: center;
  font-size: 0.775rem; font-weight: 600; color: #2a70c8;
  background: #eff6ff; border: 1px solid #bfdbfe; border-radius: 7px;
  padding: 0.45rem 0.5rem; cursor: pointer; transition: background 0.1s;
}
.btn-dl:hover { background: #dbeafe; }

.detail-panel > * { flex-shrink: 0; }
.detail-panel .detail-section { overflow: auto; }
.detail-section {
  padding: 0.9rem 1rem; border-bottom: 1px solid #e8eef6; font-size: 0.78rem;
}
.detail-section:last-child { border-bottom: none; flex: 1; overflow: auto; }
.detail-section-head {
  font-size: 0.65rem; font-weight: 700; text-transform: uppercase; letter-spacing: 0.08em;
  color: #8aa0b8; margin-bottom: 0.6rem;
}
.detail-row { display: flex; gap: 0.5rem; align-items: baseline; padding: 0.25rem 0; }
.dl { width: 100px; flex-shrink: 0; font-weight: 600; color: #6a84a0; font-size: 0.75rem; }
.dv { color: #1e3050; line-height: 1.4; word-break: break-word; }
.dv.mono { font-family: 'JetBrains Mono', ui-monospace, monospace; font-size: 0.78rem; }

/* ── Transaction table ── */
.tx-table { width: 100%; border-collapse: collapse; font-size: 0.75rem; margin-top: 0.3rem; }
.tx-table th {
  text-align: left; padding: 0.3rem 0.5rem;
  font-size: 0.63rem; font-weight: 700; text-transform: uppercase; letter-spacing: 0.07em;
  color: #a8bdd0; border-bottom: 1px solid #e8eef6;
}
.tx-table td { padding: 0.35rem 0.5rem; border-bottom: 1px solid #f0f4fa; color: #4a6080; }
.tx-table tr:last-child td { border-bottom: none; }
.tx-dir {
  font-size: 0.68rem; font-weight: 700; letter-spacing: 0.04em; text-transform: uppercase;
  padding: 0.1em 0.45em; border-radius: 999px;
}
.tx-download { background: #e8f5e9; color: #2e7d32; }
.tx-delete   { background: #fef2f2; color: #b91c1c; }
</style>
