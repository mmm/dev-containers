from flask import Flask
app = Flask(__name__)

@app.route("/")
def default_response():
    return "This is the response!"

@app.route("/purchase_a_sword")
def purchase_sword():
    # business logic to purchase sword
    return "Sword Purchased!"
