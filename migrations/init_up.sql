-- Initial schema for AUCA student portal.
CREATE TABLE users (
                       id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
                       email text NOT NULL UNIQUE,
                       full_name text NOT NULL,
                       role text NOT NULL CHECK (role IN ('student', 'advisor', 'staff', 'admin')),
                       created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE students (
                          id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
                          user_id bigint NOT NULL REFERENCES users(id) ON DELETE CASCADE,
                          student_number text NOT NULL UNIQUE,
                          program text,
                          year_level int CHECK (year_level BETWEEN 1 AND 6),
                          status text NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'leave', 'graduated', 'dismissed'))
);

CREATE TABLE departments (
                             id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
                             name text NOT NULL UNIQUE,
                             code text NOT NULL UNIQUE
);

CREATE TABLE courses (
                         id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
                         department_id bigint REFERENCES departments(id) ON DELETE SET NULL,
                         code text NOT NULL UNIQUE,
                         title text NOT NULL,
                         credits int NOT NULL CHECK (credits BETWEEN 1 AND 12),
                         description text
);

CREATE TABLE terms (
                       id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
                       name text NOT NULL UNIQUE,
                       start_date date NOT NULL,
                       end_date date NOT NULL,
                       CHECK (end_date > start_date)
);

CREATE TABLE sections (
                          id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
                          course_id bigint NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
                          term_id bigint NOT NULL REFERENCES terms(id) ON DELETE CASCADE,
                          section_code text NOT NULL,
                          instructor text,
                          room text,
                          capacity int NOT NULL DEFAULT 30 CHECK (capacity > 0),
                          meeting_days text,
                          meeting_time text,
                          UNIQUE (course_id, term_id, section_code)
);

CREATE TABLE enrollments (
                             id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
                             student_id bigint NOT NULL REFERENCES students(id) ON DELETE CASCADE,
                             section_id bigint NOT NULL REFERENCES sections(id) ON DELETE CASCADE,
                             status text NOT NULL DEFAULT 'enrolled' CHECK (status IN ('enrolled', 'waitlisted', 'dropped', 'completed')),
                             enrolled_at timestamptz NOT NULL DEFAULT now(),
                             UNIQUE (student_id, section_id)
);

CREATE TABLE grades (
                        id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
                        enrollment_id bigint NOT NULL REFERENCES enrollments(id) ON DELETE CASCADE,
                        letter text NOT NULL CHECK (letter IN ('A', 'A-', 'B+', 'B', 'B-', 'C+', 'C', 'C-', 'D', 'F', 'I', 'W')),
                        points numeric(3,2),
                        updated_at timestamptz NOT NULL DEFAULT now(),
                        UNIQUE (enrollment_id)
);

CREATE TABLE milestones (
                            id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
                            student_id bigint NOT NULL REFERENCES students(id) ON DELETE CASCADE,
                            title text NOT NULL,
                            detail text,
                            status text NOT NULL DEFAULT 'open' CHECK (status IN ('open', 'waiting', 'next', 'closed')),
                            due_at date
);

CREATE TABLE schedule_events (
                                 id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
                                 student_id bigint NOT NULL REFERENCES students(id) ON DELETE CASCADE,
                                 title text NOT NULL,
                                 event_date date NOT NULL,
                                 start_time time,
                                 end_time time,
                                 location text
);

CREATE TABLE study_plans (
                             id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
                             student_id bigint NOT NULL REFERENCES students(id) ON DELETE CASCADE,
                             title text NOT NULL,
                             status text NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'archived')),
                             created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE study_plan_items (
                                  id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
                                  study_plan_id bigint NOT NULL REFERENCES study_plans(id) ON DELETE CASCADE,
                                  course_id bigint REFERENCES courses(id) ON DELETE SET NULL,
                                  term_id bigint REFERENCES terms(id) ON DELETE SET NULL,
                                  status text NOT NULL DEFAULT 'planned' CHECK (status IN ('planned', 'in_progress', 'done')),
                                  notes text
);

CREATE INDEX students_user_id_idx ON students(user_id);
CREATE INDEX courses_department_id_idx ON courses(department_id);
CREATE INDEX sections_term_id_idx ON sections(term_id);
CREATE INDEX sections_course_id_idx ON sections(course_id);
CREATE INDEX enrollments_student_id_idx ON enrollments(student_id);
CREATE INDEX enrollments_section_id_idx ON enrollments(section_id);
CREATE INDEX grades_enrollment_id_idx ON grades(enrollment_id);
CREATE INDEX milestones_student_id_idx ON milestones(student_id);
CREATE INDEX schedule_events_student_id_idx ON schedule_events(student_id);
CREATE INDEX study_plans_student_id_idx ON study_plans(student_id);
CREATE INDEX study_plan_items_plan_id_idx ON study_plan_items(study_plan_id);
