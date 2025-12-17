# SPDX-License-Identifier: AGPL-3.0-or-later
# pylint: disable=missing-module-docstring,disable=missing-class-docstring,invalid-name

import pathlib
import os
import aiounittest


os.environ.pop('ONLINEFINDER_SETTINGS_PATH', None)
os.environ['ONLINEFINDER_DISABLE_ETC_SETTINGS'] = '1'


class SearxTestLayer:
    """Base layer for non-robot tests."""

    __name__ = 'SearxTestLayer'

    @classmethod
    def setUp(cls):
        pass

    @classmethod
    def tearDown(cls):
        pass

    @classmethod
    def testSetUp(cls):
        pass

    @classmethod
    def testTearDown(cls):
        pass


class SearxTestCase(aiounittest.AsyncTestCase):
    """Base test case for non-robot tests."""

    layer = SearxTestLayer

    SETTINGS_FOLDER = pathlib.Path(__file__).parent / "unit" / "settings"
    TEST_SETTINGS = "test_settings.yml"

    def setUp(self):
        self.init_test_settings()

    def setattr4test(self, obj, attr, value):
        """setattr(obj, attr, value) but reset to the previous value in the
        cleanup."""
        previous_value = getattr(obj, attr)

        def cleanup_patch():
            setattr(obj, attr, previous_value)

        self.addCleanup(cleanup_patch)
        setattr(obj, attr, value)

    def init_test_settings(self):
        """Sets ``ONLINEFINDER_SETTINGS_PATH`` environment variable an initialize
        global ``settings`` variable and the ``logger`` from a test config in
        :origin:`tests/unit/settings/`.
        """

        os.environ['ONLINEFINDER_SETTINGS_PATH'] = str(self.SETTINGS_FOLDER / self.TEST_SETTINGS)

        # pylint: disable=import-outside-toplevel
        import olf
        import olf.locales
        import olf.plugins
        import olf.search
        import olf.webapp

        # https://flask.palletsprojects.com/en/stable/config/#builtin-configuration-values
        # olf.webapp.app.config["DEBUG"] = True
        olf.webapp.app.config["TESTING"] = True  # to get better error messages
        olf.webapp.app.config["EXPLAIN_TEMPLATE_LOADING"] = True

        olf.init_settings()
        olf.plugins.initialize(olf.webapp.app)

        # olf.search.initialize will:
        # - load the engines and
        # - initialize olf.network, olf.metrics, olf.processors and olf.search.checker

        olf.search.initialize(
            enable_checker=True,
            check_network=True,
            enable_metrics=olf.get_setting("general.enable_metrics"),  # type: ignore
        )

        # pylint: disable=attribute-defined-outside-init
        self.app = olf.webapp.app
        self.client = self.app.test_client()
