# Running This

## Prerequisites

If configured, it uses Redis for a low level persistent cache store. A running redis on localhost is sufficient.

`shards` to install dependencies.

## Running

Without persistent cache: `crystal run src/server.cr` and open [http://0.0.0.0:3000](http://0.0.0.0:3000).
With persistent cache `crystal run src/server.cr -Dpersistent_cache`

## Explanation

When `Parse Dates` is selected:

- Each page in the list is scraped
- Any pages which have already been cached are returned immediately
- Any pages which aren't are requested asynchronously over a basic Javascript WebSocket connection.

When `Search` is selected:

- Each page in the list is fetched from cache.
- Perform a text search rank on the full set of pages in the cache

### Scraping

- I used the fantastic and wicked fast [lexbor](https://github.com/kostya/lexbor) shard to parse and navigate html.
- No consideration is given to "too much parallelism" - complete trust is given to the crystal runtime to manage the fibers.

### Date parsing algorithms

- A hierarchy of parsing algorithms is implemented, and the first matching method is trusted.
- For speed, pages which contain some sort of standardized declaration of publish date are quickly parsed with a dedicated routine for that pages.
- Algorithms are vaguely sorted by speed, so the first to match is _probably_ the fastest that will work for that page.
- The final search is a free-form text/regex based fallback, which takes the longest by far.
- Faster algorithms have a higher degree of trust. For example, it is trusted that the Youtube `itemprop=datePublished` meta tag is correct.
- cf. scraper/date_extractor.cr and scraper/date_extractors/

### Caching

- A simple hash is used for caching fully parsed and analyzed pages in memory.
- A second tier, persistent cache is implemented in Redis. This stores only the raw html, and when a fetch from persistent cache is performed it needs to be re-analyzed.
- No thought has been given to expiring cache entries at either tier.

