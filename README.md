# GDMessenger
![image](https://github.com/H3XAGON3ST-Games/GDMessenger/assets/83023800/ddf06f43-c025-4182-81ae-8ecc3280b4c7)

## The future of the project:
1. Data transfer refactoring (and add data security) - In progress
2. Database refactoring - Unstarted
3. Client and Server code refactoring - Unstarted
4. Adding Groups - Unstarted
5. Gui improvement - Unstarted
6. Adding a cache for storing messages and other things - Unstarted
7. Adding the ability to send videos and pictures (and maybe a gif as file and url) - Unstarted
8. Profile improvment and add custom data about user (such as pictures profile or "about me") - Unstarted
9. Port to android - Done
10. Port to linux - In progress

## Open Sourse Server-Client Messenger on Godot 3.5 for PC 
![image](https://github.com/H3XAGON3ST-Games/GDMessenger/assets/83023800/39be0e9b-e8a1-4a12-9f12-623d712071db)

![image](https://github.com/H3XAGON3ST-Games/GDMessenger/assets/83023800/1bb13dcb-a07c-472a-a62f-32736ba28ee0)

![image](https://github.com/H3XAGON3ST-Games/GDMessenger/assets/83023800/a1e4e709-cfb3-4732-bc7c-69b6efb21111)

## The server requires:
1. Install PostgreSQL
2. Set up a postgre user and create a database for the application
3. Make CREATE TABLE, ALTER TABLE and CREATE FUNCTION queries to the database from the gmessenger.sql file
4. Run GDMessenger to create a configuration file settings.cfg and enable the server status via is_server=true
5. Restart GDMessenger to create a db_setting.cfg configuration file and enter the database data (login, password, host, port, database name)
6. Restart GDMessenger to run server 
