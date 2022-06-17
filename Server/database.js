var sqlite3 = require('sqlite3')

const DBSOURCE = "db.sqlite"

let db = new sqlite3.Database(DBSOURCE, (err) => {
    if (err) {
        // Cannot open database
        console.error(err.message)
        throw err
    } else {
        console.log('Connected to the SQLite database.')
        db.run(`CREATE TABLE readings (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            sensor TEXT NOT NULL, 
            value DOUBLE , 
            timestamp DOUBLE NOT NULL
            )`,
            (err) => {
                if (err) {
                    // Table already created
                } else {
                    console.log("Table created successfully");

                }
            });
    }
});


module.exports = db