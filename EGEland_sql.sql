SELECT
    -- Информация про курс
    courses.id as ID_курса,
    courses.name as Название_курса,
    subjects.name as Предмет,
    subjects.project as Тип_предмета,
    course_types.name as Тип_курса,
    courses.starts_at as Дата_старта_курса,

    -- Информация про ученика
    course_users.user_id as ID_ученика,
    users.last_name as Фамилия_ученика,
    cities.name as Город_ученика,
    course_users.active as Ученик_не_отчислен_с_курса,
    course_users.created_at as Дата_открытия_курса_ученику,
    
    -- Считаем открытые полные месяцы, как число открытых уроков/кол-во уроков в месяц на данном курсе
    -- остаток не учитываем, тк в данном случае получится неполный месяц
    CASE 
        WHEN courses.lessons_in_month > 0 
            THEN FLOOR(course_users.available_lessons / courses.lessons_in_month)
        ELSE 0 
    END as Число_открытых_полных_месяцев_курса,
    
    -- Посчитаем количество сданных дз, как уникальный с соответсующими id
    COUNT(DISTINCT homework_done.homework_id) AS Число_сданных_дз
    
FROM
    -- LEFT JOIN на случаи вдруг какой-то информации нет в табличке, чтобы выдавало вместо нее NULL
    courses
    LEFT JOIN subjects on courses.subject_id = subjects.id
    LEFT JOIN course_types on courses.course_type_id = course_types.id
    
    LEFT JOIN course_users on course_users.course_id = courses.id
    INNER JOIN users on course_users.user_id = users.id
    LEFT JOIN cities on cities.id = users.city_id
    
    LEFT JOIN lessons on courses.id = lessons.course_id
    LEFT JOIN homework_lessons on lessons.id = homework_lessons.lesson_id
    LEFT JOIN homework_done on homework_done.homework_id = homework_lessons.homework_id
        AND course_users.user_id = homework_done.user_id
WHERE
    -- Фильтруем необходимую информацию
    course_types.name like '%Годовой%' and subjects.project in ('ОГЭ','ЕГЭ')
GROUP BY
    -- Группируем для подсчета количества сделанных дз
    courses.id, courses.name,
    subjects.name, subjects.project,
    course_types.name,
    courses.starts_at,
    
    course_users.user_id,
    users.last_name,
    cities.name,
    course_users.active,
    course_users.created_at,
    
    lessons_in_month,
    course_users.available_lessons