CREATE TABLE `objs` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `xml` longtext,
  `uuid` text CHARACTER SET utf8,
  `hash` text CHARACTER SET utf8,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB;

CREATE TABLE `bobjs` (
  `obj_id` int(11) unsigned NOT NULL,
  `mat` longblob,
  PRIMARY KEY (`obj_id`),
  FOREIGN KEY (`obj_id`) REFERENCES `objs` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE `objmeta` (
  `obj_id` int(11) unsigned NOT NULL,
  `obj_type` enum('ao','collection','filterbank','matrix','mfir','miir','parfrac',
                  'pest','plist','pzmodel','rational','smodel','ssm','timespan') NOT NULL,
  `name` text CHARACTER SET utf8,
  `created` datetime DEFAULT NULL,
  `version` text CHARACTER SET utf8,
  `ip` text CHARACTER SET utf8,
  `hostname` text CHARACTER SET utf8,
  `os` text CHARACTER SET utf8,
  `submitted` datetime DEFAULT NULL,
  `experiment_title` text CHARACTER SET utf8,
  `experiment_desc` text CHARACTER SET utf8,
  `analysis_desc` text CHARACTER SET utf8,
  `quantity` text CHARACTER SET utf8,
  `additional_authors` text CHARACTER SET utf8,
  `additional_comments` text CHARACTER SET utf8,
  `keywords` text CHARACTER SET utf8,
  `reference_ids` text CHARACTER SET utf8,
  `validated` tinyint(4) DEFAULT NULL,
  `vdate` datetime DEFAULT NULL,
  `author` text CHARACTER SET utf8,
  PRIMARY KEY (`obj_id`),
  FOREIGN KEY (`obj_id`) REFERENCES `objs` (`id`) ON DELETE CASCADE,
  INDEX (`submitted`)
) ENGINE=InnoDB;

CREATE TABLE `collections` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB;

CREATE TABLE `collections2objs` (
  `id` int unsigned NOT NULL,
  `obj_id` int unsigned NOT NULL,
  PRIMARY KEY (`id`, `obj_id`),
  FOREIGN KEY (`id`) REFERENCES `collections` (`id`) ON DELETE CASCADE,
  FOREIGN KEY (`obj_id`) REFERENCES `objs` (`id`) ON DELETE CASCADE,
  INDEX (`id`),
  INDEX (`obj_id`)
) ENGINE=InnoDB;

CREATE TABLE `transactions` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `obj_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `transdate` datetime DEFAULT NULL,
  `direction` text CHARACTER SET utf8,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB;

CREATE TABLE `ao` (
  `obj_id` int(11) unsigned NOT NULL,
  `data_type` enum('cdata','tsdata','fsdata','xydata','xyzdata') NOT NULL,
  `description` text CHARACTER SET utf8,
  PRIMARY KEY (`obj_id`),
  FOREIGN KEY (`obj_id`) REFERENCES `objs` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE `cdata` (
  `obj_id` int(11) unsigned NOT NULL,
  `yunits` text CHARACTER SET utf8,
  PRIMARY KEY `obj_id` (`obj_id`),
  FOREIGN KEY (`obj_id`) REFERENCES `objs` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE `fsdata` (
  `obj_id` int(11) unsigned NOT NULL,
  `xunits` text CHARACTER SET utf8,
  `yunits` text CHARACTER SET utf8,
  `fs` double DEFAULT NULL,
  PRIMARY KEY `obj_id` (`obj_id`),
  FOREIGN KEY (`obj_id`) REFERENCES `objs` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE `tsdata` (
  `obj_id` int(11) unsigned NOT NULL,
  `xunits` text CHARACTER SET utf8,
  `yunits` text CHARACTER SET utf8,
  `fs` double DEFAULT NULL,
  `nsecs` double DEFAULT NULL,
  `t0` datetime DEFAULT NULL,
  `toffset` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY `obj_id` (`obj_id`),
  FOREIGN KEY (`obj_id`) REFERENCES `objs` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE `mfir` (
  `obj_id` int(11) unsigned NOT NULL,
  `in_file` text CHARACTER SET utf8,
  `fs` double DEFAULT NULL,
  PRIMARY KEY (`obj_id`),
  FOREIGN KEY (`obj_id`) REFERENCES `objs` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE `miir` (
  `obj_id` int(11) unsigned NOT NULL,
  `in_file` text CHARACTER SET utf8,
  `fs` double DEFAULT NULL,
  PRIMARY KEY (`obj_id`),
  FOREIGN KEY (`obj_id`) REFERENCES `objs` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE `xydata` (
  `obj_id` int(11) unsigned NOT NULL,
  `xunits` text CHARACTER SET utf8,
  `yunits` text CHARACTER SET utf8,
  PRIMARY KEY `obj_id` (`obj_id`),
  FOREIGN KEY (`obj_id`) REFERENCES `objs` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB;
