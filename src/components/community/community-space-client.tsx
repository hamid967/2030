"use client";

import { useEffect, useMemo, useState } from "react";
import { useLocale } from "next-intl";
import { Heart, MessageCircle, Send, Sparkles } from "lucide-react";
import type { CommunityPost } from "@/lib/community/fixtures";
import { Button } from "@/components/ui/button";
import { Card } from "@/components/ui/card";

type LocalPost = {
  id: string;
  spaceId: string;
  pseudonym: string;
  body: string;
  reactions: number;
  comments: string[];
  createdAt: string;
};

const STORAGE_KEY = "warif.community.posts.v1";

function readLocalPosts(): LocalPost[] {
  try {
    const raw = window.localStorage.getItem(STORAGE_KEY);
    return raw ? (JSON.parse(raw) as LocalPost[]) : [];
  } catch {
    return [];
  }
}

function writeLocalPosts(posts: LocalPost[]) {
  window.localStorage.setItem(STORAGE_KEY, JSON.stringify(posts));
}

function initialLetter(name: string) {
  return Array.from(name.trim())[0] ?? "و";
}

export function CommunitySpaceClient({
  spaceId,
  seedPosts,
}: {
  spaceId: string;
  seedPosts: CommunityPost[];
}) {
  const locale = useLocale();
  const loc = locale === "en" ? "en" : "ar";
  const isArabic = loc === "ar";
  const [localPosts, setLocalPosts] = useState<LocalPost[]>([]);
  const [body, setBody] = useState("");
  const [commentDrafts, setCommentDrafts] = useState<Record<string, string>>(
    {},
  );
  const [notice, setNotice] = useState("");

  useEffect(() => {
    setLocalPosts(readLocalPosts().filter((post) => post.spaceId === spaceId));
  }, [spaceId]);

  useEffect(() => {
    if (!notice) return;
    const timer = window.setTimeout(() => setNotice(""), 2200);
    return () => window.clearTimeout(timer);
  }, [notice]);

  const posts = useMemo(
    () => [
      ...localPosts.map((post) => ({
        id: post.id,
        pseudonym: post.pseudonym,
        body: post.body,
        reactions: post.reactions,
        comments: post.comments,
        local: true,
      })),
      ...seedPosts.map((post) => ({
        id: post.id,
        pseudonym: post.pseudonym,
        body: post.body[loc],
        reactions: post.reactions,
        comments: Array.from({ length: post.comments }, (_, index) =>
          isArabic ? `تعليق داعم ${index + 1}` : `Supportive note ${index + 1}`,
        ),
        local: false,
      })),
    ],
    [isArabic, loc, localPosts, seedPosts],
  );

  const syncLocalPosts = (updater: (posts: LocalPost[]) => LocalPost[]) => {
    const all = readLocalPosts();
    const nextAll = updater(all);
    writeLocalPosts(nextAll);
    setLocalPosts(nextAll.filter((post) => post.spaceId === spaceId));
  };

  const submitPost = () => {
    const text = body.trim();
    if (text.length < 3) return;
    const next: LocalPost = {
      id:
        typeof crypto !== "undefined" && "randomUUID" in crypto
          ? crypto.randomUUID()
          : `${Date.now()}`,
      spaceId,
      pseudonym: isArabic ? "عضوة وريف" : "Warif member",
      body: text,
      reactions: 0,
      comments: [],
      createdAt: new Date().toISOString(),
    };
    syncLocalPosts((posts) => [next, ...posts]);
    setBody("");
    setNotice(isArabic ? "تم نشر مشاركتك" : "Your post is live");
  };

  const likePost = (postId: string) => {
    syncLocalPosts((posts) =>
      posts.map((post) =>
        post.id === postId ? { ...post, reactions: post.reactions + 1 } : post,
      ),
    );
  };

  const addComment = (postId: string) => {
    const text = (commentDrafts[postId] ?? "").trim();
    if (text.length < 2) return;
    syncLocalPosts((posts) =>
      posts.map((post) =>
        post.id === postId
          ? { ...post, comments: [...post.comments, text] }
          : post,
      ),
    );
    setCommentDrafts((drafts) => ({ ...drafts, [postId]: "" }));
    setNotice(isArabic ? "تمت إضافة التعليق" : "Comment added");
  };

  return (
    <div className="flex flex-col gap-4">
      {notice && (
        <div className="fixed top-4 z-30 rounded-full bg-primary px-4 py-2 text-sm font-medium text-white shadow-lg shadow-primary/20 ltr:right-4 rtl:left-4">
          {notice}
        </div>
      )}

      <Card className="relative overflow-hidden">
        <div className="absolute inset-x-0 top-0 h-1 bg-primary" />
        <div className="flex items-center gap-2">
          <Sparkles className="size-5 text-primary" aria-hidden />
          <h2 className="font-semibold text-text">
            {isArabic ? "شاركي المجتمع" : "Share with the community"}
          </h2>
        </div>
        <textarea
          value={body}
          onChange={(event) => setBody(event.target.value)}
          rows={4}
          maxLength={280}
          placeholder={
            isArabic
              ? "اكتبي تجربة، سؤالاً، أو كلمة دعم..."
              : "Write an experience, question, or kind note..."
          }
          className="mt-4 min-h-28 w-full resize-none rounded-3xl border border-border bg-ivory/60 px-4 py-3 text-text outline-none transition focus:border-primary focus:ring-2 focus:ring-primary/20"
        />
        <div className="mt-3 flex items-center justify-between gap-3">
          <span className="text-xs text-muted">{body.length}/280</span>
          <Button type="button" onClick={submitPost}>
            <Send className="size-4" aria-hidden />
            {isArabic ? "نشر" : "Post"}
          </Button>
        </div>
      </Card>

      <ul className="flex flex-col gap-4">
        {posts.map((post) => (
          <li key={post.id}>
            <Card className="community-card-animated flex flex-col gap-3">
              <div className="flex items-center gap-3">
                <span
                  aria-hidden
                  className="warif-avatar-3d flex size-10 items-center justify-center rounded-full bg-lavender/30 text-sm font-bold text-primary-strong"
                >
                  {initialLetter(post.pseudonym)}
                </span>
                <div>
                  <p className="font-medium text-text">{post.pseudonym}</p>
                  {post.local && (
                    <p className="text-xs text-muted">
                      {isArabic ? "منشورك" : "Your post"}
                    </p>
                  )}
                </div>
              </div>
              <p className="leading-7 text-text">{post.body}</p>
              <div className="flex items-center gap-3 text-sm text-muted">
                <button
                  type="button"
                  onClick={() => likePost(post.id)}
                  className="inline-flex items-center gap-1 rounded-full px-2 py-1 transition hover:bg-ivory hover:text-primary"
                >
                  <Heart className="size-4" aria-hidden /> {post.reactions}
                </button>
                <span className="inline-flex items-center gap-1">
                  <MessageCircle className="size-4" aria-hidden />{" "}
                  {post.comments.length}
                </span>
              </div>
              {post.comments.length > 0 && (
                <div className="space-y-2 rounded-3xl bg-ivory/70 p-3 text-sm text-muted">
                  {post.comments.slice(-2).map((comment, index) => (
                    <p key={`${post.id}-${index}`}>{comment}</p>
                  ))}
                </div>
              )}
              {post.local && (
                <div className="flex gap-2">
                  <input
                    value={commentDrafts[post.id] ?? ""}
                    onChange={(event) =>
                      setCommentDrafts((drafts) => ({
                        ...drafts,
                        [post.id]: event.target.value,
                      }))
                    }
                    placeholder={isArabic ? "اكتبي تعليقاً" : "Write a comment"}
                    className="min-h-10 flex-1 rounded-full border border-border bg-surface px-4 text-sm outline-none focus:border-primary"
                  />
                  <button
                    type="button"
                    onClick={() => addComment(post.id)}
                    className="flex size-10 items-center justify-center rounded-full bg-primary text-white"
                    aria-label={isArabic ? "إرسال التعليق" : "Send comment"}
                  >
                    <Send className="size-4" aria-hidden />
                  </button>
                </div>
              )}
            </Card>
          </li>
        ))}
      </ul>
    </div>
  );
}
