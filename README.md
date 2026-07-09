# termux-dev-setup

بيئة تطوير Node.js كاملة على Termux بأمر واحد — تثبيت، إعداد Git، وربط GitHub عبر SSH تلقائياً.

One-command Node.js development environment for Termux — installs everything, configures Git, and sets up SSH access to GitHub automatically.

---

## المشكلة (The Problem)

آلاف المطورين حول العالم يبدؤون التعلم والبرمجة من هواتفهم عبر Termux، لكن معظم الأدوات والدروس مبنية على افتراض وجود حاسوب كامل. النتيجة: ساعات ضائعة في حل نفس الأخطاء المتكررة:

- أخطاء npm install بسبب صلاحيات أو نقص أدوات البناء
- تعقيد إعداد مفاتيح SSH وربطها بحساب GitHub من الموبايل
- أخطاء EACCES عند تثبيت حزم npm عالمياً
- عدم معرفة أي الحزم الأساسية يجب تثبيتها من البداية

هذا المشروع مبني من تجربة حقيقية: كل خطوة فيه حلّت مشكلة واجهتها فعلياً أثناء تطوير مشاريعي، بالكامل من هاتف Samsung A35 عبر Termux، بدون أي حاسوب.

## ما الذي يفعله السكريبت؟

| # | الخطوة | التفاصيل |
|---|--------|----------|
| 1 | صلاحيات التخزين | termux-setup-storage تلقائياً |
| 2 | تحديث النظام | pkg update && pkg upgrade |
| 3 | الأدوات الأساسية | git, vim, python, openssh, nodejs-lts, build-essential |
| 4 | أدوات البناء | clang, make, libtool, pkg-config |
| 5 | إصلاح npm | تغيير الـ prefix لتفادي أخطاء الصلاحيات بدون root |
| 6 | إعداد Git | اسم، بريد، main كفرع افتراضي |
| 7 | مفتاح SSH + GitHub | توليد مفتاح ed25519 وعرضه جاهزاً للإضافة إلى GitHub |

## التثبيت (Installation)

```bash
git clone https://github.com/maisaidam2504-droid/termux-dev-setup.git
cd termux-dev-setup
bash setup.sh
