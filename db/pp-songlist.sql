CREATE DATABASE `pp-songlist`;


CREATE USER 'pp_ui_user'@'%'  IDENTIFIED BY 'l1f3s a l0ng s0ng';
GRANT ALL ON `pp-songlist`.* TO 'pp_ui_user'@'%';


--CREATE USER 'pp_ui_user'@'localhost'  IDENTIFIED BY 'l1f3s a l0ng s0ng';

FLUSH PRIVILEGES;

USE pp-songlist;
DROP TABLE IF EXISTS songlist;
CREATE TABLE songlist (
    id INT(11) NOT NULL AUTO_INCREMENT,
    artist VARCHAR(120),
    title VARCHAR(120),
    create_dt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
