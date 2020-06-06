import click
import os
from flask import Flask, request, jsonify, render_template, send_from_directory


app = Flask(__name__, static_url_path='',
            static_folder='web/static', template_folder='web/templates')


@app.route('/api/detect', methods=['POST'])
def detect():

    ret = request.form
    # print(request.files)

    return jsonify(ret)


@click.command()
@click.option('--port', '-p', default=8000, type=int)
@click.option('--env', '-e', default='development')
def run(port, env):
    os.environ['FLASK_ENV'] = env
    # start server
    app.run(host='0.0.0.0', port=port)


if __name__ == '__main__':
    run()
