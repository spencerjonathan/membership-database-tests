-- phpMyAdmin SQL Dump
-- version 4.5.4.1deb2ubuntu2
-- http://www.phpmyadmin.net
--
-- Host: localhost
-- Generation Time: Apr 26, 2018 at 08:22 AM
-- Server version: 5.7.16-0ubuntu0.16.04.1
-- PHP Version: 7.0.22-0ubuntu0.16.04.1

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


--
-- Database: `joomla`
--
CREATE DATABASE IF NOT EXISTS `joomla` DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;
USE `joomla`;

DELIMITER $$
--
-- Procedures
--
DROP PROCEDURE IF EXISTS `c1jr0_md_MemberStatusChanges`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `c1jr0_md_MemberStatusChanges` (IN `p_since` TIMESTAMP)  NO SQL
BEGIN

create TEMPORARY table `prev_join` as
select m.id, m.history_id, max(prev_m.history_id) prev_history_id FROM
  (
  SELECT
    id,
    4294967295 AS 'history_id',
    member_type_id
  FROM
    c1jr0_md_member
  UNION ALL
SELECT
  id,
  history_id,
  member_type_id
FROM
  c1jr0_md_member_history
) m,
(SELECT
  id,
  history_id,
  member_type_id
FROM
  c1jr0_md_member_history) prev_m
where m.id = prev_m.id
and m.history_id > prev_m.history_id
group by m.id, m.history_id;


select prev_join.*, m.forenames, m.surname, mt.name member_type, u.username mod_username, u.name mod_name, m.mod_date, mt2.name prev_member_type from prev_join

inner join (
  SELECT
    id,
    4294967295 AS 'history_id',
    forenames,
    surname,
    member_type_id,
    mod_user_id,
    mod_date
  FROM
    c1jr0_md_member
  UNION ALL
SELECT
  id,
  history_id,
  forenames,
  surname,
  member_type_id,
  mod_user_id,
  mod_date
FROM
  c1jr0_md_member_history
) m on (m.id = prev_join.id and m.history_id = prev_join.history_id)
inner join c1jr0_md_member_type mt on mt.id = m.member_type_id
left join c1jr0_users u on u.id = m.mod_user_id


inner join (SELECT
  id,
  history_id,
  forenames,
  surname,
  member_type_id
FROM
  c1jr0_md_member_history
) m2 on prev_join.id = m2.id and prev_history_id = m2.history_id
inner join c1jr0_md_member_type mt2 on mt2.id = m2.member_type_id

where m.member_type_id != m2.member_type_id
and m.mod_date > p_since
order by m.mod_date;

END$$

DROP PROCEDURE IF EXISTS `MemberStatusChanges`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `MemberStatusChanges` ()  NO SQL
BEGIN

DECLARE prev_id, id, history_id, tower_id INT;
DECLARE forenames, surname, member_type, prev_member_type VARCHAR(50);
DECLARE mod_date TIMESTAMP;
DECLARE tower VARCHAR(82);
DECLARE mod_user VARCHAR(150);

DECLARE cur CURSOR FOR SELECT
  m.id,
  m.history_id,
  m.forenames,
  m.surname,
  CONCAT_WS(", ",
  t.place,
  t.designation) AS 'tower',
  mt.name AS 'member_type',
  m.mod_date,
  u.username
FROM
  (
  SELECT
    id,
    0 AS 'history_id',
    forenames,
    surname,
    tower_id,
    member_type_id,
    mod_date,
    mod_user_id
  FROM
    c1jr0_md_member
  UNION ALL
SELECT
  id,
  history_id,
  forenames,
  surname,
  tower_id,
  member_type_id,
  mod_date,
  mod_user_id
FROM
  c1jr0_md_member_history
) m
INNER JOIN
  c1jr0_md_tower t ON t.id = m.tower_id
INNER JOIN
  c1jr0_md_member_type mt ON mt.id = m.member_type_id
LEFT JOIN
  c1jr0_users u ON u.id = m.mod_user_id
ORDER BY
  id,
  history_id desc;
  
  CREATE TEMPORARY TABLE `results` (
  id INT NOT NULL,
  history_id INT NULL,
  forenames VARCHAR(50) NULL,
  surname VARCHAR(50) NULL,
  tower VARCHAR(82) NULL,
  member_type VARCHAR(50) NULL,
  mod_date TIMESTAMP NULL,
  mod_user VARCHAR(150) NULL
  );
  
  OPEN cur;
  
  set prev_id = 0, prev_member_type = "";

  read_loop: LOOP
    
    select prev_id, prev_member_type;
    
    FETCH cur INTO id, history_id, forenames, surname, tower, member_type, mod_date, mod_user;
    
    IF done THEN
      LEAVE read_loop;
    END IF;
    
    if (id = prev_id and member_type != prev_member_type) THEN		insert into `results` values (id, history_id, forenames, surname, tower, member_type, mod_date, mod_user);
    end if;
    
    set prev_id = id, prev_member_type = member_type;
    
  END LOOP;
  
  select * from `results`;
  
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `c1jr0_md_district`
--

DROP TABLE IF EXISTS `c1jr0_md_district`;
CREATE TABLE `c1jr0_md_district` (
  `id` int(1) NOT NULL AUTO_INCREMENT,
  `name` varchar(25) DEFAULT NULL,
  `include_in_ar` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8;

--
-- Dumping data for table `c1jr0_md_district`
--

INSERT INTO `c1jr0_md_district` (`id`, `name`, `include_in_ar`) VALUES
(1, 'Northern District', 1),
(2, 'Southern District', 1),
(3, 'Eastern District', 1),
(4, 'Western District', 1),
(5, 'General Association', 0);

-- --------------------------------------------------------

--
-- Table structure for table `c1jr0_md_invoice`
--

DROP TABLE IF EXISTS `c1jr0_md_invoice`;
CREATE TABLE `c1jr0_md_invoice` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `tower_id` int(11) NOT NULL,
  `year` int(11) NOT NULL,
  `created_by_user_id` int(11) NOT NULL,
  `created_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `paid` tinyint(1) DEFAULT NULL,
  `paid_date` date DEFAULT NULL,
  `payment_method` varchar(15) DEFAULT NULL,
  `payment_reference` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `c1jr0_md_invoicemember`
--

DROP TABLE IF EXISTS `c1jr0_md_invoicemember`;
CREATE TABLE `c1jr0_md_invoicemember` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `invoice_id` int(11) NOT NULL,
  `member_id` int(11) NOT NULL,
  `member_type_id` int(11) NOT NULL,
  `long_service` varchar(8) NOT NULL DEFAULT 'No',
  `fee` decimal(10,0) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `c1jr0_md_member`
--

DROP TABLE IF EXISTS `c1jr0_md_member`;
CREATE TABLE `c1jr0_md_member` (
  `id` int(5) NOT NULL AUTO_INCREMENT,
  `tower_id` int(3) DEFAULT NULL,
  `forenames` varchar(50) DEFAULT NULL,
  `surname` varchar(50) DEFAULT NULL,
  `title` varchar(12) DEFAULT NULL,
  `member_type_id` int(11) NOT NULL,
  `long_service` varchar(8) NOT NULL DEFAULT 'No',
  `insurance_group` varchar(10) DEFAULT NULL,
  `annual_report` tinyint(1) DEFAULT NULL,
  `telephone` varchar(28) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `newsletters` varchar(7) DEFAULT NULL,
  `district_newsletters` int(11) NOT NULL DEFAULT '0',
  `date_elected` varchar(21) DEFAULT NULL,
  `address1` varchar(100) DEFAULT NULL,
  `address2` varchar(100) DEFAULT NULL,
  `address3` varchar(100) DEFAULT NULL,
  `town` varchar(50) DEFAULT NULL,
  `county` varchar(20) DEFAULT NULL,
  `postcode` varchar(9) DEFAULT NULL,
  `country` varchar(2) DEFAULT NULL,
  `dbs_date` varchar(10) DEFAULT NULL,
  `dbs_update` varchar(10) DEFAULT NULL,
  `mod_user_id` int(11) DEFAULT NULL,
  `mod_date` timestamp NULL DEFAULT NULL,
  `db_form_received` tinyint(1) NOT NULL DEFAULT '0',
  `accept_privicy_policy` tinyint(1) NOT NULL DEFAULT '0',
  `soudbow_subscriber` tinyint(1) NOT NULL DEFAULT '0',
  `can_publish_name` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1700 DEFAULT CHARSET=utf8;

--
-- Dumping data for table `c1jr0_md_member`
--

INSERT INTO `c1jr0_md_member` (`id`, `tower_id`, `forenames`, `surname`, `title`, `member_type_id`, `long_service`, `insurance_group`, `annual_report`, `telephone`, `email`, `newsletters`, `district_newsletters`, `date_elected`, `address1`, `address2`, `address3`, `town`, `county`, `postcode`, `country`, `dbs_date`, `dbs_update`, `mod_user_id`, `mod_date`, `db_form_received`, `accept_privicy_policy`, `soudbow_subscriber`, `can_publish_name`) VALUES
(8, 19, 'Fred', 'Blogs', 'Mr', 1, 'No', '16-70', 0, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '05-Feb-13', '28-Oct-14', NULL, NULL, 1, 0, 0, NULL),
(10, 118, 'Fred', 'Blogs', 'Mr', 1, 'No', '16-70', 1, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', 850, '2017-12-18 18:43:16', 1, 0, 0, NULL),
(14, 103, 'Fred', 'Blogs', 'Mr', 1, 'No', '16-70', 0, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', NULL, NULL, 1, 0, 0, NULL),
(16, 86, 'Fred', 'Blogs', 'Mr', 1, 'No', 'Over 70', 1, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '01-Jan-12', '', NULL, NULL, 1, 0, 0, NULL),
(18, 150, 'Fred', 'Blogs', 'Mr', 1, 'No', 'Over 70', 1, '01234 567 890', 'fred@blogs.com', 'Both', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', NULL, NULL, 1, 0, 0, NULL),
(22, 135, 'Fred', 'Blogs', 'Mr', 1, 'No', '16-70', 1, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '2013-01-25', '0000-00-00', -28, '2018-01-02 14:28:13', 1, 0, 0, NULL),
(23, 135, 'Fred', 'Blogs', 'Mr', 1, 'No', '16-70', 1, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '08-Aug-13', '', NULL, NULL, 1, 0, 0, NULL),
(25, 54, 'Fred', 'Blogs', 'Mr', 1, 'No', '16-70', 0, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', NULL, NULL, 1, 0, 0, NULL),
(26, 54, 'Fred', 'Blogs', 'Mr', 1, 'No', '16-70', 0, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', NULL, NULL, 1, 0, 0, NULL),
(28, 139, 'Fred', 'Blogs', 'Mr', 1, 'No', 'Over 70', 1, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', NULL, NULL, 1, 0, 0, NULL),
(31, 53, 'Fred', 'Blogs', 'Mr', 1, '50 Years', 'Over 70', 0, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', NULL, NULL, 1, 0, 0, NULL),
(52, 51, 'Fred', 'Blogs', 'Mr', 1, 'No', '16-70', 1, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '09-Apr-13', '', NULL, NULL, 1, 0, 0, NULL),
(53, 5, 'Fred', 'Blogs', 'Mr', 1, 'No', '16-70', 1, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '11-Feb-11', '', NULL, NULL, 1, 0, 0, NULL),
(54, 5, 'Fred', 'Blogs', 'Mr', 1, 'No', '16-70', 0, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '11-Feb-11', '11-Feb-11', NULL, NULL, 1, 0, 0, NULL),
(56, 142, 'Fred', 'Blogs', 'Mr', 1, 'No', 'Over 70', 1, '01234 567 890', 'fred@blogs.com', 'Postal', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '01-Jan-07', '', NULL, NULL, 1, 0, 0, NULL),
(57, 15, 'Fred', 'Blogs', 'Mr', 3, 'No', 'Over 70', 1, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', NULL, NULL, 1, 0, 0, NULL),
(64, 59, 'Fred', 'Blogs', 'Mr', 1, '50 Years', '16-70', 1, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '25-Mar-15', '25-Mar-16', NULL, NULL, 1, 0, 0, NULL),
(65, 59, 'Fred', 'Blogs', 'Mr', 1, 'No', '16-70', 1, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', 844, '2017-12-18 12:08:12', 1, 0, 0, NULL),
(70, 3, 'Fred', 'Blogs', 'Mr', 1, 'No', '16-70', 1, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '17-Jul-14', '', NULL, NULL, 1, 0, 0, NULL),
(78, 95, 'Fred', 'Blogs', 'Mr', 1, 'No', '16-70', 1, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '02-Aug-16', '', NULL, NULL, 1, 0, 0, NULL),
(79, 95, 'Fred', 'Blogs', 'Mr', 1, '50 Years', 'Over 70', 1, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '02-Aug-16', '', NULL, NULL, 1, 0, 0, NULL),
(85, 68, 'Fred', 'Blogs', 'Mr', 1, 'No', 'Over 70', 1, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', NULL, NULL, 1, 0, 0, NULL),
(95, 143, 'Fred', 'Blogs', 'Mr', 1, 'No', 'Over 70', 1, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', NULL, NULL, 1, 0, 0, NULL),
(99, 143, 'Fred', 'Blogs', 'Mr', 1, 'No', 'Over 70', 1, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '03-Aug-15', '', NULL, NULL, 1, 0, 0, NULL),
(105, 120, 'Fred', 'Blogs', 'Mr', 1, '50 Years', 'Over 70', 1, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '02-Aug-13', NULL, NULL, 1, 0, 0, NULL),
(110, 120, 'Fred', 'Blogs', 'Mr', 1, 'No', '16-70', 0, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '29-Jul-13', '', NULL, NULL, 1, 0, 0, NULL),
(112, 99, 'Fred', 'Blogs', 'Mr', 1, 'No', 'Over 70', 1, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', NULL, NULL, 1, 0, 0, NULL),
(116, 146, 'Fred', 'Blogs', 'Mr', 1, 'No', 'Over 70', 0, '01234 567 890', 'fred@blogs.com', 'Postal', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', NULL, NULL, 1, 0, 0, NULL),
(129, 35, 'Fred', 'Blogs', 'Mr', 1, 'No', 'Over 70', 1, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', NULL, NULL, 1, 0, 0, NULL),
(135, 76, 'Fred', 'Blogs', 'Mr', 1, 'No', '16-70', 1, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '23-Jan-13', '01-Nov-15', NULL, NULL, 1, 0, 0, NULL),
(142, 48, 'Fred', 'Blogs', 'Mr', 1, 'No', '16-70', 1, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', NULL, NULL, 1, 0, 0, NULL),
(145, 99, 'Fred', 'Blogs', 'Mr', 1, 'No', 'Over 70', 1, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '01-Jan-12', '', NULL, NULL, 1, 0, 0, NULL),
(146, 114, 'Fred', 'Blogs', 'Mr', 1, 'No', 'Over 70', 1, '01234 567 890', 'fred@blogs.com', 'Neither', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', NULL, NULL, 1, 0, 0, NULL),
(161, 97, 'Fred', 'Blogs', 'Mr', 1, 'No', '16-70', 0, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', NULL, NULL, 1, 0, 0, NULL),
(165, 124, 'Fred', 'Blogs', 'Mr', 1, 'No', '16-70', 1, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', 838, '2017-07-10 19:54:50', 1, 0, 0, NULL),
(173, 141, 'Fred', 'Blogs', 'Mr', 1, 'No', 'Over 70', 0, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', NULL, NULL, 1, 0, 0, NULL),
(175, 141, 'Fred', 'Blogs', 'Mr', 1, 'No', 'Over 70', 1, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '03-Jan-17', NULL, NULL, 1, 0, 0, NULL),
(176, 34, 'Fred', 'Blogs', 'Mr', 1, 'No', 'Over 70', 1, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', NULL, NULL, 1, 0, 0, NULL),
(178, 34, 'Fred', 'Blogs', 'Mr', 1, 'No', '16-70', 1, '01234 567 890', 'fred@blogs.com', 'Postal', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', NULL, NULL, 1, 0, 0, NULL),
(190, 105, 'Fred', 'Blogs', 'Mr', 4, 'No', '', 0, '01234 567 890', 'fred@blogs.com', 'Neither', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', NULL, NULL, 1, 0, 0, NULL),
(194, 82, 'Fred', 'Blogs', 'Mr', 1, 'No', '16-70', 0, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', 860, '2017-12-16 22:35:41', 1, 0, 0, NULL),
(196, 82, 'Fred', 'Blogs', 'Mr', 1, 'No', 'Over 70', 1, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '24-Mar-13', '', 860, '2017-12-16 22:35:11', 1, 0, 0, NULL),
(199, 82, 'Fred', 'Blogs', 'Mr', 1, 'No', '16-70', 1, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', 860, '2017-12-16 22:36:07', 1, 0, 0, NULL),
(200, 82, 'Fred', 'Blogs', 'Mr', 1, 'No', '16-70', 0, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', 860, '2017-12-16 22:34:50', 1, 0, 0, NULL),
(202, 72, 'Fred', 'Blogs', 'Mr', 1, 'No', 'Over 70', 1, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '09-Mar-15', '01-Jan-16', NULL, NULL, 1, 0, 0, NULL),
(209, 142, 'Fred', 'Blogs', 'Mr', 1, 'No', '16-70', 1, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', NULL, NULL, 1, 0, 0, NULL),
(223, 121, 'Fred', 'Blogs', 'Mr', 1, 'No', 'Over 70', 1, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '19-Nov-13', '21-Oct-16', NULL, NULL, 1, 0, 0, NULL),
(225, 121, 'Fred', 'Blogs', 'Mr', 1, 'No', '16-70', 1, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '08-Nov-13', '07-Nov-16', NULL, NULL, 1, 0, 0, NULL),
(230, 16, 'Fred', 'Blogs', 'Mr', 1, 'No', '16-70', 0, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', NULL, NULL, 1, 0, 0, NULL),
(231, 16, 'Fred', 'Blogs', 'Mr', 1, 'No', '16-70', 1, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '06-Oct-14', '', NULL, NULL, 1, 0, 0, NULL),
(235, 85, 'Fred', 'Blogs', 'Mr', 1, 'No', 'Over 70', 1, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '30-Jul-07', '', NULL, NULL, 1, 0, 0, NULL),
(236, 39, 'Fred', 'Blogs', 'Mr', 1, 'No', '16-70', 0, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', NULL, NULL, 1, 0, 0, NULL),
(238, 55, 'Fred', 'Blogs', 'Mr', 1, 'No', '16-70', 0, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', NULL, NULL, 1, 0, 0, NULL),
(246, 36, 'Fred', 'Blogs', 'Mr', 1, 'No', 'Over 70', 1, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', NULL, NULL, 1, 0, 0, NULL),
(248, 36, 'Fred', 'Blogs', 'Mr', 1, '50 Years', 'Over 70', 1, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '18-Mar-11', '', NULL, NULL, 1, 0, 0, NULL),
(255, 106, 'Fred', 'Blogs', 'Mr', 1, 'No', '16-70', 1, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', NULL, NULL, 1, 0, 0, NULL),
(258, 63, 'Fred', 'Blogs', 'Mr', 1, 'No', '16-70', 0, '01234 567 890', 'fred@blogs.com', 'Postal', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', NULL, NULL, 1, 0, 0, NULL),
(260, 138, 'Fred', 'Blogs', 'Mr', 1, 'No', '16-70', 1, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', NULL, NULL, 1, 0, 0, NULL),
(261, 138, 'Fred', 'Blogs', 'Mr', 1, 'No', '16-70', 1, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '08-Sep-14', '', NULL, NULL, 1, 0, 0, NULL),
(262, 138, 'Fred', 'Blogs', 'Mr', 1, 'No', '16-70', 1, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', NULL, NULL, 1, 0, 0, NULL),
(264, 138, 'Fred', 'Blogs', 'Mr', 1, '50 Years', 'Over 70', 0, '01234 567 890', 'fred@blogs.com', 'Postal', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', 'Surrey', 'EC1 ABC', '', '', '', NULL, NULL, 1, 0, 0, NULL),
(265, 138, 'Fred', 'Blogs', 'Mr', 3, 'No', 'Over 70', 1, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', NULL, NULL, 1, 0, 0, NULL),
(266, 138, 'Fred', 'Blogs', 'Mr', 3, 'No', 'Over 70', 1, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', NULL, NULL, 1, 0, 0, NULL),
(267, 138, 'Fred', 'Blogs', 'Mr', 3, 'No', 'Over 70', 1, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '01-Apr-16', '', NULL, NULL, 1, 0, 0, NULL),
(268, 138, 'Fred', 'Blogs', 'Mr', 1, 'No', '16-70', 1, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', NULL, NULL, 1, 0, 0, NULL),
(269, 138, 'Fred', 'Blogs', 'Mr', 1, 'No', '16-70', 1, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', NULL, NULL, 1, 0, 0, NULL),
(274, 63, 'Fred', 'Blogs', 'Mr', 1, 'No', '16-70', 0, '01234 567 890', 'fred@blogs.com', 'Postal', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', NULL, NULL, 1, 0, 0, NULL),
(275, 115, 'Fred', 'Blogs', 'Mr', 1, 'No', '16-70', 1, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '20-Mar-14', '', NULL, NULL, 1, 0, 0, NULL),
(285, 140, 'Fred', 'Blogs', 'Mr', 1, 'No', 'Over 70', 1, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', NULL, NULL, 1, 0, 0, NULL),
(286, 140, 'Fred', 'Blogs', 'Mr', 1, '50 Years', 'Over 70', 1, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', 'West Sussex', 'EC1 ABC', '', '', '', NULL, NULL, 1, 0, 0, NULL),
(292, 43, 'Fred', 'Blogs', 'Mr', 1, 'No', 'Over 70', 1, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', NULL, NULL, 1, 0, 0, NULL),
(303, 77, 'Fred', 'Blogs', 'Mr', 1, 'No', '16-70', 1, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '11-Jul-12', '09-Feb-17', NULL, NULL, 1, 0, 0, NULL),
(304, 73, 'Fred', 'Blogs', 'Mr', 1, 'No', '16-70', 1, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '01-Jan-12', '01-Jan-13', NULL, NULL, 1, 0, 0, NULL),
(305, 73, 'Fred', 'Blogs', 'Mr', 3, 'No', 'Over 70', 1, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '13-Feb-13', '', NULL, NULL, 1, 0, 0, NULL),
(315, 30, 'Fred', 'Blogs', 'Mr', 1, 'No', 'Over 70', 0, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '2013-04-01', '2017-02-04', 902, '2018-01-02 15:05:08', 1, 0, 0, NULL),
(316, 30, 'Fred', 'Blogs', 'Mr', 1, 'No', '16-70', 1, '01234 567 890', 'fred@blogs.com', 'Postal', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '01-Apr-13', '04-Feb-17', NULL, NULL, 1, 0, 0, NULL),
(319, 100, 'Fred', 'Blogs', 'Mr', 1, 'No', '16-70', 1, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '01-Jan-16', '06-May-16', NULL, NULL, 1, 0, 0, NULL),
(325, 100, 'Fred', 'Blogs', 'Mr', 1, 'No', '16-70', 1, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '01-Jan-16', NULL, NULL, 1, 0, 0, NULL),
(327, 23, 'Fred', 'Blogs', 'Mr', 1, 'No', '16-70', 1, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '02-Aug-16', '', NULL, NULL, 1, 0, 0, NULL),
(331, 22, 'Fred', 'Blogs', 'Mr', 1, 'No', 'Over 70', 1, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', NULL, NULL, 1, 0, 0, NULL),
(333, 67, 'Fred', 'Blogs', 'Mr', 1, 'No', '16-70', 1, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '11-Feb-09', '', NULL, NULL, 1, 0, 0, NULL),
(335, 12, 'Fred', 'Blogs', 'Mr', 1, 'No', '16-70', 1, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', NULL, NULL, 1, 0, 0, NULL),
(336, 89, 'Fred', 'Blogs', 'Mr', 1, 'No', '16-70', 1, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', NULL, NULL, 1, 0, 0, NULL),
(337, 89, 'Fred', 'Blogs', 'Mr', 1, 'No', 'Over 70', 1, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '01-Aug-16', '01-Nov-12', NULL, NULL, 1, 0, 0, NULL),
(342, 92, 'Fred', 'Blogs', 'Mr', 1, 'No', '16-70', 0, '01234 567 890', 'fred@blogs.com', 'Postal', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', NULL, NULL, 1, 0, 0, NULL),
(344, 116, 'Fred', 'Blogs', 'Mr', 1, 'No', '16-70', 0, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', NULL, NULL, 1, 0, 0, NULL),
(346, 38, 'Fred', 'Blogs', 'Mr', 1, 'No', '16-70', 0, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', NULL, NULL, 1, 0, 0, NULL),
(351, 46, 'Fred', 'Blogs', 'Mr', 1, 'No', 'Over 70', 1, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', NULL, NULL, 1, 0, 0, NULL),
(354, 12, 'Fred', 'Blogs', 'Mr', 1, 'No', '16-70', 1, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', NULL, NULL, 1, 0, 0, NULL),
(367, 137, 'Fred', 'Blogs', 'Mr', 1, 'No', '16-70', 0, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', NULL, NULL, 1, 0, 0, NULL),
(375, 79, 'Fred', 'Blogs', 'Mr', 1, 'No', '16-70', 1, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '2015-08-01', '2015-08-01', 838, '2017-12-31 17:11:55', 1, 0, 0, NULL),
(377, 93, 'Fred', 'Blogs', 'Mr', 1, 'No', 'Over 70', 1, '01234 567 890', 'fred@blogs.com', 'Postal', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '24-Feb-16', '24-Feb-16', NULL, NULL, 1, 0, 0, NULL),
(378, 145, 'Fred', 'Blogs', 'Mr', 1, 'No', '16-70', 1, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', NULL, NULL, 1, 0, 0, NULL),
(384, 79, 'Fred', 'Blogs', 'Mr', 1, 'No', '16-70', 1, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', NULL, NULL, 1, 0, 0, NULL),
(388, 88, 'Fred', 'Blogs', 'Mr', 1, 'No', '16-70', 1, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', NULL, NULL, 1, 0, 0, NULL),
(390, 119, 'Fred', 'Blogs', 'Mr', 1, 'No', '16-70', 1, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', NULL, NULL, 1, 0, 0, NULL),
(391, 119, 'Fred', 'Blogs', 'Mr', 3, 'No', '16-70', 1, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '01-Jan-17', '24-Mar-12', NULL, NULL, 1, 0, 0, NULL),
(392, 26, 'Fred', 'Blogs', 'Mr', 1, 'No', '16-70', 1, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', NULL, NULL, 1, 0, 0, NULL),
(396, 26, 'Fred', 'Blogs', 'Mr', 1, 'No', '16-70', 0, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', NULL, NULL, 1, 0, 0, NULL),
(401, 11, 'Fred', 'Blogs', 'Mr', 3, 'No', 'Over 70', 0, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', NULL, NULL, 1, 0, 0, NULL),
(412, 112, 'Fred', 'Blogs', 'Mr', 1, 'No', '16-70', 1, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', NULL, NULL, 1, 0, 0, NULL),
(415, 148, 'Fred', 'Blogs', 'Mr', 1, 'No', '16-70', 1, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', NULL, NULL, 1, 0, 0, NULL),
(418, 148, 'Fred', 'Blogs', 'Mr', 1, 'No', '16-70', 0, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', NULL, NULL, 1, 0, 0, NULL),
(430, 81, 'Fred', 'Blogs', 'Mr', 1, 'No', '16-70', 1, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '2013-01-01', '2016-05-01', -25, '2017-12-30 10:03:39', 1, 1, 0, NULL),
(431, 81, 'Fred', 'Blogs', 'Mr', 1, 'No', '16-70', 0, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', -25, '2017-12-30 10:03:02', 1, 1, 0, NULL),
(437, 149, 'Fred', 'Blogs', 'Mr', 1, 'No', '16-70', 0, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '09-Jun-14', '', NULL, NULL, 1, 0, 0, NULL),
(438, 149, 'Fred', 'Blogs', 'Mr', 1, 'No', '16-70', 1, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '12-Jul-12', '', NULL, NULL, 1, 0, 0, NULL),
(444, 33, 'Fred', 'Blogs', 'Mr', 1, 'No', 'Over 70', 1, '01234 567 890', 'fred@blogs.com', 'Postal', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', NULL, NULL, 1, 0, 0, NULL),
(450, 104, 'Fred', 'Blogs', 'Mr', 1, 'No', '16-70', 1, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', -11, '2017-12-11 15:24:21', 1, 1, 0, NULL),
(451, 4, 'Fred', 'Blogs', 'Mr', 1, 'No', '16-70', 1, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', NULL, NULL, 1, 0, 0, NULL),
(455, 110, 'Fred', 'Blogs', 'Mr', 1, 'No', '16-70', 1, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', NULL, NULL, 1, 0, 0, NULL),
(467, 15, 'Fred', 'Blogs', 'Mr', 1, '50 Years', '16-70', 1, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', NULL, NULL, 1, 0, 0, NULL),
(475, 46, 'Fred', 'Blogs', 'Mr', 1, 'No', '16-70', 1, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', 838, '2017-09-15 14:11:40', 1, 0, 0, NULL),
(476, 134, 'Fred', 'Blogs', 'Mr', 1, 'No', 'Over 70', 1, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', NULL, NULL, 1, 0, 0, NULL),
(478, 88, 'Fred', 'Blogs', 'Mr', 1, 'No', 'Over 70', 1, '01234 567 890', 'fred@blogs.com', 'Neither', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', -17, '2017-12-18 09:21:09', 1, 1, 0, NULL),
(481, 134, 'Fred', 'Blogs', 'Mr', 1, 'No', 'Over 70', 1, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', NULL, NULL, 1, 0, 0, NULL),
(489, 108, 'Fred', 'Blogs', 'Mr', 1, 'No', '16-70', 1, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '17-Jul-13', '', NULL, NULL, 1, 0, 0, NULL),
(494, 136, 'Fred', 'Blogs', 'Mr', 1, 'No', 'Over 70', 1, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', NULL, NULL, 1, 0, 0, NULL),
(496, 136, 'Fred', 'Blogs', 'Mr', 1, 'No', '16-70', 1, '01234 567 890', 'fred@blogs.com', 'Postal', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', NULL, NULL, 1, 0, 0, NULL),
(500, 7, 'Peter', 'Rabbit', 'Mr', 1, 'No', '16-70', 0, '01234 567 890', 'peter@rabbit.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', NULL, NULL, 1, 0, 0, NULL),
(502, 2, 'Fred', 'Blogs', 'Mr', 1, 'No', '16-70', 1, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', NULL, NULL, 1, 0, 0, NULL),
(505, 31, 'Fred', 'Blogs', 'Mr', 1, 'No', '16-70', 1, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '01-May-11', '', NULL, NULL, 1, 0, 0, NULL),
(506, 31, 'Fred', 'Blogs', 'Mr', 1, 'No', '16-70', 0, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '21-Apr-11', '', NULL, NULL, 1, 0, 0, NULL),
(510, 10, 'Fred', 'Blogs', 'Mr', 1, 'No', 'Over 70', 0, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', 'West Sussex', 'EC1 ABC', '', '', '', NULL, NULL, 1, 0, 0, NULL),
(535, 64, 'Fred', 'Blogs', 'Mr', 1, 'No', '16-70', 1, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '01-Feb-16', '', NULL, NULL, 1, 0, 0, NULL),
(536, 117, 'Fred', 'Blogs', 'Mr', 1, 'No', '16-70', 1, '01234 567 890', 'fred@blogs.com', 'Neither', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', NULL, NULL, 1, 0, 0, NULL),
(538, 138, 'Fred', 'Blogs', 'Mr', 1, '50 Years', 'Over 70', 1, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', NULL, NULL, 1, 0, 0, NULL),
(539, 138, 'Fred', 'Blogs', 'Mr', 1, '50 Years', 'Over 70', 0, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', NULL, NULL, 1, 0, 0, NULL),
(545, 65, 'Fred', 'Blogs', 'Mr', 1, 'No', '16-70', 1, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '29-Oct-16', '', NULL, NULL, 1, 0, 0, NULL),
(549, 69, 'Fred', 'Blogs', 'Mr', 1, 'No', '16-70', 1, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', NULL, NULL, 1, 0, 0, NULL),
(550, 69, 'Fred', 'Blogs', 'Mr', 1, 'No', '16-70', 1, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', NULL, NULL, 1, 0, 0, NULL),
(551, 122, 'Fred', 'Blogs', 'Mr', 1, 'No', 'Over 70', 0, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', NULL, NULL, 1, 0, 0, NULL),
(553, 109, 'Fred', 'Blogs', 'Mr', 1, 'No', '16-70', 0, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', NULL, NULL, 1, 0, 0, NULL),
(561, 39, 'Fred', 'Blogs', 'Mr', 1, 'No', '16-70', 1, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '02-Dec-07', '', NULL, NULL, 1, 0, 0, NULL),
(566, 35, 'Fred', 'Blogs', 'Mr', 1, 'No', '16-70', 1, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', NULL, NULL, 1, 0, 0, NULL),
(567, 123, 'Fred', 'Blogs', 'Mr', 1, 'No', 'Over 70', 1, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', NULL, NULL, 1, 0, 0, NULL),
(569, 107, 'Fred', 'Blogs', 'Mr', 1, 'No', 'Over 70', 1, '01234 567 890', 'fred@blogs.com', 'Postal', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', NULL, NULL, 1, 0, 0, NULL),
(579, 13, 'Fred', 'Blogs', 'Mr', 1, 'No', 'Over 70', 1, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', NULL, NULL, 1, 0, 0, NULL),
(589, 72, 'Fred', 'Blogs', 'Mr', 1, 'No', '16-70', 1, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', NULL, NULL, 1, 0, 0, NULL),
(600, 76, 'Fred', 'Blogs', 'Mr', 1, 'No', '16-70', 1, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '07-Jul-16', '', NULL, NULL, 1, 0, 0, NULL),
(612, 57, 'Fred', 'Blogs', 'Mr', 1, 'No', '16-70', 1, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', NULL, NULL, 1, 0, 0, NULL),
(620, 18, 'Fred', 'Blogs', 'Mr', 1, 'No', '16-70', 0, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '11-Apr-16', '', NULL, NULL, 1, 0, 0, NULL),
(629, 123, 'Fred', 'Blogs', 'Mr', 1, 'No', 'Over 70', 1, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', NULL, NULL, 1, 0, 0, NULL),
(630, 18, 'Fred', 'Blogs', 'Mr', 1, 'No', '16-70', 1, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', NULL, NULL, 1, 0, 0, NULL),
(632, 113, 'Fred', 'Blogs', 'Mr', 1, '50 Years', 'Over 70', 1, '01234 567 890', 'fred@blogs.com', 'Postal', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', NULL, NULL, 1, 0, 0, NULL),
(641, 61, 'Fred', 'Blogs', 'Mr', 1, 'No', '16-70', 1, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '01-Jun-15', '', NULL, NULL, 1, 0, 0, NULL),
(649, 37, 'Fred', 'Blogs', 'Mr', 1, 'No', 'Over 70', 0, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '01-Jan-15', '', NULL, NULL, 1, 0, 0, NULL),
(653, 147, 'Fred', 'Blogs', 'Mr', 1, 'No', 'Over 70', 0, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', NULL, NULL, 1, 0, 0, NULL),
(660, 77, 'Fred', 'Blogs', 'Mr', 1, 'No', '16-70', 1, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', NULL, NULL, 1, 0, 0, NULL),
(675, 49, 'Fred', 'Blogs', 'Mr', 1, 'No', 'Over 70', 0, '01234 567 890', 'fred@blogs.com', 'Postal', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', NULL, NULL, 1, 0, 0, NULL),
(684, 116, 'Fred', 'Blogs', 'Mr', 1, 'No', 'Over 70', 1, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '23-Jun-15', '', NULL, NULL, 1, 0, 0, NULL),
(693, 111, 'Fred', 'Blogs', 'Mr', 1, 'No', '16-70', 1, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', NULL, NULL, 1, 0, 0, NULL),
(694, 111, 'Fred', 'Blogs', 'Mr', 1, 'No', '16-70', 0, '01234 567 890', 'fred@blogs.com', 'Neither', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '2014-12-01', '', 838, '2017-12-17 22:28:39', 1, 0, 0, NULL),
(697, 98, 'Fred', 'Blogs', 'Mr', 1, 'No', '16-70', 0, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', NULL, NULL, 1, 0, 0, NULL),
(711, 138, 'Fred', 'Blogs', 'Mr', 1, '50 Years', 'Over 70', 1, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '10-Apr-15', '', NULL, NULL, 1, 0, 0, NULL),
(718, 103, 'Fred', 'Blogs', 'Mr', 1, 'No', 'Over 70', 0, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', NULL, NULL, 1, 0, 0, NULL),
(721, 51, 'Fred', 'Blogs', 'Mr', 1, 'No', '16-70', 1, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', NULL, NULL, 1, 0, 0, NULL),
(731, 85, 'Fred', 'Blogs', 'Mr', 1, 'No', '16-70', 0, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '14-Feb-14', '16-Jun-16', NULL, NULL, 1, 0, 0, NULL),
(734, 146, 'Fred', 'Blogs', 'Mr', 1, 'No', '16-70', 0, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', 838, '2017-07-22 11:15:57', 1, 0, 0, NULL),
(736, 117, 'Fred', 'Blogs', 'Mr', 1, 'No', '16-70', 1, '01234 567 890', 'fred@blogs.com', 'Postal', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', NULL, NULL, 1, 0, 0, NULL),
(737, 82, 'Miny', 'Mouse', 'Miss', 1, 'No', 'Over 70', 1, '01234 567 890', 'mini@mouse.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', 860, '2017-12-16 22:32:52', 1, 0, 0, NULL),
(746, 20, 'Fred', 'Blogs', 'Mr', 1, 'No', 'Over 70', 1, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', NULL, NULL, 1, 0, 0, NULL),
(753, 28, 'Fred', 'Blogs', 'Mr', 1, 'No', '16-70', 0, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', NULL, NULL, 1, 0, 0, NULL),
(754, 28, 'Fred', 'Blogs', 'Mr', 1, 'No', '16-70', 1, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', NULL, NULL, 1, 0, 0, NULL),
(760, 38, 'Fred', 'Blogs', 'Mr', 1, 'No', 'Over 70', 0, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', NULL, NULL, 1, 0, 0, NULL),
(766, 133, 'Fred', 'Blogs', 'Mr', 1, 'No', '16-70', 1, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', NULL, NULL, 1, 0, 0, NULL),
(767, 41, 'Fred', 'Blogs', 'Mr', 1, 'No', 'Over 70', 1, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', NULL, NULL, 1, 0, 0, NULL),
(769, 21, 'Fred', 'Blogs', 'Mr', 1, 'No', '16-70', 1, '01234 567 890', 'fred@blogs.com', 'Postal', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', NULL, NULL, 1, 0, 0, NULL),
(771, 19, 'Fred', 'Blogs', 'Mr', 1, 'No', '16-70', 1, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '2016-11-2', '', 841, '2017-07-18 09:58:01', 1, 0, 0, NULL),
(772, 45, 'Fred', 'Blogs', 'Mr', 1, 'No', 'Over 70', 1, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '01-Jan-16', '01-Jan-16', NULL, NULL, 1, 0, 0, NULL),
(779, 40, 'Fred', 'Blogs', 'Mr', 1, 'No', 'Over 70', 1, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '01-Jan-14', '', NULL, NULL, 1, 0, 0, NULL),
(791, 109, 'Fred', 'Blogs', 'Mr', 1, 'No', '16-70', 1, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', NULL, NULL, 1, 0, 0, NULL),
(793, 27, 'Fred', 'Blogs', 'Mr', 1, 'No', '16-70', 1, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', 863, '2017-12-11 17:04:36', 1, 0, 0, NULL),
(795, 128, 'Fred', 'Blogs', 'Mr', 1, 'No', '16-70', 0, '01234 567 890', 'fred@blogs.com', 'Postal', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', NULL, NULL, 1, 0, 0, NULL),
(816, 107, 'Fred', 'Blogs', 'Mr', 1, 'No', 'Over 70', 1, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', NULL, NULL, 1, 0, 0, NULL),
(834, 43, 'Fred', 'Blogs', 'Mr', 1, 'No', '16-70', 1, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', NULL, NULL, 1, 0, 0, NULL),
(839, 1, 'Fred', 'Blogs', 'Mr', 1, 'No', 'Over 70', 0, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', NULL, NULL, 1, 0, 0, NULL),
(844, 82, 'Fred', 'Blogs', 'Mr', 1, 'No', '16-70', 0, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', 860, '2017-12-16 22:34:29', 1, 0, 0, NULL),
(854, 90, 'Fred', 'Blogs', 'Mr', 1, 'No', '16-70', 1, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', NULL, NULL, 1, 0, 0, NULL),
(858, 90, 'Fred', 'Blogs', 'Mr', 1, 'No', '16-70', 1, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', 865, '2017-12-20 13:13:29', 1, 0, 0, NULL),
(860, 58, 'Fred', 'Blogs', 'Mr', 1, 'No', '16-70', 1, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', NULL, NULL, 1, 0, 0, NULL),
(863, 58, 'Fred', 'Blogs', 'Mr', 1, 'No', 'Over 70', 1, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', NULL, NULL, 1, 0, 0, NULL),
(874, 3, 'Fred', 'Blogs', 'Mr', 1, 'No', '16-70', 1, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', NULL, NULL, 1, 0, 0, NULL),
(881, 126, 'Fred', 'Blogs', 'Mr', 1, 'No', '16-70', 1, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', NULL, NULL, 1, 0, 0, NULL),
(887, 50, 'Fred', 'Blogs', 'Mr', 1, 'No', '16-70', 0, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', 838, '2017-08-24 20:37:03', 1, 0, 0, NULL),
(901, 138, 'Fred', 'Blogs', 'Mr', 1, 'No', '16-70', 0, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '04-Apr-15', '01-Feb-15', NULL, NULL, 1, 0, 0, NULL),
(919, 138, 'Fred', 'Blogs', 'Mr', 1, 'No', '16-70', 1, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '11-Feb-15', '', NULL, NULL, 1, 0, 0, NULL),
(920, 82, 'Fred', 'Blogs', 'Mr', 1, 'No', '16-70', 0, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', 860, '2017-12-16 22:36:40', 1, 0, 0, NULL),
(922, 113, 'Fred', 'Blogs', 'Mr', 1, 'No', '16-70', 1, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', NULL, NULL, 1, 0, 0, NULL),
(923, 87, 'Fred', 'Blogs', 'Mr', 1, 'No', '16-70', 0, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', NULL, NULL, 1, 0, 0, NULL),
(928, 124, 'Fred', 'Blogs', 'Mr', 1, 'No', '16-70', 0, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', NULL, NULL, 1, 0, 0, NULL),
(942, 138, 'Fred', 'Blogs', 'Mr', 1, 'No', '16-70', 1, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', 'West Sussex', 'EC1 ABC', '', '25-Feb-15', '01-Feb-15', NULL, NULL, 1, 0, 0, NULL),
(943, 138, 'Fred', 'Blogs', 'Mr', 1, 'No', '16-70', 1, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', NULL, NULL, 1, 0, 0, NULL),
(960, 127, 'Fred', 'Blogs', 'Mr', 1, 'No', '16-70', 1, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', NULL, NULL, 1, 0, 0, NULL),
(962, 92, 'Fred', 'Blogs', 'Mr', 1, 'No', '16-70', 0, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', NULL, NULL, 1, 0, 0, NULL),
(964, 37, 'Fred', 'Blogs', 'Mr', 1, 'No', '16-70', 0, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', NULL, NULL, 1, 0, 0, NULL),
(970, 87, 'Fred', 'Blogs', 'Mr', 1, 'No', 'Over 70', 1, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', NULL, NULL, 1, 0, 0, NULL),
(973, 60, 'Fred', 'Blogs', 'Mr', 1, 'No', '16-70', 1, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '12-Jan-15', '', NULL, NULL, 1, 0, 0, NULL),
(980, 70, 'Fred', 'Blogs', 'Mr', 1, 'No', '16-70', 1, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', NULL, NULL, 1, 0, 0, NULL),
(998, 62, 'Fred', 'Blogs', 'Mr', 4, 'No', '', 0, '01234 567 890', 'fred@blogs.com', 'Neither', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', NULL, NULL, 1, 0, 0, NULL),
(1044, 138, 'Fred', 'Blogs', 'Mr', 5, 'No', '16-70', 0, '01234 567 890', 'fred@blogs.com', 'Neither', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', NULL, NULL, 1, 0, 0, NULL),
(1062, 6, 'Fred', 'Blogs', 'Mr', 1, 'No', '16-70', 1, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', NULL, NULL, 1, 0, 0, NULL),
(1110, 138, 'Fred', 'Blogs', 'Mr', 1, 'No', '16-70', 0, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', NULL, NULL, 1, 0, 0, NULL),
(1114, 78, 'Fred', 'Blogs', 'Mr', 1, 'No', '16-70', 0, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', 'West Sussex', 'EC1 ABC', '', '', '', NULL, NULL, 1, 0, 0, NULL),
(1160, 138, 'Fred', 'Blogs', 'Mr', 1, 'No', '16-70', 0, '01234 567 890', 'fred@blogs.com', 'Neither', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', NULL, NULL, 1, 0, 0, NULL),
(1194, 118, 'Fred', 'Blogs', 'Mr', 1, 'No', '16-70', 1, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', 'West Sussex', 'EC1 ABC', 'UK', '', '', -19, '2017-12-18 18:42:10', 1, 1, 0, NULL),
(1228, 110, 'Deborah', 'Abbott', 'Mrs', 4, 'No', '', 0, '01234 567 890', 'deborah@abbott.com', 'Neither', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', NULL, NULL, 1, 0, 0, NULL),
(1281, 83, 'Fred', 'Blogs', 'Mr', 1, 'No', '16-70', 0, '01234 567 890', 'fred@blogs.com', 'Neither', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', NULL, NULL, 1, 0, 0, NULL),
(1289, 108, 'Fred', 'Blogs', 'Mr', 1, 'No', '16-70', 0, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', NULL, NULL, 1, 0, 0, NULL),
(1291, 144, 'Fred', 'Blogs', 'Mr', 1, 'No', '16-70', 1, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '28-Apr-16', '29-Oct-16', NULL, NULL, 1, 0, 0, NULL),
(1426, 48, 'Fred', 'Blogs', 'Mr', 1, 'No', '16-70', 1, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', NULL, NULL, 1, 0, 0, NULL),
(1451, 9, 'Fred', 'Blogs', 'Mr', 1, 'No', '16-70', 1, '01234 567 890', 'fred@blogs.com', 'Email', 0, '2014-07-31', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', 'Sussex', 'EC1 ABC', '', '', '', NULL, NULL, 1, 0, 0, NULL),
(1475, 1, 'Fred', 'Blogs', 'Mr', 1, 'No', '16-70', 0, '01234 567 890', 'fred@blogs.com', 'Email', 0, '2015-02-01', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', NULL, NULL, 1, 0, 0, NULL),
(1501, 46, 'Fred', 'Blogs', 'Mr', 1, 'No', '16-70', 1, '01234 567 890', 'fred@blogs.com', 'Email', 0, '2014-10-01', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', NULL, NULL, 1, 0, 0, NULL),
(1512, 82, 'Jonathan', 'Spencer', 'Mr', 1, 'No', '16-70', 0, '01234 567 890', 'deborah@abbott.com', 'Email', 0, '2015-02-01', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', 'West Sussex', 'EC1 ABC', '', '', '', 838, '2017-06-29 14:09:01', 1, 0, 0, NULL),
(1513, 82, 'Fred', 'Blogs', 'Mr', 1, 'No', '16-70', 0, '01234 567 890', 'fred@blogs.com', 'Email', 0, '2015-02-01', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', 860, '2017-12-16 22:36:24', 1, 0, 0, NULL),
(1514, 105, 'Fred', 'Blogs', 'Mr', 1, 'No', '16-70', 0, '01234 567 890', 'fred@blogs.com', 'Email', 0, '2015-02-01', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', NULL, NULL, 1, 0, 0, NULL),
(1527, 27, 'Fred', 'Blogs', 'Mr', 5, 'No', 'Under 16', 1, '01234 567 890', 'fred@blogs.com', 'Email', 0, '2015-04-07', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', 863, '2017-12-11 17:19:06', 1, 0, 0, NULL),
(1545, 122, 'Fred', 'Blogs', 'Mr', 1, 'No', '16-70', 0, '01234 567 890', 'fred@blogs.com', 'Email', 0, '2016-03-01', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', NULL, NULL, 1, 0, 0, NULL),
(1591, 138, 'Fred', 'Blogs', 'Mr', 5, 'No', 'Under 16', 0, '01234 567 890', 'fred@blogs.com', 'Neither', 0, '2016-06-09', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', NULL, NULL, 1, 0, 0, NULL);
INSERT INTO `c1jr0_md_member` (`id`, `tower_id`, `forenames`, `surname`, `title`, `member_type_id`, `long_service`, `insurance_group`, `annual_report`, `telephone`, `email`, `newsletters`, `district_newsletters`, `date_elected`, `address1`, `address2`, `address3`, `town`, `county`, `postcode`, `country`, `dbs_date`, `dbs_update`, `mod_user_id`, `mod_date`, `db_form_received`, `accept_privicy_policy`, `soudbow_subscriber`, `can_publish_name`) VALUES
(1592, 138, 'Fred', 'Blogs', 'Mr', 1, 'No', '16-70', 1, '01234 567 890', 'fred@blogs.com', 'Email', 0, '2016-06-02', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', NULL, NULL, 1, 0, 0, NULL),
(1608, 44, 'Fred', 'Blogs', 'Mr', 1, 'No', '16-70', 1, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', 'East Sussex', 'EC1 ABC', '', '', '', NULL, NULL, 1, 0, 0, NULL),
(1613, 91, 'Fred', 'Blogs', 'Mr', 4, 'No', '', 0, '01234 567 890', 'fred@blogs.com', '0', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', 838, '2017-12-02 22:17:12', 1, 0, 0, NULL),
(1617, 138, 'Fred', 'Blogs', 'Mr', 1, 'No', '16-70', 1, '01234 567 890', 'fred@blogs.com', 'Neither', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', NULL, NULL, 1, 0, 0, NULL),
(1618, 138, 'Fred', 'Blogs', 'Mr', 1, 'No', '16-70', 0, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', NULL, NULL, 1, 0, 0, NULL),
(1619, 138, 'Fred', 'Blogs', 'Mr', 5, 'No', 'Under 16', 0, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', NULL, NULL, 1, 0, 0, NULL),
(1620, 138, 'Fred', 'Blogs', 'Mr', 1, 'No', '16-70', 0, '01234 567 890', 'fred@blogs.com', 'Email', 0, '2017-01-13', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', 'West Sussex', 'EC1 ABC', '', '', '', NULL, NULL, 1, 0, 0, NULL),
(1621, 53, 'Fred', 'Blogs', 'Mr', 1, 'No', '16-70', 0, '01234 567 890', 'fred@blogs.com', 'Email', 0, '2017-01-19', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', NULL, NULL, 1, 0, 0, NULL),
(1693, 75, 'Fred', 'Blogs', 'Mr', 4, 'No', '', 0, '01234 567 890', 'fred@blogs.com', 'Neither', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', '', 'EC1 ABC', '', '', '', 838, '2017-07-30 22:34:11', 1, 0, 0, NULL),
(1697, 71, 'Fred', 'Blogs', 'Mr', 4, 'No', '', 0, '01234 567 890', 'fred@blogs.com', 'Email', 0, '', '1 School Lane', 'Blogs Towers', 'Fred Village', 'London', 'East Sussex', 'EC1 ABC', '', '', '', 838, '2017-12-02 21:46:52', 1, 0, 0, NULL);

--
-- Triggers `c1jr0_md_member`
--
DROP TRIGGER IF EXISTS `md_member_delete_trigger`;
DELIMITER $$
CREATE TRIGGER `md_member_delete_trigger` BEFORE DELETE ON `c1jr0_md_member` FOR EACH ROW insert into c1jr0_md_member_history SELECT null, c1jr0_md_member.* FROM c1jr0_md_member WHERE c1jr0_md_member.id = OLD.id
$$
DELIMITER ;
DROP TRIGGER IF EXISTS `md_member_update_trigger`;
DELIMITER $$
CREATE TRIGGER `md_member_update_trigger` BEFORE UPDATE ON `c1jr0_md_member` FOR EACH ROW insert into c1jr0_md_member_history SELECT null, c1jr0_md_member.* FROM c1jr0_md_member WHERE c1jr0_md_member.id = NEW.id
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `c1jr0_md_member_attachment`
--

DROP TABLE IF EXISTS `c1jr0_md_member_attachment`;
CREATE TABLE `c1jr0_md_member_attachment` (
  `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `member_id` int(10) UNSIGNED NOT NULL,
  `name` varchar(30) NOT NULL,
  `type` varchar(50) NOT NULL,
  `description` varchar(250) DEFAULT NULL,
  `mod_user_id` int(10) UNSIGNED NOT NULL,
  `mod_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `c1jr0_md_member_history`
--

DROP TABLE IF EXISTS `c1jr0_md_member_history`;
CREATE TABLE `c1jr0_md_member_history` (
  `history_id` int(11) NOT NULL AUTO_INCREMENT,
  `id` int(5) NOT NULL,
  `tower_id` int(3) DEFAULT NULL,
  `forenames` varchar(50) DEFAULT NULL,
  `surname` varchar(50) DEFAULT NULL,
  `title` varchar(12) DEFAULT NULL,
  `member_type_id` int(11) DEFAULT NULL,
  `long_service` varchar(8) NOT NULL DEFAULT 'No',
  `insurance_group` varchar(10) DEFAULT NULL,
  `annual_report` tinyint(1) DEFAULT NULL,
  `telephone` varchar(28) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `newsletters` varchar(7) DEFAULT NULL,
  `district_newsletters` int(11) NOT NULL DEFAULT '0',
  `date_elected` varchar(21) DEFAULT NULL,
  `address1` varchar(100) DEFAULT NULL,
  `address2` varchar(100) DEFAULT NULL,
  `address3` varchar(100) DEFAULT NULL,
  `town` varchar(50) DEFAULT NULL,
  `county` varchar(20) DEFAULT NULL,
  `postcode` varchar(9) DEFAULT NULL,
  `country` varchar(2) DEFAULT NULL,
  `dbs_date` varchar(10) DEFAULT NULL,
  `dbs_update` varchar(10) DEFAULT NULL,
  `mod_user_id` int(11) DEFAULT NULL,
  `mod_date` timestamp NULL DEFAULT NULL,
  `db_form_received` tinyint(1) NOT NULL DEFAULT '0',
  `accept_privicy_policy` tinyint(1) NOT NULL DEFAULT '0',
  `soudbow_subscriber` tinyint(1) NOT NULL DEFAULT '0',
  `can_publish_name` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`history_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `c1jr0_md_member_token`
--

DROP TABLE IF EXISTS `c1jr0_md_member_token`;
CREATE TABLE `c1jr0_md_member_token` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `email` varchar(100) NOT NULL,
  `hash_token` varchar(100) NOT NULL,
  `expiry_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `created_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `c1jr0_md_member_type`
--

DROP TABLE IF EXISTS `c1jr0_md_member_type`;
CREATE TABLE `c1jr0_md_member_type` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(15) NOT NULL,
  `fee` decimal(10,0) NOT NULL,
  `include_in_reports` tinyint(1) NOT NULL DEFAULT '1',
  `enabled` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8;

--
-- Dumping data for table `c1jr0_md_member_type`
--

INSERT INTO `c1jr0_md_member_type` (`id`, `name`, `fee`, `include_in_reports`, `enabled`) VALUES
(1, 'Adult', '8', 1, 1),
(2, 'Long Service', '0', 1, 0),
(3, 'Honorary Life', '0', 1, 1),
(4, 'Non-Member', '0', 0, 1),
(5, 'Junior', '4', 1, 1),
(6, 'Associate', '8', 1, 1),
(7, 'Non-Resident', '0', 0, 1),
(8, 'Deceased', '0', 0, 1);

-- --------------------------------------------------------

--
-- Table structure for table `c1jr0_md_member_verified`
--

DROP TABLE IF EXISTS `c1jr0_md_member_verified`;
CREATE TABLE `c1jr0_md_member_verified` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `member_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `verified_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `c1jr0_md_tower`
--

DROP TABLE IF EXISTS `c1jr0_md_tower`;
CREATE TABLE `c1jr0_md_tower` (
  `id` int(3) NOT NULL AUTO_INCREMENT,
  `district_id` int(1) DEFAULT NULL,
  `place` varchar(40) DEFAULT NULL,
  `designation` varchar(40) DEFAULT NULL,
  `bells` int(2) DEFAULT NULL,
  `tenor` varchar(20) DEFAULT NULL,
  `grid_ref` varchar(8) DEFAULT NULL,
  `ground_floor` tinyint(1) DEFAULT NULL,
  `anti_clockwise` tinyint(1) DEFAULT NULL,
  `unringable` tinyint(1) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `street` varchar(100) DEFAULT NULL,
  `town` varchar(50) DEFAULT NULL,
  `county` varchar(50) DEFAULT NULL,
  `post_code` varchar(10) DEFAULT NULL,
  `country` varchar(2) DEFAULT NULL,
  `longitude` decimal(35,14) DEFAULT NULL,
  `latitude` decimal(35,14) DEFAULT NULL,
  `website` varchar(200) DEFAULT NULL,
  `church_website` varchar(200) DEFAULT NULL,
  `doves_guide` varchar(200) DEFAULT NULL,
  `tower_description` varchar(200) DEFAULT NULL,
  `wc` tinyint(1) DEFAULT NULL,
  `sunday_ringing` varchar(100) DEFAULT NULL,
  `active` tinyint(1) DEFAULT NULL,
  `correspondent_id` int(4) DEFAULT NULL,
  `corresp_email` varchar(100) DEFAULT NULL,
  `captain_id` int(5) DEFAULT NULL,
  `web_tower_id` int(3) DEFAULT NULL,
  `multi_towers` tinyint(1) DEFAULT NULL,
  `practice_night` varchar(17) DEFAULT NULL,
  `practice_details` varchar(200) DEFAULT NULL,
  `field1` varchar(4) DEFAULT NULL,
  `incl_capt` tinyint(1) DEFAULT NULL,
  `incl_corresp` tinyint(1) DEFAULT NULL,
  `mod_user_id` int(11) DEFAULT NULL,
  `mod_date` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=154 DEFAULT CHARSET=utf8;

--
-- Dumping data for table `c1jr0_md_tower`
--

INSERT INTO `c1jr0_md_tower` (`id`, `district_id`, `place`, `designation`, `bells`, `tenor`, `grid_ref`, `ground_floor`, `anti_clockwise`, `unringable`, `email`, `street`, `town`, `county`, `post_code`, `country`, `longitude`, `latitude`, `website`, `church_website`, `doves_guide`, `tower_description`, `wc`, `sunday_ringing`, `active`, `correspondent_id`, `corresp_email`, `captain_id`, `web_tower_id`, `multi_towers`, `practice_night`, `practice_details`, `field1`, `incl_capt`, `incl_corresp`, `mod_user_id`, `mod_date`) VALUES
(1, 4, 'Aldingbourne', 'St Mary the Virgin', 5, '6-1-14', 'SU923054', 0, 0, 0, 'aldingbourne@scacr.org', 'Church Rd', 'Aldingbourne', 'West Sussex', 'PO20 3TT', 'UK', '-0.68959980000000', '50.84335940000000', '', 'www.parishofabe.org.uk/', 'dove.cccbr.org.uk/detail.php?searchString=Aldingbourne&numPerPage=10&Submit=Go&searchAmount=%3D&searchMetric=cwt&sortBy=Place&sortDir=Asc&DoveID=ALDINGBOUR', '', 1, '9:30-10:00', 1, 839, NULL, 1475, 104, 0, 'Monday', '7:30-9:00', 'TRUE', 0, 0, NULL, NULL),
(2, 2, 'Aldrington', 'St Leonard', 6, '10-0-14', 'TQ266053', 0, 0, 0, 'aldrington@scacr.org', 'New Church Road', 'Hove', 'East Sussex', 'BN3 4ED', 'UK', '-0.20387507601015', '50.83263201650720', '', '', 'dove.cccbr.org.uk/detail.php?searchString=Aldrington&Submit=+Go+&DoveID=ALDRINGTON', '', 1, '9:00-9:30', 1, 502, NULL, 502, 36, 0, 'Tuesday', '7:45-9:00', 'TRUE', 0, 0, NULL, NULL),
(3, 4, 'Aldwick', 'St Richard', 8, '7-3-26', 'SZ909991', 0, 0, 0, 'aldwick@scacr.org', 'Gossamer Lane', 'Aldwick, Bognor Regis', 'West Sussex', 'PO21 3AT', 'UK', '-0.71098198755794', '50.78380900028970', '', 'www.aldwick.org.uk/', 'dove.cccbr.org.uk/detail.php?searchString=Aldwick&numPerPage=10&Submit=Go&searchAmount=%3D&searchMetric=cwt&sortBy=Place&sortDir=Asc&DoveID=ALDWICK', '', 1, '9:50-10:25', 1, 874, NULL, 70, 105, 0, 'Tuesday', '7:30-9:00', 'TRUE', 0, 0, NULL, NULL),
(4, 3, 'Alfriston', 'St Andrew', 6, '8-2-0', 'TQ521030', 1, 0, 0, 'alfriston@scacr.org', 'The Tye', 'Alfriston', 'East Sussex', 'BN26 5TL', 'UK', '0.15809714498300', '50.80653774060000', '', 'www.cuckmerechurches.org.uk', 'dove.cccbr.org.uk/detail.php?searchString=Alfriston&Submit=+Go+&DoveID=ALFRISTON', '', 1, '10:15-11:00', 1, 451, NULL, 451, 63, 0, 'Tuesday', '7:15-8:30', 'TRUE', 1, 1, 854, '2018-01-01 21:05:42'),
(5, 4, 'Amberley', 'St Michael & All Angels', 5, '5-3-13', 'TQ027132', 0, 0, 0, 'amberley@scacr.org', 'Church St', 'Amberley, Arundel', 'West Sussex', 'BN18 9NF', 'UK', '-0.53907137470696', '50.90898077830540', '', '', 'dove.cccbr.org.uk/detail.php?searchString=Amberley&numPerPage=10&Submit=Go&searchAmount=%3D&searchMetric=cwt&sortBy=Place&sortDir=Asc&DoveID=AMBERLEY', '', 1, '10:30', 1, 53, NULL, 54, 106, 0, 'Friday', '7:00-8:30 (ring to confirm 01798 831070)', 'TRUE', 0, 0, NULL, NULL),
(6, 4, 'Angmering', 'St Margaret', 6, '13-1-0', 'TQ067044', 0, 0, 0, 'angmering@scacr.org', 'Arundel Road', 'Littlehampton', 'West Sussex', 'BN16 4JS', 'UK', '-0.48604194831546', '50.82929218119020', '', 'www.angmering.org.uk/', 'dove.cccbr.org.uk/detail.php?searchString=Angmering&numPerPage=10&Submit=Go&searchAmount=%3D&searchMetric=cwt&sortBy=Place&sortDir=Asc&DoveID=ANGMERING', '', 1, '8:45 (1st, 3rd)', 1, 1062, NULL, 0, 107, 0, 'Thursday', '7:45-9:15 (2nd, 4th & 5th)', 'TRUE', 0, 0, NULL, NULL),
(7, 1, 'Ardingly', 'St Peter', 6, '8-1-0', 'TQ39298', 0, 0, 0, 'ardingly@scacr.org', 'Church Lane', 'Ardingly', 'West Sussex', 'RH17 6UR', 'UK', '-0.09150929999998', '51.04939110000000', '', 'www.ardinglychurch.co.uk/', 'dove.cccbr.org.uk/detail.php?searchString=Ardingly&numPerPage=10&Submit=Go&searchAmount=%3D&searchMetric=cwt&sortBy=Place&sortDir=Asc&DoveID=ARDINGLY', '', 1, '9.45-10.15', 1, 500, NULL, 500, 8, 0, 'Thursday', '8:00-9:00', 'TRUE', 0, 0, NULL, NULL),
(8, 4, 'Arundel', 'St Nicholas', 8, '13-3-4', 'TQ016073', 0, 0, 0, 'arundel@scacr.org', 'London Road', 'Arundel', 'West Sussex', 'BN18 9AT', 'UK', '-0.55670464130856', '50.85556584842240', '', 'www.stnicholas-arundel.co.uk/', 'dove.cccbr.org.uk/detail.php?searchString=Arundel&numPerPage=10&Submit=Go&searchAmount=%3D&searchMetric=cwt&sortBy=Place&sortDir=Asc&DoveID=ARUNDEL', '', 1, '9:30-9:55', 1, 16, NULL, 16, 108, 0, 'Monday', '7:00-9:00 (2nd & 4th, alternate with Lyminster)', 'TRUE', 0, 0, NULL, NULL),
(9, 3, 'Ashburnham', 'St Peter', 6, '9-3-7', 'TQ689145', 0, 0, 0, 'ashburnham@scacr.org', 'Ashburnham,', 'Battle', 'East Sussex', 'TN33 9NE', 'UK', '0.40277180296630', '50.90584408226160', '', 'www.ashburnhamandpenhurstchurches.org.uk/', 'dove.cccbr.org.uk/detail.php?searchString=Ashburnham&numPerPage=10&Submit=Go&searchAmount=%3D&searchMetric=cwt&sortBy=Place&sortDir=Asc&DoveID=ASHBURNHAM', '', 1, '9:45-10:25', 1, 1451, NULL, 1451, 64, 0, 'Thursday', '7:30', 'TRUE', 0, 0, NULL, NULL),
(10, 1, 'Balcombe', 'St Mary', 8, '9-0-10', 'TQ307309', 0, 0, 0, 'balcombe@scacr.org', 'Haywards Heath Road', 'Balcombe', 'West Sussex', 'RH17 6PY', 'UK', '-0.12409990000003', '51.05280220000000', '', 'www.stmarys-balcombe.org/', 'dove.cccbr.org.uk/detail.php?searchString=Balcombe&numPerPage=10&Submit=Go&searchAmount=%3D&searchMetric=cwt&sortBy=Place&sortDir=Asc&DoveID=BALCOMBE', '', 1, '9:30-10:00', 1, 510, '', 510, 9, 0, 'Tuesday', '7:30-9:00', 'TRUE', 0, 0, NULL, NULL),
(11, 2, 'Barcombe', 'St Mary the Virgin', 6, '9-0-2', 'TQ418143', 0, 0, 0, 'barcombe@scacr.org', 'Church Road', 'Barcombe', 'East Sussex', 'BN8 5TS', 'UK', '0.02213589999997', '50.91563020000000', '', '', 'dove.cccbr.org.uk/detail.php?searchString=Barcombe&numPerPage=10&Submit=Go&searchAmount=%3D&searchMetric=cwt&sortBy=Place&sortDir=Asc&DoveID=BARCOMBE', '', 1, 'By arrangement', 1, 401, NULL, 0, 39, 0, 'Thursday', '7:30 (infrequent - phone to confirm)', 'TRUE', 0, 0, NULL, NULL),
(12, 3, 'Battle', 'St Mary', 8, '21-3-8', 'TQ750158', 0, 0, 0, 'battle@scacr.org', 'Upper Lake, Battle', 'Battle', 'East Sussex', 'TN33 0AN', 'UK', '0.49003933624567', '50.91435620257610', '', 'www.stmarysbattle.com/', 'dove.cccbr.org.uk/detail.php?searchString=Battle&numPerPage=10&Submit=Go&searchAmount=%3D&searchMetric=cwt&sortBy=Place&sortDir=Asc&DoveID=BATTLE', '', 1, '10:30-11:00, 9:30-10:00 (5th)', 1, 335, NULL, 354, 65, 0, 'Tuesday', '7:30-9:30', 'TRUE', 0, 0, NULL, NULL),
(13, 3, 'Beckley', 'All Saints', 6, '12-0-10', 'TQ843237', 0, 0, 0, 'beckley@scacr.org', 'Church Lane', 'Beckley', 'East Sussex', 'TN31 6SE', 'UK', '0.62413830000003', '50.98312904231230', '', 'www.beckleyandpeasmarshchurch.co.uk/', 'dove.cccbr.org.uk/detail.php?searchString=Beckley&numPerPage=10&Submit=Go&searchAmount=%3D&searchMetric=cwt&sortBy=Place&sortDir=Asc&DoveID=BECKLEY+SX', '', 1, '9:30-10:00 (2nd, 4th)', 1, 579, NULL, 0, 66, 0, 'Wednesday', '6:30-8:00', 'TRUE', 0, 0, NULL, NULL),
(14, 3, 'Beddingham', 'St Andrew', 4, '10-0-0', 'TQ445079', 0, 0, 0, '', '', '', '', '', 'UK', '0.00000000000000', '0.00000000000000', '', '', '', '', 1, '', 1, 0, NULL, 0, 0, 0, '', '', 'TRUE', 0, 0, NULL, NULL),
(15, 3, 'Bexhill on Sea', 'St Peter', 10, '17-2-15', 'TQ746081', 0, 0, 0, 'bexhill@scacr.org', 'Church Street', 'Bexhill', 'East Sussex', 'TN40 2HE', 'UK', '0.47886319999998', '50.84605050000000', '', 'www.stpetersbexhill.org.uk/', 'dove.cccbr.org.uk/detail.php?searchString=Bexhill&numPerPage=10&Submit=Go&searchAmount=%3D&searchMetric=cwt&sortBy=Place&sortDir=Asc&DoveID=BEXHILL+ON', '', 1, '9:15-9:45, 5:30-6:00', 1, 467, NULL, 57, 67, 0, 'Tuesday', '7:30', 'TRUE', 0, 0, NULL, NULL),
(16, 4, 'Billingshurst', 'St Mary', 8, '14-2-18', 'TQ087259', 0, 0, 0, 'billingshurst@scacr.org', 'East Street', 'Billingshurst', 'West Sussex', 'RH14 9PY', 'UK', '-0.45107843865355', '51.02249729441140', '', 'www.stmarysbillingshurst.org/', 'dove.cccbr.org.uk/detail.php?searchString=Billingshurst&numPerPage=10&Submit=Go&searchAmount=%3D&searchMetric=cwt&sortBy=Place&sortDir=Asc&DoveID=BILLINGSHU', '', 1, '10:30-11:00 (1st, 3rd), 9:00-9:30 (2nd, 4th, 5th)', 1, 231, NULL, 230, 109, 0, 'Wednesday', '7:30-9:00', 'TRUE', 0, 0, NULL, NULL),
(17, 3, 'Bodiam', 'St Giles', 6, '7-1-5', 'TQ782262', 0, 0, 0, 'bodiam@scacr.org', 'Sandhurst Road', 'Bodiam', 'East Sussex', 'TN32 5UJ', 'UK', '0.54840445023194', '51.02065215106450', '', '', 'dove.cccbr.org.uk/detail.php?searchString=Bodiam&numPerPage=10&Submit=Go&searchAmount=%3D&searchMetric=cwt&sortBy=Place&sortDir=Asc&DoveID=BODIAM', '', 1, '1st & 3rd', 1, 675, NULL, 0, 68, 0, 'Thursday', '7:00-8:00 (joint with Ewhurst Green)', 'TRUE', 0, 0, NULL, NULL),
(18, 1, 'Bolney', 'St Mary Magdalene', 8, '13-0-8', 'TQ262227', 0, 0, 0, 'bolney@scacr.org', 'The Street', 'Bolney', 'West Sussex', 'RH17 5QP', 'UK', '-0.20370579999997', '50.99330900000000', '', 'www.stmarymagdalenebolney.org.uk/', 'dove.cccbr.org.uk/detail.php?searchString=Bolney&numPerPage=10&Submit=Go&searchAmount=%3D&searchMetric=cwt&sortBy=Place&sortDir=Asc&DoveID=BOLNEY', '', 1, '8:45-9:25', 1, 630, NULL, 620, 10, 0, 'Friday', '7:45-9:00', 'TRUE', 0, 0, NULL, NULL),
(19, 4, 'Bosham', 'Holy Trinity', 6, '13-0-7', 'SU803038', 0, 0, 0, 'bosham@scacr.org', 'High St', 'Bosham', 'West Sussex', 'PO18 8LY', 'UK', '-0.85931348968813', '50.82870796776990', 'www.boshamtower.org.uk/', 'www.boshamchurch.org.uk/', 'dove.cccbr.org.uk/detail.php?searchString=Bosham&numPerPage=10&Submit=Go&searchAmount=%3D&searchMetric=cwt&sortBy=Place&sortDir=Asc&DoveID=BOSHAM', '', 1, '9:00-9:30', 1, 771, NULL, 8, 110, 0, 'Thursday', '7:00-9:00', 'TRUE', 0, 0, NULL, NULL),
(20, 3, 'Brede', 'St George', 6, '13-0-13', 'TQ825183', 0, 0, 0, 'brede@scacr.org', 'Brede Hill', 'Brede', 'East Sussex', 'TN31 6EJ', 'UK', '0.59644169206547', '50.93438949218500', '', '', 'dove.cccbr.org.uk/detail.php?searchString=Brede&numPerPage=10&Submit=Go&searchAmount=%3D&searchMetric=cwt&sortBy=Place&sortDir=Asc&DoveID=BREDE', '', 1, '8:45-9:30', 1, 746, NULL, 746, 69, 0, 'Monday', '7:30-8:30 (2nd, 4th)', 'TRUE', 0, 0, NULL, NULL),
(21, 3, 'Brightling', 'St Thomas of Canterbury', 8, '12-1-9', 'TQ683210', 0, 0, 0, 'brightling@scacr.org', 'The Street', 'Brightling', 'East Sussex', 'TN32 5HH', 'UK', '0.39619824859619', '50.96380954078410', '', '', 'dove.cccbr.org.uk/detail.php?searchString=Brightling&numPerPage=10&Submit=Go&searchAmount=%3D&searchMetric=cwt&sortBy=Place&sortDir=Asc&DoveID=BRIGHTLING', '', 1, 'By arrangement', 1, 769, NULL, 769, 70, 0, 'Thursday', '7:30', 'TRUE', 0, 0, NULL, NULL),
(22, 2, 'Brighton', 'Good Shepherd', 8, '13-2-16', 'TQ298063', 0, 0, 0, 'brightongs@scacr.org', '272 Dyke Rd', 'Brighton and Hove', 'East Sussex', 'BN1 5AE', 'UK', '-0.15801299999998', '50.84151730000000', '', 'www.goodshepherdbrighton.org.uk/', 'dove.cccbr.org.uk/detail.php?searchString=Brighton&numPerPage=10&Submit=Go&searchAmount=%3D&searchMetric=cwt&sortBy=Place&sortDir=Asc&DoveID=BRIGHTONPG', '', 1, '9:45-10:15', 1, 331, NULL, 331, 41, 0, 'Tuesday', '7:00-8:30', 'TRUE', 0, 0, NULL, NULL),
(23, 2, 'Brighton (Kemp Town)', 'St Mark', 4, '6-0-0', 'TQ308041', 0, 0, 0, 'brightonkt@scacr.org', 'Church Place', 'Kemptown', 'Brighton and Hove', 'BN2 5JN', 'UK', '-0.11181227249142', '50.81754737386620', '', '', 'dove.cccbr.org.uk/detail.php?searchString=Brighton%2C+Kemp+Town&Submit=+Go+&DoveID=BRIGHTON+M', '', 1, '', 1, 327, NULL, 327, 145, 0, 'Thursday', '7:15-8:45', 'TRUE', 0, 0, NULL, NULL),
(24, 2, 'Brighton (Preston)', 'St Peter', 3, '', 'TQ304065', 0, 0, 0, '', 'Preston Drove, Preston Park', 'Brighton', 'East Sussex', 'BN1 6SD', 'UK', '-0.15006210000001', '50.84249790000000', '', 'www.stpetersprestonpark.co.uk/', 'dove.cccbr.org.uk/detail.php?searchString=Brighton&numPerPage=10&Submit=Go&searchAmount=%3D&searchMetric=cwt&sortBy=Place&sortDir=Asc&DoveID=BRIGHTONPK', '', 1, '', 1, 1628, NULL, 0, 44, 0, '', '', 'TRUE', 0, 0, NULL, NULL),
(25, 2, 'Brighton', 'St Nicholas of Myra', 10, '18-0-20', 'TQ308045', 0, 0, 0, 'brightonsn@scacr.org', 'Dyke Road', 'Brighton', 'East Sussex', 'BN1 3LH', 'UK', '-0.14489594174188', '50.82535975571760', 'www.stnicholasbrighton.org.uk', '', 'dove.cccbr.org.uk/detail.php?searchString=Brighton&numPerPage=10&Submit=Go&searchAmount=%3D&searchMetric=cwt&sortBy=Place&sortDir=Asc&DoveID=BRIGHTON+N', '', 1, '9:45 - 10:25', 1, 392, NULL, 396, 2, 0, 'Monday', '7:45-9:15 (2nd, 4th)', 'TRUE', 0, 0, NULL, NULL),
(26, 2, 'Brighton', 'St Peter', 10, '25-2-0', 'TQ314049', 0, 0, 0, 'brightonsp@scacr.org', 'York Place', 'Brighton', 'East Sussex', 'BN2 9LT', 'UK', '-0.13561989999994', '50.82871810000000', '', 'stpetersbrighton.org/', 'dove.cccbr.org.uk/detail.php?searchString=Brighton&numPerPage=10&Submit=Go&searchAmount=%3D&searchMetric=cwt&sortBy=Place&sortDir=Asc&DoveID=BRIGHTON+P', '', 1, '8:45-9:25', 1, 392, NULL, 396, 43, 0, 'Monday', '7:45-9:15 (1st, 3rd, 5th)', 'TRUE', 0, 0, NULL, NULL),
(27, 2, 'Burgess Hill', 'St John the Evangelist', 8, '14-2-26', 'TQ313193', 0, 0, 0, 'burgesshill@scacr.org', 'Lower Church Road', 'Burgess Hill', 'West Sussex', 'RH15 9AA', 'UK', '-0.13351439737551', '50.95704507799100', '', 'www.stjohnsbh.org.uk/', 'dove.cccbr.org.uk/detail.php?searchString=Burgess+Hill&numPerPage=10&Submit=Go&searchAmount=%3D&searchMetric=cwt&sortBy=Place&sortDir=Asc&DoveID=BURGESS+HI', '', 1, '9:15-10:00', 1, 793, NULL, 1527, 45, 0, 'Monday', '7:45-9:00', 'TRUE', 1, 1, 863, '2017-12-11 17:12:04'),
(28, 3, 'Burwash', 'St Bartholomew', 8, '10-1-21', 'TQ677248', 0, 0, 0, 'burwash@scacr.org', 'High Street', 'Burwash', 'East Sussex', 'TN19 7EH', 'UK', '0.38861373936766', '50.99803007501700', '', 'www.burwash.org/local-information/churches-stbartholomews.htm', 'dove.cccbr.org.uk/detail.php?searchString=Burwash&numPerPage=10&Submit=Go&searchAmount=%3D&searchMetric=cwt&sortBy=Place&sortDir=Asc&DoveID=BURWASH', '', 1, '', 1, 754, NULL, 753, 71, 0, 'Tuesday', '7:30', 'TRUE', 0, 0, NULL, NULL),
(29, 4, 'Bury', 'St John the Evangelist', 4, '10-0-0', 'TQ016131', 0, 0, 0, '', '', '', '', '', 'UK', '0.00000000000000', '0.00000000000000', '', '', '', '', 1, '', 1, 0, NULL, 0, 0, 0, '', '', 'TRUE', 0, 0, NULL, NULL),
(30, 2, 'Buxted', 'St Margaret Queen', 8, '15-0-0', 'TQ485230', 0, 0, 0, 'buxted@scacr.org', 'Off A272', 'Buxted', 'East Sussex', 'TN22 4AY', 'UK', '0.14268469895023', '50.99213495712880', '', 'www.bhdchurches.org.uk/copyofparishofbu.htm', 'dove.cccbr.org.uk/detail.php?searchString=Buxted&numPerPage=10&Submit=Go&searchAmount=%3D&searchMetric=cwt&sortBy=Place&sortDir=Asc&DoveID=BUXTED', '', 1, '9:25-9:55', 1, 315, NULL, 316, 46, 0, 'Wednesday', '8:00-9:30', 'TRUE', 0, 0, NULL, NULL),
(31, 2, 'Chailey', 'St Peter', 6, '7-1-13', 'TQ392193', 0, 0, 0, 'chailey@scacr.org', 'A275', 'Chailey', 'East Sussex', 'BN8 4DA', 'UK', '-0.01986639999996', '50.95986780000000', '', 'www.stpeterschailey.org.uk/', 'dove.cccbr.org.uk/detail.php?searchString=Chailey&numPerPage=10&Submit=Go&searchAmount=%3D&searchMetric=cwt&sortBy=Place&sortDir=Asc&DoveID=CHAILEY', '', 1, '9:25-9:55', 1, 506, NULL, 505, 47, 0, 'Monday', '8:00-9:00', 'TRUE', 0, 0, NULL, NULL),
(32, 4, 'Chichester', 'Cathedral of the Holy Trinity', 8, '18-1-12', 'SU859047', 0, 0, 0, 'chichester@scacr.org', 'West Street', 'Chichester', 'West Sussex', 'PO19 1RR', 'UK', '-0.78086168623100', '50.83664348780000', '', 'www.chichestercathedral.org.uk/', 'dove.cccbr.org.uk/detail.php?searchString=Chichester&numPerPage=10&Submit=Go&searchAmount=%3D&searchMetric=cwt&sortBy=Place&sortDir=Asc&DoveID=CHICHESTER', '', 1, '9:00-10:00', 1, 22, NULL, 23, 111, 0, 'Wednesday', '7:30-9:00', 'TRUE', 0, 1, 876, '2018-01-02 14:31:37'),
(33, 3, 'Chiddingly', '', 8, '8-3-18', 'TQ544142', 0, 0, 0, 'chiddingly@scacr.org', 'Church Lane', 'Chiddingly', 'East Sussex', 'BN8 6HE', 'UK', '0.19672158360595', '50.90614199404140', '', 'www.chiddinglychurch.org.uk/', 'dove.cccbr.org.uk/detail.php?searchString=Chiddingly&numPerPage=10&Submit=Go&searchAmount=%3D&searchMetric=cwt&sortBy=Place&sortDir=Asc&DoveID=CHIDDINGLY', '', 1, '9:00-9:30', 1, 444, NULL, 444, 72, 0, 'Thursday', '7:30-9:00', 'TRUE', 0, 0, NULL, NULL),
(34, 1, 'Coleman\'s Hatch', 'Holy Trinity', 8, '11-2-2', 'TQ450338', 0, 0, 0, 'colemanshatch@scacr.org', 'Shepherds Hill', 'Coleman\\\'s Hatch', 'East Sussex', 'TN7 4HN', 'UK', '0.06808739999997', '51.08590909999990', '', 'www.hartfieldchurch.org/', 'dove.cccbr.org.uk/detail.php?searchString=Coleman%27s+Hatch&numPerPage=10&Submit=Go&searchAmount=%3D&searchMetric=cwt&sortBy=Place&sortDir=Asc&DoveID=COLEMANS', '', 1, '10:40-11:15 2nd & 4th (by arrangement)', 1, 178, NULL, 176, 11, 0, 'Friday', '8:00-9:30', 'TRUE', 0, 0, NULL, NULL),
(35, 1, 'Cowfold', 'St Peter', 6, '8-2-0', 'TQ212226', 0, 0, 0, 'cowfold@scacr.org', 'The Street', 'Cowfold', 'West Sussex', 'RH13 8BW', 'UK', '-0.27263360000006', '50.99006550000000', '', 'www.stpeterschurch-cowfold.org.uk/', 'dove.cccbr.org.uk/detail.php?searchString=Cowfold&numPerPage=10&Submit=Go&searchAmount=%3D&searchMetric=cwt&sortBy=Place&sortDir=Asc&DoveID=COWFOLD', '', 1, '09:30-10:00 (1st), 10:45-11:15 (3rd & 4th)', 1, 566, NULL, 129, 12, 0, 'Thursday', '8:00-9:00', 'TRUE', 0, 0, NULL, NULL),
(36, 1, 'Crawley', 'St John the Baptist', 8, '13-3-12', 'TQ268366', 0, 0, 0, 'crawley@scacr.org', 'Church Walk', 'Crawley', 'West Sussex', 'RH10 1HH', 'UK', '-0.18984999999998', '51.11426680000000', '', '', 'dove.cccbr.org.uk/detail.php?searchString=Crawley&numPerPage=10&Submit=Go&searchAmount=%3D&searchMetric=cwt&sortBy=Place&sortDir=Asc&DoveID=CRAWLEY+WS', '', 1, '8:45-9:30', 1, 248, NULL, 246, 13, 0, 'Thursday', '7:30-9:00 (ring bellpush) Check with Correspondent', 'TRUE', 0, 0, NULL, NULL),
(37, 1, 'Cuckfield', 'Holy Trinity', 8, '15-0-0', 'TQ303245', 0, 0, 0, 'cuckfield@scacr.org', 'Church Street', 'Cuckfield', 'West Sussex', 'RH17 5JD', 'UK', '-0.14318070000002', '51.00547810000000', 'holytrinitycuckfield.org', '', 'dove.cccbr.org.uk/detail.php?searchString=Cuckfield&numPerPage=10&Submit=Go&searchAmount=%3D&searchMetric=cwt&sortBy=Place&sortDir=Asc&DoveID=CUCKFIELD', '', 1, '9:15-9:45', 1, 649, NULL, 964, 7, 0, 'Thursday', '7:45-9:00', 'TRUE', 0, 0, 838, '2017-09-28 16:34:54'),
(38, 3, 'Dallington', 'St Giles', 6, '10-0-11', 'TQ658191', 0, 0, 0, 'dallington@scacr.org', 'The Street', 'Dallington', 'East Sussex', 'TN21 9NH', 'UK', '0.35727718623048', '50.94584333180130', '', 'dallington.wordpress.com/category/st-giles-church/', 'dove.cccbr.org.uk/detail.php?searchString=Dallington&numPerPage=10&Submit=Go&searchAmount=%3D&searchMetric=cwt&sortBy=Place&sortDir=Asc&DoveID=DALLINGTON', '', 1, '2nd Sun 6pm, 4th Sun 9am', 1, 760, NULL, 346, 73, 0, 'Monday', '7:00-8:00', 'TRUE', 0, 0, NULL, NULL),
(39, 1, 'Danehill', 'All Saints', 6, '7-3-5', 'TQ402275', 0, 0, 0, 'danehill@scacr.org', 'Church Lane', 'Danehill', 'East Sussex', 'RH17 7HF', 'UK', '0.00091610000004', '51.02644690000000', '', 'www.allsaintsdanehill.org.uk/', 'dove.cccbr.org.uk/detail.php?searchString=Danehill&numPerPage=10&Submit=Go&searchAmount=%3D&searchMetric=cwt&sortBy=Place&sortDir=Asc&DoveID=DANEHILL', '', 1, '9:00-9:30', 1, 561, NULL, 236, 14, 0, 'Wednesday', '8:00-9:15', 'TRUE', 0, 0, NULL, NULL),
(40, 2, 'Ditchling', 'St Margaret', 8, '7-3-8', 'TQ326153', 0, 0, 0, 'ditchling@scacr.org', 'High St', 'Ditchling', 'West Sussex', 'BN6 8TB', 'UK', '-0.11556697619631', '50.92126016141700', '', '', 'dove.cccbr.org.uk/detail.php?searchString=Ditchling&numPerPage=10&Submit=Go&searchAmount=%3D&searchMetric=cwt&sortBy=Place&sortDir=Asc&DoveID=DITCHLING', '', 1, '9:15-9:45', 1, 779, NULL, 779, 48, 0, 'Tuesday', '8:00-9:15', 'TRUE', 0, 0, NULL, NULL),
(41, 4, 'Easebourne', 'St Mary', 8, '11-0-21', 'SU895225', 0, 0, 0, 'easebourne@scacr.org', 'A272', 'Easebourne', 'West Sussex', 'GU29 0AH', 'UK', '-0.72568917147214', '50.99528389305560', '', 'www.easebourne.org/united.html', 'dove.cccbr.org.uk/detail.php?searchString=Easebourne&numPerPage=10&Submit=Go&searchAmount=%3D&searchMetric=cwt&sortBy=Place&sortDir=Asc&DoveID=EASEBOURNE', '', 1, '10:00-10:30', 1, 767, NULL, 767, 112, 0, 'Thursday', '(alternate with Midhurst)', 'TRUE', 0, 0, NULL, NULL),
(42, 3, 'East Dean', 'SS Simon & Jude', 5, '5-0-25', 'TV557977', 0, 0, 0, '', '', '', '', '', 'UK', '0.00000000000000', '0.00000000000000', '', '', '', '', 1, '', 1, 0, NULL, 0, 0, 0, '', '', 'TRUE', 0, 0, NULL, NULL),
(43, 1, 'East Grinstead', 'St Swithun', 12, '28-3-10', 'TQ396380', 0, 0, 0, 'eastgrinstead@scacr.org', 'Church Lane/St Swithun\\\'s Close', 'East Grinstead', 'West Sussex', 'RH19 3AU', 'UK', '-0.00551500000006', '51.12495160000000', 'www.swithun.webeden.co.uk/#/bellringing/4541266259', 'www.swithun.webeden.co.uk/', 'dove.cccbr.org.uk/detail.php?searchString=East+Grinstead&numPerPage=10&Submit=Go&searchAmount=%3D&searchMetric=cwt&sortBy=Place&sortDir=Asc&DoveID=EAST+GRINS', '', 1, '9:20-10:00', 1, 834, NULL, 292, 15, 0, 'Wednesday', '7:45-9:30', 'TRUE', 0, 0, NULL, NULL),
(44, 3, 'East Hoathly', '', 6, '9-0-2', 'TQ520162', 0, 0, 0, 'easthoathly@scacr.org', 'Church Marks Lane', 'East Hoathly', 'East Sussex', 'BN8 6EG', 'UK', '0.16034737591860', '50.92367565880710', '', 'www.easthoathlywithhalland.org.uk/', 'dove.cccbr.org.uk/detail.php?searchString=East+Hoathly&numPerPage=10&Submit=Go&searchAmount=%3D&searchMetric=cwt&sortBy=Place&sortDir=Asc&DoveID=EAST+HOATH', '', 1, 'By arrangement', 1, 1608, NULL, 0, 76, 0, '', '', 'TRUE', 0, 0, NULL, NULL),
(45, 3, 'Eastbourne', 'All Saints', 8, '18-1-0', 'TV608983', 0, 0, 0, 'eastbourneas@scacr.org', '21a Grange Road', 'Eastbourne', 'East Sussex', 'BN21 4HL', 'UK', '0.27862789999995', '50.76433020000000', 'www.eastbourneringers.org.uk', 'www.aseb.co.uk/', 'dove.cccbr.org.uk/detail.php?searchString=Eastbourne&numPerPage=10&Submit=Go&searchAmount=%3D&searchMetric=cwt&sortBy=Place&sortDir=Asc&DoveID=EASTBORN+A', '', 1, '9:30', 1, 772, NULL, 772, 1, 0, 'Monday', '', 'TRUE', 0, 0, NULL, NULL),
(46, 3, 'Eastbourne', 'Christ Church', 8, '8-3-0', 'TV620997', 0, 0, 0, 'eastbournecc@scacr.org', 'Seaside', 'Eastbourne', 'East Sussex', 'BN22 7NN', 'UK', '0.29647182537838', '50.77417172294830', 'www.eastbourneringers.org.uk/', 'www.xpeastbourne.org/', 'dove.cccbr.org.uk/detail.php?searchString=Eastbourne&numPerPage=10&Submit=Go&searchAmount=%3D&searchMetric=cwt&sortBy=Place&sortDir=Asc&DoveID=EASTBORN+C', '', 1, '10:00-10:30', 1, 475, NULL, 1501, 74, 0, 'Tuesday', '7:15', 'TRUE', 0, 0, NULL, NULL),
(47, 3, 'Eastbourne', 'SS Saviour & Peter', 10, '24-1-23', 'TV610988', 0, 0, 0, 'eastbourness@scacr.org', 'Spencer Road', 'Eastbourne', 'East Sussex', 'BN21 4PE', 'UK', '0.28265227672114', '50.76587338635260', 'www.eastbourneringers.org.uk/', 'stsaviourseastbourne.org.uk/', 'dove.cccbr.org.uk/detail.php?searchString=Eastbourne&numPerPage=10&Submit=Go&searchAmount=%3D&searchMetric=cwt&sortBy=Place&sortDir=Asc&DoveID=EASTBORN+S', '', 1, '10:00 by arrangement', 1, 142, NULL, 351, 75, 0, 'Tuesday', '7:30 quarterly', 'TRUE', 0, 0, NULL, NULL),
(48, 3, 'Eastbourne', 'St Mary the Virgin', 8, '15-2-22', 'TV598995', 0, 0, 0, 'eastbournesm@scacr.org', 'Church St/Lawns Ave', 'Eastbourne', 'East Sussex', 'BN21 1PW', 'UK', '0.26501430105000', '50.77235028580000', 'www.eastbourneringers.org.uk', 'www.stmaryseastbourne.com/', 'dove.cccbr.org.uk/detail.php?searchString=Eastbourne&numPerPage=10&Submit=Go&searchAmount=%3D&searchMetric=cwt&sortBy=Place&sortDir=Asc&DoveID=EASTBORN+M', '', 1, '9:15-9:45, 6:00-6:30 (occasionally)', 1, 1426, NULL, 1228, 6, 0, 'Tuesday', '7:30', 'TRUE', 0, 0, 838, '2017-12-20 08:01:04'),
(49, 3, 'Ewhurst Green', 'St James', 5, '9-2-13', 'TQ796246', 0, 0, 0, 'ewhurstgreen@scacr.org', 'The Green', 'Ewhurst Green', 'East Sussex', 'TN32 5TE', 'UK', '0.55598929999996', '50.99224719999990', '', '', 'dove.cccbr.org.uk/detail.php?searchString=Ewhurst+Green&numPerPage=10&Submit=Go&searchAmount=%3D&searchMetric=cwt&sortBy=Place&sortDir=Asc&DoveID=EWHURST+GR', '', 1, '9:00', 1, 675, NULL, 675, 77, 0, 'Thursday', '', 'TRUE', 0, 0, NULL, NULL),
(50, 1, 'Fairwarp', 'Christ Church', 8, '15-2-0', 'TQ466268', 0, 0, 0, 'fairwarp@scacr.org', 'Some Road', 'Fairwarp', 'East Sussex', 'TN22 3BE', 'UK', '0.08838187934566', '51.02144727882810', '', 'www.christchurchfairwarp.org.uk/', 'dove.cccbr.org.uk/detail.php?searchString=Fairwarp&numPerPage=10&Submit=Go&searchAmount=%3D&searchMetric=cwt&sortBy=Place&sortDir=Asc&DoveID=FAIRWARP', '', 1, '8:45-9:30', 1, 887, NULL, 0, 16, 0, 'Thursday', '8:00-9:30', 'TRUE', 0, 0, NULL, NULL),
(51, 4, 'Felpham', 'St Mary', 8, '11-3-6', 'SZ949999', 0, 0, 0, 'felpham@scacr.org', 'Felpham Rd', 'Felpham', 'West Sussex', 'PO22 7PB', 'UK', '-0.65404983491817', '50.79045828229170', '', 'www.stmarys-felpham.co.uk/', 'dove.cccbr.org.uk/detail.php?searchString=Felpham&numPerPage=10&Submit=Go&searchAmount=%3D&searchMetric=cwt&sortBy=Place&sortDir=Asc&DoveID=FELPHAM', '', 1, '8:45-9:30', 1, 721, NULL, 52, 113, 0, 'Wednesday', '8:00-9:15', 'TRUE', 0, 0, NULL, NULL),
(52, 4, 'Fernhurst', 'St Margaret of Antioch', 3, '6-0-0', 'SU899285', 0, 0, 0, 'fernhurst@scacr.org', '', '', '', '', 'UK', '0.00000000000000', '0.00000000000000', '', '', '', '', 1, 'By arrangement', 1, 574, NULL, 0, 0, 0, '', 'By arrangement', 'TRUE', 0, 0, NULL, NULL),
(53, 4, 'Findon', 'St John the Baptist', 6, '9-2-14', 'TQ116085', 0, 0, 0, 'findon@scacr.org', 'A24', 'Findon', 'West Sussex', 'BN14 0RF', 'UK', '-0.41481732812497', '50.86528838271310', '', 'www.findon.info/church/church.htm', 'dove.cccbr.org.uk/detail.php?searchString=Findon&numPerPage=10&Submit=Go&searchAmount=%3D&searchMetric=cwt&sortBy=Place&sortDir=Asc&DoveID=FINDON', '', 1, '9:00-9:25 (2nd, 4th)', 1, 1621, NULL, 31, 114, 0, 'Thursday, Tuesday', '8:00 - 9.30 (1st & 3rd Thurs and Tues after those Thurs)', 'TRUE', 0, 0, NULL, NULL),
(54, 4, 'Fittleworth', 'St Mary', 6, '7-0-0', 'TQ009193', 0, 0, 0, 'fittleworth@scacr.org', 'Church Lane', 'Fittleworth', 'West Sussex', 'RH20 1HL', 'UK', '-0.54534749999993', '50.93958070000000', '', '', 'dove.cccbr.org.uk/detail.php?searchString=Fittleworth&numPerPage=10&Submit=Go&searchAmount=%3D&searchMetric=cwt&sortBy=Place&sortDir=Asc&DoveID=FITTLEWORT', '', 1, '9:00-9:30', 1, 26, NULL, 25, 22, 0, 'Tuesday', '7:30', 'TRUE', 0, 0, NULL, NULL),
(55, 1, 'Fletching', 'SS Andrew & Mary the Virgin', 8, '10-0-9', 'TQ429235', 0, 0, 0, 'fletching@scacr.org', 'Church Street', 'Fletching, Uckfield', 'East Sussex', 'TN22 3SP', 'UK', '0.09692632858889', '50.97279945662750', '', 'www.fletchingparishchurch.org.uk/', 'dove.cccbr.org.uk/detail.php?searchString=Fletching&numPerPage=10&Submit=Go&searchAmount=%3D&searchMetric=cwt&sortBy=Place&sortDir=Asc&DoveID=FLETCHING', '', 1, '9:30-10:00', 1, 238, NULL, 0, 17, 0, 'Friday', '8:00-9:15', 'TRUE', 0, 0, NULL, NULL),
(56, 3, 'Flimwell', 'St Augustine of Canterbury', 4, '5-0-0', 'TQ725309', 0, 0, 0, '', '', '', '', '', 'UK', '0.00000000000000', '0.00000000000000', '', '', '', '', 1, '', 1, 0, NULL, 0, 0, 0, '', '', 'TRUE', 0, 0, NULL, NULL),
(57, 3, 'Frant', 'St Alban', 6, '8-0-12', 'TQ590357', 0, 0, 0, 'frant@scacr.org', 'Church Lane', 'Frant', 'East Sussex', 'TN3 9DX', 'UK', '0.26875749999999', '51.09773209999990', '', 'www.frant.info/home/community/directory/.../st-albans-frant.html', 'dove.cccbr.org.uk/detail.php?searchString=Frant&numPerPage=10&Submit=Go&searchAmount=%3D&searchMetric=cwt&sortBy=Place&sortDir=Asc&DoveID=FRANT', '', 1, '9:00-9:30', 1, 612, NULL, 0, 78, 0, 'Tuesday', '8:00-9:00 (irregular)', 'TRUE', 0, 0, NULL, NULL),
(58, 4, 'Funtington', 'St Mary', 6, '5-3-21', 'SU801082', 0, 0, 0, 'funtington@scacr.org', 'Church Lane', 'Funtington', 'West Sussex', 'PO18 9LH', 'UK', '-0.86364779947507', '50.86715809067390', '', 'www.funtington-parish.org.uk/', 'dove.cccbr.org.uk/detail.php?searchString=Funtington&numPerPage=10&Submit=Go&searchAmount=%3D&searchMetric=cwt&sortBy=Place&sortDir=Asc&DoveID=FUNTINGTON', '', 1, '10:30 (1st), 9:00 (2nd, 3rd, 4th)', 1, 863, NULL, 860, 115, 0, 'Tuesday', '7:30', 'TRUE', 0, 0, NULL, NULL),
(59, 4, 'Goring by Sea', 'St Mary', 6, '17-2-3', 'TQ111026', 0, 0, 0, 'goring@scacr.org', 'Ilex Way', 'Goring-by-Sea', 'West Sussex', 'BN12 4NY', 'UK', '-0.42452849521500', '50.81260163190000', '', 'www.goringbyseacofe.org.uk', 'dove.cccbr.org.uk/detail.php?searchString=Goring&numPerPage=10&Submit=Go&searchAmount=%3D&searchMetric=cwt&sortBy=Place&sortDir=Asc&DoveID=GORING+BY', '', 1, '9:00-9:30; 1st Sunday 9:15-10:00', 1, 65, NULL, 64, 116, 0, 'Tuesday', '7:30-9:00', 'TRUE', 1, 1, 844, '2018-01-02 14:44:02'),
(60, 4, 'Graffham', 'St Giles', 6, '9-1-26', 'SU929167', 0, 0, 0, 'graffham@scacr.org', 'A272', 'Graffham', 'West Sussex', 'GU28 0NJ', 'UK', '-0.67956575764163', '50.94328485789250', '', '', 'dove.cccbr.org.uk/detail.php?searchString=Graffham&numPerPage=10&Submit=Go&searchAmount=%3D&searchMetric=cwt&sortBy=Place&sortDir=Asc&DoveID=GRAFFHAM', '', 1, '9:55-10:20', 1, 973, NULL, 973, 117, 0, 'Tuesday', '7:30-9:00', 'TRUE', 0, 0, NULL, NULL),
(61, 3, 'Hailsham', 'St Mary', 8, '9-2-5', 'TQ591095', 0, 0, 0, 'hailsham@scacr.org', 'High Street', 'Hailsham', 'East Sussex', 'BN27 1BJ', 'UK', '0.26033202911378', '50.86279072809870', '', 'www.hailshamchurch.org/', 'dove.cccbr.org.uk/detail.php?searchString=Hailsham&numPerPage=10&Submit=Go&searchAmount=%3D&searchMetric=cwt&sortBy=Place&sortDir=Asc&DoveID=HAILSHAM', '', 1, '9:45, 5:45', 1, 641, NULL, 0, 40, 0, 'Monday', '7:30-9:15', 'TRUE', 0, 0, NULL, NULL),
(62, 1, 'Hammerwood', 'St Stephen', 6, '6-1-22', 'TQ439395', 0, 0, 0, 'hammerwood@scacr.org', 'A264', 'Hammerwood', 'East Sussex', 'RH19 3QB', 'UK', '0.05135670000004', '51.13724520000000', '', 'hammerwood.wordpress.com/', 'dove.cccbr.org.uk/detail.php?searchString=Hammerwood&numPerPage=10&Submit=Go&searchAmount=%3D&searchMetric=cwt&sortBy=Place&sortDir=Asc&DoveID=HAMMERWOOD', 'Church was closed in 2016.', 1, '9:30-10:00', 0, 998, NULL, 1228, 18, 0, '', '', 'TRUE', 0, 0, 838, '2017-07-31 21:44:40'),
(63, 1, 'Hartfield', 'St Mary', 6, '12-2-0', 'TQ479357', 0, 0, 0, 'hartfield@scacr.org', 'Church Street', 'Hartfield', 'East Sussex', 'TN7 4AG', 'UK', '0.11100250000004', '51.10168680000000', '', 'www.hartfieldchurch.org/', 'dove.cccbr.org.uk/detail.php?searchString=Hartfield&numPerPage=10&Submit=Go&searchAmount=%3D&searchMetric=cwt&sortBy=Place&sortDir=Asc&DoveID=HARTFIELD', '', 1, '', 1, 258, NULL, 274, 19, 0, 'Thursday', '', 'TRUE', 0, 0, NULL, NULL),
(64, 3, 'Hastings', 'All Saints', 8, '12-1-21', 'TQ828098', 0, 0, 0, 'hastingsas@scacr.org', 'All Saints Street', 'Hastings', 'East Sussex', 'TN34 3BP', 'UK', '0.59415139999999', '50.85787100000000', '', '', 'dove.cccbr.org.uk/detail.php?searchString=Hastings&numPerPage=10&Submit=Go&searchAmount=%3D&searchMetric=cwt&sortBy=Place&sortDir=Asc&DoveID=HASTING++A', '', 1, '9:30-10:00 (when church is in use)', 1, 535, NULL, 535, 79, 0, 'Saturday', '13:30-14:30 (alternate with St Clement)', 'TRUE', 0, 0, NULL, NULL),
(65, 3, 'Hastings (Blacklands)', 'Christ Church', 8, '20-2-20', 'TQ815106', 0, 0, 0, 'hastingsb@scacr.org', 'Laton Road', 'Hastings', 'East Sussex', 'TN34 2ES', 'UK', '0.57836929999996', '50.86652880000000', '', 'www.blacklands-parish.co.uk/', 'dove.cccbr.org.uk/detail.php?searchString=Hastings&numPerPage=10&Submit=Go&searchAmount=%3D&searchMetric=cwt&sortBy=Place&sortDir=Asc&DoveID=HASTING+BL', '', 1, '9:45-10:30', 1, 545, NULL, 545, 81, 0, 'Friday', '7:30', 'TRUE', 0, 0, NULL, NULL),
(66, 3, 'Hastings', 'St Clement', 8, '14-3-26', 'TQ824096', 0, 0, 0, 'hastingssc@scacr.org', 'Swan Terrace/High St', 'Hastings', 'East Sussex', 'TN34 3HP', 'UK', '0.59192729999995', '50.85789180000000', '', '', 'dove.cccbr.org.uk/detail.php?searchString=Hastings&numPerPage=10&Submit=Go&searchAmount=%3D&searchMetric=cwt&sortBy=Place&sortDir=Asc&DoveID=HASTING++C', '', 1, '9.30 -10:00 (when church is in use)', 1, 535, NULL, 535, 80, 0, 'Saturday', '13:30-14:30 (alternate with All Saints)', 'TRUE', 0, 0, NULL, NULL),
(67, 3, 'Heathfield', 'All Saints', 8, '11-0-8', 'TQ599203', 0, 0, 0, 'heathfield@scacr.org', 'School Hill', 'Heathfield', 'East Sussex', 'TN21 9AG', 'UK', '0.27616277619600', '50.95981292490000', '', 'www.allsaintsoldheathfield.org', 'dove.cccbr.org.uk/detail.php?searchString=Heathfield&numPerPage=10&Submit=Go&searchAmount=%3D&searchMetric=cwt&sortBy=Place&sortDir=Asc&DoveID=HEATHFLDSX', '', 1, '10:30-11:00', 1, 333, NULL, 333, 82, 0, 'Wednesday', '7:30-9:00', 'TRUE', 0, 0, 894, '2017-12-21 10:41:22'),
(68, 4, 'Heene', 'St Botolph', 8, '10-1-0', 'TQ137028', 0, 0, 0, 'heene@scacr.org', 'Lansdowne Rd', 'Worthing', 'West Sussex', 'BN11 4SG', 'UK', '-0.38623153565982', '50.81316298285970', '', 'www.stbotolphsheene.org.uk/', 'dove.cccbr.org.uk/detail.php?searchString=Heene&numPerPage=10&Submit=Go&searchAmount=%3D&searchMetric=cwt&sortBy=Place&sortDir=Asc&DoveID=WORTHING', '', 1, '9:15-10:00', 1, 85, NULL, 85, 118, 0, 'Wednesday', '7:30-9:00', 'TRUE', 0, 0, NULL, NULL),
(69, 3, 'Hellingly', 'SS Peter & Paul', 6, '11-2-18', 'TQ581123', 0, 0, 0, 'hellingly@scacr.org', 'Church Lane', 'Hellingly', 'East Sussex', 'BN27 4EZ', 'UK', '0.24620633016355', '50.88803598525920', '', '', 'dove.cccbr.org.uk/detail.php?searchString=Hellingly&numPerPage=10&Submit=Go&searchAmount=%3D&searchMetric=cwt&sortBy=Place&sortDir=Asc&DoveID=HELLINGLY', '', 1, '10:15', 1, 549, NULL, 550, 83, 0, 'Wednesday', '7:30-9:00', 'TRUE', 0, 0, NULL, NULL),
(70, 2, 'Henfield', 'St Peter', 8, '16-2-7', 'TQ213162', 0, 0, 0, 'henfield@scacr.org', 'Church Lane', 'Henfield', 'West Sussex', 'BN5 9NZ', 'UK', '-0.27649900052484', '50.93215449535800', '', 'henfield.org/', 'dove.cccbr.org.uk/detail.php?searchString=Henfield&numPerPage=10&Submit=Go&searchAmount=%3D&searchMetric=cwt&sortBy=Place&sortDir=Asc&DoveID=HENFIELD', '', 1, '9:15-10:00. Evenings by arrangement', 1, 980, NULL, 980, 49, 0, 'Wednesday', '7:45-9:00', 'TRUE', 0, 0, NULL, NULL),
(71, 3, 'Hooe', 'St Oswald', 5, '11-0-24', 'TQ683092', 0, 0, 0, 'hooe@scacr.org', 'Church Lane', 'Hooe', 'East Sussex', 'TN33 9HE', 'UK', '0.38948537882084', '50.85749723066100', '', 'www.ninfield.org.uk/', 'dove.cccbr.org.uk/detail.php?searchString=Hooe&numPerPage=10&Submit=Go&searchAmount=%3D&searchMetric=cwt&sortBy=Place&sortDir=Asc&DoveID=HOOE', '', 1, '10:45 - 11:15', 1, 1697, NULL, 1697, 84, 0, 'Saturday', '9:30am - 11:30am (phone to confirm)', 'TRUE', 0, 0, 838, '2017-12-02 21:49:21'),
(72, 1, 'Horsham', 'St Mary', 10, '22-2-24', 'TQ170302', 0, 0, 0, 'horsham@scacr.org', 'The Causeway', 'Horsham', 'West Sussex', 'RH12 1HF', 'UK', '-0.32893500000000', '51.06150000000000', '', 'www.stmaryshorsham.org.uk/', 'dove.cccbr.org.uk/detail.php?searchString=Horsham&numPerPage=10&Submit=Go&searchAmount=%3D&searchMetric=cwt&sortBy=Place&sortDir=Asc&DoveID=HORSHAM', '', 1, '8:45-9:30. 4.30-5.00.', 1, 589, NULL, 202, 20, 0, 'Tuesday', '7:30-9:15', 'TRUE', 0, 0, NULL, NULL),
(73, 2, 'Hurstpierpoint', 'Holy Trinity', 8, '12-3-6', 'TQ279164', 0, 0, 0, 'hurstpierpoint@scacr.org', 'High St/Brighton Rd', 'Hurstpierpoint', 'West Sussex', 'BN6 9TY', 'UK', '-0.18048739399410', '50.93363439690830', 'www.hurstpierpointbells.org.uk', 'www.hurstpierpointholytrinity.org/', 'dove.cccbr.org.uk/detail.php?searchString=Hurstpierpoint&numPerPage=10&Submit=Go&searchAmount=%3D&searchMetric=cwt&sortBy=Place&sortDir=Asc&DoveID=HURSTPIERP', '', 1, '8:45-9:45', 1, 304, NULL, 305, 50, 0, 'Thursday', '7:30-8:45', 'TRUE', 0, 0, NULL, NULL),
(74, 3, 'Icklesham', 'St Nicholas', 4, '7-0-0', 'TQ881164', 0, 0, 0, '', '', '', '', '', 'UK', '0.00000000000000', '0.00000000000000', '', '', '', '', 1, '', 1, 0, NULL, 0, 0, 0, '', '', 'TRUE', 0, 0, NULL, NULL),
(75, 3, 'Iden', 'All Saints', 6, '15-0-0', 'TQ915238', 0, 0, 0, 'iden@scacr.org', 'Rectory Lane', 'Iden', 'East Sussex', 'TN31 7XD', 'UK', '0.73486409999998', '50.96208170000000', '', 'www.idenvillage.co.uk/church.htm', 'dove.cccbr.org.uk/detail.php?searchString=Iden&numPerPage=10&Submit=Go&searchAmount=%3D&searchMetric=cwt&sortBy=Place&sortDir=Asc&DoveID=IDEN', '', 1, '9:00-9:30 (1st)', 1, 1693, NULL, 0, 86, 0, '', '', 'TRUE', 0, 0, 838, NULL),
(76, 1, 'Itchingfield', 'St Nicolas', 5, '6-3-5', 'TQ131290', 0, 0, 0, 'itchingfield@scacr.org', 'Fulfords Hill', 'Itchingfield', 'West Sussex', 'RH13 0NX', 'UK', '-0.38529800000003', '51.04951190000000', '', 'www.stnicolas.uk.net/Index.html', 'dove.cccbr.org.uk/detail.php?searchString=Itchingfield&numPerPage=10&Submit=Go&searchAmount=%3D&searchMetric=cwt&sortBy=Place&sortDir=Asc&DoveID=ITCHINGFIE', '', 1, '10:30 (1st, 3rd, 5th )', 1, 600, NULL, 135, 21, 0, 'Friday', '7:30-9:00', 'TRUE', 0, 0, NULL, NULL),
(77, 2, 'Keymer', 'SS Cosmas & Damian', 6, '7-0-4', 'TQ315153', 0, 0, 0, 'keymer@scacr.org', 'The Crescent', 'Keymer, Hassocks', 'West Sussex', 'BN6 8QL', 'UK', '-0.13061762963866', '50.92174931767430', '', '', 'dove.cccbr.org.uk/detail.php?searchString=Keymer&numPerPage=10&Submit=Go&searchAmount=%3D&searchMetric=cwt&sortBy=Place&sortDir=Asc&DoveID=KEYMER', '', 1, '9:00-9:45', 1, 660, NULL, 303, 51, 0, 'Wednesday', '7:30-8:45', 'TRUE', 0, 0, NULL, NULL),
(78, 4, 'Kirdford', 'St John the Baptist', 6, '14-2-0', 'TQ018265', 0, 0, 0, 'kirdford@scacr.org', 'Glasshouse Lane', 'Kirdford', 'West Sussex', 'RH14 0LT', 'UK', '-0.54969851207300', '51.02885707110000', '', 'www.stjohnkirdfordwithholytrinityplaistow.org.uk/pages/Kirdford-Plaistow-Ifold-Church-of-England-Home.html', 'dove.cccbr.org.uk/detail.php?searchString=Kirdford&numPerPage=10&Submit=Go&searchAmount=%3D&searchMetric=cwt&sortBy=Place&sortDir=Asc&DoveID=KIRDFORD', '', 1, '9:30 (except 1st)', 1, 1114, NULL, 0, 119, 0, 'Tuesday', '7:45-9:00 (1st & 3rd joint with Wisborough Green)', 'TRUE', 0, 0, 838, '2017-12-31 18:21:43'),
(79, 3, 'Laughton', 'All Saints', 6, '9-2-6', 'TQ500126', 0, 0, 0, 'laughton@scacr.org', 'Church Lane', 'Laughton', 'East Sussex', 'BN8 6AH', 'UK', '0.13272811639399', '50.89304774570080', '', '', 'dove.cccbr.org.uk/detail.php?searchString=Laughton&numPerPage=10&Submit=Go&searchAmount=%3D&searchMetric=cwt&sortBy=Place&sortDir=Asc&DoveID=LAUGHTON+S', '', 1, '10:00-10:30 (3rd,4th)', 1, 375, NULL, 384, 87, 0, 'Thursday', '7:30-8:30 (occasional)', 'TRUE', 0, 0, NULL, NULL),
(80, 2, 'Lewes (Cliffe)', 'St Thomas a Becket', 4, '7-0-0', 'TQ422103', 0, 0, 0, '', '', '', '', '', 'UK', '0.00000000000000', '0.00000000000000', '', '', '', '', 1, '', 1, 0, NULL, 0, 0, 0, '', '', 'TRUE', 0, 0, NULL, NULL),
(81, 2, 'Lewes (Southover)', 'St John the Baptist', 10, '17-1-20', 'TQ413096', 0, 0, 0, 'southover@scacr.org', 'Southover High Street', 'Lewes', 'East Sussex', 'BN7 1JA', 'UK', '0.00594931055912', '50.86900002751870', '', 'www.southover.org.uk/', 'dove.cccbr.org.uk/detail.php?searchString=Lewes&numPerPage=10&Submit=Go&searchAmount=%3D&searchMetric=cwt&sortBy=Place&sortDir=Asc&DoveID=LEWES++SOU', '', 1, '9:30-10:00, 6:00-6:30', 1, 431, NULL, 430, 52, 0, 'Tuesday', '7:30-9:00', 'TRUE', 0, 0, NULL, NULL),
(82, 1, 'Lindfield', 'All Saints', 8, '21-2-19', 'TQ349258', 0, 0, 0, 'lindfield@scacr.org', 'High St, Lindfield', 'Lindfield', 'West Sussex', 'RH16 2HS', 'UK', '-0.08064179999997', '51.01350800000000', '', 'www.allsaintslindfield.org/', 'dove.cccbr.org.uk/detail.php?searchString=Lindfield&numPerPage=10&Submit=Go&searchAmount=%3D&searchMetric=cwt&sortBy=Place&sortDir=Asc&DoveID=LINDFIELD', '', 1, '8:45-9:30 (1st, 3rd, 5th); 10:45-11:15 (2nd, 4th); 6:00-6:30 (all)', 1, 737, 'test_corresp@testmail.com', 196, 23, 0, 'Tuesday', '7:30-9:00', 'TRUE', 0, 0, NULL, NULL),
(83, 2, 'Little Horsted', 'St Michael & All Angels', 6, '11-2-21', 'TQ471183', 0, 0, 0, 'littlehorsted@scacr.org', 'Lewes Road', 'Little Horsted', 'East Sussex', 'TN22 5TS', 'UK', '0.09923040000001', '50.95662470000000', '', 'www.churchoftheholycrossuckfield.co.uk', 'dove.cccbr.org.uk/detail.php?searchString=Little+Horsted&numPerPage=10&Submit=Go&searchAmount=%3D&searchMetric=cwt&sortBy=Place&sortDir=Asc&DoveID=LITTLE+HRS', '', 1, '', 1, 1281, NULL, 0, 53, 0, 'Tuesday', '7:30-9:00 (please check)', 'TRUE', 0, 0, NULL, NULL),
(84, 4, 'Lodsworth', 'St Peter', 6, '6-2-12', 'SU931227', 0, 0, 0, 'lodsworth@scacr.org', 'Church Lane', 'Lodsworth', 'West Sussex', 'GU28 9DE', 'UK', '-0.67513601639405', '50.99708242690720', '', '', 'dove.cccbr.org.uk/detail.php?searchString=Lodsworth&numPerPage=10&Submit=Go&searchAmount=%3D&searchMetric=cwt&sortBy=Place&sortDir=Asc&DoveID=LODSWORTH', '', 1, '', 1, 767, NULL, 0, 120, 0, '', '', 'TRUE', 0, 0, NULL, NULL),
(85, 1, 'Lower Beeding', 'Holy Trinity', 8, '10-3-2', 'TQ220275', 0, 0, 0, 'lowerbeeding@scacr.org', 'Sandygate Lane', 'Lower Beeding', 'West Sussex', 'RH13 6NU', 'UK', '-0.26655170000004', '51.03111050000000', '', '', 'dove.cccbr.org.uk/detail.php?searchString=Lower+Beeding&numPerPage=10&Submit=Go&searchAmount=%3D&searchMetric=cwt&sortBy=Place&sortDir=Asc&DoveID=LOWER+BEED', '', 1, '9:30-10:00', 1, 731, NULL, 235, 24, 0, 'Thursday', '7:30-9:00', 'TRUE', 0, 0, NULL, NULL),
(86, 4, 'Lyminster', 'St Mary Magdalene', 6, '9-3-18', 'TQ023047', 0, 0, 0, 'lyminster@scacr.org', 'Church Lane', 'Lyminster', 'West Sussex', 'BN17 7QJ', 'UK', '-0.54898758308104', '50.83362392568490', '', '', 'dove.cccbr.org.uk/detail.php?searchString=Lyminster&numPerPage=10&Submit=Go&searchAmount=%3D&searchMetric=cwt&sortBy=Place&sortDir=Asc&DoveID=LYMINSTER', '', 1, '10:30-11:00', 1, 16, NULL, 16, 121, 0, 'Monday', '7:30-9:00 (1st & 3rd, alternate with Arundel)', 'TRUE', 0, 0, NULL, NULL),
(87, 2, 'Maresfield', 'St Bartholomew', 8, '14-1-5', 'TQ465240', 0, 0, 0, 'maresfield@scacr.org', 'Batts Bridge Road', 'Maresfield, Nr. Uckfield', 'East Sussex', 'TN22 2EJ', 'UK', '0.08302670000000', '50.99619460000000', '', 'www.maresfieldchurch.org/', 'dove.cccbr.org.uk/detail.php?searchString=Maresfield&numPerPage=10&Submit=Go&searchAmount=%3D&searchMetric=cwt&sortBy=Place&sortDir=Asc&DoveID=MARESFIELD', '', 1, '10:45-11:15 (please check)', 1, 970, NULL, 923, 54, 0, 'Monday', '8:00-9:00 (unfrequent - please check)', 'TRUE', 0, 0, NULL, NULL),
(88, 3, 'Mayfield', 'St Dunstan', 8, '19-2-26', 'TQ586270', 0, 0, 0, 'mayfield@scacr.org', 'High Street', 'Mayfield', 'East Sussex', 'TN20 6AQ', 'UK', '0.26059991429440', '51.02054884758930', '', 'www.stdunstansmayfield.org.uk/', 'dove.cccbr.org.uk/detail.php?searchString=Mayfield&numPerPage=10&Submit=Go&searchAmount=%3D&searchMetric=cwt&sortBy=Place&sortDir=Asc&DoveID=MAYFIELDSX', '', 1, '9:30-10:00', 1, 478, NULL, 388, 88, 0, 'Tuesday', '8:00-9:10', 'TRUE', 0, 0, NULL, NULL),
(89, 4, 'Midhurst', 'SS Mary Magdalene & Denys', 6, '10-2-8', 'SU887215', 0, 0, 0, 'midhurst@scacr.org', 'Church Hill', 'Midhurst', 'West Sussex', 'GU29 9NJ', 'UK', '-0.73725000000002', '50.98562200000000', '', 'www.midhurstparishchurch.net/', 'dove.cccbr.org.uk/detail.php?searchString=Midhurst&numPerPage=10&Submit=Go&searchAmount=%3D&searchMetric=cwt&sortBy=Place&sortDir=Asc&DoveID=MIDHURST', '', 1, '9:30-10:00 (1st, 2nd, 4th)', 1, 336, NULL, 337, 122, 0, 'Thursday', '7:30-9:00 (2nd, 4th)', 'TRUE', 0, 0, NULL, NULL),
(90, 4, 'Milland', 'St Luke', 6, '11-2-03', 'SU824283', 0, 0, 0, 'milland@scacr.org', 'B2070', 'Milland', 'West Sussex', 'GU30 7JL', 'UK', '-0.82532588261722', '51.04784015495700', '', 'www.stlukesmilland.org/', 'dove.cccbr.org.uk/detail.php?searchString=Milland&numPerPage=10&Submit=Go&searchAmount=%3D&searchMetric=cwt&sortBy=Place&sortDir=Asc&DoveID=MILLAND', '', 1, '10:15', 1, 858, NULL, 854, 123, 0, 'Thursday', '7:30-9:00', 'TRUE', 0, 0, NULL, NULL),
(91, 2, 'Newick', 'St Mary', 6, '5-0-27', 'TQ422208', 0, 0, 0, 'newick@scacr.org', 'Church Road', 'Newick', 'East Sussex', 'BN8 4JZ', 'UK', '0.01980200000003', '50.97269090000000', '', 'www.stmarysnewick.co.uk/', 'dove.cccbr.org.uk/detail.php?searchString=Newick&numPerPage=10&Submit=Go&searchAmount=%3D&searchMetric=cwt&sortBy=Place&sortDir=Asc&DoveID=NEWICK', '', 1, '10:00-10:30, 6:00-6:30', 1, 1613, NULL, 0, 55, 0, 'Wednesday', '7:30-8:30', 'TRUE', 0, 0, NULL, NULL),
(92, 4, 'Northchapel', 'St Michael & All Angels', 6, '3-0-0', 'SU953295', 0, 0, 0, 'northchapel@scacr.org', 'A283', 'Fisherstreet', 'West Sussex', 'GU28 9HP', 'UK', '-0.64331447141115', '51.05640753342390', '', '', 'dove.cccbr.org.uk/detail.php?searchString=Northchapel&numPerPage=10&Submit=Go&searchAmount=%3D&searchMetric=cwt&sortBy=Place&sortDir=Asc&DoveID=NORTHCHAPE', '', 1, '10:30', 1, 962, NULL, 342, 124, 0, 'Wednesday', '2nd and 4th Weds of the month (please call)', 'TRUE', 0, 0, NULL, NULL),
(93, 3, 'Northiam', 'St Mary', 6, '14-3-16', 'TQ830245', 0, 0, 0, 'northiam@scacr.org', 'Church Lane', 'Northiam', 'East Sussex', 'TN31 6NN', 'UK', '0.60634554180297', '50.99094483618130', '', 'www.northiamvillage.co.uk/St%20Mary%27s%20Church.html', 'dove.cccbr.org.uk/detail.php?searchString=Northiam&numPerPage=10&Submit=Go&searchAmount=%3D&searchMetric=cwt&sortBy=Place&sortDir=Asc&DoveID=NORTHIAM', '', 1, '9:45-10:20', 1, 377, NULL, 377, 89, 0, 'Tuesday', '7:30-9:00', 'TRUE', 0, 0, NULL, NULL),
(94, 4, 'Oving', 'St Andrew', 4, '7-0-0', 'SU901050', 0, 0, 0, '', '', '', '', '', 'UK', '0.00000000000000', '0.00000000000000', '', '', '', '', 1, '', 1, 0, NULL, 0, 0, 0, '', '', 'TRUE', 0, 0, NULL, NULL),
(95, 4, 'Pagham', 'St Thomas a Becket', 6, '7-2-7', 'SZ884975', 0, 0, 0, 'pagham@scacr.org', 'Church Lane', 'Pagham', 'West Sussex', 'PO21 4NU', 'UK', '-0.74832547829590', '50.77008379925700', '', 'www.paghamchurch.co.uk/', 'dove.cccbr.org.uk/detail.php?searchString=Pagham&numPerPage=10&Submit=Go&searchAmount=%3D&searchMetric=cwt&sortBy=Place&sortDir=Asc&DoveID=PAGHAM', '', 1, '9:15-9:40', 1, 78, NULL, 79, 125, 0, 'Monday', '7:30-9:00', 'TRUE', 0, 0, NULL, NULL),
(96, 3, 'Peasmarsh', 'SS Peter & Paul', 6, '9-1-4', 'TQ887218', 0, 0, 0, 'peasmarsh@scacr.org', 'Church Lane', 'Peasmarsh', 'East Sussex', 'TN31 6XS', 'UK', '0.68620018780518', '50.96502510854320', '', 'www.achurchnearyou.com/peasmarsh-st-peter-st-paul/', 'dove.cccbr.org.uk/detail.php?searchString=Peasmarsh&numPerPage=10&Submit=Go&searchAmount=%3D&searchMetric=cwt&sortBy=Place&sortDir=Asc&DoveID=PEASMARSH', '', 1, '9:30-10:00 (1st, 3rd)', 1, 579, NULL, 0, 90, 0, '', 'see Beckley', 'TRUE', 0, 0, NULL, NULL),
(97, 4, 'Petworth', 'St Mary', 8, '18-0-9', 'SU977218', 0, 0, 0, 'petworth@scacr.org', 'Church St', 'Petworth', 'West Sussex', 'GU28 0AE', 'UK', '-0.60994760849610', '50.98784436125450', '', '', 'dove.cccbr.org.uk/detail.php?searchString=Petworth&numPerPage=10&Submit=Go&searchAmount=%3D&searchMetric=cwt&sortBy=Place&sortDir=Asc&DoveID=PETWORTH', '', 1, '10:00-10:30', 1, 161, NULL, 0, 126, 0, 'Thursday', '7:45-9:15', 'TRUE', 0, 0, NULL, NULL),
(98, 3, 'Pevensey', 'St Nicolas', 6, '7-3-3', 'TQ647048', 0, 0, 0, 'pevensey@scacr.org', 'Church Lane', 'Pevensey', 'East Sussex', 'BN24 5LD', 'UK', '0.33729459999995', '50.81997860000000', '', '', 'dove.cccbr.org.uk/detail.php?searchString=Pevensey&numPerPage=10&Submit=Go&searchAmount=%3D&searchMetric=cwt&sortBy=Place&sortDir=Asc&DoveID=PEVENSEY', '', 1, '10:30-11:00', 1, 697, NULL, 697, 91, 0, 'Saturday', '10:00-11:00', 'TRUE', 0, 0, NULL, NULL),
(99, 4, 'Pulborough', 'St Mary', 8, '13-2-0', 'TQ047187', 0, 0, 0, 'pulborough@scacr.org', 'Church Place', 'Pulborough', 'West Sussex', 'RH20 1AE', 'UK', '-0.51054240052486', '50.95877498654850', '', 'www.stmaryspulborough.org.uk/', 'dove.cccbr.org.uk/detail.php?searchString=Pulborough&numPerPage=10&Submit=Go&searchAmount=%3D&searchMetric=cwt&sortBy=Place&sortDir=Asc&DoveID=PULBOROUGH', '', 1, '10:00-10:30', 1, 112, NULL, 145, 127, 0, 'Monday', '7:30-9:00 (not Bank Hol)', 'TRUE', 0, 0, NULL, NULL),
(100, 2, 'Ringmer', 'St Mary the Virgin', 8, '13-3-0', 'TQ446125', 0, 0, 0, 'ringmer@scacr.org', 'Church Hill', 'Ringmer', 'East Sussex', 'BN8 5JX', 'UK', '0.05398309999998', '50.89434070000000', 'www.ringmertower.org.uk/', 'www.ringmerchurch.org.uk', 'dove.cccbr.org.uk/detail.php?searchString=Ringmer&numPerPage=10&Submit=Go&searchAmount=%3D&searchMetric=cwt&sortBy=Place&sortDir=Asc&DoveID=RINGMER', '', 1, '9:00-9:40, 5:45-6:25 (except 1st & 3rd - Q.Peal)', 1, 319, NULL, 325, 56, 0, 'Wednesday', '7:30-9:00', 'TRUE', 0, 0, NULL, NULL),
(101, 3, 'Ripe', 'St John the Baptist', 5, '9-3-0', 'TQ514099', 0, 0, 0, 'ripe@scacr.org', 'Church Lane', 'Ripe', 'East Sussex', 'BN8 6AU', 'UK', '0.14926383102716', '50.86857741764580', '', '', 'dove.cccbr.org.uk/detail.php?searchString=Ripe&numPerPage=10&Submit=Go&searchAmount=%3D&searchMetric=cwt&sortBy=Place&sortDir=Asc&DoveID=RIPE', '', 1, '10:00 (2nd)', 1, 375, NULL, 0, 92, 0, '', '', 'TRUE', 0, 0, NULL, NULL),
(102, 2, 'Rodmell', 'St Peter', 6, '7-0-0', 'TQ421063', 0, 0, 0, '', '', '', '', '', 'UK', '0.00000000000000', '0.00000000000000', '', '', '', '', 1, '', 1, 0, NULL, 0, 0, 0, '', '', 'TRUE', 0, 0, NULL, NULL),
(103, 4, 'Rogate', 'St Bartholomew', 6, '8-1-21', 'SU807237', 0, 0, 0, 'rogate@scacr.org', 'A272', 'Rogate', 'West Sussex', 'GU31 5EA', 'UK', '-0.85035671318360', '51.00837180421470', '', '', 'dove.cccbr.org.uk/detail.php?searchString=Rogate&numPerPage=10&Submit=Go&searchAmount=%3D&searchMetric=cwt&sortBy=Place&sortDir=Asc&DoveID=ROGATE', '', 1, '9:30-10:15', 1, 14, NULL, 718, 128, 0, 'Thursday', '7:30-9:00', 'TRUE', 0, 0, NULL, NULL),
(104, 3, 'Rotherfield', 'St Denys', 8, '23-0-23', 'TQ556298', 0, 0, 0, 'rotherfield@scacr.org', 'Church Road', 'Rotherfield', 'East Sussex', 'TN6 3LG', 'UK', '0.21859350000000', '51.04651370000000', '', 'www.stdenysrotherfield.org.uk/', 'dove.cccbr.org.uk/detail.php?searchString=Rotherfield&numPerPage=10&Submit=Go&searchAmount=%3D&searchMetric=cwt&sortBy=Place&sortDir=Asc&DoveID=ROTHERFIEL', '', 1, '9:30-10:00', 1, 450, NULL, 450, 93, 0, 'Monday', '8:00-9:30', 'TRUE', 0, 0, 866, '2017-12-12 10:22:04'),
(105, 1, 'Rudgwick', 'Holy Trinity', 8, '14-0-5', 'TQ091343', 0, 0, 0, 'rudgwick@scacr.org', 'Church Street', 'Rudgwick', 'West Sussex', 'RH12 3EB', 'UK', '-0.44541380000000', '51.09403090000000', '', 'rudgwick.churchinsight.com/.../Rudgwick/Holy_Trinity_Church/Chu..', 'dove.cccbr.org.uk/detail.php?searchString=Rudgwick&numPerPage=10&Submit=Go&searchAmount=%3D&searchMetric=cwt&sortBy=Place&sortDir=Asc&DoveID=RUDGWICK', '', 1, '10:00', 1, 1514, NULL, 190, 37, 0, 'Tuesday', '7:30-9:00', 'TRUE', 0, 0, 838, '2018-01-01 21:15:47');
INSERT INTO `c1jr0_md_tower` (`id`, `district_id`, `place`, `designation`, `bells`, `tenor`, `grid_ref`, `ground_floor`, `anti_clockwise`, `unringable`, `email`, `street`, `town`, `county`, `post_code`, `country`, `longitude`, `latitude`, `website`, `church_website`, `doves_guide`, `tower_description`, `wc`, `sunday_ringing`, `active`, `correspondent_id`, `corresp_email`, `captain_id`, `web_tower_id`, `multi_towers`, `practice_night`, `practice_details`, `field1`, `incl_capt`, `incl_corresp`, `mod_user_id`, `mod_date`) VALUES
(106, 1, 'Rusper', 'St Mary Magdalene', 8, '12-2-0', 'TQ205373', 0, 0, 0, 'rusper@scacr.org', 'High Street', 'Rusper', 'West Sussex', 'RH12 4PX', 'UK', '-0.27906899999994', '51.12248460000000', '', 'www.rusperchurch.co.uk/', 'dove.cccbr.org.uk/detail.php?searchString=Rusper&numPerPage=10&Submit=Go&searchAmount=%3D&searchMetric=cwt&sortBy=Place&sortDir=Asc&DoveID=RUSPER', '', 1, '10:30-11:00am (except 5th, please check)', 1, 255, NULL, 255, 26, 0, 'Thursday', '7:45-9:15', 'TRUE', 0, 0, NULL, NULL),
(107, 3, 'Rye', 'St Mary the Virgin', 8, '19-2-2', 'TQ921203', 0, 0, 0, 'rye@scacr.org', 'Church Square', 'Rye', 'East Sussex', 'TN31 7HE', 'UK', '0.73432500000001', '50.94975350000000', '', 'ryeparishchurch.org.uk/', 'dove.cccbr.org.uk/detail.php?searchString=Rye&numPerPage=10&Submit=Go&searchAmount=%3D&searchMetric=cwt&sortBy=Place&sortDir=Asc&DoveID=RYE', '', 1, '9:45-10:30', 1, 816, NULL, 569, 94, 0, 'Thursday', '7:30-9:00', 'TRUE', 0, 0, NULL, NULL),
(108, 3, 'Salehurst', 'St Mary the Virgin', 8, '18-1-26', 'TQ749242', 0, 0, 0, 'salehurst@scacr.org', 'Church Lane', 'Salehurst', 'East Sussex', 'TN32 5PJ', 'UK', '0.49048379999999', '50.99085220000000', '', '', 'dove.cccbr.org.uk/detail.php?searchString=Salehurst&numPerPage=10&Submit=Go&searchAmount=%3D&searchMetric=cwt&sortBy=Place&sortDir=Asc&DoveID=SALEHURST', '', 1, '10:30', 1, 1289, NULL, 489, 96, 0, 'Wednesday', '7:30-9:00', 'TRUE', 0, 0, NULL, NULL),
(109, 2, 'Seaford', 'St Leonard', 8, '13-2-0', 'TV483990', 0, 0, 0, 'seaford@scacr.org', 'Church St/Place Lane', 'Seaford', 'East Sussex', 'BN25 1HH', 'UK', '0.10152760000005', '50.77227749999990', '', 'www.seafordparish.org.uk/', 'dove.cccbr.org.uk/detail.php?searchString=Seaford&numPerPage=10&Submit=Go&searchAmount=%3D&searchMetric=cwt&sortBy=Place&sortDir=Asc&DoveID=SEAFORD', '', 1, '8:45-9:30', 1, 791, NULL, 553, 57, 0, 'Tuesday', '7:30-9:00', 'TRUE', 0, 0, NULL, NULL),
(110, 3, 'Sedlescombe', 'St John the Baptist', 6, '10-0-0', 'TQ777188', 0, 0, 0, 'sedlescombe@scacr.org', 'Church Hill', 'Sedlescombe', 'East Sussex', 'TN33 0QP', 'UK', '0.57353119999993', '50.90832820000000', '', 'www.sedlescombeparishchurch.com/', 'dove.cccbr.org.uk/detail.php?searchString=Sedlescombe&numPerPage=10&Submit=Go&searchAmount=%3D&searchMetric=cwt&sortBy=Place&sortDir=Asc&DoveID=SEDLESCOMB', '', 1, '9:45 (2nd,4th)', 1, 455, NULL, 455, 97, 0, 'Wednesday', '7:30', 'TRUE', 0, 0, NULL, NULL),
(111, 4, 'Shipley', 'St Mary the Virgin', 6, '9-3-0', 'TQ145218', 0, 0, 0, 'shipley@scacr.org', 'Church Close', 'Shipley', 'West Sussex', 'RH13 8PJ', 'UK', '-0.36942680000004', '50.98456140000000', '', '', 'dove.cccbr.org.uk/detail.php?searchString=Shipley&numPerPage=10&Submit=Go&searchAmount=%3D&searchMetric=cwt&sortBy=Place&sortDir=Asc&DoveID=SHIPLEY+S', '', 1, '9:30-10:00', 1, 694, NULL, 693, 129, 0, 'Wednesday', '7:30-9:00', 'TRUE', 0, 1, 838, '2017-12-02 21:28:09'),
(112, 2, 'Shoreham by Sea', 'St Mary de Haura', 8, '14-0-16', 'TQ216051', 0, 0, 0, 'shoreham@scacr.org', 'St Mary\\\'s Road', 'Shoreham-by-Sea', 'West Sussex', 'BN43 5ZB', 'UK', '-0.27330210000002', '50.83309440000000', '', 'www.stmarydehaura.org.uk/', 'dove.cccbr.org.uk/detail.php?searchString=Shoreham&numPerPage=10&Submit=Go&searchAmount=%3D&searchMetric=cwt&sortBy=Place&sortDir=Asc&DoveID=SHOREHAMBS', '', 1, '9:15-10:00', 1, 412, NULL, 0, 58, 0, 'Tuesday', '7:45-9:15', 'TRUE', 0, 0, NULL, NULL),
(113, 1, 'Slaugham', 'St Mary', 8, '11-1-20', 'TQ257281', 0, 0, 0, 'slaugham@scacr.org', 'Staplefield Lane', 'Slaugham', 'West Sussex', 'RH17 6AQ', 'UK', '-0.19108840000001', '51.02436360000000', '', 'www.stmarysparish.org.uk/', 'dove.cccbr.org.uk/detail.php?searchString=Slaugham&numPerPage=10&Submit=Go&searchAmount=%3D&searchMetric=cwt&sortBy=Place&sortDir=Asc&DoveID=SLAUGHAM', '', 1, '9:45-10:30', 1, 922, NULL, 632, 27, 0, 'Friday', '8:00-9:15', 'TRUE', 0, 0, NULL, NULL),
(114, 4, 'Slindon', 'St Mary', 4, '7-0-0', 'SU961083', 0, 0, 0, 'slindon@scacr.org', 'Church Hill', 'Slindon', 'West Sussex', 'BN18 0RB', 'UK', '-0.63536607619631', '50.86668311046860', '', '', 'dove.cccbr.org.uk/detail.php?searchString=Slindon&numPerPage=10&Submit=Go&searchAmount=%3D&searchMetric=cwt&sortBy=Place&sortDir=Asc&DoveID=SLINDON', '', 1, 'Variable', 1, 146, NULL, 146, 130, 0, 'Monday', '7:00-8:00', 'TRUE', 0, 0, NULL, NULL),
(115, 1, 'Slinfold', 'St Peter', 6, '11-1-3', 'TQ117316', 0, 0, 0, 'slinfold@scacr.org', 'The Street', 'Slinfold', 'West Sussex', 'RH17 0RR', 'UK', '-0.40613504307703', '51.07230988742470', '', 'www.stpeterslinfold.co.uk/', 'dove.cccbr.org.uk/detail.php?searchString=Slinfold&numPerPage=10&Submit=Go&searchAmount=%3D&searchMetric=cwt&sortBy=Place&sortDir=Asc&DoveID=SLINFOLD', '', 1, '9:00-9:30', 1, 275, NULL, 275, 28, 0, 'Wednesday', '7:30-9:00', 'TRUE', 0, 0, NULL, NULL),
(116, 4, 'South Harting', 'SS Mary and Gabriel', 6, '12-0-0', 'SU783194', 0, 0, 0, 'southharting@scacr.org', 'The Street', 'South Harting', 'West Sussex', 'GU31 5QF', 'UK', '-0.88461537567139', '50.96879411683980', '', 'www.harting.org.uk/', 'dove.cccbr.org.uk/detail.php?searchString=South+Harting&numPerPage=10&Submit=Go&searchAmount=%3D&searchMetric=cwt&sortBy=Place&sortDir=Asc&DoveID=SOUTH+HART', '', 1, '9:20', 1, 684, NULL, 344, 131, 0, 'Tuesday', '7:30', 'TRUE', 0, 0, NULL, NULL),
(117, 3, 'St Leonards on Sea', 'Christ Church', 8, '20-0-0', 'TQ802091', 0, 0, 0, 'stleonards@scacr.org', 'London Road', 'St Leonards-on-Sea', 'East Sussex', 'TN37 6GL', 'UK', '0.55717379999999', '50.85940340000000', '', '', 'dove.cccbr.org.uk/detail.php?searchString=St+Leonards&numPerPage=10&Submit=Go&searchAmount=%3D&searchMetric=cwt&sortBy=Place&sortDir=Asc&DoveID=SAI+LEONAR', '', 1, '9:30', 1, 736, NULL, 536, 95, 0, 'Monday', '7:00', 'TRUE', 0, 0, NULL, NULL),
(118, 4, 'Stedham', 'St James', 6, '9-3-11', 'SU863225', 1, 0, 0, 'stedham@scacr.org', 'Mill Lane', 'Stedham', 'West Sussex', 'GU29 0PS', 'UK', '-0.77045224498300', '50.99634070510000', '', '', 'dove.cccbr.org.uk/detail.php?searchString=Stedham&numPerPage=10&Submit=Go&searchAmount=%3D&searchMetric=cwt&sortBy=Place&sortDir=Asc&DoveID=STEDHAM', '', 0, 'None at present', 1, 1194, NULL, 10, 132, 0, '', 'No set practice', 'TRUE', 0, 0, 850, '2018-01-02 07:55:21'),
(119, 4, 'Steyning', 'St Andrew & St Cuthman', 8, '12-1-16', 'TQ179071', 0, 0, 0, 'steyning@scacr.org', 'Vicarage Lane', 'Steyning', 'West Sussex', 'BN44 3YQ', 'UK', '-0.32396080000001', '50.89010940000000', '', '', 'dove.cccbr.org.uk/detail.php?searchString=Steyning&numPerPage=10&Submit=Go&searchAmount=%3D&searchMetric=cwt&sortBy=Place&sortDir=Asc&DoveID=STEYNING', '', 1, '9:00-9:30, Evening by arrangement', 1, 390, NULL, 391, 5, 0, 'Thursday', '7:45-9:15', 'TRUE', 0, 0, NULL, NULL),
(120, 4, 'Storrington', 'St Mary', 6, '9-1-7', 'TQ086141', 0, 0, 0, 'storrington@scacr.org', 'Church St', 'Storrington', 'West Sussex', 'RH20 4LL', 'UK', '-0.45722722911376', '50.91641943169830', '', 'www.storringtonparishchurch.org.uk/', 'dove.cccbr.org.uk/detail.php?searchString=Storrington&numPerPage=10&Submit=Go&searchAmount=%3D&searchMetric=cwt&sortBy=Place&sortDir=Asc&DoveID=STORRINGT4', '', 1, '9:30-10:00, 5:30-6:00', 1, 110, NULL, 105, 133, 0, 'Friday', '7:45-9:30', 'TRUE', 0, 0, NULL, NULL),
(121, 4, 'Stoughton', 'St Mary', 6, '10-0-0', 'SU801115', 0, 0, 0, 'stoughton@scacr.org', 'B2146', 'Stoughton', 'West Sussex', 'PO18 9JJ', 'UK', '-0.86207907391361', '50.89800988028370', '', 'www.octagon-parishes.org.uk/ourchurches.htm', 'dove.cccbr.org.uk/detail.php?searchString=Stoughton&numPerPage=10&Submit=Go&searchAmount=%3D&searchMetric=cwt&sortBy=Place&sortDir=Asc&DoveID=STOUGHTONS', '', 1, '9:25-9:55 (1st,& 3rd)', 1, 223, NULL, 225, 134, 0, 'Wednesday', '7:30-9:00', 'TRUE', 0, 0, NULL, NULL),
(122, 4, 'Thakeham', 'St Mary', 6, '9-1-3', 'TQ110173', 0, 0, 0, 'thakeham@scacr.org', 'The Street', 'Thakeham', 'West Sussex', 'RH20 3ER', 'UK', '-0.42197565711672', '50.94469993088050', '', 'www.thakehamchurch.typepad.com/', 'dove.cccbr.org.uk/detail.php?searchString=Thakeham&numPerPage=10&Submit=Go&searchAmount=%3D&searchMetric=cwt&sortBy=Place&sortDir=Asc&DoveID=THAKEHAM', '', 1, '9:10-9:40', 1, 1545, NULL, 551, 135, 0, 'Wednesday', '7:30-9:00', 'TRUE', 0, 0, NULL, NULL),
(123, 3, 'Ticehurst', 'St Mary', 6, '15-1-16', 'TQ689301', 0, 0, 0, 'ticehurst@scacr.org', 'Church St/St Mary\\\'s Lane', 'Ticehurst', 'East Sussex', 'TN5 7AB', 'UK', '0.40778717829585', '51.04539246655870', '', 'ticehurst.ticehurstflimwellchurch.org.uk/', 'dove.cccbr.org.uk/detail.php?searchString=Ticehurst&numPerPage=10&Submit=Go&searchAmount=%3D&searchMetric=cwt&sortBy=Place&sortDir=Asc&DoveID=TICEHURST', '', 1, '10:30', 1, 629, NULL, 567, 98, 0, 'Monday', '7:30', 'TRUE', 0, 0, NULL, NULL),
(124, 4, 'Tillington', 'All Hallows', 5, '6-1-10', 'SU963220', 0, 0, 0, 'tillington@scacr.org', 'Upperton Rd', 'Tillington', 'West Sussex', 'GU28 9AF', 'UK', '-0.62931803383788', '50.98900084533040', '', 'www.tillington.net/', 'dove.cccbr.org.uk/detail.php?searchString=Tillington&numPerPage=10&Submit=Go&searchAmount=%3D&searchMetric=cwt&sortBy=Place&sortDir=Asc&DoveID=TILLINGTON', '', 1, '10:45-11:15 (1st), 9:15-9:45 (others)', 1, 928, NULL, 165, 136, 0, 'Tuesday', '7:45-9:00 (please phone)', 'TRUE', 0, 0, NULL, NULL),
(125, 4, 'Trotton', 'St George', 4, '8-0-0', 'SU837225', 0, 0, 0, 'trotton@scacr.org', 'A272', 'Trotton', 'West Sussex', 'GU31 5EN', 'UK', '-0.80973179141847', '50.99565140771310', '', '', 'dove.cccbr.org.uk/detail.php?searchString=Trotton&numPerPage=10&Submit=Go&searchAmount=%3D&searchMetric=cwt&sortBy=Place&sortDir=Asc&DoveID=TROTTON', '', 1, '5th only (ring to confirm)', 1, 14, NULL, 1628, 137, 0, '', '', 'TRUE', 0, 0, NULL, NULL),
(126, 1, 'Turners Hill', 'St Leonards', 8, '13-3-27', 'TQ337353', 0, 0, 0, 'turnershill@scacr.org', 'Church Road', 'Turners Hill', 'West Sussex', 'RH10 4PB', 'UK', '-0.08861019999995', '51.10247600000000', '', 'www.stleonard-turnershill.org.uk/', 'dove.cccbr.org.uk/detail.php?searchString=Turners+Hill&numPerPage=10&Submit=Go&searchAmount=%3D&searchMetric=cwt&sortBy=Place&sortDir=Asc&DoveID=TURNERS+HI', '', 1, '10:00-10:30 (1st, 3rd)', 1, 881, NULL, 881, 29, 0, 'Tuesday', '7:30-8:30 (phone to confirm)', 'TRUE', 0, 0, NULL, NULL),
(127, 2, 'Twineham', 'St Peter', 5, '6-3-22', 'TQ253199', 0, 0, 0, 'twineham@scacr.org', 'Twineham Lane (Church Lane)', 'Twineham', 'West Sussex', 'RH17 5NR', 'UK', '-0.21741999999995', '50.96570000000000', '', '', 'dove.cccbr.org.uk/detail.php?searchString=Twineham&numPerPage=10&Submit=Go&searchAmount=%3D&searchMetric=cwt&sortBy=Place&sortDir=Asc&DoveID=TWINEHAM', '', 1, '9:30-10:00 (4th), 5:15-6:00 (1st)', 1, 960, NULL, 960, 59, 0, 'Friday', '7:30-9:00 (1st, 3rd, 5th)', 'TRUE', 0, 0, NULL, NULL),
(128, 2, 'Uckfield', 'Holy Cross', 8, '11-3-24', 'TQ472214', 0, 0, 0, 'uckfield@scacr.org', 'Church St/Belmont Rd, Uckfield', 'Uckfield', 'East Sussex', 'TN22 1BS', 'UK', '-81.02700720000000', '35.24337910000000', '', 'www.churchoftheholycrossuckfield.co.uk', 'dove.cccbr.org.uk/detail.php?searchString=Uckfield&numPerPage=10&Submit=Go&searchAmount=%3D&searchMetric=cwt&sortBy=Place&sortDir=Asc&DoveID=UCKFIELD', '', 1, '9:00-9:30, exc 2nd Sun 9:30-10:00', 1, 1281, NULL, 795, 60, 0, 'Tuesday', '7:30-9:00', 'TRUE', 0, 0, NULL, NULL),
(129, 3, 'Unattached (E)', '', 0, '', '', 0, 0, 0, '', '', '', '', '', 'UK', '0.00000000000000', '0.00000000000000', '', '', '', '', 1, '', 1, 0, NULL, 0, 0, 0, '', '', 'TRUE', 0, 0, NULL, NULL),
(130, 1, 'Unattached (N)', '', 0, '', '', 0, 0, 0, '', '', '', '', '', 'UK', '0.00000000000000', '0.00000000000000', '', '', '', '', 1, '', 1, 0, NULL, 0, 0, 0, '', '', 'TRUE', 0, 0, NULL, NULL),
(131, 2, 'Unattached (S)', '', 0, '', '', 0, 0, 0, '', '', '', '', '', 'UK', '0.00000000000000', '0.00000000000000', '', '', '', '', 1, '', 1, 0, NULL, 0, 0, 0, '', '', 'TRUE', 0, 0, NULL, NULL),
(132, 4, 'Unattached (W)', '', 0, '', '', 0, 0, 0, '', '', '', '', '', 'UK', '0.00000000000000', '0.00000000000000', '', '', '', '', 1, '', 1, 0, NULL, 0, 0, 0, '', '', 'TRUE', 0, 0, NULL, NULL),
(133, 4, 'Upper Beeding', 'St Peter', 6, '8-0-0', 'TQ193112', 0, 0, 0, 'upperbeeding@scacr.org', 'Church Lane', 'Upper Beeding', 'West Sussex', 'BN44 3HP', 'UK', '-0.30574175291747', '50.88717026726540', '', 'www.3bsparish.co.uk/', 'dove.cccbr.org.uk/detail.php?searchString=Upper+Beeding&numPerPage=10&Submit=Go&searchAmount=%3D&searchMetric=cwt&sortBy=Place&sortDir=Asc&DoveID=UPPER+BEED', '', 1, '', 1, 766, NULL, 766, 138, 0, 'Wednesday', '7:30-9:00 (please call)', 'TRUE', 0, 0, NULL, NULL),
(134, 3, 'Wadhurst', 'SS Peter & Paul', 8, '12-1-15', 'TQ641319', 0, 0, 0, 'wadhurst@scacr.org', 'B2099', 'Wadhurst', 'East Sussex', 'TN5 6AR', 'UK', '0.34000746610104', '51.06197468353260', '', 'www.wadhurstparishchurch.org/', 'dove.cccbr.org.uk/detail.php?searchString=Wadhurst&numPerPage=10&Submit=Go&searchAmount=%3D&searchMetric=cwt&sortBy=Place&sortDir=Asc&DoveID=WADHURST', '', 1, '9:15', 1, 476, NULL, 481, 99, 0, 'Wednesday', '7:30-9:00', 'TRUE', 0, 0, NULL, NULL),
(135, 4, 'Walberton', 'St Mary', 6, '10-3-15', 'SU972057', 0, 0, 0, 'walberton@scacr.org', 'Binsted Lane', 'Walberton', 'West Sussex', 'BN18 0FH', 'UK', '-0.62155779493412', '50.84334709977720', '', '', 'dove.cccbr.org.uk/detail.php?searchString=Walberton&numPerPage=10&Submit=Go&searchAmount=%3D&searchMetric=cwt&sortBy=Place&sortDir=Asc&DoveID=WARBLETON', '', 1, '5:15-5:55', 1, 23, NULL, 23, 139, 0, 'Thursday', '7:30-9:00', 'TRUE', 0, 0, NULL, NULL),
(136, 3, 'Waldron', 'All Saints', 8, '12-0-7', 'TQ549193', 0, 0, 0, 'waldron@scacr.org', 'Opposite The Star', 'Waldron', 'East Sussex', 'TN21 0RA', 'UK', '0.20416216289061', '50.95151480968350', '', 'www.heathfield.net/.../churches/east.../all-saints-waldron-church-of.../', 'dove.cccbr.org.uk/detail.php?searchString=Waldron&numPerPage=10&Submit=Go&searchAmount=%3D&searchMetric=cwt&sortBy=Place&sortDir=Asc&DoveID=WALDRON', '', 1, 'By arrangement', 1, 494, NULL, 496, 100, 0, 'Monday', '7:30-9:00', 'TRUE', 0, 0, NULL, NULL),
(137, 3, 'Warbleton', 'St Mary the Virgin', 6, '10-0-9', 'TQ609182', 0, 0, 0, 'warbleton@scacr.org', 'Church Hill', 'Warbleton', 'East Sussex', 'TN21 9BD', 'UK', '0.28861851015631', '50.94067173028110', '', 'www.warbleton.org/churches.html', 'dove.cccbr.org.uk/detail.php?searchString=Warbleton&numPerPage=10&Submit=Go&searchAmount=%3D&searchMetric=cwt&sortBy=Place&sortDir=Asc&DoveID=WARBLETON', '', 1, '10:30', 1, 367, NULL, 367, 101, 0, 'Monday', '7:00 at Dallington', 'TRUE', 0, 0, NULL, NULL),
(138, 1, 'Warnham', 'St Margaret', 10, '14-2-11', 'TQ158336', 0, 0, 0, 'warnham@scacr.org', 'Church Street', 'Warnham', 'West Sussex', 'RH12 3QW', 'UK', '-0.34818880000000', '51.08987620000000', '', '', 'dove.cccbr.org.uk/detail.php?searchString=Warnham&numPerPage=10&Submit=Go&searchAmount=%3D&searchMetric=cwt&sortBy=Place&sortDir=Asc&DoveID=WARNHAM', '', 1, '9:15-10:00; 5:30 (Quarter peal)', 1, 260, NULL, 260, 30, 0, 'Thursday', '7:30-9:30', 'TRUE', 0, 0, NULL, NULL),
(139, 4, 'Washington', 'St Mary', 6, '9-2-5', 'TQ118128', 0, 0, 0, 'washington@scacr.org', 'The Street', 'Washington', 'West Sussex', 'RH20 4AS', 'UK', '-0.41051445927735', '50.90445557239030', '', '', 'dove.cccbr.org.uk/detail.php?searchString=Washington&numPerPage=10&Submit=Go&searchAmount=%3D&searchMetric=cwt&sortBy=Place&sortDir=Asc&DoveID=WASHINGTSX', '', 1, '8:30 (Subject to change. Please ring to confirm)', 1, 28, NULL, 28, 140, 0, 'Tuesday', '8:00-9:30', 'TRUE', 0, 0, NULL, NULL),
(140, 1, 'West Grinstead', 'St George', 6, '8-0-7', 'TQ171206', 0, 0, 0, 'westgrinstead@scacr.org', 'Off Steyning Rd', 'West Grinstead', 'West Sussex', 'RH13 8LR', 'UK', '-0.32872550000002', '50.97775060000000', '', 'westgrinstead.org.uk/wp/st-georges/', 'dove.cccbr.org.uk/detail.php?searchString=West+Grinstead&numPerPage=10&Submit=Go&searchAmount=%3D&searchMetric=cwt&sortBy=Place&sortDir=Asc&DoveID=WEST+GRINS', '', 1, '10:30-11:00', 1, 285, NULL, 286, 32, 0, 'Thursday', '8:00-9:30', 'TRUE', 0, 0, NULL, NULL),
(141, 1, 'West Hoathly', 'St Margaret', 6, '11-1-7', 'TQ363326', 0, 0, 0, 'westhoathly@scacr.org', 'North Lane', 'West Hoathly', 'West Sussex', 'RH19 4PP', 'UK', '-0.05519030000005', '51.07733220000000', '', 'www.westhoathly.org.uk/', 'dove.cccbr.org.uk/detail.php?searchString=West+Hoathly&numPerPage=10&Submit=Go&searchAmount=%3D&searchMetric=cwt&sortBy=Place&sortDir=Asc&DoveID=WEST+HOATH', '', 1, '9:30-10:00 (irregular)', 1, 173, NULL, 175, 38, 0, 'Thursday', 'Thursday, alternately with Ardingly. Please check first by emailing the tower contact or phoning 01342 810112.', 'TRUE', 0, 0, NULL, NULL),
(142, 4, 'West Tarring', 'St Andrew', 6, '8-3-26', 'TQ131040', 0, 0, 0, 'westtarring@scacr.org', 'Church Rd', 'West Tarring', 'West Sussex', 'BN13 1HQ', 'UK', '-0.39604655396727', '50.82419776729720', '', 'www.st-andrews-west-tarring.org.uk/', 'dove.cccbr.org.uk/detail.php?searchString=West+Tarring&numPerPage=10&Submit=Go&searchAmount=%3D&searchMetric=cwt&sortBy=Place&sortDir=Asc&DoveID=WEST+TARRI', '', 1, '9:15-9:55; evening ringing by arrangement', 1, 209, NULL, 56, 142, 0, 'Monday', '', 'TRUE', 0, 0, NULL, NULL),
(143, 4, 'Westbourne', 'St John the Baptist', 8, '10-1-12', 'SU756073', 0, 0, 0, 'westbourne@scacr.org', 'Westbourne Road', 'Westbourne', 'West Sussex', 'PO10 8UL', 'UK', '-0.92778726452639', '50.86047333134920', '', 'www.westbourneparish.org.uk/', 'dove.cccbr.org.uk/detail.php?searchString=Westbourne&numPerPage=10&Submit=Go&searchAmount=%3D&searchMetric=cwt&sortBy=Place&sortDir=Asc&DoveID=WESTBOURNE', '', 1, '9:00-9:30; 5:30-6:00', 1, 95, NULL, 99, 141, 0, 'Monday', '7:30-9:00', 'TRUE', 0, 0, NULL, NULL),
(144, 3, 'Westham', 'St Mary', 6, '10-1-10', 'TQ641046', 0, 0, 0, 'westham@scacr.org', 'High Street, Westham', 'Westham', 'East Sussex', 'BN24 5LL', 'UK', '0.33088629999997', '50.81870290000000', '', '', 'dove.cccbr.org.uk/detail.php?searchString=Westham&numPerPage=10&Submit=Go&searchAmount=%3D&searchMetric=cwt&sortBy=Place&sortDir=Asc&DoveID=WESTHAM', '', 1, '9:10-9:45', 1, 475, NULL, 1291, 102, 0, 'Wednesday', 'Alternate. 7:30', 'TRUE', 0, 0, NULL, NULL),
(145, 3, 'Willingdon', 'St Mary', 6, '10-1-14', 'TQ589025', 0, 0, 0, 'willingdon@scacr.org', 'Church St', 'Willingdon', 'East Sussex', 'BN20 9HT', 'UK', '0.25343108616948', '50.79968916572160', 'www.eastbourneringers.org.uk/', '', 'dove.cccbr.org.uk/detail.php?searchString=Willingdon&numPerPage=10&Submit=Go&searchAmount=%3D&searchMetric=cwt&sortBy=Place&sortDir=Asc&DoveID=WILLINGDON', '', 1, '6:00-6:30', 1, 378, NULL, 0, 103, 0, 'Thursday', '7:30-8:30', 'TRUE', 0, 0, NULL, NULL),
(146, 4, 'Wisborough Green', 'St Peter ad Vincula', 6, '12-0-21', 'TQ052258', 0, 0, 0, 'wisboroughgreen@scacr.org', 'A272', 'Wisborough Green', 'West Sussex', 'RH14 0DZ', 'UK', '-0.50193523902590', '51.02237891772400', '', 'www.wisboroughgreen.org/', 'dove.cccbr.org.uk/detail.php?searchString=Wisborough+Green&numPerPage=10&Submit=Go&searchAmount=%3D&searchMetric=cwt&sortBy=Place&sortDir=Asc&DoveID=WISBOROUGH', '', 1, '10:00-10:30', 1, 734, NULL, 116, 143, 0, 'Tuesday', '8:00-9:00 (2nd & 4th)', 'TRUE', 0, 0, NULL, NULL),
(147, 1, 'Withyham', 'St Michael & All Angels', 8, '15-0-9', 'TQ493356', 0, 0, 0, 'withyham@scacr.org', 'B2110 by Hewkins Bridge', 'Withyham', 'East Sussex', 'TN7 4BA', 'UK', '0.12862350000000', '51.10204470000000', '', 'www.withyhamchurch.org/', 'dove.cccbr.org.uk/detail.php?searchString=Withyham&numPerPage=10&Submit=Go&searchAmount=%3D&searchMetric=cwt&sortBy=Place&sortDir=Asc&DoveID=WITHYHAM', '', 1, '10:15-10:55', 1, 653, NULL, 653, 34, 0, 'Wednesday', '8:00-9:30', 'TRUE', 0, 0, NULL, NULL),
(148, 2, 'Wivelsfield', 'St John the Baptist', 6, '5-3-0', 'TQ338208', 0, 0, 0, 'wivelsfield@scacr.org', 'Church Lane', 'Wivelsfield', 'West Sussex', 'RH17 7RD', 'UK', '-0.09587310000006', '50.97112200000000', '', 'www.wivelsfieldchurch.org.uk/', 'dove.cccbr.org.uk/detail.php?searchString=Wivelsfield&numPerPage=10&Submit=Go&searchAmount=%3D&searchMetric=cwt&sortBy=Place&sortDir=Asc&DoveID=WIVELSFIEL', '', 1, '10:00-10:30', 1, 415, NULL, 418, 62, 0, 'Thursday', '8:00-9:15', 'TRUE', 0, 0, NULL, NULL),
(149, 1, 'Worth', 'St Nicholas', 6, '9-2-14', 'TQ302362', 0, 0, 0, 'worth@scacr.org', 'Church Road', 'Worth', 'West Sussex', 'RH10 7RT', 'UK', '-0.14347568215328', '51.11192702155360', '', 'www.worthparish.org.uk/', 'dove.cccbr.org.uk/detail.php?searchString=Worth&numPerPage=10&Submit=Go&searchAmount=%3D&searchMetric=cwt&sortBy=Place&sortDir=Asc&DoveID=WORTH', '', 1, '9:00-9:45; occasional evenings', 1, 437, NULL, 438, 35, 0, 'Thursday', '7:30-9:00', 'TRUE', 0, 0, NULL, NULL),
(150, 4, 'Yapton', 'St Mary', 6, '6-2-12', 'SU982035', 0, 0, 0, 'yapton@scacr.org', 'Church Rd, Yapton, West Sussex,', 'Yapton', 'West Sussex', 'BN18 0EP', 'UK', '-0.60770239660644', '50.82313642105100', '', 'www.cyfchurches.org.uk/CYFChurches/Welcome.html', 'dove.cccbr.org.uk/detail.php?searchString=Yapton&numPerPage=10&Submit=Go&searchAmount=%3D&searchMetric=cwt&sortBy=Place&sortDir=Asc&DoveID=YAPTON', '', 1, '', 1, 18, NULL, 18, 144, 0, 'Monday', '2:00-3:30', 'TRUE', 0, 0, NULL, NULL),
(151, 1, 'Warnham', 'The Bell Meadow Peal', 10, '21lb', '', 1, 0, 0, '', '', '', '', '', 'UK', '0.00000000000000', '0.00000000000000', '', '', '', '', 1, '', 1, 266, NULL, 266, 0, 0, '', '', 'TRUE', 0, 1, 838, '2017-12-31 15:49:11'),
(152, 2, 'Hurstpierpoint', 'The Wickham Ring', 8, '', '', 0, 0, 0, '', '', '', '', '', 'UK', '0.00000000000000', '0.00000000000000', '', '', '', '', 1, '', 1, 0, NULL, 0, 0, 0, '', '', 'TRUE', 0, 0, NULL, NULL),
(153, 3, 'Hooe', 'Dewbys Bells', 8, '', '', 0, 0, 0, '', '', '', '', '', 'UK', '0.00000000000000', '0.00000000000000', '', '', '', '', 1, '', 1, 0, NULL, 0, 0, 0, '', '', 'FALS', 0, 0, NULL, NULL);

--
-- Triggers `c1jr0_md_tower`
--
DROP TRIGGER IF EXISTS `md_tower_delete_trigger`;
DELIMITER $$
CREATE TRIGGER `md_tower_delete_trigger` BEFORE DELETE ON `c1jr0_md_tower` FOR EACH ROW insert into c1jr0_md_tower_history SELECT null, c1jr0_md_tower.* FROM c1jr0_md_tower WHERE c1jr0_md_tower.id = OLD.id
$$
DELIMITER ;
DROP TRIGGER IF EXISTS `md_tower_update_trigger`;
DELIMITER $$
CREATE TRIGGER `md_tower_update_trigger` BEFORE UPDATE ON `c1jr0_md_tower` FOR EACH ROW insert into c1jr0_md_tower_history SELECT null, c1jr0_md_tower.* FROM c1jr0_md_tower WHERE c1jr0_md_tower.id = NEW.id
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `c1jr0_md_tower_history`
--

DROP TABLE IF EXISTS `c1jr0_md_tower_history`;
CREATE TABLE `c1jr0_md_tower_history` (
  `history_id` int(11) NOT NULL AUTO_INCREMENT,
  `id` int(3) NOT NULL,
  `district_id` int(1) DEFAULT NULL,
  `place` varchar(40) DEFAULT NULL,
  `designation` varchar(40) DEFAULT NULL,
  `bells` int(2) DEFAULT NULL,
  `tenor` varchar(20) DEFAULT NULL,
  `grid_ref` varchar(8) DEFAULT NULL,
  `ground_floor` tinyint(1) DEFAULT NULL,
  `anti_clockwise` tinyint(1) DEFAULT NULL,
  `unringable` tinyint(1) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `street` varchar(100) DEFAULT NULL,
  `town` varchar(50) DEFAULT NULL,
  `county` varchar(50) DEFAULT NULL,
  `post_code` varchar(10) DEFAULT NULL,
  `country` varchar(2) DEFAULT NULL,
  `longitude` decimal(35,14) DEFAULT NULL,
  `latitude` decimal(35,14) DEFAULT NULL,
  `website` varchar(200) DEFAULT NULL,
  `church_website` varchar(200) DEFAULT NULL,
  `doves_guide` varchar(200) DEFAULT NULL,
  `tower_description` varchar(200) DEFAULT NULL,
  `wc` tinyint(1) DEFAULT NULL,
  `sunday_ringing` varchar(100) DEFAULT NULL,
  `active` tinyint(1) DEFAULT NULL,
  `correspondent_id` int(4) DEFAULT NULL,
  `corresp_email` varchar(100) DEFAULT NULL,
  `captain_id` int(5) DEFAULT NULL,
  `web_tower_id` int(3) DEFAULT NULL,
  `multi_towers` tinyint(1) DEFAULT NULL,
  `practice_night` varchar(17) DEFAULT NULL,
  `practice_details` varchar(200) DEFAULT NULL,
  `field1` varchar(4) DEFAULT NULL,
  `incl_capt` tinyint(1) DEFAULT NULL,
  `incl_corresp` tinyint(1) DEFAULT NULL,
  `mod_user_id` int(11) DEFAULT NULL,
  `mod_date` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`history_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `c1jr0_md_userdistrict`
--

DROP TABLE IF EXISTS `c1jr0_md_userdistrict`;
CREATE TABLE `c1jr0_md_userdistrict` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `district_id` int(2) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;

--
-- Dumping data for table `c1jr0_md_userdistrict`
--

INSERT INTO `c1jr0_md_userdistrict` (`id`, `user_id`, `district_id`) VALUES
(1, 440, 4),
(3, 440, 3);

-- --------------------------------------------------------

--
-- Table structure for table `c1jr0_md_usertower`
--

DROP TABLE IF EXISTS `c1jr0_md_usertower`;
CREATE TABLE `c1jr0_md_usertower` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `tower_id` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;

--
-- Dumping data for table `c1jr0_md_usertower`
--

INSERT INTO `c1jr0_md_usertower` (`id`, `user_id`, `tower_id`) VALUES
(1, 412, 82),
(2, 412, 138),
(3, 413, 82);


DROP TABLE IF EXISTS `c1jr0_md_new_member`;
CREATE TABLE `c1jr0_md_new_member` (
  `id` int(5) NOT NULL AUTO_INCREMENT,
  `tower_id` int(3) DEFAULT NULL,
  `forenames` varchar(50) DEFAULT NULL,
  `surname` varchar(50) DEFAULT NULL,
  `title` varchar(12) DEFAULT NULL,
  `member_type_id` int(11) NOT NULL,
  `long_service` varchar(8) NOT NULL DEFAULT 'No',
  `insurance_group` varchar(10) DEFAULT NULL,
  `annual_report` tinyint(1) DEFAULT NULL,
  `telephone` varchar(28) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `newsletters` varchar(7) DEFAULT NULL,
  `district_newsletters` int(11) NOT NULL DEFAULT '0',
  `date_elected` varchar(21) DEFAULT NULL,
  `address1` varchar(100) DEFAULT NULL,
  `address2` varchar(100) DEFAULT NULL,
  `address3` varchar(100) DEFAULT NULL,
  `town` varchar(50) DEFAULT NULL,
  `county` varchar(20) DEFAULT NULL,
  `postcode` varchar(9) DEFAULT NULL,
  `country` varchar(2) DEFAULT NULL,
  `dbs_date` varchar(10) DEFAULT NULL,
  `dbs_update` varchar(10) DEFAULT NULL,
  `mod_date` timestamp NULL DEFAULT NULL,
  `accept_privicy_policy` tinyint(1) NOT NULL DEFAULT '0',
  `soudbow_subscriber` tinyint(1) NOT NULL DEFAULT '0',
  `can_publish_name` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1700 DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `c1jr0_md_new_member_proposer`;
CREATE TABLE `c1jr0_md_new_member_proposer` (
	`id` INT NOT NULL AUTO_INCREMENT,
	`newmember_id` INT NOT NULL,
	`email` varchar(100) NOT NULL,
	`hash_token` VARCHAR(100) NOT NULL,
	`created_date` timestamp NOT NULL,
	`approved_flag` tinyint(1) DEFAULT NULL,
	PRIMARY KEY (`id`)
);
ALTER TABLE `c1jr0_md_new_member_proposer` ADD `mod_date` TIMESTAMP NULL DEFAULT NULL AFTER `approved_flag`;


ALTER TABLE `c1jr0_md_member_type` ADD `new_member_type` BOOLEAN NOT NULL DEFAULT FALSE AFTER `enabled`;

update `c1jr0_md_member_type` set `new_member_type` = 1 where id in (1, 5, 7);
