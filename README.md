# modriff.com

The public site for [mõdRïff](https://modriff.com): landing page, support, privacy
policy and terms. Plain static HTML and one stylesheet, no build step and nothing
loaded from other companies (the privacy policy says so, keep it true).

```
index.html      landing page
support.html    FAQ and contact
privacy.html    privacy policy (App Store requires its URL)
terms.html      terms of use
play/           the free browser version of the app. Generated: do not edit by hand.
                Made by `npm run publish:web -- ../modriff-site` in the modriff repo.
score/          mõdScore, copied from the Mobile-Notation repo by build/sync-apps.sh.
playground/     Music Playground, copied from the General-Music repo by build/sync-apps.sh
                (without its analytics snippet). Do not edit either copy by hand.
assets/         site.css, icons, screenshots, fonts/ (Outfit, the app's typeface, OFL)
CNAME           the custom domain: leave it in place
```

Served by GitHub Pages from `main` / root. DNS (Namecheap): four `A` records for `@`
(185.199.108.153, .109.153, .110.153, .111.153) and `CNAME www` to `handelmusic-cpu.github.io`.

The app itself lives in the `modriff` repo; the App Store listing text and
screenshots are in its `docs/app-store.md`. When the app is live, put its App Store
URL on the button with `id="get-app"` in `index.html`.

## The launch email list

The one form on the site is the opt-in launch list on the home page (`#launch-list` in
`index.html`). It is a plain HTML form that posts straight to the list service: no script,
no iframe, no cookies, and nothing from the service loads until someone presses Join. Keep
it that way, and keep it out of the apps (`play/`, `score/`, `playground/`).

- **The one setting** is the form's `action`, the service's subscribe address. For Buttondown
  it is `https://buttondown.com/api/emails/embed-subscribe/USERNAME`. The placeholder
  `YOUR-BUTTONDOWN-USERNAME` must be replaced before this goes live.
- `privacy.html#email-list` names the service and promises that its open and click tracking
  are off. If the service or that setting changes, change the policy first.

## The mõd suite

modriff.com is the home of all three web apps (`play/`, `score/`, `playground/`), on one
origin on purpose: that is what will let them pass songs to each other in the browser.
`build/sync-apps.sh` has the details; run it after a change to mõdScore or Music Playground.
