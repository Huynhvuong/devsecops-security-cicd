import unittest
import json
from flask import Flask

# Add current directory to the path
import sys
sys.path.append('.')

from main import app  # Assuming the Flask app is defined in main.py

class HealthcheckTestCase(unittest.TestCase):
    def setUp(self):
        self.app = app.test_client()
        self.app.testing = True

    def test_healthcheck(self):
        response = self.app.get('/healthcheck')
        self.assertEqual(response.status_code, 200)
        body = response.data.decode()

        # Split the response into JSON and designer line
        json_part, designer_part = body.strip().split('\n\n', 1)
        data = json.loads(json_part)

        self.assertEqual(data['status'], 'ok')
        self.assertIn('app_env', data)
        self.assertIn('timestamp', data)
        self.assertEqual(designer_part.strip(), "Designed by HieuMai & VuongHuynh.")

if __name__ == '__main__':
    unittest.main()