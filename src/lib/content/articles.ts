/**
 * Warif Learn library — seed fixtures ONLY.
 *
 * Every item is labelled experimental ("محتوى تجريبي — بانتظار المراجعة الطبية")
 * and MUST NOT be presented as approved medical content. Real content follows
 * the workflow draft → medical_review → approved → published → archived once the
 * CMS + medical reviewers exist (later batch). Content here is original, general,
 * non-diagnostic and contains no personal/health data.
 */
export type ArticleCategory =
  | "cycle"
  | "pain"
  | "hormones"
  | "fertility"
  | "mental"
  | "nutrition"
  | "doctor";

export type ArticleStatus = "draft" | "published" | "archived";

export interface Article {
  slug: string;
  category: ArticleCategory;
  status: ArticleStatus;
  /** All seed items are unreviewed drafts shown as experimental. */
  experimental: boolean;
  readingMinutes: number;
  reviewer: string | null;
  reviewedAt: string | null;
  sources: string[];
  title: { ar: string; en: string };
  summary: { ar: string; en: string };
  body: { ar: string[]; en: string[] };
}

export const ARTICLE_CATEGORIES: ArticleCategory[] = [
  "cycle",
  "pain",
  "hormones",
  "fertility",
  "mental",
  "nutrition",
  "doctor",
];

export const articles: Article[] = [
  {
    slug: "understanding-your-cycle",
    category: "cycle",
    status: "draft",
    experimental: true,
    readingMinutes: 4,
    reviewer: null,
    reviewedAt: null,
    sources: ["Office on Women's Health — Menstrual cycle"],
    title: { ar: "كيف تعمل دورتك؟", en: "How your cycle works" },
    summary: {
      ar: "نظرة هادئة على مراحل الدورة الأربع وما قد تلاحظينه في كل مرحلة.",
      en: "A calm look at the four phases and what you might notice in each.",
    },
    body: {
      ar: [
        "تمرّ الدورة عادةً بأربع مراحل تقديرية: الطمث، ثم مرحلة ما بعده، ثم منتصف الدورة، ثم الأيام السابقة للدورة القادمة.",
        "تختلف مدة كل مرحلة من جسم لآخر، وما تعرضه وريف تقديرات مبنية على تسجيلاتك وليست قياسات مؤكدة.",
      ],
      en: [
        "A cycle usually moves through four estimated phases: menstruation, the days after it, mid-cycle, and the days before the next period.",
        "Each phase varies from body to body; what Warif shows are estimates from your logs, not confirmed measurements.",
      ],
    },
  },
  {
    slug: "tracking-in-30-seconds",
    category: "cycle",
    status: "draft",
    experimental: true,
    readingMinutes: 3,
    reviewer: null,
    reviewedAt: null,
    sources: [],
    title: { ar: "التسجيل في ٣٠ ثانية", en: "Logging in 30 seconds" },
    summary: {
      ar: "لماذا يساعد التسجيل اليومي القصير على فهم نمطك بمرور الوقت.",
      en: "Why a short daily check-in helps you understand your pattern over time.",
    },
    body: {
      ar: [
        "لا يلزم أن يكون يومك مثالياً لتسجّليه. حتى تسجيل بسيط يساعد وريف على تحسين التقديرات.",
        "سجّلي ما تلاحظينه فقط، وتخطّي ما لا يعنيك.",
      ],
      en: [
        "Your day doesn't need to be perfect to log it. Even a simple entry helps Warif improve its estimates.",
        "Log only what you notice, and skip what isn't relevant to you.",
      ],
    },
  },
  {
    slug: "period-pain-basics",
    category: "pain",
    status: "draft",
    experimental: true,
    readingMinutes: 5,
    reviewer: null,
    reviewedAt: null,
    sources: [],
    title: { ar: "ألم الدورة: أساسيات", en: "Period pain: the basics" },
    summary: {
      ar: "أفكار عامة للعناية الذاتية، ومتى يستحسن استشارة مختصة.",
      en: "General self-care ideas, and when it's better to consult a specialist.",
    },
    body: {
      ar: [
        "قد تساعد الحرارة والراحة والحركة الخفيفة بعض النساء على الشعور بتحسّن.",
        "إذا كان الألم شديداً أو غير معتاد أو يعطّل يومك، الأفضل التواصل مع مختصة. هذه ليست نصيحة طبية.",
      ],
      en: [
        "Warmth, rest and gentle movement help some people feel better.",
        "If pain is severe, unusual, or disrupts your day, it's better to contact a specialist. This is not medical advice.",
      ],
    },
  },
  {
    slug: "tracking-symptoms",
    category: "pain",
    status: "draft",
    experimental: true,
    readingMinutes: 3,
    reviewer: null,
    reviewedAt: null,
    sources: [],
    title: { ar: "تتبّع الأعراض", en: "Tracking symptoms" },
    summary: {
      ar: "كيف يساعد وصف مكان الألم وشدته على رؤية الأنماط.",
      en: "How noting pain location and intensity helps you see patterns.",
    },
    body: {
      ar: [
        "تسجيل شدة الألم من ٠ إلى ١٠ ومكانه يعطيكِ صورة أوضح عبر الدورات.",
        "الأنماط التي تظهر في تسجيلاتك ملاحظات، وليست تشخيصاً.",
      ],
      en: [
        "Logging pain intensity from 0–10 and its location gives a clearer picture across cycles.",
        "Patterns in your logs are observations, not a diagnosis.",
      ],
    },
  },
  {
    slug: "hormones-overview",
    category: "hormones",
    status: "draft",
    experimental: true,
    readingMinutes: 4,
    reviewer: null,
    reviewedAt: null,
    sources: [],
    title: { ar: "الهرمونات باختصار", en: "Hormones in brief" },
    summary: {
      ar: "لمحة عامة دون منحنيات تُعرض كأنها قياسات حقيقية.",
      en: "A general overview — without curves presented as real measurements.",
    },
    body: {
      ar: [
        "تتغير الهرمونات خلال الدورة، لكن وريف لا يقيسها ولا يعرض منحنيات كأنها قياسات فعلية.",
        "نكتفي بوصف عام يساعدك على الفهم دون ادعاء الدقة.",
      ],
      en: [
        "Hormones shift across the cycle, but Warif does not measure them or show curves as if they were real readings.",
        "We keep to a general description that aids understanding without claiming precision.",
      ],
    },
  },
  {
    slug: "fertile-window-estimate",
    category: "fertility",
    status: "draft",
    experimental: true,
    readingMinutes: 4,
    reviewer: null,
    reviewedAt: null,
    sources: [],
    title: {
      ar: "نافذة التبويض التقديرية",
      en: "The estimated fertile window",
    },
    summary: {
      ar: "لماذا تُعرض النافذة كتقدير ولا تُستخدم لمنع الحمل.",
      en: "Why the window is shown as an estimate and not used for contraception.",
    },
    body: {
      ar: [
        "نافذة التبويض في وريف تقدير مبني على متوسط دوراتك، وقد تتغير.",
        "لا تُستخدم هذه النافذة وسيلةً لمنع الحمل أو تأكيد الإباضة.",
      ],
      en: [
        "Warif's fertile window is an estimate from your average cycles and can change.",
        "This window must not be used as contraception or to confirm ovulation.",
      ],
    },
  },
  {
    slug: "mind-and-cycle",
    category: "mental",
    status: "draft",
    experimental: true,
    readingMinutes: 4,
    reviewer: null,
    reviewedAt: null,
    sources: [],
    title: { ar: "الصحة النفسية والدورة", en: "Mind and cycle" },
    summary: {
      ar: "ملاحظات لطيفة عن المزاج والطاقة دون أحكام.",
      en: "Gentle notes about mood and energy, without judgement.",
    },
    body: {
      ar: [
        "قد يتغير المزاج أو الطاقة لدى بعض النساء في أوقات مختلفة من الدورة.",
        "وريف لا يصف المستخدمة بالمزاجية، ولا يربط شخصيتك بمرحلة الدورة.",
      ],
      en: [
        "Mood or energy may shift for some people at different times in the cycle.",
        "Warif never labels you as \u201cmoody\u201d or ties your personality to a phase.",
      ],
    },
  },
  {
    slug: "rest-and-care",
    category: "mental",
    status: "draft",
    experimental: true,
    readingMinutes: 3,
    reviewer: null,
    reviewedAt: null,
    sources: [],
    title: { ar: "خذي دقيقة لكِ", en: "Take a minute for you" },
    summary: {
      ar: "أفكار عناية عامة غير علاجية لأيامك المزدحمة.",
      en: "General, non-therapeutic care ideas for busy days.",
    },
    body: {
      ar: [
        "روتين هادئ قبل النوم، وشرب ماء كافٍ، ومساحة صغيرة للراحة قد تُحدث فرقاً.",
        "هذه اقتراحات عامة وليست علاجاً.",
      ],
      en: [
        "A calm pre-sleep routine, enough water, and a little space to rest can make a difference.",
        "These are general suggestions, not treatment.",
      ],
    },
  },
  {
    slug: "eating-and-movement",
    category: "nutrition",
    status: "draft",
    experimental: true,
    readingMinutes: 4,
    reviewer: null,
    reviewedAt: null,
    sources: [],
    title: { ar: "التغذية والحركة", en: "Eating and movement" },
    summary: {
      ar: "عادات متوازنة تناسب طاقتك المتغيرة.",
      en: "Balanced habits that fit your changing energy.",
    },
    body: {
      ar: [
        "وجبات متوازنة وحركة تحبينها قد تدعمان راحتك خلال الدورة.",
        "لا توجد \u201cحمية دورة\u201d واحدة تناسب الجميع.",
      ],
      en: [
        "Balanced meals and movement you enjoy can support your comfort during the cycle.",
        "There is no single \u201ccycle diet\u201d that fits everyone.",
      ],
    },
  },
  {
    slug: "hydration",
    category: "nutrition",
    status: "draft",
    experimental: true,
    readingMinutes: 2,
    reviewer: null,
    reviewedAt: null,
    sources: [],
    title: { ar: "الترطيب", en: "Hydration" },
    summary: {
      ar: "لماذا يُذكر الماء كثيراً في نصائح العناية.",
      en: "Why water shows up so often in care tips.",
    },
    body: {
      ar: [
        "شرب ماء كافٍ عادة بسيطة قد تساعد على الشعور بتحسّن عام.",
        "أنصتي لجسمك واضبطي الكمية حسب نشاطك.",
      ],
      en: [
        "Drinking enough water is a simple habit that may help you feel better overall.",
        "Listen to your body and adjust to your activity.",
      ],
    },
  },
  {
    slug: "when-to-see-a-doctor",
    category: "doctor",
    status: "draft",
    experimental: true,
    readingMinutes: 5,
    reviewer: null,
    reviewedAt: null,
    sources: [],
    title: { ar: "متى أراجع الطبيبة؟", en: "When to see a doctor" },
    summary: {
      ar: "علامات عامة يُستحسن عندها التواصل مع مختصة.",
      en: "General signs where contacting a specialist is advisable.",
    },
    body: {
      ar: [
        "ألم شديد غير معتاد، نزف غزير جداً، أو غياب الدورة لفترة طويلة قد تكون أسباباً لاستشارة مختصة.",
        "وريف أداة متابعة وتثقيف، وليست بديلاً عن رأي الطبيبة.",
      ],
      en: [
        "Severe unusual pain, very heavy bleeding, or a long absence of periods can be reasons to consult a specialist.",
        "Warif is a tracking and education tool, not a substitute for a doctor's opinion.",
      ],
    },
  },
  {
    slug: "preparing-for-a-visit",
    category: "doctor",
    status: "draft",
    experimental: true,
    readingMinutes: 3,
    reviewer: null,
    reviewedAt: null,
    sources: [],
    title: {
      ar: "الاستعداد لزيارة الطبيبة",
      en: "Preparing for a visit",
    },
    summary: {
      ar: "كيف يساعدك ملخص تسجيلاتك في زيارة أوضح.",
      en: "How a summary of your logs supports a clearer visit.",
    },
    body: {
      ar: [
        "إحضار ملخص عن دوراتك وأعراضك قد يجعل النقاش مع المختصة أوضح.",
        "تختارين ما تشاركينه، وتبقى بياناتك في يدك.",
      ],
      en: [
        "Bringing a summary of your cycles and symptoms can make the discussion clearer.",
        "You choose what to share, and your data stays in your hands.",
      ],
    },
  },
];

export function getArticle(slug: string): Article | undefined {
  return articles.find((a) => a.slug === slug);
}
