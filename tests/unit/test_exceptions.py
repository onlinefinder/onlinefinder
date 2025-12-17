# SPDX-License-Identifier: AGPL-3.0-or-later
# pylint: disable=missing-module-docstring,disable=missing-class-docstring,invalid-name

from parameterized import parameterized
from tests import SearxTestCase
import olf.exceptions
from olf import get_setting


class TestExceptions(SearxTestCase):

    @parameterized.expand(
        [
            olf.exceptions.SearxEngineAccessDeniedException,
            olf.exceptions.SearxEngineCaptchaException,
            olf.exceptions.SearxEngineTooManyRequestsException,
        ]
    )
    def test_default_suspend_time(self, exception):
        with self.assertRaises(exception) as e:
            raise exception()
        self.assertEqual(
            e.exception.suspended_time,
            get_setting(exception.SUSPEND_TIME_SETTING),
        )

    @parameterized.expand(
        [
            olf.exceptions.SearxEngineAccessDeniedException,
            olf.exceptions.SearxEngineCaptchaException,
            olf.exceptions.SearxEngineTooManyRequestsException,
        ]
    )
    def test_custom_suspend_time(self, exception):
        with self.assertRaises(exception) as e:
            raise exception(suspended_time=1337)
        self.assertEqual(e.exception.suspended_time, 1337)
