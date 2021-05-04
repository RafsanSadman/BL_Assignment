from flask import Flask,jsonify
app = Flask(__name__)
tmpDB=[
    {
        'id':'101',
        'description':'Sun 10 May 2015 13:54:36 -0700'
                      'Sun 10 May 2015 13:54:36 -0000',
        'result':'25200'
    },
    {
        'id': '102',
        'description': 'Sat 02 May 2015 19:54:36 +0530'
                       'Fri 01 May 2015 13:54:36 -0000',
        'result': '88200'

    }
]
@app.route("/tmpDB/timedelta", methods=['Get'])
def getAlltmp():
    return jsonify({'tmps':tmpDB})
@app.route('/tmpDB/timedelta/<ID>', methods=['Get'])
def getEmp(ID):
    usr = [ emp for emp in tmpDB if (emp['id'] == ID)]
    return jsonify({'emp':usr})

if __name__ == "__main__":
    app.run()