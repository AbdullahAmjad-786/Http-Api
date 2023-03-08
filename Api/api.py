from flask import Flask
import os
import psycopg2

app = Flask(__name__)

@app.route('/live')
def live():
    try:
        # Read configuration from environment variables
        port = os.getenv('PORT', 5000)
        db_url = os.getenv('DATABASE_URL')

        # Connect to the database
        conn = psycopg2.connect(db_url)
        cur = conn.cursor()

        # Check if the connection is successful
        cur.execute('SELECT 1')
        result = cur.fetchone()
        if result[0] == 1:
            return 'Well done'
        else:
            return 'Maintenance'
    except:
        return 'Maintenance'
    finally:
        cur.close()
        conn.close()

if __name__ == '__main__':
    app.run(port=port)
