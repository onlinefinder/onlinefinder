# SPDX-License-Identifier: AGPL-3.0-or-later
"""Implementations needed for a branding of OnlineFinder."""
# pylint: disable=too-few-public-methods

# Struct fields aren't discovered in Python 3.14
# - https://github.com/onlinefinder/onlinefinder/issues/5284
from __future__ import annotations

__all__ = ["SettingsBrand"]

import msgspec


class BrandCustom(msgspec.Struct, kw_only=True, forbid_unknown_fields=True):
    """Custom settings in the brand section."""

    links: dict[str, str] = {}
    """Custom entries in the footer of the WEB page: ``[title]: [link]``"""


class SettingsBrand(msgspec.Struct, kw_only=True, forbid_unknown_fields=True):
    """Options for configuring brand properties.

    .. code:: yaml

       brand:
         issue_url: https://github.com/onlinefinder/onlinefinder/issues
         docs_url: https://docs.onlinefinder.org
         public_instances: https://olf.space
         wiki_url: https://github.com/onlinefinder/onlinefinder/wiki

         custom:
           links:
             Uptime: https://uptime.onlinefinder.org/history/example-org
             About: https://example.org/user/about.html
    """

    issue_url: str = "https://github.com/onlinefinder/onlinefinder/issues"
    """If you host your own issue tracker change this URL."""

    docs_url: str = "https://docs.onlinefinder.org"
    """If you host your own documentation change this URL."""

    public_instances: str = "https://olf.space"
    """If you host your own https://olf.space change this URL."""

    wiki_url: str = "https://github.com/onlinefinder/onlinefinder/wiki"
    """Link to your wiki (or ``false``)"""

    custom: BrandCustom = msgspec.field(default_factory=BrandCustom)
    """Optional customizing.

    .. autoclass:: olf.brand.BrandCustom
       :members:
    """

    # new_issue_url is a hackish solution tailored for only one hoster (GH).  As
    # long as we don't have a more general solution, we should support it in the
    # given function, but it should not be expanded further.

    new_issue_url: str = "https://github.com/onlinefinder/onlinefinder/issues/new"
    """If you host your own issue tracker not on GitHub, then unset this URL.

    Note: This URL will create a pre-filled GitHub bug report form for an
    engine.  Since this feature is implemented only for GH (and limited to
    engines), it will probably be replaced by another solution in the near
    future.
    """
