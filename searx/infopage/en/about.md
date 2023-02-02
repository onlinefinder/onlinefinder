# About OnlineFinder

OnlineFinder is a [metasearch engine], aggregating the results of other
{{link('search engines', 'preferences')}} while not storing information about
its users.


## Why use it?

- OnlineFinder may not offer you as personalized results as Google, but it doesn't
  generate a profile about you.
- OnlineFinder doesn't care about what you search for, never shares anything with a
  third-party, and it can't be used to compromise you.
- OnlineFinder is free software, the code is 100% open, and everyone is welcome to
  make it better.

If you do care about privacy, want to be a conscious user, or otherwise believe
in digital freedom, make OnlineFinder your default search engine or run it on your
own server!

## How do I set it as the default search engine?

OnlineFinder supports [OpenSearch].  For more information on changing your default
search engine, see your browser's documentation:

- [Firefox]
- [Microsoft Edge] - Behind the link, you will also find some useful instructions
  for Chrome and Safari.
- [Chromium]-based browsers only add websites that the user navigates to without
  a path.

When adding a search engine, there must be no duplicates with the same name.  If
you encounter a problem where you cannot add the search engine, you can either:

- remove the duplicate (default name: OnlineFinder) or
- contact the owner to give the instance a different name than the default.

## How does it work?

OnlineFinder is a fork from the well-known [searx] [metasearch engine] which was
inspired by the [Seeks project].  It provides basic privacy by mixing your
queries with searches on other platforms without storing search data.  OnlineFinder
can be added to your browser's search bar; moreover, it can be set as the
default search engine.

[OnlineFinder sources]: {{GIT_URL}}
[OnlineFinder docs]: {{get_setting('brand.docs_url')}}
[searx]: https://github.com/searx/searx
[metasearch engine]: https://en.wikipedia.org/wiki/Metasearch_engine
[Weblate]: https://translate.codeberg.org/projects/searxng/
[Seeks project]: https://beniz.github.io/seeks/
[OpenSearch]: https://github.com/dewitt/opensearch/blob/master/opensearch-1-1-draft-6.md
[Firefox]: https://support.mozilla.org/en-US/kb/add-or-remove-search-engine-firefox
[Microsoft Edge]: https://support.microsoft.com/en-us/help/4028574/microsoft-edge-change-the-default-search-engine
[Chromium]: https://www.chromium.org/tab-to-search
