# Warif Visual Kit

حزمة بصرية أصلية لتطبيق «وريف» بهوية أنثوية عربية ناضجة ومتناسقة.

## الملفات

| الملف | الاستخدام |
|---|---|
| `app-icon-1024.png` | أيقونة App Store ومصدر AppIcon |
| `app-icon-512.png` | أيقونة PWA عالية الدقة |
| `app-icon-192.png` | أيقونة PWA المختصرة |
| `hero-community-16x9.png` | Hero، صفحة المجتمع، أو صفحة التعريف |
| `onboarding-privacy-4x5.png` | شاشة الخصوصية والتفعيل |
| `check-in-square.png` | الصفحة الرئيسية، تسجيل اليوم، والحالات الفارغة |
| `saudi-warif-community-16x9.png` | شخصيات سعودية معاصرة لبطاقة اليوم أو المجتمع |

## لوحة الألوان

- Primary Berry: `#8F5C78`
- Dusty Rose: `#C98C9E`
- Warm Ivory: `#FFF9F7`
- Sage: `#8FAF9B`
- Lavender: `#A99AC6`
- Text Plum: `#30272D`

## إرشادات الدمج

- استخدم الصور عبر `next/image` مع `sizes` مناسب.
- حوّل الرسومات الكبيرة إلى WebP أو AVIF أثناء البناء، مع الاحتفاظ بنسخة PNG الأصلية.
- لا تضع بيانات صحية أو نصوص شخصية داخل الصور.
- استخدم `hero-community-16x9.png` مع مساحة النص الفارغة في اليسار.
- استخدم `onboarding-privacy-4x5.png` داخل بطاقة عمودية أو شاشة Onboarding.
- استخدم `check-in-square.png` كبطاقة ترحيب أو حالة فارغة للتسجيل اليومي.
- استخدم `saudi-warif-community-16x9.png` في Hero أو بطاقة «مجتمع وريف»،
  مع إبقاء النص في المساحة الفارغة وعدم قص الشخصيات على الشاشات الصغيرة.
- لا تطبق تدويراً أو قصاً دائرياً على `app-icon-1024.png`؛ نظام Apple يطبق القناع النهائي.

## أيقونات الواجهة

استخدم أيقونات SVG موحدة من Lucide أو حزمة المشروع الحالية للأوامر الوظيفية:

- `CalendarDays` للتقويم.
- `NotebookPen` للتسجيل اليومي.
- `ChartNoAxesCombined` للتحليلات.
- `BookOpenText` للمقالات.
- `UsersRound` للمجتمع.
- `ShieldCheck` للخصوصية.
- `Bell` للإشعارات.
- `Settings` للإعدادات.

تكون سماكة الخط `1.75`، والحجم الافتراضي `22px`، وتستخدم الألوان من Design Tokens بدلاً من قيم ثابتة داخل المكونات.

## نص الدمج المقترح لـ Cursor

```text
ادمج حزمة Warif Visual Kit داخل مشروع وريف:

1. ضع ملفات الصور تحت public/brand وpublic/illustrations.
2. حدّث manifest وmetadata وApple touch icon باستخدام app-icon-192 و512.
3. جهّز AppIcon 1024 لمشروع iOS دون alpha أو corner masking إضافي.
4. استخدم hero-community في Landing/Community Hero.
5. استخدم onboarding-privacy في شاشة الخصوصية والتفعيل.
6. استخدم check-in-square في الصفحة الرئيسية والتسجيل اليومي.
7. استخدم next/image مع أحجام responsive وlazy loading للصور خارج أول viewport.
8. أضف alt عربي وإنجليزي عبر ملفات i18n.
9. طبّق Lucide icons المذكورة في README على شريط التنقل والبطاقات.
10. شغّل lint وtypecheck وtests وbuild، ثم اعرض الملفات المعدلة والنتائج.
```

## تنبيه الخصوصية عند الدمج

- لا ترفع بيانات `localStorage` الحالية إلى Supabase تلقائياً.
- اعرض موافقة مستقلة تشرح البيانات التي ستُنقل، مع خيار إبقائها على الجهاز.
- استخدم تاريخ `Asia/Riyadh` المحلي بدلاً من قص تاريخ UTC.
- لا تستخدم مفتاح Supabase الإداري داخل الواجهة أو عمليات العضوة العادية.
