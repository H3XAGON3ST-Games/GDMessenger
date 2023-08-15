DROP FUNCTION 
get_user_data, 
set_user_data, 
get_user_chat_list, 
set_message_text;

DROP TABLE "user_client", 
"chat",
"user_has_chat", 
"chat_has_message";

CREATE TABLE "user_client" (
  "login_nickname" varchar(60) PRIMARY KEY NOT NULL,
  "password" varchar(60) NOT NULL
);

CREATE TABLE "chat" (
  "id" varchar(100) PRIMARY KEY NOT NULL,
  "last_user_message" varchar(200)
);

CREATE TABLE "user_has_chat" (
  "id_user" varchar(60) NOT NULL,
  "id_chat" varchar(100) NOT NULL
);

CREATE TABLE "chat_has_message" (
  "id_user" varchar(60) NOT NULL,
  "id_chat" varchar(100) NOT NULL,
  "message_text" varchar(60) NOT NULL
);

ALTER TABLE "user_has_chat" ADD FOREIGN KEY ("id_user") REFERENCES "user_client" ("login_nickname");

ALTER TABLE "user_has_chat" ADD FOREIGN KEY ("id_chat") REFERENCES "chat" ("id");

ALTER TABLE "chat_has_message" ADD FOREIGN KEY ("id_user") REFERENCES "user_client" ("login_nickname");

ALTER TABLE "chat_has_message" ADD FOREIGN KEY ("id_chat") REFERENCES "chat" ("id");

CREATE OR REPLACE FUNCTION get_user_data(IN nickname varchar)
RETURNS SETOF user_client AS $$
BEGIN
  RETURN QUERY SELECT * FROM user_client
  WHERE user_client.login_nickname = nickname;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION set_user_data(IN nickname varchar, IN pass varchar)
RETURNS void AS $$
BEGIN
  INSERT INTO user_client
  VALUES (nickname, pass);
  RETURN;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_user_chat_list(IN nickname varchar)
RETURNS SETOF user_has_chat AS $$
BEGIN
  RETURN QUERY SELECT * FROM user_has_chat 
  WHERE id_user = nickname;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION set_message_text(IN nickname varchar, IN message_text varchar, IN id_chat varchar)
RETURNS void AS $$
BEGIN
  INSERT INTO chat_has_message
  VALUES (nickname, id_chat, message_text);
  RETURN;
END;
$$ LANGUAGE plpgsql;
