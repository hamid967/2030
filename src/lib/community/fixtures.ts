/**
 * Warif community — seed fixtures ONLY (prototype).
 *
 * Pseudonymous by design: no real name, age, city, or cycle data is ever shown.
 * Posts here are fictional samples for the prototype UI. Peer experiences are
 * never medical advice. Real community features (posting, moderation queue,
 * verified experts, reports) arrive behind Auth + moderation in a later batch.
 */
export interface CommunitySpace {
  id: string;
  name: { ar: string; en: string };
  description: { ar: string; en: string };
}

export interface CommunityPost {
  id: string;
  spaceId: string;
  pseudonym: string;
  /** Seed for a generated botanical/geometric avatar (no real photo). */
  avatarSeed: string;
  body: { ar: string; en: string };
  reactions: number;
  comments: number;
}

export const communitySpaces: CommunitySpace[] = [
  {
    id: "cycle-experiences",
    name: { ar: "تجارب الدورة", en: "Cycle experiences" },
    description: {
      ar: "مساحة لطيفة لمشاركة التجارب اليومية.",
      en: "A gentle space to share everyday experiences.",
    },
  },
  {
    id: "pain-and-disorders",
    name: { ar: "الألم والاضطرابات", en: "Pain & disorders" },
    description: {
      ar: "دعم متبادل حول الألم والأعراض الصعبة.",
      en: "Mutual support around pain and difficult symptoms.",
    },
  },
  {
    id: "pcos",
    name: { ar: "تكيّس المبايض", en: "PCOS" },
    description: {
      ar: "تجارب وأسئلة عامة، دون تشخيص.",
      en: "General experiences and questions, without diagnosis.",
    },
  },
  {
    id: "mental-care",
    name: { ar: "العناية النفسية", en: "Mental care" },
    description: {
      ar: "مساحة هادئة للعناية بالنفس.",
      en: "A calm space for self-care.",
    },
  },
  {
    id: "nutrition-movement",
    name: { ar: "التغذية والحركة", en: "Nutrition & movement" },
    description: {
      ar: "عادات متوازنة نتبادلها بلطف.",
      en: "Balanced habits shared kindly.",
    },
  },
  {
    id: "doctor-visit-prep",
    name: { ar: "الاستعداد لزيارة الطبيبة", en: "Preparing for a visit" },
    description: {
      ar: "أسئلة ونصائح لزيارة أوضح.",
      en: "Questions and tips for a clearer visit.",
    },
  },
];

export const communityPosts: CommunityPost[] = [
  {
    id: "p1",
    spaceId: "cycle-experiences",
    pseudonym: "وردة ٢١٤",
    avatarSeed: "rose-214",
    body: {
      ar: "التسجيل اليومي ساعدني أفهم نمطي بهدوء، حتى في الأيام المزدحمة.",
      en: "Daily logging helped me understand my pattern calmly, even on busy days.",
    },
    reactions: 12,
    comments: 3,
  },
  {
    id: "p2",
    spaceId: "cycle-experiences",
    pseudonym: "ياسمين ٠٩",
    avatarSeed: "jasmine-09",
    body: {
      ar: "عجبتني فكرة إخفاء المعلومات الحساسة بسرعة وقت أكون بين الناس.",
      en: "I love being able to quickly hide sensitive info when I'm around people.",
    },
    reactions: 8,
    comments: 1,
  },
  {
    id: "p3",
    spaceId: "pain-and-disorders",
    pseudonym: "نرجس ٥٢",
    avatarSeed: "narcissus-52",
    body: {
      ar: "الحرارة والراحة تساعدني كثيراً في أول يومين. وش يساعدكم؟",
      en: "Warmth and rest help me a lot in the first two days. What helps you?",
    },
    reactions: 20,
    comments: 6,
  },
];

export function getSpace(id: string): CommunitySpace | undefined {
  return communitySpaces.find((s) => s.id === id);
}

export function postsForSpace(spaceId: string): CommunityPost[] {
  return communityPosts.filter((p) => p.spaceId === spaceId);
}
