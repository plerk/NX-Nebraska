/* 
  places schema for NX::Nebraska
  MySQL
*/

CREATE TABLE `map` (
  id CHAR(3) PRIMARY KEY,
  country_code CHAR(2),
  name VARCHAR(128)
)
ENGINE=INNODB;

INSERT INTO `map` VALUES ('top', NULL, 'World');
INSERT INTO `map` VALUES ('au1', 'au', 'Australia');
INSERT INTO `map` VALUES ('ca1', 'ca', 'Canada');
INSERT INTO `map` VALUES ('mx1', 'mx', 'Mexico');
INSERT INTO `map` VALUES ('us1', 'us', 'United States of America');
INSERT INTO `map` VALUES ('ru1', 'ru', 'Russia');
INSERT INTO `map` VALUES ('eu1', 'eu', 'Europe');

CREATE TABLE place (
  id INTEGER PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(128) NOT NULL,
  
/* references the parent in this table.  can be NULL */
  parent_id INTEGER,
  FOREIGN KEY (parent_id) REFERENCES place(id),
  
/* refrences the map table. */
  map_id CHAR(3) NOT NULL,
  FOREIGN KEY (map_id) REFERENCES `map`(id),
  
  map_code VARCHAR(10),
  flag VARCHAR(10),
  
  UNIQUE(map_id, name),
  UNIQUE(map_id, map_code)
)
ENGINE=INNODB;

INSERT INTO place (name, map_id, map_code) VALUES ('Australia', 'top', 'au');
INSERT INTO place (name, map_id, map_code) VALUES ('Canada', 'top', 'ca');
INSERT INTO place (name, map_id, map_code) VALUES ('Mexico', 'top', 'mx');
INSERT INTO place (name, map_id, map_code) VALUES ('United States of America', 'top', 'us');

CREATE TABLE integer_statistic (
  id INTEGER PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(128) NOT NULL,
  units VARCHAR(10) NOT NULL,
  is_primary BOOLEAN NOT NULL DEFAULT false
)
ENGINE=INNODB;

INSERT INTO integer_statistic (name) VALUES ('population');
INSERT INTO integer_statistic (name) VALUES ('area');

CREATE TABLE integer_value (
/* references place */
  place_id INTEGER NOT NULL,
  FOREIGN KEY (place_id) REFERENCES place(id),
/* references integer_statistic */
  integer_statistic_id INTEGER NOT NULL,
  FOREIGN KEY (integer_statistic_id) REFERENCES integer_statistic(id),

  `year` INTEGER NOT NULL,
  
  `value` INTEGER,
  
  PRIMARY KEY (place_id, integer_statistic_id, `year`)
)
ENGINE=INNODB;
