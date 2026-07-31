import createMiddleware from "next-intl/middleware";
import { createServerClient } from "@supabase/ssr";
import { NextRequest, NextResponse } from "next/server";
import { routing } from "./i18n/routing";

const intlMiddleware = createMiddleware(routing);

const protectedSegments = new Set([
  "calendar",
  "check-in",
  "community",
  "insights",
  "learn",
  "reports",
  "settings",
  "today",
]);

function protectedLocalePath(pathname: string) {
  const [, locale, segment] = pathname.split("/");
  if (!routing.locales.includes(locale as (typeof routing.locales)[number])) {
    return null;
  }
  return protectedSegments.has(segment) ? locale : null;
}

function loginRedirect(request: NextRequest, locale: string) {
  const url = request.nextUrl.clone();
  url.pathname = `/${locale}/auth/login`;
  url.searchParams.set("next", request.nextUrl.pathname);
  return NextResponse.redirect(url);
}

export default async function proxy(request: NextRequest) {
  const response = intlMiddleware(request);
  const protectedLocale = protectedLocalePath(request.nextUrl.pathname);
  if (!protectedLocale) return response;

  const url = process.env.NEXT_PUBLIC_SUPABASE_URL;
  const anonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY;
  const demoAuthEnabled = process.env.NEXT_PUBLIC_DEMO_AUTH_ENABLED !== "false";

  if (demoAuthEnabled || !url || !anonKey) {
    return response;
  }

  const supabase = createServerClient(url, anonKey, {
    cookies: {
      getAll() {
        return request.cookies.getAll();
      },
      setAll(cookiesToSet) {
        cookiesToSet.forEach(({ name, value }) => request.cookies.set(name, value));
        cookiesToSet.forEach(({ name, value, options }) => {
          response.cookies.set(name, value, options);
        });
      },
    },
  });

  const {
    data: { user },
  } = await supabase.auth.getUser();

  return user ? response : loginRedirect(request, protectedLocale);
}

export const config = {
  // Match all pathnames except for API routes, Next internals and static files.
  matcher: ["/((?!api|_next|_vercel|.*\\..*).*)"],
};
