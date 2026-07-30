import type { MetadataRoute } from "next";

/**
 * PWA manifest. Warif is a mobile-first, Arabic-first (RTL) installable PWA.
 * The start URL points at the default Arabic member home.
 */
export default function manifest(): MetadataRoute.Manifest {
  return {
    name: "وريف | Warif",
    short_name: "وريف",
    description:
      "تطبيق نسائي عربي خاص وآمن لمتابعة الدورة الشهرية والصحة اليومية.",
    lang: "ar",
    dir: "rtl",
    start_url: "/ar/today",
    scope: "/",
    display: "standalone",
    background_color: "#FFF9F7",
    theme_color: "#8F5C78",
    icons: [
      {
        src: "/icon.svg",
        sizes: "any",
        type: "image/svg+xml",
        purpose: "any",
      },
      {
        src: "/icon-maskable.svg",
        sizes: "any",
        type: "image/svg+xml",
        purpose: "maskable",
      },
    ],
  };
}
