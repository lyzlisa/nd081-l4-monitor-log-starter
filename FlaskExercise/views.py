from flask import flash, render_template, redirect, request, Response
from FlaskExercise import app


@app.route('/')
def home():
    log = request.values.get('log_button')

    if log not in ["info", "warning", "error", "critical"]:
        return

    if log == "info":
        app.logger.info("home info")
    elif log == "warning":
        app.logger.warning("home warning")
    elif log == "error":
        app.logger.error("home error")
    elif log == "critical":
        app.logger.critical("home critical")
    else:
        return Response(status=400)

    return render_template(
        'index.html',
        log=log
    )
