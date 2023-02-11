-- TABLES
CREATE TABLE IF NOT EXISTS `druglabs` (
	`id` INT(11) NOT NULL AUTO_INCREMENT,
	`teleport_from` VARCHAR(255) NOT NULL DEFAULT '{"x": 0, "y": 0, "z": 0}',
	`teleport_to` VARCHAR(255) NOT NULL DEFAULT '{"x": 0, "y": 0, "z": 0}',
	`code` VARCHAR(255) NULL DEFAULT NULL,
	`storage_size` INT(11) NULL DEFAULT '50',
	`storage_data` LONGTEXT NULL DEFAULT '[]',
	`produce_location` VARCHAR(255) NULL DEFAULT '{"x": 0, "y": 0, "z": 0}',
	`process_location` VARCHAR(255) NULL DEFAULT '{"x": 0, "y": 0, "z": 0}',
	`managelab_location` VARCHAR(255) NULL DEFAULT '{"x": 0, "y": 0, "z": 0}',
	`buyprice` INT(11) NULL DEFAULT '0',
	`owner` VARCHAR(255) NULL DEFAULT NULL,
	PRIMARY KEY (`id`)
);

-- ITEMS
-- If you're using ox_inventory, check the file: ox.md
INSERT INTO `items` (`name`, `label`, `weight`, `rare`, `can_remove`) VALUES ('coke', 'Coke', 1, 1, 1);
INSERT INTO `items` (`name`, `label`, `weight`, `rare`, `can_remove`) VALUES ('processed_coke', 'Processed coke', 1, 1, 1);