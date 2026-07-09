#!/data/data/com.termux/files/usr/bin/bash
#
# termux-dev-setup
# One-command Node.js + Git/SSH/GitHub development environment for Termux
# Author: Mema | https://github.com/maisaidam2504-droid
#
# Usage: bash setup.sh

set -e

# ---------- Colors ----------
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

log()  { echo -e "${GREEN}[✓]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }
err()  { echo -e "${RED}[✗]${NC} $1"; }
step() { echo -e "\n${CYAN}==> $1${NC}"; }

echo -e "${CYAN}"
echo "  termux-dev-setup — بيئة تطوير جاهزة لـ Termux"
echo "  Node.js + Git + SSH + GitHub, in one command"
echo -e "${NC}"

# ---------- 1. Storage permission ----------
step "1/7 إعداد صلاحيات التخزين (Storage Permission)"
if [ ! -d "$HOME/storage" ]; then
  termux-setup-storage
  sleep 1
  log "تم طلب صلاحية التخزين — اقبل الإذن إذا ظهرت نافذة"
else
  log "صلاحية التخزين مفعّلة مسبقاً"
fi

# ---------- 2. Update & upgrade packages ----------
step "2/7 تحديث الحزم الأساسية"
pkg update -y && pkg upgrade -y
log "تم تحديث النظام"

# ---------- 3. Core packages ----------
step "3/7 تثبيت الأدوات الأساسية (git, vim, python, openssh, nodejs, build tools)"
pkg install -y git vim python openssh nodejs-lts build-essential which curl wget
log "تم تثبيت الأدوات الأساسية"

# node-gyp يحتاج هذي الحزم لبناء native modules (مصدر شائع للأعطال)
pkg install -y python-pip clang make libtool pkg-config
log "تم تثبيت أدوات بناء native modules (لتفادي أخطاء npm install الشائعة)"

# ---------- 4. npm global prefix fix (permission errors) ----------
step "4/7 إصلاح صلاحيات npm العالمية (تفادي EACCES)"
mkdir -p "$HOME/.npm-global"
npm config set prefix "$HOME/.npm-global"
if ! grep -q "npm-global" "$HOME/.bashrc" 2>/dev/null; then
  echo 'export PATH="$HOME/.npm-global/bin:$PATH"' >> "$HOME/.bashrc"
fi
log "npm جاهز بدون مشاكل صلاحيات (لا حاجة لـ sudo/root)"

# ---------- 5. Git configuration ----------
step "5/7 إعداد Git"
CURRENT_NAME=$(git config --global user.name || true)
CURRENT_EMAIL=$(git config --global user.email || true)

if [ -z "$CURRENT_NAME" ]; then
  read -p "  أدخل اسمك لـ Git commits: " GIT_NAME
  git config --global user.name "$GIT_NAME"
fi
if [ -z "$CURRENT_EMAIL" ]; then
  read -p "  أدخل بريدك الإلكتروني (نفس بريد GitHub): " GIT_EMAIL
  git config --global user.email "$GIT_EMAIL"
fi

git config --global init.defaultBranch main
git config --global credential.helper "cache --timeout=7200"
git config --global pull.rebase false
log "تم إعداد Git (اسم، بريد، فرع افتراضي main)"

# ---------- 6. SSH key + GitHub setup ----------
step "6/7 إعداد مفتاح SSH لربط GitHub"
SSH_KEY="$HOME/.ssh/id_ed25519"

if [ -f "$SSH_KEY" ]; then
  log "يوجد مفتاح SSH مسبقاً، تم تخطي الإنشاء"
else
  mkdir -p "$HOME/.ssh" && chmod 700 "$HOME/.ssh"
  ssh-keygen -t ed25519 -C "${GIT_EMAIL:-$CURRENT_EMAIL}" -f "$SSH_KEY" -N ""
  log "تم إنشاء مفتاح SSH جديد (ed25519)"
fi

eval "$(ssh-agent -s)" > /dev/null
ssh-add "$SSH_KEY" > /dev/null 2>&1 || true

echo ""
warn "الخطوة الأهم: انسخ هذا المفتاح العام وأضفه إلى GitHub"
echo "   Settings → SSH and GPG keys → New SSH key"
echo ""
echo -e "${CYAN}--------- Public Key (انسخ من هنا) ---------${NC}"
cat "${SSH_KEY}.pub"
echo -e "${CYAN}---------------------------------------------${NC}"
echo ""
echo "  رابط مباشر لإضافة المفتاح: https://github.com/settings/ssh/new"

# ---------- 7. Verify ----------
step "7/7 التحقق من التثبيت"
echo "Node.js : $(node -v 2>/dev/null || echo 'غير مثبت')"
echo "npm     : $(npm -v 2>/dev/null || echo 'غير مثبت')"
echo "Git     : $(git --version 2>/dev/null || echo 'غير مثبت')"
echo "Python  : $(python --version 2>/dev/null || echo 'غير مثبت')"

echo ""
log "اكتمل الإعداد بنجاح! 🎉"
echo ""
echo "الخطوات التالية:"
echo "  1. أضف مفتاح SSH أعلاه إلى GitHub (الرابط بالأعلى)"
echo "  2. اختبر الاتصال: ssh -T git@github.com"
echo "  3. أعد تشغيل Termux أو نفّذ: source ~/.bashrc"
echo "  4. جرّب: git clone git@github.com:username/repo.git"
