-- Create the database
CREATE DATABASE IF NOT EXISTS aula_virtual;
USE aula_virtual;

-- User table (supertype)
CREATE TABLE User (
    id INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    phone VARCHAR(20),
    photo VARCHAR(255),
    status ENUM('active', 'inactive', 'suspended') DEFAULT 'active',
    type ENUM('student', 'tutor', 'administrator') NOT NULL,
    registration_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    last_access DATETIME,
    recovery_token VARCHAR(255),
    token_expiration DATETIME
);

-- Student table (subtype)
CREATE TABLE Student (
    user_id INT PRIMARY KEY,
    university VARCHAR(100) NOT NULL,
    major VARCHAR(100) NOT NULL,
    semester INT,
    credits_earned INT DEFAULT 0,
    FOREIGN KEY (user_id) REFERENCES User(id) ON DELETE CASCADE
);

-- Tutor table (subtype)
CREATE TABLE Tutor (
    user_id INT PRIMARY KEY,
    university VARCHAR(100) NOT NULL,
    degree VARCHAR(100),
    experience TEXT,
    bio TEXT,
    rating DECIMAL(3,2) DEFAULT 0.00,
    tutoring_hours INT DEFAULT 0,
    FOREIGN KEY (user_id) REFERENCES User(id) ON DELETE CASCADE
);

-- Administrator table (subtype)
CREATE TABLE Administrator (
    user_id INT PRIMARY KEY,
    department VARCHAR(100) NOT NULL,
    access_level ENUM('basic', 'medium', 'high') DEFAULT 'medium',
    FOREIGN KEY (user_id) REFERENCES User(id) ON DELETE CASCADE
);

-- Subject table
CREATE TABLE Subject (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    area VARCHAR(50),
    code VARCHAR(20) UNIQUE,
    difficulty_level ENUM('basic', 'intermediate', 'advanced')
);

-- Tutoring table
CREATE TABLE Tutoring (
    id INT AUTO_INCREMENT PRIMARY KEY,
    tutor_id INT NOT NULL,
    description TEXT NOT NULL,
    level ENUM('basic', 'intermediate', 'advanced') NOT NULL,
    modality ENUM('in_person', 'virtual', 'both') NOT NULL,
    status ENUM('active', 'inactive', 'under_review') DEFAULT 'active',
    creation_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    price DECIMAL(10,2) DEFAULT 0.00, -- For future expansion
    requires_approval BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (tutor_id) REFERENCES Tutor(user_id)
);

-- Tutoring-Subject relationship table (M:N)
CREATE TABLE TutoringSubject (
    tutoring_id INT NOT NULL,
    subject_id INT NOT NULL,
    is_primary BOOLEAN DEFAULT TRUE,
    PRIMARY KEY (tutoring_id, subject_id),
    FOREIGN KEY (tutoring_id) REFERENCES Tutoring(id) ON DELETE CASCADE,
    FOREIGN KEY (subject_id) REFERENCES Subject(id)
);

-- Session table (now supports multiple students)
CREATE TABLE Session (
    id INT AUTO_INCREMENT PRIMARY KEY,
    tutoring_id INT NOT NULL,
    date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    status ENUM('pending', 'confirmed', 'completed', 'canceled') DEFAULT 'pending',
    virtual_link VARCHAR(255),
    physical_location VARCHAR(255),
    max_capacity INT DEFAULT 1,
    price DECIMAL(10,2) DEFAULT 0.00, -- For future expansion
    reminder_sent BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (tutoring_id) REFERENCES Tutoring(id) ON DELETE CASCADE
);

-- Session enrollment table (M:N relationship)
CREATE TABLE SessionEnrollment (
    id INT AUTO_INCREMENT PRIMARY KEY,
    session_id INT NOT NULL,
    student_id INT NOT NULL,
    enrollment_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    status ENUM('confirmed', 'waitlisted', 'canceled', 'attended', 'did_not_attend') DEFAULT 'confirmed',
    tutor_rating INT CHECK (tutor_rating BETWEEN 1 AND 5 OR tutor_rating IS NULL),
    tutor_feedback TEXT,
    UNIQUE KEY (session_id, student_id),
    FOREIGN KEY (session_id) REFERENCES Session(id) ON DELETE CASCADE,
    FOREIGN KEY (student_id) REFERENCES Student(user_id)
);

-- Rating table (two types: tutoring and session)
CREATE TABLE Rating (
    id INT AUTO_INCREMENT PRIMARY KEY,
    type ENUM('tutoring', 'session') NOT NULL,
    tutoring_id INT DEFAULT NULL,
    session_id INT DEFAULT NULL,
    evaluator_id INT NOT NULL,
    evaluated_id INT NOT NULL,
    score DECIMAL(3,2) NOT NULL CHECK (score >= 0 AND score <= 5),
    comment TEXT,
    active TINYINT(1) NOT NULL DEFAULT 1, -- 1 = active, 0 = logical deletion
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (tutoring_id) REFERENCES Tutoring(id),
    FOREIGN KEY (session_id) REFERENCES Session(id),
    FOREIGN KEY (evaluator_id) REFERENCES User(id),
    FOREIGN KEY (evaluated_id) REFERENCES User(id)
);

-- Message table
CREATE TABLE Message (
    id INT AUTO_INCREMENT PRIMARY KEY,
    sender_id INT NOT NULL,
    receiver_id INT NOT NULL,
    subject VARCHAR(100),
    text TEXT NOT NULL,
    send_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    read_date DATETIME,
    status ENUM('sent', 'read', 'archived') DEFAULT 'sent',
    is_system BOOLEAN DEFAULT FALSE, -- For automatic system messages
    FOREIGN KEY (sender_id) REFERENCES User(id),
    FOREIGN KEY (receiver_id) REFERENCES User(id)
);

-- EducationalResource table enhanced
CREATE TABLE EducationalResource (
    id INT AUTO_INCREMENT PRIMARY KEY,
    tutoring_id INT DEFAULT NULL,
    session_id INT DEFAULT NULL,
    tutor_id INT NOT NULL,
    type ENUM('document', 'video', 'link', 'presentation', 'exercise') NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    url TEXT NOT NULL,
    active TINYINT(1) NOT NULL DEFAULT 1,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (tutoring_id) REFERENCES Tutoring(id),
    FOREIGN KEY (session_id) REFERENCES Session(id),
    FOREIGN KEY (tutor_id) REFERENCES User(id)
);

-- Reward table for gamification
CREATE TABLE Reward (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    required_points INT NOT NULL,
    image VARCHAR(255),
    type ENUM('badge', 'certificate', 'benefit') NOT NULL,
    level ENUM('bronze', 'silver', 'gold', 'platinum') DEFAULT 'bronze',
    creation_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    is_exclusive BOOLEAN DEFAULT FALSE
);

-- User-Reward relationship table (Earned)
CREATE TABLE UserReward (
    user_id INT NOT NULL,
    reward_id INT NOT NULL,
    acquisition_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    message TEXT,
    PRIMARY KEY (user_id, reward_id),
    FOREIGN KEY (user_id) REFERENCES User(id) ON DELETE CASCADE,
    FOREIGN KEY (reward_id) REFERENCES Reward(id)
);

-- Gamification points tracking table
CREATE TABLE UserPoints (
    user_id INT PRIMARY KEY,
    points INT DEFAULT 0,
    level INT DEFAULT 1,
    badges INT DEFAULT 0,
    last_update DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES User(id) ON DELETE CASCADE
);

-- Security logs table
CREATE TABLE ActivityLog (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    action VARCHAR(100) NOT NULL,
    date DATETIME DEFAULT CURRENT_TIMESTAMP,
    ip VARCHAR(45),
    user_agent TEXT,
    details TEXT,
    FOREIGN KEY (user_id) REFERENCES User(id) ON DELETE SET NULL
);

-- Notification table
CREATE TABLE Notification (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    title VARCHAR(100) NOT NULL,
    message TEXT NOT NULL,
    type ENUM('system', 'message', 'tutoring', 'reminder') NOT NULL,
    creation_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    read_date DATETIME,
    status ENUM('new', 'read', 'archived') DEFAULT 'new',
    link VARCHAR(255),
    FOREIGN KEY (user_id) REFERENCES User(id) ON DELETE CASCADE
);

-- Tutor availability table
CREATE TABLE TutorAvailability (
    id INT AUTO_INCREMENT PRIMARY KEY,
    tutor_id INT NOT NULL,
    weekday ENUM('monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday') NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    is_recurring BOOLEAN DEFAULT TRUE,
    start_date DATE,
    end_date DATE,
    FOREIGN KEY (tutor_id) REFERENCES Tutor(user_id) ON DELETE CASCADE
);

-- Technical support requests table
CREATE TABLE TechnicalSupport (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    subject VARCHAR(100) NOT NULL,
    description TEXT NOT NULL,
    status ENUM('open', 'in_progress', 'resolved', 'closed') DEFAULT 'open',
    creation_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    closure_date DATETIME,
    priority ENUM('low', 'medium', 'high', 'critical') DEFAULT 'medium',
    assigned_administrator INT,
    solution TEXT,
    FOREIGN KEY (user_id) REFERENCES User(id),
    FOREIGN KEY (assigned_administrator) REFERENCES Administrator(user_id)
);

-- Indexes to improve performance
CREATE INDEX idx_user_email ON User(email);
CREATE INDEX idx_tutoring_tutor ON Tutoring(tutor_id);
CREATE INDEX idx_session_tutoring ON Session(tutoring_id);
CREATE INDEX idx_enrollment_student ON SessionEnrollment(student_id);
CREATE INDEX idx_rating_evaluated ON Rating(evaluated_id);
CREATE INDEX idx_resource_tutor ON EducationalResource(tutor_id);
CREATE INDEX idx_notification_user ON Notification(user_id);
CREATE INDEX idx_activity_log_date ON ActivityLog(date);

DELIMITER //

CREATE TRIGGER trg_validate_resource
BEFORE INSERT ON EducationalResource
FOR EACH ROW
BEGIN
    IF NEW.tutoring_id IS NULL AND NEW.session_id IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'The resource must be associated with a tutoring or session';
    END IF;
END;
CREATE TRIGGER trg_update_rating
BEFORE UPDATE ON Rating
FOR EACH ROW
BEGIN
    SET NEW.updated_at = CURRENT_TIMESTAMP;
END;
//

DELIMITER ;

INSERT INTO User (email, password, first_name, last_name, phone, photo, status, type)
VALUES ('juan.perez@example.com', 'secure_password', 'Juan', 'Perez', '123456789', 'photo_juan.jpg', 'active', 'student');

-- Get the ID of the newly created user
SET @user_id = LAST_INSERT_ID();

-- Insert the corresponding data into the Student table
INSERT INTO Student (user_id, university, major, semester, credits_earned)
VALUES (@user_id, 'National University', 'Computer Engineering', 3, 25);
