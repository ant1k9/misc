#!/usr/bin/env python3

import re
import sqlite3

from flask import Flask, request


Q_PATTERN = re.compile(r"^[\w\s]+$")

app = Flask(__name__)


@app.route("/")
def list_links() -> str:
    extra_filter = "1 = 1"
    if (q := request.args.get("q")) and Q_PATTERN.match(q):
        extra_filter = f"title LIKE '%{q}%'"
    query = (
        f"SELECT title, href FROM links WHERE is_finished = 0 AND {extra_filter} "
        "ORDER BY RANDOM() LIMIT 10"
    )

    connection = sqlite3.Connection("links.sqlite3")
    connection.row_factory = sqlite3.Row
    cursor = connection.execute(query)
    result = cursor.fetchall()

    cursor.execute(f"SELECT COUNT(1) cnt FROM links WHERE is_finished AND {extra_filter}")
    finished = cursor.fetchall()[0]['cnt']
    cursor.execute(f"SELECT COUNT(1) cnt FROM links WHERE {extra_filter}")
    total = cursor.fetchall()[0]['cnt']

    cursor.close()

    head = """
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@forevolve/bootstrap-dark@1.0.0/dist/css/bootstrap-dark.min.css" />
    <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/js/bootstrap.min.js" integrity="sha384-JjSmVgyd0p3pXB1rRibZUAYoIIy6OrQ6VrjIEaFf/nJGzIxFDsf4x0xIM+B07jRM" crossorigin="anonymous"></script>
    <script>
      const doneHandler = function(link) {
        let xhr = new XMLHttpRequest();
        xhr.open("POST", "/done");
        xhr.send([link]);
      }
    </script>
    """
    html = head + """<body><div class="container p-4 col-8">"""
    if 'android' in request.headers.get('User-Agent').lower():
        html = head + """<body><div class="container p-4 col-12">"""

    for item in result:
        title = item["title"].strip('"')
        html += f"""
        <div class="card">
          <div class="card-body text-center">
            <a href={item['href']} target="_blank">{title}</a>
            <button class="float-right btn btn-dark" onclick='doneHandler({item['href']})'>done</button>
          </div>
        </div>
        """
    if total > 0:
        html += f"""<div class="text-right">[{finished}/{total}] {100*finished/total:.3f}%</div>"""
    return html + "</div></body>"


@app.route("/done", methods=["POST"])
def done():
    request.get_data()
    connection = sqlite3.Connection("links.sqlite3")
    cursor = connection.execute(
        "UPDATE links SET is_finished = 1 WHERE href = ?",
        (f'"{request.data.decode()}"',)
    )
    connection.commit()
    cursor.close()
    return ('', 204)


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8000)
