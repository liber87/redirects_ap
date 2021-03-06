#
# Host: 
# Generation Time: 27-06-2020 12:33:43
# Server version: 5.5.64-MariaDB

# Description: 
#

# --------------------------------------------------------

#
# Table structure for table `{PREFIX}redirects`
#

SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
DROP TABLE IF EXISTS `{PREFIX}redirects`;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;

CREATE TABLE `{PREFIX}redirects` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `old_url` varchar(256) NOT NULL,
  `new_url` varchar(256) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

#
# Dumping data for table `{PREFIX}redirects`
#
