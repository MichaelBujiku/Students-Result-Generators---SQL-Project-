with cte_marks as
		( select student_id, s.name, column1 as subject_code, column2 as marks 
		  from student_marks sm
		  cross join lateral(values ('subject1', subject1), ('subject2', subject2),('subject3', subject3),
						  ('subject4', subject4), ('subject5', subject5), ('subject6', subject6)) x
		  join students s on s.roll_no = sm.student_id
		  where column2 is not null),
	  
	  cte_sub as
		  (select subject_code, subject_name, pass_marks
		   from( select row_number() over (order by ordinal_position) as rn, column_name as subject_code
				  from information_schema.columns 
				  where table_name = 'student_marks' and column_name like 'subject%') a
			join ( select row_number() over (order by id) as rn, name as subject_name, pass_marks
				   from subjects) b
				   on b.rn = a.rn),
				   
	  cte_agg as
			(select student_id, name
			 , round(avg(marks), 2) as average_marks
			 , string_agg(case when marks >= pass_marks then null else subject_name end, ' , ') as failed_subject
			 from cte_marks cm
			 join cte_sub cs on cs.subject_code = cm.subject_code
			 group by student_id, name)
select student_id, name, average_marks, coalesce(failed_subject, '-') as failed_subject
, case when failed_subject is not null then 'Fail'
	   when average_marks >= 70 then 'First Class'
	   when average_marks between 50 and 70 then 'Second Class'
	   when average_marks < 50 then 'Third Class' end as Result
from cte_agg;





