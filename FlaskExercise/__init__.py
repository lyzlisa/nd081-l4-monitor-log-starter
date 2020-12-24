import logging
from flask import Flask

app = Flask(__name__)
wsgi_app = app.wsgi_app

app.logger.setLevel(logging.WARNING)

stream_handler = logging.StreamHandler()
stream_handler.setLevel(logging.WARNING)
app.logger.addHandler(stream_handler)

import FlaskExercise.views
