# modriff.com

The public site for [mõdRïff](https://modriff.com): landing page, support, privacy
policy and terms. Plain static HTML and one stylesheet, no build step and nothing
loaded from other companies (the privacy policy says so, keep it true).

```
index.html      landing page
support.html    FAQ and contact
privacy.html    privacy policy (App Store requires its URL)
terms.html      terms of use
assets/         site.css, icons, screenshots
CNAME           the custom domain: leave it in place
```

Served by GitHub Pages from `main` / root. DNS (Namecheap): four `A` records for `@`
(185.199.108.153, .109.153, .110.153, .111.153) and `CNAME www` to `handelmusic-cpu.github.io`.

The app itself lives in the `modriff` repo; the App Store listing text and
screenshots are in its `docs/app-store.md`. When the app is live, put its App Store
URL on the button with `id="get-app"` in `index.html`.
