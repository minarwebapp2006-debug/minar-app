# Minar Catalogue & Price Manager (MCPM) — ডিপ্লয় গাইড

অ্যাপটি তিন জায়গায় কাজ করে:

| কোথায় | কী কাজ করে |
|---|---|
| **Supabase** | ডাটাবেস (ব্র্যান্ড, প্রোডাক্ট), ইউজার অ্যাকাউন্ট, লগইন, অ্যাডমিন পাসওয়ার্ড, ওনারের অনুমোদন/লক/কিক |
| **GitHub** | কোড রাখার জায়গা (ভার্সন সংরক্ষণ) |
| **Vercel** | GitHub থেকে কোড নিয়ে ইন্টারনেটে অ্যাপ চালু করে (লিংক দেয়) |

## ধাপ ১ — Supabase (supabase.com)
1. Sign in → **New project** (নাম: minar, একটা Database Password দিন ও সেভ রাখুন, Region: Singapore) → তৈরি হওয়া পর্যন্ত অপেক্ষা।
2. বাঁদিকের মেনু **SQL Editor → New query** → `supabase/schema.sql` ফাইলের পুরো লেখা পেস্ট করে **Run**। "Success" দেখাবে।
3. **Authentication → Sign In / Providers → Email**: **Confirm email** বন্ধ (OFF) করে Save। (অনুমোদন ওনারই দেবেন, তাই ইমেইল কনফার্ম লাগবে না।)
4. **Project Settings → API**: **Project URL** আর **anon public key** কপি করুন।

## ধাপ ২ — config.js পূরণ (আপনার কম্পিউটারে)
`config.js` খুলে `SUPABASE_URL` ও `SUPABASE_ANON_KEY`-এর জায়গায় ধাপ ১-এর দুটো মান বসান। (anon key গোপন নয়; ডাটা সুরক্ষিত রাখে schema.sql-এর নিয়ম।)

## ধাপ ৩ — GitHub (github.com)
1. **New repository** → নাম `minar-app` → Create।
2. **uploading an existing file** লিংকে ক্লিক করে এই ফোল্ডারের সব ফাইল ও ফোল্ডার (`index.html`, `config.js`, `sw.js`, `manifest.webmanifest`, `vercel.json`, `icons/`, `supabase/`) ড্র্যাগ করুন → **Commit changes**।

## ধাপ ৪ — Vercel (vercel.com)
1. GitHub দিয়ে Sign in → **Add New → Project** → `minar-app` রিপোজিটরি **Import**।
2. Framework Preset: **Other**। Build Command ও Output Directory ফাঁকা রাখুন → **Deploy**।
3. শেষে একটা লিংক পাবেন (যেমন `https://minar-app.vercel.app`)।

## ধাপ ৫ — Supabase-এ লিংক জানানো
**Authentication → URL Configuration**: **Site URL**-এ Vercel-এর লিংকটি বসিয়ে Save।

## ধাপ ৬ — প্রথম ব্যবহার
1. Vercel-এর লিংক খুলে **"ব্যবহারের আবেদন"** ট্যাবে **আপনার Gmail ও পাসওয়ার্ড** দিন। **প্রথম অ্যাকাউন্টই App Owner** হয় (অন্য কেউ আগে আবেদন করলে তিনি ওনার হয়ে যাবেন, তাই নিজে আগে করুন)।
2. Admin প্রোফাইলের ডিফল্ট পাসওয়ার্ড `admin123`। এখনই বদলান: উপরের ডানে **গিয়ার → Admin Profile Password Change**।
3. অন্যদের লিংক দিন। তারা আবেদন করলে **App Owner বাটন** থেকে Approve/Reject, App Lock/Unlock, Kick User করুন।

## ধাপ ৭ — ফোন/কম্পিউটারে ইনস্টল
- **Android (Chrome):** মেনু ⋮ → *Install app* / *Add to Home screen* (অথবা গিয়ার প্যানেলের *Install App* বাটন)।
- **iPhone (Safari):** Share → *Add to Home Screen*।
- **কম্পিউটার (Chrome/Edge):** ঠিকানার বারের ডানে ইনস্টল আইকন।
ইনস্টলের পর হোম-স্ক্রিনে আইকনের নিচে নাম **MCPM**।

## পরে কোড বদলালে
GitHub-এ ফাইল আপডেট করলে Vercel নিজে নতুন সংস্করণ চালু করে। `sw.js`-এর `CACHE = 'mcpm-v1'` নাম বদলালে (v2, v3…) সবার ডিভাইসে নতুন সংস্করণ দ্রুত আসে।

## জেনে রাখুন
- ইন্টারনেট ছাড়া অ্যাপের কাঠামো খুলবে, কিন্তু ডাটা (দাম/প্রোডাক্ট) দেখতে ইন্টারনেট লাগবে।
- অ্যাডমিন পাসওয়ার্ড দিলে ৮ ঘণ্টা পর্যন্ত এডিট করা যায়, তারপর আবার পাসওয়ার্ড চাইবে।
- লক/কিক করলে ইউজার সর্বোচ্চ ~২০ সেকেন্ডের মধ্যে (অ্যাপ খোলা থাকলেও) বের হয়ে যান।
- Supabase-এর Free plan-এ ৭ দিন কেউ ব্যবহার না করলে প্রজেক্ট ঘুমিয়ে যেতে পারে; ড্যাশবোর্ড থেকে Restore করা যায়।
