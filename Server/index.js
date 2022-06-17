const express = require("express");
const app = express();
const db = require("./database.js")
const cors = require('cors')
    // constants
const PORT = process.env.PORT || 8000;

// middlewares
app.use(express.json());

// set dates
let current_date = new Date()
let toggleFlag = false;

function set_date() {
    current_date = new Date();
}
//setInterval(set_date, 900000);
setInterval(set_date, 900000);
// routes
app.get("/api/readings", cors(), async(req, res) => {

    const sql = "select * from readings"
    const params = []
    db.all(sql, params, (err, rows) => {
        if (err) {
            res.status(400).json({ "error": err.message });
            return;
        }
        res.status(200).json(
            rows
        )
    });
});

app.get("/api/readings/:sensor", cors(), (req, res) => {
    const sql = "select * from readings where sensor = ?"
    const params = [req.params.sensor]
    db.all(sql, params, (err, rows) => {
        if (err) {
            res.status(400).json({ "error": err.message });
            return;
        }
        res.status(200).json(
            rows
        )
    });
});


app.post("/api/readings", cors(), async(req, res) => {

    var errors = []
    if (!req.body.sensor) {
        errors.push("No sensor specified");
    }
    if (!(req.body.value >= 0)) {
        errors.push("No value specified");
    }
    if (errors.length) {
        res.status(400).json({ "error": errors.join(",") });
        return;
    }
    let current_time = new Date()
    const data = {
        sensor: req.body.sensor,
        value: req.body.value,
        timestamp: (current_time.getTime() - current_date.getTime()) / 1000
    }
    var sql = 'INSERT INTO readings (sensor, value, timestamp) VALUES (?,?,?)'
    var params = [data.sensor, data.value, data.timestamp]
    db.run(sql, params, function(err, result) {
        if (err) {
            res.status(400).json({ "error": err.message })
            return;
        }
        res.status(200).json(
            data
        )
    });
});

app.post("/api/toggle/:toggle", cors(), async(req, res) => {
    if (req.params.toggle == "True"){
        toggleFlag = true;
    }
    else if (req.params.toggle == "False"){
        toggleFlag = false;
    }
    else {res.status(400).json(
        "NOk"
    )}
    res.status(200).json(
        "Ok"
    )
});
app.get("/api/toggle", cors(), async(req, res) => {
    if(toggleFlag){
        res.status(200).json("True")
    }
    else{
        res.status(200).json("False")
    }
});

app.listen(PORT, () => console.log("Listening on port", PORT));