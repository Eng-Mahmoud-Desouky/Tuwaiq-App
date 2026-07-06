# 🎨 نظام التصميم — تطبيق $CRATCH (سابقاً Tuwaiq App)

يصف هذا الملف نظام التصميم (Design System) المطبق حالياً في تطبيق **$CRATCH**، والذي تم تحويله من السمات الافتراضية إلى مظهر مظلم متميز (Premium Dark Aesthetic) مع تفاصيل معدنية عالية التباين، لتوفير تجربة مستخدم عصرية وفاخرة تناسب هوية التطبيق الجديدة.

---

## 1. الهوية البصرية والتوجه الفني

- **الاسم التجاري الجديد:** $CRATCH
- **السمة العامة:** واجهة مظلمة بالكامل (Pitch Black) خالية من الوهج، مع لمسات معدنية فضية ورمادية مستوحاة من شعار الكروم الشفاف لـ `$CRATCH`.
- **أهداف التصميم:**
  - تقديم واجهة تبهر المستخدم من النظرة الأولى بلمسات عصرية متميزة.
  - تقليل إجهاد العين باستخدام ألوان داكنة مريحة.
  - الحفاظ على أداء التطبيق وسلاسة الحركة عبر قيود استهلاك الذاكرة وتخفيف الفيديو.

---

## 2. لوحة الألوان (Colors Palette)

تم توحيد الألوان داخل الفئة [AppColors](file:///c:/Users/IT/StudioProjects/tuwaiq_app/lib/shared/theme/app_colors.dart) وتطبيقها عبر كامل عناصر التطبيق لضمان اتساق الواجهات:

### الألوان الأساسية والثانوية (Brand Colors)

| اسم اللون في الكود | رمز اللون (Hex) | الوصف والاستخدام |
| :--- | :--- | :--- |
| `primary` | `#E2E8F0` | اللون الفضي المعدني الكرومي (اللون الأساسي للتفاعل والأزرار الرئيسية) |
| `onPrimary` | `#000000` | لون النصوص أو الأيقونات التي تظهر فوق اللون الأساسي |
| `primaryContainer` | `#1E293B` | خلفية الحاويات ذات الأهمية العالية (رمادي حديدي سلست) |
| `onPrimaryContainer` | `#F1F5F9` | لون النصوص فوق حاويات اللون الأساسي |
| `secondary` | `#94A3B8` | رمادي صخري باهت (للنصوص الثانوية والعناصر الأقل أهمية) |
| `onSecondary` | `#000000` | لون النصوص فوق العناصر الثانوية |
| `secondaryContainer` | `#0F172A` | لون الخلفية لبعض حاويات العناصر الفرعية |
| `onSecondaryContainer`| `#94A3B8` | لون النصوص فوق حاويات العناصر الفرعية |

### الخلفيات والأسطح (Background & Surfaces)

| اسم اللون في الكود | رمز اللون (Hex) | الوصف والاستخدام |
| :--- | :--- | :--- |
| `background` | `#000000` | أسود حالك (Pitch Black) لخلفية الشاشات بالكامل |
| `onBackground` | `#FFFFFF` | الأبيض للنصوص الأساسية فوق الخلفية |
| `surface` | `#000000` | لون الأسطح العامة |
| `onSurface` | `#FFFFFF` | لون النصوص والرموز فوق الأسطح العامة |
| `onSurfaceVariant` | `#94A3B8` | لون النصوص الفرعية والإيضاحية |
| `surfaceContainerLowest`| `#000000`| المستوى الأدنى للأسطح |
| `surfaceContainerLow` | `#15181C` | لون بطاقات المنشورات والتعليقات والمدخلات (Cards & TextFields) |
| `surfaceContainer` | `#1E293B` | لون الأسطح المتوسطة |
| `surfaceContainerHigh`| `#334155` | لون أسطح التباين العالي |
| `surfaceContainerHighest`| `#475569`| لون أسطح التباين الأقصى |

### الحواف والحدود (Outlines & Borders)

| اسم اللون في الكود | رمز اللون (Hex) | الوصف والاستخدام |
| :--- | :--- | :--- |
| `outline` | `#334155` | للحدود والإطارات الرفيعة للبطاقات لتحديدها بوضوح خفيف |
| `outlineVariant` | `#1E293B` | لون إطارات بديل وأقل تبايناً |

### حالات الخطأ والتنبيهات (Error States)

| اسم اللون في الكود | رمز اللون (Hex) | الوصف والاستخدام |
| :--- | :--- | :--- |
| `error` | `#EF4444` | اللون الأحمر المتميز للإشارة للخطأ أو للتأكيد على عمليات مثل تسجيل الخروج |
| `errorContainer` | `#991B1B` | لون خلفية حاويات الأخطاء |
| `onError` | `#FFFFFF` | لون النصوص فوق حاوية الخطأ |
| `onErrorContainer` | `#FEE2E2` | لون نصوص تنبيهات الخطأ الفرعية |

---

## 3. الخطوط والطباعة (Typography)

يتم تفعيل الخطوط والأنماط مركزياً في ملف [app_text_styles.dart](file:///c:/Users/IT/StudioProjects/tuwaiq_app/lib/shared/theme/app_text_styles.dart) لتحديد حجم الخط ووزنه بناءً على موقعه في الشاشة:

### عائلات الخطوط (Font Families)
- **خط العناوين والملصقات:** `Plus Jakarta Sans` (يتميز بلمسة هندسية حديثة للعناوين الكبيرة).
- **خط المتن والرسائل:** `Inter` (خط مقروء للغاية ومثالي للشاشات الرقمية والأحجام الصغيرة).
- **خط الواجهات باللغة العربية والتنبيهات:** `IBM Plex Sans Arabic` (يوفر شكلاً احترافياً متوافقاً مع RTL).

### أنماط النصوص المحددة (Text Styles)

```dart
// العناوين الضخمة (العرض)
static const TextStyle displayLg = TextStyle(
  fontFamily: 'Plus Jakarta Sans',
  fontSize: 48,
  fontWeight: FontWeight.w800,
  letterSpacing: -0.02,
);

// العناوين الرئيسية (الهاتف والويب)
static const TextStyle headlineLg = TextStyle(
  fontFamily: 'Plus Jakarta Sans',
  fontSize: 32,
  fontWeight: FontWeight.w700,
  letterSpacing: -0.01,
);

// العناوين المتوسطة
static const TextStyle titleMd = TextStyle(
  fontFamily: 'Plus Jakarta Sans',
  fontSize: 20,
  fontWeight: FontWeight.w600,
);

// النصوص الطويلة والمتن الكبيرة
static const TextStyle bodyLg = TextStyle(
  fontFamily: 'Inter',
  fontSize: 18,
  fontWeight: FontWeight.w400,
);

// النصوص الطويلة والمتن المتوسطة
static const TextStyle bodyMd = TextStyle(
  fontFamily: 'Inter',
  fontSize: 16,
  fontWeight: FontWeight.w400,
);

// التسميات والملصقات الكبيرة
static const TextStyle labelLg = TextStyle(
  fontFamily: 'Plus Jakarta Sans',
  fontSize: 14,
  fontWeight: FontWeight.w600,
);

// التسميات والملصقات الصغيرة
static const TextStyle labelSm = TextStyle(
  fontFamily: 'Plus Jakarta Sans',
  fontSize: 12,
  fontWeight: FontWeight.w700,
);
```

---

## 4. إعدادات السمة العامة (Theme Configuration)

تتجمع الإعدادات في ملف [app_theme.dart](file:///c:/Users/IT/StudioProjects/tuwaiq_app/lib/shared/theme/app_theme.dart) لبناء `ThemeData` متكامل يدعم المظهر الداكن للمطورين:

- **تفعيل Material 3:** `useMaterial3: true`.
- **السطوع الافتراضي:** `Brightness.dark`.
- **تنسيق حقول الإدخال (Input Decoration):**
  - الحقول مملوءة بـ `AppColors.surfaceContainerLow` (`#15181C`).
  - زوايا دائرية بمقدار `12.0`.
  - حدود مخفية في الوضع العادي والمفعل.
  - إطار باللون الفضي `primary` بسمك `2.0` عند التركيز (Focus).
  - إطار باللون الأحمر `error` عند حدوث خطأ في التحقق من البيانات.

---

## 5. المكونات المشتركة (Shared Components)

توجد هذه المكونات في المجلد `lib/shared/widgets/` لتسهيل إعادة استخدامها مع الحفاظ على الهوية البصرية:

### 1. الزر الرئيسي [PrimaryButton](file:///c:/Users/IT/StudioProjects/tuwaiq_app/lib/shared/widgets/primary_button.dart)
- **الوضع العادي:** خلفية باللون الفضي الكرومي `primary` ونصوص سوداء `onPrimary`.
- **الوضع المفرغ (Outlined):** خلفية شفافة وإطار فضي بنصوص فضية.
- **التفاعل الحركي:** يحتوي على حركة تصغير طفيفة (Scale Interaction) بنسبة `0.96` عند الضغط لإعطاء إيحاء فيزيائي واقعي (Micro-animation).
- **التأثيرات:** يمتلك ظلاً خفيفاً ناعماً بنفس لون الزر لتأثير عمق بصري مميز.

### 2. أيقونة إضافة حدث الفيكتور [AddEventIcon](file:///c:/Users/IT/StudioProjects/tuwaiq_app/lib/shared/widgets/add_event_icon.dart)
- تم رسمها خصيصاً بواسطة `CustomPainter` بدلاً من الاعتماد على صورة ثابتة أو أيقونة جاهزة.
- ترسم تقويماً مفرغاً مع علامة `+` دائرية في الأسفل بشكل يعكس دقة التصميم في التطبيق.

### 3. الصورة الشخصية لشريط التطبيق [AppBarAvatar](file:///c:/Users/IT/StudioProjects/tuwaiq_app/lib/shared/widgets/app_bar_avatar.dart)
- دائرة مثالية محاطة بإطار رمادي نحيف.
- تستخدم `CachedNetworkImage` لضمان سرعة التحميل مع توفير بديل نصي يعرض الحرف الأول من اسم المستخدم عند عدم وجود صورة أو فشل التحميل.

---

## 6. قواعد وقوانين تجربة المستخدم والأداء (UX & Performance Rules)

نظام التصميم في تطبيق `$CRATCH` لا يقتصر على الأشكال البصرية فقط، بل يمتد ليشمل أداء حركة العناصر لضمان تجربة مستخدم متميزة:

1. **إدراج الشعار المركزي (Centered Logo Branding):**
   - تم استبدال العناوين النصية الجافة لشريط التطبيق (AppBar) بشعار `$CRATCH` المصمم بصيغة عالية الجودة `logo.png` في الشاشات الرئيسية (الرئيسية، الاستكشاف، التنبيهات، وتفاصيل المنشورات).
2. **الحد الأقصى لذاكرة الصور (Image Memory Capping):**
   - لتجنب استهلاك الذاكرة العشوائية (RAM) والتسبب في إغلاق التطبيق فجأة (OOM Crashes) بسبب الصور الكبيرة المرفوعة من المستخدمين، يتم إجبار المصادر على تحديد حجم ذاكرة التخزين المؤقت للصور:
     - صور المنشورات في القائمة الرئيسية: حد أقصى `400x400` بكسل.
     - الصورة الشخصية في شاشة الحساب: حد أقصى `250x250` بكسل.
     - غلاف الحساب الشخصي (Cover Banner): حد أقصى `800x400` بكسل.
3. **التشغيل الذكي للفيديو (Visibility-Aware Playback):**
   - يتم التحكم في تشغيل الفيديو في القائمة الرئيسية ذكياً باستخدام `VisibilityDetector`:
     - يتم تشغيل الفيديو تلقائياً فقط إذا كان ظاهراً بنسبة أكبر من `70%`.
     - يتم إيقاف الفيديو مؤقتاً فوراً إذا قل عن ذلك.
     - يتم تدمير المشغل (Dispose) بالكامل إذا اختفى من الشاشة بنسبة `0%` لتحرير قنوات فك التشفير الصلبة في المعالج.
4. **منع التوجيه المتعدد (Double-Tap Protection):**
   - لحماية شاشات التفاصيل من التكرار والفتح المتعدد المزعج عند نقر المستخدم بسرعة على بطاقة المنشور أو التعليق، تم بناء نظام حماية يمنع أي عملية نقر إضافية خلال نافذة زمنية قدرها `800` مللي ثانية من النقر الأول.
5. **تنسيق التنبيهات المنبثقة (Floating SnackBars):**
   - تم ربط الـ `bottomNavigationBar` مع الـ `BottomAppBar` لضمان إعطاء إحداثيات ارتفاع صحيحة للـ `Scaffold` حتى ترتفع رسائل الـ `SnackBar` العائمة تلقائياً ولا تتراكب أو تغطي أزرار التنقل السفلية.
