CREATE TABLE playlists (
    playlist_id TEXT,
    video_id    TEXT UNIQUE,
    views       INT,
    likes       INT,
    dislikes    INT,
    name        TEXT
);
