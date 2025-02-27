from flask import Flask, jsonify, request, make_response
from flask_cors import CORS
from google.cloud import datastore
import logging
import os

app = Flask(__name__)
CORS(app, resources={r"/*": {"origins": "https://jw-barker.com"}})

client = datastore.Client(namespace="visitorcounter")

@app.route('/visit', methods=['GET', 'OPTIONS'])
def visit():
    # Handle CORS preflight requests
    if request.method == 'OPTIONS':
        response = make_response()
        response.headers['Access-Control-Allow-Origin'] = 'https://jw-barker.com'
        response.headers['Access-Control-Allow-Methods'] = 'GET, OPTIONS'
        response.headers['Access-Control-Allow-Headers'] = 'Content-Type, Authorization, X-Requested-With'
        response.headers['Access-Control-Max-Age'] = '3600'
        return response, 204

    kind = "visitorCounter"
    entity_id = "counter"

    try:
        key = client.key(kind, entity_id)
        entity = client.get(key)

        if not entity:
            logging.error('Counter not found in Firestore.')
            return jsonify({'error': 'Counter not found in Firestore'}), 404

        entity['count'] += 1
        client.put(entity)

        response = make_response(jsonify({'count': entity['count']}), 200)
        response.headers['Access-Control-Allow-Origin'] = 'https://jw-barker.com'
        return response

    except Exception as e:
        logging.error(f"Error in /visit endpoint: {e}")
        response = make_response(jsonify({'error': str(e)}), 500)
        response.headers['Access-Control-Allow-Origin'] = 'https://jw-barker.com'
        return response

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 8080))
    app.run(host='0.0.0.0', port=port)
