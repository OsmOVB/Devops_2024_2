from flask import Flask, jsonify, request
from flask_cors import CORS

app = Flask(__name__)

# Habilitar CORS para todas as rotas
CORS(app)

@app.route('/hello', methods=['GET'])
def hello_world():
    return jsonify({'message': 'Hello, World!'})

@app.route('/sum', methods=['POST'])
def sum_numbers():
    data = request.get_json()
    if not data or 'num1' not in data or 'num2' not in data:
        return jsonify({'error': 'Dados inválidos'}), 400
    
    num1 = data.get('num1')
    num2 = data.get('num2')
    
    try:
        total = float(num1) + float(num2)
        return jsonify({'sum': total})
    except (TypeError, ValueError):
        return jsonify({'error': 'Números inválidos'}), 400

if __name__ == '__main__':
    app.run(debug=True)
