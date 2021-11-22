### Usage

Create the `commands` directory and put there bash scripts which prepare the links with given format:

```json
[
  {
    "href": "https://marcusedmondson.com/2021/07/15/to-catch-a-hacker-in-my-home-lab",
    "title": "To Catch a Hacker in My Home Lab"
  },
  ...
]
```

Run `make load` command to update the database file `links.sqlite3`.
