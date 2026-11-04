#!/usr/bin/env python3
"""Unit test suite for problem_with_exceptions HOL4/CakeML script files."""

import os
import unittest

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


class TestProblemWithExceptions(unittest.TestCase):
    def test_hol_scripts_exist(self):
        for rel in ("README.md", "Holmakefile", "exceptionProgScript.sml", "exception2ProgScript.sml"):
            fpath = os.path.join(ROOT, rel)
            self.assertTrue(os.path.isfile(fpath), f"Missing {fpath}")
            self.assertGreater(os.path.getsize(fpath), 0)

    def test_theory_declarations(self):
        for rel in ("exceptionProgScript.sml", "exception2ProgScript.sml"):
            with open(os.path.join(ROOT, rel), encoding="utf-8") as f:
                text = f.read()
            self.assertIn("open", text)
            self.assertIn("export_theory", text)


if __name__ == "__main__":
    unittest.main()
