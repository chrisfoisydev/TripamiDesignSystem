// Keyword search over the brand book, docs and component guidance.
import type { TripamiData } from './data.js';

export interface SearchHit { source: string; title: string; breadcrumb: string; score: number; snippet: string; text: string }

const STOP = new Set('a an and are as at be by can do does for from how i if in is it of on or should the to use what when where which with you your'.split(' '));

export function terms(q: string): string[] {
  return q.toLowerCase().split(/[^a-z0-9#-]+/).filter((t) => t.length > 1 && !STOP.has(t));
}

function snippet(text: string, words: string[], width = 320): string {
  const lower = text.toLowerCase();
  const at = Math.min(...words.map((w) => lower.indexOf(w)).filter((i) => i >= 0), text.length);
  const start = Math.max(0, (at === text.length ? 0 : at) - 80);
  const s = text.slice(start, start + width).replace(/\s+/g, ' ').trim();
  return (start > 0 ? '…' : '') + s + (start + width < text.length ? '…' : '');
}

export function searchGuidelines(data: TripamiData, query: string, limit: number): SearchHit[] {
  const words = terms(query);
  if (!words.length) return [];
  const docs = [
    ...data.guidelines,
    ...data.components.map((c) => ({ source: `component:${c.name}`, title: c.name, breadcrumb: `Components › ${c.group} › ${c.name}`, text: c.guidance })),
  ];
  return docs
    .map((d) => {
      const title = d.breadcrumb.toLowerCase();
      const body = d.text.toLowerCase();
      let score = 0, matched = 0;
      for (const w of words) {
        const inTitle = title.split(w).length - 1;
        const inBody = body.split(w).length - 1;
        if (inTitle || inBody) matched++;
        score += inTitle * 4 + Math.log1p(inBody) * 2;
      }
      // Favour sections that cover more of the query, and short focused sections.
      score *= matched / words.length;
      score /= 1 + Math.log10(1 + body.length / 1500);
      return { ...d, score, matched };
    })
    .filter((d) => d.matched > 0)
    .sort((a, b) => b.score - a.score)
    .slice(0, limit)
    .map(({ matched: _m, ...d }) => ({ ...d, score: Math.round(d.score * 100) / 100, snippet: snippet(d.text, words) }));
}
