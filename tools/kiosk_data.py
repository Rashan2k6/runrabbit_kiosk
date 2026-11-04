#!/usr/bin/env python3
"""RunRabbit kiosk data tool: Shopify export -> review sheet -> products.json -> images.

Works on the ORIGINAL Shopify export (products_export_1.csv, 1,517 rows, 129 columns).
Row types in that file (all handled here):
  * product row       Title filled (first variant of a product)
  * extra variant row Title empty, Option1 Value / Variant Price filled
  * gallery row       Title empty, only Handle + Image Src (+ Image Position)

Commands (run from the project root):
  python tools/kiosk_data.py review-sheet --export products_export_1.csv --out tools/kiosk_review.csv
  python tools/kiosk_data.py build        --export products_export_1.csv --review tools/kiosk_review.csv
  python tools/kiosk_data.py images       (needs: pip install pillow, and internet)

Only the standard library is used for review-sheet and build.
"""
import argparse, csv, html, json, re, sys, time, urllib.request
from pathlib import Path

csv.field_size_limit(10**9)

STEPS = ['cleanser', 'toner', 'serum', 'moisturiser', 'sunscreen', 'mask']
SKIN_IDS = {'oily', 'dry', 'combination', 'sensitive', 'normal', 'all'}
CONCERNS = ['acne', 'pores', 'pigmentation', 'dullness', 'aging', 'darkcircles', 'dryness', 'redness']

# --- reading the original export ------------------------------------------------------------
def toks(v):
    return [t.strip() for t in re.split(r'[\n;]', v or '') if t.strip()]

def plain(h):
    return re.sub(r'\s+', ' ', html.unescape(re.sub(r'<[^>]+>', ' ', h or ''))).strip()

def load_export(path):
    """Returns {handle: product dict} for every product in the original export."""
    with open(path, encoding='utf-8-sig', newline='') as f:
        rows = list(csv.DictReader(f))
    cols = list(rows[0].keys())

    def col(prefix):  # metafield columns carry a long "(product.metafields...)" suffix
        hit = next((c for c in cols if c.startswith(prefix)), None)
        if hit is None:
            sys.exit(f'Column starting with "{prefix}" not found. Is this the original 129-column export?')
        return hit

    C = dict(
        cat=col('Category (product.metafields.filter.category)'), step=col('Step (Skincare)'),
        skin=col('Skin Type (product.metafields'), concern=col('Concern (Skincare)'),
        skinc=col('Skin Concern'), ing=col('Key Ingredient (Skincare)'), how=col('How to Use'),
        inci=col('All Ingredients'), what=col('What it is'), pgroup=col('Product Group'),
    )
    prods = {}
    for r in rows:
        p = prods.setdefault(r['Handle'], {'row': None, 'variants': [], 'images': []})
        if (r['Title'] or '').strip():
            p['row'] = r
        if (r['Variant Price'] or '').strip():
            p['variants'].append({
                'price': float(r['Variant Price']),
                'opt1': (r['Option1 Name'], r['Option1 Value']),
                'opt2': (r['Option2 Name'], r['Option2 Value']),
            })
        if (r['Image Src'] or '').strip():
            pos = int(float(r['Image Position'] or 9999))
            p['images'].append((pos, r['Image Src'].strip()))
    for h, p in prods.items():
        p['handle'] = h
        p['images'].sort()
    return {h: p for h, p in prods.items() if p['row']}, C

# --- pre-filling guesses (always to be reviewed by staff) -----------------------------------
SPECIFIC = {  # "Skin Concern" field: specific tags -> weight 2
    'acne': {'Acne & Blemishes', 'Breakouts', 'Acne & Pimples'},
    'pores': {'Open Pores', 'Blackheads & Whiteheads'},
    'pigmentation': {'Hyperpigmentation', 'Dark Spots', 'Dark Spots & Pigmentation'},
    'dullness': {'Dullness', 'Skin Brightening'},
    'aging': {'Anti-Aging', 'Fine Lines & Wrinkles'},
    'darkcircles': {'Dark Circles'},
}
# "Concern" field is very generous (almost every product lists "Dry Skin"), so it only gets weight 1
# and "Dry Skin" / "Sensitive Skin" in it are ignored.
# Common ingredients only STRENGTHEN a concern the product already has (+1, max 3). Nearly every K-beauty
# product has niacinamide or hyaluronic acid, so letting them create weights made all products look alike.
REINFORCE = {
    'niacinamide': ['pores', 'pigmentation'], 'peptide': ['aging'], 'collagen': ['aging'],
    'adenosine': ['aging'], 'tea tree': ['acne'], 'hyaluronic': ['dryness'], 'ceramide': ['dryness'],
    'squalane': ['dryness'], 'panthenol': ['redness'], 'allantoin': ['redness'],
}
# Strong actives may CREATE a concern (weight 2). Checked against first 15 ingredients + title + key tags.
SIGNATURE = {
    'retinol': ['aging'], 'retinal': ['aging'], 'salicylic acid': ['acne', 'pores'], 'aha & bha': ['acne', 'pores'],
    'caffeine': ['darkcircles'], 'arbutin': ['pigmentation'], 'tranexamic': ['pigmentation'],
    'glutathione': ['pigmentation', 'dullness'], 'vitamin c': ['pigmentation', 'dullness'],
    'ascorbic': ['pigmentation', 'dullness'], 'centella': ['redness'], 'madecassoside': ['redness'],
}
BHA_AHA = ['salicylic acid', 'glycolic acid', 'lactic acid', 'mandelic acid', 'betaine salicylate', 'aha & bha']
SKIN_MAP = {'Oily Skin': 'oily', 'Dry Skin': 'dry', 'Combination Skin': 'combination',
            'Sensitive Skin': 'sensitive', 'All Skin Types': 'all'}
CATEGORY_STEP = {'face serums': 'serum', 'facial cleansers': 'cleanser', 'face moisturizers': 'moisturiser',
                 'lotions & moisturizers': 'moisturiser', 'sunscreen': 'sunscreen', 'toners': 'toner',
                 'astringents': 'toner'}
STEP_ORDER = ['cleanser', 'toner', 'serum', 'moisturiser', 'sunscreen']
STEP_WORD = {'Cleanser': 'cleanser', 'Toner': 'toner', 'Serum': 'serum', 'Moisturiser': 'moisturiser',
             'Moisturizer': 'moisturiser', 'Sunscreen': 'sunscreen'}

def guess(p, C):
    r = p['row']
    notes = []
    # Only trust ingredients that matter: Shopify's key-ingredient tags + the first 15 INCI entries
    # (matching anywhere in a 40-item list gave false cautions, e.g. trace acids in a cleansing oil).
    top = ', '.join(re.split(r',\s*', r[C['inci']])[:15])
    inci = (top + ' ' + r[C['ing']]).lower()          # used for concern weights (low risk)
    # Safety guesses (cautions / avoid) use ONLY the first 15 ingredients and the title: Shopify's
    # key-ingredient tags are loose (a "Summer" cream tagged retinol, a sunscreen tagged salicylic acid).
    safe = (top + ' ' + r['Title']).lower()
    # step
    steps = [STEP_WORD[t] for t in toks(r[C['step']]) if t in STEP_WORD]
    cat = r['Product Category'].split('>')[-1].strip()
    step = CATEGORY_STEP.get(cat.lower()) or next((s for s in STEP_ORDER if s in steps), '')
    if len(steps) > 1:
        notes.append(f'check step (Shopify lists: {"/".join(steps)})')
    if cat.lower() == 'skin care masks & peels':
        step = 'mask'   # sheet masks tagged "Serum" in Shopify would otherwise be recommended as serums
        notes.append('mask/peel: the kiosk only shows it if a Mask step exists; change step if wrong')
    if cat.lower() == 'eye creams' and not step:
        step = 'moisturiser'
    # include?
    handle_title = (p['handle'] + ' ' + r['Title']).lower()
    is_set = ('kits & sets' in cat.lower() or r['Type'] == 'Skin Care Set' or 'bundle' in handle_title
              or ' set' in r['Title'].lower() or 'Bundles' in toks(r[C['cat']]))
    include = 'yes' if step and not is_set else 'no'
    if is_set:
        notes.append('set/bundle: left out by default (set include to yes to show it)')
    if not step:
        notes.append('no usable step')
    # concerns
    w = {c: 0 for c in CONCERNS}
    has_specific = bool(toks(r[C['skinc']]))
    for c, tags in SPECIFIC.items():
        if any(t in tags for t in toks(r[C['skinc']])):
            w[c] = 2
        elif not has_specific and any(t in tags for t in toks(r[C['concern']])):
            w[c] = 1   # generic store tags are only a fallback when there are no specific ones
    if not has_specific:
        notes.append('weights from generic store tags only: review carefully')
    for key, cs in REINFORCE.items():
        if key in inci:
            for c in cs:
                if w[c]:
                    w[c] = min(3, w[c] + 1)
    for key, cs in SIGNATURE.items():
        if key in inci:
            for c in cs:
                w[c] = min(3, max(w[c], 2) + (1 if w[c] >= 2 else 0))
    if step == 'moisturiser' and w['dryness'] == 0:
        w['dryness'] = 1
    if not any(w.values()):
        notes.append('no concern detected: set weights')
    # skin types
    tags = toks(r[C['skin']])
    specific = sorted({SKIN_MAP[t] for t in tags if t in SKIN_MAP and SKIN_MAP[t] != 'all'})
    if not tags:
        skin = ['all']
        notes.append('no skin type in Shopify: assumed all')
    elif len(specific) >= 4 or specific == []:
        skin = ['all']
    else:
        skin = specific
        if 'All Skin Types' in tags:
            notes.append('Shopify says All Skin Types plus a subset: kept the subset')
    # avoid + caution
    avoid, caution = set(), ''
    if 'retinol' in safe or 'retinal' in safe or 'retinaldehyde' in safe:
        avoid.add('sensitive')
        caution = 'Night use only. Not for use in pregnancy. Always use sunscreen the next day.'
    elif any(k in safe for k in BHA_AHA + ['peel', 'exfoliant']):
        avoid.add('sensitive')
        caution = 'May cause dryness or stinging. Avoid the eye area. Always use sunscreen.'
    elif 'vitamin c' in safe or 'ascorbic' in safe:
        caution = 'May tingle on first use. Use sunscreen in the daytime.'
    if step == 'sunscreen':
        caution = (caution + ' ' if caution else '') + 'Reapply every 2 hours when outdoors.'
    if caution:
        notes.append('SAFETY: caution/avoid is only a guess from the ingredient list: check the product label')
    # size / price / variants
    sizes = [v['opt1'][1] for v in p['variants'] if v['opt1'][0] == 'Size'] + \
            [v['opt2'][1] for v in p['variants'] if v['opt2'][0] == 'Size']
    size = sizes[0] if sizes else ''
    prices = sorted({v['price'] for v in p['variants']})
    if len(p['variants']) > 1:
        notes.append(f'{len(p["variants"])} variants, shown from Rs. {int(prices[0])}')
    return dict(include=include, step=step, size=size, skin_types=';'.join(skin),
                avoid_skin_types=';'.join(sorted(avoid)), caution_en=caution, weights=w,
                price=int(prices[0]) if prices else '', category=cat, notes=notes)

# --- review sheet --------------------------------------------------------------------------
SHEET_COLS = (['include', 'handle', 'title', 'vendor', 'kind', 'step', 'price_lkr', 'size', 'in_stock',
               'skin_types', 'avoid_skin_types'] + [f'w_{c}' for c in CONCERNS] +
              ['caution_en', 'shelf', 'reviewed', 'notes'])

def cmd_review_sheet(a):
    prods, C = load_export(a.export)
    out = Path(a.out)
    if out.exists() and not a.force:
        sys.exit(f'{out} already exists (your reviewed work!). Use --force to overwrite or pick another --out.')
    live = [p for p in prods.values() if p['row']['Status'] == 'active'
            and p['row']['Published'].lower() == 'true' and 'Skincare' in toks(p['row'][C['cat']])]
    live.sort(key=lambda p: (STEP_ORDER.index(guess(p, C)['step']) if guess(p, C)['step'] in STEP_ORDER else 9,
                             p['row']['Vendor'], p['row']['Title']))
    out.parent.mkdir(parents=True, exist_ok=True)
    with open(out, 'w', encoding='utf-8-sig', newline='') as f:  # BOM so Excel shows symbols correctly
        w = csv.DictWriter(f, fieldnames=SHEET_COLS)
        w.writeheader()
        for p in live:
            g = guess(p, C)
            row = dict(include=g['include'], handle=p['handle'], title=p['row']['Title'],
                       vendor=p['row']['Vendor'], kind=g['category'], step=g['step'], price_lkr=g['price'],
                       size=g['size'], in_stock='yes', skin_types=g['skin_types'],
                       avoid_skin_types=g['avoid_skin_types'], caution_en=g['caution_en'], shelf='',
                       reviewed='', notes=' | '.join(g['notes']))
            row.update({f'w_{c}': g['weights'][c] for c in CONCERNS})
            w.writerow(row)
    print(f'Wrote {len(live)} live skincare products to {out}')
    print('Staff: check every row, fix the guesses, fill in shelf, then put "yes" in the reviewed column.')

# --- build products.json --------------------------------------------------------------------
def short(text, n=150):
    text = plain(text)
    if len(text) <= n:
        return text
    cut = text[:n]
    m = max(cut.rfind('. '), cut.rfind('! '))
    return (cut[:m + 1] if m > 60 else cut.rsplit(' ', 1)[0] + '...')

def cmd_build(a):
    prods, C = load_export(a.export)
    with open(a.review, encoding='utf-8-sig', newline='') as f:
        sheet = list(csv.DictReader(f))
    errors, warnings, items, seen = [], [], [], set()
    unreviewed = 0
    for i, s in enumerate(sheet, start=2):  # row number as shown in Excel
        if s['include'].strip().lower() != 'yes':
            continue
        h = s['handle'].strip()
        where = f'row {i} ({h})'
        if h in seen:
            errors.append(f'{where}: duplicate handle'); continue
        seen.add(h)
        p = prods.get(h)
        if not p:
            errors.append(f'{where}: handle not found in the export'); continue
        if s['reviewed'].strip().lower() != 'yes':
            unreviewed += 1
        step = s['step'].strip().lower()
        if step not in STEPS:
            errors.append(f'{where}: step "{step}" must be one of {STEPS}')
        skin = [t for t in re.split(r'[;,]', s['skin_types'].lower()) if t.strip()]
        avoid = [t for t in re.split(r'[;,]', s['avoid_skin_types'].lower()) if t.strip()]
        skin, avoid = [t.strip() for t in skin], [t.strip() for t in avoid]
        for t in skin + avoid:
            if t not in SKIN_IDS:
                errors.append(f'{where}: unknown skin type "{t}"')
        if not skin:
            errors.append(f'{where}: skin_types is empty (use "all")')
        conc = {}
        for c in CONCERNS:
            raw = (s[f'w_{c}'] or '0').strip() or '0'
            if raw not in ('0', '1', '2', '3'):
                errors.append(f'{where}: w_{c} must be 0-3, got "{raw}"')
            elif int(raw) > 0:
                conc[c] = int(raw)
        price = (s['price_lkr'] or '').strip()
        if not price.replace('.', '', 1).isdigit():
            errors.append(f'{where}: price_lkr missing')
        if not p['images']:
            warnings.append(f'{where}: no image in Shopify')
        if not s['shelf'].strip():
            warnings.append(f'{where}: shelf is empty')
        if not conc:
            warnings.append(f'{where}: no concern weights, only ever shown as a filler')
        r = p['row']
        benefit = short(r[C['what']] or r['Body (HTML)'])
        note = s['caution_en'].strip()
        prices = {v['price'] for v in p['variants']}
        items.append({
            'id': h, 'name': r['Title'].strip(), 'brand': r['Vendor'].strip(), 'step': step,
            'price': int(float(price)) if price else 0, 'priceFrom': len(prices) > 1,
            'size': s['size'].strip(), 'inStock': s['in_stock'].strip().lower() != 'no',
            'skinTypes': skin, 'avoidSkinTypes': avoid, 'concerns': conc,
            'keyIngredients': toks(r[C['ing']]), 'note': ({'en': note} if note else {}),
            'shelf': s['shelf'].strip(), 'benefit': {'en': benefit},
            'howTo': {'en': plain(r[C['how']])}, 'ingredients': plain(r[C['inci']]),
            'image': f'assets/images/products/{h}.webp',
            'imageUrl': p['images'][0][1] if p['images'] else '',
        })
    if errors:
        print('Fix these in the review sheet, then run again:\n  ' + '\n  '.join(errors))
        sys.exit(1)
    if a.require_reviewed and unreviewed:
        sys.exit(f'{unreviewed} included rows are not marked reviewed = yes.')
    out = Path(a.out)
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(json.dumps({'source': Path(a.export).name, 'generated': time.strftime('%Y-%m-%d'),
                               'products': items}, indent=1, ensure_ascii=False), encoding='utf-8')
    by = {}
    for it in items:
        by[it['step']] = by.get(it['step'], 0) + 1
    print(f'Wrote {len(items)} products to {out}   per step: {by}')
    print(f'Not yet marked reviewed: {unreviewed}   warnings: {len(warnings)}')
    for w in warnings[:25]:
        print('  warning:', w)
    if len(warnings) > 25:
        print(f'  ... and {len(warnings) - 25} more')

# --- images --------------------------------------------------------------------------------
def cmd_images(a):
    try:
        from PIL import Image
    except ImportError:
        sys.exit('Install Pillow first:  pip install pillow')
    import io
    data = json.loads(Path(a.products).read_text(encoding='utf-8'))
    outdir = Path(a.outdir)
    outdir.mkdir(parents=True, exist_ok=True)
    done = failed = skipped = total = 0
    for p in data['products']:
        dest = Path(p['image'])
        dest = outdir / dest.name
        if dest.exists() and not a.force:
            skipped += 1; continue
        if not p.get('imageUrl'):
            failed += 1; print('  no image url:', p['id']); continue
        try:
            req = urllib.request.Request(p['imageUrl'], headers={'User-Agent': 'runrabbit-kiosk-tools'})
            raw = urllib.request.urlopen(req, timeout=30).read()
            im = Image.open(io.BytesIO(raw))
            if im.mode in ('RGBA', 'LA', 'P'):
                bg = Image.new('RGB', im.size, 'white')
                im = im.convert('RGBA'); bg.paste(im, mask=im.split()[-1]); im = bg
            else:
                im = im.convert('RGB')
            if im.width > a.max_width:
                im = im.resize((a.max_width, round(im.height * a.max_width / im.width)), Image.LANCZOS)
            im.save(dest, 'WEBP', quality=a.quality, method=4)
            done += 1; total += dest.stat().st_size
        except Exception as e:  # keep going, report at the end
            failed += 1; print(f'  failed {p["id"]}: {e}')
    print(f'Saved {done}, skipped {skipped} existing, failed {failed}. New files total {total / 1024:.0f} KB')
    print('Large files slow low-end tablets: if the total is big, lower --max-width or --quality.')

# --- cli -----------------------------------------------------------------------------------
def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = ap.add_subparsers(dest='cmd', required=True)
    s = sub.add_parser('review-sheet'); s.add_argument('--export', required=True)
    s.add_argument('--out', default='tools/kiosk_review.csv'); s.add_argument('--force', action='store_true')
    s.set_defaults(fn=cmd_review_sheet)
    s = sub.add_parser('build'); s.add_argument('--export', required=True)
    s.add_argument('--review', default='tools/kiosk_review.csv')
    s.add_argument('--out', default='assets/data/products.json')
    s.add_argument('--require-reviewed', action='store_true'); s.set_defaults(fn=cmd_build)
    s = sub.add_parser('images'); s.add_argument('--products', default='assets/data/products.json')
    s.add_argument('--outdir', default='assets/images/products'); s.add_argument('--max-width', type=int, default=640)
    s.add_argument('--quality', type=int, default=72); s.add_argument('--force', action='store_true')
    s.set_defaults(fn=cmd_images)
    a = ap.parse_args(); a.fn(a)

if __name__ == '__main__':
    main()
