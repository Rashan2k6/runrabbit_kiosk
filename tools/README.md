# Kiosk data tools

Turns the Shopify export into the kiosk's `assets/data/products.json` and product images.
Python 3.9+ only. `pip install pillow` is needed for the `images` step.

IMPORTANT: use the ORIGINAL export (`products_export_1.csv`, 1,517 rows, 129 columns). The slimmed-down
versions have no image links. Keep the export in `tools/data/` (git-ignored). Never put it in `assets/`,
or it ships inside the tablet app.

## Steps
1. Make or refresh the review sheet (a ready one is in `tools/kiosk_review.csv`):
   `python tools/kiosk_data.py review-sheet --export tools/data/products_export_1.csv --out tools/kiosk_review.csv`
   (it refuses to overwrite a sheet that already exists, to protect staff work; use `--force` deliberately)
2. Staff review the sheet in Excel or Google Sheets (File > Import, UTF-8). See the column guide below.
3. Build the app data:
   `python tools/kiosk_data.py build --export tools/data/products_export_1.csv --review tools/kiosk_review.csv`
   It lists every error with a row number. Add `--require-reviewed` to insist every included row says `yes`.
4. Download and shrink the images (needs internet):
   `python tools/kiosk_data.py images`
   Check the reported total size. Target: under about 10 MB for all images.
5. Run the app and test.

## Review sheet columns
| Column | What to do |
|---|---|
| include | `yes` = show in the kiosk, `no` = leave out (sets and bundles start as `no`) |
| step | cleanser, toner, serum, moisturiser, sunscreen, or mask. Fix wrong guesses |
| price_lkr, size | From Shopify (cheapest variant). Fix size if blank |
| in_stock | `yes` / `no`. The export has no stock quantity, so this is manual for now |
| skin_types | Skin types it truly suits: oily, dry, combination, sensitive, normal, or `all` (separate with `;`) |
| avoid_skin_types | Skin types that should NEVER be shown this product |
| w_acne ... w_redness | How strongly it helps each concern: 0 none, 1 slight, 2 good, 3 main purpose |
| caution_en | Warning shown on the card (blank = none) |
| shelf | Where customers find it in the store |
| reviewed | Put `yes` once a person has checked the row |
| notes | Flags from the tool. Read them, then clear or ignore |

SAFETY: `avoid_skin_types` and `caution_en` are only guesses from the ingredient list. A person must
check them against the product label before the kiosk goes live (retinol, acids, vitamin C, pregnancy).
Weights are guesses from Shopify tags (which are very generous) and need staff judgement.

## Notes
- Prices use the cheapest variant; products with several sizes show "from" pricing (`priceFrom`).
- Stock is not in the export. Later, read it from Shopify's inventory (API or inventory export).
- Shopify tags only matter as starting points. The review sheet is the source of truth.
