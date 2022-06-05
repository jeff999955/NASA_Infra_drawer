from flask import Flask,jsonify,request
import json

app =   Flask(__name__)
  
@app.route('/json', methods = ['GET'])
def ReturnJSON():
    if(request.method == 'GET'):
        with open('data.json') as json_file:
            data = json.load(json_file)
  
        return jsonify(data)
  
if __name__=='__main__':
    app.run(debug=True)